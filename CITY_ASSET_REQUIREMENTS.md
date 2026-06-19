# City, Province, and Category Asset Requirements

All visuals must be local assets in `YouNew/Assets.xcassets`, generated in-app SwiftUI artwork, user-provided, public-domain, or properly licensed for app use. Do not hotlink remote images.

## City Assets

Recommended hero size: 1600x1000 PNG/JPG. Recommended flag and coat-of-arms format: SVG/PDF/transparent PNG.

Create each city image as an Image Set in `YouNew/Assets.xcassets` with the stable names below. Raster assets should include `@1x`, `@2x`, and `@3x` variants before public release. Do not reference an image name from SwiftUI unless that image set exists in the asset catalog; the app falls back to `ImagePlaceholderView` when an asset is absent.

| City | Asset name | Purpose | License requirement |
|---|---|---|---|
| Amsterdam | `city_amsterdam_hero` | City hero image | local/user-provided/generated/public-domain/properly licensed |
| Amsterdam | `city_amsterdam_flag` | City flag badge | properly licensed/public-domain |
| Amsterdam | `city_amsterdam_coat_of_arms` | Coat of arms badge | properly licensed/public-domain |
| Amsterdam | `city_amsterdam_canals` | Landmark card | local/user-provided/generated/public-domain/properly licensed |
| Amsterdam | `city_amsterdam_station` | Landmark card | local/user-provided/generated/public-domain/properly licensed |
| Leiden | `city_leiden_hero` | City hero image | local/user-provided/generated/public-domain/properly licensed |
| Leiden | `city_leiden_flag` | City flag badge | properly licensed/public-domain |
| Leiden | `city_leiden_coat_of_arms` | Coat of arms badge | properly licensed/public-domain |
| Leiden | `city_leiden_university` | Landmark card | local/user-provided/generated/public-domain/properly licensed |
| Leiden | `city_leiden_canals` | Landmark card | local/user-provided/generated/public-domain/properly licensed |
| Rotterdam | `city_rotterdam_hero` | City hero image | local/user-provided/generated/public-domain/properly licensed |
| Rotterdam | `city_rotterdam_flag` | City flag badge | properly licensed/public-domain |
| Rotterdam | `city_rotterdam_coat_of_arms` | Coat of arms badge | properly licensed/public-domain |
| Rotterdam | `city_rotterdam_skyline` | Landmark card | local/user-provided/generated/public-domain/properly licensed |
| Den Haag | `city_den_haag_hero` | City hero image | local/user-provided/generated/public-domain/properly licensed |
| Den Haag | `city_den_haag_flag` | City flag badge | properly licensed/public-domain |
| Den Haag | `city_den_haag_coat_of_arms` | Coat of arms badge | properly licensed/public-domain |
| Utrecht | `city_utrecht_hero` | City hero image | local/user-provided/generated/public-domain/properly licensed |
| Utrecht | `city_utrecht_flag` | City flag badge | properly licensed/public-domain |
| Utrecht | `city_utrecht_coat_of_arms` | Coat of arms badge | properly licensed/public-domain |
| Eindhoven | `city_eindhoven_hero` | City hero image | local/user-provided/generated/public-domain/properly licensed |
| Eindhoven | `city_eindhoven_flag` | City flag badge | properly licensed/public-domain |
| Eindhoven | `city_eindhoven_coat_of_arms` | Coat of arms badge | properly licensed/public-domain |
| Groningen | `city_groningen_hero` | City hero image | local/user-provided/generated/public-domain/properly licensed |
| Groningen | `city_groningen_flag` | City flag badge | properly licensed/public-domain |
| Groningen | `city_groningen_coat_of_arms` | Coat of arms badge | properly licensed/public-domain |
| Maastricht | `city_maastricht_hero` | City hero image | local/user-provided/generated/public-domain/properly licensed |
| Maastricht | `city_maastricht_flag` | City flag badge | properly licensed/public-domain |
| Maastricht | `city_maastricht_coat_of_arms` | Coat of arms badge | properly licensed/public-domain |
| Tilburg | `city_tilburg_flag` | City flag badge and city identity card | user-provided/generated/public-domain/properly licensed |
| Breda | `city_breda_flag` | City flag badge and city identity card | user-provided/generated/public-domain/properly licensed |
| 's-Hertogenbosch | `city_s_hertogenbosch_flag` | City flag badge and city identity card | user-provided/generated/public-domain/properly licensed |
| Haarlem | `city_haarlem_flag` | City flag badge and city identity card | user-provided/generated/public-domain/properly licensed |
| Delft | `city_delft_flag` | City flag badge and city identity card | user-provided/generated/public-domain/properly licensed |
| Almere | `city_almere_flag` | City flag badge and city identity card | user-provided/generated/public-domain/properly licensed |
| Arnhem | `city_arnhem_flag` | City flag badge and city identity card | user-provided/generated/public-domain/properly licensed |
| Nijmegen | `city_nijmegen_flag` | City flag badge and city identity card | user-provided/generated/public-domain/properly licensed |

## Province Assets

Recommended hero size: 1600x1000 PNG/JPG. Recommended map size: vector PDF or 1200px transparent PNG.

| Province | Asset name | Purpose | License requirement |
|---|---|---|---|
| South Holland | `province_south_holland_hero` | Province hero image | local/user-provided/generated/public-domain/properly licensed |
| South Holland | `province_south_holland_flag` | Province flag | properly licensed/public-domain |
| South Holland | `province_south_holland_map` | Province map graphic | properly licensed/public-domain |
| North Holland | `province_north_holland_hero` | Province hero image | local/user-provided/generated/public-domain/properly licensed |
| North Holland | `province_north_holland_flag` | Province flag | properly licensed/public-domain |
| North Holland | `province_north_holland_map` | Province map graphic | properly licensed/public-domain |

Existing legacy province flags and map overlays such as `zuid_holland_flag`, `map_zuid_holland`, and `netherlands_map_base` remain supported.

## Category Assets

Recommended hero size: 1200x800 PNG/JPG or vector PDF.

| Category | Asset name | Purpose | License requirement |
|---|---|---|---|
| BSN & registration | `category_bsn_hero` | Category hero | local/user-provided/generated/public-domain/properly licensed |
| Housing | `category_housing_hero` | Category hero | local/user-provided/generated/public-domain/properly licensed |
| Work | `category_work_hero` | Category hero | local/user-provided/generated/public-domain/properly licensed |
| Healthcare | `category_healthcare_hero` | Category hero | local/user-provided/generated/public-domain/properly licensed |
| Transport | `category_transport_hero` | Category hero | local/user-provided/generated/public-domain/properly licensed |
| Fines & rules | `category_fines_hero` | Category hero | local/user-provided/generated/public-domain/properly licensed |
| Documents | `category_documents_hero` | Category hero | local/user-provided/generated/public-domain/properly licensed |
| AI Explain | `category_ai_hero` | Category hero | local/user-provided/generated/public-domain/properly licensed |
| LGBTQ+ support | `category_lgbtq_hero` | Category hero | local/user-provided/generated/public-domain/properly licensed |
| Official websites | `category_official_sources_hero` | Category hero | local/user-provided/generated/public-domain/properly licensed |

## Runtime Behavior

`AssetAvailability.exists(_:)` and `VisualAssetHelper.exists(_:)` select the real local asset when present. If an asset is missing, the UI shows generated SwiftUI artwork using `CityHeroVisual`, `CategoryHeroVisual`, `GeneratedCityArtwork`, `GeneratedProvinceArtwork`, `GeneratedCategoryArtwork`, `DutchFlagRibbon`, `AbstractCanalLines`, `MiniSkylineGraphic`, `ProvinceMapSilhouette`, `ProvinceMapMiniGraphic`, `LandmarkSymbolBadge`, `GlassImageBadge`, `GlassVisualBadge`, `LandmarkCard`, `PremiumSectionHeader`, `GlassMetricCard`, `OfficialSourceVisualCard`, and `VisualEmptyState`.

User-facing fallback text is localized:

| English | Dutch | Russian |
|---|---|---|
| Image will be added later | Afbeelding wordt later toegevoegd | Изображение будет добавлено позже |
| Image source | Beeldbron | Источник изображения |
| Visual preview | Visuele preview | Визуальный предпросмотр |
