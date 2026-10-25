# Monetization production release gate

Date: 2026-08-18–2026-08-19 (Europe/Amsterdam)

Scope: pre-production validation only

Branch: `agent/monetization-preprod-validation-2026-08-18`

Base commit: `60accbcb8f8c169e1ef6e09cd7b56824bea6d08e`

Initial implementation commit: `879f95b`

Production connection, deployment, migration, payment activation and outreach: **not performed**

## Executive verdict

**PARTIAL — NO-GO for production.**

The locally executable technical gate is green:

- Supabase: **81/81 pgTAP PASS** on a clean disposable PostgreSQL 17.6/Supabase CLI 2.109.1 runtime;
- schema lint: **PASS**, no `public` or `private` schema errors;
- Admin: frozen install, TypeScript, ESLint, **59/59 tests** and production build all **PASS**;
- public site: frozen install, TypeScript, ESLint, **157/157 tests** and **611/611-page production build** all **PASS**;
- visual/accessibility suite: **6/6 PASS** across the six approved routes at desktop and mobile sizes, with 24 screenshots;
- exact five-file offline migration dry-run: **PASS**.

Production remains NO-GO because the approved feature branch could not be published to GitHub from this environment, so there are no independent GitHub Actions run URLs or uploaded CI artifacts. A second risk is documented in the disposable baseline: the raw historical repository chain is not a clean-empty-database fixture without a transparent production-history normalization. Production backup/restore evidence, lead-retention/DPA/aggregate-reporting decisions and a new owner authorization for each production action also remain required.

This report supersedes the earlier point-in-time execution, disposable-validation and visual-review reports for the current gate. Those reports remain historical evidence of what was blocked before the approved pre-production validation.

## 1. Supabase and pgTAP

### Runtime boundary

- Disposable local VM and containers only; all were stopped and deleted after the run.
- Empty schema plus synthetic fixtures only.
- No production URL, project credentials, leads or PII were used.
- No remote migration or deployment command was run.
- Supabase CLI pinned to `2.109.1`; database engine was PostgreSQL `17.6`.

### Assertion result

| Suite | Result |
|---|---:|
| Analytics ingest-window RLS and grants | 19/19 PASS |
| Business-inquiry pipeline and lifecycle | 19/19 PASS |
| Exact-retry deduplication | 13/13 PASS |
| Lead analytics funnel | 12/12 PASS |
| Internal notification inbox | 18/18 PASS |
| **Total** | **81/81 PASS** |

The run also found and corrected one functional defect before the final clean rebuild: an exact retry could return the original row's ID but a new call timestamp rather than the original `created_at`. The RPC now returns the persisted row's complete stable receipt. The final 13/13 deduplication suite proves the stable receipt, one-row behavior, rate-limit accounting and absence of a stored PII fingerprint.

Evidence:

- `admin-dashboard/supabase/ci-artifacts/pgtap-results.tap` — SHA-256 `90cd94d9fa9939cfb4820c90f5ed2883564f0624e3985dc6044a4d587f482c9e`;
- `admin-dashboard/supabase/ci-artifacts/db-lint.log` — SHA-256 `a98725ff9eaabebc8bfb7911353deb65dab44b065278cb0b860bfa0d666287e6`;
- `admin-dashboard/supabase/ci-artifacts/local-migration-list.txt`;
- individual suite logs in `admin-dashboard/supabase/ci-artifacts/`.

Schema lint result: `No schema errors found` for `public` and `private`.

### Disposable baseline qualification

The canonical source migrations were not edited to conceal historical assumptions. The generator `admin-dashboard/scripts/prepare-disposable-supabase-baseline.py` creates an ignored runtime copy and records every normalization with source/runtime hashes in `disposable-baseline.json`:

1. it removes only the production-snapshot guard from `20260727170658_harden_rls_and_function_boundaries.sql` in the generated copy while retaining its DDL;
2. it excludes bootstrap `0006_lock_down_analytics_ingest.sql`, whose transition overlaps that managed migration;
3. it excludes `20260805173500_normalize_article_search_taxonomy.sql`, a bounded data backfill that intentionally requires three pre-existing production articles;
4. it verifies that all five pending migration files are copied byte-for-byte.

This makes the pending-migration test deterministic and auditable, but it does **not** prove that an unmodified `supabase db reset` from the repository can bootstrap an empty database. Before long-term CI or disaster-recovery reliance, approve this normalized baseline as the canonical fixture or replace it with an explicit, reviewed historical fixture.

Evidence: `admin-dashboard/supabase/ci-artifacts/disposable-baseline.json`, SHA-256 `f001ec802352c3b2d82674180f702966ce3c8d2fcce8602b76c4a3f531bc2bda`.

## 2. Five pending migrations and dry-run

The production manifest passes with 24 applied production versions, five reviewed pending versions and six historical bootstrap files.

| Order | Migration | Bytes | MD5 |
|---:|---|---:|---|
| 1 | `20260818145801_harden_analytics_ingest_windows_rls.sql` | 5,294 | `e702afeef312705d2a5bc5a8858da0c4` |
| 2 | `20260818191112_harden_business_inquiry_pipeline.sql` | 8,280 | `716b6222ca3010e4f385082414169440` |
| 3 | `20260818192423_deduplicate_business_inquiry_submissions.sql` | 11,408 | `d3010eb22035a572d0b36a8c522e68a0` |
| 4 | `20260818193310_extend_lead_analytics_funnel.sql` | 12,423 | `220bfa6bddd463acb67a86b31bbea285` |
| 5 | `20260818194626_add_business_inquiry_notification_inbox.sql` | 4,858 | `e9df9c0cbd8828bbe6cfa26f57c5a295` |

Offline production migration dry-run: **PASS** for exact identity, order and the destructive-operation screen. The clean disposable database was rebuilt before this check and listed all five versions as applied. No linked or production dry-run was attempted because that would cross the approved boundary.

Evidence: `admin-dashboard/supabase/ci-artifacts/production-migration-dry-run.txt`, SHA-256 `aea21883e6e6c311064b21fc6658ab6c7e536ae6d04facab1d92e57042f2d7c9`.

## 3. Application verification

### Admin

| Check | Result |
|---|---|
| `pnpm install --frozen-lockfile` | PASS |
| TypeScript | PASS |
| ESLint | PASS |
| Tests | **59/59 PASS** |
| Next.js production build | PASS, 32 routes |

Dependency files stayed unchanged:

- `admin-dashboard/pnpm-lock.yaml` SHA-256 `66ffb06edb7948d7afd24a78425c7ccb1211b6b93953f4e54d42fcd31c0b94bb`;
- `admin-dashboard/package.json` SHA-256 `4c726f9aa87590b742ed9a4b07dab671cbcc57ebd178f88c24543287de8ed97c`.

### Public site

| Check | Result |
|---|---|
| `pnpm install --frozen-lockfile` | PASS |
| TypeScript | PASS |
| ESLint | PASS |
| Tests | **157/157 PASS** |
| Next.js production build | **PASS, 611/611 static pages** |

Dependency files stayed unchanged:

- `admin-dashboard/public-site/pnpm-lock.yaml` SHA-256 `41b651e0fafe72d40458837a3fbb814ebafee9881c472a282eb1ceca41fa569f`;
- `admin-dashboard/public-site/package.json` SHA-256 `5ea59c7b89098f3755a059fbf2126538219203ca8caa9c63384377d6fc302922`.

The build contains all six approved canonical routes:

- `/for-business`;
- `/for-business/pilot`;
- `/for-business/demo-report`;
- `/partners`;
- `/partners/apply`;
- `/partners/apply/success`.

## 4. Visual and accessibility verdict

**PASS locally — no P0 visual or accessibility failure found.**

Playwright ran the production static build through an isolated loopback preview. All external HTTP(S) requests were intercepted, the form used `.test` synthetic data only, and the suite reached a stored-receipt success state without sending a production request.

| Viewport | Result |
|---|---:|
| Desktop `1440×900` | 3/3 PASS |
| Mobile `390×844` | 3/3 PASS |
| **Total** | **6/6 PASS** |

Covered states and assertions:

- six initial route renders, exact price and CTA visibility;
- empty form, validation errors, synthetic filled form and success state;
- analytics consent state and property-free lead analytics;
- partner disclosure and editorial-independence copy;
- keyboard navigation/focus visibility and minimum control sizes;
- computed text contrast checks;
- no horizontal overflow or element overlap at either viewport;
- 308 redirect status, query preservation and canonical destination;
- no submitted PII in analytics payloads or screenshots.

Artifacts:

- 24 PNG files under `admin-dashboard/visual-validation/screenshots/`;
- `admin-dashboard/visual-validation/playwright-results.json` — 6 expected, 0 unexpected, 0 flaky, SHA-256 `931be1dc9dd44bdc6f443e8300c7c9b8738bd6913363114bedb880dcbc8a3218`;
- representative desktop price: `admin-dashboard/visual-validation/screenshots/desktop-1440x900/pilot-price.png`;
- representative mobile validation: `admin-dashboard/visual-validation/screenshots/mobile-390x844/form-validation-errors.png`;
- representative desktop disclosure: `admin-dashboard/visual-validation/screenshots/desktop-1440x900/partners-disclosure.png`;
- representative mobile success: `admin-dashboard/visual-validation/screenshots/mobile-390x844/form-success.png`.

Owner review of the screenshot artifact remains the final brand/public-copy approval; no design was deployed.

## 5. Complete lead-flow evidence

The locally proven path is:

`consent-aware public form → validated Edge/RPC contract → exact-retry deduplication → new inquiry → one safe-reference notification → seven-stage Admin pipeline → authorized CSV export`

Verified properties:

- canonical lifecycle `new → qualified → discovery → proposal → won/lost → archived`;
- a mandatory controlled lost reason and factual detail when required;
- controlled, non-future evidence before `won`;
- one notification per new lead and no second notification for an exact retry;
- notification storage contains safe receipt metadata and no contact/company/message fields;
- analytics accepts only the three reviewed property-free events;
- anonymous/authenticated users cannot invoke the service-only submission and ingest RPCs;
- unapproved authenticated profiles cannot read inquiries or notifications;
- CSV export is owner/admin gated, capped, excludes messages/internal notes and neutralizes spreadsheet formula prefixes.

No real lead, customer claim, invoice, payment, email, LinkedIn message or outreach submission was created.

## 6. Security and privacy verdict

**Technical pre-production controls: PASS. Commercial/legal production readiness: PARTIAL / NO-GO.**

Green technical evidence:

- RLS, grants and service-role boundaries passed their runtime assertions;
- duplicate handling, controlled stages and audit timestamps passed;
- one-notification behavior and notification PII minimisation passed;
- analytics property minimisation passed;
- disposable schema lint and repository static security checks passed;
- tests used no production credentials or real PII;
- success page is non-indexable and legacy commercial routes are permanent redirects;
- no live checkout or payment integration exists.

Open production requirements:

1. approve and implement a lead-PII retention/deletion or anonymisation schedule;
2. finalize controller/processor responsibilities, DPA terms and privacy notice for the pilot;
3. define minimum cohort/aggregation rules that prevent employee-level usage inference;
4. rehearse a lead-specific data access/delete request with disposable data;
5. add lead tables and notification inbox to the incident-response review;
6. approve the legal, tax, VAT, proposal, contract and manual-invoice model;
7. create a fresh encrypted production backup and prove restore into an isolated target before migration.

## 7. CI workflows and run links

Prepared workflows:

- `.github/workflows/supabase-disposable-ci.yml` — exact five migrations, 81 pgTAP assertions, schema lint, dry-run logs and 14-day artifacts;
- `.github/workflows/monetization-visual-validation.yml` — frozen installs, public validation/build, isolated Playwright preview, screenshots and JSON artifacts.

Both YAML files parse locally. Permissions are read-only, production secrets are not referenced, and each workflow supports manual dispatch.

**CI run links: unavailable.** The feature branch and workflows are committed locally, but this environment has no usable GitHub CLI/HTTPS/SSH credentials. The installed GitHub integration also rejected repository writes with `403 Resource not accessible by integration`. Therefore no branch push, workflow dispatch, CI run ID or remote artifact URL was fabricated. This missing independent run is a release-gate blocker even though the equivalent disposable suites passed locally.

## 8. Rollback procedure

The five database migrations are forward-only. Do not auto-rollback by dropping the new table/columns, weakening RLS or reversing mapped audit states.

| Failure point | Safe response |
|---|---|
| Edge fails before database apply | Redeploy the previously recorded Edge bundle; schema is unchanged. |
| Migration transaction fails | Stop, confirm whether a remote migration version was recorded, compare schema and manifest, and do not retry blindly. |
| Database succeeds but Admin fails | Keep lead edits in maintenance mode, retain the compatible Edge, deploy the prebuilt schema-compatible Admin repair/rollback artifact and fix forward. |
| Public release fails | Restore the previous static/worker artifact; retain the compatible database, Edge and Admin. |
| RLS/grant verification fails | Disable public intake at the Edge/public boundary, preserve evidence and apply a separately reviewed forward security migration. Never weaken RLS. |
| Data integrity fails | Stop writes, preserve logs, restore only into an isolated environment, reconcile, and obtain owner approval before any production corrective DML/restore. |

A full database restore is last-resort incident work. It requires a verified encrypted archive, measured recovery point, maintenance window, successful isolated rehearsal and explicit owner approval.

Detailed procedure: `docs/reports/SUPABASE_MONETIZATION_MIGRATION_ROLLBACK_PLAN_2026-08-18.md` and `docs/ROLLBACK_RUNBOOK.md`.

## 9. Known risks and release blockers

| Risk | Severity | Required resolution |
|---|---|---|
| No GitHub Actions run/artifact URLs | Release blocker | Publish the isolated branch with an authorized GitHub identity and manually run both workflows; require matching green results. |
| Raw historical migration chain is not an empty-database fixture | High | Review/approve the documented normalized fixture or create a canonical historical baseline; keep hash evidence. |
| No fresh encrypted production backup/restore rehearsal | Release blocker | Perform only after separate production-access approval, then record checksum, restore result and RTO. |
| Lead retention, DPA and aggregate-reporting rules incomplete | Release blocker | Finalize policy and contract before accepting a pilot or processing usage analytics. |
| No linked production migration-list/dry-run | Expected blocker | Perform read-only verification only after new approval; stop on any drift. |
| Screenshot/brand review not yet recorded by owner | Medium | Review the 24 local/CI screenshots before public deployment. |
| Production environment may differ from disposable runtime | High | Compare versions, advisors, grants, migration history and configuration immediately before an approved release. |

## 10. Exact production deployment actions — prepared, not authorized

Stop before this list. None of these actions were executed by this validation.

1. Obtain Ivan Chernikov's explicit approval for the reviewed commit, screenshot artifact and the exact five migration hashes.
2. Publish the isolated feature branch; run both approved GitHub Actions workflows manually; require 81/81 pgTAP, schema lint, Admin/public checks and visual 6/6 with downloadable artifacts.
3. Resolve or explicitly accept the normalized historical fixture and close the retention/DPA/aggregation/legal/VAT blockers.
4. With separate production-read authorization, compare the linked production migration list to the 24-version manifest and run the pinned linked `db push --dry-run`; stop on any drift or extra file.
5. With separate backup authorization, create an encrypted production backup, verify its SHA-256 and complete an isolated restore rehearsal with recorded RTO.
6. Build Edge, Admin and public artifacts from one reviewed full commit SHA; record fingerprints and prepare the schema-compatible Admin plus public rollback artifacts.
7. With a separate Edge deployment approval, deploy the compatible `submit-business-inquiry` function and verify invalid-payload/CORS/rate-limit behavior without real PII.
8. Pause Admin lead edits. With a separate production-migration approval, apply exactly the five manifest-pinned migrations once, in timestamp order.
9. Deploy the new Admin immediately, verify owner/admin authorization, denial for an unapproved user, stages, lost/won constraints, notification inbox and CSV export.
10. Deploy the six canonical public routes and query-preserving 308 worker; do not enable checkout or payment.
11. With explicit synthetic-smoke approval, submit one labelled test inquiry, verify one receipt/notification and one exact retry with no second notification, then remove or label the record through the reviewed procedure.
12. Verify security headers, consent, analytics minimisation, responsive screenshots, production identity, logs and rollback readiness; record release IDs and artifact hashes.
13. Keep outreach, payment activation and any customer/ROI/result claims disabled until separately approved.

## Final gate

- **GO:** local owner review of implementation, copy, screenshots, migration evidence and rollback plan.
- **PARTIAL:** pre-production technical readiness; all locally executable suites pass, but independent GitHub CI evidence and canonical historical-fixture approval are missing.
- **NO-GO:** production deployment, production migrations, payment activation and external outreach until the blockers above are closed and Ivan authorizes each production action.
