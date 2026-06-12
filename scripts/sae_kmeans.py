from pathlib import Path
import csv

import numpy as np
import rasterio
import matplotlib.pyplot as plt

from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans

import torch
from torch import nn
from torch.utils.data import TensorDataset, DataLoader

from plot_style import DPI_LINE, DPI_RASTER, apply_report_style


ROOT = Path(__file__).parent.parent.resolve()
PROCESSED = ROOT / "data" / "processed"
OUT_DIR = ROOT / "results" / "cluster_sae"
OUT_DIR.mkdir(parents=True, exist_ok=True)

NPZ_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_pixels.npz"
MASK_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif"
REF_TIF = PROCESSED / "s2_tuwu_yandong_20240813_stack_20m_masked.tif"

RANDOM_STATE = 42
K = 6
BOTTLENECK_DIM = 5
TRAIN_SAMPLE_SIZE = 300_000
BATCH_SIZE = 4096
EPOCHS = 30
LR = 1e-3

apply_report_style()


class SAE(nn.Module):
    def __init__(self, input_dim=10, bottleneck_dim=3):
        super().__init__()

        self.encoder = nn.Sequential(
            nn.Linear(input_dim, 32),
            nn.ReLU(),
            nn.Linear(32, 16),
            nn.ReLU(),
            nn.Linear(16, bottleneck_dim),
        )

        self.decoder = nn.Sequential(
            nn.Linear(bottleneck_dim, 16),
            nn.ReLU(),
            nn.Linear(16, 32),
            nn.ReLU(),
            nn.Linear(32, input_dim),
        )

    def forward(self, x):
        z = self.encoder(x)
        x_hat = self.decoder(z)
        return x_hat

    def encode(self, x):
        return self.encoder(x)


def save_cluster_png(label_map, out_png):
    img = label_map.astype(np.float32)
    img[img < 0] = np.nan

    plt.figure(figsize=(8, 8))
    plt.imshow(img, cmap="tab20")
    plt.axis("off")
    plt.title(f"SAE + K-means clustering result, k={K}")
    plt.tight_layout()
    plt.savefig(out_png, dpi=DPI_RASTER, bbox_inches="tight")
    plt.close()


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

    # 2. 抽样训练 SAE
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

    model = SAE(input_dim=X_scaled.shape[1], bottleneck_dim=BOTTLENECK_DIM).to(device)
    optimizer = torch.optim.Adam(model.parameters(), lr=LR)
    loss_fn = nn.MSELoss()

    # 3. 训练 SAE
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
    plt.figure(figsize=(7, 5))
    plt.plot(range(1, EPOCHS + 1), loss_log, marker="o", color="#0072B2", linewidth=1.5)
    plt.xlabel("Epoch / count")
    plt.ylabel("Reconstruction MSE / 1")
    plt.title("SAE training loss")
    plt.grid(axis="y", alpha=0.15)
    plt.tight_layout()
    plt.savefig(OUT_DIR / f"sae_training_loss_z{BOTTLENECK_DIM}.png", dpi=DPI_LINE)
    plt.close()

    with open(OUT_DIR / f"sae_training_loss_z{BOTTLENECK_DIM}.csv", "w", newline="", encoding="utf-8") as f:
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
        OUT_DIR / f"sae_encoded_features_z{BOTTLENECK_DIM}.npz",
        Z=Z,
        band_order=band_order,
        bottleneck_dim=BOTTLENECK_DIM,
    )

    # 6. 在 SAE 低维特征上做 k-means
    km = KMeans(
        n_clusters=K,
        random_state=RANDOM_STATE,
        n_init=10,
        max_iter=300,
    )
    labels = km.fit_predict(Z).astype(np.int16)

    print("KMeans inertia on SAE features:", km.inertia_)

    # 7. 还原为二维 label map
    with rasterio.open(MASK_PATH) as src:
        valid_mask = src.read(1).astype(bool)

    label_map = np.full(valid_mask.shape, -1, dtype=np.int16)
    label_map[valid_mask] = labels

    # 8. 保存 GeoTIFF
    with rasterio.open(REF_TIF) as ref:
        profile = ref.profile.copy()
        profile.update(
            count=1,
            dtype="int16",
            nodata=-1,
            compress="lzw",
        )

    out_tif = OUT_DIR / f"sae_kmeans_k{K}_z{BOTTLENECK_DIM}.tif"
    with rasterio.open(out_tif, "w", **profile) as dst:
        dst.write(label_map, 1)

    # 9. 保存 PNG 预览
    save_cluster_png(label_map, OUT_DIR / f"sae_kmeans_k{K}_z{BOTTLENECK_DIM}.png")

    # 10. 保存每类像元数量
    unique, counts = np.unique(labels, return_counts=True)
    with open(OUT_DIR / f"sae_kmeans_k{K}_z{BOTTLENECK_DIM}_class_counts.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["cluster_id", "pixel_count", "percentage"])
        for u, c in zip(unique, counts):
            writer.writerow([int(u), int(c), float(c / labels.size)])

    # 11. 保存模型
    torch.save(
        {
            "model_state_dict": model.state_dict(),
            "input_dim": X_scaled.shape[1],
            "bottleneck_dim": BOTTLENECK_DIM,
            "band_order": band_order,
            "scaler_mean": scaler.mean_,
            "scaler_scale": scaler.scale_,
        },
        OUT_DIR / f"sae_model_z{BOTTLENECK_DIM}.pt",
    )

    print("Saved outputs to:", OUT_DIR)
    print("Done.")


if __name__ == "__main__":
    main()
