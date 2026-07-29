# YouNew Admin-to-site production GO LIVE evidence — 2026-07-29

## Release decision

Decision: **GO LIVE completed for the Admin → public-site content sync path.**

The approved owner published one reviewed article, prepared a candidate
artifact, activated it through Admin, and verified the same artifact through the
public Admin API and the production `/updates/` experience.

This decision is scoped to the Admin-to-site synchronization path. It does not
remove the separately accepted Supabase Free-plan risks or replace the existing
Lighthouse performance evidence.

## Production result

| Check | Result | Evidence |
|---|---|---|
| Admin production | PASS | `https://admin.younew.nl`; Hostinger deployment completed and marked current |
| Public production | PASS | `https://younew.nl`; staged artifact switched into `public_html` |
| Approved owner login | PASS | Existing approved owner completed interactive authentication |
| Reviewed publication | PASS | `Регистрация в муниципалитете` published with reviewer and verification metadata |
| Candidate preparation | PASS | JWT-protected `prepare-content-sync` returned HTTP 200 |
| Manual activation | PASS | Candidate activated through Admin; audit actor is present |
| Public content API | PASS | HTTP 200, `available: true`, schema version 1, record count 1 |
| Public updates page | PASS | The verified article is visible on `https://younew.nl/updates/` |
| CORS and cache validation | PASS | Production origin allowed; untrusted origin not allowed; ETag conditional request returned 304 |

## Active content artifact

| Field | Value |
|---|---|
| Artifact ID | `2e1e13a7-7a25-4348-9c4f-ebee1f96d7e0` |
| Feed key | `active` |
| Status | `active` |
| Record count | `1` |
| Fingerprint | `2c3980bab10960449fbfa0c9315dae2d8848b1a309f1f507ec2dc991732348b5` |
| Source version | `2026-07-29T09:29:20.996974+00:00` |
| Activated at | `2026-07-29T09:30:26.269892+00:00` |

The activation audit row uses action `content_artifact_activated`, references
the same artifact and fingerprint, reports one record, and is attributed to an
authenticated user.

The published record was checked against the official Government of the
Netherlands guidance:

- `https://www.government.nl/faq/what-do-i-need-to-arrange-if-im-moving-to-the-netherlands`
- verified date: `2026-07-29`
- published slug: `municipality-registration`
- category: `documents-services`

## Supabase production

Project: `pgdzdxsiagfjioxwuqxf`.

Release migrations registered in production:

| Version | Migration |
|---|---|
| `20260729082542` | `activate_public_content_feed` |
| `20260729092849` | `secure_article_publication_gate` |

Active Edge Functions:

| Function | Version | JWT mode |
|---|---:|---|
| `analytics-ingest` | 4 | Public function with internal controls |
| `submit-business-inquiry` | 1 | Public function with internal controls |
| `submit-public-feedback` | 1 | Public function with internal controls |
| `prepare-content-sync` | 1 | JWT required |

The publication trigger initially failed because an invoker-context function
could not access the private role helper. The release fixes this boundary by
making `public.enforce_article_publication_gate()` a narrowly privileged
`SECURITY DEFINER` function with `search_path = pg_catalog`. Direct execution is
revoked from `PUBLIC`, `anon`, and `authenticated`; only `service_role` retains
execute permission. The authenticated role still has no `USAGE` on the private
schema.

Post-DDL advisors report no new blocking finding. Remaining notices:

- `feedback_rate_limits` has RLS and deliberately no client policy because it is
  service-only (`INFO`);
- `activate_content_artifact()` and `request_content_sync()` are intentionally
  callable by authenticated Admin users and perform approved-role checks
  internally (`WARN`);
- leaked-password protection remains disabled on Supabase Free, explicitly
  accepted by the owner (`WARN`);
- performance notices are unused-index information on a newly deployed /
  low-traffic database, not a release failure.

Advisor references:

- <https://supabase.com/docs/guides/database/database-linter?lint=0008_rls_enabled_no_policy>
- <https://supabase.com/docs/guides/database/database-linter?lint=0029_authenticated_security_definer_function_executable>
- <https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection>

## Deployment and rollback

Admin artifact:

- `release-artifacts/admin-dashboard-hostinger-2026-07-29-go-live.zip`
- SHA-256:
  `c0b2e1ba896456acd18bce41e3479ebdece721a8cdd40acd59569403f1976408`
- size: 233,791 bytes
- the previous Hostinger deployment remains available for rollback

Public artifact:

- `release-artifacts/younew-public-hostinger-2026-07-29-go-live.zip`
- SHA-256:
  `b1eab2f0ec0722354d2235c69acf630eeace1ca721fbbf99c01a53656e7d3561`
- size: 5,467,671 bytes
- previous origin retained as `public_html-pre-go-live-20260729-1058`
- fresh rollback archive:
  `younew-public-html-pre-go-live-20260729T0853Z.zip`

Live HTTP checks returned 200 for:

- `https://younew.nl/`
- `https://younew.nl/updates/`
- `https://younew.nl/status/`
- `https://younew.nl/business/apply/`
- `https://younew.nl/sw.js`
- `https://younew.nl/data/status.json`

The public `/updates/` response includes CSP, HSTS, `X-Frame-Options: DENY`,
`X-Content-Type-Options: nosniff`, referrer, permissions, and cross-origin
opener policies.

## Database backup and access cleanup

Fresh custom-format PostgreSQL dump:

- `/Users/ivan/Library/Application Support/YouNew/backups/younew-20260729T081500Z.dump`
- size: 403,026 bytes
- `pg_restore --list`: PASS, 684 catalog entries
- SHA-256:
  `42b979ca5bfb0ecd5fc5c9c39fca3e851b5e39a40cfe275147ed9fbf7eb36d35`

The temporary PAT was revoked and deleted locally. The temporary read-only
database access rule was revoked. Temporary access remains enabled with zero
active rules.

Hostinger also showed its scheduled backup from `2026-07-28 12:34`; the fresh
public rollback ZIP and retained previous deployment provide the release-time
rollback evidence.

## Verification gates

Admin:

- lint: PASS
- type check: PASS
- tests: PASS, 14 of 14
- production build: PASS

Public:

- `pnpm predeploy:check`: PASS
- tests: PASS, 69 of 69
- sitemap smoke: PASS, 223 URLs
- internal references: PASS, 17,284
- security package: PASS
- production build: PASS

Public API:

- allowed-origin request: HTTP 200
- ETag:
  `W/"2c3980bab10960449fbfa0c9315dae2d8848b1a309f1f507ec2dc991732348b5"`
- fingerprint header matches the active database artifact
- `If-None-Match`: HTTP 304
- preflight: HTTP 204 with `GET, OPTIONS`
- untrusted origin receives no `Access-Control-Allow-Origin`

## Residual accepted risks and scope limits

1. Supabase Free does not provide the requested managed project backup feature,
   and leaked-password protection remains unavailable/disabled. The owner
   explicitly accepted both Free-plan risks.
2. The prior standard Lighthouse desktop Performance result remains below the
   requested 90 gate. No new Lighthouse claim is made by this sync release.
3. The iOS Simulator build issue and iOS release readiness are outside this
   Admin-to-site synchronization release.
4. Release commits are local only. No Git push was performed.
