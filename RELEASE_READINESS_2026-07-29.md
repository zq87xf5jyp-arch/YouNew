# YouNew release readiness — 2026-07-29

Assessment prepared: 2026-07-28, Europe/Amsterdam

## Decision

**NO-GO**

The repository contains a locally verified public release candidate and a tested Admin/Supabase implementation, but the system does not yet satisfy the production completion criteria. No production deployment was performed because the exact authorization `GO LIVE` was not given.

## Release identity

| Item | Value |
|---|---|
| Branch | `release/younew-production-2026-07-29` |
| Clean release base | `76df6ca969927687e1b3a517ac2cecec4b8130f7` (`origin/admin-dashboard-integration`) |
| Release candidate commit | `8566a228ea703db2280e153bf57ce1cad37e99c9` |
| iOS asset commit | `cadf8e7f00293172e1971801419bd5f70714b3a7` |
| Original mixed worktree HEAD | `66ecc29e5026b85dcee571ad18de3250599ae27f` |
| Content heads | `amsterdam-v0.1.2`, `cities-v0.1.0` |
| Public records | 186 |
| Migration | `20260728075522_younew_production_operations.sql` |
| Migration SHA-256 | `c5c055676cd3cad86a63116ad809f9bc609927829fc82ccb6eb77439840ff69b` |
| Admin runtime fingerprint | `066158d1e248ba544b582ef0a2eaf60648c8e50da04e2ba89d041e707178e2de` |
| Production artifact | `release-artifacts/younew-public-2026-07-29.tar.gz` |
| Artifact SHA-256 | `74ef1465e8657a66ee0cd4c43c4023a56e39c38ac3b2674c229c535b7f72dd8c` |
| Artifact content fingerprint | `01a412afde506911a4395f71143636a1c09c324cad870c38d6964ac4bd117a97` |

A separate worktree was created at `/Users/ivan/Desktop/Developer:YouNew/YouNew-release-clean-2026-07-29`. It is clean and two local commits ahead of `origin/admin-dashboard-integration`; nothing was pushed. The original mixed worktree remains untouched apart from the intended `.gitignore` test-tracking fix and two trailing-newline corrections, and currently has 187 status entries.

## Gate matrix

| Gate | Result | Evidence |
|---|---|---|
| Public production build | PASS | 230 static pages |
| Public unit/schema tests | PASS | 65/65 |
| Public routes and package | PASS | 222 sitemap URLs, 227 HTML files, real 404 |
| Internal links/assets | PASS | 16,539 references, 0 broken |
| Static security scan | PASS | 0 known secret patterns; required local Hostinger headers present |
| Data health | PASS | 450 governed, 186 published, 0 structural issues, 2,560 URL evidence records with 0 confirmed broken |
| Content isolation | PASS | draft/review excluded; two expired events retired |
| Admin lint/type/test/build | PASS | 8/8 tests; 31-page Next build |
| Edge Function format/type | PASS | Deno 2.9.4, 9 files formatted, 3 entrypoints checked |
| SQL syntax | PASS | PostgreSQL parser accepted 97 statements / 33,450 bytes |
| Browser responsive QA | PASS | 156 route/viewport combinations, 0 relevant console logs |
| Public interactions | PASS locally | Search, Saved, journeys, map and client validation; no production test records created |
| Production URL availability | PASS | 17 required URLs return 200; unknown URL returns 404 |
| Lighthouse accessibility | PASS | 100 |
| Lighthouse best practices | PASS | 100 |
| Lighthouse SEO | PASS | 100 |
| Lighthouse performance | PASS | Three clean standard mobile runs: 99/100/100; three desktop runs: 100/100/100 |
| Supabase deployment | **FAIL** | Production has 0 Edge Functions and does not contain the release migration |
| Business form persistence | **FAIL** | Cannot persist until migration/functions deploy |
| Admin production E2E | **FAIL** | `admin.younew.nl` and interactive sign-in by an existing approved owner are authorized, but the host is not provisioned and production code is not deployed |
| Sync production E2E | **FAIL** | Candidate contract tested locally; function/table not deployed |
| Hostinger file backup | PASS | Manual files/database backup completed 2026-07-28 12:34; `domains/younew.nl/public_html` contents and restore control verified |
| Database backup/restore proof | **FAIL** | `libpq` 18.4 is installed and the mode-`0700` backup directory exists; Supabase requires SSL enforcement and a brief database restart before Temporary access can be granted |
| Supabase Free-plan security | RISK ACCEPTED | Owner accepted the absence of leaked-password protection and managed project backups on 2026-07-28 |
| iOS simulator build | PASS | Clean build/install/launch completed in 229.75 s with no reported warnings/errors after replacing 27 oversized coat-of-arms SVGs |
| Commit/CI on release SHA | PARTIAL | Clean local branch and two isolated commits exist; all corresponding local CI commands pass, but the branch was not pushed and remote CI therefore has not run |

## Production comparison

Confirmed facts:

- all required public URLs are reachable;
- App Store listing ID `6782617312` resolves;
- production homepage has CSP, `nosniff`, referrer, frame, permissions and COOP headers;
- production does not advertise HSTS;
- production CSP still has `connect-src 'self'`, so it is not the new Supabase form artifact;
- the new business/feedback endpoints are not deployed.

## Blocking owner actions

1. Explicitly authorize enabling SSL enforcement now and accept the Supabase PostgreSQL restart/downtime of a few minutes. Then create a fresh 30-minute read-only grant/PAT, produce the dump, validate `pg_restore --list` and SHA-256, and revoke both.
2. Review the clean local commits. Push/PR remains a separate owner-authorized action.
3. Provision `admin.younew.nl` during the release and use the approved interactive owner sign-in for authenticated E2E.
4. After the backup gate is closed and the commits are reviewed, send the exact instruction `GO LIVE` to authorize migration, Edge Function, Admin and Hostinger deployment.

After deployment, controlled business, feedback, Admin and sync E2E tests remain mandatory before the release can be called complete.

## Accepted risk

On 2026-07-28 the owner explicitly accepted continuing on Supabase Free. This accepts the absence of leaked-password protection and Supabase-managed backups. Temporary access preview was enabled, but the unused PAT was deleted and no database role was granted after the SSL-restart prerequisite appeared. This does not waive the manual database-backup gate, authorize downtime or constitute `GO LIVE`.
