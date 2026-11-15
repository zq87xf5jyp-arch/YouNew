# Leiden: approved content in the existing iOS cards — 2026-11-15

## Delivered in the local app bundle

Seven existing places now use the same owner-approved EN/NL descriptions, addresses, official URLs and source dates as web: Museum De Lakenhal, Hortus Botanicus, Burcht van Leiden, Rijksmuseum van Oudheden, Naturalis, Rijksmuseum Boerhaave and Wereldmuseum Leiden. No new places, categories, reviews or events were invented. Existing Saved IDs remain unchanged; canonical web IDs also resolve to the same place detail.

- 7 descriptions EN/NL, 7 addresses, 7 official website links connected.
- 2 coordinates imported exactly from the approved release (Lakenhal and Hortus); not newly surveyed. The other 5 remain null. Directions opens Apple Maps with coordinates when available and the approved address otherwise. It does not manufacture a map marker or travel time.
- 0 new photographs imported. The 3 existing licensed venue photos (Lakenhal, Burcht, Naturalis) are now connected to the **active RootHomeView Places to Visit previews**, not just the older carousel. Existing source/license credits remain on place details. Pending photo revisions were not activated.
- Save and Share reuse existing storage and system actions. Tickets remain absent: the base approved export contains no dedicated approved ticket links.
- EN/NL summaries appear in the existing carousel, places list, preview and detail. Existing titles/categories and Saved identifiers remain compatible. Other languages fall back to approved English summaries.
- Detail hero and information cards use opaque theme-aware surfaces instead of dark translucent panels; the title follows Dynamic Type.

## Reuse and data governance

The existing `CanonicalPlaceCatalog`, `PlaceItem`, `DataProjectRuntimeLoader`, media resolver, image loaders, detail screen and Saved store remain in use. No database, SDK or service was added.

`node scripts/export-approved-ios-places.mjs` generates `YouNew/Resources/Data/younew-approved-places.json` from the **existing web release validator**, `loadEditorialRelease`. It verifies the original 71-record owner approval, staged-file hashes, reviewer scope, freshness and publication constraints before selecting seven existing records. This JSON is a derived bundle projection, not an independently editable catalog. The only added field is an explicit legacy iOS ID alias. `--check` verifies reproducibility. Private review environment variables are rejected; unapproved photographs and revised descriptions cannot enter this export.

The existing canonical city artifact and the web-generated artifacts remain unchanged. The Swift loader reuses its existing production/published/verified decoder for the editorial projection, and the catalog also observes canonical withheld IDs when selecting approved overlays. Updating original staging or approval requires the existing review process and regeneration; never hand-edit the generated bundle.

The compact descriptions were approved on 2026-11-10 from sources checked on 2026-11-09. Their dates were not falsely advanced by today's reachability checks. Richer revisions in PRs #62/#64 remain review-only.

## ID alignment

Recomputed from the local web export and iOS bundle inputs: web 76 canonical IDs; original iOS city artifact 5; selected editorial projection 7. Bundled canonical source coverage is now 12, leaving **64 web-only IDs**, previously 71. The seven records overlay existing seed cards rather than creating duplicate cards. This measures bundled source coverage, not shipped App Store data or complete search-index migration. The knowledge index still has legacy identities; a full index migration is outside this batch.

## Validation

- Final Xcode command, using `/Applications/Xcode.app/Contents/Developer`: `xcodebuild -project YouNew.xcodeproj -scheme YouNew -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/younew-leiden-build CODE_SIGNING_ALLOWED=NO build-for-testing` — **TEST BUILD SUCCEEDED**, arm64 and x86_64, including Swift Testing targets. Final log `/tmp/leiden-approved-ios-build-final.log` contains no warnings/errors. Signing configuration was not edited.
- Verified the generated JSON is present in `Debug-iphonesimulator/YouNew.app` and byte-identical to the source projection.
- `node --test scripts/tests/approved-ios-places.test.mjs`: **2 passed** (exact upstream projection and rejection of private review export).
- Existing editorial/review tests: **14 passed**, 0 failures, using `node --experimental-strip-types --test admin-dashboard/public-site/tests/editorial-release.test.ts admin-dashboard/public-site/tests/place-review.test.ts admin-dashboard/public-site/tests/leiden-nature-review.test.ts`.
- Added a Swift Testing regression for seven unique canonical aliases, preserved Saved IDs, distinct Dutch summaries, exactly two known coordinates and address-based Directions. Compiled; execution not claimed.
- Seven official URLs returned **HTTP 200** in direct GET checks. The web reading tool separately opened six; its RMO request returned 403, while the direct check succeeded. Full URLs and results are in the adjacent evidence JSON. A successful response is not an in-app interaction test.
- `simctl list runtimes` returned no runtimes; available devices list was empty, with historical iOS 26.5 unavailable. `test-without-building` was attempted for iPhone 16; no matching destination exists. Simulator launch, rendered photography, Save → Saved, MapKit, Share, small screens, EN/NL interaction, light/dark appearance and Preview remain **unverified**.
- Xcode integration was attached to a different checkout earlier in this session; explicit project paths ensured that `/Users/ivan/YouNew` was built.
- `git diff --check` passed. No production, App Store Connect, TestFlight, project signing, entitlements or user settings changes.

## Changed files

- `scripts/export-approved-ios-places.mjs` and `scripts/tests/approved-ios-places.test.mjs`: governed, reproducible bundle projection and checks.
- `YouNew/Resources/Data/younew-approved-places.json`: seven generated approved records.
- `YouNew/Services/DataProjectRuntimeLoader.swift`: reuse decoder for that bundled projection.
- `YouNew/Data/MockDashboardDiscoveryData.swift`: overlay approved content onto existing seeds and resolve canonical aliases.
- `YouNew/Models/DashboardDiscoveryModels.swift`: canonical identity, localized summary and safe Directions URL.
- `YouNew/Views/RootHomeView.swift`: correct active home photo sources for Leiden.
- `YouNew/Views/HomeDashboardDiscoveryComponents.swift`, `HomeExploreListView.swift`, `DashboardDiscoveryViews.swift`: localized summaries, detail contrast and routing action.
- `YouNewTests/CityPlacesCalendarRegressionTests.swift`: adapter regression coverage.
- This report and `LEIDEN_APPROVED_IOS_EVIDENCE_2026-11-15.json`.

## Remaining and next batch

Restore an iOS Simulator runtime and execute Launch → Places to Visit → Place → Save → Saved before merging. Four selected cards still have no approved photograph; five have no approved coordinates; dedicated ticket links and richer revisions remain in review. Next batch can apply the same validated projection to 5–10 approved Leiden food/stay entries after checking the relevant existing adapters. Nationwide expansion is not claimed.
