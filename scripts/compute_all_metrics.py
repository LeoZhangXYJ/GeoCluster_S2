"""Compute common clustering metrics for all generated experiment outputs."""
from pathlib import Path
import csv
import os

import numpy as np
from sklearn.decomposition import PCA
from sklearn.metrics import (
    calinski_harabasz_score,
    davies_bouldin_score,
    silhouette_score,
)
from sklearn.preprocessing import StandardScaler


ROOT = Path(__file__).parent.parent.resolve()
PROCESSED = ROOT / "data" / "processed"
OUT_DIR = ROOT / "results" / "cluster_metrics"
OUT_DIR.mkdir(parents=True, exist_ok=True)

NPZ_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_pixels.npz"
MASK_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif"
RANDOM_STATE = 42
METRIC_SAMPLE = int(os.getenv("METRIC_SAMPLE", "100000"))


def load_labels_from_tif(tif_path, mask_path=MASK_PATH):
    import rasterio

    with rasterio.open(mask_path) as src:
        valid = src.read(1).astype(bool)
    with rasterio.open(tif_path) as src:
        label_map = src.read(1)
    return label_map[valid]


def compute_metrics(features, labels):
    n = len(labels)
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


def local_sum_3x3(arr):
    h, w = arr.shape
    padded = np.pad(arr, 1, mode="constant", constant_values=0)
    total = np.zeros((h, w), dtype=np.float32)
    for dy in range(3):
        for dx in range(3):
            total += padded[dy:dy + h, dx:dx + w]
    return total


def count_same_label_neighbors(label_map, valid_mask, include_center):
    same_count = np.zeros(label_map.shape, dtype=np.float32)
    for cid in np.unique(label_map[valid_mask]):
        class_mask = ((label_map == cid) & valid_mask).astype(np.float32)
        count = local_sum_3x3(class_mask)
        if not include_center:
            count -= class_mask
        same_count[label_map == cid] = count[label_map == cid]
    return same_count


def compute_spatial_metrics_from_tif(tif_path):
    import rasterio

    with rasterio.open(tif_path) as src:
        label_map = src.read(1)

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


def append_row(rows, method, z, k, features, labels, tif_path):
    sil, db, ch = compute_metrics(features, labels)
    _, counts = np.unique(labels, return_counts=True)
    pcts = counts / counts.sum()
    local_agreement, isolated_ratio = compute_spatial_metrics_from_tif(tif_path)

    rows.append({
        "method": method,
        "z": z,
        "k": k,
        "silhouette": float(sil),
        "davies_bouldin": float(db),
        "calinski_harabasz": float(ch),
        "max_class_ratio": float(pcts.max()),
        "min_class_ratio": float(pcts.min()),
        "local_agreement_ratio": local_agreement,
        "isolated_pixel_ratio": isolated_ratio,
    })
    print(
        f"{method} z={z}, k={k}: "
        f"Sil={sil:.4f}, DB={db:.4f}, CH={ch:.1f}, "
        f"Agree={local_agreement:.4f}, Iso={isolated_ratio:.4f}"
    )


def main():
    data = np.load(NPZ_PATH, allow_pickle=True)
    X = data["X"].astype(np.float32)

    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X).astype(np.float32)

    rows = []

    raw_tif = ROOT / "results" / "cluster_baseline" / "kmeans_baseline_k5.tif"
    append_row(rows, "Raw K-means", 10, 5, X_scaled, load_labels_from_tif(raw_tif), raw_tif)

    pca3_tif = ROOT / "results" / "cluster_pca" / "pca_kmeans_z3_k5.tif"
    pca3 = PCA(n_components=3, random_state=RANDOM_STATE)
    Z3 = pca3.fit_transform(X_scaled).astype(np.float32)
    append_row(rows, "PCA + K-means", 3, 5, Z3, load_labels_from_tif(pca3_tif), pca3_tif)

    pca5_tif = ROOT / "results" / "cluster_pca" / "pca_kmeans_z5_k6.tif"
    pca5 = PCA(n_components=5, random_state=RANDOM_STATE)
    Z5 = pca5.fit_transform(X_scaled).astype(np.float32)
    append_row(rows, "PCA + K-means", 5, 6, Z5, load_labels_from_tif(pca5_tif), pca5_tif)

    sae3_tif = ROOT / "results" / "cluster_sae" / "sae_kmeans_k5_z3.tif"
    Z_sae3 = np.load(ROOT / "results" / "cluster_sae" / "sae_encoded_features_z3.npz")["Z"]
    append_row(rows, "SAE + K-means", 3, 5, Z_sae3, load_labels_from_tif(sae3_tif), sae3_tif)

    sae4_tif = ROOT / "results" / "cluster_sae" / "sae_kmeans_k6_z4.tif"
    Z_sae4 = np.load(ROOT / "results" / "cluster_sae" / "sae_encoded_features_z4.npz")["Z"]
    append_row(rows, "SAE + K-means", 4, 6, Z_sae4, load_labels_from_tif(sae4_tif), sae4_tif)

    sae5_tif = ROOT / "results" / "cluster_sae" / "sae_kmeans_k6_z5.tif"
    Z_sae5 = np.load(ROOT / "results" / "cluster_sae" / "sae_encoded_features_z5.npz")["Z"]
    append_row(rows, "SAE + K-means", 5, 6, Z_sae5, load_labels_from_tif(sae5_tif), sae5_tif)

    ae5_tif = ROOT / "results" / "cluster_ae" / "ae_kmeans_k6_z5.tif"
    Z_ae5 = np.load(ROOT / "results" / "cluster_ae" / "ae_encoded_features_z5.npz")["Z"]
    append_row(rows, "Canonical AE + K-means", 5, 6, Z_ae5, load_labels_from_tif(ae5_tif), ae5_tif)

    geo_tif = ROOT / "results" / "cluster_geo_dec" / "geo_dec_k6_z5.tif"
    geo_npz = ROOT / "results" / "cluster_geo_dec" / "geo_dec_encoded_features_z5.npz"
    if geo_tif.exists() and geo_npz.exists():
        Z_geo5 = np.load(geo_npz)["Z"]
        append_row(rows, "Geo-DEC", 5, 6, Z_geo5, load_labels_from_tif(geo_tif), geo_tif)
    else:
        print("Geo-DEC outputs not found; skipping Geo-DEC metrics.")

    fieldnames = [
        "method", "z", "k", "silhouette", "davies_bouldin",
        "calinski_harabasz", "max_class_ratio", "min_class_ratio",
        "local_agreement_ratio", "isolated_pixel_ratio",
    ]
    with open(OUT_DIR / "all_cluster_metrics.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)

    print("\n=== Unified comparison table ===")
    print(
        f"{'Method':<24s} {'z':>3s} {'k':>3s} {'Silhouette':>10s} "
        f"{'Davies-Bouldin':>15s} {'CH':>12s} {'Max%':>8s} {'Min%':>8s} "
        f"{'Agree':>8s} {'Iso':>8s}"
    )
    print("-" * 112)
    for r in rows:
        print(
            f"{r['method']:<24s} {r['z']:>3d} {r['k']:>3d} "
            f"{r['silhouette']:>10.4f} {r['davies_bouldin']:>15.4f} "
            f"{r['calinski_harabasz']:>12.1f} "
            f"{r['max_class_ratio']:>8.4f} {r['min_class_ratio']:>8.4f} "
            f"{r['local_agreement_ratio']:>8.4f} {r['isolated_pixel_ratio']:>8.4f}"
        )

    print("\nSaved to:", OUT_DIR / "all_cluster_metrics.csv")


if __name__ == "__main__":
    main()
