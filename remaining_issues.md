# Remaining issues

The application is **not ready to declare the refactor complete**.

## Critical

1. Canonical `younew://content/<id>` deep links are generated but not handled.
2. Guide does not use the canonical repository as its displayed catalogue.
3. Search does not display the canonical `searchContent()` result pipeline.

## High

4. Map does not consume `ContentRepository.mapItems()`; coordinate coverage is therefore a repository contract, not a UI guarantee.
5. Saved stores IDs correctly but cannot open every canonical item when a legacy destination is absent.
6. Canonical coverage unit tests did not execute because the iOS 26.5 test runner stalled after build.
7. SE, Pro Max, landscape, VoiceOver, offline and Dynamic Type remain without current runtime proof. Standard-iPhone root smoke checks and final-card/tab-bar clearance are now visually confirmed.
8. The real-link check produced 44 HTTP 404 responses and one HTTP 500 response. Each must be reviewed; some malformed Wikimedia URLs are clearly broken.

## Medium

9. 396 URLs returned HTTP 429 and 13 returned 403. These are not automatically broken, but remain unverified in this run.
10. Source-wide text audit still reports 9,333 exact-repeat issue rows and 2,278 cross-category occurrences; canonical runtime duplicate metrics were not emitted.
11. Error, loading and offline states are implemented inconsistently across legacy screens and were not exercised end-to-end.

## Release conditions

- Add one canonical destination and URL resolver.
- Drive Guide, Search, Map and Saved from `ContentRepository` projections.
- Export repository metrics and validation issues in a deterministic test artifact.
- Obtain passing root UI runs on SE, standard and Pro Max, including Accessibility XXXL.
- Recheck 404/500 links and distinguish intentional restricted endpoints from broken sources.
- Do not set `lost_content`, `orphaned_content` or `unsearchable_content` to zero until these checks pass at runtime.
# Remaining stabilization issues (2026-07-11)

1. UI test execution is blocked before XCTest launch by Xcode LLDB infrastructure (`no debugger version`). Test bundles compile successfully.
2. Scroll-end/tab-bar geometry is therefore NOT TESTED on all five roots.
3. iPhone SE, iPhone 17 Pro, and Pro Max runtime matrices are NOT TESTED.
4. Dutch and Accessibility XXXL screenshot files need re-capture/visual validation with a reliable wait-for-root mechanism.
5. VoiceOver focus order and system accessibility settings require manual audit.
6. Map collapsed/medium/expanded bottom-sheet geometry is NOT TESTED.
7. Existing compiler warning in `RootHomeView` about a main-actor-isolated hero registry call remains; it predates this patch.

Release verdict: NOT READY FOR FINAL ACCEPTANCE until items 1–6 have runtime evidence.
