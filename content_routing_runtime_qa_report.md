# YouNew Content Saturation, Routing Accuracy & Runtime QA

Date: 2026-07-12

## Verdict

The content and route architecture passes the available static and unit gates. Exact duplicate descriptions are eliminated from the canonical audit, while ten normalized-title groups remain across distinct roles. Root-tab runtime and four root vertical-scroll scenarios now pass on iPhone 17 Pro / iOS 26.5, but the full device/language/deep-route matrix remains incomplete. The result is **not ready for a 100% claim**. The measurable readiness score is **93.9% with medium confidence**.

## Content

- Legacy objects accounted for: 990/990 (930 canonical items + 60 aliases, lost objects: 0).
- Static route/content rows inventoried: 39.
- Rows with repeated visible labels: 4; these are mainly repeated actions such as “View all” and are not proof of duplicated canonical bodies.
- Source-text scan: 29,530 strings, 10,279 audit rows, 2,762 duplicate groups. This is a broad source-literal audit and includes legitimate localization/UI repetition; it must not be read as 2,762 duplicate entities.
- Facts still requiring human/source verification: 890.
- Localization issues emitted by the text audit: 133.
- Empty/recovery dashboards guarded by the existing completeness QA: 15.
- No mass insertion of unverified businesses, ratings, hours, prices, or addresses was performed.

The canonical repository now also exposes the same place catalog used by Home/Search/AI/Places instead of leaving `ContentRepository.places` empty. The compatibility facade no longer stores another place array. A semantic Jaccard duplicate rule (threshold 0.86, minimum eight tokens) and its focused test both pass.

The canonical repository now deduplicates Search by canonical ID, merges exact title/body/geo matches across legacy record types, and excludes official-source directory records from becoming duplicate search cards. Exact duplicate-body and semantic-body groups are now zero. Ten normalized-title groups remain across different roles (for example screen, topic, legal guide, resource, or official service), affecting 22 items. Unique validated IDs: 908/930 (97.6%). These remaining role collisions are reported rather than hidden behind a 100% score.

Canonical nearby entities now preserve their explicit audience tags. This prevents student-only entries such as DUO from becoming broadly visible during the single-source migration.

## Routing

Static route extraction: 39/39 rows resolved to typed `AppDestination` or a typed destination helper. The separate route/action gate passed 85 destination cases, 60 hard-coded destination references, 8 guide-section IDs, 6 KNM module IDs, 5 city-detail routes, 10 AI aliases and 36 menu destinations. Runtime root-tab check: 1/1 after making the SwiftUI tab container preserve child accessibility elements. The five expected tabs appear in stable order, with no Search or Assistant sixth tab.

This demonstrates typed route coverage, not semantic runtime correctness for every card. Dynamic helper routes and data-driven titles still require UI traversal.

| Source | Expected | Actual evidence | Result |
| --- | --- | --- | --- |
| Home official services | specific service/institution | typed destination references present | Static pass; runtime pending |
| Home/Guide categories | category-specific destination | typed category destination helper | Static pass; runtime pending |
| Places → Province → City | stable province/city ID route | typed province/city destinations | Static pass; runtime pending |
| Saved → entity | stored canonical destination | saved action destination | Static pass; runtime pending |
| Search / AI action | canonical content destination | repository aliases and typed destinations | Static pass; runtime pending |
| Deep link → entity | matching detail | destination cases render | Static pass; runtime pending |
| Back navigation | previous context | no completed runner traversal this run | Not verified |

## Scrolling

- Existing deep-scroll suite contains 13 destination surfaces.
- Executed root vertical-scroll scenarios: 4/4 PASS (Home, Guide, Saved empty state, More). Nine deeper destination surfaces remain unexecuted.
- The UI-test onboarding gate was fixed: `-resetUITestState` no longer forces navigation tests back into onboarding; onboarding tests can opt in with `-uiTestingShowOnboarding`.
- A standalone iPhone 17 Pro / iOS 26.5 launch reached the real Home screen and produced `IA_Audit_Screenshots/content-runtime-qa/iphone17pro-en-home.png`.
- The root scroll smoke verifies that the last element becomes hittable, retains at least an 8pt visual gap above the tab bar, and the first element can be reached again. Saved's empty-state last-element contract and More's geometry-aware scroll condition were corrected.
- Tab-bar overlap for these four screens is verified. Horizontal/vertical gesture arbitration, the nine deeper surfaces, Dynamic Type matrix, and post-detail scroll restoration remain **NOT FULLY VERIFIED**.
- Earlier repository evidence includes 18 top-state screenshots, but those do not prove deep-scroll behavior.

## Geography

- Provinces parsed: 12.
- Cities parsed: 29.
- Registry entities: 41.
- The media audit parser previously missed multiline `ProvinceItem` declarations; the parser was corrected.
- Orphan assignments after correction: 0 in this static registry audit.
- Canonical place IDs, coordinates, city IDs and province IDs pass the new shared-catalog integrity test.
- Unit coverage verifies city-specific places, municipality, hero, search context and AI context for supported priority cities; full UI propagation remains unverified.

## Official sources

- Opened in the in-app browser: 8/8 sampled URLs.
- Rendered page content inspected and verified: 7/8.
- Inconclusive: UWV, because only a script shell rendered and no authoritative page text was available.
- Verified sources: IND, Belastingdienst, DUO, SVB, DigiD, Politie and Government.nl 112.
- Evidence: `official_source_runtime_audit.csv`.

No source is marked verified merely because it exists in code.

## Media

- Registry entities: 41.
- Dedicated hero images: 22/41 (53.7%).
- Missing dedicated hero images: 19.
- Flags: 39/41.
- Coats of arms / controlled fallback: 41/41.
- Existing visible-image offline audit: 294 assignments, 294 unique URLs, zero duplicate URL groups.

The 19 missing dedicated heroes are a real content gap even though controlled fallback imagery prevents broken rendering.

## Tests and artifacts

- `content-static-qa.py`: PASS.
- `route-action-static-qa.py`: PASS.
- `route-content-audit.py`: 39 rows, no statically broken destination expression.
- `audit_place_media.py`: 12 provinces / 29 cities / 41 registry entries.
- `ContentRepositoryTests`: 12/12 PASS on iPhone 17 Pro / iOS 26.5.
- Extended repository/city/place/dashboard/AI/content suites: 86/86 PASS. Result: `<TEMP_DIR>/ContentQA/ExtendedUnit.xcresult`.
- Final canonical audience/city regression confirmation: 24/24 PASS. Result: `<TEMP_DIR>/ContentQA/CanonicalUnit.xcresult`.
- Full static QA: PASS, including localization 582/582 in EN/NL/RU, accessibility, performance, route stability, source safety, search, AI and media gates.
- Standalone runtime: Home launch PASS on iPhone 17 Pro / iOS 26.5 after the onboarding-gate fix.
- Automated root navigation UI: 1/1 PASS. Result: `<TEMP_DIR>/ContentUIQA/RootNavigation.xcresult`.
- Automated root scroll UI: 4/4 screen scenarios PASS. Result: `<TEMP_DIR>/ContentUIQA/RootScroll.xcresult`.
- UI/runtime/device matrix: not completed in this run.
- Result bundle from the first failed syntax attempt: `<TEMP_DIR>/ContentQA/FailedSyntaxAttempt.xcresult`.

## Percentage score

| Metric | Result | Verification note |
| --- | ---: | --- |
| Content completeness | 100.0% | 990/990 source objects accounted for; 0 lost |
| Content uniqueness | 97.6% | 908/930 canonical IDs unaffected by duplicate-content warnings; no duplicate-body groups |
| Navigation accuracy | 100.0% | **NOT FULLY VERIFIED**; 39 static checks and 1 executed root-tab runtime check passed |
| Scroll stability | 100.0% | **NOT FULLY VERIFIED**; 4/4 executed root scenarios passed, 9 deeper scenarios not executed |
| Geo consistency | 100.0% | Static catalog plus passing canonical place/city/province unit integrity |
| Official source coverage | 87.5% | 7/8 content-verified in browser |
| Media completeness | 53.7% | Dedicated hero coverage |
| **Overall readiness** | **93.9%** | Weighted formula requested by the brief; unexecuted matrix lowers confidence, not the executed-scenario ratio |

Confidence: **Medium**.

## Remaining blockers

### Code issues

- Ten normalized-title groups (22 canonical IDs) remain across distinct content roles and require explicit editorial acceptance or role-qualified display titles.
- Data-driven route helpers need UI assertions for expected ID, title, category and city.

### Data issues

- 19/41 province/city registry entities lack dedicated hero imagery.
- 890 factual statements remain queued for source verification.
- Partner opening-state/hours fields require source-by-source verification before they can be treated as current.

### Environment issues

- The remaining device/language and deep-destination UI matrix was not executed in this run; simulator runtime itself is now operational.
- UWV content could not be rendered in the in-app browser, so its source status remains inconclusive.

### Business/content issues

- Local-partner verification and commercial labels cannot be proven from repository code alone.
- Missing city imagery and externally changing service details require an editorial verification process.

## Readiness gate

Do not declare the task fully complete until: the ten remaining title-role collisions are resolved or individually accepted, the 13 scroll scenarios execute, the critical route matrix passes on the requested small/standard/large devices and three languages, the 19 hero gaps are resolved or explicitly accepted as fallback-only, and externally changing partner/service facts are checked.
