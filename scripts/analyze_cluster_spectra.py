"""为每个聚类类别计算光谱统计量、波段比值，并绘制光谱响应曲线。"""
from pathlib import Path
import csv

import numpy as np
import rasterio
import matplotlib.pyplot as plt

from plot_style import COLORBLIND_PALETTE, DPI_LINE, apply_report_style

ROOT = Path(__file__).parent.parent.resolve()
OUT_DIR = ROOT / "results" / "cluster_spectra"
OUT_DIR.mkdir(parents=True, exist_ok=True)

STACK_PATH = ROOT / "data" / "processed" / "s2_tuwu_yandong_20240813_stack_20m_masked.tif"
SAE_LABEL_PATH = ROOT / "results" / "cluster_sae" / "sae_kmeans_k6_z5.tif"

BAND_NAMES = ["B02", "B03", "B04", "B05", "B06", "B07", "B08", "B8A", "B11", "B12"]
BAND_WL = [490, 560, 665, 705, 740, 783, 842, 865, 1610, 2190]  # 中心波长 nm
RATIO_PAIRS = [
    ("B11/B12", 8, 9),
    ("B12/B8A", 9, 7),
    ("B11/B8A", 8, 7),
    ("B04/B02", 2, 0),
    ("B08/B04", 6, 2),
]
MAX_SAMPLE_PER_CLUSTER = 100_000
RANDOM_STATE = 42

apply_report_style()


def main():
    rng = np.random.default_rng(RANDOM_STATE)

    # 1. 读取数据
    with rasterio.open(STACK_PATH) as src:
        stack = src.read()  # (10, H, W)
        profile = src.profile

    with rasterio.open(SAE_LABEL_PATH) as src:
        labels_2d = src.read(1)  # (H, W)

    n_bands, H, W = stack.shape
    print(f"Stack shape: {stack.shape}, Labels shape: {labels_2d.shape}")

    # 过滤有效像元（排除 nodata -9999 和无类别 -1）
    valid = (labels_2d >= 0) & np.all(stack > -9000, axis=0)
    labels_flat = labels_2d[valid]
    spectra = stack[:, valid].T  # (N, 10)

    n_total = labels_flat.shape[0]
    print(f"Valid labeled pixels: {n_total}")

    cluster_ids = np.unique(labels_flat)
    print(f"Cluster IDs: {cluster_ids}")

    # 2. 计算每类光谱统计
    stats_rows = []
    ratio_rows = []

    fig, ax = plt.subplots(figsize=(10, 6))
    colors = COLORBLIND_PALETTE[:len(cluster_ids)]

    for idx, cid in enumerate(sorted(cluster_ids)):
        mask = labels_flat == cid
        cluster_spec = spectra[mask]
        n_pix = cluster_spec.shape[0]
        print(f"  Cluster {cid}: {n_pix} pixels ({n_pix / n_total:.3%})")

        # 抽样用于稳定计算和绘图
        if n_pix > MAX_SAMPLE_PER_CLUSTER:
            sample_idx = rng.choice(n_pix, size=MAX_SAMPLE_PER_CLUSTER, replace=False)
            cluster_spec_sample = cluster_spec[sample_idx]
        else:
            cluster_spec_sample = cluster_spec

        mean_vals = cluster_spec.mean(axis=0)
        std_vals = cluster_spec.std(axis=0)
        median_vals = np.median(cluster_spec, axis=0)

        for b_idx, b_name in enumerate(BAND_NAMES):
            stats_rows.append({
                "cluster_id": int(cid),
                "band": b_name,
                "wavelength_nm": BAND_WL[b_idx],
                "mean": float(mean_vals[b_idx]),
                "std": float(std_vals[b_idx]),
                "median": float(median_vals[b_idx]),
                "pixel_count": int(n_pix),
            })

        # 绘制光谱曲线（均值 ± 标准差）
        ax.fill_between(
            range(n_bands),
            mean_vals - std_vals,
            mean_vals + std_vals,
            alpha=0.15,
            color=colors[idx],
        )
        ax.plot(
            range(n_bands),
            mean_vals,
            marker="o",
            color=colors[idx],
            linewidth=1.5,
            markersize=4,
            label=f"Cluster {cid} ({n_pix / n_total:.1%})",
        )

        # 波段比值（在抽样数据上计算以避免极端值影响太大）
        for ratio_name, bi, bj in RATIO_PAIRS:
            ratio_vals = cluster_spec_sample[:, bi] / (cluster_spec_sample[:, bj] + 1e-8)
            ratio_rows.append({
                "cluster_id": int(cid),
                "ratio": ratio_name,
                "mean": float(np.mean(ratio_vals)),
                "std": float(np.std(ratio_vals)),
                "median": float(np.median(ratio_vals)),
                "p5": float(np.percentile(ratio_vals, 5)),
                "p95": float(np.percentile(ratio_vals, 95)),
            })

    # 3. 保存光谱统计 CSV
    with open(OUT_DIR / "cluster_spectral_statistics.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=[
            "cluster_id", "band", "wavelength_nm", "mean", "std", "median", "pixel_count",
        ])
        writer.writeheader()
        writer.writerows(stats_rows)

    # 4. 保存波段比值 CSV
    with open(OUT_DIR / "cluster_band_ratio_table.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(f, fieldnames=[
            "cluster_id", "ratio", "mean", "std", "median", "p5", "p95",
        ])
        writer.writeheader()
        writer.writerows(ratio_rows)

    # 5. 保存光谱曲线图
    ax.set_xticks(range(n_bands))
    ax.set_xticklabels(BAND_NAMES, fontsize=8)
    ax.set_xlabel("Band / Sentinel-2 MSI")
    ax.set_ylabel("Surface reflectance / 1")
    ax.set_title("Mean spectral profiles by cluster (SAE z=5, k=6)")
    ax.legend(fontsize=8, ncol=2, loc="upper left", frameon=False)
    ax.grid(axis="y", alpha=0.15)

    # 标注 SWIR 特征吸收区域
    ax.axvspan(7.5, 9.5, color="gray", alpha=0.08)
    ax.text(8.5, ax.get_ylim()[1] * 0.98, "SWIR\n(OH⁻/CO₃²⁻)", fontsize=8,
            ha="center", va="top", color="gray")

    fig.tight_layout()
    fig.savefig(OUT_DIR / "cluster_spectral_profiles.png", dpi=DPI_LINE)
    fig.savefig(OUT_DIR / "cluster_spectral_profiles.pdf", dpi=DPI_LINE)
    plt.close()

    # 6. 保存带误差棒的单独大图（每类一条）
    fig, axes = plt.subplots(2, 3, figsize=(15, 9))
    for idx, cid in enumerate(sorted(cluster_ids)):
        ax_i = axes.ravel()[idx]
        mask = labels_flat == cid
        cluster_spec = spectra[mask]
        n_pix = cluster_spec.shape[0]
        if n_pix > MAX_SAMPLE_PER_CLUSTER:
            sample_idx_i = rng.choice(n_pix, size=MAX_SAMPLE_PER_CLUSTER, replace=False)
            cluster_spec_s = cluster_spec[sample_idx_i]
        else:
            cluster_spec_s = cluster_spec

        mean_vals = cluster_spec_s.mean(axis=0)
        std_vals = cluster_spec_s.std(axis=0)

        ax_i.fill_between(
            range(n_bands), mean_vals - std_vals, mean_vals + std_vals,
            alpha=0.2, color=colors[idx],
        )
        ax_i.plot(range(n_bands), mean_vals, marker="o", color=colors[idx],
                  linewidth=1.5, markersize=4)
        ax_i.set_xticks(range(n_bands))
        ax_i.set_xticklabels(BAND_NAMES, fontsize=7, rotation=45)
        ax_i.set_title(f"Cluster {cid} ({n_pix / n_total:.1%})", fontsize=9)
        ax_i.grid(axis="y", alpha=0.15)
        ax_i.axvspan(7.5, 9.5, color="gray", alpha=0.08)

    fig.suptitle("Spectral profiles per cluster (SAE z=5, k=6)", fontsize=9, y=1.01)
    fig.tight_layout()
    fig.savefig(OUT_DIR / "cluster_spectral_profiles_per_class.png", dpi=DPI_LINE)
    plt.close()

    # 7. 打印关键比值摘要
    print("\n=== 波段比值摘要（按 cluster 排列）===")
    for cid in sorted(cluster_ids):
        print(f"\n  Cluster {cid}:")
        for r in ratio_rows:
            if r["cluster_id"] == cid:
                print(f"    {r['ratio']}: mean={r['mean']:.4f}, median={r['median']:.4f}, "
                      f"p5={r['p5']:.4f}, p95={r['p95']:.4f}")

    print(f"\nSaved to: {OUT_DIR}")
    print("Done.")


if __name__ == "__main__":
    main()
