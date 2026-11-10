# YouNew Geo Relevance and Action-First UX — Release Gate

Date: 2026-08-19  
Scope: local pre-production implementation and validation only  
Production deployment: **not performed**  
Production migrations: **not performed**

## Executive verdict

**PARTIAL — application gate GO; production gate remains NO-GO until owner-approved disposable database validation, production migration approval, and deployment approval.**

The user-visible P0 acceptance criteria are met locally. An explicit Leiden query no longer admits Amsterdam-only organizations: the approved 144-scenario city/intent matrix recognized 144/144 cities, produced zero wrong-city organizations in top five, and preserved a useful local, municipal, national, remote, or emergency route. Public tests pass 170/170; Admin tests pass 67/67; TypeScript, ESLint, and both production builds pass.

The remaining production blocker is operational rather than a known ranking defect. Migration `20260819080242_allow_geo_relevance_analytics.sql` is prepared but was intentionally not applied or executed against a disposable database because this release explicitly forbids migrations. Until that validation and a separately approved production rollout occur, the new consent-based geo events must not be treated as production-ready ingestion evidence.

## Confirmed root cause

Three existing behaviors combined to create the Leiden defect:

1. When a city filter or saved city already existed, query location inference was skipped, so an explicit city in the query could lose to earlier state.
2. Geography was a scoring adjustment rather than an admissibility rule. A wrong-city organization could retain enough textual relevance to remain in the results.
3. The current organization dataset is Amsterdam-heavy, which amplified the ranking weakness and made Amsterdam behave like a practical hidden default for some broad queries.

No second search engine was added. The existing normalization, taxonomy, ranking, generated index, and search UI were extended.

## Ranking flow after the change

1. Normalize query text without storing the raw query in analytics.
2. Resolve exact city/municipality aliases first, then bounded deterministic typo matches. The resolver supports Dutch, English, and Russian aliases; it does not depend on an LLM.
3. Select geography in strict order: explicit query city → current selected city → saved city → national fallback.
4. Apply geographic admissibility before scoring:
   - allow the requested city/municipality;
   - allow national, province-applicable, explicitly matching service-area, online, and remote content;
   - exclude an organization from another city unless its structured service area covers the requested city.
5. Rank only the admissible set. Partner or sponsor status is not a factual ranking signal.
6. Keep national guidance and the municipality route adjacent to the useful local action.
7. If verified local data is absent, show the exact honest fallback and official next actions rather than padding with Amsterdam organizations.

## Before / after: “I need a GP in Leiden”

### Before

Baseline replay of the pre-change ranking returned:

1. national healthcare guidance;
2. healthcare category;
3. emergency guidance;
4. ACTA — Amsterdam-only organization;
5. Amsterdam UMC — Amsterdam-only organization.

Wrong-city rate for this top five: **2/5 (40%)**. The wider result set contained ten Amsterdam-local organizations.

### After

The same query resolves Leiden deterministically and produces a top group containing national healthcare guidance, the official Leiden municipality route, healthcare guidance, and emergency guidance. Amsterdam-only organizations are excluded.

Wrong-city rate for this top five: **0/5 (0%)**.

## Search and regression evidence

| Check | Result | Gate |
| --- | ---: | --- |
| Required city/intent scenarios | 144 (12 cities × 12 intents) | PASS |
| Explicit city recognition | 144/144 (100%) | PASS; threshold ≥95% |
| Wrong-city organizations in top five | 0 across the 144-scenario matrix | PASS |
| Query city vs conflicting saved/selected city | query city wins | PASS |
| Leiden typo and Russian alias | deterministic Leiden resolution | PASS |
| Hidden Amsterdam default without city | 0 | PASS |
| Service-area / online / remote admission | only from structured scope | PASS |
| Partner status affecting factual rank | no | PASS |
| Emergency availability | preserved | PASS |
| Saved exhaustive search QA | 2,608/2,608 | PASS |
| Public tests | 170/170 | PASS |
| Admin tests | 67/67 | PASS |

The saved QA matrix covers all 12 provinces and 342 municipalities. Debt-help, legal-help, veterinarian, huisarts/GP, gemeente, zorgverzekering, registration, benefits, DigiD, housing, work, hospital, and language-learning vocabulary are covered by the deterministic taxonomy and scenario matrix.

## Action-first guide evidence

An Action Panel is rendered before detailed content for the seven P0 guide categories: housing, work, documents/BSN, healthcare, education, telecom, and rules. It includes a task title, city selector, direct short answer, one primary next action, official CTA(s), verification date, official-source count, warning, and advice boundary. Existing detailed guide content remains in place.

The city selector reads `?city=` after hydration, preserving the existing static export. The BSN example with Leiden opens the official Leiden registration route and the national NetherlandsWorldwide BSN source.

## Visual and accessibility validation

Browser validation used the local static preview only; production was not contacted for form or analytics operations.

| Surface | Viewport | Evidence |
| --- | --- | --- |
| Search with Leiden | 1440×720 | first result top 498 px / bottom 664 px; visible without scrolling; no horizontal overflow |
| Search with Leiden | 390×844 | first result top 571 px / bottom 836 px; visible; filters above results; no horizontal overflow |
| BSN Action Panel | 1440×900 | panel top 161 px / bottom 599 px; fully visible |
| BSN Action Panel | 390×844 | panel top 291 px / bottom 685 px; fully visible |
| Homepage light/dark | 1440×900 | explicit switch visible; hero 651 px; no horizontal overflow |

Runtime console errors/warnings: **0** on the validated surfaces.

Contrast ratios measured against the dark page background:

- search H1: 18.16:1;
- search introduction: 11.71:1;
- city supporting text: 7.57:1;
- result heading: 18.16:1;
- result metadata: 7.57:1.

The focused search input has a visible 3 px dark separation ring plus 3 px cyan outer ring. Accessible names and screen-reader labels pass automated source/runtime tests. Keyboard/focus contracts pass automated tests; the browser automation API did not provide a reliable complete manual Tab-sequence traversal, so that narrow manual check remains a pre-deployment owner QA item rather than an unqualified claim.

Screenshots:

- `/Users/ivan/.codex/visualizations/2026/08/19/younew-geo-release/desktop-search-leiden-1440x720.png`
- `/Users/ivan/.codex/visualizations/2026/08/19/younew-geo-release/mobile-search-leiden-390x844.png`
- `/Users/ivan/.codex/visualizations/2026/08/19/younew-geo-release/desktop-search-honest-fallback-1440x720.png`
- `/Users/ivan/.codex/visualizations/2026/08/19/younew-geo-release/desktop-bsn-action-panel-1440x900.png`
- `/Users/ivan/.codex/visualizations/2026/08/19/younew-geo-release/mobile-bsn-action-panel-390x844.png`
- `/Users/ivan/.codex/visualizations/2026/08/19/younew-geo-release/desktop-home-light-1440x900.png`
- `/Users/ivan/.codex/visualizations/2026/08/19/younew-geo-release/desktop-home-dark-1440x900.png`

## Test and build results

| Target | Result |
| --- | --- |
| Public TypeScript | PASS |
| Public ESLint | PASS, zero warnings |
| Public tests | PASS, 170/170 |
| Public production build | PASS, 611 static pages exported and Hostinger package generated |
| Admin TypeScript | PASS |
| Admin ESLint | PASS, zero warnings |
| Admin tests | PASS, 67/67 |
| Admin production build | PASS, 32 routes |
| Monetization routes, CRM and lead contracts | PASS within public/Admin suites |
| `git diff --check` | PASS |

The initial shell-only rerun failed because the desktop shell no longer exposed `node` in `PATH`; rerunning with the bundled Codex Node/pnpm runtime produced the PASS results above. This was an environment-path issue, not a test regression.

## Consent-based analytics

The client emits only after consent and retains only bounded properties: normalized city, intent ID, source/content ID, and bounded action duration. It does not send the raw search text, names, email, phone, IP, or free-form content.

New event contracts:

- `explicit_city_detected`;
- `city_filter_applied`;
- `city_filter_corrected`;
- `local_result_available`;
- `national_fallback_shown`;
- `wrong_geo_result_reported`;
- `action_panel_cta_clicked`;
- `time_to_first_action`.

The requested click meanings map to the existing canonical events `search_result_opened` and `official_source_click`; duplicate event names were intentionally not introduced. The pending migration extends the server allowlist while retaining the hardened authorization, RLS, batch, property, and value bounds.

## Relevant changed files

- `admin-dashboard/public-site/src/lib/search/geography.ts`
- `admin-dashboard/public-site/src/lib/search/rank.ts`
- `admin-dashboard/public-site/src/lib/search/taxonomy.ts`
- `admin-dashboard/public-site/src/components/search-experience.tsx`
- `admin-dashboard/public-site/src/components/national-guide-action-panel.tsx`
- `admin-dashboard/public-site/src/components/tracked-official-source-link.tsx`
- `admin-dashboard/public-site/src/app/essentials/[slug]/page.tsx`
- `admin-dashboard/public-site/src/app/globals.css`
- `admin-dashboard/public-site/src/lib/analytics/client.ts`
- `admin-dashboard/public-site/scripts/generate-public-content.mjs`
- `admin-dashboard/public-site/public/data/search-index.json`
- `admin-dashboard/public-site/public/sw.js`
- `admin-dashboard/public-site/tests/geo-relevance.test.ts`
- `admin-dashboard/public-site/tests/analytics.test.ts`
- `admin-dashboard/tests/geo-relevance-analytics-contract.test.ts`
- `admin-dashboard/supabase/migrations/20260819080242_allow_geo_relevance_analytics.sql`
- `admin-dashboard/supabase/production-migration-manifest.json`
- `docs/reports/SEARCH_QA_MATRIX.json`
- `docs/reports/SEARCH_QA_MATRIX.md`
- `docs/reports/YOUNEW_GEO_RELEVANCE_RELEASE_GATE_2026-08-19.md`

Unrelated pre-existing dirty and untracked workspace files were preserved and were not committed, reset, or deleted.

## Remaining risks and required gates

1. The new SQL migration has contract tests but has not been applied to a disposable Supabase database in this release. A real migration apply plus pgTAP/API rejection tests are mandatory before production.
2. The governed organization dataset is still Amsterdam-heavy. The new eligibility rule prevents wrong-city leakage, but honest local fallback will remain common until verified service areas and local organizations are added through governance.
3. Generated `serviceAreaCityIds` are empty unless explicitly governed. Do not infer them from organization names or marketing text.
4. A complete manual keyboard traversal remains recommended before owner approval, even though labels, focus CSS, contrast, and automated accessibility contracts pass.
5. No staging or production deployment was performed, so CDN, production headers, cache invalidation, and production analytics ingestion are not evidenced by this local gate.

## Exact production deployment plan — do not execute without new approval

1. Ivan Chernikov approves the reviewed diff, exact commit, migration window, rollback owner, and production deployment.
2. Capture and verify the existing encrypted production database backup, migration manifest, current static artifact identifier, and rollback point. Complete the already defined disposable restore drill; never test restore against production.
3. In an isolated Supabase stack with synthetic data, apply every pending migration in manifest order:
   1. `20260818145801_harden_analytics_ingest_windows_rls.sql`
   2. `20260818191112_harden_business_inquiry_pipeline.sql`
   3. `20260818192423_deduplicate_business_inquiry_submissions.sql`
   4. `20260818193310_extend_lead_analytics_funnel.sql`
   5. `20260818194626_add_business_inquiry_notification_inbox.sql`
   6. `20260818235619_enforce_monetization_retention_and_private_reports.sql`
   7. `20260819080242_allow_geo_relevance_analytics.sql`
4. Run all pgTAP suites and explicitly prove acceptance of every new bounded geo event plus rejection of raw queries, unknown keys, overlong values, PII-shaped properties, unauthorized callers, and cross-client data.
5. Re-run public/Admin TypeScript, ESLint, tests, builds, secret scan, dependency audit, and the 144-scenario geo matrix on the reviewed commit. Any failure stops the rollout.
6. Apply the approved production migrations through the existing documented migration process. Capture checksums and schema evidence; do not use ad-hoc SQL.
7. Deploy the exact reviewed public static artifact through the existing approved Hostinger mechanism. Do not enable payments, outreach, or unrelated feature flags.
8. Smoke-test `/`, `/search/?q=I%20need%20a%20GP%20in%20Leiden`, the BSN guide with `?city=leiden`, emergency, the six approved monetization routes, lead submission with approved synthetic validation data, Admin login, and CRM status flow.
9. Verify consent-off produces no analytics request; consent-on accepts bounded synthetic geo events and rejects an invalid property. Confirm no PII appears in logs or artifacts.
10. Monitor error rate, zero-result rate, honest-fallback rate, analytics rejection rate, and cache behavior during the approved observation window. Ivan records final GO or triggers rollback.

## Rollback plan

Rollback triggers: any wrong-city organization in top five, city-precedence failure, P0 accessibility regression, failed migration assertion, analytics privacy rejection bypass, lead/CRM regression, elevated server/client errors, or an unrecoverable cache mismatch.

1. Stop the rollout and prevent further production changes.
2. Restore the previously recorded static artifact and invalidate only the affected cache paths through the approved hosting workflow.
3. For the additive analytics function change, restore the captured pre-migration `public.ingest_analytics_batch` definition from the verified backup/migration baseline and re-run grants/RLS checks. Do not perform a broad destructive database restore for a function-only issue.
4. If another migration changed state, use its reviewed rollback procedure or restore into a disposable environment first. A production restore requires a separate explicit owner decision.
5. Re-run the Leiden smoke test, consent-off test, CRM smoke test, and security checks before reopening traffic.

Rollback owner and final production authority: **Ivan Chernikov**. Technical execution support: **Codex**, only after explicit per-action approval.
