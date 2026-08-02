# Supabase production migrations

Verified: **2026-08-01**

Production project: `pgdzdxsiagfjioxwuqxf` (`YouNew Project`, `eu-west-1`)

## Canonical contract

The production-managed migration history and this repository contain the same
13 timestamped migrations. `production-migration-manifest.json` is the
machine-checked immutable contract for these files.

| Production version | Migration | SQL MD5 |
| --- | --- | --- |
| `20260727170658` | `harden_rls_and_function_boundaries` | `72a05daa90d58fa544ad839897eaec6e` |
| `20260727170715` | `add_foreign_key_indexes` | `49985497a6463000a655340405a7483f` |
| `20260728152428` | `business_inquiries` | `79a9a56c6f6059d91e47a9765d4bf61e` |
| `20260728152529` | `deny_direct_business_inquiry_rate_limit_access` | `69c1cb27d3e2ec2ebc9e666fc85c455d` |
| `20260728173016` | `connect_privacy_safe_analytics` | `dd528297d8e35f6850db59526bdf8203` |
| `20260728173737` | `enforce_analytics_retention_and_production_views` | `ad25d4fb8ee7d4944edba8fcbc591cb2` |
| `20260728192120` | `younew_production_operations` | `c431f52694f3ff6c6f9c640f5267d984` |
| `20260728194108` | `provision_content_images_and_harden_extensions` | `98b723765f6aaee31a11fe4085555679` |
| `20260728200449` | `harden_content_image_listing_and_fk_indexes` | `97e6f7a9c8a2d85128c7f4030bd3570e` |
| `20260729082542` | `activate_public_content_feed` | `c9e78fb1eb410be9e7b067cb76e75345` |
| `20260729092849` | `secure_article_publication_gate` | `e921d53eba88a6a7c50a43fa8dfdf397` |
| `20260801002204` | `content_governance_platform` | `171e72a0c02d7f8c796427a4c814a83d` |
| `20260801002707` | `harden_content_governance_performance` | `e71a0460b23ee953c92237852907bd11` |

Canonical files live in `admin-dashboard/supabase/migrations/`. The hashes were
compared with the exact bytes in
`supabase_migrations.schema_migrations.statements` in production, not inferred
from filenames. Static QA runs
`scripts/verify-supabase-migration-manifest.py` to prevent an applied migration
from being renamed or edited in place.

## Historical baseline

The pre-existing 20-table schema predates managed migration history. Files
`0001` through `0006` are the reviewed bootstrap needed to reconstruct a fresh
local database; they are intentionally not represented as applied versions in
the production migration-history table. Timestamped managed history begins at
`20260727170658`. Do not mark the bootstrap files as newly applied in production
or replay them against the existing project.

Supabase treats local timestamped files under `supabase/migrations` as the
source-controlled managed history and records applied versions in
`supabase_migrations.schema_migrations`. Direct SQL changes bypass that history,
so future production DDL must use reviewed versioned migrations.

## Verified production result

Current production evidence on 2026-08-01:

- all 36 public tables have RLS enabled;
- the Security Advisor reports seven authenticated `SECURITY DEFINER` warnings,
  one leaked-password-protection warning and two deny-by-default tables without
  policies;
- the reviewed definer functions check `auth.uid()`, approved internal roles and
  a fixed `search_path`; this is not evidence that future changes are safe, so
  advisor review remains mandatory;
- the Performance Advisor reports four multiple-permissive-policy warnings and
  41 unused-index information notices;
- no index is removed based only on an unused-index notice.

Leaked-password protection is an Auth setting, not SQL, and remains a separate
owner-controlled action subject to the accepted project-plan limitation.

## Operating procedure

1. Create and verify a backup or point-in-time recovery checkpoint.
2. Run new migrations on a disposable branch or local database.
3. Run `admin-dashboard/supabase/verification/verify_after_migration.sql`.
4. Verify the anonymous, unapproved, and approved-role API matrix.
5. Review Security and Performance Advisors.
6. Apply the reviewed migration once through the managed migration boundary.
7. Confirm the production migration version and SQL hash.
8. Repeat verification and advisor checks.

Never commit a service-role key, database password, access token, or generated
production data.

## References

- [Supabase database migrations](https://supabase.com/docs/guides/deployment/database-migrations)
- [Securing the Data API](https://supabase.com/docs/guides/api/securing-your-api)
- [Row Level Security](https://supabase.com/docs/guides/database/postgres/row-level-security)
- [Leaked-password protection](https://supabase.com/docs/guides/auth/password-security#password-strength-and-leaked-password-protection)
