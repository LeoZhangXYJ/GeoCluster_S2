# geology/

Place external geological-map data here for the final comparison validation.

## Target data

- Study area: Tuwu-Yandong porphyry copper district, Hami, Xinjiang.
- AOI: 94.30E-94.70E, 42.02N-42.32N.
- Preferred source: Geocloud / National Geological Archives of China.
- Preferred scale: 1:200,000 regional geological map or regional geological survey map.

## Search keywords

Use these in Geocloud, from specific to broad:

- `土屋 延东`
- `土屋`
- `延东`
- `哈密 1:20万 区域地质调查`
- `东天山 1:20万 地质图`
- `新疆 1:20万 区域地质图`
- `哈密幅`
- `觉罗塔格`
- `土屋铜矿`
- `东天山成矿带`

## Recommended files

Best to acceptable:

1. Vector geology units: SHP, GDB, GeoJSON.
2. Georeferenced raster: GeoTIFF.
3. Scanned JPG/PDF after QGIS georeferencing.

For vector data, keep the attribute table field that stores the geological unit
or lithology code. The validation script needs that field name through
`--attribute`.

## Validation command

Example for vector geology units:

```bash
python scripts/validate_geology_map.py --geology data/geology/tuwu_yandong_geology.shp --attribute lithology
```

Example for a georeferenced raster geology map:

```bash
python scripts/validate_geology_map.py --geology data/geology/tuwu_yandong_geology.tif
```

Outputs are written to `results/geology_validation/`.

