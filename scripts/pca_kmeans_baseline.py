from pathlib import Path
import csv

import numpy as np
import rasterio
import matplotlib.pyplot as plt

from sklearn.preprocessing import StandardScaler
from sklearn.decomposition import PCA
from sklearn.cluster import KMeans
from sklearn.metrics import silhouette_score, davies_bouldin_score, calinski_harabasz_score

from plot_style import DPI_LINE, DPI_RASTER, apply_report_style


ROOT = Path(__file__).parent.parent.resolve()
PROCESSED = ROOT / "data" / "processed"
OUT_DIR = ROOT / "results" / "cluster_pca"
OUT_DIR.mkdir(parents=True, exist_ok=True)

NPZ_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_pixels.npz"
MASK_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif"
REF_TIF = PROCESSED / "s2_tuwu_yandong_20240813_stack_20m_masked.tif"

RANDOM_STATE = 42
METRIC_SAMPLE = 100_000  # 抽样计算聚类指标，避免 OOM

apply_report_style()


def save_cluster_png(label_map, out_png, title):
    img = label_map.astype(np.float32)
    img[img < 0] = np.nan
    plt.figure(figsize=(8, 8))
    plt.imshow(img, cmap="tab20")
    plt.axis("off")
    plt.title(title)
    plt.tight_layout()
    plt.savefig(out_png, dpi=DPI_RASTER, bbox_inches="tight")
    plt.close()


def compute_cluster_metrics(features, labels, sample_size=METRIC_SAMPLE):
    """在随机抽样上计算三个聚类评价指标。"""
    n = features.shape[0]
    if n > sample_size:
        rng = np.random.default_rng(RANDOM_STATE)
        idx = rng.choice(n, size=sample_size, replace=False)
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
    rng = np.random.default_rng(RANDOM_STATE)

    print("Loading:", NPZ_PATH)
    data = np.load(NPZ_PATH, allow_pickle=True)
    X = data["X"].astype(np.float32)
    band_order = data["band_order"]
    print("X shape:", X.shape)
    print("Band order:", band_order)

    # ---- 1. 标准化（与 baseline/SAE 一致）----
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X).astype(np.float32)
    n, d = X_scaled.shape

    # ---- 2. PCA 方差解释分析 ----
    pca_full = PCA(random_state=RANDOM_STATE)
    pca_full.fit(X_scaled)

    cumsum_var = np.cumsum(pca_full.explained_variance_ratio_)

    fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(12, 5))

    ax1.bar(range(1, d + 1), pca_full.explained_variance_ratio_, color="#0072B2", edgecolor="0.25", linewidth=0.4)
    ax1.set_xlabel("Principal component / index")
    ax1.set_ylabel("Explained variance ratio / 1")
    ax1.set_title("PCA Explained Variance per Component")
    ax1.set_xticks(range(1, d + 1))

    ax2.plot(range(1, d + 1), cumsum_var, marker="o", color="#E69F00", linewidth=1.5)
    ax2.axhline(0.95, color="0.45", linestyle="--", linewidth=1.2, label="95% threshold")
    ax2.axhline(0.99, color="0.45", linestyle=":", linewidth=1.2, label="99% threshold")
    ax2.set_xlabel("Number of components / count")
    ax2.set_ylabel("Cumulative explained variance / 1")
    ax2.set_title("PCA Cumulative Explained Variance")
    ax2.legend(frameon=False)
    ax2.set_xticks(range(1, d + 1))

    plt.tight_layout()
    plt.savefig(OUT_DIR / "pca_explained_variance.png", dpi=DPI_LINE)
    plt.close()

    # 保存 PCA 方差数据
    with open(OUT_DIR / "pca_explained_variance.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["component", "explained_variance_ratio", "cumulative_variance_ratio"])
        for i, (evr, cum) in enumerate(zip(pca_full.explained_variance_ratio_, cumsum_var), start=1):
            writer.writerow([i, evr, cum])

    print("PCA explained variance (per component):",
          np.round(pca_full.explained_variance_ratio_, 4))
    print("Cumulative variance: z=3 -> {:.4f}, z=5 -> {:.4f}".format(
        cumsum_var[2], cumsum_var[4]))

    # ---- 3. PCA + K-means 实验：z=3, k=5 / z=5, k=6 ----
    experiments = [
        {"z": 3, "k": 5,  "label": "PCA z=3, k=5"},
        {"z": 5, "k": 6,  "label": "PCA z=5, k=6"},
    ]

    with rasterio.open(MASK_PATH) as src:
        valid_mask = src.read(1).astype(bool)

    metrics_rows = []

    for exp in experiments:
        z = exp["z"]
        k = exp["k"]
        label = exp["label"]
        tag = f"z{z}_k{k}"

        print(f"\n=== {label} ===")

        # PCA 降维
        pca = PCA(n_components=z, random_state=RANDOM_STATE)
        Z = pca.fit_transform(X_scaled).astype(np.float32)
        print(f"PCA features shape: {Z.shape}")

        # K-means
        km = KMeans(n_clusters=k, random_state=RANDOM_STATE, n_init=10, max_iter=300)
        labels = km.fit_predict(Z).astype(np.int16)
        print(f"KMeans inertia: {km.inertia_:.2f}")

        # 聚类指标
        sil, db, ch = compute_cluster_metrics(Z, labels)
        print(f"Silhouette: {sil:.4f}, Davies-Bouldin: {db:.4f}, CH: {ch:.2f}")

        # 类别分布
        unique, counts = np.unique(labels, return_counts=True)
        class_pcts = counts / counts.sum()

        # 还原为二维 label map
        label_map = np.full(valid_mask.shape, -1, dtype=np.int16)
        label_map[valid_mask] = labels

        # 保存 GeoTIFF
        with rasterio.open(REF_TIF) as ref:
            profile = ref.profile.copy()
            profile.update(count=1, dtype="int16", nodata=-1, compress="lzw")

        out_tif = OUT_DIR / f"pca_kmeans_{tag}.tif"
        with rasterio.open(out_tif, "w", **profile) as dst:
            dst.write(label_map, 1)

        # 保存 PNG
        save_cluster_png(
            label_map,
            OUT_DIR / f"pca_kmeans_{tag}.png",
            f"PCA ({z}D) + K-means clustering, k={k}",
        )

        # 保存类别分布
        with open(OUT_DIR / f"pca_kmeans_{tag}_class_counts.csv", "w", newline="", encoding="utf-8") as f:
            writer = csv.writer(f)
            writer.writerow(["cluster_id", "pixel_count", "percentage"])
            for u, c, p in zip(unique, counts, class_pcts):
                writer.writerow([int(u), int(c), float(p)])

        max_pct = float(class_pcts.max())
        min_pct = float(class_pcts[class_pcts > 0.01].min()) if (class_pcts > 0.01).any() else float(class_pcts.min())

        metrics_rows.append({
            "method": "PCA + K-means",
            "z": z,
            "k": k,
            "inertia": float(km.inertia_),
            "silhouette": float(sil),
            "davies_bouldin": float(db),
            "calinski_harabasz": float(ch),
            "max_class_ratio": max_pct,
            "min_class_ratio_gt1pct": min_pct,
        })

    # ---- 4. 保存综合指标表 ----
    with open(OUT_DIR / "pca_metrics.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=[
            "method", "z", "k", "inertia", "silhouette",
            "davies_bouldin", "calinski_harabasz",
            "max_class_ratio", "min_class_ratio_gt1pct",
        ])
        writer.writeheader()
        writer.writerows(metrics_rows)

    print("\n=== PCA experiment summary ===")
    for row in metrics_rows:
        print(f"  z={row['z']}, k={row['k']}: "
              f"Sil={row['silhouette']:.4f}, DB={row['davies_bouldin']:.4f}, "
              f"CH={row['calinski_harabasz']:.1f}, "
              f"Max%={row['max_class_ratio']:.3f}")

    print("\nSaved outputs to:", OUT_DIR)
    print("Done.")


if __name__ == "__main__":
    main()
