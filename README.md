# Sentinel-2 SAE + K-means 遥感岩性聚类研究

基于 Sentinel-2A 多光谱影像与堆叠自编码器的无监督岩性/蚀变聚类分析，研究区为新疆哈密土屋-延东斑岩型铜矿区。

## 参考论文

> Naagar, S., Chawla, S., Bhattacharya, A., et al. *Remote sensing framework for geological mapping via stacked autoencoders and clustering.* Advances in Space Research, 2024, 74(10): 4502–4516.

- 论文链接：https://www.sciencedirect.com/science/article/pii/S0273117724009335
- 开源代码：https://github.com/sydney-machine-learning/autoencoders_remotesensing

## 数据来源

- **卫星**：Sentinel-2A, MSI 传感器
- **产品级别**：Level-2A（大气底层反射率）
- **下载平台**：[Copernicus Browser](https://browser.dataspace.copernicus.eu/)
- **Tile**：T46TFM
- **主影像**：`S2A_MSIL2A_20240813T042701_N0511_R133_T46TFM_20240813T100054.SAFE`
- **AOI**：94.30°E–94.70°E, 42.02°N–42.32°N

## 目录结构

```
Tuwu_Yandong_S2/
├── README.md
├── .gitignore
├── scripts/                  # 所有 Python 脚本
│   ├── preprocess_s2.py           # 数据预处理
│   ├── cluster_kmeans_baseline.py # Baseline K-means + Elbow
│   ├── pca_kmeans_baseline.py     # PCA + K-means
│   ├── ae_kmeans_baseline.py      # Canonical AE + K-means
│   ├── sae_kmeans.py              # Stacked AE + K-means
│   ├── compute_all_metrics.py     # 统一指标计算
│   ├── analyze_cluster_spectra.py # 聚类光谱响应分析
│   ├── make_final_figures.py      # 对比图生成
│   └── make_interpretation_map.py # Python 自动地质解释制图
├── data/
│   ├── raw_zip/     # 原始下载的 SAFE zip 文件
│   ├── raw_safe/    # 解压后的 SAFE 产品
│   ├── raw_bands/   # 提取并重命名的 JP2 波段
│   └── processed/   # 预处理后的 20 m 堆叠与掩膜
├── results/
│   ├── cluster_baseline/  # Raw K-means 结果
│   ├── cluster_pca/       # PCA + K-means 结果
│   ├── cluster_ae/        # Canonical AE + K-means 结果
│   ├── cluster_sae/       # Stacked AE + K-means 结果
│   ├── cluster_metrics/   # 统一聚类指标
│   ├── cluster_spectra/   # 光谱响应分析
│   └── final_figures/     # 最终对比图与解释图
└── report/
    ├── template.typ        # Typst 课程报告模板
    ├── document.typ        # 课程论文 Typst 源文件
    └── zjulogo.svg         # 校徽
```

## 运行顺序

```bash
python scripts/preprocess_s2.py
python scripts/cluster_kmeans_baseline.py
python scripts/pca_kmeans_baseline.py
python scripts/ae_kmeans_baseline.py
python scripts/sae_kmeans.py
python scripts/compute_all_metrics.py
python scripts/analyze_cluster_spectra.py
python scripts/make_final_figures.py
python scripts/make_interpretation_map.py
```

编译论文 PDF：
```bash
cd report && typst compile document.typ
```

## 方法概述

本项目对比了四种无监督聚类方法在 Sentinel-2 多光谱岩性识别中的效果：

| 方法 | 特征类型 | 用途 |
|---|---|---|
| Raw K-means | 原始 10 波段光谱 | 无降维基线 |
| PCA + K-means | 线性降维特征 | 线性基线 |
| Canonical AE + K-means | 浅层非线性隐特征 | 非线性浅层基线 |
| Stacked AE + K-means | 深层非线性隐特征 | 主体方法（参考原论文） |

评估指标：Silhouette 系数、Davies-Bouldin 指数（DBI）、Calinski-Harabasz 指数（CHI）、重建误差。

## 重要说明

- 最终输出的"遥感地质解释图"是基于无监督聚类结果的**光谱推断**，未经过野外验证，不应视为正式地质图。
- Canonical AE 在部分聚类指标上表现很强；SAE 在重建误差、簇紧凑性和原论文框架一致性方面更适合作为最终解释结果。因此本文采用 SAE z=5, k=6 作为主要地质解释图，同时保留 Canonical AE 作为强基线。

## 模板致谢

本项目报告和幻灯片分别基于以下开源模板修改：

- **Typst 课程报告模板**：[ZJU-Project-Report-Template](https://github.com/memset0/ZJU-Project-Report-Template)（`report/` 目录，已做一定修改）
- **LaTeX Beamer 幻灯片模板**：[ZJU-Beamer-Template](https://github.com/qychen2001/ZJU-Beamer-Template)（`slide/` 目录）
