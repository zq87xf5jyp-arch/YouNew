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
| P0 correction commit | `e2d1eac2face010a48ec8412860a7281cb85c9ee` |
| iOS asset commit | `cadf8e7f00293172e1971801419bd5f70714b3a7` |
| Original mixed worktree HEAD | `66ecc29e5026b85dcee571ad18de3250599ae27f` |
| Content heads | `amsterdam-v0.1.2`, `cities-v0.1.0` |
| Public records | 186 |
| Migration | `20260728075522_younew_production_operations.sql` |
| Migration SHA-256 | `af35cc6f128795fcb36ccacbb19c9db85c78ac325e03f7b239b3378de6951165` |
| Admin runtime fingerprint | `066158d1e248ba544b582ef0a2eaf60648c8e50da04e2ba89d041e707178e2de` |
| Production artifact | `release-artifacts/younew-public-2026-07-29.tar.gz` |
| Artifact SHA-256 | `fec353bfbbec840f39a1b0e8fa463b399e1570522c0a5b8fd3859f666ef4ebc7` |
| Artifact content fingerprint | `33bf83f90c66cac8042bafdfa051fed4c9ccc7277cda0dce5b9becca8f2d70eb` |

A separate worktree was created at `/Users/ivan/Desktop/Developer:YouNew/YouNew-release-clean-2026-07-29`. The P0 correction is the fifth local commit ahead of `origin/admin-dashboard-integration`; this evidence update follows as a sixth local commit. Nothing was pushed. The original mixed worktree remains separate and was not used for the P0 correction.

## Gate matrix

| Gate | Result | Evidence |
|---|---|---|
| Public production build | PASS | 230 static pages |
| Public unit/schema tests | PASS | 66/66 |
| Public routes and package | PASS | 222 sitemap URLs, 227 HTML files, real 404 |
| Internal links/assets | PASS | 16,539 references, 0 broken |
| Static security scan | PASS | 0 known secret patterns; required local Hostinger headers present |
| Data health | PASS | 450 governed, 186 published, 0 structural issues, 2,560 URL evidence records with 0 confirmed broken |
| Content isolation | PASS | draft/review excluded; two expired events retired |
| Admin lint/type/test/build | PASS | 9/9 tests; 31-page Next build |
| Edge Function format/type | PASS | Deno 2.9.4, 9 files formatted, 3 entrypoints checked |
| SQL syntax | PASS | PostgreSQL parser accepted 111 statements / 38,205 bytes |
| Browser responsive QA | PASS | 156 route/viewport combinations, 0 relevant console logs |
| Public interactions | PASS locally | Search, Saved, journeys, map and client validation; no production test records created |
| Production URL availability | PASS | 17 required URLs return 200; unknown URL returns 404 |
| Lighthouse accessibility | PASS | 100 |
| Lighthouse best practices | PASS | 100 |
| Lighthouse SEO | PASS | 100 |
| Lighthouse performance | PASS | Three clean standard mobile runs: 99/100/100; three desktop runs: 100/100/100 |
| Supabase deployment | **FAIL** | Production has one unrelated `analytics-ingest` function, but does not contain the release migration or the three release functions |
| Business form persistence | **FAIL** | A compatible base table exists, but public persistence still cannot run until the release migration and submission function deploy |
| Admin production E2E | **FAIL** | `admin.younew.nl` and interactive sign-in by an existing approved owner are authorized, but the host is not provisioned and production code is not deployed |
| Sync production E2E | **FAIL** | Candidate contract tested locally; function/table not deployed |
| Hostinger file backup | PASS | Manual files/database backup completed 2026-07-28 12:34; `domains/younew.nl/public_html` contents and restore control verified |
| Database backup/restore proof | PASS | Custom-format dump `younew-pgdzdxsiagfjioxwuqxf-20260728T113724Z.dump`, 306,563 bytes, `pg_restore --list` PASS with 564 catalog entries, SHA-256 `1156df801833aed5c0d16aabc5843b79f9bcb664edebf968bcc12d7b9af744f7` |
| Supabase Free-plan security | RISK ACCEPTED | Owner accepted the absence of leaked-password protection and managed project backups on 2026-07-28 |
| iOS simulator build | PASS | Clean build/install/launch completed in 229.75 s with no reported warnings/errors after replacing 27 oversized coat-of-arms SVGs |
| Commit/CI on release SHA | PARTIAL | Clean local branch and four isolated commits exist; all corresponding local CI commands pass, but the branch was not pushed and remote CI therefore has not run |

## Production comparison

Confirmed facts:

- all required public URLs are reachable;
- App Store listing ID `6782617312` resolves;
- production homepage has CSP, `nosniff`, referrer, frame, permissions and COOP headers;
- production does not advertise HSTS;
- production CSP still has `connect-src 'self'`, so it is not the new Supabase form artifact;
- production now contains migrations through `20260728173737_enforce_analytics_retention_and_production_views` and the unrelated `analytics-ingest` Edge Function;
- the release migration and `submit-business-inquiry`, `submit-public-feedback` and `prepare-content-sync` functions are not deployed;
- the local migration was revised to extend the deployed `business_inquiries` contract in place and to use the production private authorization/rate-limit boundaries.

## Blocking owner actions

1. Review the six clean local commits. Push/PR remains a separate owner-authorized action.
2. Send the exact instruction `GO LIVE` to authorize migration, Edge Function, Admin and Hostinger deployment.
3. During the authorized release, provision `admin.younew.nl` and use the approved interactive owner sign-in for authenticated E2E.

After deployment, controlled business, feedback, Admin and sync E2E tests remain mandatory before the release can be called complete.

## Accepted risk

On 2026-07-28 the owner explicitly accepted continuing on Supabase Free. This accepts the absence of leaked-password protection and Supabase-managed backups. The owner separately approved the SSL restart: SSL enforcement is now enabled, the database returned `ACTIVE_HEALTHY`, and a verified manual backup closed the compensating backup gate. The short-lived PAT and read-only rule were deleted; a repeat connection with the revoked PAT was rejected. This does not constitute `GO LIVE`.
