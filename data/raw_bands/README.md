# raw_bands/

从 `raw_safe/` 中提取并重命名的单波段 `.jp2` 文件，`preprocess_s2.py` 的中间输入。

## 数据来源

从 Sentinel-2 L2A SAFE 产品中提取，原始数据来自 Copernicus Data Space Ecosystem。

## 包含文件

```
B02_20m.jp2   B05_20m.jp2   B08_10m.jp2   B11_20m.jp2
B03_20m.jp2   B06_20m.jp2   B8A_20m.jp2   B12_20m.jp2
B04_20m.jp2   B07_20m.jp2                 SCL_20m.jp2
```

## 说明

- 由 `preprocess_s2.py` 从 `raw_safe/` 自动提取
- 所有波段在后续步骤中统一重采样至 20 m，并裁剪至 AOI 范围
- 此目录不入 git（已在 `.gitignore` 中排除）
- 预处理后的最终输出存入 `processed/`
