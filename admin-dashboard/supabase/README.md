# YouNew Supabase

This directory is the canonical source-controlled database boundary for the
YouNew production project `pgdzdxsiagfjioxwuqxf`.

## Layout

- `migrations/0001_*.sql` through `0006_*.sql` are the historical bootstrap for
  rebuilding a fresh local project. They predate production managed history and
  must not be replayed against the existing production database.
- timestamped `migrations/20*.sql` contain the exact SQL bytes recorded in
  production managed migration history.
- `production-migration-manifest.json` pins every managed version, name, byte
  count and MD5 hash.
- `verification/verify_after_migration.sql` is read-only post-migration
  verification.
- `docs/SUPABASE_PRODUCTION.md` records hashes, current advisor evidence, the
  historical-baseline limitation, and the rollout procedure.

The complete source-controlled production migration set is hash-pinned. Check
it locally with:

```bash
python3 scripts/verify-supabase-migration-manifest.py
```

Do not rename an applied migration, replay it under a new version, or place
credentials in this directory.
