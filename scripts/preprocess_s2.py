from pathlib import Path

import numpy as np
import rasterio
from rasterio.windows import from_bounds, Window
from rasterio.warp import transform_bounds, reproject, Resampling
import matplotlib.pyplot as plt


# ========== 1. 路径设置 ==========
ROOT = Path(__file__).parent.parent.resolve()
BAND_DIR = ROOT / "data" / "raw_bands"
OUT_DIR = ROOT / "data" / "processed"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# 研究区范围：新疆哈密土屋-延东
# 顺序：min_lon, min_lat, max_lon, max_lat
AOI_LONLAT = (94.30, 42.02, 94.70, 42.32)

# 输入波段
BANDS_20M = {
    "B02": BAND_DIR / "B02_20m.jp2",
    "B03": BAND_DIR / "B03_20m.jp2",
    "B04": BAND_DIR / "B04_20m.jp2",
    "B05": BAND_DIR / "B05_20m.jp2",
    "B06": BAND_DIR / "B06_20m.jp2",
    "B07": BAND_DIR / "B07_20m.jp2",
    "B8A": BAND_DIR / "B8A_20m.jp2",
    "B11": BAND_DIR / "B11_20m.jp2",
    "B12": BAND_DIR / "B12_20m.jp2",
}

B08_10M = BAND_DIR / "B08_10m.jp2"
SCL_20M = BAND_DIR / "SCL_20m.jp2"

# SAE / k-means 的最终输入波段顺序
BAND_ORDER = ["B02", "B03", "B04", "B05", "B06", "B07", "B08", "B8A", "B11", "B12"]


# ========== 2. 工具函数 ==========
def check_files():
    required = list(BANDS_20M.values()) + [B08_10M, SCL_20M]
    missing = [str(p) for p in required if not p.exists()]
    if missing:
        raise FileNotFoundError("以下文件不存在：\n" + "\n".join(missing))


def make_crop_window(ref_ds, bbox_lonlat):
    min_lon, min_lat, max_lon, max_lat = bbox_lonlat

    # 把经纬度范围 EPSG:4326 转成影像自身 CRS，Sentinel-2 tile 通常是 UTM 投影
    minx, miny, maxx, maxy = transform_bounds(
        "EPSG:4326",
        ref_ds.crs,
        min_lon,
        min_lat,
        max_lon,
        max_lat,
        densify_pts=21,
    )

    raw_window = from_bounds(minx, miny, maxx, maxy, transform=ref_ds.transform)
    raw_window = raw_window.round_offsets().round_lengths()

    # 防止窗口超出影像范围
    col_off = max(0, int(raw_window.col_off))
    row_off = max(0, int(raw_window.row_off))
    col_end = min(ref_ds.width, int(raw_window.col_off + raw_window.width))
    row_end = min(ref_ds.height, int(raw_window.row_off + raw_window.height))

    width = col_end - col_off
    height = row_end - row_off

    if width <= 0 or height <= 0:
        raise ValueError("AOI 与影像没有交集。请检查经纬度范围或是否选错 tile。")

    return Window(col_off, row_off, width, height)


def read_20m_band(path, window):
    with rasterio.open(path) as src:
        return src.read(1, window=window).astype(np.float32)


def resample_10m_to_ref_grid(path, dst_shape, dst_transform, dst_crs):
    dst = np.zeros(dst_shape, dtype=np.float32)

    with rasterio.open(path) as src:
        reproject(
            source=rasterio.band(src, 1),
            destination=dst,
            src_transform=src.transform,
            src_crs=src.crs,
            src_nodata=0,
            dst_transform=dst_transform,
            dst_crs=dst_crs,
            dst_nodata=0,
            resampling=Resampling.bilinear,
        )

    return dst


def percentile_stretch(rgb, valid_mask):
    """用于快速预览，不影响正式数据。"""
    out = np.zeros_like(rgb, dtype=np.float32)
    for i in range(rgb.shape[2]):
        band = rgb[:, :, i]
        values = band[valid_mask & np.isfinite(band)]
        if values.size == 0:
            continue
        lo, hi = np.percentile(values, [2, 98])
        out[:, :, i] = np.clip((band - lo) / (hi - lo + 1e-6), 0, 1)
    return out


# ========== 3. 主流程 ==========
def main():
    check_files()

    ref_path = BANDS_20M["B02"]

    with rasterio.open(ref_path) as ref:
        window = make_crop_window(ref, AOI_LONLAT)
        crop_transform = ref.window_transform(window)
        crop_height = int(window.height)
        crop_width = int(window.width)
        ref_crs = ref.crs

        profile = ref.profile.copy()
        profile.update(
            driver="GTiff",
            height=crop_height,
            width=crop_width,
            count=len(BAND_ORDER),
            dtype="float32",
            transform=crop_transform,
            crs=ref_crs,
            nodata=-9999.0,
            compress="lzw",
        )

    print("AOI crop size:", crop_width, "x", crop_height)
    print("Output CRS:", ref_crs)

    # 读取 20m 波段
    band_arrays = {}
    for name, path in BANDS_20M.items():
        print(f"Reading {name}: {path.name}")
        band_arrays[name] = read_20m_band(path, window)

    # B08 是 10m，需要重采样到 20m AOI 网格
    print("Resampling B08 10m -> 20m")
    band_arrays["B08"] = resample_10m_to_ref_grid(
        B08_10M,
        dst_shape=(crop_height, crop_width),
        dst_transform=crop_transform,
        dst_crs=ref_crs,
    )

    # 读取 SCL
    print("Reading SCL")
    scl = read_20m_band(SCL_20M, window).astype(np.uint8)

    # SCL 掩膜
    # 0 No data
    # 1 Saturated / Defective
    # 2 Dark Area Pixels
    # 3 Cloud Shadows
    # 6 Water
    # 8 Clouds medium probability
    # 9 Clouds high probability
    # 10 Cirrus
    # 11 Snow / Ice
    invalid_scl = [0, 1, 2, 3, 6, 8, 9, 10, 11]
    valid_mask = ~np.isin(scl, invalid_scl)

    # 堆叠 10 个光谱波段
    stack = np.stack([band_arrays[name] for name in BAND_ORDER], axis=0)

    # 去掉所有波段为 0 或异常的像元
    valid_mask = valid_mask & np.all(stack > 0, axis=0)

    valid_count = int(valid_mask.sum())
    total_count = int(valid_mask.size)
    print(f"Valid pixels: {valid_count} / {total_count} = {valid_count / total_count:.2%}")

    # 输出掩膜后的 10 波段 GeoTIFF
    stack_out = np.where(valid_mask[None, :, :], stack, -9999.0).astype(np.float32)

    out_tif = OUT_DIR / "s2_tuwu_yandong_20240813_stack_20m_masked.tif"
    with rasterio.open(out_tif, "w", **profile) as dst:
        for i, name in enumerate(BAND_ORDER, start=1):
            dst.write(stack_out[i - 1], i)
            dst.set_band_description(i, name)

    # 输出有效像元 mask
    mask_profile = profile.copy()
    mask_profile.update(count=1, dtype="uint8", nodata=0)

    out_mask = OUT_DIR / "s2_tuwu_yandong_20240813_valid_mask.tif"
    with rasterio.open(out_mask, "w", **mask_profile) as dst:
        dst.write(valid_mask.astype(np.uint8), 1)

    # 输出机器学习用矩阵：N_pixels × 10
    X = stack[:, valid_mask].T.astype(np.float32)
    out_npz = OUT_DIR / "s2_tuwu_yandong_20240813_valid_pixels.npz"
    np.savez_compressed(
        out_npz,
        X=X,
        band_order=np.array(BAND_ORDER),
    )

    print("Saved:")
    print(" ", out_tif)
    print(" ", out_mask)
    print(" ", out_npz)
    print("X shape:", X.shape)

    # 快速预览：真彩色 B04/B03/B02
    true_rgb = np.dstack([
        band_arrays["B04"],
        band_arrays["B03"],
        band_arrays["B02"],
    ])
    true_rgb = percentile_stretch(true_rgb, valid_mask)
    plt.imsave(OUT_DIR / "preview_true_color_B04_B03_B02.png", true_rgb)

    # 快速预览：地质假彩色 B12/B8A/B02
    geology_rgb = np.dstack([
        band_arrays["B12"],
        band_arrays["B8A"],
        band_arrays["B02"],
    ])
    geology_rgb = percentile_stretch(geology_rgb, valid_mask)
    plt.imsave(OUT_DIR / "preview_geology_B12_B8A_B02.png", geology_rgb)

    print("Preview images saved.")


if __name__ == "__main__":
    main()