# results/

聚类实验结果输出，由各实验脚本生成。

## 子目录说明

| 目录 | 对应脚本 | 内容 |
|------|----------|------|
| `cluster_baseline/` | `cluster_baseline.py` | 原始波段 K-Means + 肘部法则 |
| `cluster_pca/` | `cluster_pca.py` | PCA 降维 + K-Means |
| `cluster_ae/` | `cluster_ae.py` | 标准 Autoencoder 降维 + K-Means |
| `cluster_sae/` | `cluster_sae.py` | Sparse Autoencoder 降维 + K-Means |
| `cluster_spectra/` | `spectral_analysis.py` | 各类光谱剖面与波段比值分析 |
| `cluster_metrics/` | `cluster_metrics.py` | 聚类评估指标汇总 |
| `final_figures/` | `final_figures.py` | 论文用最终对比图 |

## 说明

- 所有 `.tif`、`.npz`、`.csv`、`.pt`、`.png`、`.pdf` 文件由实验脚本生成
- 此目录除 README 和 `.gitkeep` 外不入 git（已在 `.gitignore` 中排除）
- 复现实验时按顺序运行 `scripts/` 下的脚本即可重新生成全部结果
