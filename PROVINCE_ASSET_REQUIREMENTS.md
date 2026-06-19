# Province Asset Requirements

All province visuals must be local to `YouNew/Assets.xcassets`, user-provided, generated, public-domain, or properly licensed for app use. Do not hotlink remote images.

Recommended province hero size: 1600x1000 PNG/JPG. Recommended map format: vector PDF or 1200px transparent PNG. Existing legacy province flag/map names remain supported where already present.

| Province | Asset name | Purpose | Recommended file type | License requirement | Fallback used |
|---|---|---|---|---|---|
| South Holland | `province_south_holland_hero` | Province hero image | PNG/JPG | local/user-provided/generated/public-domain/properly licensed | `GeneratedProvinceArtwork` |
| South Holland | `province_south_holland_flag` | Province flag badge | PDF/SVG/PNG | public-domain/properly licensed | Generated flag-style badge |
| South Holland | `province_south_holland_map` | Province mini-map graphic | PDF/transparent PNG | public-domain/properly licensed | `ProvinceMapMiniGraphic` |
| North Holland | `province_north_holland_hero` | Province hero image | PNG/JPG | local/user-provided/generated/public-domain/properly licensed | `GeneratedProvinceArtwork` |
| North Holland | `province_north_holland_flag` | Province flag badge | PDF/SVG/PNG | public-domain/properly licensed | Generated flag-style badge |
| North Holland | `province_north_holland_map` | Province mini-map graphic | PDF/transparent PNG | public-domain/properly licensed | `ProvinceMapMiniGraphic` |

## Existing Legacy Assets

The asset catalog currently includes province-style assets such as `zuid_holland_flag`, `noord_holland_flag`, `map_zuid_holland`, `map_noord_holland`, and `netherlands_map_base`. Keep these unless a deliberate migration maps them to the documented `province_*` names.

## Runtime Behavior

If the documented province image exists, the app displays the local asset. If it is absent, `GeneratedProvinceArtwork`, `ProvinceMapSilhouette`, or `ProvinceMapMiniGraphic` provides the visual fallback. Province screens must not show broken boxes or technical placeholder text.
