"""用 Python 代替 QGIS 生成最终遥感地质解释图。

底图：Sentinel-2 B12/B8A/B02 地质假彩色
叠加：SAE z=5,k=6 聚类结果（半透明）
标注：C1 candidate clue 高亮 + 图例 + 比例尺 + 指北针
"""
from pathlib import Path

import numpy as np
import rasterio
import matplotlib.pyplot as plt
from matplotlib.patches import FancyArrowPatch, Rectangle
from matplotlib.lines import Line2D
import matplotlib.ticker as mticker

from plot_style import DPI_RASTER, apply_report_style

ROOT = Path(__file__).parent.parent.resolve()
STACK_PATH = ROOT / "data" / "processed" / "s2_tuwu_yandong_20240813_stack_20m_masked.tif"
SAE_LABEL_PATH = ROOT / "results" / "cluster_sae" / "sae_kmeans_k6_z5.tif"
OUT_DIR = ROOT / "results" / "final_figures"
OUT_DIR.mkdir(parents=True, exist_ok=True)

BAND_NAMES = ["B02", "B03", "B04", "B05", "B06", "B07", "B08", "B8A", "B11", "B12"]

# — 固定颜色映射（Cluster 0–5）—
CLUSTER_COLORS = {
    0: "#1f77b4",  # blue
    1: "#E69F00",  # orange - candidate clue
    2: "#7f7f7f",  # gray
    3: "#9467bd",  # purple
    4: "#8c564b",  # brown
    5: "#bcbd22",  # olive
}

CLUSTER_LABELS = {
    0: "C0: unaltered intrusive candidate",
    1: "C1: spectral-spatial\n    candidate clue",
    2: "C2: volcanic-sedimentary\n    background",
    3: "C3: mixed / transition pixels",
    4: "C4: mafic rock or\n    terrain shadow",
    5: "C5: sediment /\n    high-iron candidate",
}

PIXEL_SIZE_M = 20  # 空间分辨率

apply_report_style()


def percentile_stretch(rgb, lo=2, hi=98):
    """对 RGB 各通道分别做 percentile stretch 到 [0, 1]."""
    out = np.zeros_like(rgb, dtype=np.float32)
    for i in range(rgb.shape[2]):
        band = rgb[:, :, i]
        values = band[np.isfinite(band) & (band > 0)]
        if values.size == 0:
            continue
        vmin, vmax = np.percentile(values, [lo, hi])
        out[:, :, i] = np.clip((band - vmin) / (vmax - vmin + 1e-6), 0, 1)
    return out


def clean_mask(mask):
    """用二值形态学开/闭运算去除小噪点。若 scipy 不可用则跳过。"""
    try:
        from scipy.ndimage import binary_opening, binary_closing
        mask = binary_closing(binary_opening(mask, iterations=2), iterations=2)
    except ImportError:
        pass
    return mask


def find_contour_outline(mask):
    """提取 mask 的外轮廓像素坐标（行, 列），用于 Matplotlib 叠加。"""
    from scipy.ndimage import binary_dilation
    inner = binary_dilation(mask, iterations=1) ^ mask
    if inner.sum() == 0:
        inner = mask ^ mask
    return np.argwhere(inner)


def add_scale_bar(ax, pixel_width, pixel_size_m, max_km=10):
    """在右下角添加比例尺。"""
    # 选择最接近 max_km 的整公里数
    km_per_pixel = pixel_size_m / 1000.0
    width_km = pixel_width * km_per_pixel
    bar_km = max_km
    while bar_km > width_km * 0.6:
        bar_km = bar_km // 2 if bar_km >= 4 else bar_km - 1
    if bar_km < 1:
        bar_km = 1
    bar_pixels = bar_km / km_per_pixel

    # 放在右下角
    x0 = pixel_width - bar_pixels - 30
    y0 = 30
    rect = Rectangle((x0, y0), bar_pixels, 8, facecolor="white", edgecolor="black",
                     linewidth=1.2, zorder=10)
    ax.add_patch(rect)
    ax.text(x0 + bar_pixels / 2, y0 + 16, f"{bar_km} km", ha="center", va="bottom",
            fontsize=9, fontweight="bold", color="black", zorder=10,
            bbox=dict(boxstyle="square,pad=0.1", facecolor="white", edgecolor="none", alpha=0.8))


def add_north_arrow(ax, x, y, size=40):
    """在指定位置添加简洁指北针。"""
    ax.annotate("N", xy=(x, y + size * 1.15), ha="center", va="bottom",
                fontsize=11, fontweight="bold", color="black", zorder=10,
                bbox=dict(boxstyle="square,pad=0.1", facecolor="white",
                          edgecolor="none", alpha=0.8))
    arrow = FancyArrowPatch(
        (x, y), (x, y + size),
        arrowstyle="-|>,head_length=8,head_width=6",
        color="black", linewidth=2, zorder=10,
    )
    ax.add_patch(arrow)


def main():
    # ---- 1. 读取数据 ----
    with rasterio.open(STACK_PATH) as src:
        stack = src.read()  # (10, H, W)
        H, W = src.height, src.width
        crs = src.crs

    with rasterio.open(SAE_LABEL_PATH) as src:
        labels = src.read(1)  # (H, W)

    print(f"Stack: {stack.shape}, Labels: {labels.shape}, CRS: {crs}")

    # ---- 2. 构建地质假彩色底图（B12/B8A/B02）----
    # 波段顺序: B02=0, B03=1, B04=2, B05=3, B06=4, B07=5, B08=6, B8A=7, B11=8, B12=9
    rgb = np.dstack([stack[9], stack[7], stack[0]]).astype(np.float32)  # B12, B8A, B02
    rgb_stretched = percentile_stretch(rgb)

    # ---- 3. 构建聚类叠加层 ----
    overlay = np.zeros((H, W, 4), dtype=np.float32)
    alpha = 0.45

    for cid, hex_color in CLUSTER_COLORS.items():
        mask = labels == cid
        r = int(hex_color[1:3], 16) / 255.0
        g = int(hex_color[3:5], 16) / 255.0
        b = int(hex_color[5:7], 16) / 255.0
        overlay[mask, 0] = r
        overlay[mask, 1] = g
        overlay[mask, 2] = b
        overlay[mask, 3] = alpha

    # ---- 4. 绘图 ----
    fig, ax = plt.subplots(figsize=(14, 12))

    # 底图
    ax.imshow(rgb_stretched, extent=(0, W, H, 0), interpolation="bilinear")

    # 聚类叠加
    ax.imshow(overlay, extent=(0, W, H, 0), interpolation="nearest")

    # ---- 5. C1 candidate clue highlight ----
    c1_mask = labels == 1
    c1_mask = clean_mask(c1_mask)
    contour_pts = find_contour_outline(c1_mask)
    if contour_pts.size > 0:
        # 随机抽样减少绘图点数（保留 20%）
        if len(contour_pts) > 50000:
            rng = np.random.default_rng(42)
            idx = rng.choice(len(contour_pts), size=min(50000, len(contour_pts)), replace=False)
            contour_pts = contour_pts[idx]
        ax.scatter(contour_pts[:, 1], contour_pts[:, 0], s=0.3, c="#E69F00",
                   alpha=0.7, zorder=8, linewidths=0)

    # C1 标注箭头
    c1_ys, c1_xs = np.where(c1_mask)
    if len(c1_ys) > 0:
        # 取最大连通区域的中心
        # 用简单方法：取 mask 的质心
        cy, cx = c1_ys.mean(), c1_xs.mean()
        ax.annotate(
            "C1: candidate clue\nvalidation required",
            xy=(cx, cy), xytext=(cx + 200, cy + 150),
            fontsize=9, fontweight="bold", color="#E69F00",
            arrowprops=dict(arrowstyle="->", color="#E69F00", lw=1.5, connectionstyle="arc3,rad=0.3"),
            bbox=dict(boxstyle="square,pad=0.25", facecolor="white", edgecolor="#E69F00", alpha=0.9),
            zorder=11,
        )

    # ---- 6. 比例尺 ----
    add_scale_bar(ax, W, PIXEL_SIZE_M, max_km=10)

    # ---- 7. 指北针 ----
    add_north_arrow(ax, 35, H - 80, size=50)

    # ---- 8. 图例 ----
    legend_patches = []
    for cid in sorted(CLUSTER_COLORS.keys()):
        legend_patches.append(
            plt.matplotlib.patches.Patch(
                facecolor=CLUSTER_COLORS[cid],
                edgecolor="black",
                linewidth=0.5,
                alpha=0.7,
                label=CLUSTER_LABELS[cid],
            )
        )

    legend = ax.legend(
        handles=legend_patches,
        loc="upper left",
        fontsize=8,
        framealpha=0.92,
        edgecolor="gray",
        title="SAE z=5, k=6 clusters",
        title_fontsize=9,
    )
    legend.get_frame().set_linewidth(0.8)

    # ---- 9. 标题与坐标 ----
    ax.set_title(
        "Remote Sensing Geological Interpretation Map\n"
        "Tuwu–Yandong, Hami, Xinjiang  |  Sentinel-2A 2024-08-13  |  B12/B8A/B02",
        fontsize=9, fontweight="bold", pad=10,
    )

    # 坐标轴标注（像素坐标 + 地理标记说明）
    ax.set_xlabel("Column / 20 m pixel")
    ax.set_ylabel("Row / 20 m pixel")
    ax.tick_params(labelsize=7)

    # 图件说明
    ax.text(
        0.5, -0.06,
        "Base map: Sentinel-2 B12 (2190 nm)/B8A (865 nm)/B02 (490 nm) geology false-color composite.\n"
        "Overlay: SAE z=5, k=6 clustering result (45% transparency). "
        "C1 (orange outline) is retained as a spectral-spatial candidate clue requiring validation.\n"
        "Generated with Python/rasterio/matplotlib - fully reproducible.",
        transform=ax.transAxes, ha="center", va="top",
        fontsize=7, color="gray", style="italic",
    )

    # ---- 10. 保存 ----
    fig.tight_layout()
    out_png = OUT_DIR / "python_final_interpretation_map.png"
    out_pdf = OUT_DIR / "python_final_interpretation_map.pdf"
    fig.savefig(out_png, dpi=DPI_RASTER, bbox_inches="tight")
    fig.savefig(out_pdf, dpi=DPI_RASTER, bbox_inches="tight")
    plt.close()

    print(f"Saved: {out_png}")
    print(f"Saved: {out_pdf}")
    print("Done.")


if __name__ == "__main__":
    main()
