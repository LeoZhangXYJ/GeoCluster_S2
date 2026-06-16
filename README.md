# Sentinel-2 Unsupervised Lithological Mapping for the Tuwu-Yandong Porphyry Copper District

本项目基于 Sentinel-2A L2A 多光谱影像，面向新疆哈密土屋-延东斑岩型铜矿区开展无监督岩性/蚀变聚类制图。实验主线迁移并扩展 Naagar et al. (2024) 的 autoencoder + K-means 遥感地质制图框架，比较 Raw K-means、PCA + K-means、Canonical AE + K-means、Stacked AE + K-means，并进一步加入 Geo-DEC 空间上下文增强方法。

项目同时补充了地质云 1:250,000 高光谱遥感矿物分布图的配准、拼接与辅助叠加验证，用于检查聚类图斑与白云母、绿泥石、碳酸盐、铁氧化物等矿物异常线索之间的空间关系。该矿物图仅作为定性空间一致性辅助材料，不作为传统岩性地质图或精度评价真值。

## Reference

> Naagar, S., Chawla, S., Bhattacharya, A., et al. _Remote sensing framework for geological mapping via stacked autoencoders and clustering._ Advances in Space Research, 2024, 74(10): 4502-4516.

- Paper: https://www.sciencedirect.com/science/article/pii/S0273117724009335
- Original code: https://github.com/sydney-machine-learning/autoencoders_remotesensing

## Data

- Satellite: Sentinel-2A MSI
- Product level: Level-2A, bottom-of-atmosphere reflectance
- Download platform: Copernicus Browser, https://browser.dataspace.copernicus.eu/
- Tile: T46TFM
- Main scene: `S2A_MSIL2A_20240813T042701_N0511_R133_T46TFM_20240813T100054.SAFE`
- AOI: 94.30E-94.70E, 42.02N-42.32N
- External auxiliary maps: Geocloud 1:250,000 Altun hyperspectral remote sensing mineral-distribution maps, mainly sheets `J46 C 002003` and `J46 C 002004`

Large raw data and generated results are intentionally ignored by Git. See `.gitignore` and the README files under `data/` and `results/`.

## Directory Structure

```text
Tuwu_Yandong_S2/
|-- README.md
|-- AI_USAGE.md
|-- scripts/
|   |-- preprocess_s2.py              # Sentinel-2 preprocessing
|   |-- cluster_kmeans_baseline.py    # Raw K-means + Elbow analysis
|   |-- pca_kmeans_baseline.py        # PCA + K-means baseline
|   |-- ae_kmeans_baseline.py         # Canonical AE + K-means
|   |-- sae_kmeans.py                 # Stacked AE + K-means
|   |-- geo_dec_clustering.py         # Geo-DEC spatial enhancement
|   |-- compute_all_metrics.py        # Unified metric computation
|   |-- analyze_cluster_spectra.py    # Cluster spectral response and band ratios
|   |-- make_final_figures.py         # Method comparison figures
|   |-- make_interpretation_map.py    # Automated interpretation map
|   |-- georeference_mineral_maps.py  # Geocloud mineral-map registration and overlay
|   `-- validate_geology_map.py       # Optional external geology-map validation
|-- data/
|   |-- raw_zip/       # Downloaded SAFE zip files, ignored
|   |-- raw_safe/      # Extracted SAFE products, ignored
|   |-- raw_bands/     # Extracted JP2 bands, ignored
|   |-- processed/     # Preprocessed 20 m stack, masks, previews, ignored
|   `-- geology/       # External geology/mineral map sources and notes
|-- results/
|   |-- cluster_baseline/
|   |-- cluster_pca/
|   |-- cluster_ae/
|   |-- cluster_sae/
|   |-- cluster_geo_dec/
|   |-- cluster_metrics/
|   |-- cluster_spectra/
|   |-- final_figures/
|   `-- geology_validation/
|-- report/
|   |-- template.typ
|   |-- document.typ       # Chinese report
|   |-- document_en.typ    # English report
|   |-- assets/
|   `-- zjulogo.svg
`-- slide/
    |-- ZJU_BeamerTemplate.tex
    |-- topic_proposal.tex
    |-- zju_beamer.sty
    |-- references.bib
    `-- figures/
```

## Reproduction Workflow

Run the main processing and clustering pipeline:

```bash
python scripts/preprocess_s2.py
python scripts/cluster_kmeans_baseline.py
python scripts/pca_kmeans_baseline.py
python scripts/ae_kmeans_baseline.py
python scripts/sae_kmeans.py
python scripts/geo_dec_clustering.py
python scripts/compute_all_metrics.py
python scripts/analyze_cluster_spectra.py
python scripts/make_final_figures.py
python scripts/make_interpretation_map.py
```

Generate the Geocloud mineral-map auxiliary validation panel:

```bash
python scripts/georeference_mineral_maps.py
```

Optional validation against a georeferenced external geology map:

```bash
python scripts/validate_geology_map.py --geology data/geology/tuwu_yandong_geology.tif
python scripts/validate_geology_map.py --geology data/geology/tuwu_yandong_geology.shp --attribute lithology
```

Compile the reports with Typst:

```bash
typst compile report/document.typ report/document.pdf
typst compile report/document_en.typ report/document_en.pdf
```

Compile the Beamer slides:

```bash
cd slide
make
```

## Methods

| Method | Feature space | Role |
|---|---|---|
| Raw K-means | Original 10 Sentinel-2 bands | No-dimensionality-reduction baseline |
| PCA + K-means | Linear low-dimensional features | Linear dimensionality-reduction baseline |
| Canonical AE + K-means | Shallow nonlinear latent features | Shallow autoencoder baseline |
| Stacked AE + K-means | Deep nonlinear latent features | Main migrated framework from Naagar et al. (2024) |
| Geo-DEC | Spectral bands + geological indices + 3-by-3 spatial context + DEC loss | Spatial-continuity enhancement extension |

Main evaluation metrics include Silhouette coefficient, Davies-Bouldin Index (DBI), Calinski-Harabasz Index (CHI), reconstruction MSE, local agreement ratio, isolated pixel ratio, class balance, spectral response curves, and selected band ratios.

## Important Notes

- The final remote sensing geological interpretation map is a spectral-spatial inference based on unsupervised clustering. It has not been calibrated by field samples and should not be treated as an official geological map.
- The Geocloud hyperspectral mineral maps are auxiliary remote-sensing mineral anomaly products. They can support qualitative spatial-consistency checks, but they are not lithological ground truth.
- Generated files under `results/` are ignored by default. If the report must compile directly from a fresh clone, add the required final figure explicitly, for example:

```bash
git add -f results/geology_validation/mineral_maps/mineral_map_validation_panel.png
```

- Do not commit `.codex_tmp/`; it is temporary workspace state.

## Template Acknowledgements

The report and slides are adapted from the following open-source templates:

- Typst report template: https://github.com/memset0/ZJU-Project-Report-Template
- ZJU Beamer template: https://github.com/qychen2001/ZJU-Beamer-Template
