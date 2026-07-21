# Stage 2 — test remediation ledger

Date: 2026-07-21 (Europe/Amsterdam)
Branch: `build-week-readiness`
Baseline commit: `b15a2f2913911763c989f9880f8ce376f903fc6e`

## 2026-07-21 evidence chronology

This ledger preserves earlier findings rather than rewriting them as current facts.

- Frozen audit baseline: UI **80/86 RED**.
- Historical source `61e7ce11`: serial UI **82/87 RED**; the failure details below
  remain historical diagnostics.
- Last fully closed clean-clone snapshot:
  `efd1a7c50bf7b5e2f82be047b084b6d73cb009a7`, serial UI **84/87 RED**.
- The current working tree over product/test source
  `da8c3fe22e7a5d99b2187aab1141700b2d34f508` adds narrow root-tab, Guide,
  input-hit-testing, and media-URL fixes. The preserved targeted results close the
  primary Map → Home blocker (3/3 checks; 10/10 first-tap transitions), the Guide
  placeholder (1/1), and search focus (5/5). Category routing was not reproduced
  after repeated focused passes, so routing code was not changed speculatively.
- A current local Data Health report also records 18 confirmed broken URLs in
  shipped runtime data. This is a release-data blocker, not a reason to skip,
  weaken, or reclassify UI tests.

No targeted result replaces a complete serial UI aggregate. The Build Week freeze
therefore reports the targeted evidence exactly and makes no all-UI-green claim.

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

- Cause: this direct command used the same exact-string matcher as the aggregate
  gate and therefore rejected the configured
  `TimelineView(.animation(minimumInterval: 1 / 15))` ambient layer.
- Classification: stale static matcher.
- Fix: accept the `TimelineView(.animation` call prefix while retaining the
  per-card-loop prohibition.
- Files: `scripts/brand-static-qa.py`.
- Why correct: the check still verifies one app-wide ambient animation and still
  rejects motion loops in individual cards; it now accepts the configured framework
  invocation.
- Rerun: PASS individually and in the 40-command aggregate.

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

- Cause: the same `home.currentProfile` control was fixed at 42×42 points, below
  the shared 44-point minimum touch target.
- Classification: product accessibility bug.
- Fix: size the control with `AppIcons.Metrics.minimumTouchTarget`.
- Files: `YouNew/Views/HomePremiumInformationCard.swift`.
- Why correct: the shared design-system token preserves the control, label, and
  action while satisfying the minimum reachable target requirement.
- Rerun: **PASS**, 39.034 s in the same closed bundle.

### 3. `ContentCompletionRuntimeUITests/testRequiredContentDestinationsRenderCompletedSurfacesWithoutPlaceholderCopy()`

- Cause: SwiftUI's outer `practicalGuide.transportBasics` accessibility identifier correctly replaced the inner legacy `transport.screen` identifier; the destination rendered in the baseline hierarchy.
- Classification: stale UI-test contract.
- Fix: assert the canonical route identifier `practicalGuide.transportBasics`.
- Files: `YouNewUITests/ContentCompletionRuntimeUITests.swift`.
- Why correct: this is the stable typed route used by current navigation and by other passing UI coverage; content and accessibility checks remain intact.
- Rerun: **PASS**, 482.396 s in the same closed bundle.

### 4. `ContentCompletionRuntimeUITests/testRequiredContentSurfacesStayCompletedWhileScrolling()`

- Cause: the test searched for the inner legacy `transport.screen` identifier even
  though the active typed route exposes the stable outer
  `practicalGuide.transportBasics` identifier.
- Classification: stale UI-test contract.
- Fix: assert `practicalGuide.transportBasics` while retaining the scrolling and
  placeholder-content assertions.
- Files: `YouNewUITests/ContentCompletionRuntimeUITests.swift`.
- Why correct: the revised assertion validates the current typed destination and
  still proves that the completed transport surface remains available while
  scrolling.
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
`YouNewBuildWeekRouteUnit-20260720-3.xcresult` artifact. The earlier complete
serial post-fix snapshot at `49acdc66` executed **87 tests: 86 passed, 1 failed,
0 skipped**. A later authoritative clean-clone serial run at `61e7ce11` is closed
**RED at 82 passed, 5 failed, 0 skipped, 0 expected failures**. The later result is
the release gate; historical 86/87 evidence is retained only for diagnosis. No
in-progress console output or the interrupted `ENOSPC` attempt is treated as a
PASS.

### Follow-up UI diagnostics — content scrolling and Discovery presentation

1. **`ContentCompletionRuntimeUITests.testRequiredContentSurfacesStayCompletedWhileScrolling()`**
   - Real cause: the test took two independent global accessibility snapshots after
     every scroll. In the closed 84/87 clean-clone bundle, the second snapshot
     stalled on a dense Documents surface and later starved the next route query;
     the completed content itself was already present.
   - Classification: test-implementation/performance defect amplified by
     XCUITest/Simulator accessibility-query instability, not a proven product
     content defect or stale expected value.
   - Fix: capture visible labels once per state and reuse the same labels for the
     unchanged unfinished-copy/raw-localization and meaningful-content assertions.
   - Files: `YouNewUITests/ContentCompletionRuntimeUITests.swift`.
   - Why correct: every destination, scroll count, forbidden-copy check, raw-key
     check, and minimum-content assertion remains. The change removes only the
     duplicate expensive query; it adds no sleep, skip, retry, or weaker expected
     value.
   - Rerun: **PASS — 1/1, 2,145.578 s** in
     `FocusedUI.xcresult` on iPhone 17 Pro / iOS Simulator 26.5.

2. **`CategoryRoutingRuntimeUITests.testRequestedDiscoveryChipsReachTheirTypedDetailAndReturn()`**
   - Real observations: the initial closed 84/87 bundle did not observe the menu
     after a synthetic tap. The first follow-up proved the menu can open; after
     synchronization it reached multiple real Place/Discovery routes (including
     Nature) before a later fresh launch again failed at menu presentation.
   - Classification: a narrow test synchronization/targeting defect was corrected,
     but the remaining menu-presentation observation is an **unresolved UI
     reliability issue most consistent with intermittent Simulator/XCUITest input
     delivery**. A product presentation defect is not excluded.
   - Fix: wait for the existing trigger to become hittable, require the existing
     overlay after tapping, and use that verified overlay as the gesture container
     for Discovery-group scrolling. Failure messages now include the requested
     chip. No group/chip/detail/back assertion, data fixture, expected route,
     accessibility check, or product behavior was removed.
   - Files: `YouNewUITests/CategoryRoutingRuntimeUITests.swift`.
   - Why correct: existence alone was not a proof that the trigger could receive a
     synthetic event, and the SwiftUI `ScrollView` itself is not exposed as a
     standalone accessibility element. The already-visible overlay is the stable
     enclosing gesture surface; this is not an added retry or delay.
   - Rerun: **RED — 0/1, 294.928 s** in
     `CategoryRoutingUIOverlay.xcresult`; after several real routes it again
     reported that the menu did not open. This focused result is diagnostic only
     and cannot replace the required full clean-clone aggregate.

No further test-contract changes are retained for this finding without new
device/hit-test evidence. The required next proof is a physical-device or
instrumented hit-test run that records receipt of the menu action; increasing waits,
adding repeated taps, or skipping the scenario would conceal the release risk.

### Post-fix failure — `MapChipUITests/testRootTabNavigationLatency()`

- Name: `MapChipUITests.testRootTabNavigationLatency`.
- Real cause: the first cold Map → Home transition can include initial
  `RootHomeView`/`NavigationStack` construction and exceed the test's 100 ms bound;
  later transitions in the same run are materially faster. The audited simulator
  also emitted duplicate Accessibility-loader warnings, and one rebooted optimized
  run failed because the synthetic Home tap was not committed at all.
- Classification: **product performance bug amplified by an environment issue**.
  It is not a stale baseline or a test bug: the threshold and outcome assertions
  remain unchanged.
- Fix attempted and retained: remove unnecessary published root-tab selection
  invalidation and dead tab bookkeeping, and prewarm the existing connectivity
  monitor after the first frame. Add state-semantics unit coverage and print exact
  latency samples for evidence. No user feature was removed.
- Files: `YouNew/App/AppEntry.swift`, `YouNew/App/AppTabView.swift`,
  `YouNew/Models/TabRouter.swift`, `YouNewTests/TabRouterTests.swift`, and
  `YouNewUITests/MapChipUITests.swift`.
- Why correct: tab selection is an imperative navigation cursor, not view content;
  removing its unused `@Published` invalidation preserves selection/reset behavior
  while avoiding a root-hierarchy notification. The added diagnostics do not
  change the assertion, threshold, timeout, or execution count.
- Rejected experiments: native/persistent tab variants made transitions slower;
  the persistent-tabs run completed all ten transitions but still failed at
  144.067 ms (66.8 ms average). Lazy/`AnyView` wrapping delayed or lost Home, and
  model-metadata prewarming produced a non-repeatable isolated pass. All were
  reverted rather than retained as speculative changes.
- Rerun evidence: the earlier reliable complete serial result failed at a 103.455 ms
  maximum. Later exact Debug samples still showed cold maxima of 129–138 ms while
  warm samples were approximately 26–39 ms. One optimized run passed with a 96.5 ms
  maximum, but a full simulator reboot then lost the synthetic Home tap and never
  produced a valid metric. Neither outcome is promoted to a green gate. The
  historical `61e7ce11` clean-clone serial run failed at **102.043 ms**; it
  remains a mandatory historical aggregate result, not a result for current code.
- Minimal safe demo workaround: cold-launch directly on Home and run the judge demo
  on one controlled simulator or physical device; do not include the Map → Home
  stress calibration in the main take. This is a demonstration workaround, not a
  release-gate PASS.

### Current-source UI — `CategoryRoutingRuntimeUITests.testEveryLeisureSectionReachesDetailAndReturns()`

1. **Failure:** after tapping `home.exploreList.action.family-museums`, the expected
   `category.list.museums.leiden` did not appear; the source
   `category.list.family-activities.leiden` remained active.
2. **Real cause:** XCTest observed no navigation push after the synthetic tap.
   Product mapping is unambiguous: the standard `NavigationLink(value:)` maps this
   action to `.museumList(city: .leiden)`, which renders
   `category.list.museums.leiden`. There is no evidence of a push to the wrong
   destination.
3. **Classification:** **environment/UI-automation event-delivery issue is the
   best-supported classification; a product bug is not proven**. The expected
   destination is correct and the baseline is not stale. The assertion message
   says “wrong nested list,” but its checked contract remains valid and was not
   weakened.
4. **Fix:** production code, expected value, timeout, and assertion were not
   changed. One isolated diagnostic rerun of the same test is performed after the
   full serial suite, without a retry policy, sleeps, skips, or altered expectations.
5. **Changed files:** none for this finding.
6. **Why correct:** replacing a standard navigation link, increasing waits, or
   repeating the tap would mask an unproven cause. The identical test/routing/view
   source passed in the earlier clean-clone Category suite (15/15; this case
   77.885 s), and those files are byte-identical between `49acdc66` and `61e7ce11`.
7. **Rerun:** **PASS — 1/1, 75.775 s** on the same clean-clone binary and
   simulator. It demonstrates that the route works and that the full-run observation
   is nondeterministic; it cannot erase the failure in the mandatory 82/87
   aggregate or prove that a product bug is impossible.

### Current-source UI — `CategoryRoutingRuntimeUITests.testEveryHousingAndGovernmentSectionReachesDetailAndReturns()`

1. **Failure:** after the municipality detail appeared, the Back action did not
   return to `category.section.government.municipality` within the unchanged six
   second contract.
2. **Real observation:** the test had already proved that the exact municipality
   detail existed before it invoked the shared navigation-bar/edge-swipe Back helper.
   The full bundle contains no evidence of a wrong destination or changed expected
   value; it only records the missing return to the typed list.
3. **Classification:** **unresolved UI navigation reliability issue**. It is not a
   stale baseline or a proven test bug. The prior `49acdc66` complete suite passed
   this unchanged route, but a product Back-state defect cannot be excluded from a
   single failed automation observation.
4. **Fix:** no speculative source or test change was retained. No timeout, gesture,
   assertion, or expected destination was weakened.
5. **Changed files:** none for this finding.
6. **Why correct:** changing the helper to repeat a tap or use a longer wait would
   mask exactly the navigation reliability contract the test protects.
7. **Result:** full clean-clone result remains **FAIL**. A physical-device/profile
   investigation with navigation hierarchy evidence is required before calling this
   an environment-only issue.

### Current-source UI — `YouNewUITests.testAssistantHealthInsuranceWorkflowOpensHealthcareMapFocus()`

1. **Failure:** the test found both required health-insurance follow-up actions and
   `assistant.quickAction.openScreen.mapfocus.healthcare`, tapped it, then did not
   observe `map.screen` within the unchanged six-second contract.
2. **Real observation:** all prerequisite deterministic Assistant workflow steps
   completed in the full run; the failure occurred only after the synthetic map
   action. The same app route resolves `mapFocus:healthcare` to
   `NearbyMapView(initialFocus: .healthcare)`.
3. **Classification:** **environment/UI-automation event or transition-delivery
   issue is the best-supported classification; product defect not excluded**. The
   action's contract is current and was not relaxed.
4. **Fix:** no production or test code changed for this isolated observation.
5. **Changed files:** none for this finding.
6. **Why correct:** modifying the Assistant route, adding delay, or retrying the
   tap would hide a non-reproduced failure rather than establish its cause.
7. **Rerun:** **PASS — 1/1** as part of the post-full-run two-test Assistant
   diagnostic (25.041 s for this case). The full aggregate remains red.

### Current-source UI — `YouNewUITests.testBuildWeekNewcomerDemoUsesExplicitLocalFallbackWithoutBackend()`

1. **Failure:** the test could not find `assistant.input`. Its full-run hierarchy
   showed a Russian `map.hub`, selected Map tab, and root metric `tab=map` even
   though the test requested English plus `-uiTestingDestination assistant`.
2. **Real observation:** this is a launch-state mismatch before the fallback prompt
   or fallback assertions ran. It is not evidence that the deterministic fallback
   returned a wrong origin, missing step, or wrong guide action.
3. **Classification:** **environment/XCTest process launch-state contamination is
   the best-supported classification; a product launch-routing defect is not fully
   excluded**. The explicit launch arguments and fallback assertions remain valid.
4. **Fix:** no product behavior or test contract changed. The test retains the
   reset argument, Assistant destination, local-origin assertion, four steps,
   source action, and BSN guide navigation.
5. **Changed files:** none for this finding.
6. **Why correct:** accepting the Map snapshot, removing reset, or replacing the
   Assistant assertion would conceal the exact demo guarantee.
7. **Rerun:** **PASS — 1/1** as the second case in the paired Assistant diagnostic
   (26.892 s; pair total 51.933 s). It does not overwrite the 82/87 full result.

## Clean-clone findings after the original failure set

These findings were exposed only after the intended product files were committed
and cloned without the source workspace's ignored generated state. They are not
retroactively folded into the original 4/5/6 baseline counts.

### Aggregate static QA: missing release manifest in a fresh clone

- Failure: `data-project-import-static-qa.py` stopped with
  `Release cities-v0.1.0 has no generated release manifest`.
- Cause: `scripts/run-static-qa.sh` invoked importer validation before
  `generate-data-observability.py`, while the required release manifests correctly
  live under ignored `DataProject/reports/`.
- Classification: **reproducibility/product-pipeline bug** hidden by generated local
  state, not a network or test-expectation failure.
- Fix: generate observability/release manifests before importer validation; add an
  ordering assertion; run import validation in the offline GitHub publication gate
  after manifest generation.
- Files: `scripts/run-static-qa.sh`,
  `scripts/data-project-workflow-static-qa.py`, and
  `.github/workflows/data-project-health.yml`.
- Why correct: the importer still requires a governed manifest and retains every
  assertion. The producer now runs before the consumer in a fresh repository; no
  ignored artifact is checked in and no validation is bypassed.
- Rerun: authoritative report-free clean clone **40/40 PASS**; DataProject/import
  validation PASS; post-run tracked tree clean.

### `KnowledgeIndexTests/allIndexedRoutesResolveToLiveDestinations()`

- Cause: published DataProject place-like records intentionally use
  `article:data-project:<canonical-id>`. The UI, visibility engine, and Saved
  restoration accepted that route, but the central string resolver checked only
  the static `GuideContent` registry. The test's second existence assertion also
  used that static registry for a dynamic repository article.
- Classification: **product bug** in route restoration plus a **test datasource
  bug** introduced by the new dynamic article architecture.
- Fix: resolve published `data-project` article IDs through `ContentRepository` in
  the main-actor navigation resolver; retain static `GuideContent` validation for
  ordinary guide articles; make the integrity test validate each route against its
  authoritative store.
- Files: `YouNew/App/Navigation/AppRouter.swift`,
  `YouNewTests/KnowledgeIndexTests.swift`, and
  `YouNewTests/PublishedCitiesDataReleaseTests.swift`.
- Why correct: the expected route and existence requirement were not weakened.
  The test still rejects unpublished/missing dynamic records and dead static
  articles, while string deep links now round-trip to the exact published record.
- Rerun: affected KnowledgeIndex and city-release suites **39/39 PASS**; the earlier
  resolver snapshot completed **458/458**. The current authoritative source commit
  independently passes **460/460**, with 0 skipped/expected failures.

### `KnowledgeIndexTests/navigationResolverRoundTripsIndexedDestinations()`

- Cause: same missing dynamic-article branch in `AppNavigationResolver`; the first
  reported route was `article:data-project:cafe.back-to-black`.
- Classification: **product bug**.
- Fix/files/correctness: same resolver correction above, plus a direct
  Rijksmuseum string-route regression in `PublishedCitiesDataReleaseTests`.
- Rerun: **PASS** in the 39-test focused rerun and the earlier 458-test complete
  rerun; it remains covered by the current 460/460 complete suite.

### Actor-isolation warning found during the route fix

An intermediate centralization attempt compiled but emitted three synchronous
nonisolated-to-main-actor warnings. It was not accepted as the final fix. Dynamic
repository lookup was moved back to the main-actor resolver, the static guide
registry kept its nonisolated contract, and the authoritative clean build completed
with **0 errors, 0 warnings, and 0 analyzer warnings**.
