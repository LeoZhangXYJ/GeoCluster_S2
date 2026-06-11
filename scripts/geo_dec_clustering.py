"""Geo-DEC clustering for Sentinel-2 lithological mapping.

This script extends the SAE + K-means baseline with three additions:
1. geology-aware spectral ratios,
2. 3x3 mask-aware spatial context features,
3. a DEC-style clustering loss jointly optimized with reconstruction loss.
"""
from pathlib import Path
import csv
import os
import time

_NUM_THREADS = os.getenv("GEODEC_NUM_THREADS")
if _NUM_THREADS:
    for _var in ("OMP_NUM_THREADS", "MKL_NUM_THREADS", "OPENBLAS_NUM_THREADS", "NUMEXPR_NUM_THREADS"):
        os.environ.setdefault(_var, _NUM_THREADS)
    os.environ.setdefault("GDAL_NUM_THREADS", "ALL_CPUS")

import numpy as np
import rasterio
import matplotlib.pyplot as plt

from sklearn.cluster import KMeans
from sklearn.metrics import (
    calinski_harabasz_score,
    davies_bouldin_score,
    silhouette_score,
)
from sklearn.preprocessing import StandardScaler

import torch
from torch import nn
import torch.nn.functional as F
from torch.utils.data import DataLoader, TensorDataset


ROOT = Path(__file__).parent.parent.resolve()
PROCESSED = ROOT / "data" / "processed"
OUT_DIR = ROOT / "results" / "cluster_geo_dec"
OUT_DIR.mkdir(parents=True, exist_ok=True)

STACK_PATH = PROCESSED / "s2_tuwu_yandong_20240813_stack_20m_masked.tif"
MASK_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif"
REF_TIF = STACK_PATH

BAND_NAMES = ["B02", "B03", "B04", "B05", "B06", "B07", "B08", "B8A", "B11", "B12"]
BAND_INDEX = {name: idx for idx, name in enumerate(BAND_NAMES)}

RANDOM_STATE = 42
K = 6
BOTTLENECK_DIM = 5
TRAIN_SAMPLE_SIZE = int(os.getenv("GEODEC_TRAIN_SAMPLE_SIZE", "300000"))
BATCH_SIZE = int(os.getenv("GEODEC_BATCH_SIZE", "4096"))
PRETRAIN_EPOCHS = int(os.getenv("GEODEC_PRETRAIN_EPOCHS", "30"))
DEC_EPOCHS = int(os.getenv("GEODEC_DEC_EPOCHS", "20"))
LR = float(os.getenv("GEODEC_LR", "0.001"))
DEC_LR = float(os.getenv("GEODEC_DEC_LR", "0.0005"))
DEC_WEIGHT = float(os.getenv("GEODEC_DEC_WEIGHT", "0.1"))
DEC_ALPHA = 1.0
METRIC_SAMPLE = int(os.getenv("GEODEC_METRIC_SAMPLE", "100000"))
ENCODE_BATCH_SIZE = int(os.getenv("GEODEC_ENCODE_BATCH_SIZE", "65536"))
QUICK_PIXELS = int(os.getenv("GEODEC_QUICK_PIXELS", "0"))
KMEANS_N_INIT = int(os.getenv("GEODEC_KMEANS_N_INIT", "10"))
PROGRESS_EVERY = int(os.getenv("GEODEC_PROGRESS_EVERY", "10"))


def format_seconds(seconds):
    seconds = int(seconds)
    if seconds < 60:
        return f"{seconds}s"
    minutes, seconds = divmod(seconds, 60)
    if minutes < 60:
        return f"{minutes}m{seconds:02d}s"
    hours, minutes = divmod(minutes, 60)
    return f"{hours}h{minutes:02d}m{seconds:02d}s"


def progress_line(stage, current, total, start_time):
    pct = 100.0 * current / max(total, 1)
    elapsed = time.time() - start_time
    rate = current / elapsed if elapsed > 0 else 0.0
    remaining = (total - current) / rate if rate > 0 else 0.0
    print(
        f"{stage}: {current}/{total} ({pct:5.1f}%), "
        f"elapsed={format_seconds(elapsed)}, eta={format_seconds(remaining)}",
        flush=True,
    )


def should_report(current, total, every_percent=PROGRESS_EVERY):
    if current >= total:
        return True
    if every_percent <= 0:
        return False
    step = max(1, int(np.ceil(total * every_percent / 100.0)))
    return current == 1 or current % step == 0


class GeoDEC(nn.Module):
    def __init__(self, input_dim, bottleneck_dim=5, n_clusters=6):
        super().__init__()
        self.encoder = nn.Sequential(
            nn.Linear(input_dim, 64),
            nn.ReLU(),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Linear(32, bottleneck_dim),
        )
        self.decoder = nn.Sequential(
            nn.Linear(bottleneck_dim, 32),
            nn.ReLU(),
            nn.Linear(32, 64),
            nn.ReLU(),
            nn.Linear(64, input_dim),
        )
        self.cluster_centers = nn.Parameter(torch.empty(n_clusters, bottleneck_dim))
        nn.init.xavier_uniform_(self.cluster_centers.data)

    def forward(self, x):
        z = self.encoder(x)
        x_hat = self.decoder(z)
        return x_hat, z

    def encode(self, x):
        return self.encoder(x)

    def soft_assign(self, z):
        dist_sq = torch.sum((z.unsqueeze(1) - self.cluster_centers) ** 2, dim=2)
        q = 1.0 / (1.0 + dist_sq / DEC_ALPHA)
        q = q ** ((DEC_ALPHA + 1.0) / 2.0)
        q = q / torch.sum(q, dim=1, keepdim=True)
        return q


def safe_ratio(num, den, valid_mask, eps=1e-6):
    out = np.zeros_like(num, dtype=np.float32)
    np.divide(num, den + eps, out=out, where=valid_mask & (np.abs(den) > eps))
    out[~np.isfinite(out)] = 0.0
    return out.astype(np.float32, copy=False)


def ndvi(nir, red, valid_mask, eps=1e-6):
    out = np.zeros_like(nir, dtype=np.float32)
    den = nir + red
    np.divide(nir - red, den + eps, out=out, where=valid_mask & (np.abs(den) > eps))
    out[~np.isfinite(out)] = 0.0
    return out.astype(np.float32, copy=False)


def local_sum_3x3(arr):
    h, w = arr.shape
    padded = np.pad(arr, 1, mode="constant", constant_values=0)
    total = np.zeros((h, w), dtype=np.float32)
    for dy in range(3):
        for dx in range(3):
            total += padded[dy:dy + h, dx:dx + w]
    return total


def masked_local_mean_std(arr, valid_mask, count, count_safe):
    values = np.where(valid_mask, arr, 0.0).astype(np.float32, copy=False)
    count_safe = np.maximum(count, 1.0)
    total = local_sum_3x3(values)
    total_sq = local_sum_3x3(values * values)
    mean = total / count_safe
    var = np.maximum(total_sq / count_safe - mean * mean, 0.0)
    std = np.sqrt(var).astype(np.float32)
    mean = mean.astype(np.float32)
    mean[~valid_mask] = 0.0
    std[~valid_mask] = 0.0
    return mean, std


def build_geo_features(quick_pixels=0):
    stage_start = time.time()
    print("Loading stack:", STACK_PATH)
    with rasterio.open(STACK_PATH) as src:
        stack = src.read().astype(np.float32)

    with rasterio.open(MASK_PATH) as src:
        valid_mask = src.read(1).astype(bool)

    print("Stack shape:", stack.shape)
    print("Valid pixels:", int(valid_mask.sum()))
    if quick_pixels > 0:
        print(f"Quick mode: sampling {quick_pixels:,} valid pixels and skipping full-map context output")

    b = {name: stack[idx] for name, idx in BAND_INDEX.items()}
    print("Computing geology-aware ratios", flush=True)
    ratio_start = time.time()
    ratio_maps = {
        "B11_B12": safe_ratio(b["B11"], b["B12"], valid_mask),
        "B12_B8A": safe_ratio(b["B12"], b["B8A"], valid_mask),
        "B11_B8A": safe_ratio(b["B11"], b["B8A"], valid_mask),
        "B04_B02": safe_ratio(b["B04"], b["B02"], valid_mask),
        "B08_B04": safe_ratio(b["B08"], b["B04"], valid_mask),
        "NDVI": ndvi(b["B08"], b["B04"], valid_mask),
    }
    print(f"Ratios done in {format_seconds(time.time() - ratio_start)}", flush=True)

    context_maps = {
        "B11": b["B11"],
        "B12": b["B12"],
        "B11_B12": ratio_maps["B11_B12"],
        "B12_B8A": ratio_maps["B12_B8A"],
        "B11_B8A": ratio_maps["B11_B8A"],
        "NDVI": ratio_maps["NDVI"],
    }

    rng = np.random.default_rng(RANDOM_STATE)
    all_valid_idx = np.flatnonzero(valid_mask.ravel())
    if quick_pixels > 0:
        sample_n = min(quick_pixels, all_valid_idx.size)
        selected_flat_idx = rng.choice(all_valid_idx, size=sample_n, replace=False)
        selected_mask = np.zeros(valid_mask.size, dtype=bool)
        selected_mask[selected_flat_idx] = True
        selected_mask = selected_mask.reshape(valid_mask.shape)
        row_mask = selected_mask
    else:
        row_mask = valid_mask

    feature_names = (
        BAND_NAMES
        + list(ratio_maps.keys())
        + [f"{name}_{stat}3x3" for name in context_maps for stat in ("mean", "std")]
    )
    n_rows = int(row_mask.sum())
    X_geo = np.empty((n_rows, len(feature_names)), dtype=np.float32)
    col = 0

    for idx in range(len(BAND_NAMES)):
        X_geo[:, col] = stack[idx, row_mask]
        col += 1

    for arr in ratio_maps.values():
        X_geo[:, col] = arr[row_mask]
        col += 1

    print("Computing 3x3 spatial context", flush=True)
    context_start = time.time()
    count = local_sum_3x3(valid_mask.astype(np.float32))
    count_safe = np.maximum(count, 1.0)
    total_context = len(context_maps)
    for i, (name, arr) in enumerate(context_maps.items(), start=1):
        local_mean, local_std = masked_local_mean_std(arr, valid_mask, count, count_safe)
        X_geo[:, col] = local_mean[row_mask]
        col += 1
        X_geo[:, col] = local_std[row_mask]
        col += 1
        progress_line(f"Context {name}", i, total_context, context_start)

    X_geo = np.nan_to_num(X_geo, nan=0.0, posinf=0.0, neginf=0.0)
    print("Geo feature shape:", X_geo.shape)
    print("Feature names:", feature_names)
    print(f"Feature construction done in {format_seconds(time.time() - stage_start)}", flush=True)
    return X_geo, valid_mask, np.array(feature_names)


def target_distribution(q):
    weight = (q ** 2) / np.maximum(q.sum(axis=0, keepdims=True), 1e-12)
    p = weight / np.maximum(weight.sum(axis=1, keepdims=True), 1e-12)
    return p.astype(np.float32)


def encode_features(model, X_scaled, device, stage_name="Encoding"):
    model.eval()
    loader = DataLoader(
        TensorDataset(torch.from_numpy(X_scaled)),
        batch_size=ENCODE_BATCH_SIZE,
        shuffle=False,
        drop_last=False,
    )
    chunks = []
    total_batches = len(loader)
    start_time = time.time()
    with torch.no_grad():
        for batch_idx, (xb,) in enumerate(loader, start=1):
            xb = xb.to(device)
            chunks.append(model.encode(xb).cpu().numpy().astype(np.float32))
            if should_report(batch_idx, total_batches):
                progress_line(stage_name, batch_idx, total_batches, start_time)
    return np.vstack(chunks)


def soft_assign_numpy(Z, centers, batch_size=500000):
    labels = np.empty(Z.shape[0], dtype=np.int16)
    total_batches = int(np.ceil(Z.shape[0] / batch_size))
    start_time = time.time()
    batch_idx = 0
    for start in range(0, Z.shape[0], batch_size):
        batch_idx += 1
        end = min(start + batch_size, Z.shape[0])
        z = Z[start:end]
        dist_sq = np.sum((z[:, None, :] - centers[None, :, :]) ** 2, axis=2)
        q = 1.0 / (1.0 + dist_sq / DEC_ALPHA)
        q = q ** ((DEC_ALPHA + 1.0) / 2.0)
        q = q / np.maximum(q.sum(axis=1, keepdims=True), 1e-12)
        labels[start:end] = np.argmax(q, axis=1).astype(np.int16)
        if should_report(batch_idx, total_batches):
            progress_line("Soft assignment", batch_idx, total_batches, start_time)
    return labels


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


def count_same_label_neighbors(label_map, valid_mask, include_center):
    same_count = np.zeros(label_map.shape, dtype=np.float32)
    for cid in np.unique(label_map[valid_mask]):
        class_mask = ((label_map == cid) & valid_mask).astype(np.float32)
        count = local_sum_3x3(class_mask)
        if not include_center:
            count -= class_mask
        same_count[label_map == cid] = count[label_map == cid]
    return same_count


def compute_spatial_metrics(label_map):
    valid_mask = label_map >= 0
    if not np.any(valid_mask):
        return float("nan"), float("nan")

    same_with_center = count_same_label_neighbors(label_map, valid_mask, include_center=True)
    max_count = np.zeros(label_map.shape, dtype=np.float32)
    for cid in np.unique(label_map[valid_mask]):
        class_mask = ((label_map == cid) & valid_mask).astype(np.float32)
        max_count = np.maximum(max_count, local_sum_3x3(class_mask))

    same_neighbors = count_same_label_neighbors(label_map, valid_mask, include_center=False)
    local_agreement = np.mean(same_with_center[valid_mask] >= max_count[valid_mask])
    isolated_ratio = np.mean(same_neighbors[valid_mask] == 0)
    return float(local_agreement), float(isolated_ratio)


def save_cluster_png(label_map, out_png):
    img = label_map.astype(np.float32)
    img[img < 0] = np.nan
    plt.figure(figsize=(8, 8))
    plt.imshow(img, cmap="tab20")
    plt.axis("off")
    plt.title(f"Geo-DEC clustering result, k={K}, z={BOTTLENECK_DIM}")
    plt.tight_layout()
    plt.savefig(out_png, dpi=300, bbox_inches="tight")
    plt.close()


def save_loss_plot(pretrain_losses, dec_recon_losses, dec_kl_losses):
    fig, axes = plt.subplots(1, 2, figsize=(12, 5))
    axes[0].plot(range(1, len(pretrain_losses) + 1), pretrain_losses, marker="o")
    axes[0].set_xlabel("Pretrain epoch")
    axes[0].set_ylabel("Reconstruction MSE")
    axes[0].set_title("Geo-DEC AE pretraining loss")

    axes[1].plot(range(1, len(dec_recon_losses) + 1), dec_recon_losses, marker="o", label="Recon MSE")
    axes[1].plot(range(1, len(dec_kl_losses) + 1), dec_kl_losses, marker="s", label="DEC KL")
    axes[1].set_xlabel("DEC epoch")
    axes[1].set_title("Geo-DEC fine-tuning losses")
    axes[1].legend()

    fig.tight_layout()
    fig.savefig(OUT_DIR / f"geo_dec_training_loss_z{BOTTLENECK_DIM}.png", dpi=300)
    plt.close(fig)

    with open(OUT_DIR / f"geo_dec_training_loss_z{BOTTLENECK_DIM}.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["phase", "epoch", "reconstruction_mse", "dec_kl"])
        for i, loss in enumerate(pretrain_losses, start=1):
            writer.writerow(["pretrain", i, loss, ""])
        for i, (recon, kl) in enumerate(zip(dec_recon_losses, dec_kl_losses), start=1):
            writer.writerow(["dec", i, recon, kl])


def main():
    np.random.seed(RANDOM_STATE)
    torch.manual_seed(RANDOM_STATE)
    if _NUM_THREADS:
        torch.set_num_threads(int(_NUM_THREADS))

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    print("Device:", device)
    print(
        "Config:",
        f"train_sample={TRAIN_SAMPLE_SIZE}",
        f"batch={BATCH_SIZE}",
        f"pretrain_epochs={PRETRAIN_EPOCHS}",
        f"dec_epochs={DEC_EPOCHS}",
        f"quick_pixels={QUICK_PIXELS}",
    )

    X_geo, valid_mask, feature_names = build_geo_features(QUICK_PIXELS)
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X_geo).astype(np.float32, copy=False)
    del X_geo

    n = X_scaled.shape[0]
    train_n = min(TRAIN_SAMPLE_SIZE, n)
    rng = np.random.default_rng(RANDOM_STATE)
    train_idx = rng.choice(n, size=train_n, replace=False)
    X_train = X_scaled[train_idx]
    train_tensor = torch.from_numpy(X_train)

    model = GeoDEC(
        input_dim=X_scaled.shape[1],
        bottleneck_dim=BOTTLENECK_DIM,
        n_clusters=K,
    ).to(device)

    pretrain_loader = DataLoader(
        TensorDataset(train_tensor),
        batch_size=BATCH_SIZE,
        shuffle=True,
        drop_last=False,
    )

    optimizer = torch.optim.Adam(model.parameters(), lr=LR)
    loss_fn = nn.MSELoss()
    pretrain_losses = []

    for epoch in range(1, PRETRAIN_EPOCHS + 1):
        model.train()
        total_loss = 0.0
        total_count = 0
        epoch_start = time.time()
        total_batches = len(pretrain_loader)
        for batch_idx, (xb,) in enumerate(pretrain_loader, start=1):
            xb = xb.to(device)
            optimizer.zero_grad()
            x_hat, _ = model(xb)
            loss = loss_fn(x_hat, xb)
            loss.backward()
            optimizer.step()
            total_loss += loss.item() * xb.size(0)
            total_count += xb.size(0)
            if should_report(batch_idx, total_batches):
                progress_line(f"Pretrain epoch {epoch:03d}", batch_idx, total_batches, epoch_start)
        avg_loss = total_loss / total_count
        pretrain_losses.append(avg_loss)
        print(
            f"Pretrain epoch {epoch:03d}/{PRETRAIN_EPOCHS}, "
            f"recon_loss={avg_loss:.6f}, elapsed={format_seconds(time.time() - epoch_start)}",
            flush=True,
        )

    print("Initializing DEC centers with K-means on pretrained embeddings")
    Z_train = encode_features(model, X_train, device, stage_name="Encoding train set for K-means")
    km_start = time.time()
    km = KMeans(n_clusters=K, random_state=RANDOM_STATE, n_init=KMEANS_N_INIT, max_iter=300)
    km.fit(Z_train)
    print(f"K-means init done in {format_seconds(time.time() - km_start)}", flush=True)
    model.cluster_centers.data = torch.from_numpy(km.cluster_centers_.astype(np.float32)).to(device)

    dec_optimizer = torch.optim.Adam(model.parameters(), lr=DEC_LR)
    dec_recon_losses = []
    dec_kl_losses = []

    for epoch in range(1, DEC_EPOCHS + 1):
        model.eval()
        q_train_chunks = []
        epoch_start = time.time()
        with torch.no_grad():
            assign_loader = DataLoader(TensorDataset(train_tensor), batch_size=BATCH_SIZE, shuffle=False)
            assign_total = len(assign_loader)
            assign_start = time.time()
            for batch_idx, (xb,) in enumerate(assign_loader, start=1):
                xb = xb.to(device)
                z = model.encode(xb)
                q_train_chunks.append(model.soft_assign(z).cpu().numpy().astype(np.float32))
                if should_report(batch_idx, assign_total):
                    progress_line(f"DEC target epoch {epoch:03d}", batch_idx, assign_total, assign_start)
        p_train = target_distribution(np.vstack(q_train_chunks))

        dec_loader = DataLoader(
            TensorDataset(train_tensor, torch.from_numpy(p_train)),
            batch_size=BATCH_SIZE,
            shuffle=True,
            drop_last=False,
        )

        model.train()
        total_recon = 0.0
        total_kl = 0.0
        total_count = 0
        dec_total = len(dec_loader)
        dec_start = time.time()
        for batch_idx, (xb, pb) in enumerate(dec_loader, start=1):
            xb = xb.to(device)
            pb = pb.to(device)
            dec_optimizer.zero_grad()
            x_hat, z = model(xb)
            q = model.soft_assign(z)
            recon_loss = loss_fn(x_hat, xb)
            kl_loss = F.kl_div(torch.log(q + 1e-8), pb, reduction="batchmean")
            loss = recon_loss + DEC_WEIGHT * kl_loss
            loss.backward()
            dec_optimizer.step()
            total_recon += recon_loss.item() * xb.size(0)
            total_kl += kl_loss.item() * xb.size(0)
            total_count += xb.size(0)
            if should_report(batch_idx, dec_total):
                progress_line(f"DEC train epoch {epoch:03d}", batch_idx, dec_total, dec_start)

        avg_recon = total_recon / total_count
        avg_kl = total_kl / total_count
        dec_recon_losses.append(avg_recon)
        dec_kl_losses.append(avg_kl)
        print(
            f"DEC epoch {epoch:03d}/{DEC_EPOCHS}, "
            f"recon_loss={avg_recon:.6f}, kl_loss={avg_kl:.6f}, "
            f"elapsed={format_seconds(time.time() - epoch_start)}",
            flush=True,
        )

    save_loss_plot(pretrain_losses, dec_recon_losses, dec_kl_losses)

    print("Encoding all valid pixels")
    Z = encode_features(model, X_scaled, device, stage_name="Encoding all rows")
    centers = model.cluster_centers.detach().cpu().numpy().astype(np.float32)
    labels = soft_assign_numpy(Z, centers).astype(np.int16)

    if QUICK_PIXELS > 0:
        sil, db, ch = compute_cluster_metrics(Z, labels)
        unique, counts = np.unique(labels, return_counts=True)
        class_pcts = counts / counts.sum()
        quick_path = OUT_DIR / f"geo_dec_quick_metrics_z{BOTTLENECK_DIM}.csv"
        with open(quick_path, "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow([
                "method", "z", "k", "quick_pixels", "silhouette",
                "davies_bouldin", "calinski_harabasz",
                "max_class_ratio", "min_class_ratio",
                "pretrain_recon_mse", "dec_recon_mse", "dec_kl",
            ])
            writer.writerow([
                "Geo-DEC quick", BOTTLENECK_DIM, K, int(Z.shape[0]),
                float(sil), float(db), float(ch),
                float(class_pcts.max()), float(class_pcts.min()),
                float(pretrain_losses[-1]) if pretrain_losses else float("nan"),
                float(dec_recon_losses[-1]) if dec_recon_losses else float("nan"),
                float(dec_kl_losses[-1]) if dec_kl_losses else float("nan"),
            ])
        print(f"Quick mode metrics: Sil={sil:.4f}, DB={db:.4f}, CH={ch:.2f}")
        print("Saved quick metrics to:", quick_path)
        print("Quick mode done. Run without GEODEC_QUICK_PIXELS for full GeoTIFF outputs.")
        return

    np.savez_compressed(
        OUT_DIR / f"geo_dec_encoded_features_z{BOTTLENECK_DIM}.npz",
        Z=Z,
        feature_names=feature_names,
        band_order=np.array(BAND_NAMES),
        bottleneck_dim=BOTTLENECK_DIM,
        cluster_centers=centers,
        train_indices=train_idx,
    )
    print("Encoded features saved", flush=True)

    label_map = np.full(valid_mask.shape, -1, dtype=np.int16)
    label_map[valid_mask] = labels

    with rasterio.open(REF_TIF) as ref:
        profile = ref.profile.copy()
        profile.update(count=1, dtype="int16", nodata=-1, compress="lzw")

    out_tif = OUT_DIR / f"geo_dec_k{K}_z{BOTTLENECK_DIM}.tif"
    write_start = time.time()
    with rasterio.open(out_tif, "w", **profile) as dst:
        dst.write(label_map, 1)
    print(f"GeoTIFF written in {format_seconds(time.time() - write_start)}", flush=True)

    save_cluster_png(label_map, OUT_DIR / f"geo_dec_k{K}_z{BOTTLENECK_DIM}.png")

    unique, counts = np.unique(labels, return_counts=True)
    class_pcts = counts / counts.sum()
    with open(OUT_DIR / f"geo_dec_k{K}_z{BOTTLENECK_DIM}_class_counts.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["cluster_id", "pixel_count", "percentage"])
        for u, c, p in zip(unique, counts, class_pcts):
            writer.writerow([int(u), int(c), float(p)])

    metric_start = time.time()
    print("Computing cluster metrics", flush=True)
    sil, db, ch = compute_cluster_metrics(Z, labels)
    local_agreement, isolated_ratio = compute_spatial_metrics(label_map)
    print(f"Metrics done in {format_seconds(time.time() - metric_start)}", flush=True)
    print(f"Silhouette: {sil:.4f}, Davies-Bouldin: {db:.4f}, CH: {ch:.2f}")
    print(f"Local agreement: {local_agreement:.4f}, isolated pixel ratio: {isolated_ratio:.4f}")

    with open(OUT_DIR / "geo_dec_metrics.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow([
            "method", "z", "k", "silhouette", "davies_bouldin",
            "calinski_harabasz", "max_class_ratio", "min_class_ratio",
            "local_agreement_ratio", "isolated_pixel_ratio",
            "pretrain_recon_mse", "dec_recon_mse", "dec_kl",
        ])
        writer.writerow([
            "Geo-DEC", BOTTLENECK_DIM, K, float(sil), float(db), float(ch),
            float(class_pcts.max()), float(class_pcts.min()),
            local_agreement, isolated_ratio,
            float(pretrain_losses[-1]) if pretrain_losses else float("nan"),
            float(dec_recon_losses[-1]) if dec_recon_losses else float("nan"),
            float(dec_kl_losses[-1]) if dec_kl_losses else float("nan"),
        ])

    torch.save(
        {
            "model_state_dict": model.state_dict(),
            "input_dim": X_scaled.shape[1],
            "bottleneck_dim": BOTTLENECK_DIM,
            "n_clusters": K,
            "feature_names": feature_names,
            "scaler_mean": scaler.mean_,
            "scaler_scale": scaler.scale_,
            "cluster_centers": centers,
        },
        OUT_DIR / f"geo_dec_model_z{BOTTLENECK_DIM}.pt",
    )

    print("Saved outputs to:", OUT_DIR)
    print("Done.")


if __name__ == "__main__":
    main()
