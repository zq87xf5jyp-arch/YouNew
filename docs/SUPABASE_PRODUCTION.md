# Supabase production migrations

Verified: **2026-07-27**

Production project: `pgdzdxsiagfjioxwuqxf` (`YouNew Project`, `eu-west-1`)

## Canonical contract

The production-managed migration history and this repository now contain the
same two migrations:

| Production version | Migration | SQL MD5 |
| --- | --- | --- |
| `20260727170658` | `harden_rls_and_function_boundaries` | `72a05daa90d58fa544ad839897eaec6e` |
| `20260727170715` | `add_foreign_key_indexes` | `49985497a6463000a655340405a7483f` |

Canonical files live in
`admin-dashboard/supabase/migrations/`. The hashes above were compared with
`supabase_migrations.schema_migrations.statements` in production, not inferred
from filenames.

The original review-package timestamps were replaced with the versions actually
recorded by production. Do not add the review filenames as separate migrations:
that would represent the same SQL twice.

## Historical baseline

The pre-existing 20-table schema predates managed migration history. These two
entries are the first managed production migrations; this repository does not
invent a historical migration record for schema that Supabase did not record.
A future full baseline must be generated from production, reviewed for secrets
and destructive statements, and introduced as a separate documented change.

Supabase treats local files under `supabase/migrations` as the source-controlled
migration history and records applied versions in
`supabase_migrations.schema_migrations`. Direct SQL changes bypass that history,
so future production DDL must use reviewed versioned migrations.

## Verified production result

After the two migrations:

- the Security Advisor reports one remaining warning:
  `auth_leaked_password_protection`;
- the Performance Advisor reports 17 `INFO` notices for unused indexes and no
  warning-level finding;
- the 13 foreign-key indexes created by the second migration are present but
  currently unused, which is expected immediately after creation;
- no index is removed based only on an unused-index notice.

Leaked-password protection is an Auth setting, not SQL, and remains a separate
owner-controlled action.

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
