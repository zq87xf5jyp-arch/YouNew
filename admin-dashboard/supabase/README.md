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
  `tests/business_inquiry_notification_test.sql` provide 81 core assertions,
  while `tests/monetization_retention_policy_test.sql` and
  `tests/pilot_usage_report_privacy_test.sql` provide 67 retention and aggregate
  privacy assertions, and `tests/geo_relevance_analytics_test.sql` provides 43
  geo analytics privacy/security assertions. The additive Admin remediation
  suites contribute 184 assertions: 37 content/security, 60 operational truth,
  43 Analytics v2, and 44 canonical Map/Links compatibility assertions. All
  385 targeted assertions must pass on a disposable database. The historical
  12-assertion content-governance suite is also executed, producing a complete
  gate of 397 assertions across all 14 checked-in pgTAP files before any
  migration is eligible for a production approval request.
- `docs/SUPABASE_PRODUCTION.md` records hashes, current advisor evidence, the
  historical-baseline limitation, and the rollout procedure.

The complete source-controlled production migration set is hash-pinned. Check
it locally with:

```bash
python3 scripts/verify-supabase-migration-manifest.py
```

Do not rename an applied migration, replay it under a new version, or place
credentials in this directory.
