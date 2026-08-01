# YouNew release report — 2026-07-29

Prepared on 2026-07-28, Europe/Amsterdam

## 1. Executive summary

A local release candidate was implemented across the public/business site, Admin Dashboard, DataProject projections and Supabase contracts. The candidate adds real server-backed form contracts, protected operational Admin flows, deterministic content-sync candidates, immutable retirement of two expired events, release runbooks and browser/package QA.

Production application code and data were not modified. A fresh Hostinger backup was created through the authenticated control panel. The owner accepted the documented Supabase Free-plan security/backup limitations on 2026-07-28. The release remains **NO-GO** because the Supabase migration/functions are not deployed, a restorable manual production database backup and authenticated Admin/sync E2E are absent, and the mixed working tree has no isolated release commit.

## 2. GO / NO-GO

**NO-GO**

Passing local gates do not prove the production business, Admin and sync flows. The exact command `GO LIVE` was not provided, and critical prerequisites remain unresolved.

## 3. System architecture

The detailed map is in `docs/SYSTEM_MAP.md`.

```text
DataProject immutable releases/overlays
  → governed importer
    → iOS runtime JSON
    → public static projection
    → Admin governed projection

Public business/feedback forms
  → Edge validation/rate limiting
    → service-role-only RPC
      → RLS-protected operational tables
        → authenticated Admin

Admin published articles
  → authenticated sync job
    → deterministic candidate artifact + fingerprint
      → manual DataProject/release/deployment gate
```

## 4. Public website

Implemented or verified:

- useful homepage CTAs for web, search, App Store, guides and emergency help;
- 186 published records, 5 city guides and 10 categories;
- Discover, search, Saved, journeys, map, guides, cities, provinces, organizations and places;
- honest iOS listing language without an unverified public version claim;
- real 404, sitemap, robots, manifest and service worker package;
- static homepage without the full Next hydration runtime;
- production status snapshot that distinguishes website availability from undeployed form backends.

Package evidence:

- 230 generated static pages;
- 222 unique sitemap URLs;
- 227 HTML files;
- 16,539 checked internal references;
- exact `out/` and `dist/client/` mirrors;
- 0 missing local assets, secret patterns or public draft/review records.

Current production check:

- 17 required URLs return HTTP 200;
- an unknown URL returns HTTP 404;
- app preview and touch icon return HTTP 200;
- HSTS is absent from current production, while the local `.htaccess` requires it.

## 5. Business website

Implemented:

- advertising, partnership, media, public-interest and other inquiry types;
- organization/contact, location/audience, placement, dates, budget, description, consent and source/UTM fields;
- conditional eight-digit KvK validation for commercial organizations;
- protected endpoint repository with timeout and fail-closed receipt validation;
- user-controlled email draft only as an honest fallback;
- no false success and no automatic fake submission;
- media-kit demonstrations clearly labelled as demo/illustrative.

Production persistence is not available until the migration and `submit-business-inquiry` function are deployed.

## 6. Admin Dashboard

Implemented:

- owner/admin authorization for publication and business operations;
- business inquiry list, detail, actions and PII-reduced export;
- real feedback view without fake production fallback;
- article evidence/reviewer/verification/mapping/media publication gate;
- sync candidate actions and job lifecycle;
- private `/api/workspace/status` endpoint with bearer JWT, `no-store`, `noindex` and fail-closed `503`;
- navigation and protected pages for the new workflows.

Verification:

- ESLint PASS;
- TypeScript PASS;
- 8/8 tests PASS;
- Next production build PASS with 31 routes/pages;
- the current Hostinger Business plan exposes an unused Web App slot and supports Next.js with Node 24, matching the Admin package engine;
- `admin.younew.nl` is the proposed production URL but has not been provisioned;
- authenticated production browser E2E was not executed. It can use an existing approved owner through interactive sign-in, without sharing the password with Codex.

## 7. Supabase schema and RLS

Local migration:

- `admin-dashboard/supabase/migrations/20260728192120_younew_production_operations.sql`;
- 97 PostgreSQL statements;
- SHA-256 `c5c055676cd3cad86a63116ad809f9bc609927829fc82ccb6eb77439840ff69b`.

It adds or hardens:

- article publication evidence/reviewer/media/mapping fields and trigger;
- `business_inquiries`, rate limit and service-role-only submission RPC;
- controlled public feedback fields, rate limit and submission RPC;
- service registry/status/deployment records;
- expanded sync-job lifecycle/idempotency;
- published content artifacts;
- authenticated sync request RPC;
- RLS, grants, function search paths and default privilege revocation.

Connected production facts:

- project `pgdzdxsiagfjioxwuqxf`, `eu-west-1`, PostgreSQL 17.6;
- current project plan: Free;
- existing production migrations stop at `20260727170715_add_foreign_key_indexes`;
- deployed Edge Functions: 0;
- two approved `owner` profiles exist, but no permitted E2E passwords were provided;
- project backups are unavailable on the Free plan;
- security advisor warning: leaked-password protection disabled; the control is Pro-only;
- performance advisor reports informational unused-index findings; indexes were not removed without workload evidence.

Supabase Temporary access is available as a feature preview. The project database build is `17.6.1.147`, above the feature minimum `17.6.1.081`; it can provide a time-limited database-role grant using a Personal Access Token without revealing or resetting the database password. The feature and grant remain disabled pending explicit permission.

## 8. Content workflow

The workflow is documented in `docs/CONTENT_PUBLICATION_WORKFLOW.md`.

Release `amsterdam-v0.1.2` immutably supersedes `amsterdam-v0.1.1`. Pride Walk and Pride Park ended on 25 July and were changed to lifecycle `retired` using official-source evidence; their stable IDs remain auditable but they are absent from public/runtime outputs.

Final governed state:

- 450 governed records;
- 186 published/public records;
- quality score 100%;
- data health healthy with 0 structural issues;
- 15 summary guides;
- 0 full practical guides;
- 20 draft/review guide scaffolds;
- 0 production-ready full guides.

The last two figures are content maturity limitations, not audit-integrity failures.

## 9. Synchronization

The complete contract is in `docs/SYNC_CONTRACT.md`.

Verified locally:

- public/iOS/Admin projections contain the same 186 governed entities;
- iOS and Admin runtime JSON SHA-256 are both `3f2d162b7c67539bd407e17b35072817c023dcc215ba7023b10b0de94029fd86`;
- Admin runtime content fingerprint is `066158d1e248ba544b582ef0a2eaf60648c8e50da04e2ba89d041e707178e2de`;
- content candidate generation is sorted, deterministic and idempotent;
- a failed sync cannot activate or replace working production data.

Production sync was not tested because the migration and `prepare-content-sync` function are absent.

## 10. YouNewWorkspace integration

No separate Workspace repository or callable production integration was found. A precise private contract was implemented at `/api/workspace/status`:

- Supabase JWT required;
- only approved owner/admin roles;
- counters, service state, sync/deployment state and release metadata;
- no service-role browser credential;
- `503` when operational tables are unavailable.

The consuming Workspace URL/credential remains an owner configuration step.

## 11. Security and privacy

Implemented or verified:

- exact-origin CORS allowlists;
- 32 KiB business and 16 KiB feedback body limits;
- repeated server validation and honeypots;
- consent and enumerated-field checks;
- salted, non-reversible rate-limit fingerprints;
- service-role key only inside Edge Functions;
- PII-safe logs/audit and reduced export;
- RLS and least-privilege grants;
- CSP updated locally for the Supabase endpoint;
- privacy page describes the actual proposed processing and fallback;
- 0 known secret patterns in the static package.

Open security items:

- Supabase leaked-password protection is unavailable on Free; the owner accepted this risk on 2026-07-28;
- current production lacks HSTS and uses the old `connect-src 'self'` CSP;
- production RLS/RPC behavior must be retested after migration.

Supabase remediation reference: `https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection`.

The Free-plan acceptance also covers the absence of Supabase-managed backups. It does not waive the requirement for an off-site logical database dump. Recommended compensating controls are strong unique owner/admin passwords, MFA, minimal approved accounts and authentication-log review.

## 12. GitHub CI/CD

Admin CI now runs:

- lint;
- TypeScript;
- 8 tests;
- Deno format/check for all three Edge Functions;
- production build.

Release state:

- branch `admin-dashboard-integration`;
- baseline SHA `66ecc29e5026b85dcee571ad18de3250599ae27f`;
- recorded `origin/main` `2b30f82d353604cd6839f99d53cc08c975bfb3e8`;
- current `origin/admin-dashboard-integration` `76df6ca969927687e1b3a517ac2cecec4b8130f7`; the local branch is four commits behind it;
- `origin/release/younew-web-2026-07-29` exists at `5d26d8c29ceec03cfe05c1685e179cac478c6c6e`, diverges from the Admin branch and overlaps 71 dirty paths;
- local HEAD is two commits ahead of the recorded `origin/main`;
- 185 modified/untracked entries in the shared working tree: 104 in the pre-fix mixed baseline plus 81 attributable to the verified iOS asset fix;
- no commit, push or PR was created to avoid mixing pre-existing user changes.

## 13. Browser and responsive QA

The final local static candidate was checked at:

- 320×568;
- 390×844;
- 430×932;
- 768×1024;
- 1280×800;
- 1440×900.

Across 26 key routes and six viewports:

- 156 route/viewport combinations;
- 0 missing H1;
- 0 horizontal overflow;
- 0 loaded broken images;
- 0 relevant browser console logs.

Interaction checks:

- BSN search resolves to a useful published registration path;
- Save → Saved → Remove works locally;
- journey status updates and reset work locally;
- map city/type/category filters combine and reset;
- empty business and feedback forms fail validation;
- fully valid local form states were reached without submitting test data;
- mobile menu opens and exposes 13 navigation links.

Screenshots:

- `younew-home-390x844.png`;
- `younew-home-1440x900.png`;
- `younew-business-apply-390x844.png`;
- `younew-support-768x1024.png`.

They are stored in the task visualization directory.

## 14. E2E tests

Passed locally:

- public information routes;
- search;
- Saved;
- journey progress/reset;
- map filters/reset;
- public form validation and no-false-success contracts;
- Admin authorization and migration/function contracts;
- deterministic content candidate generation.

Not executed in production:

- persisted business inquiry → Admin list/detail;
- persisted feedback → Admin;
- Admin publish → sync candidate;
- candidate fingerprint → reviewed activation;
- unapproved authenticated Admin denial.

These are blocking, not optional.

## 15. Lighthouse

Lighthouse 13.0.1 was repeated on the final local homepage after stopping orphaned `AssetCatalogSimulatorAgent` processes that had reduced the earlier benchmark index to approximately 1,100:

| Preset | Performance runs | Accessibility | Best Practices | SEO |
|---|---:|---:|---:|---:|
| Standard mobile simulated | 99 / 100 / 100 | 100 | 100 | 100 |
| Desktop | 100 / 100 / 100 | 100 | 100 | 100 |

Mobile metrics across the three runs:

- FCP 904–944 ms;
- LCP 1,129–1,208 ms;
- TBT 0–95 ms;
- CLS 0;
- Speed Index 1,305–1,415 ms;
- benchmark index 2,897.5–3,006.5.

Desktop metrics across the three runs:

- FCP 243–254 ms;
- LCP 263–285 ms;
- TBT 0 ms;
- benchmark index 2,909.5–2,986.

The earlier 66/72 results were host-contention measurements, not reproducible clean-run results. The three-run clean evidence proves the requested standard Performance gate of at least 90.

Evidence:

- `lighthouse-standard-mobile-r1.json`;
- `lighthouse-standard-mobile-r2.json`;
- `lighthouse-standard-mobile-r3.json`;
- `lighthouse-standard-desktop-r1.json`;
- `lighthouse-standard-desktop-r2.json`;
- `lighthouse-standard-desktop-r3.json`.

## 16. iOS simulator build

The `actool` timeout was isolated to 27 city coat-of-arms SVGs larger than 100 KiB. Each was converted to a transparent PNG with a maximum dimension of 1,024 px, its asset metadata was updated, and the original oversized SVG was removed.

Verification:

- complete temporary asset-catalog compile after the replacement: 15.59 s;
- `validate-app-icons.sh`: PASS;
- image render static QA: PASS;
- media static QA: PASS;
- clean Xcode Simulator build/install/launch: PASS in 229.75 s;
- build reported no warnings or errors;
- the installed `nl.younew.app` launched to the Home screen on the configured iOS 26.5 simulator.

## 17. Production artifact

Artifact:

- path: `release-artifacts/younew-public-2026-07-29.tar.gz`;
- contains the contents of `out/`, including `.htaccess` and `.well-known`;
- file count: 522;
- size: 4,762,844 bytes;
- archive SHA-256: `74ef1465e8657a66ee0cd4c43c4023a56e39c38ac3b2674c229c535b7f72dd8c`;
- content fingerprint: `01a412afde506911a4395f71143636a1c09c324cad870c38d6964ac4bd117a97`.

The artifact is local only and was not uploaded.

## 18. Backup and rollback

Prepared:

- `admin-dashboard/scripts/backup-postgres.sh`;
- `docs/DEPLOYMENT_RUNBOOK.md`;
- `docs/ROLLBACK_RUNBOOK.md`;
- static artifact rollback procedure;
- forward-only database compensation policy;
- manual Hostinger backup completed 2026-07-28 12:34;
- backup browser confirmed `domains/younew.nl/public_html`, including the deployed routes/assets and restore/download controls.

Not completed:

- fresh production Postgres dump;
- `pg_restore --list` proof;
- live Hostinger restore rehearsal, because it would overwrite production and no staging restore target was provided;
- live rollback rehearsal.

The connected Supabase project is on Free, which does not include project backups. No secure `DATABASE_URL` or PostgreSQL client tools were available for a manual dump.

The preferred immediate backup path is a short-lived Supabase Temporary access grant, local `libpq` tools, SSL, a mode-`0600` off-site dump, `pg_restore --list` validation and immediate grant/token revocation. Enabling the preview, granting a role and creating a PAT are permission changes and require action-time owner approval.

## 19. Changed files

Current tree summary: 135 tracked status entries and 50 untracked paths, 185 total. The pre-iOS-fix mixed baseline contained 104 entries; the asset fix added exactly 81. Major release-candidate groups:

- DataProject overlay, acceptance lock, release registry and generated reports;
- iOS/Admin/public governed runtime projections;
- public/business/feedback components, repositories, tests and security/build scripts;
- Admin business, feedback, content, sync and workspace endpoint;
- Supabase migration and three Edge Functions;
- CI;
- architecture, workflow, deployment and operations documentation.

The tree also contains pre-existing user changes in iOS/UI-test and public-site files; attribution must be reviewed before commit.

## 20. Commits

No commit was created.

Reason: the shared working tree was already dirty and overlaps release files. Creating a commit without owner review would mix unrelated work. The current baseline is `66ecc29e5026b85dcee571ad18de3250599ae27f`.

## 21. Known limitations

- production form persistence, Admin and sync paths are not active;
- Admin hosting destination is unknown;
- public practical guides remain summary-depth only;
- App Store listing resolves, but its exact public version was not independently verified;
- YouNewWorkspace consumer is not connected;
- no fresh Postgres dump or restore-list proof;
- no live Hostinger restore rehearsal;
- Supabase leaked-password protection and managed backups are unavailable on Free; the owner accepted this documented risk on 2026-07-28;
- local branch/worktree must be reconciled with current `origin/main`.

## 22. Manual owner actions

1. Review and isolate the 185-entry working tree against `origin/admin-dashboard-integration`; resolve the 71-path overlap with the parallel release branch, create the release commit/PR and run CI.
2. Approve `admin.younew.nl` on the existing Hostinger Business Web App slot and plan interactive sign-in with an existing approved owner.
3. Authorize short-lived Supabase Temporary access, create a fresh off-site Postgres dump and validate it with `pg_restore --list`.
4. Review migration dry-run, Edge Function secrets and artifact checksums.
5. Send the exact instruction `GO LIVE` only when the blockers are accepted/resolved.
6. After deployment, execute controlled business, feedback, Admin and sync E2E, then record production deployment IDs and final GO/NO-GO.
