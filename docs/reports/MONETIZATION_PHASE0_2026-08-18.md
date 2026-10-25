# YouNew monetization readiness — Phase 0

Date: 2026-08-18 (Europe/Amsterdam)  
Scope: completed Phase 0 plus review-only Gate 1 content preparation; no production deployment, publication, external message, payment integration, database migration or production write was performed.  
Audited source: `main` at `60accbcb8f8c169e1ef6e09cd7b56824bea6d08e` (`Refresh production status snapshot (#46)`).

## Outcome

Gate 0 is **GO**. The baseline is reproducible, all known failures and unknowns are recorded, the production identity blocker is explicit, the mandatory 50-query scorecard is saved, and the analytics event dictionary is defined.

This is not a GO for Phase 1 completion, commercialization or deployment. Product readiness is currently **NO-GO** against the later gates because there are zero approved full practical guides, the audited production-source baseline has only 31/50 actionable searches, the expanded iOS UI smoke is partial, and a production Supabase table has RLS disabled. A later local, non-publishing candidate reaches 32/50 with public content and 48/50 with the 20 private QA packets; it also improves local mobile Lighthouse from 74/97/77/100 to 90/100/100/100. None of this is deployed product evidence.

## Evidence

### 1. Repository and production identity

- Canonical repository: `https://github.com/zq87xf5jyp-arch/YouNew.git`.
- Default branch and current GitHub head: `main` at `60accbcb8f8c169e1ef6e09cd7b56824bea6d08e`.
- The live service worker has cache version `younew-web-84200d19bb29`; a clean build of the same commit produced the exact value.
- Live `/data/status.json` matches the repository bytes and says that Sites v53 is linked to the green GitHub `main`. It reports 177 published records.
- The prompt's audit label v54 and the hosting provider's Sites v53 are different version namespaces and are not comparable. The live origin exposes no provider-attested deployment SHA. Therefore `60accbcb...` is the high-confidence production source, not a provider-verified deployment identity. The exact blocker is the absence of a SHA-bearing provider deployment record.
- P0 Task 1 follow-up added an immutable production observation, JSON Schema and offline/live verifier. Both verification modes pass for Sites v53, source commit `60accbcb...` and artifact-subset fingerprint `a7e2f4d15d58022341212d3ed39d37e183226f58f46cb8a8cef15157594c90cf`.
- `https://younew.nl`, critical public routes, canonical redirects, the AASA file, a true 404 and security headers were reachable during the audit.
- `https://mta-sts.younew.nl/.well-known/mta-sts.txt` returns STSv1 in testing mode with Hostinger MX hosts and `max_age: 86400`.

The restored workspace contains the canonical product repository under `02-Product` plus rebuilt read-only diagnostics under `08-Automation`. `01-Workspace`, `03-Naruto-Assistant` and `05-Business-and-Portfolio` were not recoverable from iCloud. No shared contract was changed, so the unavailable consumers were not reconstructed or guessed.

### 2. Application map

| Component | Authoritative path | Baseline state |
|---|---|---|
| iOS app | `YouNew/`, `YouNewTests/`, `YouNewUITests/`, `YouNew.xcodeproj` | Release build and all 473 unit tests pass; expanded search UI smoke is partial. |
| Public and business web | `admin-dashboard/public-site/` | Static production package and all 10 predeploy stages pass. |
| Admin | `admin-dashboard/` | Build, lint, typecheck, 42 tests and isolated Playwright suites pass. |
| Governed content | `DataProject/` and generated `YouNew/Resources/Data/younew-runtime-data.json` | 454 governed records and 177 published; 20 exact mandatory source-backed QA packets, but zero human-reviewed or approved full practical guides. |
| Supabase | `admin-dashboard/supabase/` and project `pgdzdxsiagfjioxwuqxf` | Four active Edge Functions; migration and security drift documented below. |
| CI/release | `.github/workflows/`, `docs/DEPLOYMENT_RUNBOOK.md` | CI validates candidates; production activation remains a separately approved manual action. |

### 3. Reproducible baseline matrix

The install/build/test work ran from a clean temporary clone of the exact commit under `/private/tmp`, so generated output and dependencies did not pollute the iCloud source tree.

| Surface / command | Result | Evidence |
|---|:---:|---|
| `scripts/run-static-qa.sh` | PASS | Localization, routes, URLs, Apple contracts, accessibility, performance, search, DataProject and migration-manifest static gates passed. |
| Public frozen dependency install | PASS | 351 packages; lockfile accepted. |
| Admin frozen dependency install | PASS | 424 packages; lockfile accepted. |
| Public `pnpm predeploy:check` | PASS | 10/10 stages; 136 tests; 595 indexable URLs; 602 HTML files; 47,058 internal references; exact `out`/`dist` mirror; true 404; no drafts, secrets or local paths. No deploy occurred. |
| Repository Python tests | PASS | 72/72. The expired fixture warning is an expected negative test. |
| Admin build / lint / typecheck / tests | PASS | 32 routes, lint clean, types clean, 42/42 tests. |
| Admin isolated Playwright | PASS | Two demo-mode tests and one closed-auth test. Chromium was installed only in the user Playwright cache. |
| Search regression matrix | PASS | 2,608/2,608 across 12 provinces and 342 municipalities. |
| Mandatory monetization queries | PARTIAL / FAIL TARGET | Audited baseline 31/50 (62%); current local public-content candidate 32/50 (64%); private QA projection 48/50 (96%). Production remains unchanged. |
| Mandatory practical-guide QA | PARTIAL | Exact 20/20 topic set; 120 sourced facts, 120 steps, 60 FAQ records and 69 unique official URLs. All packets remain non-publishable: 0 reviewers, 0 verified guide assets and 0 passed publication gates. |
| iOS unsigned generic Release build | PASS | Xcode 26.6, iOS 26.5 SDK, `** BUILD SUCCEEDED **`. |
| iOS `YouNewTests` follow-up | PASS | 473 tests in 40 suites; `** TEST SUCCEEDED **`. Catalog coverage is evaluated at the recorded audit date while the current public index continues to exclude stale partner records. Result bundle: `Test-YouNewUnitTests-2026.08.18_18-02-15-+0200.xcresult`. |
| iOS expanded search UI smoke | PARTIAL | 1/4 passed. The localized BSN result contract passed; a duplicate BSN scenario was cold-start flaky, the no-results scenario lost keyboard focus, and the accessibility scenario timed out during first launch. XCTest on iOS 26.5 also reported the 440 x 956 point window as 146.7 x 318.7 (exact 1:3 scaling), while a simulator screenshot confirmed the full-size rendered UI. Result bundle: `Test-YouNewUITests-2026.08.18_18-15-24-+0200.xcresult`. A separate retry was interrupted because the UI-test worker never materialized; it is not counted as a product test. |
| Lighthouse, exact local production package | PARTIAL | Mobile 74/97/77/100; desktop 98/97/77/100 for performance/accessibility/best-practices/SEO. Mobile LCP 5.198 s; desktop LCP 1.075 s. |

The live Lighthouse navigation did not establish `navigationStart`, so scores were collected against the byte-equivalent local production build after the complete predeploy package gate passed. The previous documented mobile performance score of 94 is not treated as current evidence.

A subsequent local source candidate replaced the remote LCP image with its governed local WebP alias, corrected failing contrast tokens and made analytics consent non-modal. One-run Lighthouse results for that non-deployed candidate are mobile 90/100/100/100 and desktop 100/100/100/100. The detailed limitations and remaining Gate 2 blockers are recorded in `docs/reports/MONETIZATION_GATE2_WEB_READINESS_2026-08-18.md`.

### 4. Current data and content inventory

- DataProject: 17 work packages, 7 milestones, 15 releases, 29 batches and 454 records.
- Public projection: 177 published entities: 15 summary guides, 30 organizations and 127 places, plus supporting entities.
- Practical guides: 20 exact mandatory source-backed schema-v2 QA packets, 120 numbered steps and 60 answered FAQ records; 0 human-reviewed, 0 production-ready and 0 approved full guides.
- Search: schema v3, 573 documents, fingerprint `68a0d201921d8ab2c7ef1078422575132c3a202d30bf1e9678f1b39a93802052`.
- Geography: full reference data for 12 provinces, 342 municipalities and 2,502 settlements; editorial coverage is 5 cities and 4 provinces.
- Languages: public web is English only. Dutch, Russian, Ukrainian and Polish are pending review. iOS has 582 matching localization keys in English, Dutch and Russian.
- Data health reports 95.9% quality and no structural issues, but external-link evidence contains zero checked URLs in the current generated snapshot. Freshness is 87.9%; usage coverage is 0.0.

The detailed mandatory-query evidence is in `docs/reports/MONETIZATION_PHASE0_50_QUERY_SCORECARD.md`. The established 2,608-check search matrix remains useful but masks monetization gaps because it checks seven broad guide groups rather than all required user intents.

### 5. Confirmed audit changes

| Prior claim / expectation | Current evidence |
|---|---|
| 177 published entities | Confirmed. |
| 573 search documents | Confirmed. |
| 15 short guides and 0 full practical guides | Confirmed. |
| Five main cities and four editorial provinces | Confirmed, while reference geography is complete nationally. |
| English-only public web | Confirmed. |
| Business inquiry is email-only | Changed: the configured path is API-first with a user-controlled mail fallback. Media-kit copy is stale. |
| Mobile Lighthouse performance 94, accessibility/best practices 100 | Not confirmed at baseline: exact audited package was 74/97/77. A later local candidate is 90/100/100; production is unchanged. |
| iOS unit suite green | Confirmed after remediation: 473 tests in 40 suites pass. Stale partners remain fail-closed. |
| Supabase hardening complete | Not confirmed: one private table has RLS disabled and migration identities drift. |
| Audit label v54 | Reconciled: it is an input-audit label, not a Sites deployment version; production observation is Sites v53. |

### 6. Content → build → deploy chain

1. `DataProject` releases, overlays, evidence and acceptance locks are the governed editorial source.
2. `python3 scripts/import-data-project.py --all-approved` produces `YouNew/Resources/Data/younew-runtime-data.json` after schema, status, reviewer, evidence and release checks.
3. iOS bundles that runtime. Admin generates its governed runtime projection from the same file.
4. The public generator combines the governed runtime with reviewed national-guide, taxonomy and geography inputs, then produces public content, provenance and search-index artifacts.
5. `pnpm predeploy:check` regenerates and validates the static package; `build-sites.sh` prepares the Sites worker-first artifact.
6. GitHub Actions validates candidates but does not prove which SHA the custom domain serves. An approved manual deployment and a SHA-bearing post-deploy record are still required.

No content was published and no release artifact was uploaded in Phase 0.

### 7. Lead → storage → notification chain

1. The public business form calls the `submit-business-inquiry` Edge Function.
2. The function validates origin and fields, applies honeypot/rate-limit controls, stores a salted network fingerprint and calls the service-role-only `submit_business_inquiry` RPC.
3. The RPC writes `public.business_inquiries`; authenticated Admin users can review records. Production has three inquiry rows; no personal data was read or copied for this audit.
4. On an API error, the UI offers a user-initiated email fallback.
5. No automated notification step was found in repository evidence. The media-kit statement that the form is mailto-only contradicts the configured path.

### 8. Measurement map

The detailed contract is in `docs/reports/MONETIZATION_PHASE0_ANALYTICS_EVENT_DICTIONARY.md`.

- Ready: page view, search, empty-result property, official-source click and save on planner/generic content surfaces.
- Existing bounded fallback event: `business_mailto_prepared` is emitted only when a validated API failure produces a user-controlled draft; it does not claim delivery.
- Declared but not emitted: partner click.
- Missing: guide start, guide completion, report-outdated intent, lead start, lead success and pilot request.
- Analytics is consent-gated and excludes raw form text, exact location, advertising IDs and raw free-form search terms.

### 9. Security and privacy baseline

No database or external system was modified. A reviewed local remediation was
prepared after this baseline; see
`docs/reports/SUPABASE_P0_2_SECURITY_REVIEW_2026-08-18.md`.

- Production has 41 tables: 39 in `public` and 2 in `private`.
- Critical production finding: `private.analytics_ingest_windows` has RLS disabled. Local migration `20260818145801` now encodes the server-only policy and 19 pgTAP assertions, but is unapplied.
- The two RLS-enabled no-policy tables were confirmed as intentional server-only state; the pending migration adds explicit restrictive rejection policies.
- Seven authenticated-callable `SECURITY DEFINER` governance functions were classified as intentional guarded Admin RPCs with fixed `search_path`; the advisor warnings remain monitored.
- Supabase Auth leaked-password protection is disabled.
- Four tables have overlapping permissive policies; 38 unused-index notices and one absolute-connection notice were also reported.
- The 24 local and 24 remote migrations had two timestamp identity mismatches despite matching names and bytes:
  - local `20260805173500_normalize_article_search_taxonomy` vs remote `20260805221430_normalize_article_search_taxonomy`;
  - local `20260805223000_expand_privacy_safe_analytics_dashboard` vs remote `20260805231047_expand_privacy_safe_analytics_dashboard`.
  Manifest schema 2 now records both evidence-backed aliases and keeps the new migration in a separate pending list.
- The analytics Edge Function called absent RPC `ingest_analytics_batch_v2`; the local source now calls verified production RPC `ingest_analytics_batch`.
- Four Edge Functions are active. Three public form/analytics endpoints use custom request validation rather than JWT; `prepare-content-sync` requires JWT.
- No local Supabase CLI/Postgres container was available, so pgTAP/local database integration tests were not executed. Connected read-only advisors and repository contract tests were used instead.

## Changed

Phase 0 evidence, read-only verification commands and the P0 Task 1 production-identity contract were added:

- `docs/reports/MONETIZATION_PHASE0_2026-08-18.md`;
- `docs/reports/MONETIZATION_PHASE0_50_QUERY_SCORECARD.md`;
- `docs/reports/MONETIZATION_PHASE0_ANALYTICS_EVENT_DICTIONARY.md`;
- `admin-dashboard/public-site/scripts/monetization-phase0-query-scorecard.mjs`;
- `admin-dashboard/public-site/scripts/check-production-identity.mjs`;
- `admin-dashboard/public-site/tests/production-identity.test.ts`;
- `docs/schemas/production-identity.schema.json`;
- `docs/reports/production-identity/production-observation-2026-08-18.json`;
- `admin-dashboard/public-site/package.json` (`qa:monetization` and production-identity checks);
- `admin-dashboard/public-site/src/config/status.json`, its generated public copy, and `docs/DEPLOYMENT_RUNBOOK.md`.

P0 Task 3 then made verification time explicit in the iOS knowledge pipeline
and its tests. `KnowledgeDataGovernance`, `NetherlandsData` and
`KnowledgeIndexBuilder` now accept a deterministic audit clock. Catalog
completeness is tested at the recorded verification date, while a separate
expiry test proves that stale Rotterdam, Eindhoven and Leiden partner records
remain excluded from the current public index. `BrandAssetTests` now decodes
asset bytes directly, avoiding a blocking CoreGraphics URL read across the
iCloud/Simulator filesystem bridge.

The workspace recovery also rebuilt root diagnostics `08-Automation/status-all.sh` and `08-Automation/verify-structure.sh`; these are outside the product Git repository. No commit was created.

Tasks 4–10 now have an exact, deterministic review-only content set. The prior
Priority-1 queue covered only 14 of the 20 mandatory topics and included six
secondary topics. `DataProject/research/monetization-practical-guide-addendum-2026-08-18.json`
adds official-source research for temporary housing, debt help, SIM/home
internet, diploma recognition, family/school and pets/veterinary care. The
canonical builder now emits the required 20 topics in prompt order. Static QA
proves source closure and blocks runtime projection. The detailed decision is
in `docs/reports/PRACTICAL_GUIDE_QA_2026-08-18.md`.

## Metrics before → after

| Metric | Before Phase 0 | After Phase 0 |
|---|---:|---:|
| Production identity | Assumed audit/version reference | High-confidence commit `60accbcb...`; immutable SHA blocker documented |
| Reproducible mandatory search audit | None | 50 queries; 31 actionable; 7 zero-result |
| Private Gate 1 search projection | None | 20 QA candidates added in memory only: 48/50 actionable, 2 zero-result, 0 invisible location substitutions; no publication |
| Analytics measurement contract | Scattered declarations | 12-signal dictionary defined; page/search/empty/source/save ready, bounded mail-fallback producer wired, 7 required funnel signals missing/deferred |
| Exact mandatory guide QA packets | 14/20 topics covered by the prior queue | 20/20 source-backed schema-v2 QA packets; 0/20 human-reviewed |
| Approved full practical guides | 0 | 0; Phase 1 QA drafting started, but no human review or publication occurred |
| Public production package tests | Unknown for restored tree | 10/10 predeploy stages pass |
| iOS unit baseline | 472 tests; 11 issues disclosed | 473 tests; 0 issues |
| iOS expanded search smoke | Previously 1 targeted pass | 1/4 in the expanded run; UI runner/coordinate defects and one cold-index flake recorded |
| Mobile Lighthouse performance | Previously documented 94 | Audited baseline 74, LCP 5.198 s; later local candidate 90, LCP 3.352 s; production unchanged |
| Production RLS-disabled tables | Unknown | 1 identified; no automatic remediation |

## First 10 P0 tasks

All tasks are source-only until a separate approval authorizes publication, migration or deployment. One person owns each result even when reviewers contribute.

| Order | Task | Owner | Estimate | Dependencies | Acceptance criteria |
|---:|---|---|---:|---|---|
| 1 | **Audit and freeze production identity** — complete 2026-08-18 | Release engineer | 0.5 d | Repository/admin access | A release record names Sites version, full Git SHA, artifact fingerprint and timestamp; live fingerprint is compared; v53/v54 namespaces are reconciled; no deployment. |
| 2 | **Fix Supabase RLS and migration identity drift** — PARTIAL locally 2026-08-18 | Backend security engineer | 2 d | Disposable PostgreSQL/Supabase runtime; database reviewer; production approval | Forward-only migration enables reviewed protection for `private.analytics_ingest_windows`; access tests cover anon/authenticated/service paths; no-policy tables and seven definer functions are classified; local/remote migration identities reconcile. Apply only after separate production approval. |
| 3 | **Restore the iOS content-index baseline** — PARTIAL 2026-08-18 | iOS engineer | 1.5 d | Stable Xcode UI-test worker and simulator coordinate space | The 11 content/index issues are fixed without fabricated partners and all 473 unit tests pass. Catalog-completeness tests use an explicit audited clock; current publication remains fail-closed after verification expiry. Completion still requires a clean targeted UI smoke on a stable runner. |
| 4 | **Create identity and immigration guides (1–3)** — PARTIAL QA packets 2026-08-18 | Senior editor | 2 d | Named human reviewer; IND/gemeente/DigiD sources | BSN/gemeente, DigiD and residence-permit scenarios meet the full guide schema, source/date/owner fields, refusal/escalation paths and search tests; remain review-only. |
| 5 | **Create healthcare and emergency guides (4–6)** — PARTIAL QA packets 2026-08-18 | Health editor | 2 d | Named clinical/content reviewer; Rijksoverheid/Thuisarts sources | Insurance, huisarts and urgent/emergency scenarios pass schema and source validation, distinguish 112/huisartsenpost/GP paths, and contain no individualized medical advice. |
| 6 | **Create housing guides (7–9)** — PARTIAL QA packets 2026-08-18 | Housing editor | 2 d | Tenant-law reviewer; national and municipal sources | Long-term housing, temporary housing and landlord-problem guides provide national fallback, location-safe routing and verified escalation paths; unscoped searches never substitute Amsterdam. |
| 7 | **Create employment guides (10–11)** — PARTIAL QA packets 2026-08-18 | Employment editor | 1.5 d | Employment-law reviewer; UWV/government sources | Work-with-limited-Dutch and contract/payslip guides pass schema, search and source checks; legal limits and rejection paths are explicit. |
| 8 | **Create finance guides (12–14)** — PARTIAL QA packets 2026-08-18 | Finance editor | 2 d | Tax/debt reviewer; Belastingdienst/municipal/bank sources | Taxes/toeslagen, debt help and bank-account guides produce actionable national next steps, pass regulated-content review and remove current zero/category-only outcomes. |
| 9 | **Create connectivity, transport and diploma guides (15–17)** — PARTIAL QA packets 2026-08-18 | Practical-content editor | 2 d | ACM/OV/IDW source checks | SIM/internet, public transport and diploma-recognition guides pass the contract and replace directory-only results with actionable steps. |
| 10 | **Create integration, family and pet guides (18–20)** — PARTIAL QA packets 2026-08-18 | Integration/family editor | 2 d | DUO/gemeente/school/NVWA source review | Language/inburgering, family/children/school-registration and pet/veterinary guides pass schema, source and search tests with national fallback and location-safe escalation. |

After these ten, the mobile Lighthouse/contrast defect and two already-allowlisted consent-safe producers were corrected in the local web candidate. The remaining funnel events require a reviewed shared contract. Guide production still comes first because Gate 1 requires all 20 reviewed scenarios and at least 90% actionable search.

## Remaining gaps and exact blockers

1. The hosting-provider record was unavailable and does not independently attest a deployment SHA; artifact-subset evidence links Sites v53 to `60accbcb...` at high confidence.
2. Human reviewer and guide-evidence registries are empty; all 20 exact mandatory QA packets remain blocked from publication, and all 20 still need verified guide media.
3. The approved full-guide count is 0. The audited production-source baseline is 62%; a local public-content fix reaches 64%, while the private QA projection reaches 96%. The numeric threshold therefore passes only in a non-publishable candidate.
4. The iOS content/index unit baseline is green, but the expanded UI smoke is partial: Xcode UI workers intermittently fail to materialize, iOS 26.5 reports a 1:3 coordinate-space mismatch, and one cold-index BSN assertion was flaky.
5. A private production table still has RLS disabled; the identity drift is reconciled locally and the forward fix remains unapplied pending DB tests and approval.
6. The local web candidate corrects the measured contrast, third-party LCP and consent focus defects and reaches mobile 90/100/100/100; production and field performance remain unverified, and complete tablet/keyboard/screen-reader QA is pending.
7. The measurement funnel is incomplete: guide start/completion, report-outdated intent, partner CTA, lead start/success and pilot request remain missing, and production usage coverage is not established.
8. Automatic inquiry notification is absent; media-kit form copy is stale.
9. `01-Workspace` and `03-Naruto-Assistant` remain unavailable after iCloud recovery, limiting ecosystem-wide inspection if a shared contract is later changed.

## Risks

- Publishing summary content as a practical guide would create legal, medical and immigration trust risk.
- Enabling RLS without tested policies could silently stop analytics ingestion; leaving it disabled weakens defense in depth.
- Treating a non-empty search result as success would hide wrong-city and directory-only failures.
- Using stale Lighthouse or release reports would overstate readiness.
- Starting outreach before guide/search/measurement readiness would test an incomplete product rather than the 90-day pilot hypothesis.

## Decision

**GO — Gate 0. PARTIAL — Gate 1 preparation.** Phase 0 is complete and reproducible; the exact 20-guide QA set now exists. **NO-GO for Gate 1 completion, production publication or commercial launch today.**

## Next smallest useful action

Task 1 is complete. Task 2 has a server-only access decision, a forward
migration, explicit policies, pgTAP coverage, function classification and exact
migration aliases. It remains PARTIAL because this Mac has no disposable
PostgreSQL/Docker runtime and production application has not been authorized.
Task 3 has restored the complete unit baseline without extending stale partner
freshness, but remains PARTIAL until the UI smoke can be rerun on a stable Xcode
worker. Tasks 4–10 now have the exact source-backed QA packets, but remain
PARTIAL until named reviewers, verified media and evidence-registry records are
present. The private search projection is now complete and remains outside the
public index. The next safe product action is named human review of the 20 QA
packets plus source-backed coverage for the two remaining search gaps, Dutch
citizenship and pregnancy/midwife; the database migration must follow its
separate backup/test/approval path.

Plain-language summary: the restored project can be built and audited, the iOS unit suite is green, and the exact 20 useful step-by-step scenarios now exist as review-only QA packets. The private search candidate answers 96% of the required scenarios without wrong-city substitutions, but the product is not ready to sell yet: none of those packets has human approval or verified media, production remains at the audited 62% baseline, one database protection gap exists, and the expanded iOS UI smoke is partial. The correct next move remains a narrow, reviewed 90-day B2B pilot after these P0 foundations—not audience advertising.
