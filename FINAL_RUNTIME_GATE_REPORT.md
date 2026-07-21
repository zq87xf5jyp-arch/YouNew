# YouNew Final Runtime Gate Report

Date: 2026-07-12/13 (Europe/Amsterdam)  
Gate status: **OPEN**  
Confidence: **Medium for iPhone 17 Pro / Low for the full device matrix**

## Environment

- Xcode: 26.6 (17F113) — PASS
- iOS runtime: 26.5 (23F77) — PASS
- Executed device: iPhone 17 Pro, `A237D791-3020-4538-BAD2-0A19F66279EE` — PASS
- DerivedData: `<TEMP_DIR>/FinalRuntimeQA` — PASS
- Locale runtime coverage on the executed device: English, Dutch, Russian primary navigation — PASS
- Network: available for the official-source and priority-city media checks — PASS
- iPhone SE, iPhone 15, Pro Max and iPad runtime traversal — NOT TESTED

## Build and tests

| Gate | Result | Evidence |
|---|---:|---|
| Clean build | PASS | `xcodebuild clean` exit 0 |
| Build for testing | PASS | `BuildForTesting.xcresult` |
| Unit tests | PASS | 387/387, 0 failures, `UnitTestsAfterFix.xcresult` |
| Full UI suite | FAIL | 49/63 passed, 14 failed, `UITestsGateFinal.xcresult` |
| Accessibility Home retest | PASS | 1/1, `UIHomeAccessibility3.xcresult` |
| Accessibility AI + Map retest | PASS | 1/1, `UIAssistantRetest7.xcresult` |
| Corrected Map tests | PASS | 2/2 within `UIConfirmedFixes.xcresult` |
| Corrected Home/More/localization tests | PASS (targeted) | subsequent targeted bundles; Search→KNM remains FAIL |
| Search → KNM | FAIL | `UISearchKNMFinal2.xcresult` |

The complete 63-test result remains the authoritative full-suite result. Targeted retests prove individual fixes, but do not convert the full suite to PASS.

## Runtime traversal

- Full automated UI plan executed: 63 tests, 49 PASS, 14 FAIL at the captured full-suite checkpoint.
- Confirmed working: cold launch, five-tab navigation, root surfaces, Home/Search/AI accessibility size, Search→BSN, Map→Leiden, selected city/province AI routes, DigiD, BSN, fines, healthcare, housing, More, Saved, History, direct KNM menu route, Dutch course route.
- Confirmed failing: Search result → KNM detail.
- Onboarding all personas, complete side-menu gesture matrix, all 12 provinces, all requested business flows, background/warm/force-quit matrix — NOT TESTED as a complete gate traversal.

## Navigation evidence

| Source | Expected | Actual | Result |
|---|---|---|---|
| Root tabs | Home / Guide / Map / Saved / More | Correct five surfaces | PASS |
| Search suggestion: BSN | BSN result | BSN result card | PASS |
| Map city filter: Leiden | Leiden route target | Leiden city target | PASS |
| AI: Rotterdam | Rotterdam detail | `city.detail.rotterdam` | PASS |
| AI: selected Leiden | Leiden detail | `city.detail.leiden` | PASS |
| AI: selected Zuid-Holland | Province detail | `province.detail.zuid-holland` | PASS |
| AI: DigiD / BSN | Documents/guide/source actions | Correct target surfaces | PASS |
| AI: housing / healthcare / fines | Topic-specific guide/actions | Correct target surfaces | PASS |
| More tab | More root surface | `screen.more` | PASS after contract fix |
| Menu KNM | KNM detail | `knm.screen` | PASS |
| Search KNM | KNM detail | Non-KNM first result / stable KNM result not exposed | FAIL |

No claim is made that every requested Home card, province, city, side-menu category or deep link was traversed.

## Back stack and state

- Root tab switching and persistent custom tab bar — PASS.
- AI actions to city/province/topic surfaces — PASS in automated routes.
- Selected Leiden context in AI/map checks — PASS.
- Full detail→list scroll restoration, side-menu→origin restoration and every deep-link back stack — NOT TESTED.

## Scrolling

- All five root screens to a visible last element above the tab bar — PASS.
- All five root screens at Accessibility XXXL — PASS.
- Home controls at accessibility text size — PASS.
- Search, AI and Map entry points at accessibility size — PASS.
- Long content-completion scroll test — FAIL in the full suite due to the old map launch contract; test contract corrected but the entire long test was NOT RETESTED.
- Side menu, business registration, gallery and calendar scroll matrices — NOT TESTED.
- Runtime warnings `Invalid frame dimension (negative or non-finite)` were emitted in several AI tests. They did not fail those tests, but remain a performance/layout risk requiring diagnosis.

## Factual source audit

Risk-prioritized claims checked against first-party sources:

| Topic | Organization | Result |
|---|---|---:|
| BSN | Government.nl | VERIFIED |
| DigiD purpose/application | DigiD | VERIFIED; delivery wording corrected to “within 5 working days” |
| Residence permits | IND | VERIFIED |
| Personal tax | Belastingdienst | VERIFIED |
| Health-insurance obligation/basic scope | Government.nl | VERIFIED |
| Emergency/non-emergency police contact | Politie.nl | VERIFIED |
| Housing information | Government.nl | VERIFIED |
| Employment/benefits entry point | UWV | VERIFIED |
| Civic integration timing/path | Inburgeren.nl / DUO context | VERIFIED; unsupported generalized B1/duration/renewal copy removed |

Audited claims: 9; verified after correction: 9; outdated wording found: 2; unsupported wording removed: 1 group. The complete Priority-1 content corpus was not exhaustively audited.

## Official URLs

- Checked official application URLs: 9
- Valid/current organization pages: 9
- Broken application URLs: 0
- One guessed Government.nl URL returned 404 but was not referenced by the app and is excluded from the application metric.
- Partner, affiliate and booking link corpus — NOT TESTED.

## Media

- Priority-city hero URLs checked live: 8
- HTTP success + image content type + minimum payload: 8/8 PASS
- Home hero and premium map rendered on iPhone 17 Pro — PASS by runtime screenshot inspection
- Restaurant, partner and event remote-media corpus — NOT TESTED
- Full semantic city/entity correctness and fallback activation under forced failures — NOT TESTED

## Fixes made during this gate

| Defect | Root cause | Fix | Retest |
|---|---|---|---:|
| Unit knowledge-index failure | Institutions omitted from index | Added institutions to `KnowledgeIndex` | PASS, 387/387 |
| Production-safety pattern failure | Explicit `DispatchQueue.main` | Replaced with MainActor task | PASS, 387/387 |
| Home search AX identifier missing | Identifier overwritten by discovery-menu identifier | Attached `home.globalSearch` to real search button | PASS |
| AI send target below 44 pt | 38×38 control | Raised to 44×44 | PASS |
| Map/city runtime identifiers missing/stale | Tests targeted old chips; current map lacked stable city target | Added `map.hub` and stable `map.city.<slug>` contract; updated tests | PASS, 2/2 |
| Empty Recently Viewed block | Placeholder shown with no history | Hide section when no real entries exist | Build PASS; long content suite NOT RETESTED |
| Home/More tests targeted removed release surfaces | Stale UI contracts | Migrated tests to current root identifiers | Targeted PASS |
| DigiD/inburgering statements too broad | Unsupported/generalized copy | Replaced with first-party-source-aligned wording | Unit/build PASS |
| Search→KNM | Search result ordering/identifier does not yield KNM detail | Not resolved in this gate | FAIL |

## Scores

All denominators are stated; unexecuted work is not counted as PASS.

- Runtime navigation accuracy: **97.1%** (33/34 explicitly exercised route checks; Search→KNM failed)
- Runtime flow coverage: **44.7%** (34/76 flows in the requested traversal matrix exercised with route-level evidence)
- Scroll stability: **90.9%** (10/11 executed root/accessibility/content-scroll scenarios passed)
- Device coverage: **16.7%** (1/6 requested device classes executed)
- Localization runtime coverage: **100% for primary tabs/root launch only** (15/15 language×tab checks); deeper localized flows are NOT TESTED
- Factual verification: **100% of the audited subset** (9/9 after corrections); corpus coverage is incomplete
- Official URL validity: **100% of the checked subset** (9/9)
- Media live availability: **100% of the checked priority-city subset** (8/8)
- Content depth: **90.0% of the risk-prioritized audited subset** (9/10; Search→KNM discovery path incomplete)
- Weighted overall runtime readiness: **80.8%**
- Confidence: **Low overall**, because device coverage, full manual traversal, complete Priority-1 corpus coverage and the post-fix full UI rerun are incomplete.

## Remaining blockers

### Code

- Search→KNM route remains FAIL.
- AI tests emit invalid/non-finite frame runtime warnings.

### Test/evidence

- Full UI suite is not PASS (authoritative checkpoint 49/63).
- The three long content-completion tests and Home language-switch test were not fully rerun after their fixes.
- Full back-stack/deep-link/state-restoration matrix is incomplete.

### Environment/device

- iPhone SE, iPhone 15, Pro Max and iPad portrait/landscape are NOT TESTED.
- Instruments, Leaks, Allocations and Memory Graph are NOT TESTED in this gate.

### Content/source/media

- Full Priority-1 corpus, partner/affiliate URLs, and non-city remote media remain partially or wholly NOT TESTED.

## Closure decision

**Gate remains OPEN.** Required closure conditions are not met because the complete UI suite does not pass, Search→KNM is reproducibly broken, the requested device matrix is incomplete, and full Priority-1/source/media/back-stack evidence has not been collected.
