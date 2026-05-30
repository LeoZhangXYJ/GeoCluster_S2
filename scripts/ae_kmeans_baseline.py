from pathlib import Path
import csv

import numpy as np
import rasterio
import matplotlib.pyplot as plt

from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score, davies_bouldin_score, calinski_harabasz_score

import torch
from torch import nn
from torch.utils.data import TensorDataset, DataLoader


ROOT = Path(__file__).parent.parent.resolve()
PROCESSED = ROOT / "data" / "processed"
OUT_DIR = ROOT / "results" / "cluster_ae"
OUT_DIR.mkdir(parents=True, exist_ok=True)

NPZ_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_pixels.npz"
MASK_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif"
REF_TIF = PROCESSED / "s2_tuwu_yandong_20240813_stack_20m_masked.tif"

RANDOM_STATE = 42
BOTTLENECK_DIM = 5
K = 6
TRAIN_SAMPLE_SIZE = 300_000
BATCH_SIZE = 4096
EPOCHS = 30
LR = 1e-3
METRIC_SAMPLE = 100_000


class CanonicalAE(nn.Module):
    """浅层自编码器：10 → 16 → z → 16 → 10，与 SAE 的 10→32→16→z→16→32→10 对比。"""

    def __init__(self, input_dim=10, bottleneck_dim=5):
        super().__init__()

        self.encoder = nn.Sequential(
            nn.Linear(input_dim, 16),
            nn.ReLU(),
            nn.Linear(16, bottleneck_dim),
        )

        self.decoder = nn.Sequential(
            nn.Linear(bottleneck_dim, 16),
            nn.ReLU(),
            nn.Linear(16, input_dim),
        )

    def forward(self, x):
        z = self.encoder(x)
        x_hat = self.decoder(z)
        return x_hat

    def encode(self, x):
        return self.encoder(x)


def save_cluster_png(label_map, out_png, title):
    img = label_map.astype(np.float32)
    img[img < 0] = np.nan
    plt.figure(figsize=(8, 8))
    plt.imshow(img, cmap="tab20")
    plt.axis("off")
    plt.title(title)
    plt.tight_layout()
    plt.savefig(out_png, dpi=300, bbox_inches="tight")
    plt.close()


def compute_cluster_metrics(features, labels):
    n = features.shape[0]
    if n > METRIC_SAMPLE:
        rng = np.random.default_rng(RANDOM_STATE)
        idx = rng.choice(n, size=METRIC_SAMPLE, replace=False)
        feats = features[idx]
        labs = labels[idx]
    else:
        feats = features
        labs = labels

    sil = silhouette_score(feats, labs, random_state=RANDOM_STATE)
    db = davies_bouldin_score(feats, labs)
    ch = calinski_harabasz_score(feats, labs)
    return sil, db, ch


def main():
    np.random.seed(RANDOM_STATE)
    torch.manual_seed(RANDOM_STATE)

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print("Device:", device)

    data = np.load(NPZ_PATH, allow_pickle=True)
    X = data["X"].astype(np.float32)
    band_order = data["band_order"]
    print("X shape:", X.shape)
    print("Band order:", band_order)

    # 1. 标准化
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X).astype(np.float32)

    # 2. 抽样训练 Canonical AE
    n = X_scaled.shape[0]
    train_n = min(TRAIN_SAMPLE_SIZE, n)
    rng = np.random.default_rng(RANDOM_STATE)
    train_idx = rng.choice(n, size=train_n, replace=False)
    X_train = X_scaled[train_idx]

    train_tensor = torch.from_numpy(X_train)
    loader = DataLoader(
        TensorDataset(train_tensor),
        batch_size=BATCH_SIZE,
        shuffle=True,
        drop_last=False,
    )

    model = CanonicalAE(input_dim=X_scaled.shape[1], bottleneck_dim=BOTTLENECK_DIM).to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=LR)
    loss_fn = nn.MSELoss()

    # 3. 训练
    loss_log = []
    for epoch in range(1, EPOCHS + 1):
        model.train()
        total_loss = 0.0
        total_count = 0

        for (xb,) in loader:
            xb = xb.to(device)
            optimizer.zero_grad()
            x_hat = model(xb)
            loss = loss_fn(x_hat, xb)
            loss.backward()
            optimizer.step()

            total_loss += loss.item() * xb.size(0)
            total_count += xb.size(0)

        avg_loss = total_loss / total_count
        loss_log.append(avg_loss)
        print(f"Epoch {epoch:03d}/{EPOCHS}, recon_loss={avg_loss:.6f}")

    # 4. 保存 loss 曲线
    fig, ax = plt.subplots(figsize=(7, 5))
    ax.plot(range(1, EPOCHS + 1), loss_log, marker="o")
    ax.set_xlabel("Epoch")
    ax.set_ylabel("Reconstruction MSE")
    ax.set_title(f"Canonical AE training loss (z={BOTTLENECK_DIM})")
    fig.tight_layout()
    fig.savefig(OUT_DIR / f"ae_training_loss_z{BOTTLENECK_DIM}.png", dpi=300)
    plt.close()

    with open(OUT_DIR / f"ae_training_loss_z{BOTTLENECK_DIM}.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["epoch", "reconstruction_mse"])
        for i, loss in enumerate(loss_log, start=1):
            writer.writerow([i, loss])

    # 5. 编码所有有效像元
    model.eval()
    Z_list = []
    full_tensor = torch.from_numpy(X_scaled)
    full_loader = DataLoader(
        TensorDataset(full_tensor),
        batch_size=65536,
        shuffle=False,
        drop_last=False,
    )

    with torch.no_grad():
        for (xb,) in full_loader:
            xb = xb.to(device)
            z = model.encode(xb).cpu().numpy().astype(np.float32)
            Z_list.append(z)

    Z = np.vstack(Z_list)
    print("Encoded feature shape:", Z.shape)

    np.savez_compressed(
        OUT_DIR / f"ae_encoded_features_z{BOTTLENECK_DIM}.npz",
        Z=Z,
        band_order=band_order,
        bottleneck_dim=BOTTLENECK_DIM,
    )

    # 6. K-means
    km = KMeans(n_clusters=K, random_state=RANDOM_STATE, n_init=10, max_iter=300)
    labels = km.fit_predict(Z).astype(np.int16)
    print(f"KMeans inertia on AE features: {km.inertia_:.2f}")

    # 7. 聚类指标
    sil, db, ch = compute_cluster_metrics(Z, labels)
    print(f"Silhouette: {sil:.4f}, Davies-Bouldin: {db:.4f}, Calinski-Harabasz: {ch:.2f}")

    # 8. 还原为二维 label map
    with rasterio.open(MASK_PATH) as src:
        valid_mask = src.read(1).astype(bool)

    label_map = np.full(valid_mask.shape, -1, dtype=np.int16)
    label_map[valid_mask] = labels

    # 9. 保存 GeoTIFF
    with rasterio.open(REF_TIF) as ref:
        profile = ref.profile.copy()
        profile.update(count=1, dtype="int16", nodata=-1, compress="lzw")

    out_tif = OUT_DIR / f"ae_kmeans_k{K}_z{BOTTLENECK_DIM}.tif"
    with rasterio.open(out_tif, "w", **profile) as dst:
        dst.write(label_map, 1)

    # 10. 保存 PNG
    save_cluster_png(
        label_map,
        OUT_DIR / f"ae_kmeans_k{K}_z{BOTTLENECK_DIM}.png",
        f"Canonical AE ({BOTTLENECK_DIM}D) + K-means, k={K}",
    )

    # 11. 类别分布
    unique, counts = np.unique(labels, return_counts=True)
    class_pcts = counts / counts.sum()
    max_pct = float(class_pcts.max())
    min_pct = float(class_pcts[class_pcts > 0.01].min()) if (class_pcts > 0.01).any() else float(class_pcts.min())

    with open(OUT_DIR / f"ae_kmeans_k{K}_z{BOTTLENECK_DIM}_class_counts.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["cluster_id", "pixel_count", "percentage"])
        for u, c, p in zip(unique, counts, class_pcts):
            writer.writerow([int(u), int(c), float(p)])

    # 12. 指标 CSV
    with open(OUT_DIR / "ae_metrics.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["method", "z", "k", "inertia", "silhouette",
                         "davies_bouldin", "calinski_harabasz",
                         "max_class_ratio", "min_class_ratio_gt1pct", "recon_mse"])
        writer.writerow(["Canonical AE + K-means", BOTTLENECK_DIM, K,
                         float(km.inertia_), float(sil), float(db), float(ch),
                         max_pct, min_pct, loss_log[-1]])

    # 13. 保存模型
    torch.save(
        {
            "model_state_dict": model.state_dict(),
            "input_dim": X_scaled.shape[1],
            "bottleneck_dim": BOTTLENECK_DIM,
            "band_order": band_order,
            "scaler_mean": scaler.mean_,
            "scaler_scale": scaler.scale_,
        },
        OUT_DIR / f"ae_model_z{BOTTLENECK_DIM}.pt",
    )

    print(f"\n=== Canonical AE z={BOTTLENECK_DIM}, k={K} summary ===")
    print(f"  Reconstructed MSE: {loss_log[-1]:.6f}")
    print(f"  Silhouette: {sil:.4f}")
    print(f"  Davies-Bouldin: {db:.4f}")
    print(f"  Calinski-Harabasz: {ch:.1f}")
    print(f"  Max class ratio: {max_pct:.4f}")
    print(f"  Min class ratio (>1%): {min_pct:.4f}")

    print("\nSaved outputs to:", OUT_DIR)
    print("Done.")


if __name__ == "__main__":
    main()
