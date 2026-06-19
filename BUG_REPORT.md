# Bug Report

Generated: 2026-06-10

## Audit Coverage

Covered by static routing review, source inspection, attached screenshot review, image metadata verification, syntax parsing of edited Swift files, and attempted Xcode build.

Screens and flows reviewed: Home, Search, Map, Saved/Bookmarks, AI Assistant, More/Settings, Onboarding references, City list, City pages, Province list, Province pages, map province previews, Government Services, Transport, Housing, Healthcare, Emergency Contacts, Tax Information, Document Guides, Official Sources, search results, and saved-item routing.

Runtime limitation: CoreSimulator is unavailable in this environment, so iPhone SE, iPhone 15 Pro Max, iPad, orientation, memory, freeze, and full tap-through testing must still be completed on a real simulator/device before release.

## Bugs

| Severity | Screen | Bug | Steps to reproduce | Root cause | Recommended fix | Fixed status |
|---|---|---|---|---|---|---|
| Critical | Map, Province pages | Drenthe and North Brabant could show an Amsterdam bicycle-street image. | Open Map, select Drenthe or North Brabant, inspect province/card imagery. | Broken province URLs fell through to an overly generic Netherlands fallback; map sheet also used legacy media. Evidence: supplied screenshots. | Replace broken URLs, use province-specific fallbacks, and move map sheet to curated media. | Fixed |
| Critical | City/province image surfaces | Image failures could degrade to non-premium or empty-looking containers. | Disable/fail a city URL and inspect city cards/details. | Single-source loading had no full city -> province -> Netherlands -> bundled chain. | Add ordered fallback chain and bundled emergency visual. | Fixed |
| High | Amsterdam city page | Amsterdam hero showed an over-cropped facade close-up instead of a recognizable Amsterdam landmark. | Open Map, open Amsterdam city detail, inspect the top hero image. Evidence: supplied 20:47 Amsterdam screenshot. | Legacy Amsterdam media URL/crop was still used by the verified city-detail media path. | Replace with a wide Damrak canal/Oude Kerk hero and align catalog plus verified media registry. | Fixed |
| High | Haarlem city page | Haarlem hero showed a mostly blank sky/cloud crop instead of Haarlem city imagery. | Open Map, open Haarlem city detail, inspect the top hero image. Evidence: supplied 20:47 Haarlem screenshot. | Legacy Haarlem hero photo cropped into sky in the tall hero frame. | Replace with a Haarlem Grote Kerk/Sint-Bavo city hero and align catalog plus verified media registry. | Fixed |
| High | Map province preview | Map modal used legacy `NLProvince` / `NLCity` images and could diverge from city detail pages. | Open Map, tap a province, compare image with province detail. | `ProvinceSelectionCard` read old data sources. | Use `ProvinceCatalog` and `CuratedPlaceHeroMediaRegistry`. | Fixed |
| High | City/province media | Several curated URLs returned 404. | Run metadata verification over curated registry. | Guessed `Special:FilePath` filenames did not match real Wikimedia file names. | Replace with exact upload URLs and verify dimensions. | Fixed |
| High | City directory | City cards were icon-only, not hero-image cards. | Open city directory and inspect key city tiles/all city rows. | `CitiesDirectoryView` used SF Symbols instead of city imagery. | Add fixed-size image cards with dark gradient overlays. | Fixed |
| High | Retina rendering | City images were downsampled to 900 px. | Inspect `CityImageView` loader target width. | Loader target was too small for hero use on modern iPhones/iPads. | Raise decode target to 1800 px and source images to 2000 px+. | Fixed |
| Medium | Map province preview | Province sheets could mix languages. | Use English/Dutch/Russian, open a map province sheet. | Hard-coded Russian labels and English-only legacy province descriptions. | Add language-aware labels and localized summary copy. | Fixed |
| Medium | Shared content images | Shared content image component could stop at generated fallback without trying known fallback URLs. | Fail primary content URL and inspect content card. | `AppContentImageView` did not accept ordered fallback URLs or bundled fallback. | Add fallback URL list and bundled local fallback. | Fixed |
| Medium | Offline/premium release | Local city hero assets are not bundled. | Inspect `Assets.xcassets` for `hero_*.imageset`. | City heroes are currently remote-first. | Add local 2400 x 1350 px+ assets listed in `MISSING_CITY_ASSETS.md`. | Documented, not fixed |
| High | Full runtime QA | Complete simulator audit could not run here. | Run `xcodebuild` or attempt simulator pass in this sandbox. | CoreSimulatorService unavailable; asset compiler reports no simulator runtimes. | Re-run full UI automation/manual pass on a working local Xcode simulator/device. | Blocked by environment |

## Verification Performed

- Curated image static audit: city/province records OK, 0 missing configured records, 0 low-resolution priority heroes.
- Syntax parse of edited Swift files: passed for `ImageLoader.swift`, `NetherlandsInteractiveMapView.swift`, `CitiesDirectoryView.swift`, and `CuratedPlaceHeroMediaRegistry.swift`.
- `xcodebuild -list -json`: succeeded and found `YouNew` scheme.
- Generic iOS build: blocked by missing signing profile for `com.company.younew`.
- Generic iOS no-sign build: progressed into build setup, then blocked by asset catalog compilation because CoreSimulator services are unavailable.

## Exact Fix References

- Image registry and fallback URLs: `YouNew/Data/CuratedPlaceHeroMediaRegistry.swift:14`
- City image fallback chain: `YouNew/Components/ImageLoader.swift:216`
- Bundled fallback visual: `YouNew/Components/ImageLoader.swift:276`
- Shared content fallback: `YouNew/Components/AppContentImageView.swift:21`
- Map preview media source: `YouNew/Views/NetherlandsInteractiveMapView.swift:1118`
- Map preview localized descriptions and labels: `YouNew/Views/NetherlandsInteractiveMapView.swift:1122`
- City directory hero cards: `YouNew/Views/CitiesDirectoryView.swift:110`
- Emergency fallback asset: `YouNew/Assets.xcassets/premium_netherlands_emergency_fallback.imageset/`
