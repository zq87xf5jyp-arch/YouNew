# YouNew production GO LIVE evidence — 2026-07-28

## Current state

The production migration, release Edge Functions, Admin deployment and public
Hostinger artifact are live. Public Business and Feedback UI submissions are
persisting in PostgreSQL. Authenticated Admin and sync E2E remain pending until
an approved owner completes the interactive login at
`https://admin.younew.nl/login`.

## Production changes

| Component | Result | Evidence |
|---|---|---|
| Supabase release migration | PASS | `20260728192120 younew_production_operations` applied once |
| Admin image storage | PASS | `20260728194108 provision_content_images_and_harden_extensions` applied once |
| Storage/advisor hardening | PASS | `20260728200449 harden_content_image_listing_and_fk_indexes` applied once |
| Business Edge Function | PASS | `submit-business-inquiry`, version 1, `ACTIVE`, intentional public JWT setting with Origin/CORS, validation, honeypot and rate limiting |
| Feedback Edge Function | PASS | `submit-public-feedback`, version 1, `ACTIVE`, intentional public JWT setting with Origin/CORS, validation, honeypot and rate limiting |
| Sync Edge Function | PASS for deployment and unauthenticated rejection | `prepare-content-sync`, version 1, `ACTIVE`, JWT required; unauthenticated request returned 401 |
| Admin deployment | PASS for deployment and route protection | Hostinger deployment completed at 2026-07-28 21:37 CEST; `/login` returns 200 and protected `/business`, `/feedback` and `/sync` redirect unauthenticated users to `/login` |
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
These records remain marked `new` until authenticated Admin E2E verifies
visibility and moves the controlled records out of the operational queue.

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

## Pending release closure

1. Complete interactive login with an existing approved owner.
2. Verify Business and Feedback records in Admin and move the controlled E2E
   records out of the live queue.
3. Run authenticated sync candidate preparation and verify the resulting
   `sync_jobs`/artifact state and logs without activating unreviewed content.
4. Record the final GO/conditional-GO decision with the remaining desktop
   performance evidence gap.
