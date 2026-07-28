# YouNew production GO LIVE evidence — 2026-07-28

## Current state

The production migration, release Edge Functions, Admin deployment and public
Hostinger artifact are live. Public Business and Feedback UI submissions are
persisting in PostgreSQL. An approved owner completed the interactive login and
the authenticated Business, Feedback and candidate-sync paths were exercised.

Business and Feedback are operational end to end. The sync control plane also
completed successfully. The candidate contained zero records because production
has no database articles in `published` status, and it was correctly not
activated. Production is live with a conditional GO because the desktop
performance gate remains unmet, not because of an E2E functional failure.

## Production changes

| Component | Result | Evidence |
|---|---|---|
| Supabase release migration | PASS | `20260728192120 younew_production_operations` applied once |
| Admin image storage | PASS | `20260728194108 provision_content_images_and_harden_extensions` applied once |
| Storage/advisor hardening | PASS | `20260728200449 harden_content_image_listing_and_fk_indexes` applied once |
| Business Edge Function | PASS | `submit-business-inquiry`, version 1, `ACTIVE`, intentional public JWT setting with Origin/CORS, validation, honeypot and rate limiting |
| Feedback Edge Function | PASS | `submit-public-feedback`, version 1, `ACTIVE`, intentional public JWT setting with Origin/CORS, validation, honeypot and rate limiting |
| Sync Edge Function | PASS for deployment, authorization and candidate execution | `prepare-content-sync`, version 1, `ACTIVE`, JWT required; unauthenticated request returned 401; approved owner candidate job completed `succeeded` |
| Admin deployment | PASS | Hostinger deployment completed at 2026-07-28 21:37 CEST; protected routes redirect unauthenticated users; approved owner authenticated and exercised Business, Feedback and Sync |
| Public deployment | PASS | Hostinger `public_html` switched at approximately 2026-07-28 21:58 CEST |

## Public production verification

| Check | Result |
|---|---|
| Sitemap live crawl | 222 of 222 URLs returned HTTP 200 |
| Homepage, Business and Support | HTTP 200 |
| Apple association file | HTTP 200, `application/json` |
| Unknown route | HTTP 404 with the release 404 artifact |
| Security headers | CSP, HSTS, `nosniff`, `DENY`, referrer and permissions policies present |
| HTML cache behavior | `Cache-Control: public, max-age=0, must-revalidate` |
| CSP Supabase connection | Limited to `https://pgdzdxsiagfjioxwuqxf.supabase.co` |

Public Hostinger artifact:

- ZIP: `release-artifacts/younew-public-hostinger-2026-07-28-1947.zip`
- SHA-256: `e83a095750fd9eb98d524b251f031c9a53c6c80c8b1899a11587e1be6ca698e1`
- Previous origin retained as `public_html-pre-go-live-20260728-2157`
- Earlier verified rollback directory retained as `public_html-rollback-20260728`
- Earlier verified backup retained as `public_html-backup-20260728-pre-release.zip`

## Production E2E records

Controlled direct Edge Function checks:

- Business: `YNI-2F0EDB9F6F97`
- Feedback: `YNF-7655BA0FC98B`

Public UI checks after the Hostinger switch:

- Business: `YNI-2308DA8E179F`
- Business duplicate caused by the explicit retry: `YNI-507E6F5EBBBA`
- Feedback: `YNF-8F796EB8827E`

The UI markers and receipts were verified against the production tables.
Authenticated Admin displayed all five controlled records.

- All three Business records were changed from `new` to `test` through the
  production Admin server action. Each update is attributed to the approved
  owner and has a corresponding `business_inquiry_updated` audit row.
- The two Feedback records were changed from `new` to `resolved`, with an E2E
  resolution note and the approved owner recorded in `resolved_by`. The current
  Feedback screen is read-only, so this controlled cleanup used the production
  database operation after Admin visibility was verified.

## Authenticated candidate-sync E2E

The approved owner ran exactly one `Подготовить candidate-артефакт` action.
The action is candidate-only and does not permit production replacement.

| Object | Result |
|---|---|
| Sync job | `55314d7c-cb73-42de-b9fc-a4c06cc010bf` |
| Job status | `succeeded`; initiator attributed; no error summary |
| Candidate artifact | `522c709e-6af5-4eb1-ae8f-b51adcc2f9be` |
| Candidate fingerprint | `5f77a0ca28aed6d932200e71d13d1d3b2ed258afe74602040c25af4f6314bba4` |
| Candidate state | `candidate`, never activated |
| Candidate records | `0` |

The successful job proves the authenticated Admin action, role check, RPC,
JWT-protected Edge Function and artifact write path. The zero-record result is
expected: the candidate contract includes only database articles with
`status = 'published'`, while production currently has one `draft`, two
`review`, and zero `published` articles.

The Admin summary count of 186 and the six `content_sync_state` rows totalling
299 describe separate governed/runtime projections, not the database-article
candidate. The `resources` runtime state remains `needs review`, but it is not
silently activated or overwritten by this candidate workflow.

## Backup and temporary database access

- Custom-format PostgreSQL dump:
  `/Users/ivan/Library/Application Support/YouNew/backups/younew-pgdzdxsiagfjioxwuqxf-20260728T113724Z.dump`
- File mode: `0600`; size: 306,563 bytes.
- `pg_restore --list`: PASS with 564 catalog entries.
- SHA-256:
  `1156df801833aed5c0d16aabc5843b79f9bcb664edebf968bcc12d7b9af744f7`.
- The temporary PAT and read-only access rule were deleted after verification;
  a repeat connection attempt was rejected.
- Supabase Temporary access remains enabled with zero active rules.

## Supabase security and storage

- Direct anonymous REST access to `business_inquiries` and `feedback` is denied.
- RLS is enabled on the release operational tables.
- `content-images` is public for object delivery, limited to 8 MiB and
  AVIF/JPEG/PNG/WebP.
- Object listing and mutation policies are restricted to authenticated,
  approved owner/admin/editor roles.
- The public-bucket listing advisor warning was removed.
- All seven newly reported foreign keys now have covering indexes.

Remaining advisor notices:

- `feedback_rate_limits` has RLS and deliberately no client policy because it is
  service-only (`INFO`).
- `request_content_sync()` is intentionally callable by authenticated users as
  a `SECURITY DEFINER` function; it performs the approved Admin role check
  internally (`WARN`).
- leaked-password protection remains disabled on Supabase Free; the owner
  explicitly accepted this Free-plan risk (`WARN`).

## Performance evidence

Live production is healthy for normal requests, but Hostinger returned HTTP 403
only to Lighthouse headless navigation. The unauthenticated public curl checks
and interactive browser checks returned HTTP 200. Google PageSpeed Insights
could not provide a substitute measurement because its public daily quota was
exhausted.

Standard Lighthouse 12.8.0 against the exact deployed artifact:

| Run | Performance | Accessibility | Best Practices | SEO | Notes |
|---|---:|---:|---:|---:|---|
| Mobile | 100 | 100 | 100 | 100 | FCP 1.4 s, LCP 1.4 s, TBT 60 ms, CLS 0 |
| Desktop 1 | 66 | 100 | 100 | 100 | FCP/LCP 0.9 s, TBT 590 ms; 823 ms unattributable long task |
| Desktop 2 | 65 | 100 | 100 | 100 | FCP/LCP 0.9 s, TBT 610 ms; 790 ms unattributable long task |

Therefore the standard mobile gate is proven, but the requested standard
desktop Performance gate of at least 90 is not met in this execution
environment. The live-origin standard score is also not measurable while the
Hostinger bot policy returns 403 to Lighthouse.

## Release decision and remaining closure

Decision: **CONDITIONAL GO for the live public site, Business, Feedback, Admin
and authenticated sync control plane.** The zero-record candidate remains
inactive as expected.

1. Publish a reviewed database article before expecting a non-empty article
   candidate; keep activation manual.
2. Review the separately governed `resources` dataset, which remains marked
   `needs review`.
3. Meet the standard desktop Lighthouse Performance gate of at least 90 or
   explicitly accept the measured 65–66 result as a release exception.
4. Supabase Free leaked-password protection and managed-backup limitations
   remain explicitly accepted risks.
