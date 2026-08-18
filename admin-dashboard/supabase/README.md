# YouNew Supabase

This directory is the canonical source-controlled database boundary for the
YouNew production project `pgdzdxsiagfjioxwuqxf`.

## Layout

- `migrations/0001_*.sql` through `0006_*.sql` are the historical bootstrap for
  rebuilding a fresh local project. They predate production managed history and
  must not be replayed against the existing production database.
- timestamped `migrations/20*.sql` contain exact applied SQL plus separately
  reviewed pending forward migrations.
- `production-migration-manifest.json` schema 2 pins every applied production
  version, name, byte count and MD5 hash, records evidence-backed local timestamp
  aliases, and keeps pending SQL separate from applied history.
- `verification/verify_after_migration.sql` is read-only post-migration
  verification.
- `tests/analytics_ingest_windows_rls_test.sql`,
  `tests/business_inquiry_pipeline_test.sql` and
  `tests/business_inquiry_deduplication_test.sql` and
  `tests/lead_analytics_funnel_test.sql` and
  `tests/business_inquiry_notification_test.sql` provide 81 assertions for the
  five pending 2026-08-18 migrations. They must pass on a disposable database
  before any migration is eligible for a production approval request.
- `docs/SUPABASE_PRODUCTION.md` records hashes, current advisor evidence, the
  historical-baseline limitation, and the rollout procedure.

The complete source-controlled production migration set is hash-pinned. Check
it locally with:

```bash
python3 scripts/verify-supabase-migration-manifest.py
```

Do not rename an applied migration, replay it under a new version, or place
credentials in this directory.
