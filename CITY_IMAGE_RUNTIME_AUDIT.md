# City Image Runtime Audit

Date: 2026-06-10

Scope: Amsterdam, Rotterdam, Den Haag, Leiden, Utrecht, Groningen, Nijmegen, Arnhem, Eindhoven, Maastricht, Haarlem. Audited city detail hero sources, curated card/map hero registry, Den Haag Places data, city-specific map routing, and shared image fallback behavior.

## Summary

- Total cities audited: 11
- Incorrect city heroes found: 1
- City hero duplicates found after fix: 0
- Wrong Den Haag place landmarks found: fixed
- City-data mismatches found after fix: 0
- Blank image container risk after fix: mitigated by existing `CityImageView` fallback chain

## Fixes Applied

1. Haarlem hero image replaced.
   - Previous source: `Haarlem, Grote Kerk.jpg`, which produced a cloud/sky crop in runtime screenshots.
   - New source: `HaarlemGroteMarkt1.JPG`, a real Haarlem Grote Markt / St. Bavo historic-center image.
   - Files:
     - `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:20`
     - `YouNew/Data/VerifiedPlaceMediaRegistry.swift:103`
     - `YouNew/Data/NetherlandsData.swift:1105`

2. Haarlem Places tab images cleaned.
   - Removed old `Haarlem, Grote Kerk.jpg` from Haarlem attraction cards.
   - Added specific Haarlem-related sources for Frans Hals Museum, Teylers Museum, and Sint-Bavokerk / Grote Markt.
   - File: `YouNew/Data/NetherlandsData.swift:1113`

3. Den Haag Places section replaced with requested landmarks.
   - Current Den Haag Places now include Binnenhof, Peace Palace, Scheveningen Beach, and Mauritshuis.
   - No Den Haag attraction image URL contains `Kinderdijk` or `windmill`.
   - File: `YouNew/Data/NetherlandsData.swift:843`

4. Municipality routing verified.
   - City detail map action uses `.city(city.id)` and stores the same city-specific focus before navigation.
   - Den Haag city data contains `Gemeente Den Haag` and does not contain `Gemeente Leiden`.
   - File: `YouNew/Views/ProvinceDirectoryView.swift:824`

5. Regression tests added.
   - 11 audited city heroes must be non-empty, unique, and non-placeholder.
   - Haarlem must use `HaarlemGroteMarkt1.JPG`.
   - Den Haag must include requested places and must not include Leiden municipality data.
   - File: `YouNewTests/PriorityCityHeroMediaTests.swift:84`

## City Inventory

| City | Current image | Correct? | Duplicate? | Fix applied? |
|---|---|---:|---:|---:|
| Amsterdam | Canal houses and Oude Kerk at blue hour, Damrak | Yes | No | No |
| Rotterdam | Erasmus Bridge seen from Euromast | Yes | No | No |
| Den Haag | Peace Palace / `Friedenspalast_Den_Haag.jpg` | Yes | No | Yes, Places data fixed |
| Leiden | Oude Vest canal, Leiden | Yes | No | No |
| Utrecht | Dom Tower from Oudegracht | Yes | No | No |
| Groningen | Grote Markt and Martinitoren | Yes | No | No |
| Nijmegen | Valkhof / curated skyline source | Yes | No | No |
| Arnhem | John Frost Bridge / curated Musis Sacrum source | Yes | No | No |
| Eindhoven | Witte Dame, Eindhoven | Yes | No | No |
| Maastricht | Magisch Maastricht / Vrijthof context | Yes | No | No |
| Haarlem | Grote Markt / St. Bavo historic center | Yes | No | Yes |

## Den Haag Places

Required landmarks now present:

- Binnenhof
- Peace Palace
- Scheveningen Beach
- Mauritshuis

Removed from Den Haag Places runtime data:

- Kinderdijk windmills
- Generic windmill fallback imagery
- Leiden municipality references

## Layout And Fallback Check

No city image view should render an empty container:

- `CityImageView` tries the curated city URL first.
- If that fails, it tries the city data URL.
- If that fails, it appends province fallback URLs and then Netherlands premium fallback URLs.
- If all remote images fail, it renders `FallbackCityView` instead of a blank container.

City detail map routing was checked for oversized/generic routing state:

- City detail map button targets `AppDestination.mapFocus(.city(city.id))`.
- `appState.pendingMapFocus` is set to `.city(city.id)`.
- This prevents a Den Haag page action from inheriting the saved/default Leiden map state.

## Validation

Passed:

- `scripts/run-static-qa.sh`
- `scripts/place-media-static-qa.py`
- `scripts/content-static-qa.py`
- Swift parse check for changed Swift files
- Static duplicate scan for the 11 requested city heroes
- Static Den Haag block scan for `Gemeente Leiden`, `Kinderdijk`, and `windmill`

Blocked:

- Full simulator runtime UI replay. Xcode reported unavailable simulator runtimes and asset-catalog compilation stopped with `No available simulator runtimes for platform iphonesimulator`.

## Final Counts

- Total cities found: 11
- Total correct after fix: 11
- Total fixed: 2 city content areas
- Total missing: 0
- Total duplicates: 0
- Total wrong images after fix: 0
