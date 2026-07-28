# YouNew Supabase

This directory is the canonical source-controlled database boundary for the
YouNew production project `pgdzdxsiagfjioxwuqxf`.

## Layout

- `migrations/` contains the exact SQL versions recorded in production managed
  migration history plus reviewed, unapplied release migrations.
- `functions/business-inquiry/` is the public, server-validated form boundary.
- `verification/verify_after_migration.sql` is read-only post-migration
  verification.
- `docs/SUPABASE_PRODUCTION.md` records hashes, current advisor evidence, the
  historical-baseline limitation, and the rollout procedure.

The production SQL hashes were verified on 2026-07-27:

```text
20260727170658_harden_rls_and_function_boundaries.sql
MD5 72a05daa90d58fa544ad839897eaec6e

20260727170715_add_foreign_key_indexes.sql
MD5 49985497a6463000a655340405a7483f
```

Do not rename an applied migration, replay it under a new version, or place
credentials in this directory.

## Pending 2026-07-29 release

The following files are source-controlled but **not applied to production**:

- `20260727234843_business_inquiries.sql`
- `functions/business-inquiry/index.ts`

The function intentionally has `verify_jwt = false` because the form is
anonymous. Its boundary is instead enforced with an exact origin allowlist,
server validation, payload limits, a honeypot and an atomic salted-IP rate
limit. Only the function's service-role client can execute the insert RPC.

Before an approved rollout:

1. Capture a database backup and confirm restore evidence.
2. Test the migration and function on an isolated branch.
3. Configure `BUSINESS_INQUIRY_RATE_LIMIT_SALT` and
   `BUSINESS_INQUIRY_ALLOWED_ORIGINS`.
4. Apply the migration, deploy the function, run the read-only verification,
   and submit one labelled test inquiry.
5. Confirm the test inquiry appears only for an approved owner/admin.

Production rollout remains blocked until the user gives the exact command
`GO LIVE`.
