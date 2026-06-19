# Image Replacement Report

Date: 2026-06-17

## Executive Decision

The visual system now treats every place image as intentional content, not decoration. City list thumbnails and province city cards no longer automatically reuse the city hero. All 29 visible province-directory cities have six separate roles: hero, landmark, culture, night, thumbnail, and card. Provinces have five separate roles: landscape, culture, nature, architecture, and tourism.

## Runtime Changes

- Added explicit visual role metadata in `CuratedPlaceHeroMediaRegistry`.
- Added `CityVisualRole` and `ProvinceVisualRole`.
- Added `CuratedPlaceVisualMedia` with title, reason, source URL, minimum width, and safe-area notes.
- Updated `CanonicalPlaceImageResolver.resolveCityThumbnail` to use the `thumbnail` role.
- Updated `CanonicalPlaceImageResolver.resolveProvinceCityCard` to use the `card` role.
- Kept city hero fallback only as an emergency path; every visible `ProvinceCatalog` city now has complete role coverage.
- Added stricter static QA so future province-directory cities fail unless hero, landmark, culture, night, thumbnail, and card imagery are all present and source-unique within the city.
- Expanded runtime `Attraction` data with tourism category, location, why-visit, best-season, and photo-purpose metadata.
- Added `TourismAttractionCatalog` so Top Attractions, Museums, Castles, Nature, Beaches, Parks, Historic Centres, UNESCO Sites, Hidden Gems, and Day Trips are represented in app data.
- Added a category-driven tourism section to `CultureAttractionsView`, so the tourism catalog is now visible in the app instead of only existing as data.
- Updated city attraction cards to show attraction-specific tourism metadata instead of treating images as anonymous thumbnails.
- Raised remaining 960px attraction/province/city references to 1200px+ card requests or 2400px hero requests.
- Replaced visible exact-source duplicates across city visual roles, province visual roles, runtime city attractions, and tourism catalog records.
- Added a no-visible-reuse regression test that normalizes Wikimedia thumbnail URLs to the underlying source file before checking duplicates.
- Added `scripts/visible-image-remote-qa.py`, a cache-aware visible-image validator that checks only rendered city/province/attraction/tourism URLs, uses byte-range requests, stops on rate limits, and separates transient network failures from true broken-image failures.
- Replaced a first high-confidence unresolved-title batch using exact Commons search hits: Amsterdam night canals, Marker Wadden beach, Noorderzon, Groningen salt marsh, Bourtange, Frisian lakes, Skutsjesilen, Van Gogh House Drenthe, Dwingelderveld, Drents Museum, and TT Circuit Assen.
- Added Commons metadata dimension and aspect-ratio enforcement so visible sources fail when hero/landscape files are below 2400px long-edge source size, card/thumbnail/attraction/tourism files are below 1200px long-edge source size, or source files are too panoramic/narrow for safe aspect-fill cropping.
- Replaced the final metadata-valid but undersized visible sources for Rotterdam, Den Haag, Leiden, Haarlem, Hoorn, Breda, Den Bosch, Zwolle, Lelystad, Leeuwarden, Zuid-Holland, Utrecht, Limburg, Flevoland, Groningen, Drenthe, and Anne Frank House.
- Extended runtime data QA to inspect visual metadata contracts: non-empty title and purpose, role-appropriate minimum pixel width, safe-area/crop-protection wording, no placeholder/stock/generic markers, and culture/night role relationship wording.
- Moved province visual role completeness, province cross-province uniqueness, tourism category coverage, tourism card metadata, and runtime attraction metadata into the Python release gate so they remain enforceable when Xcode/simulator verification is unavailable.
- Added `scripts/image-render-static-qa.py` to enforce the shared image rendering contract: aspect-fill image surfaces must clip inside stable frames, documentary fit surfaces must not crop, city/tourism cards must use display-aware target sizes, and tourism catalog cards must request 1200px imagery.
- Upgraded the default visual safe-area policy from a vague landmark-center note to explicit protection for full towers, bridges, windmill sails, castle facades, monuments, waterfront edges, and skylines. `scripts/image-runtime-data-qa.py` now fails if the legacy weak safe-area default returns.
- Extended visible-image QA to require Wikimedia-hosted visible photo sources and reject screenshot, logo, watermark, placeholder, stock, and guessed-image tokens on visible city, province, attraction, and tourism images.
- Extended runtime data QA to reject repeated subject titles and repeated asset identifiers inside the city visual system and province visual system, catching semantic duplicates even when source URLs differ.
- Added `scripts/visual-report-static-qa.py` so the five required output reports are checked for required sections, visual-role evidence, tourism category evidence, duplicate evidence, source-quality evidence, and the remaining device QA caveat.
- Added `scripts/generate-visual-audit-gallery.py` and `VISUAL_AUDIT_GALLERY.html` as a simulator-independent rendered review artifact. The gallery renders current city, province, and tourism visual records in aspect-fill audit frames with purpose and safe-area notes.
- Added the visual duplicate/source gate, runtime data gate, render gate, and report gate near the top of `scripts/run-static-qa.sh` so the visual asset system is checked by the normal static QA path before later non-visual gates run.
- Aligned Haarlem's verified fallback metadata and Swift test expectation with the upgraded `Zijlstrat Grote Markt Haarlem` source.

## Replacement Policy

- No generic Netherlands image is allowed as a city or province identity image.
- No Amsterdam imagery may represent another city.
- No windmill image may act as a generic city fallback.
- Culture surfaces use culture imagery, not city hero photos.
- History surfaces remain separate from tourism imagery.
- Landmark-safe crops must protect church towers, windmills, bridges, castles, and monuments.

## QA Result

- `python3 scripts/image-runtime-data-qa.py`: passed.
- `python3 scripts/place-media-static-qa.py`: passed.
- `python3 scripts/media-static-qa.py`: passed.
- `python3 scripts/image-render-static-qa.py`: passed.
- `python3 scripts/generate-visual-audit-gallery.py`: passed.
- `python3 scripts/visual-report-static-qa.py`: passed.
- `python3 scripts/visible-image-remote-qa.py --offline`: passed.
- `python3 scripts/visible-image-remote-qa.py --commons-metadata --enforce-dimensions --enforce-aspect-ratio --sleep 1.0 --timeout 20 --failure-report VISIBLE_IMAGE_REMOTE_FAILURES.md`: passed.
- `scripts/run-static-qa.sh`: visual gates pass inside the shared runner; the full runner currently stops later on an unrelated persona IA documentation gate.

The targeted iOS suite includes checks for city visual role uniqueness, province visual role uniqueness, runtime attraction metadata, tourism category coverage, unique tourism photo URLs, and minimum requested pixel sizes for hero and card imagery. It was attempted in this session with `xcodebuild test -scheme YouNew -destination 'platform=iOS Simulator,name=YouNew,OS=26.5' -only-testing:YouNewTests/PriorityCityHeroMediaTests -derivedDataPath .DerivedDataVisualSystemTests -jobs 1`, but the environment became resource constrained and the run was interrupted before a reliable test result.

Additional source audit:

- Province catalog city role sets checked: 29.
- Simulator-independent visual audit gallery generated: 257 rendered audit cards from current city/province/tourism visual records.
- Visual metadata contracts checked for city and province roles through `scripts/image-runtime-data-qa.py`.
- Visible image assignments checked across city roles, province roles, city attractions, and tourism catalog: 294.
- Exact normalized source-file duplicate groups across those visible surfaces: 0.
- `python3 scripts/visible-image-remote-qa.py --offline`: passed for parser coverage and duplicate-source detection.
- `python3 scripts/visible-image-remote-qa.py --commons-metadata --enforce-dimensions --enforce-aspect-ratio --sleep 1.0 --timeout 20 --failure-report VISIBLE_IMAGE_REMOTE_FAILURES.md`: checked 294 visible assignments, 294 unique URLs, and 294 Commons file titles with 0 duplicate source groups, 0 confirmed missing visible titles, 0 undersized visible source files, and 0 unsafe source aspect ratios.
- Remaining confirmed missing titles by surface in the current failure report: 0 city-role images, 0 province-role images, 0 runtime city-attraction images, and 0 tourism catalog images.
- Confirmed exact-title replacement work has now resolved every visible metadata failure while preserving 0 duplicate source groups.

## Risk Notes

Some remote Wikimedia file names are curated without downloading during static QA. The app already has remote fallback behavior; network rendering should still be checked on device before TestFlight approval.

The replacement validator is now safe to rerun as `python3 scripts/visible-image-remote-qa.py --commons-metadata --enforce-dimensions --enforce-aspect-ratio --sleep 1.0 --timeout 20 --failure-report VISIBLE_IMAGE_REMOTE_FAILURES.md`. Bulk direct image downloading remains separate from Commons metadata validation and should still be paced to avoid Wikimedia rate limits.

The Commons metadata check remains the required network-backed release guard for guessed `Special:FilePath` values and should be rerun before final App Store/TestFlight approval.

`VISIBLE_IMAGE_REMOTE_FAILURES.md` shows 0 unresolved visible URLs after the latest Commons metadata and dimension run.

Simulator screenshot QA is still pending because `simctl` is currently failing to connect to CoreSimulatorService after test execution.
