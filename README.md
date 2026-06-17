# Sentinel-2 土屋-延东斑岩铜矿区无监督岩性填图

本项目基于 Sentinel-2A L2A 多光谱影像，面向新疆哈密土屋-延东斑岩型铜矿区开展无监督岩性/蚀变聚类制图。研究主线迁移并扩展 Naagar et al. (2024) 的 autoencoder + K-means 遥感地质制图框架，系统比较 Raw K-means、PCA + K-means、Canonical AE + K-means、Stacked AE + K-means，并进一步提出 Geo-DEC 空间上下文增强方法。

项目还新增了地质云 1:250,000 高光谱遥感矿物分布图的配准、拼接与辅助叠加验证流程，用于检查聚类图斑与白云母、绿泥石、碳酸盐、铁氧化物等矿物异常线索之间的空间关系。需要注意的是，该矿物图仅作为定性空间一致性辅助材料，不作为传统岩性地质图或精度评价真值。

## 项目流程
- 2026.5.30 完成Baseline搭建
- 2026.6.11 新增GEO-DEC方法
- 2026.6.16 寻找相关地区地质图(地址云上找不到区域地质图-需要权限)，用地质云高光谱矿物图替代

## 参考论文

> Naagar, S., Chawla, S., Bhattacharya, A., et al. _Remote sensing framework for geological mapping via stacked autoencoders and clustering._ Advances in Space Research, 2024, 74(10): 4502-4516.

- 论文链接：https://www.sciencedirect.com/science/article/pii/S0273117724009335
- 原论文开源代码：https://github.com/sydney-machine-learning/autoencoders_remotesensing

## 数据来源

- 卫星与传感器：Sentinel-2A MSI
- 产品级别：Level-2A，大气底层反射率
- 下载平台：Copernicus Browser，https://browser.dataspace.copernicus.eu/
- Tile：`T46TFM`
- 主影像：`S2A_MSIL2A_20240813T042701_N0511_R133_T46TFM_20240813T100054.SAFE`
- 研究区范围：94.30E-94.70E，42.02N-42.32N
- 外部辅助图件：地质云 1:250,000 阿尔金高光谱遥感矿物分布图，研究区主要由 `J46 C 002003` 和 `J46 C 002004` 两幅图覆盖

大型原始数据和实验生成结果默认不纳入 Git 管理，具体见 `.gitignore` 以及 `data/`、`results/` 下的 README。

## 目录结构

```text
Tuwu_Yandong_S2/
|-- README.md
|-- AI_USAGE.md
|-- scripts/
|   |-- preprocess_s2.py              # Sentinel-2 数据预处理
|   |-- cluster_kmeans_baseline.py    # Raw K-means + Elbow 分析
|   |-- pca_kmeans_baseline.py        # PCA + K-means 基线
|   |-- ae_kmeans_baseline.py         # Canonical AE + K-means
|   |-- sae_kmeans.py                 # Stacked AE + K-means
|   |-- geo_dec_clustering.py         # Geo-DEC 空间增强聚类
|   |-- compute_all_metrics.py        # 统一指标计算
|   |-- analyze_cluster_spectra.py    # 聚类光谱响应与波段比值分析
|   |-- make_final_figures.py         # 方法对比图生成
|   |-- make_interpretation_map.py    # 自动遥感地质解释图生成
|   |-- georeference_mineral_maps.py  # 地质云矿物图配准、拼接与叠加验证
|   `-- validate_geology_map.py       # 可选：外部地质图一致性验证
|-- data/
|   |-- raw_zip/       # 原始 SAFE zip 文件，默认忽略
|   |-- raw_safe/      # 解压后的 SAFE 产品，默认忽略
|   |-- raw_bands/     # 提取后的 JP2 波段，默认忽略
|   |-- processed/     # 预处理后的 20 m 数据栈、掩膜和预览图，默认忽略
|   `-- geology/       # 外部地质/矿物图源数据与说明
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
|   |-- document.typ       # 中文论文
|   |-- document_en.typ    # 英文论文
|   |-- assets/
|   `-- zjulogo.svg
`-- slide/
    |-- ZJU_BeamerTemplate.tex
    |-- topic_proposal.tex
    |-- zju_beamer.sty
    |-- references.bib
    `-- figures/
```

## 复现实验流程

运行主流程：

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

生成地质云矿物图辅助验证面板：

```bash
python scripts/georeference_mineral_maps.py
```

如有已配准的外部地质图，可选择运行一致性验证：

```bash
python scripts/validate_geology_map.py --geology data/geology/tuwu_yandong_geology.tif
python scripts/validate_geology_map.py --geology data/geology/tuwu_yandong_geology.shp --attribute lithology
```

编译 Typst 论文：

```bash
typst compile report/document.typ report/document.pdf
typst compile report/document_en.typ report/document_en.pdf
```

编译 Beamer 幻灯片：

```bash
cd slide
make
```

## 方法概览

| 方法 | 特征空间 | 作用 |
|---|---|---|
| Raw K-means | 原始 10 个 Sentinel-2 波段 | 无降维基线 |
| PCA + K-means | 线性低维特征 | 线性降维基线 |
| Canonical AE + K-means | 浅层非线性隐空间特征 | 浅层自编码器基线 |
| Stacked AE + K-means | 深层非线性隐空间特征 | 迁移 Naagar et al. (2024) 的主线框架 |
| Geo-DEC | 光谱波段 + 地质指数 + 3×3 空间上下文 + DEC 损失 | 面向制图连续性的空间增强扩展 |

主要评价指标包括 Silhouette 系数、Davies-Bouldin 指数（DBI）、Calinski-Harabasz 指数（CHI）、重建 MSE、local agreement ratio、isolated pixel ratio、类别均衡性、光谱响应曲线和关键波段比值。

## 重要说明

- 最终遥感地质解释图是基于无监督聚类结果的光谱-空间推断，尚未经过野外样点标定，不能视为正式地质图。
- 地质云高光谱矿物图属于遥感矿物异常图，可用于定性空间一致性检查，但不是岩性真值。
- `results/` 下的生成文件默认被 `.gitignore` 忽略。如果论文需要在新克隆仓库中直接编译，需要强制加入必要的最终图件，例如：

```bash
git add -f results/geology_validation/mineral_maps/mineral_map_validation_panel.png
```


## 模板致谢

本项目报告和幻灯片分别基于以下开源模板修改：

- Typst 课程报告模板：https://github.com/memset0/ZJU-Project-Report-Template
- 浙江大学 Beamer 模板：https://github.com/qychen2001/ZJU-Beamer-Template
