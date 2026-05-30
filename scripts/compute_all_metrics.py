"""在已有聚类结果上统一计算 Silhouette / DB / CH 指标，用于综合对比表。"""
from pathlib import Path
import csv
import numpy as np
from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.metrics import silhouette_score, davies_bouldin_score, calinski_harabasz_score

ROOT = Path(__file__).parent.parent.resolve()
PROCESSED = ROOT / "data" / "processed"
OUT_DIR = ROOT / "results" / "cluster_metrics"
OUT_DIR.mkdir(parents=True, exist_ok=True)

NPZ_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_pixels.npz"
RANDOM_STATE = 42
METRIC_SAMPLE = 100_000


def load_labels_from_tif(tif_path, mask_path):
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


def main():
    data = np.load(NPZ_PATH, allow_pickle=True)
    X = data["X"].astype(np.float32)

    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X).astype(np.float32)

    rows = []

    # ---- Baseline: Raw K-means k=5 ----
    labels = load_labels_from_tif(
        ROOT / "results" / "cluster_baseline" / "kmeans_baseline_k5.tif",
        PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif",
    )
    sil, db, ch = compute_metrics(X_scaled, labels)
    unique, counts = np.unique(labels, return_counts=True)
    pcts = counts / counts.sum()
    rows.append({
        "method": "Raw K-means", "z": 10, "k": 5,
        "silhouette": sil, "davies_bouldin": db, "calinski_harabasz": ch,
        "max_class_ratio": float(pcts.max()),
        "min_class_ratio": float(pcts.min()),
    })
    print(f"Raw K-means k=5: Sil={sil:.4f}, DB={db:.4f}, CH={ch:.1f}")

    # ---- PCA z=3, k=5 ----
    labels = load_labels_from_tif(
        ROOT / "results" / "cluster_pca" / "pca_kmeans_z3_k5.tif",
        PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif",
    )
    pca3 = PCA(n_components=3, random_state=RANDOM_STATE)
    Z3 = pca3.fit_transform(X_scaled).astype(np.float32)
    sil, db, ch = compute_metrics(Z3, labels)
    unique, counts = np.unique(labels, return_counts=True)
    pcts = counts / counts.sum()
    rows.append({
        "method": "PCA + K-means", "z": 3, "k": 5,
        "silhouette": sil, "davies_bouldin": db, "calinski_harabasz": ch,
        "max_class_ratio": float(pcts.max()),
        "min_class_ratio": float(pcts.min()),
    })
    print(f"PCA z=3, k=5: Sil={sil:.4f}, DB={db:.4f}, CH={ch:.1f}")

    # ---- PCA z=5, k=6 ----
    labels = load_labels_from_tif(
        ROOT / "results" / "cluster_pca" / "pca_kmeans_z5_k6.tif",
        PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif",
    )
    pca5 = PCA(n_components=5, random_state=RANDOM_STATE)
    Z5 = pca5.fit_transform(X_scaled).astype(np.float32)
    sil, db, ch = compute_metrics(Z5, labels)
    unique, counts = np.unique(labels, return_counts=True)
    pcts = counts / counts.sum()
    rows.append({
        "method": "PCA + K-means", "z": 5, "k": 6,
        "silhouette": sil, "davies_bouldin": db, "calinski_harabasz": ch,
        "max_class_ratio": float(pcts.max()),
        "min_class_ratio": float(pcts.min()),
    })
    print(f"PCA z=5, k=6: Sil={sil:.4f}, DB={db:.4f}, CH={ch:.1f}")

    # ---- SAE z=3, k=5 ----
    labels = load_labels_from_tif(
        ROOT / "results" / "cluster_sae" / "sae_kmeans_k5_z3.tif",
        PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif",
    )
    sae_z3 = np.load(ROOT / "results" / "cluster_sae" / "sae_encoded_features.npz")
    Z_sae3 = sae_z3["Z"]
    sil, db, ch = compute_metrics(Z_sae3, labels)
    unique, counts = np.unique(labels, return_counts=True)
    pcts = counts / counts.sum()
    rows.append({
        "method": "SAE + K-means", "z": 3, "k": 5,
        "silhouette": sil, "davies_bouldin": db, "calinski_harabasz": ch,
        "max_class_ratio": float(pcts.max()),
        "min_class_ratio": float(pcts.min()),
    })
    print(f"SAE z=3, k=5: Sil={sil:.4f}, DB={db:.4f}, CH={ch:.1f}")

    # ---- SAE z=4, k=6 ----
    labels = load_labels_from_tif(
        ROOT / "results" / "cluster_sae" / "sae_kmeans_k6_z4.tif",
        PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif",
    )
    sae_z4 = np.load(ROOT / "results" / "cluster_sae" / "sae_encoded_features_z4.npz")
    Z_sae4 = sae_z4["Z"]
    sil, db, ch = compute_metrics(Z_sae4, labels)
    unique, counts = np.unique(labels, return_counts=True)
    pcts = counts / counts.sum()
    rows.append({
        "method": "SAE + K-means", "z": 4, "k": 6,
        "silhouette": sil, "davies_bouldin": db, "calinski_harabasz": ch,
        "max_class_ratio": float(pcts.max()),
        "min_class_ratio": float(pcts.min()),
    })
    print(f"SAE z=4, k=6: Sil={sil:.4f}, DB={db:.4f}, CH={ch:.1f}")

    # ---- SAE z=5, k=6 ----
    labels = load_labels_from_tif(
        ROOT / "results" / "cluster_sae" / "sae_kmeans_k6_z5.tif",
        PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif",
    )
    sae_z5 = np.load(ROOT / "results" / "cluster_sae" / "sae_encoded_features_z5.npz")
    Z_sae5 = sae_z5["Z"]
    sil, db, ch = compute_metrics(Z_sae5, labels)
    unique, counts = np.unique(labels, return_counts=True)
    pcts = counts / counts.sum()
    rows.append({
        "method": "SAE + K-means", "z": 5, "k": 6,
        "silhouette": sil, "davies_bouldin": db, "calinski_harabasz": ch,
        "max_class_ratio": float(pcts.max()),
        "min_class_ratio": float(pcts.min()),
    })
    print(f"SAE z=5, k=6: Sil={sil:.4f}, DB={db:.4f}, CH={ch:.1f}")

    # ---- Canonical AE z=5, k=6 ----
    labels = load_labels_from_tif(
        ROOT / "results" / "cluster_ae" / "ae_kmeans_k6_z5.tif",
        PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif",
    )
    ae_z5 = np.load(ROOT / "results" / "cluster_ae" / "ae_encoded_features_z5.npz")
    Z_ae5 = ae_z5["Z"]
    sil, db, ch = compute_metrics(Z_ae5, labels)
    unique, counts = np.unique(labels, return_counts=True)
    pcts = counts / counts.sum()
    rows.append({
        "method": "Canonical AE + K-means", "z": 5, "k": 6,
        "silhouette": sil, "davies_bouldin": db, "calinski_harabasz": ch,
        "max_class_ratio": float(pcts.max()),
        "min_class_ratio": float(pcts.min()),
    })
    print(f"Canonical AE z=5, k=6: Sil={sil:.4f}, DB={db:.4f}, CH={ch:.1f}")

    # ---- 保存 ----
    with open(OUT_DIR / "all_cluster_metrics.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=[
            "method", "z", "k", "silhouette", "davies_bouldin",
            "calinski_harabasz", "max_class_ratio", "min_class_ratio",
        ])
        writer.writeheader()
        writer.writerows(rows)

    print("\n=== 综合对比表 ===")
    print(f"{'Method':<20s} {'z':>3s} {'k':>3s} {'Silhouette':>10s} {'Davies-Bouldin':>15s} {'CH':>12s} {'Max%':>8s} {'Min%':>8s}")
    print("-" * 90)
    for r in rows:
        print(f"{r['method']:<20s} {r['z']:>3d} {r['k']:>3d} "
              f"{r['silhouette']:>10.4f} {r['davies_bouldin']:>15.4f} "
              f"{r['calinski_harabasz']:>12.1f} "
              f"{r['max_class_ratio']:>8.4f} {r['min_class_ratio']:>8.4f}")

    print("\nSaved to:", OUT_DIR / "all_cluster_metrics.csv")


if __name__ == "__main__":
    main()
