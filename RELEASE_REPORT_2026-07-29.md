# YouNew release report — 2026-07-29

Prepared on 2026-07-28, Europe/Amsterdam

## 1. Executive summary

A local release candidate was implemented across the public/business site, Admin Dashboard, DataProject projections and Supabase contracts. The candidate adds real server-backed form contracts, protected operational Admin flows, deterministic content-sync candidates, immutable retirement of two expired events, release runbooks and browser/package QA.

Production application code, schema and data were not modified. SSL enforcement was enabled with the authorized brief database restart, after which the project returned `ACTIVE_HEALTHY`. Fresh Hostinger and custom-format PostgreSQL backups now exist. The owner accepted the documented Supabase Free-plan security/backup limitations on 2026-07-28. A clean local release branch contains isolated commits with no push. The release remains **NO-GO** because the Supabase migration/functions are not deployed and authenticated Admin/sync E2E are absent.

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
- `admin.younew.nl` is the owner-approved production URL but has not been provisioned;
- authenticated production browser E2E was not executed. The owner authorized an existing approved owner to sign in interactively, without sharing the password with Codex.

## 7. Supabase schema and RLS

Local migration:

- `admin-dashboard/supabase/migrations/20260728075522_younew_production_operations.sql`;
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

Supabase Temporary access preview and project-level Temporary access were enabled. The project database build is `17.6.1.147`, above the feature minimum `17.6.1.081`. After explicit owner approval, SSL enforcement was enabled; the authorized database restart completed and the project returned `ACTIVE_HEALTHY`. A current owner received only `supabase_read_only_user` until 28 July 2026 14:02 Europe/Amsterdam. A one-hour PAT was used only from process memory over `sslmode=verify-full`. After the dump, the PAT and rule were deleted, the PAT variable was cleared, and a repeat connection attempt was rejected.

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

- clean worktree: `/Users/ivan/Desktop/Developer:YouNew/YouNew-release-clean-2026-07-29`;
- branch: `release/younew-production-2026-07-29`;
- base: `76df6ca969927687e1b3a517ac2cecec4b8130f7` (`origin/admin-dashboard-integration`);
- release candidate: `8566a228ea703db2280e153bf57ce1cad37e99c9`;
- iOS asset optimization: `cadf8e7f00293172e1971801419bd5f70714b3a7`;
- the release worktree was clean after both commits and was two commits ahead of its base;
- no commit was pushed and no PR was created;
- the original mixed worktree remains separate at HEAD `66ecc29e5026b85dcee571ad18de3250599ae27f` with 187 status entries;
- four Admin contract test files were made trackable by narrowing `.gitignore`; the verified 8/8 Admin result now represents committed tests rather than an empty test glob.

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
- Homebrew `libpq` 18.4;
- mode-`0700` directory `/Users/ivan/Library/Application Support/YouNew/backups`;
- mode-`0600` custom-format dump `younew-pgdzdxsiagfjioxwuqxf-20260728T113724Z.dump`, 306,563 bytes;
- `PGDMP` signature and `pg_restore --list` PASS with 564 catalog entries, including 55 table-data and 11 schema entries;
- SHA-256 `1156df801833aed5c0d16aabc5843b79f9bcb664edebf968bcc12d7b9af744f7`, independently reproduced with `shasum`;
- mode-`0600` restore-list and SHA-256 sidecar evidence;
- `verify-full` TLS using the Supabase production CA;
- post-backup PAT deletion, role-rule deletion and failed revoked-credential connection test.

Not completed:

- live Hostinger restore rehearsal, because it would overwrite production and no staging restore target was provided;
- live rollback rehearsal.

The connected Supabase project is on Free, which does not include managed project backups. The manual logical-backup compensating control is now satisfied. SSL enforcement remains enabled as a security improvement; Temporary access remains enabled but has zero rules and no PAT exists.

## 19. Changed files

The clean release worktree contains the isolated release changes in two commits and was clean after commit. The original shared worktree remains separate with 187 status entries. Major release-candidate groups:

- DataProject overlay, acceptance lock, release registry and generated reports;
- iOS/Admin/public governed runtime projections;
- public/business/feedback components, repositories, tests and security/build scripts;
- Admin business, feedback, content, sync and workspace endpoint;
- Supabase migration and three Edge Functions;
- CI;
- architecture, workflow, deployment and operations documentation.

The release commit intentionally preserves the complete candidate transferred from the mixed source tree. Owner review is still required before any push because some iOS/UI-test and public-site edits predated this release audit.

## 20. Commits

Created locally without push:

- `8566a228ea703db2280e153bf57ce1cad37e99c9` — `Prepare YouNew production release candidate`;
- `cadf8e7f00293172e1971801419bd5f70714b3a7` — `Optimize city coat-of-arms assets for iOS builds`.
- `59e49c077ed7a4916a67903ad76cb50ce044de99` — `Document release evidence and remaining SSL backup gate`.

This backup evidence update is committed separately as the fourth local commit. The branch is based directly on current `origin/admin-dashboard-integration`, so the original dirty worktree did not need to be reset, stashed or committed.

## 21. Known limitations

- production form persistence, Admin and sync paths are not active;
- `admin.younew.nl` is approved but not provisioned;
- public practical guides remain summary-depth only;
- App Store listing resolves, but its exact public version was not independently verified;
- YouNewWorkspace consumer is not connected;
- no live Hostinger restore rehearsal;
- Supabase leaked-password protection and managed backups are unavailable on Free; the owner accepted this documented risk on 2026-07-28;
- remote CI has not run because the clean release branch is intentionally local-only.

## 22. Manual owner actions

1. Review the four clean local commits; authorize push/PR separately if desired.
2. Review migration dry-run, Edge Function secrets and artifact checksums.
3. Send the exact instruction `GO LIVE` only when the remaining deployment blockers are accepted.
4. During deployment, provision `admin.younew.nl`, then use interactive owner sign-in for controlled business, feedback, Admin and sync E2E; record production deployment IDs and final GO/NO-GO.
