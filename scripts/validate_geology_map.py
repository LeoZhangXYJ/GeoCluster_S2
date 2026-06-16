"""Compare cluster labels with an external geological map.

The script accepts either:
1. a vector geological map plus a categorical attribute field, or
2. a georeferenced raster geological map.

It aligns the geology reference to the cluster GeoTIFF grid and writes
cross-tabulation tables plus optional ARI/NMI metrics.
"""
from __future__ import annotations

import argparse
import csv
from pathlib import Path
from typing import Iterable

import numpy as np
import rasterio
from rasterio.enums import Resampling
from rasterio.features import rasterize
from rasterio.warp import reproject, transform_geom

ROOT = Path(__file__).parent.parent.resolve()
DEFAULT_LABEL = ROOT / "results" / "cluster_sae" / "sae_kmeans_k6_z5.tif"
DEFAULT_OUT_DIR = ROOT / "results" / "geology_validation"

RASTER_EXTENSIONS = {".tif", ".tiff", ".img", ".vrt"}
VECTOR_EXTENSIONS = {".shp", ".geojson", ".json", ".gpkg", ".gdb"}
REFERENCE_NODATA = -9999


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Validate cluster labels against an external geological map."
    )
    parser.add_argument(
        "--label-raster",
        type=Path,
        default=DEFAULT_LABEL,
        help="Cluster-label GeoTIFF. Default: SAE z=5, k=6 result.",
    )
    parser.add_argument(
        "--geology",
        type=Path,
        required=True,
        help="Geological map path: SHP/GPKG/GeoJSON/GDB or GeoTIFF.",
    )
    parser.add_argument(
        "--attribute",
        help="Categorical geology-unit field for vector input, for example lithology or unit.",
    )
    parser.add_argument(
        "--out-dir",
        type=Path,
        default=DEFAULT_OUT_DIR,
        help="Output directory for validation tables and aligned reference raster.",
    )
    parser.add_argument(
        "--raster-nodata",
        type=float,
        default=None,
        help="Override nodata value for raster geology input.",
    )
    return parser.parse_args()


def detect_input_type(path: Path) -> str:
    suffix = path.suffix.lower()
    if suffix in RASTER_EXTENSIONS:
        return "raster"
    if suffix in VECTOR_EXTENSIONS or path.is_dir():
        return "vector"
    raise ValueError(f"Unsupported geology input type: {path}")


def read_label_grid(path: Path) -> tuple[np.ndarray, dict]:
    with rasterio.open(path) as src:
        labels = src.read(1)
        meta = {
            "crs": src.crs,
            "transform": src.transform,
            "height": src.height,
            "width": src.width,
            "profile": src.profile.copy(),
        }
    return labels, meta


def load_vector_shapes(
    path: Path,
    attribute: str,
    dst_crs,
) -> tuple[list[tuple[dict, int]], dict[int, str]]:
    try:
        import fiona
    except ImportError as exc:
        return load_vector_shapes_geopandas(path, attribute, dst_crs)

    shapes: list[tuple[dict, int]] = []
    value_to_code: dict[str, int] = {}
    code_to_value: dict[int, str] = {}

    with fiona.open(path) as src:
        if src.crs is None:
            raise ValueError("Vector geology input has no CRS; georeference it before validation.")
        if attribute not in src.schema["properties"]:
            fields = ", ".join(src.schema["properties"].keys())
            raise ValueError(f"Attribute '{attribute}' not found. Available fields: {fields}")

        for feature in src:
            geom = feature.get("geometry")
            if geom is None:
                continue
            raw_value = feature["properties"].get(attribute)
            if raw_value is None or raw_value == "":
                continue
            value = str(raw_value)
            if value not in value_to_code:
                code = len(value_to_code) + 1
                value_to_code[value] = code
                code_to_value[code] = value
            geom_t = transform_geom(src.crs, dst_crs, geom)
            shapes.append((geom_t, value_to_code[value]))

    if not shapes:
        raise ValueError("No valid vector geometries were found for the selected attribute.")
    return shapes, code_to_value


def load_vector_shapes_geopandas(
    path: Path,
    attribute: str,
    dst_crs,
) -> tuple[list[tuple[object, int]], dict[int, str]]:
    try:
        import geopandas as gpd
    except ImportError as exc:
        raise RuntimeError(
            "Vector input requires fiona or geopandas. Install one of them, "
            "or export the geology map to GeoTIFF first."
        ) from exc

    gdf = gpd.read_file(path)
    if gdf.crs is None:
        raise ValueError("Vector geology input has no CRS; georeference it before validation.")
    if attribute not in gdf.columns:
        fields = ", ".join(str(col) for col in gdf.columns if col != "geometry")
        raise ValueError(f"Attribute '{attribute}' not found. Available fields: {fields}")

    gdf = gdf.to_crs(dst_crs)
    shapes: list[tuple[object, int]] = []
    value_to_code: dict[str, int] = {}
    code_to_value: dict[int, str] = {}

    for _, row in gdf.iterrows():
        geom = row.geometry
        raw_value = row[attribute]
        if geom is None or geom.is_empty:
            continue
        if raw_value is None or str(raw_value) == "":
            continue
        value = str(raw_value)
        if value not in value_to_code:
            code = len(value_to_code) + 1
            value_to_code[value] = code
            code_to_value[code] = value
        shapes.append((geom, value_to_code[value]))

    if not shapes:
        raise ValueError("No valid vector geometries were found for the selected attribute.")
    return shapes, code_to_value


def rasterize_vector_reference(
    geology_path: Path,
    attribute: str,
    label_meta: dict,
) -> tuple[np.ndarray, dict[int, str]]:
    if not attribute:
        raise ValueError("Vector geology input requires --attribute.")

    shapes, code_to_value = load_vector_shapes(geology_path, attribute, label_meta["crs"])
    reference = rasterize(
        shapes,
        out_shape=(label_meta["height"], label_meta["width"]),
        transform=label_meta["transform"],
        fill=REFERENCE_NODATA,
        dtype="int32",
    )
    return reference, code_to_value


def align_raster_reference(
    geology_path: Path,
    label_meta: dict,
    nodata_override: float | None,
) -> tuple[np.ndarray, dict[int, str]]:
    reference = np.full(
        (label_meta["height"], label_meta["width"]),
        REFERENCE_NODATA,
        dtype=np.int32,
    )
    with rasterio.open(geology_path) as src:
        src_nodata = src.nodata if nodata_override is None else nodata_override
        reproject(
            source=rasterio.band(src, 1),
            destination=reference,
            src_transform=src.transform,
            src_crs=src.crs,
            src_nodata=src_nodata,
            dst_transform=label_meta["transform"],
            dst_crs=label_meta["crs"],
            dst_nodata=REFERENCE_NODATA,
            resampling=Resampling.nearest,
        )

    valid_values = sorted(int(v) for v in np.unique(reference) if int(v) != REFERENCE_NODATA)
    code_to_value = {v: str(v) for v in valid_values}
    return reference, code_to_value


def write_reference_raster(path: Path, reference: np.ndarray, label_meta: dict) -> None:
    profile = label_meta["profile"].copy()
    profile.update(count=1, dtype="int32", nodata=REFERENCE_NODATA, compress="lzw")
    with rasterio.open(path, "w", **profile) as dst:
        dst.write(reference, 1)


def write_mapping(path: Path, code_to_value: dict[int, str]) -> None:
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["geology_code", "geology_unit"])
        for code in sorted(code_to_value):
            writer.writerow([code, code_to_value[code]])


def pair_counts(clusters: np.ndarray, geology: np.ndarray) -> dict[tuple[int, int], int]:
    pairs = np.column_stack([clusters.astype(np.int32), geology.astype(np.int32)])
    unique_pairs, counts = np.unique(pairs, axis=0, return_counts=True)
    return {
        (int(pair[0]), int(pair[1])): int(count)
        for pair, count in zip(unique_pairs, counts)
    }


def write_crosstab(
    path: Path,
    counts: dict[tuple[int, int], int],
    code_to_value: dict[int, str],
) -> None:
    cluster_ids = sorted({cluster for cluster, _ in counts})
    geology_codes = sorted({code for _, code in counts})

    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        header = ["cluster_id"] + [
            f"{code}:{code_to_value.get(code, str(code))}" for code in geology_codes
        ] + ["cluster_total"]
        writer.writerow(header)
        for cluster_id in cluster_ids:
            row_counts = [counts.get((cluster_id, code), 0) for code in geology_codes]
            writer.writerow([cluster_id] + row_counts + [sum(row_counts)])


def write_majority_table(
    path: Path,
    counts: dict[tuple[int, int], int],
    code_to_value: dict[int, str],
) -> None:
    cluster_ids = sorted({cluster for cluster, _ in counts})
    geology_codes = sorted({code for _, code in counts})

    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(
            [
                "cluster_id",
                "cluster_total_pixels",
                "majority_geology_code",
                "majority_geology_unit",
                "majority_pixels",
                "majority_fraction",
            ]
        )
        for cluster_id in cluster_ids:
            code_counts = [(code, counts.get((cluster_id, code), 0)) for code in geology_codes]
            total = sum(count for _, count in code_counts)
            majority_code, majority_count = max(code_counts, key=lambda item: item[1])
            fraction = majority_count / total if total else 0.0
            writer.writerow(
                [
                    cluster_id,
                    total,
                    majority_code,
                    code_to_value.get(majority_code, str(majority_code)),
                    majority_count,
                    fraction,
                ]
            )


def compute_external_metrics(clusters: np.ndarray, geology: np.ndarray) -> dict[str, float | int | str]:
    metrics: dict[str, float | int | str] = {
        "valid_pixel_count": int(clusters.size),
        "cluster_class_count": int(np.unique(clusters).size),
        "geology_unit_count": int(np.unique(geology).size),
    }
    try:
        from sklearn.metrics import adjusted_rand_score, normalized_mutual_info_score
    except ImportError:
        metrics["adjusted_rand_index"] = "sklearn_not_available"
        metrics["normalized_mutual_information"] = "sklearn_not_available"
        return metrics

    metrics["adjusted_rand_index"] = float(adjusted_rand_score(geology, clusters))
    metrics["normalized_mutual_information"] = float(
        normalized_mutual_info_score(geology, clusters)
    )
    return metrics


def write_metrics(path: Path, metrics: dict[str, float | int | str]) -> None:
    with path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["metric", "value"])
        for key, value in metrics.items():
            writer.writerow([key, value])


def main() -> None:
    args = parse_args()
    args.out_dir.mkdir(parents=True, exist_ok=True)

    labels, label_meta = read_label_grid(args.label_raster)
    input_type = detect_input_type(args.geology)

    if input_type == "vector":
        reference, code_to_value = rasterize_vector_reference(
            args.geology, args.attribute, label_meta
        )
    else:
        reference, code_to_value = align_raster_reference(
            args.geology, label_meta, args.raster_nodata
        )

    valid = (labels >= 0) & (reference != REFERENCE_NODATA)
    clusters = labels[valid]
    geology = reference[valid]
    if clusters.size == 0:
        raise ValueError("No overlapping valid pixels between labels and geology reference.")

    counts = pair_counts(clusters, geology)
    metrics = compute_external_metrics(clusters, geology)

    write_reference_raster(args.out_dir / "aligned_geology_reference.tif", reference, label_meta)
    write_mapping(args.out_dir / "geology_code_mapping.csv", code_to_value)
    write_crosstab(args.out_dir / "cluster_geology_crosstab.csv", counts, code_to_value)
    write_majority_table(args.out_dir / "cluster_geology_majority.csv", counts, code_to_value)
    write_metrics(args.out_dir / "validation_metrics.csv", metrics)

    print(f"Input type: {input_type}")
    print(f"Valid overlap pixels: {clusters.size}")
    print(f"Geology units: {len(code_to_value)}")
    print(f"Outputs written to: {args.out_dir}")


if __name__ == "__main__":
    main()
