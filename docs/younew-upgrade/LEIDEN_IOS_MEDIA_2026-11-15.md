# Leiden: iOS media connection — 2026-11-15

## Scope and existing work

Checkout `/Users/ivan/YouNew`; base commit `3e1d421`, branch `feature/ios-leiden-place-media-20261115`.
This is an iOS follow-up to draft PR #62, not another copy of its content batch.
PR #62 already prepares five EN/NL revisions (Lakenhal, Naturalis, Hortus, RMO, Boerhaave), five licensed photographs in three sizes, five coordinate/address evidence entries and 19 checked official links. Its manifest remains `needs_review`, `publicationAuthorized: false`, no reviewer. None of those revisions or private photographs were activated in iOS or production.

The app already has PlaceItem detail/navigation, SavedItemsStore, Directions, category filters, an image loader with memory/disk caching and decoding downsampling, and a knowledge database that applies runtime migrations/withholding. These were reused.

## Actual changes and counts

- 3 existing cards connected to existing licensed venue photographs: Museum De Lakenhal, Naturalis Biodiversity Center, Burcht van Leiden. This is media enrichment, not three fully rewritten EN/NL records.
- 0 new catalog objects; 0 new approvals; 0 newly published records; 0 changed coordinates; 0 new ticket claims.
- 3 existing image endpoints checked again: HTTP 200, image/jpeg signatures. No photo files downloaded into the repository.
- Existing five detailed content revisions remain in PR #62 review, including their EN/NL descriptions, addresses, coordinates and ticket links. Their evidence was inspected and their five automated review tests rerun, not counted as new verification here.
- The ten existing Leiden seeds were inspected: Lakenhal, Hortus, Burcht, RMO, Naturalis, Boerhaave, Wereldmuseum, De Valk, SieboldHuis, Pieterskerk. No duplicate seeds were added.

## Why repeated maps appeared

Dashboard and detail built new AppImageAsset wrappers from raw PlaceItem.image strings, losing the existing rights metadata. Naturalis had no image there despite a licensed venue asset elsewhere. `.city` fallback rendered `netherlands_map_base`. The preview sheet also showed unrelated category photography.

The shared CanonicalPlaceImageResolver now maps three existing stable dashboard IDs to their existing knowledge graph IDs. Lookup goes through NetherlandsKnowledgeDatabase so migration/withholding continues to apply. Home carousel, preview and detail use the same asset. The remaining Leiden raw image URLs lack attached rights evidence in that catalog and intentionally show an accessible photo fallback until reviewed. Maps retain their map artwork.

Place detail exposes existing official Website and Share actions and visible credit/source/license links. Save and Directions continue using existing implementations. No second loader, database, dependency or authorization was added.

## Photo evidence (rechecked 2026-11-15)

| Place | Existing media ID | Source and author | License |
| --- | --- | --- | --- |
| De Lakenhal | media:leiden:lakenhal | [Lakenhal.jpg](https://commons.wikimedia.org/wiki/File:Lakenhal.jpg), PeteBobb | CC BY-SA 3.0 NL |
| Naturalis | media:leiden:naturalis-2019 | [Naturalis-Leiden-2019-3.jpg](https://commons.wikimedia.org/wiki/File:Naturalis-Leiden-2019-3.jpg), Hay Kranen | CC BY 4.0 |
| Burcht | media:leiden:burcht | [Burcht, Leiden.JPG](https://commons.wikimedia.org/wiki/File:Burcht,_Leiden.JPG), Effeietsanders | CC BY-SA 3.0 NL |

Existing registry retains source URL, author, license URL and retrieval date. Images are fitted/cropped for the existing card layout; no edited derivative is stored. Network availability is not proof of a rendered Simulator image.

## Web/iOS alignment

Recomputed from current generated artifacts: web 76, iOS 5, common 5, web-only 71, iOS-only 0. Live provenance fingerprint is `32fb2435ffb84b46b7d0c2e3c2371a217b1bb5280e8aa13cff9bc394f8812e17`; the live search response contains all 71 web-only IDs. Full ID list and HTTP evidence: `LEIDEN_IOS_MEDIA_EVIDENCE_2026-11-15.json`.

The 71 original compact EN/NL records have an existing hash-bound editorial approval; it is distinct from activation in the iOS runtime and excludes the pending new photo revisions. The iOS loader only accepts production artifacts and published/verified records. No manual JSON transplant or alternate catalog was introduced. This compares source bundles, not a shipped App Store binary.

## Validation

- `xcodebuild -project YouNew.xcodeproj -scheme YouNew -destination 'generic/platform=iOS Simulator' -derivedDataPath /tmp/younew-leiden-build CODE_SIGNING_ALLOWED=NO build-for-testing`: **TEST BUILD SUCCEEDED**, including new Swift Testing regressions for media identity, rights and review exclusion, arm64 and x86_64. Final incremental log has no warnings/errors.
- Initial sandboxed build failed in SwiftPM with sandbox_apply; rerun outside sandbox succeeded. No signing/project settings changed.
- `node --experimental-strip-types --test tests/place-review.test.ts` in public-site: **5 passed, 0 failed**.
- Swift unit execution attempted with scheme YouNewUnitTests on My Mac. Blocked by existing macOS-unavailable navigationBarTitleDisplayMode/topBarLeading in unchanged `YouNew/Views/PlacesDiscoveryView.swift:570,572`. An earlier attempt used the scheme name as a test target and was corrected. No Swift test pass is claimed.
- `simctl list devices available` outside sandbox: no available devices, iOS 26.5 runtime unavailable. Simulator launch, rendered images, Save→Saved, MapKit, Share sheet, EN/NL UI, small iPhone, light/dark themes and previews **not verified**.
- Xcode MCP was attached to another checkout. Explicit xcodebuild paths ensured compilation of `/Users/ivan/YouNew`.
- `git diff --check`: passed. Production, App Store, signing, entitlements and user data unchanged.

## Changed files

- `YouNew/Core/Imaging/AppContentImageView.swift`: honest place fallback.
- `YouNew/Data/CanonicalPlaceImageResolver.swift`: existing ID/media adapter.
- `YouNew/Views/HomeDashboardDiscoveryComponents.swift`: carousel resolver.
- `YouNew/Views/HomeExploreListView.swift`: exact-place preview media.
- `YouNew/Views/DashboardDiscoveryViews.swift`: same hero, credits, Website/Share.
- `YouNewTests/CityPlacesCalendarRegressionTests.swift`: two regression tests.
- This report and adjacent evidence JSON.

## Next gate and next batch

This is a reviewable, compiled media fix, not completed nationwide content expansion. Restore an iOS Simulator runtime and execute the existing unit/UI suite and the requested scenario before merging. Review the five prepared PR #62 content revisions, then deliver approved data through the existing governed exporter. Next Leiden batch: Burcht, Pieterskerk, De Valk, Wereldmuseum and SieboldHuis, with primary-source EN/NL and licensed imagery reviewed before activation. No events were invented or activated.
