# processed/

预处理后的数据，由 `scripts/preprocess_s2.py` 生成，是后续所有聚类实验的输入。

## 数据来源

从 `raw_bands/` 中读取单波段 `.jp2` 文件，经重采样（统一至 20 m）、波段堆叠、AOI 裁剪、云/影掩膜后输出。

## 包含文件

| 文件名 | 类型 | 大小 | 说明 |
|--------|------|------|------|
| `s2_tuwu_yandong_20240813_stack_20m_masked.tif` | GeoTIFF | ~100 MB | 13 波段堆叠影像（B02–B12, B8A, SCL） |
| `s2_tuwu_yandong_20240813_valid_mask.tif` | GeoTIFF | ~3 MB | 有效像素掩膜（排除云/影/水/雪） |
| `s2_tuwu_yandong_20240813_valid_pixels.npz` | NPZ | ~31 MB | 有效像素光谱矩阵 (N×13) |
| `preview_true_color_B04_B03_B02.png` | PNG | ~1 MB | 真彩色预览 |
| `preview_geology_B12_B8A_B02.png` | PNG | ~1 MB | 地质假彩色预览（SWIR-NIR-Blue） |

## 说明

- 由 `preprocess_s2.py` 从 `raw_bands/` 自动生成
- 正式实验以 2024-08-13 Sentinel-2A 产品为准
- 此目录除 README 外不入 git（已在 `.gitignore` 中排除）
- 复现实验时运行 `python scripts/preprocess_s2.py` 即可重新生成
