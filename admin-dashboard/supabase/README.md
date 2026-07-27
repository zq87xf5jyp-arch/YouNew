# YouNew Supabase

This directory is the canonical source-controlled database boundary for the
YouNew production project `pgdzdxsiagfjioxwuqxf`.

## Layout

- `migrations/` contains the exact SQL versions recorded in production managed
  migration history.
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
