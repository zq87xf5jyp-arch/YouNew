# YouNew — Launch Readiness for 29 July 2026

Checked: 28 July 2026, Europe/Amsterdam

Release branch: `release/younew-web-2026-07-29`

Draft PR: https://github.com/zq87xf5jyp-arch/YouNew/pull/15

Current decision: **NO-GO**

## Confirmed facts

- Production at `https://younew.nl` was not changed during this release-preparation pass.
- The live homepage still shows the older 188-record snapshot and says that the iPhone public download is not confirmed. The release candidate shows 186 published records and links directly to the verified App Store listing.
- The live business form still describes an email-only handoff. The release candidate uses a server-validated Supabase Edge Function and returns success only after a database receipt.
- Public-site `predeploy:check` passed all 10 gates on Next.js 15.5.21.
- Public-site tests: 53 passed, 0 failed.
- Admin tests: 6 passed, 0 failed; ESLint, TypeScript and the 30-route Next.js production build passed.
- `pnpm audit --prod`: no known vulnerabilities after upgrading Next.js to 15.5.21 and overriding Sharp to 0.35.0.
- The static Hostinger package contains 707 regular files plus 270 directory entries, with `index.html` and `.htaccess` at archive root and no `out/` prefix.
- The production Supabase project was `ACTIVE_HEALTHY` when inspected. All 20 tables in its public schema had RLS enabled.
- The new `business_inquiries` migration and Edge Function are prepared but not applied to production.
- YouNewWorkspace branch `codex/services-release-center-20260727` is pushed. PR #2 passed its GitHub gate.
- Hostinger File Manager contains `public_html-rollback-20260728` and `public_html-backup-20260728-pre-release.zip`.

## Assumptions and unverified ownership

- Named service owners are not recorded in the repository. The table therefore uses “not recorded” rather than inventing owners.
- The Hostinger backup names indicate rollback intent, but an actual restore drill has not been performed.
- No continuously hosted Admin Dashboard URL was discovered.
- Universal Links are not confirmed. The iOS app has verified public web URLs, but no associated-domain entitlement or `apple-app-site-association` file was found in this audit.

## Service inventory

| Service | Owner | URL / identifier | Purpose | Source of truth | Deployment / update | Health check | State |
|---|---|---|---|---|---|---|---|
| Public website | Not recorded | https://younew.nl | Public guidance, search, map, saved items, journeys, business pages | `DataProject` → checked runtime JSON → static export | Manual Hostinger upload of `out/` contents | Browser QA, static 404, sitemap and link gates | Live, but older than release candidate |
| iOS application | Not recorded | App Store ID `6782617312` | Native YouNew experience | Xcode project + compatible runtime JSON | App Store Connect, outside this web deployment | App Store listing and Xcode tests | Version 1.1 public; full local simulator suite failed 11 of 551 tests |
| Supabase | Not recorded | Project `pgdzdxsiagfjioxwuqxf` | Auth, operational data and secure inquiry boundary | Versioned SQL migrations | Supabase migrations and Edge Function deploy | Project health, RLS inspection, contract tests | Healthy current schema; new inquiry flow pending |
| Admin Dashboard | Not recorded | Production URL not discovered | Private content, release and inquiry operations | Supabase + checked local runtime | Hosting method not verified | Local production build and protected-route browser test | Candidate only; production config absent |
| YouNewWorkspace | Not recorded | https://github.com/zq87xf5jyp-arch/YouNewWorkspace/pull/2 | Private cross-service release centre | Shared service registry and expected migration matrix | GitHub branch / app build | 192 unit tests and GitHub check | PR gate passed; not merged |
| GitHub | Not recorded | https://github.com/zq87xf5jyp-arch/YouNew | Versioning and CI | Repository | PR merge after required checks | PR checks | Draft PR #15 open |
| Hostinger | Not recorded | `public_html` in File Manager | Static production hosting | Deployment ZIP | Manual upload/extract | Browser production checks | Backup present; candidate not uploaded |
| Support email | Not recorded | `support@younew.nl` | Support and explicit form fallback | Mail provider outside repository | Manual mailbox administration | Mailbox delivery not tested in this pass | Address is linked; end-to-end delivery unverified |

## Architecture boundary

```text
DataProject + Git history
        │
        ├── checked published runtime ──> static website export ──> Hostinger
        ├── checked published runtime ──> iOS local fallback
        └── Admin Dashboard ──> Supabase operational tables
                                      │
                                      └── business inquiry Edge Function

YouNewWorkspace reads release/service evidence; it is not a second content source.
```

## Release gates

| Gate | Evidence | Result |
|---|---|---|
| Production build | 230 generated routes on Next.js 15.5.21 | PASS |
| TypeScript / ESLint | Public and admin commands completed without errors | PASS |
| Public unit/schema tests | 53/53 | PASS |
| Admin business contract tests | 6/6 | PASS |
| Deno Edge Function check | `pnpm dlx deno check supabase/functions/business-inquiry/index.ts` | PASS |
| Internal links/assets/fragments | 16,494 references across 227 HTML files; 0 broken | PASS |
| Sitemap / canonical / 404 | 222 indexable URLs; real runtime 404; exact `out`/`dist` mirror | PASS |
| Secret and package scan | No secret patterns; `pnpm audit --prod` reports no known vulnerabilities | PASS |
| Browser viewports | 320×568, 390×844, 430×932, 768×1024, 1280×800, 1440×900; no homepage overflow or broken images | PASS |
| Browser core interactions | Mobile menu, Escape, navigation, search, map filters/marker/reset, save/remove, profile persistence, journey persistence/reset, form validation and 404 | PASS |
| Search false-redirect protection | `residence permit` now returns an honest empty state instead of Parking permit | PASS |
| Content publication | 15 summary guides, 0 full guides, 0 production-ready guides, no human reviewer | **FAIL** |
| Supabase migration deployment | `20260727234843_business_inquiries.sql` not applied | **PENDING** |
| Business submission E2E | Cannot pass until migration/function/admin are deployed in a controlled environment | **PENDING** |
| Admin CRUD / inquiry E2E | Production Admin URL and environment are not configured | **PENDING** |
| Sync E2E | Controlled publish → export → deploy → iOS availability is not end-to-end automated | **PENDING** |
| Lighthouse targets | Not run in the explicitly selected in-app Browser; no Lighthouse capability is exposed | **PENDING** |
| GitHub required checks | Draft PR checks still running after the dependency-security update | **PENDING** |
| Backup restore drill | Backup exists; restoration not executed | **PENDING** |
| Full iOS simulator suite | 540/551 passed; 11 UI tests failed. Failures cover search focus, typed-category routing/back navigation, one assistant city flow and a 199 ms root-tab sample against a 100 ms threshold | **FAIL** |

## Content readiness

- Governed records: 450.
- Published records in the website runtime: 186.
- Material records: 277.
- Public guides: 15 summary-level, 0 full.
- Draft/review guide scaffolds: 20.
- Production-ready practical guides: 0.
- Research-backed priority topics: 18/20.
- Missing dedicated research dossiers: Dutch integration exams and reporting discrimination.
- Human reviewer: absent.
- Publication authorization: false.
- Current source-health evidence: 2,560 URLs, 0 confirmed broken.

This is the primary reason the release cannot be labelled “site filled 100%”.

## Prepared production package

- Commit represented: `c34ce61209dbda45b1ef82fe57af914c56404707` (short `c34ce61`).
- Content dataset fingerprint: `0997fa89245b53f6d53f59c5f5544a34cd29a8632047bbe25b09a9389c7261cc`.
- Canonical source SHA-256: `45e77f10115a409b12ad8b1c78675cfa91fa7d0fa36f5d742afbbba901591784`.
- Artifact: `artifacts/younew-hostinger-c34ce61-20260728.zip`.
- Artifact SHA-256: `7541723b3535ae1431a6dde350cd92a30c715993d0ebb072d5cd09d191af9471`.
- Archive contents: 707 regular files plus 270 directory entries.
- Production database latest applied migration: `20260727170715_add_foreign_key_indexes.sql`.
- Pending release migration: `20260727234843_business_inquiries.sql`.

The previous generated `2a4827e` ZIP was deleted after the dependency-security rebuild so it cannot be uploaded by mistake. It is reproducible from Git history if needed.

## Rollback

### Website

1. Stop further manual edits in `public_html`.
2. Move the failed release aside with a timestamped name.
3. Restore `public_html-rollback-20260728`, or extract `public_html-backup-20260728-pre-release.zip` into `public_html`.
4. Confirm that `.htaccess` exists at `public_html/.htaccess`.
5. Verify `/`, `/app/`, `/business/apply/`, `/privacy/`, `/robots.txt`, `/sitemap.xml`, `/sw.js` and a missing-page 404.
6. Clear only the Hostinger/CDN cache for the affected site if one is enabled; do not change DNS, MX, SSL or mailbox settings.

### Database and Edge Function

- Before production migration: no database rollback is required.
- After production migration: do not automatically drop the inquiry table, audit data or rate-limit state. First disable the public form or Edge Function, restore the previous website, preserve submitted inquiries, and prepare a reviewed forward-fix or explicit data-preserving rollback migration.

## Manual owner actions required

1. Assign and record service owners.
2. Complete human editorial review and publication evidence for any full practical guide intended for launch.
3. Configure and deploy the private Admin Dashboard with approved Supabase auth and role assignments.
4. Review and apply the pending Supabase migration, rate-limit salt and allowed origins; deploy the Edge Function.
5. Run business submission E2E and confirm receipt, admin visibility, status update, audit entry and Workspace counter.
6. Run admin CRUD and sync E2E.
7. Run Lighthouse on the production candidate and meet 90/95/95/95.
8. Complete the GitHub checks and the backup restore drill.
9. Fix and rerun the 11 failed iOS UI tests; do not treat the green unit-test CI job as a substitute for the failed full simulator suite.
10. Re-run production checks after deployment.

Production deployment remains blocked until all mandatory gates pass and the owner sends the exact command `GO LIVE`.
