# raw_zip/

原始下载的 Sentinel-2 L2A `.SAFE.zip` 压缩包，未解压。

## 数据来源

- **平台**：Copernicus Data Space Ecosystem（[Copernicus Browser](https://browser.dataspace.copernicus.eu/)）
- **传感器**：Sentinel-2 MSI，Level-2A（地表反射率产品）
- **研究区**：新疆哈密土屋—延东（94.30°E–94.70°E, 42.02°N–42.32°N）
- **Tile**：T46TFM

## 包含产品

| 文件名 | 大小 | 用途 |
|--------|------|------|
| `S2A_MSIL2A_20240813T042701_N0511_R133_T46TFM_20240813T100054.SAFE.zip` | ~1.1 GB | 主影像（2024-08-13） |
| `S2B_MSIL2A_20240818T042709_N0511_R133_T46TFM_20240818T074736.SAFE.zip` | ~1.1 GB | 备用影像（2024-08-18） |

## 说明

- 正式实验以 2024-08-13 Sentinel-2A 产品为准
- 此目录不入 git（已在 `.gitignore` 中排除）
- 复现实验时，从 Copernicus Browser 重新下载即可
- 详细下载步骤见项目根目录 [README.md](../README.md)
