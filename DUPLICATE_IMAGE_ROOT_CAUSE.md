# Duplicate Image Root Cause

Date: 2026-06-10

## Exact Repeated Windmill Sources Found

| Source | File reference | URL/asset | Intended use |
|---|---:|---|---|
| Netherlands premium remote fallback | `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:15` | `https://commons.wikimedia.org/wiki/Special:FilePath/Kinderdijk%20windmills.jpg?width=2400` | Last-resort country fallback. |
| South Holland curated province hero | `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:51` | `https://upload.wikimedia.org/wikipedia/commons/6/69/Kinderdijk_windmills.jpg` | Legitimate South Holland province hero. |
| South Holland legacy province field | `YouNew/Data/NetherlandsData.swift:294` | `https://upload.wikimedia.org/wikipedia/commons/thumb/f/f9/Kinderdijk_windmills.jpg/960px-Kinderdijk_windmills.jpg` | Legacy `NLProvince` field. |
| Culture content image | `YouNew/Data/ContentMediaRegistry.swift:242` | `https://upload.wikimedia.org/wikipedia/commons/2/2c/The_windmills_of_Kinderdijk.JPG` | Culture/water-management article image. |
| Side menu landmark image | `YouNew/Data/SideMenuLandmarkRegistry.swift:109` | `The_windmills_of_Kinderdijk.JPG` | Intentional landmark gallery item. |
| Bundled emergency fallback | `YouNew/Assets.xcassets/premium_netherlands_emergency_fallback.imageset/premium_netherlands_emergency_fallback.svg` | stylized water/city/windmill SVG | Local emergency fallback when remote media is unavailable. |

## Real Root Cause

The runtime issue was not one broken registry entry. It was a combination of three issues:

1. Multiple UI paths selected image URLs locally instead of asking one canonical resolver.
   - Map province modal hero and city cards had their own `province.media.heroImage` / `city.media.heroImage` priority.
   - Home, city detail, city places, city sidebar cards, city directory, and nearby map previews also had local selection logic.
   - This explains why a registry-only fix could look correct in reports while runtime UI still showed old or duplicate imagery.

2. The shared loader could cache a fallback image under the failed primary URL.
   - Before this pass, if URL A failed and fallback URL B loaded, the loader stored B under A's cache key.
   - Later visits to A could show B immediately from memory.
   - This made old duplicate fallback imagery survive even after data changes.
   - Fixed in `YouNew/Components/ImageLoader.swift:98` through `:130`: fallback candidates now cache under their own candidate URL, while the primary cache key is written only when the primary candidate succeeds.

3. Historical figure thumbnails reused `CityImageView`.
   - `CityImageView` is place-oriented and has place/bundled fallback behavior.
   - People thumbnails now use `resolveFigureThumbnail(figure:)` and `HistoricalFigurePortraitImage`, with portrait URLs first and symbolic category fallbacks only.
   - Fixed in `YouNew/Views/RootTabView.swift:1562` and `:1607`.

## Fixes Applied

| Area | Fix | File reference |
|---|---|---:|
| Canonical resolver | Added `CanonicalPlaceImageResolver` with city, province, figure, and place APIs. | `YouNew/Data/CanonicalPlaceImageResolver.swift:85` |
| Map province modal | Province hero and province city cards now use resolver output. | `YouNew/Views/NetherlandsInteractiveMapView.swift:1248`, `:1499` |
| Province detail | Province and city detail hero backgrounds now use resolver output. | `YouNew/Views/ProvinceDirectoryView.swift:293`, `:1646` |
| City detail and places | City hero and attraction cards now use resolver output. | `YouNew/Components/NetherlandsCityViews.swift:104`, `:260` |
| Home | Home hero, featured city, and backdrop asset now use resolver output. | `YouNew/Views/HomeView.swift:364`, `:829`, `:2050` |
| City directory | Tile and row thumbnails now use resolver output. | `YouNew/Views/CitiesDirectoryView.swift:110`, `:176` |
| Nearby map | City preview now uses resolver output. | `YouNew/Views/NearbyMapView.swift:405` |
| Figures | People thumbnails no longer use city/province image fallback. | `YouNew/Views/RootTabView.swift:1562`, `:1607` |
| Cache | Fallback image no longer poisons primary URL cache. | `YouNew/Components/ImageLoader.swift:98` |
| Arnhem | Curated hero changed to John Frost Bridge. | `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:33` |
| Nijmegen | Curated hero changed to Waalbrug. | `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:34` |
| Haarlem | Curated hero remains Grote Markt, not sky/cloud. | `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:20` |
| Utrecht province | Curated hero remains Dom Tower. | `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:52` |
| Drenthe province | Curated hero remains Hunebed D27. | `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:60` |
| Den Haag places | Static QA checks Binnenhof, Peace Palace, Scheveningen, Mauritshuis for non-windmill URLs. | `scripts/image-runtime-data-qa.py` |

## Why The Previous Fix Did Not Show Up At Runtime

The previous media-registry changes were valid for registry-backed paths, but some visible UI was not consistently registry-backed. In addition, `ImageLoader` could preserve a fallback image under an unrelated original URL. A runtime session that had already loaded a fallback could continue displaying that fallback from memory, making the UI appear stale.

## Current Status

- Static duplicate checks now pass.
- Figure thumbnails cannot use place/province fallback URLs in static QA.
- Den Haag place images are checked against windmill URLs.
- Haarlem sky/cloud regression is checked.
- Utrecht and Drenthe province heroes are checked against generic windmill fallback patterns.
- Runtime screenshot verification is still required on a simulator or device because CoreSimulator is unavailable in this environment.
