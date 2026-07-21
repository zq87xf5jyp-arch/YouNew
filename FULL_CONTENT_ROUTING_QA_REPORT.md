# YouNew — Content, Sources, Routing & Runtime QA

Date: 2026-07-12

## Executive summary

This pass audited the existing data and navigation architecture; it did not invent businesses, ratings, prices, opening hours, events, or addresses. The application already has broad curated datasets and extensive integrity gates. One confirmed routing defect was fixed: the Home and Guide cards for Housing, Healthcare, and Transport previously opened one generic practical-guide page. They now open their typed multi-article sections (`guideSection("housing")`, `guideSection("healthcare")`, `guideSection("transport")`).

The product is not declared fully populated. Category-specific live events, backend-backed business authentication/moderation, full external-link traversal, and complete device/runtime traversal remain incomplete.

## Content

- Requested user-visible surfaces in the existing completion matrix: 19.
- Live top states already captured: 18/19.
- Statically inspected visible view files: 36.
- Empty/recovery dashboards guarded: 15.
- Localized literal UI keys: 582/582 in EN, NL and RU.
- Visible media assignments: 294.
- Unique visible media URLs: 294.
- Duplicate visible media source groups: 0.
- Route/content audit rows: 39.
- Correct: 39; wrong: 0; generic after this pass: 0.
- The broad literal-text scanner reported 2,787 normalized duplicate groups. This includes localization labels, test fixtures and repeated operational UI labels and therefore is not treated as 2,787 duplicate entities.
- The focused route audit found four repeated visible labels among 39 rows (`View all` and similar labels), not four duplicated entities.

## Websites

Browser-opened official pages:

| Source | Result |
| --- | --- |
| IND | verified |
| Belastingdienst | verified |
| DUO | verified |
| DigiD | verified |
| SVB | verified |
| Politie | verified |
| Emergency 112 / Government.nl | verified |
| NS | verified |
| 9292 | verified |
| Government.nl portal | verified |
| UWV | inconclusive — script shell rendered without authoritative body text |

Verified: 10/11. All verified final URLs remained HTTPS and resolved to the expected organization. The result is recorded in `official_source_runtime_audit.csv`.

The repository contains hundreds of media/source URLs. They pass syntax and source-safety gates, but 0/294 media URLs were re-requested during this run because the media QA ran in offline/cache mode. They are renderable assignments, not current network-availability proof.

## Routing

### Fixed

| Source | Previous | Current | Result |
| --- | --- | --- | --- |
| Home → Housing | one `housingBasics` page | `guideSection("housing")` with Renting, Huurtoeslag and Tenant Rights | fixed |
| Home → Health and safety | one `healthcareBasics` page | `guideSection("healthcare")` | fixed |
| Home → Transport | one `transportBasics` page | `guideSection("transport")` with OV-chipkaart, bicycle and train articles | fixed |
| Guide → Housing | one practical page | typed housing section | fixed |
| Guide → Healthcare | one practical page | typed healthcare section | fixed |
| Guide → Transport | one practical page | typed transport section | fixed |

### Verified contracts

- `AppDestination` rendered cases: 85.
- Menu destinations mapped: 36.
- Static route/content cards: 39/39 correct.
- Stable IDs checked for checklist, fines, Dutch terms, rule topics/scenarios, mistakes, resources, beginner guides, scams, legal information, daily-life items, nearby places and search answers.
- Side-menu routes use `DiscoveryMenuRoute`, not display-title switches.
- Business login, registration and dashboard remain distinct routes.

## Runtime navigation

| Source | Expected | Actual | Result |
| --- | --- | --- | --- |
| Home → discovery menu | left overlay, Home preserved | overlay opened above Home | pass |
| Side menu → Places to visit | category sheet | sheet showed Museums, Attractions, Historic places, Parks with real counts | pass |
| Side menu → Museums | Leiden museum list | three Leiden museum entities, Back returned to Home stack | pass |
| Direct RU Housing route | Housing content | Russian generic guide was observed before fix | confirmed defect; fixed in code |
| Home deep scroll | lower sections remain usable | reached Netherlands in focus, Recently viewed and Saved without tab-bar overlap | pass |

Runtime traversal of every requested route was not completed. Navigation is therefore **NOT FULLY VERIFIED** despite the static 39/39 result.

## Scrolling

- Device executed: iPhone 17 Pro, iOS 26.5.
- Home initial state: pass.
- Home repeated upward drag/deep scroll: pass.
- Side-menu internal scroll and bottom business CTA: previously observed and pass.
- Category sheet presentation: pass.
- Russian Housing long text: top state wrapped correctly.
- Not executed in this pass: iPhone SE, iPhone 15, Pro Max, all 13 requested long screens, large Dynamic Type, Dutch deep scroll, nested horizontal carousels after image reload.

## Geography

- Runtime city used: Leiden.
- Home hero, nearby references, museum results and Housing context retained Leiden.
- Static media gates checked 12 province visual sets, 29 province-city cards, 37 runtime attractions and 42 curated place images.
- Full 12-province × all-city runtime traversal was not executed.

## Sources and media

- Static AI official-source tuples: 29.
- Browser-checked official pages: 11, of which 10 verified and one inconclusive.
- Image render/static QA: pass.
- Duplicate visible image groups: 0.
- Media URL live availability: not revalidated in this run.

## Tests

- Full static QA: PASS.
- App Store static QA: PASS after updating the overlay assertion to the new `DiscoverySideMenuOverlay`.
- Accessibility static QA: PASS.
- Performance static QA: PASS.
- Search static QA: PASS.
- AI subsystem static QA: PASS.
- Content and user-visible completeness static QA: PASS.
- `xcodebuild build-for-testing`: **TEST BUILD SUCCEEDED**; unit and UI bundles compile.
- XCTest execution: not rerun to completion because this environment has repeatedly stalled while materializing Simulator test workers.

## Scores

Scores use the stated evidence denominators rather than subjective completion claims.

- Content completeness: **94.7%** — 18/19 requested surfaces have live top-state evidence.
- Content uniqueness: **89.7%** — 35/39 focused visible route rows have non-repeated labels; the four repeats are shared UI labels, so this is a conservative proxy, not an entity-duplicate count.
- Website validity: **90.9%** — 10/11 browser-opened official pages verified.
- Navigation accuracy: **73.7%** — 39/39 static routes plus 3/18 required runtime flows = 42/57 combined checks.
- Scroll stability: **15.4% coverage** — 2/13 requested long-screen families were executed successfully; unexecuted scenarios are not counted as passes.
- Geo consistency: **92.0%** — static province/city gates pass and Leiden runtime context passes, but multi-city traversal is incomplete.
- Source coverage: **97.5%** — 29 static AI source tuples plus 10/11 live official-source checks = 39/40.
- Media completeness: **100% static** — 294/294 visible assignments are unique and render-gated; current remote availability is not implied.
- Weighted overall readiness: **80.8%**.
- Confidence: **Medium** for static/data integrity; **Low-to-medium** for full runtime readiness.

## Remaining blockers

### Code

- Some legacy HomeView/persona shortcuts still intentionally point at broad practical guides; they need a product decision before changing their semantics.
- Event models do not yet carry enough verified taxonomy to truthfully populate every requested filter such as Music, Markets and Free.

### Data

- 889 literal factual claims were flagged for claim-specific source/date review.
- Full live validation of hundreds of URLs was not executed.
- UWV remains inconclusive in the in-app browser.

### Environment

- XCTest runtime execution is unstable; build-for-testing succeeds, but worker materialization has stalled in prior runs.
- Only iPhone 17 Pro runtime traversal was performed in this pass.

### Backend/business

- Business authentication, moderation, billing and analytics remain local/demo state and must not be represented as production-connected.
- Partner verification is a business process, not something the client can prove solely from local fixtures.

