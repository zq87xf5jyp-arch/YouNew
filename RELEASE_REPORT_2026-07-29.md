# YouNew Release Report — 29 July 2026

Prepared: 28 July 2026, Europe/Amsterdam

Release branch: `release/younew-web-2026-07-29`

Draft PR: https://github.com/zq87xf5jyp-arch/YouNew/pull/15

## 1. Executive summary

The release candidate now connects the public website, App Store listing, protected business-inquiry backend, Admin Dashboard and YouNewWorkspace release boundary. The public static export passes its complete local 10-stage predeploy pipeline. The Admin Dashboard builds and its business security contracts pass. Browser QA covers the main web journeys and all required responsive breakpoints.

Production was intentionally not modified. The live homepage and live business form remain older than the candidate. Mandatory content, deployment and end-to-end gates remain incomplete.

## 2. GO / NO-GO

**NO-GO**

Blocking conditions:

1. Human editorial review is absent; 0 full practical guides are production-ready.
2. The business migration and Edge Function are not deployed to Supabase production.
3. The Admin Dashboard has no verified production URL/configuration.
4. Business submission, admin visibility, audit, Workspace counter and sync E2E cannot pass before controlled deployment.
5. Lighthouse 90/95/95/95 evidence is absent.
6. GitHub checks after the final dependency-security commit are not yet all complete.
7. The backup exists but restore has not been tested.
8. The long-running full iOS simulator/UI suite has not produced a final result bundle yet.

## 3. Production URLs

| URL | Observed production state | Release-candidate state |
|---|---|---|
| https://younew.nl/ | Live; older homepage says iPhone download is unconfirmed and shows 188 records | Direct App Store CTA; 186 checked published records |
| https://younew.nl/app/ | Live App Store links to ID `6782617312` | Same verified link, version 1.1 copy |
| https://younew.nl/business/ | Live | Connected to map, inquiry flow and App Store |
| https://younew.nl/business/apply/ | Live email-oriented form; no secure backend claim | Server-validated Supabase submission with receipt-only success |
| https://younew.nl/status/ | Static status snapshot dated 27 July | Static snapshot dated 28 July with Supabase, inquiries and admin-sync limitations |
| https://younew.nl/privacy/ | Live | Updated to match local browser data and business-inquiry processing |
| https://younew.nl/terms/ | Live | Verified in static export |
| https://younew.nl/definitely-missing-page/ | Branded 404 | Branded 404 |
| App Store | https://apps.apple.com/app/id6782617312 | Verified in config, HTML and browser QA |
| Admin Dashboard | Not discovered | Local production build only |

## 4. Architecture

The implementation keeps one controlled content pipeline:

```text
DataProject + Git governance
        │
        ├── published runtime JSON ──> website static export
        ├── published runtime JSON ──> iOS local fallback
        └── Admin Dashboard ──> Supabase operational data
                                     ├── business inquiries
                                     ├── audit log
                                     └── future sync jobs/status

YouNewWorkspace consumes release/service evidence and expected migrations.
```

The website remains static for Hostinger. Anonymous business submissions go through one Edge Function; the browser never receives a service-role key. Draft/review content remains excluded from the public export, search and sitemap.

## 5. Content coverage

| Measure | Result |
|---|---:|
| Governed records | 450 |
| Material records | 277 |
| Published runtime records | 186 |
| Public summary guides | 15 |
| Public full practical guides | 0 |
| Draft/review guide scaffolds | 20 |
| Production-ready practical guides | 0 |
| Priority topics with research dossiers | 18/20 |
| Human reviewer | Absent |
| Publication authorization | False |
| Link evidence | 2,560 URLs, 0 confirmed broken |

Known research gaps: Dutch integration exams and reporting discrimination. Explicit content gaps also remain for finding work, opening a bank account and student housing. The candidate does not publish these drafts as complete guides.

## 6. Public-site QA

Command:

```bash
cd admin-dashboard/public-site
pnpm audit --prod
pnpm predeploy:check
```

Results:

- Next.js 15.5.21 production build: 230 routes.
- Unit/schema tests: 53 passed, 0 failed.
- Static smoke test: passed.
- Sitemap: 222 indexable URLs.
- Link/fragment/asset inspection: 16,494 references across 227 HTML files; 0 broken.
- 404 runtime: passed.
- `out/` and `dist/client/` exact mirror: passed.
- Secret patterns, localhost paths and draft leakage: none found.
- `pnpm audit --prod`: no known vulnerabilities.
- Service worker, manifest, icons, revalidation `.htaccess` and offline shell: passed.
- Per-entity local images and attribution: 186 published entities covered by distinct card-image assignments.

Browser QA in the selected in-app Browser:

- Viewports: 320×568, 390×844, 430×932, 768×1024, 1280×800 and 1440×900.
- Homepage at all six viewports: one `h1`, zero horizontal overflow, zero broken loaded images.
- Mobile menu: opens, Escape closes it, route navigation closes it.
- Key routes checked: homepage, discover, search, guides, one summary guide, journeys, map, saved, app, status, support, business, business apply, privacy, terms and 404.
- Search form and URL state: working.
- Map filter example: Amsterdam + organization + healthcare produced 10 visible items and matching URL parameters; marker keyboard activation selected Arkin; reset returned 171 coordinate-backed items.
- Save/remove: `!WOON` persisted after reload and was removed without clearing other saved items.
- Journey: first step persisted as “In progress” after reload and reset to “Not started”.
- Discover profile: Tourist recommendations persisted after reload.
- Business form: empty submit showed validation errors and did not show false success.
- Final preview console: no relevant warning/error entries on the checked homepage state.

Saved visual evidence:

- `artifacts/browser-home-390x844.jpg` — release-candidate homepage, mobile viewport.
- `artifacts/browser-home-1440x900.jpg` — release-candidate homepage, desktop viewport.
- `artifacts/browser-admin-login-1280x720.jpg` — local production Admin Dashboard login.

Search acceptance:

- Positive: BSN, “How do I get a BSN?”, huisarts, health insurance, renting a home, landlord repair, emergency, 112 and student housing.
- Honest empty states: DigiD, work contract and residence permit.
- A false `residence permit` → `Parking permit Amsterdam` match was found in browser QA, fixed in ranking, covered by regression test and rechecked.

## 7. Business flow QA

Implemented:

- browser validation and server validation;
- maximum 16 KB JSON body;
- allowed-origin enforcement;
- typed inquiry and placement enums;
- honeypot;
- consent and authorization confirmations;
- pseudonymous salted-IP hourly rate limit;
- database insert through a service-role-only RPC;
- no browser service-role key;
- opaque reference in `YN-XXXXXXXXXXXX` form;
- success only after a confirmed insert;
- values preserved after delivery errors;
- explicit prefilled-email fallback that never claims submission;
- admin owner/admin authorization repeated in the server action;
- status and admin-note update;
- database audit trigger.

Evidence:

```bash
cd admin-dashboard
pnpm test
# 6 passed, 0 failed

pnpm dlx deno check supabase/functions/business-inquiry/index.ts
# passed
```

Not passed:

- real production insert;
- confirmation receipt from production;
- production Admin Dashboard visibility;
- production status update and audit entry;
- Workspace open-inquiry counter.

Those are blocked because the release migration/function and private Admin Dashboard are intentionally not deployed before `GO LIVE`.

## 8. Admin QA

Commands:

```bash
cd admin-dashboard
pnpm test
pnpm lint
pnpm typecheck
pnpm build
```

Results:

- 6/6 tests passed.
- ESLint: passed.
- TypeScript: passed.
- Next.js 15.5.19 production build: 30 routes, including `/business-inquiries`.
- Login page has one semantic `h1`.
- `robots` metadata: `noindex, nofollow, nocache`.
- Response configuration includes `X-Robots-Tag: noindex, nofollow, noarchive`.
- Direct local access to `/business-inquiries` without configuration redirected to `/login?error=configuration`.
- Login form exposes email/password fields without enabling a demo mode in production.
- Logout exists.
- Password reset is not implemented; the requirement applied only if already provided.

Unverified: production Supabase auth, approved role records, session persistence, production CRUD, production inquiry queue and hosted admin URL.

## 9. Supabase and RLS

Confirmed production observations:

- Project: `pgdzdxsiagfjioxwuqxf`.
- Health: `ACTIVE_HEALTHY`.
- PostgreSQL: 17.6.1 at inspection time.
- Public-schema tables: 20.
- RLS enabled: 20/20.
- Applied migrations:
  - `20260727170658_harden_rls_and_function_boundaries.sql`
  - `20260727170715_add_foreign_key_indexes.sql`
- Password leaked-credential protection: disabled warning.
- Performance advisor: 17 unused-index informational findings.

Pending release migration:

```text
20260727234843_business_inquiries.sql
```

The migration creates an isolated inquiry table, private rate-limit state, admin-only RLS, updated-at handling, audit integration and a service-role-only submission RPC. Anonymous users cannot select, update or delete inquiries.

No production migration or function deployment was performed.

## 10. YouNewWorkspace integration

- Repository: `zq87xf5jyp-arch/YouNewWorkspace`.
- Branch: `codex/services-release-center-20260727`.
- Commit: `b996e05 feat: track business inquiry release boundary`.
- Draft PR: https://github.com/zq87xf5jyp-arch/YouNewWorkspace/pull/2
- Local tests: 192/192 passed.
- GitHub gate: “Unit tests and release audit” passed.
- Workspace now expects the 14th protected table and pending business migration for the production project.

Limitation: the Workspace can represent the release boundary, but it cannot show a real open-inquiry count until the production migration, function and safe health/status feed are deployed.

## 11. GitHub and deployment

YouNew draft PR: https://github.com/zq87xf5jyp-arch/YouNew/pull/15

Release commits:

```text
c34ce61 fix(deps): patch public site security advisories
2a4827e feat(admin): add protected operations dashboard
0e5c427 feat(web): connect secure business inquiries
7b03518 chore(supabase): sync production migration history
c453158 Connect business flows across web and iOS
9d06a21 Fix effective release CI validation
a7eb56f Prepare public site for production
a8d0978 Add individual images to entity cards
```

GitHub checks observed as passing after `c34ce61` include the secret scan, offline publication gates, backend security contract tests, public-site validation and both Admin Dashboard jobs. The iOS job is still pending and must pass before merge.

Hostinger deployment is manual. The ZIP contains the contents of `out/`, not the `out` directory itself, and includes root `.htaccess`.

## 12. Security and privacy

Passed:

- CSP includes the exact Supabase function origin.
- `X-Content-Type-Options`, `Referrer-Policy`, `X-Frame-Options` and `Permissions-Policy` are present.
- No secret patterns in the deploy package.
- No known production dependency vulnerabilities after the Next.js/Sharp update.
- Business body-size, origin, validation, rate-limit and RLS boundaries are implemented.
- Admin routes are protected and non-indexable.
- External App Store/source links are explicit.
- Privacy copy covers local profile, saved items, search history, journeys, business inquiries, Supabase processing and deletion contact.
- No non-essential tracking/cookie system was found, so no fake cookie banner was added.

Remaining:

- Supabase leaked-password protection should be enabled and retested.
- Production session/auth behaviour is not verified.
- A real restore drill is absent.
- Exact retention/deletion operations for production inquiry records need owner approval and operational documentation.

## 13. Test results

| Area | Evidence | Result |
|---|---|---|
| Public site | `pnpm predeploy:check` | 10/10 PASS |
| Public unit/schema | `pnpm test` | 53/53 PASS |
| Admin contracts | `pnpm test` | 6/6 PASS |
| Admin lint/type/build | `pnpm lint && pnpm typecheck && pnpm build` | PASS |
| Edge Function TypeScript | `pnpm dlx deno check ...` | PASS |
| Main static QA | `bash scripts/run-static-qa.sh` | PASS in the release-preparation run |
| Workspace | unit suite | 192/192 PASS |
| Workspace GitHub gate | Unit tests and release audit | PASS |
| iOS targeted public links | `PublicReleaseLinksTests` | 2/2 PASS |
| Full iOS simulator/UI suite | XcodeBuildMCP `test_sim` | RUNNING / no final summary yet |
| Business production E2E | real insert and admin verification | NOT RUN |
| Admin production CRUD E2E | protected production environment | NOT RUN |
| Sync E2E | publish → export → deploy → iOS | NOT RUN |

Local Node is 26.5.0 while both web packages declare Node `>=24 <25`. Local builds passed, but CI on the declared Node version remains the authoritative compatibility gate.

## 14. Lighthouse

Not run. The user selected the in-app Browser, and its exposed capabilities do not include Lighthouse. Launching a separate browser/CLI would violate the selected-browser constraint without approval.

Required before GO:

- Performance ≥ 90
- Accessibility ≥ 95
- Best Practices ≥ 95
- SEO ≥ 95

## 15. Known limitations

- 0 full practical guides are public.
- DigiD, work-contract and residence-permit searches intentionally return empty states until reviewed content exists.
- Content is concentrated in five cities and does not claim nationwide completeness.
- Saved items, profile, search history and journeys remain local to one browser and do not sync to iOS.
- Status is a static checked snapshot, not live monitoring.
- Admin hosting, automated Hostinger deploy and end-to-end sync are not verified.
- Business email notification is not implemented; database receipt is designed not to depend on email.
- Universal Links are not verified.
- Support mailbox delivery was not tested.

## 16. Backup and rollback

Observed Hostinger backup assets:

```text
public_html-rollback-20260728
public_html-backup-20260728-pre-release.zip
```

Prepared artifact:

```text
artifacts/younew-hostinger-c34ce61-20260728.zip
SHA-256 7541723b3535ae1431a6dde350cd92a30c715993d0ebb072d5cd09d191af9471
707 regular files + 270 directory entries
commit c34ce61209dbda45b1ef82fe57af914c56404707
dataset fingerprint 0997fa89245b53f6d53f59c5f5544a34cd29a8632047bbe25b09a9389c7261cc
```

Rollback:

1. Restore the timestamped `public_html` rollback directory or pre-release ZIP.
2. Confirm root `.htaccess`.
3. Verify critical routes and a real 404.
4. Do not change DNS, MX, SSL or mailboxes.
5. If the inquiry migration has already been applied, disable the function/form first and preserve inquiry/audit data; use a reviewed data-preserving migration rather than dropping the table automatically.

Restore success is not yet proven.

## 17. Changed files

Major changed areas:

- `admin-dashboard/public-site/`: App Store connection, status, reader-facing copy, search precision, business form, tests, security headers and final static export logic.
- `admin-dashboard/supabase/`: migration, Edge Function, shared validation and configuration.
- `admin-dashboard/src/`: protected Admin Dashboard and business-inquiry queue.
- `admin-dashboard/scripts/`: governed runtime generation and backup helper.
- `.github/workflows/admin-ci.yml`: admin CI.
- `scripts/admin-production-static-qa.py` and `scripts/run-static-qa.sh`: admin release gate.
- `DataProject/quality/content-readiness-matrix.json`: refreshed release evidence.
- `YouNew/Core/AppPublicLinks.swift` and related earlier release commits: public web/business links.
- YouNewWorkspace branch: protected-table and migration expectations.

Use `git show --stat <commit>` and the two readiness reports for the exact diff.

## 18. Commits

Artifact code commit:

```text
c34ce61209dbda45b1ef82fe57af914c56404707
```

The report/readiness commit is intentionally later and is not part of the static artifact. The artifact is reproducible from `c34ce61`.

## 19. Manual owner actions

1. Record service owners and the private Admin Dashboard URL.
2. Complete human editorial review and authorize any full guide intended for release.
3. Approve the new Supabase migration and production environment variables:
   - publishable browser-safe key where required;
   - server-only service-role key;
   - strong rate-limit salt;
   - exact allowed production origins.
4. Deploy the migration and Edge Function in a controlled window.
5. Deploy/configure the Admin Dashboard privately and assign approved roles.
6. Execute one clearly labelled test business inquiry; verify receipt, admin view, status transition, audit entry and Workspace update; retain or remove it through an audited workflow.
7. Run admin CRUD and sync E2E.
8. Run Lighthouse and meet all four targets.
9. Wait for all GitHub checks, including iOS, to pass.
10. Test restoring the Hostinger backup.
11. Review this NO-GO report. Only after every mandatory blocker is resolved, send the exact command `GO LIVE`.
