# raw_safe/

解压后的 Sentinel-2 L2A `.SAFE` 目录，预处理脚本 `preprocess_s2.py` 的输入。

## 数据来源

由 `raw_zip/` 中对应的 `.SAFE.zip` 解压得到。原始产品来自 Copernicus Data Space Ecosystem。

## 目录结构（预期）

```
S2A_MSIL2A_20240813T042701_N0511_R133_T46TFM_20240813T100054.SAFE/
└── GRANULE/
    └── L2A_T46TFM_.../
        └── IMG_DATA/
            ├── R10m/    # B08_10m.jp2
            ├── R20m/    # B02–B07, B8A, B11, B12, SCL (20m)
            └── R60m/    # 不使用
```

## 所需波段

| 波段 | 名称 | 分辨率 | 用途 |
|------|------|--------|------|
| B02 | Blue | 20 m | 可见光 |
| B03 | Green | 20 m | 可见光 |
| B04 | Red | 20 m | 可见光 / 铁染响应 |
| B05 | Red Edge 1 | 20 m | 红边 |
| B06 | Red Edge 2 | 20 m | 红边 |
| B07 | Red Edge 3 | 20 m | 红边 |
| B08 | NIR | 10 m | 近红外 |
| B8A | Narrow NIR | 20 m | 窄近红外 |
| B11 | SWIR 1 | 20 m | 蚀变敏感短波红外 |
| B12 | SWIR 2 | 20 m | 蚀变敏感短波红外 |
| SCL | Scene Classification | 20 m | 云/影/水/雪掩膜 |

## 说明

- 此目录不入 git（已在 `.gitignore` 中排除）
- 预处理后，提取的单波段 `.jp2` 存入 `raw_bands/`
- 详细预处理流程见 [README.md](../README.md)
