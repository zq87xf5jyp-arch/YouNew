# Stage 2 — test remediation ledger

Date: 2026-07-20 (Europe/Amsterdam)
Branch: `build-week-readiness`
Baseline commit: `b15a2f2913911763c989f9880f8ce376f903fc6e`

This ledger classifies every failure from the frozen `BuildWeekAudit` baseline. No test was skipped or disabled, no assertion was removed, and no delay was added. Expected values were changed only where a current independent product contract demonstrated that the recorded expectation was stale.

## Unit tests

### 1. `KnowledgeDataGovernanceTests/partnerVerificationRequiresRealWebsiteAndStatus()`

- Cause: the ten approved DataProject `local_partner` records had HTTPS sources but no explicit `plan`, `verified`, or `sponsored` attributes. The importer and schema allowed that governance metadata to disappear.
- Classification: product data-governance bug.
- Fix: require the three attributes for `local_partner`; support the schema condition in the repository validator; add honest values (`Free Listing`, `false`, `false`) and human-readable subcategories to all ten records; regenerate the runtime payload.
- Files: `DataProject/schema/entity.schema.json`, `DataProject/batches/WP-06/M2-amsterdam-001.json`, `scripts/import-data-project.py`, `YouNew/Resources/Data/younew-runtime-data.json`.
- Why correct: the product now distinguishes an editorial listing from a verified or sponsored relationship. It does not fabricate verification or commercial status, and future imports fail when the metadata is absent.
- Rerun: PASS in the focused rerun and in the complete unit suite.

### 2. `KnowledgeIndexTests/netherlandsKnowledgeDatabaseProvidesUnifiedDataPlatform()`

- Cause: ten Amsterdam partner records existed both in the legacy in-app registry and the approved DataProject release. Missing migration mappings made the unified database publish both representations (49 instead of the canonical 39 at baseline).
- Classification: product data-migration bug.
- Fix: add ten exact legacy-to-canonical mappings, deduplicate through the existing migration registry, and retain display subcategories when DataProject entities are projected into `KnowledgeItem`.
- Files: `DataProject/observability/migration-registry.json`, `YouNew/Data/NetherlandsData.swift`, `DataProject/schema/entity.schema.json`, `DataProject/batches/WP-06/M2-amsterdam-001.json`, `YouNew/Resources/Data/younew-runtime-data.json`.
- Why correct: the records remain available once under their canonical IDs; no partner functionality or record was deleted. Display categories remain meaningful instead of becoming the generic entity kind.
- Rerun: PASS in the focused rerun and in the complete unit suite.

### 3. `KnowledgeIndexTests/allGuideArticlesCitiesAndProvincesAreIndexedForAI()`

- Cause: the test required every housing, transport, healthcare, and work article to serialize as the old broad `.guideSection` route. The current navigation contract uses typed category destinations, already covered independently by `TypedCategoryRouteSerializationTests`.
- Classification: stale test baseline.
- Fix: validate each article against `KnowledgeIndexBuilder.guideSectionDestination(for:)`, then assert both the indexed route and its resolver round trip.
- Files: `YouNewTests/KnowledgeIndexTests.swift`.
- Why correct: the assertion is stronger about the actual typed routing contract and does not change product code or merely substitute a convenient expected literal.
- Rerun: PASS together with the independent typed-route test and in the complete unit suite.

### 4. `KnowledgeIndexTests/localPartnersAreIndexedForEverySupportedCityAndCoreCategory()`

- Cause: the supported-city inventory had no honest local listing for Arnhem, Delft, Haarlem, or Nijmegen.
- Classification: product content-coverage bug.
- Fix: add one `.freeListing` educational institution per missing city, with HTTPS institutional source, address/contact metadata, conservative availability status, and copy that explicitly says the entry is not a commercial partnership.
- Files: `YouNew/Data/MockLocalPartnersData.swift`.
- Why correct: all four entries identify real institutions and remain explicitly unverified/unsponsored editorial listings; the fix does not invent ratings, sponsorship, or live opening status.
- Rerun: PASS in the focused rerun and in the complete unit suite.

### Unit result

The full `YouNewUnitTests` rerun completed with **450/450 passed, 0 failed, 0 skipped, 0 expected failures** on iPhone 17 Pro / iOS 26.5. The result bundle is stored outside the repository at `<TEMP_DIR>/FullUnitAfterFix.xcresult`.

## Static QA

### 1. `python3 scripts/static-qa.py`

- Cause: this aggregate invokes `brand-static-qa.py`; the brand matcher required the exact spelling `TimelineView(.animation)` while the shared ambient layer correctly used `TimelineView(.animation(minimumInterval: 1 / 15))` and respected Reduce Motion.
- Classification: stale static matcher.
- Fix: match the `TimelineView(.animation` call prefix while retaining the prohibition against per-card timeline loops.
- Files: `scripts/brand-static-qa.py`.
- Why correct: the guard still proves app-wide ambient motion exists and card contours stay static; it now accepts the framework's configured animation cadence.
- Rerun: PASS individually and in `scripts/run-static-qa.sh`.

### 2. `python3 scripts/brand-static-qa.py`

- Cause, classification, fix, files, and rationale: same root issue as static gate 1; it is listed separately because it was a separate failing command in the 40-command ledger.
- Rerun: PASS individually and in the aggregate.

### 3. `python3 scripts/apple-review-static-qa.py`

- Cause: the gate searched for old tab/menu conditional text although the current root-layout contract deliberately keeps the contextual launcher disabled while no overlay space is reserved. Dedicated unit coverage independently verifies the launcher visibility function.
- Classification: stale static matcher.
- Fix: check the current function body for an explicit `false` return rather than requiring obsolete conditional syntax.
- Files: `scripts/apple-review-static-qa.py`.
- Why correct: the guard still prevents an unreserved global overlay from becoming visible and does not enable, hide, or remove user functionality.
- Rerun: PASS individually and in the aggregate.

### 4. `python3 scripts/persona-ia-static-qa.py`

- Cause: one direct-result filter check depended on an exact closure spelling, while guide/institution checks encoded a filter-out policy that conflicts with the product's current `rank-not-restrict` policy for general content. Route visibility still requires scoped lookups.
- Classification: stale/brittle static matcher with a real lookup-hardening gap.
- Fix: make the direct-result matcher syntax-tolerant; require guide and institution lookups to pass active persona and access scope; add those scoped lookup calls in the destination view.
- Files: `scripts/persona-ia-static-qa.py`, `YouNew/App/Navigation/AppDestinationView.swift`.
- Why correct: the app preserves general content visibility while preventing an out-of-scope lookup from bypassing the central persona policy.
- Rerun: PASS individually and in the aggregate.

### 5. `python3 scripts/content-static-qa.py`

- Cause: the gate inspected inactive legacy `HomeView`, while the active `RootHomeView` Transport card opened a shallow overview rather than the canonical completed practical guide.
- Classification: mixed stale static target and product routing bug.
- Fix: inspect `RootHomeView.swift`; route the primary Transport card to `.practicalGuide(.transportBasics)` while keeping its typed feature links.
- Files: `scripts/content-static-qa.py`, `YouNew/Views/RootHomeView.swift`.
- Why correct: the user-facing card now opens the completed Transport surface that the rest of navigation already treats as canonical.
- Rerun: PASS individually and in the aggregate.

### Static result

`scripts/run-static-qa.sh` completed with **40/40 commands passed**. DataProject import validation also passed after regenerating the runtime payload. Generated reports and `VISUAL_AUDIT_GALLERY.html` are build artifacts, not source evidence to stage blindly.

### Post-integration static regression

After the bounded Build Week backend client replaced the former generic retrieval
payload, `persona-ia-static-qa.py` initially failed because it still required
`activePersonaTag` and `personaSearchScope` to leave the device. Classification:
**stale static baseline**, not a missing product field. The named endpoint is not a
generic retrieval endpoint and its privacy contract deliberately excludes profile,
city, saved-state, route, and conversation fields.

The check now has two strict branches: a generic retrieval client must remain
persona-aware, while `NewcomerRequestBody` must contain exactly the bounded demo
fields, omit private context, reject generic chat, and use the fixed knowledge-ID
set. No product context was added to the network request and no assertion was
disabled. Files: `scripts/persona-ia-static-qa.py`, with the contract independently
covered by `scripts/ai-subsystem-static-qa.py` and Swift request-encoding tests.
The complete 40-command aggregate passed again on the current working tree.

Repository-readiness review then found that the dashboard generator silently
depended on an untracked `knowledge_data_health.json`. That was a reproducibility
bug, not a reason to version a stale network report. The generator now emits an
explicit epoch/zero-count `OFFLINE_LINK_EVIDENCE` sentinel when no network artifact
exists. An isolated temporary-copy check generated the dashboard and passed the
offline structural health gate with 0 inspected URLs; the same report was then
correctly rejected by `data-health-gate.py --require-network` as stale. The full
40-command aggregate passed after this change. Files:
`scripts/generate-data-dashboard.py`, `scripts/data-dashboard-static-qa.py`, and
`DataProject/README.md`. The nightly network gate was not weakened.

## UI tests

### 1. `AccessibilityRuntimeUITests/testAccessibilityTextSizeKeepsHomeControlsReachable()`

- Cause: `home.currentProfile` had a fixed 42×42 frame, below the shared 44-point minimum touch target.
- Classification: product accessibility bug.
- Fix: size the control with `AppIcons.Metrics.minimumTouchTarget`.
- Files: `YouNew/Views/HomePremiumInformationCard.swift`.
- Why correct: it uses the existing design-system accessibility token and preserves the control and its action.
- Rerun: **PASS**, 21.308 s in the closed frozen-source exact-six bundle.

### 2. `RootNavigationUITests/testAccessibilitySizeKeepsPrimaryHomeActionsReachable()`

- Cause, classification, fix, files, and rationale: the same independently reproduced 42-point product defect as UI failure 1.
- Rerun: **PASS**, 39.034 s in the same closed bundle.

### 3. `ContentCompletionRuntimeUITests/testRequiredContentDestinationsRenderCompletedSurfacesWithoutPlaceholderCopy()`

- Cause: SwiftUI's outer `practicalGuide.transportBasics` accessibility identifier correctly replaced the inner legacy `transport.screen` identifier; the destination rendered in the baseline hierarchy.
- Classification: stale UI-test contract.
- Fix: assert the canonical route identifier `practicalGuide.transportBasics`.
- Files: `YouNewUITests/ContentCompletionRuntimeUITests.swift`.
- Why correct: this is the stable typed route used by current navigation and by other passing UI coverage; content and accessibility checks remain intact.
- Rerun: **PASS**, 482.396 s in the same closed bundle.

### 4. `ContentCompletionRuntimeUITests/testRequiredContentSurfacesStayCompletedWhileScrolling()`

- Cause, classification, fix, files, and rationale: same canonical-identifier mismatch as UI failure 3; scrolling and placeholder assertions remain enabled.
- Rerun: **PASS**, 4,164.856 s in the same closed bundle. The long duration
  reflects real accessibility-tree traversal across all 13 destinations; it was
  not shortened with sleeps, skips, or reduced assertions.

### 5. `PublishedCitiesRuntimeUITests/testPublishedAmsterdamMuseumFlowsFromSearchToGuideAndSaved()`

- Initial cause: Search exposed the published item with its current canonical
  result prefix, while the test queried the obsolete unprefixed identifier. The
  result was present in the baseline accessibility hierarchy.
- Initial classification: stale UI-test contract.
- Initial fix: use
  `search.directResult.link.canonical-museum.rijksmuseum` and additionally verify
  the visible title before navigation.
- Frozen exact-six finding: five of the six original failing UI tests passed. The
  Rijksmuseum test reached the exact canonical element but failed because the
  first remediation compared its label to title-only text. The product
  intentionally combines result type, exact title, and descriptive subtitle for
  VoiceOver with `.accessibilityElement(children: .combine)`. Classification:
  **test bug in the first remediation**, not a product or environment failure.
- Semantic-label fix: preserve the informative combined VoiceOver label and
  assert that `Rijksmuseum` is an exact comma-delimited component. This rejects a
  different title without discarding the type or description read by VoiceOver.
- First revised-run finding: the corrected label assertion passed, but tapping
  the result opened `.mapHub` instead of the published record's Guide detail.
  Classification: **product routing bug**. A place-like DataProject entity used
  the map consumer as its own detail route, which discarded the record body,
  sources, and Saved action after Search navigation.
- Product-route fix: route published DataProject place-like entities to
  `.guideArticle(sectionID: "data-project", articleID: id)`; resolve that dynamic
  article from `ContentRepository`; and render its structured description and
  source links in the existing Guide article surface. The map remains a consumer
  of the same canonical coordinate record.
- Visibility-resolver fix: teach `RelatedContentEngine.isVisible` to recognize a
  published dynamic `data-project` Guide article. Without this, the outer route
  guard rejected the new valid destination before `AppDestinationView` could
  resolve it.
- Saved-control fix: the test had depended on the localized VoiceOver label
  `Bookmark`. `SaveItemButton` now exposes the stable identifier
  `saved.toggle.<canonical-id>` while retaining its localized Save/Remove
  VoiceOver label unchanged. No accessibility text was removed.
- Harness fix: a duplicated DEBUG destination presentation kept the Search path
  in an overlay, so tapping the root Saved tab could not switch the visible root
  content. The duplicate overlay initialization was removed; the existing
  path-based `-uiTestingDestination` launch is retained and applied once after
  the root stack appears. This changes only the DEBUG test harness.
- Files: `YouNew/Services/DataProjectRuntimeLoader.swift`,
  `YouNew/Services/ContentRepository.swift`,
  `YouNew/Models/RelatedContentEngine.swift`,
  `YouNew/App/Navigation/AppDestinationView.swift`,
  `YouNew/Views/GuideContentView.swift`,
  `YouNew/Core/DesignSystem/Components/NavigationUIComponents.swift`,
  `YouNew/App/AppTabView.swift`,
  `YouNewTests/PublishedCitiesDataReleaseTests.swift`, and
  `YouNewUITests/PublishedCitiesRuntimeUITests.swift`.
- Why correct: Search, Guide, Map, and Saved now consume one published canonical
  record and one restorable typed detail route. The exact title, dynamic article,
  Saved action, root-tab transition, and final Saved presence all remain asserted;
  no sleep, skip, accessibility check, or user feature was removed.
- Focused unit route verification: **4/4 passed, 0 failed** in
  `YouNewBuildWeekRouteUnit-20260720-3.xcresult` (local test artifact, not committed).
- Focused final UI verification: **1/1 passed, 0 failed**, 20.867 s, in
  `PublishedHarnessFixTest-20260720T1204.xcresult` (local test artifact, not committed).
- Environment note: one intervening rerun could not complete because the host
  reported `ENOSPC` (no space left on device). That attempt is classified as an
  environment issue and is not counted as product PASS or FAIL evidence.

### 6. `YouNewUITests/testSearchAfspraakFindsDutchCourse()`

- Cause: the test asserted a presentation-dependent text lookup even though Search exposes the stable canonical Dutch-course module result.
- Classification: stale UI-test baseline.
- Fix: assert `search.directResult.link.canonical-dutchCourseModule:time-appointments`.
- Files: `YouNewUITests/YouNewUITests.swift`.
- Why correct: the test still proves that the `afspraak` query resolves to the exact time-and-appointments course module; no wait, assertion, search content, or accessibility check was removed.
- Rerun: **PASS**, 15.453 s in the closed frozen-source exact-six bundle.

### UI result

The closed frozen-source exact-six action executed 6 tests: **5 passed, 1 failed,
0 skipped, 0 expected failures**. Its only failure was the over-strict Rijksmuseum
label equality documented above. The action took 4,778.451 s wall-clock. That red
bundle remains evidence and is not overwritten. A subsequent revised run proved
the label correction and exposed the separate `.mapHub` product-route defect;
each later failure in the chain was retained as diagnostic evidence rather than
being hidden by a broader assertion.

The final focused Rijksmuseum Search → Guide → Saved flow is now **1/1 passed** in
20.867 s in the local `PublishedHarnessFixTest-20260720T1204.xcresult` artifact.
Its focused route contract is **4/4 passed** in the local
`YouNewBuildWeekRouteUnit-20260720-3.xcresult` artifact. A complete post-fix
inventory of **87 UI tests** is still required; the additional test is the explicit
no-backend `BuildWeekNewcomerDemo` fallback path. No in-progress console output or
the interrupted `ENOSPC` attempt is treated as a PASS.
