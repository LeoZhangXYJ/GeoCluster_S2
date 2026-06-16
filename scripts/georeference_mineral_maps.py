"""Georeference adjacent 1:250,000 hyperspectral mineral maps and clip to AOI.

The input JPG files are Geocloud preview maps with the same page layout.
This script crops the main map panel, assigns the latitude/longitude extent
from the map-sheet code, reprojects all sheets to the Sentinel-2 20 m grid,
and writes an AOI mosaic plus a cluster-overlay quicklook.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import numpy as np
import rasterio
from PIL import Image
from matplotlib import pyplot as plt
from matplotlib.colors import ListedColormap
from scipy.ndimage import binary_closing, binary_opening
from rasterio.transform import from_bounds
from rasterio.warp import Resampling, reproject

from plot_style import DPI_RASTER, apply_report_style

ROOT = Path(__file__).parent.parent.resolve()
REF_TIF = ROOT / "data" / "processed" / "s2_tuwu_yandong_20240813_stack_20m_masked.tif"
LABEL_TIF = ROOT / "results" / "cluster_sae" / "sae_kmeans_k6_z5.tif"
OUT_DIR = ROOT / "results" / "geology_validation" / "mineral_maps"
OUT_DIR.mkdir(parents=True, exist_ok=True)

# Main map panel bounds in the 9450 x 7088 Geocloud JPG layout.
# These exclude the title, side text, legend, and scale-bar area.
MAP_CROP_BOX = (285, 826, 6837, 6416)  # left, upper, right, lower

# Inner map boxes relative to MAP_CROP_BOX. The Geocloud JPGs are page layouts,
# so the visible map frame is not identical across sheets.
INNER_MAP_BOXES = {
    "J46C002003": (249, 265, 6438, 5516),
    "J46C002004": (121, 185, 6347, 5432),
    "J46C003003": (118, 287, 6391, 5536),
    "J46C003004": (120, 178, 6390, 5433),
}


@dataclass(frozen=True)
class Sheet:
    code: str
    pattern: str
    lon_min: float
    lon_max: float
    lat_min: float
    lat_max: float


SHEETS = [
    Sheet("J46C002003", "J46 C 002003", 93.0, 94.5, 42.0, 43.0),
    Sheet("J46C002004", "J46 C 002004", 94.5, 96.0, 42.0, 43.0),
    Sheet("J46C003003", "J46 C 003003", 93.0, 94.5, 41.0, 42.0),
    Sheet("J46C003004", "J46 C 003004", 94.5, 96.0, 41.0, 42.0),
]

CLUSTER_COLORS = [
    "#1f77b4",
    "#E69F00",
    "#56B4E9",
    "#CC79A7",
    "#999999",
    "#000000",
]

EDGE_FRAME_MARGIN_PX = 100


def find_sheet_file(sheet: Sheet) -> Path:
    normalized_code = sheet.pattern.replace(" ", "")
    candidates = list(ROOT.glob("*高光谱遥感矿物填图.jpg"))
    candidates.extend((ROOT / "data" / "geology").glob("*高光谱遥感矿物填图.jpg"))
    matches = sorted(
        path for path in candidates
        if normalized_code in path.name.replace(" ", "")
    )
    if not matches:
        raise FileNotFoundError(f"Missing JPG for sheet {sheet.code}: pattern {sheet.pattern}")
    return matches[0]


def crop_sheet_image(sheet: Sheet, path: Path) -> tuple[np.ndarray, np.ndarray]:
    image = Image.open(path).convert("RGB")
    print(f"  JPG file: {path.name}", flush=True)
    print(f"  image.size: {image.size}", flush=True)
    outer_crop = image.crop(MAP_CROP_BOX)
    inner_box = INNER_MAP_BOXES.get(sheet.code)
    if inner_box is None:
        crop = outer_crop
        print(f"  inner crop box: <none>; using MAP_CROP_BOX={MAP_CROP_BOX}", flush=True)
    else:
        crop = outer_crop.crop(inner_box)
        print(f"  inner crop box within MAP_CROP_BOX: {inner_box}", flush=True)
    rgb = np.asarray(crop)
    print(f"  crop.shape: {rgb.shape}", flush=True)
    # Geocloud preview JPGs contain a large white page background around the map panel.
    # We treat near-white pixels as background so they do not dominate the mosaic.
    nonwhite = np.any(rgb < 245, axis=2)
    channel_spread = rgb.max(axis=2) - rgb.min(axis=2)
    height, width, _ = rgb.shape
    edge_frame = np.zeros((height, width), dtype=bool)
    margin = min(EDGE_FRAME_MARGIN_PX, width // 8)
    edge_frame[:, :margin] = True
    edge_frame[:, -margin:] = True
    neutral_edge = edge_frame & (channel_spread < 18)
    valid = nonwhite & (~neutral_edge)
    valid = binary_opening(valid, iterations=1)
    valid = binary_closing(valid, iterations=2)
    print(f"  crop valid pixels: {int(valid.sum())}/{valid.size} ({valid.mean():.2%})", flush=True)
    return rgb, valid


def write_sheet_geotiff(sheet: Sheet, rgb: np.ndarray) -> Path:
    height, width, _ = rgb.shape
    transform = from_bounds(sheet.lon_min, sheet.lat_min, sheet.lon_max, sheet.lat_max, width, height)
    out_path = OUT_DIR / f"{sheet.code}_mineral_map_epsg4326.tif"
    profile = {
        "driver": "GTiff",
        "height": height,
        "width": width,
        "count": 3,
        "dtype": "uint8",
        "crs": "EPSG:4326",
        "transform": transform,
        "compress": "lzw",
    }
    with rasterio.open(out_path, "w", **profile) as dst:
        dst.write(np.moveaxis(rgb, 2, 0))
    return out_path


def reproject_to_reference(
    sheet: Sheet, rgb: np.ndarray, valid_mask: np.ndarray, ref_meta: dict
) -> tuple[np.ndarray, np.ndarray]:
    height, width, _ = rgb.shape
    src_transform = from_bounds(
        sheet.lon_min, sheet.lat_min, sheet.lon_max, sheet.lat_max, width, height
    )
    dst = np.zeros((3, ref_meta["height"], ref_meta["width"]), dtype=np.uint8)
    dst_mask = np.zeros((ref_meta["height"], ref_meta["width"]), dtype=np.uint8)
    src = np.moveaxis(rgb, 2, 0)
    for band_idx in range(3):
        reproject(
            source=src[band_idx],
            destination=dst[band_idx],
            src_transform=src_transform,
            src_crs="EPSG:4326",
            dst_transform=ref_meta["transform"],
            dst_crs=ref_meta["crs"],
            src_nodata=255,
            dst_nodata=0,
            resampling=Resampling.nearest,
        )
    reproject(
        source=valid_mask.astype(np.uint8),
        destination=dst_mask,
        src_transform=src_transform,
        src_crs="EPSG:4326",
        dst_transform=ref_meta["transform"],
        dst_crs=ref_meta["crs"],
        src_nodata=0,
        dst_nodata=0,
        resampling=Resampling.nearest,
    )
    return dst, dst_mask.astype(bool)


def load_reference_meta() -> dict:
    with rasterio.open(REF_TIF) as ref:
        return {
            "height": ref.height,
            "width": ref.width,
            "crs": ref.crs,
            "transform": ref.transform,
            "profile": ref.profile.copy(),
        }


def load_labels_checked(ref_meta: dict) -> np.ndarray:
    with rasterio.open(LABEL_TIF) as label:
        same_crs = label.crs == ref_meta["crs"]
        same_transform = np.allclose(
            tuple(label.transform),
            tuple(ref_meta["transform"]),
            rtol=0,
            atol=1e-9,
        )
        same_shape = label.height == ref_meta["height"] and label.width == ref_meta["width"]
        if not (same_crs and same_transform and same_shape):
            raise ValueError(
                "LABEL_TIF and REF_TIF are not on the same grid. "
                f"REF crs={ref_meta['crs']}, shape=({ref_meta['height']}, {ref_meta['width']}), "
                f"transform={ref_meta['transform']}; "
                f"LABEL crs={label.crs}, shape=({label.height}, {label.width}), "
                f"transform={label.transform}."
            )
        return label.read(1)


def write_aligned_mosaic(mosaic: np.ndarray, ref_meta: dict) -> Path:
    out_path = OUT_DIR / "tuwu_yandong_mineral_map_aligned_20m.tif"
    profile = ref_meta["profile"].copy()
    profile.update(count=3, dtype="uint8", nodata=0, compress="lzw")
    with rasterio.open(out_path, "w", **profile) as dst:
        dst.write(mosaic)
    return out_path


def write_quicklook(mosaic: np.ndarray, out_path: Path) -> None:
    rgb = np.moveaxis(mosaic, 0, 2)
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.imshow(rgb)
    ax.set_axis_off()
    ax.set_title("Geocloud hyperspectral mineral map mosaic clipped to Tuwu-Yandong AOI")
    fig.tight_layout()
    fig.savefig(out_path, dpi=DPI_RASTER, bbox_inches="tight")
    plt.close(fig)


def rgb_with_nodata_background(mosaic: np.ndarray, coverage: np.ndarray) -> np.ndarray:
    rgb = np.moveaxis(mosaic, 0, 2).copy()
    rgb[~coverage] = 245
    return rgb


def write_mineral_only(mosaic: np.ndarray, coverage: np.ndarray, out_path: Path) -> None:
    rgb = rgb_with_nodata_background(mosaic, coverage)
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.imshow(rgb)
    ax.set_axis_off()
    ax.set_title("Geocloud hyperspectral mineral map mosaic clipped to Tuwu-Yandong AOI")
    fig.tight_layout()
    fig.savefig(out_path, dpi=DPI_RASTER, bbox_inches="tight")
    plt.close(fig)


def write_labels_only(labels: np.ndarray, out_path: Path) -> None:
    label_masked = np.ma.masked_where(labels < 0, labels)
    cmap = ListedColormap(CLUSTER_COLORS)
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.imshow(label_masked, cmap=cmap, vmin=0, vmax=len(CLUSTER_COLORS) - 1)
    ax.set_axis_off()
    ax.set_title("SAE labels only")
    fig.tight_layout()
    fig.savefig(out_path, dpi=DPI_RASTER, bbox_inches="tight")
    plt.close(fig)


def write_coverage_debug(coverage: np.ndarray, out_path: Path) -> None:
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.imshow(coverage.astype(np.uint8), cmap="gray_r", vmin=0, vmax=1, interpolation="nearest")
    ax.set_axis_off()
    ax.set_title("Mineral-map coverage mask")
    fig.tight_layout()
    fig.savefig(out_path, dpi=DPI_RASTER, bbox_inches="tight")
    plt.close(fig)


def write_cluster_overlay(
    mosaic: np.ndarray, labels: np.ndarray, coverage: np.ndarray, out_path: Path
) -> None:
    rgb = rgb_with_nodata_background(mosaic, coverage)
    cluster_masked = np.ma.masked_where(labels < 0, labels)

    cmap = ListedColormap(CLUSTER_COLORS)
    fig, ax = plt.subplots(figsize=(8, 8))
    ax.imshow(rgb)
    ax.imshow(cluster_masked, cmap=cmap, vmin=0, vmax=len(CLUSTER_COLORS) - 1, alpha=0.42)
    ax.set_axis_off()
    ax.set_title("SAE clusters over Geocloud mineral map mosaic")
    fig.tight_layout()
    fig.savefig(out_path, dpi=DPI_RASTER, bbox_inches="tight")
    plt.close(fig)


def write_validation_panel(
    mosaic: np.ndarray, labels: np.ndarray, coverage: np.ndarray, out_path: Path
) -> None:
    rgb = rgb_with_nodata_background(mosaic, coverage)
    cluster_masked = np.ma.masked_where(labels < 0, labels)

    cmap = ListedColormap(CLUSTER_COLORS)
    fig, axes = plt.subplots(1, 2, figsize=(12, 6), constrained_layout=True)
    axes[0].imshow(rgb)
    axes[0].set_title("(a) Geocloud hyperspectral mineral map")
    axes[0].set_axis_off()

    axes[1].imshow(rgb)
    axes[1].imshow(cluster_masked, cmap=cmap, vmin=0, vmax=len(CLUSTER_COLORS) - 1, alpha=0.42)
    axes[1].set_title("(b) SAE clusters over mineral map")
    axes[1].set_axis_off()

    fig.savefig(out_path, dpi=DPI_RASTER, bbox_inches="tight")
    plt.close(fig)


def main() -> None:
    apply_report_style()
    ref_meta = load_reference_meta()
    labels = load_labels_checked(ref_meta)
    mosaic = np.zeros((3, ref_meta["height"], ref_meta["width"]), dtype=np.uint8)
    coverage = np.zeros((ref_meta["height"], ref_meta["width"]), dtype=bool)
    total_pixels = coverage.size

    for sheet in SHEETS:
        path = find_sheet_file(sheet)
        print(f"Processing {sheet.code}: {path.name}", flush=True)
        rgb, valid_mask = crop_sheet_image(sheet, path)
        sheet_tif = write_sheet_geotiff(sheet, rgb)
        print(f"  Wrote georeferenced sheet: {sheet_tif}", flush=True)

        aligned, aligned_mask = reproject_to_reference(sheet, rgb, valid_mask, ref_meta)
        valid = aligned_mask
        valid_pixels = int(valid.sum())
        print(
            f"  valid pixels in AOI after reproject: {valid_pixels}/{total_pixels} "
            f"({valid_pixels / total_pixels:.2%})",
            flush=True,
        )
        fill = valid & (~coverage)
        overwrite = valid & coverage
        fill_pixels = int(fill.sum())
        overlap_pixels = int(overwrite.sum())
        print(
            f"  pixels newly written to mosaic: {fill_pixels}; "
            f"overlap with existing sheets: {overlap_pixels}",
            flush=True,
        )
        mosaic[:, fill] = aligned[:, fill]
        coverage |= valid

    out_tif = write_aligned_mosaic(mosaic, ref_meta)
    write_mineral_only(mosaic, coverage, OUT_DIR / "tuwu_yandong_mineral_map_aligned_20m.png")
    write_cluster_overlay(mosaic, labels, coverage, OUT_DIR / "sae_clusters_over_mineral_map.png")
    write_validation_panel(mosaic, labels, coverage, OUT_DIR / "mineral_map_validation_panel.png")

    write_mineral_only(mosaic, coverage, OUT_DIR / "debug_mineral_only.png")
    write_labels_only(labels, OUT_DIR / "debug_labels_only.png")
    write_coverage_debug(coverage, OUT_DIR / "debug_coverage.png")
    write_cluster_overlay(mosaic, labels, coverage, OUT_DIR / "debug_overlay.png")

    valid_pixels = int(coverage.sum())
    print(f"Aligned mosaic: {out_tif}", flush=True)
    print(f"Final coverage: {valid_pixels}/{total_pixels} pixels ({valid_pixels / total_pixels:.2%})")
    print(f"Outputs written to: {OUT_DIR}", flush=True)


if __name__ == "__main__":
    main()
