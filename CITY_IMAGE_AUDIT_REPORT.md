# City Image Audit Report

Generated: 2026-06-10

## Scope

Audited every city surfaced through the current city catalog, province pages, city detail routing, city directory, map province previews, featured city sections, onboarding city references, search/bookmark destinations, and fallback image loaders.

Primary evidence and file references:

- Screenshot evidence: `<LOCAL_ARTIFACT>/city-image-audit-01.png`
- Screenshot evidence: `<LOCAL_ARTIFACT>/city-image-audit-02.png`
- Screenshot evidence: `<LOCAL_ARTIFACT>/city-image-audit-03.png`
- Screenshot evidence: `<LOCAL_ARTIFACT>/city-image-audit-04.png`
- City/province image registry: `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:14`
- City fallback loader: `YouNew/Components/ImageLoader.swift:216`
- Shared content fallback: `YouNew/Components/AppContentImageView.swift:21`
- Map province preview: `YouNew/Views/NetherlandsInteractiveMapView.swift:1118`
- City directory cards: `YouNew/Views/CitiesDirectoryView.swift:110`
- Emergency bundled fallback asset: `YouNew/Assets.xcassets/premium_netherlands_emergency_fallback.imageset/`

## Totals

| Metric | Count |
|---|---:|
| TOTAL CITIES FOUND | 29 |
| TOTAL CORRECT | 29 |
| TOTAL FIXED | 29 displayed city heroes, 1 compatibility city alias, 12 province fallbacks, 1 Netherlands fallback |
| TOTAL MISSING REMOTE CITY IMAGES | 0 |
| TOTAL MISSING LOCAL CITY HERO ASSETS | 29 |
| TOTAL DUPLICATE DISPLAYED CITY PHOTOS | 0 |
| TOTAL WRONG IMAGES | 0 after fixes |
| TOTAL CITY/PROVINCE IMAGE RECORDS METADATA-VERIFIED | 42/42 |

Metadata verification result: 42/42 curated city/province records were found through Wikimedia metadata, with 0 missing and 0 below the Retina threshold. The only duplicate registry URL is the intentional compatibility alias for `'s-Hertogenbosch` / `Den Bosch`; it is not a duplicate displayed city.

## City Inventory

| City | Current image | Valid / Invalid | Reason | Replacement needed |
|---|---|---|---|---|
| Amsterdam | Damrak canal houses and Oude Kerk reflection | Valid | City-specific canal hero that crops correctly in tall hero cards, 2400 px delivery | NO |
| Haarlem | Haarlem Grote Kerk / Sint-Bavo | Valid | City-specific historic-center hero, 2400 px delivery, replaces blank sky crop | NO |
| Alkmaar | Waagplein / Waag cheese market | Valid | City-specific landmark, 3024 x 2016 source | NO |
| Hoorn | Hoorn harbor at dawn | Valid | City-specific harbor scene, 4437 x 3326 source | NO |
| Zaanstad | Zaanse Schans | Valid | City-specific windmill landmark, 4032 x 3024 source | NO |
| Amstelveen | Laan van Deshima | Valid | City-specific center/civic scene, 3008 x 2000 source | NO |
| Purmerend | Koemarkt in summer | Valid | City-specific historic market, 4912 x 3264 source | NO |
| Heerhugowaard | Station Heerhugowaard 2024 | Valid | City-specific high-res local transport/civic scene, 4608 x 2074 source | NO |
| Rotterdam | Erasmus Bridge and skyline | Valid | Priority landmark match, 3060 x 3067 source | NO |
| Den Haag | Peace Palace | Valid | Priority landmark match, 19905 x 16191 source | NO |
| Leiden | Oude Vest canal | Valid | Priority canal/historic center match, 4632 x 3464 source | NO |
| Delft | View from Nieuwe Kerk | Valid | City-specific historic center, 4592 x 3154 source | NO |
| Utrecht | Dom Tower from Oudegracht | Valid | Priority landmark match, 4201 x 3008 source | NO |
| Amersfoort | Zuidsingel | Valid | City-specific historic canal/center, 2560 x 1920 source | NO |
| Arnhem | Musis Sacrum | Valid | City-specific landmark/city center, 3923 x 2350 source | NO |
| Nijmegen | Nijmegen skyline | Valid | City-specific skyline, 6016 x 4000 source | NO |
| Eindhoven | Witte Dame | Valid | Priority modern city/technology district match, 5312 x 2988 source | NO |
| Tilburg | De Heuvel | Valid | City-specific center, 4861 x 3241 source | NO |
| Breda | Breda historic center | Valid | City-specific historic center, 3008 x 2000 source | NO |
| 's-Hertogenbosch | St. Jans cathedral | Valid | City-specific landmark, 4000 x 3000 source | NO |
| Maastricht | Magisch Maastricht / Vrijthof area | Valid | Priority city landmark atmosphere, 2600 x 1909 source | NO |
| Venlo | Parade | Valid | City-specific center, 4320 x 3240 source | NO |
| Zwolle | Sassenstraat | Valid | City-specific historic center, 2048 x 1375 source | NO |
| Almere | Almere Stad center | Valid | City-specific modern center, 4896 x 3264 source | NO |
| Lelystad | Bataviawerf | Valid | City-specific waterfront/heritage landmark, 4162 x 3080 source | NO |
| Groningen | Grote Markt and Martinitoren | Valid | Priority landmark match, 4877 x 2851 source | NO |
| Leeuwarden | Nieuwestad | Valid | City-specific historic center/canal, 3648 x 2736 source | NO |
| Assen | Assen market | Valid | City-specific center, 2848 x 2134 source | NO |
| Middelburg | Middelburg Stadhuis | Valid | City-specific landmark, 2496 x 2996 source | NO |

## Problems Detected

- The supplied Drenthe and North Brabant screenshots showed a generic Amsterdam bicycle-street fallback instead of province/city imagery.
- The supplied Amsterdam detail screenshot showed an over-cropped facade close-up instead of a recognizable Amsterdam canal landmark.
- The supplied Haarlem detail screenshot showed an almost blank sky/cloud crop instead of Haarlem city imagery.
- Multiple guessed `Special:FilePath` URLs returned 404 for city and province heroes.
- The map province sheet used legacy `NLProvince` / `NLCity` images instead of the curated catalog.
- City directory cards were icon-only, so they failed the premium city-card requirement.
- City image downsampling targeted 900 px, too soft for Retina hero surfaces.
- The image fallback chain did not include a bundled emergency fallback.
- Map preview labels included hard-coded Russian strings in non-Russian UI states.
- Local offline city hero assets are still not bundled.

## Fixes Applied

- Replaced all displayed city hero sources with city-specific high-resolution photography.
- Replaced Amsterdam with a Damrak canal/Oude Kerk reflection hero that matches the city title and priority landmark requirements.
- Replaced Haarlem with a Grote Kerk/Sint-Bavo hero to remove the blank sky crop.
- Replaced the Binnenhof attraction montage with a direct Binnenhof photo.
- Replaced all province fallback sources with province-specific high-resolution landmarks or landscapes.
- Replaced the Netherlands fallback with a premium Kinderdijk fallback and added a bundled emergency fallback asset.
- Implemented city -> province -> Netherlands -> bundled fallback image flow.
- Moved map province previews and map city cards onto `ProvinceCatalog` and curated media.
- Converted city directory tiles and rows to image-backed cards with dark overlays and fixed dimensions.
- Increased city image decode target from 900 px to 1800 px.
- Verified 42/42 city/province records through Wikimedia metadata: 0 missing, 0 low-resolution.

## Remaining Release Gate

All 29 cities now have a valid city-specific image and functioning fallback. The remaining city-image release gate is bundling local `hero_*.imageset` assets for offline App Store-grade rendering; see `MISSING_CITY_ASSETS.md`.
