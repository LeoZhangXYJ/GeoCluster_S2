from pathlib import Path
import csv

import numpy as np
import rasterio
import matplotlib.pyplot as plt

from sklearn.preprocessing import StandardScaler
from sklearn.cluster import KMeans


ROOT = Path(__file__).parent.parent.resolve()
PROCESSED = ROOT / "data" / "processed"
OUT_DIR = ROOT / "results" / "cluster_baseline"
OUT_DIR.mkdir(parents=True, exist_ok=True)

NPZ_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_pixels.npz"
MASK_PATH = PROCESSED / "s2_tuwu_yandong_20240813_valid_mask.tif"
REF_TIF = PROCESSED / "s2_tuwu_yandong_20240813_stack_20m_masked.tif"

RANDOM_STATE = 42
SAMPLE_SIZE = 200_000
K_RANGE = list(range(2, 13))


def choose_elbow_by_max_distance(k_values, inertias):
    """
    简单 elbow 自动选择：
    把 inertia 曲线首尾连成直线，选择到直线距离最大的 k。
    """
    x = np.array(k_values, dtype=np.float64)
    y = np.array(inertias, dtype=np.float64)

    # 归一化，避免尺度影响
    x_norm = (x - x.min()) / (x.max() - x.min())
    y_norm = (y - y.min()) / (y.max() - y.min() + 1e-12)

    p1 = np.array([x_norm[0], y_norm[0]])
    p2 = np.array([x_norm[-1], y_norm[-1]])

    distances = []
    for xi, yi in zip(x_norm, y_norm):
        p = np.array([xi, yi])
        v = p2 - p1
        w = p1 - p
        dist = np.abs(v[0] * w[1] - v[1] * w[0]) / (np.linalg.norm(v) + 1e-12)
        distances.append(dist)

    best_idx = int(np.argmax(distances))
    return int(k_values[best_idx]), distances


def save_cluster_png(label_map, out_png):
    """
    输出聚类预览图。
    -1 表示无效像元，显示为黑色。
    """
    img = label_map.astype(np.float32)
    img[img < 0] = np.nan

    plt.figure(figsize=(8, 8))
    plt.imshow(img, cmap="tab20")
    plt.axis("off")
    plt.title("K-means clustering result")
    plt.tight_layout()
    plt.savefig(out_png, dpi=300, bbox_inches="tight")
    plt.close()


def main():
    print("Loading:", NPZ_PATH)
    data = np.load(NPZ_PATH, allow_pickle=True)
    X = data["X"].astype(np.float32)
    band_order = data["band_order"]

    print("X shape:", X.shape)
    print("Band order:", band_order)

    # 1. 标准化
    scaler = StandardScaler()
    X_scaled = scaler.fit_transform(X).astype(np.float32)

    # 保存标准化统计量，后续报告可用
    np.savez(
        OUT_DIR / "standard_scaler_stats.npz",
        mean=scaler.mean_,
        scale=scaler.scale_,
        var=scaler.var_,
        band_order=band_order,
    )

    # 2. 抽样用于 elbow 和模型训练
    n = X_scaled.shape[0]
    sample_n = min(SAMPLE_SIZE, n)

    rng = np.random.default_rng(RANDOM_STATE)
    sample_idx = rng.choice(n, size=sample_n, replace=False)
    X_sample = X_scaled[sample_idx]

    print("Sample size for KMeans:", X_sample.shape)

    # 3. 计算 elbow curve
    inertias = []
    models = {}

    for k in K_RANGE:
        print(f"Fitting KMeans k={k}")
        km = KMeans(
            n_clusters=k,
            random_state=RANDOM_STATE,
            n_init=10,
            max_iter=300,
        )
        km.fit(X_sample)
        inertias.append(float(km.inertia_))
        models[k] = km

    k_auto, distances = choose_elbow_by_max_distance(K_RANGE, inertias)
    print("Auto-selected k:", k_auto)

    # 4. 保存 elbow 数据
    csv_path = OUT_DIR / "elbow_curve.csv"
    with open(csv_path, "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["k", "inertia", "distance_to_line"])
        for k, inertia, dist in zip(K_RANGE, inertias, distances):
            writer.writerow([k, inertia, dist])

    # 5. 保存 elbow 图
    plt.figure(figsize=(7, 5))
    plt.plot(K_RANGE, inertias, marker="o")
    plt.axvline(k_auto, linestyle="--", label=f"auto k = {k_auto}")
    plt.xlabel("Number of clusters k")
    plt.ylabel("Inertia")
    plt.title("Elbow curve for K-means")
    plt.legend()
    plt.tight_layout()
    plt.savefig(OUT_DIR / "elbow_curve.png", dpi=300)
    plt.close()

    # 6. 用自动选择的 k 对所有有效像元预测
    best_model = models[k_auto]
    labels = best_model.predict(X_scaled).astype(np.int16)

    # 7. 还原为二维聚类图
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

    out_tif = OUT_DIR / f"kmeans_baseline_k{k_auto}.tif"
    with rasterio.open(out_tif, "w", **profile) as dst:
        dst.write(label_map, 1)

    # 9. 保存 PNG 预览
    save_cluster_png(label_map, OUT_DIR / f"kmeans_baseline_k{k_auto}.png")

    # 10. 保存每类像元数量
    unique, counts = np.unique(labels, return_counts=True)
    with open(OUT_DIR / f"kmeans_baseline_k{k_auto}_class_counts.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["cluster_id", "pixel_count", "percentage"])
        for u, c in zip(unique, counts):
            writer.writerow([int(u), int(c), float(c / labels.size)])

    print("Saved outputs to:", OUT_DIR)
    print("Selected k:", k_auto)
    print("Done.")


if __name__ == "__main__":
    main()