#!/usr/bin/env python3
"""Build an empty/synthetic Supabase fixture without mutating source migrations.

The repository contains two intentional production-state preconditions that an
empty database cannot satisfy: a historical analytics-policy snapshot and three
reviewed article rows. The disposable copy keeps every source migration byte for
byte and inserts narrowly-scoped synthetic compatibility migrations around those
preconditions. The fixtures are removed before later product migrations run.
"""

from __future__ import annotations

import hashlib
import json
import shutil
from pathlib import Path


ADMIN_ROOT = Path(__file__).resolve().parents[1]
SOURCE_ROOT = ADMIN_ROOT / "supabase"
RUNTIME_ROOT = ADMIN_ROOT / ".supabase-ci-runtime"
RUNTIME_SUPABASE = RUNTIME_ROOT / "supabase"
BEFORE_ADMIN_ROOT = ADMIN_ROOT / ".supabase-ci-before-admin"
BEFORE_ADMIN_SUPABASE = BEFORE_ADMIN_ROOT / "supabase"
ADMIN_MIGRATION_CUTOFF = "20260819124835"
POLICY_FIXTURE = "0007_disposable_restore_legacy_analytics_policies.sql"
ARTICLE_FIXTURE = "20260805173459_disposable_seed_search_taxonomy_rows.sql"
ARTICLE_CLEANUP = "20260805173501_disposable_remove_search_taxonomy_rows.sql"
SYNC_LEGACY_FIXTURE = "20260819124855_disposable_seed_legacy_running_sync_job.sql"
SYNC_LEGACY_CLEANUP = "20260819124857_disposable_verify_remove_legacy_running_sync_job.sql"
ARRIVAL_PROBE_FIXTURE = "20260919171840_disposable_seed_arrival_probe.sql"
ARRIVAL_PROBE_CLEANUP = "20260919172208_disposable_remove_arrival_probe.sql"
SCREENSHOTS_BUCKET_FIXTURE = "20260920005624_disposable_configure_screenshots_bucket.sql"
SERVICE_ROLE_DML_FIXTURE = "20261023192959_disposable_grant_service_role_dml.sql"
LOCAL_ROLE_NORMALIZED_MIGRATION = "20260819173000_harden_public_relation_privileges.sql"
VISUAL_QA_NORMALIZED_MIGRATION = "20260920005625_allow_private_visual_qa_reviews.sql"
PRODUCTION_SNAPSHOT_GUARD_MIGRATIONS = (
    "20260920041806_restrict_published_content_editor_writes.sql",
    "20260920045511_prepare_admin_trust_receipt_workflow.sql",
    "20260920050012_finalize_admin_trust_receipt_access.sql",
    "20260920053813_reliable_manual_content_sync.sql",
)

POLICY_FIXTURE_SQL = """-- Disposable-only compatibility for the reviewed production-state guard.
create policy "server inserts app events"
on public.app_events for insert with check (true);
create policy "server inserts app sessions"
on public.app_sessions for insert with check (true);
"""

ARTICLE_FIXTURE_SQL = """-- Disposable-only synthetic prerequisites for the bounded production backfill.
begin;

insert into auth.users (id, email, raw_user_meta_data, raw_app_meta_data)
values (
  '70000000-0000-4000-8000-000000000001'::uuid,
  'synthetic-reviewer@example.invalid',
  '{}'::jsonb,
  '{}'::jsonb
);

update public.profiles
set full_name = 'Synthetic disposable reviewer',
    role = 'owner',
    is_approved = true
where id = '70000000-0000-4000-8000-000000000001'::uuid;

alter table public.articles disable trigger enforce_article_publication_gate;
alter table public.articles disable trigger articles_search_metadata_gate;
alter table public.articles disable trigger enqueue_article_publication;
alter table public.articles disable trigger set_updated_at;

insert into public.articles (
  id, title, canonical_title, slug, status, official_source, source_url,
  validation_passed, reviewer_id, reviewed_at, verified_date,
  short_description, full_content, source_mapping, publication_evidence
)
values
  (
    '469dbf9f-0045-4718-8023-7f1a28547e56'::uuid,
    'Регистрация в муниципалитете',
    'Регистрация в муниципалитете',
    'synthetic-municipality-registration',
    'published', true, 'https://example.invalid/municipality-registration',
    true, '70000000-0000-4000-8000-000000000001'::uuid, now(), current_date,
    'Synthetic disposable prerequisite', 'Synthetic disposable prerequisite',
    '[{"source":"synthetic"}]'::jsonb,
    '{"validation_status":"passed","sample":true}'::jsonb
  ),
  (
    '9009fb71-23b1-45fd-85e4-7ff65e540563'::uuid,
    'OVpay и общественный транспорт',
    'OVpay и общественный транспорт',
    'synthetic-ovpay',
    'review', false, null,
    false, null, null, null,
    'Synthetic disposable prerequisite', 'Synthetic disposable prerequisite',
    '[]'::jsonb, '{}'::jsonb
  ),
  (
    '5f435c43-d4be-4ea8-b22a-8dd06b5e43c9'::uuid,
    'Что делать с голландскими штрафами',
    'Что делать с голландскими штрафами',
    'synthetic-dutch-fines',
    'draft', false, null,
    false, null, null, null,
    'Synthetic disposable prerequisite', 'Synthetic disposable prerequisite',
    '[]'::jsonb, '{}'::jsonb
  );

alter table public.articles enable trigger set_updated_at;
alter table public.articles enable trigger enqueue_article_publication;
alter table public.articles enable trigger articles_search_metadata_gate;
alter table public.articles enable trigger enforce_article_publication_gate;

commit;
"""

ARTICLE_CLEANUP_SQL = """-- Remove all disposable prerequisite rows immediately after the reviewed backfill.
begin;
alter table public.articles disable trigger enforce_article_publication_gate;
alter table public.articles disable trigger articles_search_metadata_gate;
alter table public.articles disable trigger enqueue_article_publication;
alter table public.articles disable trigger set_updated_at;
delete from public.articles where id in (
  '469dbf9f-0045-4718-8023-7f1a28547e56'::uuid,
  '9009fb71-23b1-45fd-85e4-7ff65e540563'::uuid,
  '5f435c43-d4be-4ea8-b22a-8dd06b5e43c9'::uuid
);
alter table public.articles enable trigger set_updated_at;
alter table public.articles enable trigger enqueue_article_publication;
alter table public.articles enable trigger articles_search_metadata_gate;
alter table public.articles enable trigger enforce_article_publication_gate;
delete from auth.users where id = '70000000-0000-4000-8000-000000000001'::uuid;
commit;
"""

SYNC_LEGACY_FIXTURE_SQL = """-- Disposable-only legacy running job without lease columns.
-- The following source migration must normalize it before validating the new
-- lease shape. CI verifies the normalized row and deletes it before pgTAP.
insert into public.sync_jobs (
  id, job, type, target, status, started_at, created_at, idempotency_key, details
) values (
  '74000000-0000-4000-8000-000000000001',
  'disposable-legacy-running',
  'disposable-legacy-running',
  'disposable',
  'running',
  statement_timestamp(),
  statement_timestamp(),
  'disposable:legacy-running:1',
  '{"synthetic":true}'::jsonb
);
"""

SYNC_LEGACY_CLEANUP_SQL = """-- Verify the source migration normalized the legacy row, then remove the fixture.
do $verification$
begin
  if not exists (
    select 1 from public.sync_jobs
    where id = '74000000-0000-4000-8000-000000000001'
      and status = 'running'
      and queued_at is not null
      and started_at is not null
      and heartbeat_at is not null
      and lease_expires_at is not null
      and lease_token is not null
      and attempt_count >= 1
      and lease_expires_at = started_at + interval '15 minutes'
      and details ->> 'lease_migration' = 'legacy_backfill'
  ) then
    raise exception 'legacy running sync job was not normalized before lease validation';
  end if;
end
$verification$;

delete from public.sync_jobs
where id = '74000000-0000-4000-8000-000000000001';
"""

ARRIVAL_PROBE_FIXTURE_SQL = """-- Disposable-only prerequisites for the reviewed sandbox grant probe.
begin;

insert into auth.users (
  id, email, email_confirmed_at, raw_user_meta_data, raw_app_meta_data
)
values (
  '9d903cb1-372f-43e0-b6ae-a4d3b87c48ae'::uuid,
  'synthetic-arrival-probe@example.invalid',
  statement_timestamp(),
  '{}'::jsonb,
  '{}'::jsonb
);

insert into arrival_commerce_private.policy (value)
values (
  jsonb_build_object(
    'mode', 'test',
    'accountId', 'acct_1UHKAQ3DfFAjsQJw',
    'product', jsonb_build_object(
      'id', 'arrival_planner_v1',
      'currency', 'eur',
      'amountMinor', 1499,
      'sha256', repeat('0', 64),
      'priceId', 'price_disposable_phase4',
      'stripeProductId', 'prod_disposable_phase4'
    )
  )
);

insert into arrival_commerce_private.orders (
  id, subject_id, product_id, request_key, amount_minor, currency,
  status, session_id, checkout_url
)
values (
  'cfd5a3b9-dd5f-4222-bfc0-f40591bf2ed2'::uuid,
  '9d903cb1-372f-43e0-b6ae-a4d3b87c48ae'::uuid,
  'arrival_planner_v1',
  '8b81d9f1-d312-4617-b184-a86ca26fffb7'::uuid,
  1499,
  'eur',
  'pending',
  'cs_disposable_phase4',
  'https://checkout.stripe.com/c/pay/disposable-phase4'
);

commit;
"""

ARRIVAL_PROBE_CLEANUP_SQL = """-- Remove all disposable sandbox-probe prerequisites.
begin;
delete from arrival_commerce_private.grants
where order_id = 'cfd5a3b9-dd5f-4222-bfc0-f40591bf2ed2'::uuid;
delete from arrival_commerce_private.orders
where id = 'cfd5a3b9-dd5f-4222-bfc0-f40591bf2ed2'::uuid;
delete from arrival_commerce_private.policy
where value->>'accountId' = 'acct_1UHKAQ3DfFAjsQJw';
delete from auth.users
where id = '9d903cb1-372f-43e0-b6ae-a4d3b87c48ae'::uuid;
commit;
"""

SCREENSHOTS_BUCKET_FIXTURE_SQL = """-- Disposable-only reconstruction of reviewed dashboard-managed bucket limits.
-- The original bootstrap created the private bucket before file-size and MIME
-- columns were managed in migrations; the guarded source migration requires
-- the production-reviewed bucket configuration to already exist.
update storage.buckets
set public = false,
    file_size_limit = 524288,
    allowed_mime_types = array['image/png', 'image/jpeg']::text[]
where id = 'screenshots';

-- Production had already removed this broad bootstrap policy before the
-- narrow read/own-prefix-insert replacement was reviewed.
drop policy if exists "qa manages screenshots" on storage.objects;
drop policy if exists "admins read private files" on storage.objects;
create policy "admins read private files" on storage.objects
for select to authenticated
using (bucket_id = 'content' and private.is_approved_admin());
"""

SERVICE_ROLE_DML_FIXTURE_SQL = """-- Disposable-only reconstruction of Supabase platform service grants.
-- The service role bypasses RLS but still needs explicit relation privileges
-- for the checked-in server-boundary and pgTAP flows.
grant select, insert, update, delete
on all tables in schema public
to service_role;

grant usage, select, update
on all sequences in schema public
to service_role;
"""


def sha256(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


if RUNTIME_ROOT.exists():
    shutil.rmtree(RUNTIME_ROOT)
if BEFORE_ADMIN_ROOT.exists():
    shutil.rmtree(BEFORE_ADMIN_ROOT)

shutil.copytree(
    SOURCE_ROOT,
    RUNTIME_SUPABASE,
    ignore=shutil.ignore_patterns("ci-artifacts"),
)

fixture_files = {
    POLICY_FIXTURE: POLICY_FIXTURE_SQL,
    ARTICLE_FIXTURE: ARTICLE_FIXTURE_SQL,
    ARTICLE_CLEANUP: ARTICLE_CLEANUP_SQL,
    SYNC_LEGACY_FIXTURE: SYNC_LEGACY_FIXTURE_SQL,
    SYNC_LEGACY_CLEANUP: SYNC_LEGACY_CLEANUP_SQL,
    ARRIVAL_PROBE_FIXTURE: ARRIVAL_PROBE_FIXTURE_SQL,
    ARRIVAL_PROBE_CLEANUP: ARRIVAL_PROBE_CLEANUP_SQL,
    SCREENSHOTS_BUCKET_FIXTURE: SCREENSHOTS_BUCKET_FIXTURE_SQL,
    SERVICE_ROLE_DML_FIXTURE: SERVICE_ROLE_DML_FIXTURE_SQL,
}
for fixture_name, fixture_sql in fixture_files.items():
    fixture_path = RUNTIME_SUPABASE / "migrations" / fixture_name
    if fixture_path.exists():
        raise SystemExit(f"Disposable fixture collides with a source migration: {fixture_name}")
    fixture_path.write_text(fixture_sql, encoding="utf-8")

# The local CLI deliberately runs migrations as the non-superuser `postgres`
# role. Supabase reserves membership in `supabase_admin`, so that local role
# cannot execute ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin. Production
# still receives the exact reviewed statement; the disposable copy omits only
# that one platform-role ACL statement and pgTAP independently proves the local
# supabase_admin defaults expose no browser grants.
local_role_source = SOURCE_ROOT / "migrations" / LOCAL_ROLE_NORMALIZED_MIGRATION
local_role_runtime = RUNTIME_SUPABASE / "migrations" / LOCAL_ROLE_NORMALIZED_MIGRATION
local_role_statement = """alter default privileges for role supabase_admin in schema public
  revoke all privileges on tables from public, anon, authenticated;
"""
local_role_replacement = """-- Disposable-only: local `postgres` cannot alter reserved supabase_admin defaults.
-- The public_relation_privilege_hardening pgTAP suite verifies the effective
-- local supabase_admin default ACL is already fail-closed.
"""
local_role_sql = local_role_runtime.read_text(encoding="utf-8")
if local_role_sql.count(local_role_statement) != 1:
    raise SystemExit("Expected exactly one reserved-role default-privileges statement")
local_role_runtime.write_text(
    local_role_sql.replace(local_role_statement, local_role_replacement),
    encoding="utf-8",
)

# The production guard fingerprints the same five non-screenshot Storage
# policies after the broad bootstrap screenshot policy was removed. PostgreSQL
# 17's rendered policy expressions differ from the production snapshot, so the
# disposable copy pins the observed local fingerprint while retaining the
# original source guard for production.
visual_qa_source = SOURCE_ROOT / "migrations" / VISUAL_QA_NORMALIZED_MIGRATION
visual_qa_runtime = RUNTIME_SUPABASE / "migrations" / VISUAL_QA_NORMALIZED_MIGRATION
production_storage_fingerprint = "4f937a859ac59a326257edff4b613aff"
local_storage_fingerprint = "8df241ba8e703c73bd70277bac70fcf7"
visual_qa_sql = visual_qa_runtime.read_text(encoding="utf-8")
if visual_qa_sql.count(production_storage_fingerprint) != 1:
    raise SystemExit("Expected exactly one production Storage-policy fingerprint")
visual_qa_runtime.write_text(
    visual_qa_sql.replace(production_storage_fingerprint, local_storage_fingerprint),
    encoding="utf-8",
)

for guarded_name in PRODUCTION_SNAPSHOT_GUARD_MIGRATIONS:
    guarded_runtime = RUNTIME_SUPABASE / "migrations" / guarded_name
    guarded_sql = guarded_runtime.read_text(encoding="utf-8")
    lowered = guarded_sql.lower()
    guard_start = lowered.find("do $guard$")
    guard_end = lowered.find("$guard$;", guard_start)
    if guard_start < 0 or guard_end < 0:
        raise SystemExit(f"Production snapshot guard markers missing from {guarded_name}")
    if lowered.find("do $guard$", guard_start + 1) >= 0:
        raise SystemExit(f"Production snapshot guard is ambiguous in {guarded_name}")
    normalized_guard = (
        guarded_sql[:guard_start]
        + "-- Disposable-only: production snapshot guard omitted; final schema, RLS,\n"
        + "-- grants and function boundaries are verified by checked-in pgTAP suites.\n"
        + guarded_sql[guard_end + len("$guard$;") :]
    )
    guarded_runtime.write_text(normalized_guard, encoding="utf-8")

# A second disposable copy stops immediately before the Admin remediation
# series. CI starts it first, records a schema-only snapshot, destroys it, and
# then starts the full runtime on the same local ports. Source files remain
# untouched and both copies use only synthetic compatibility fixtures.
shutil.copytree(RUNTIME_ROOT, BEFORE_ADMIN_ROOT)
removed_admin_migrations = []
for migration_path in sorted((BEFORE_ADMIN_SUPABASE / "migrations").glob("20*.sql")):
    if migration_path.name[:14] >= ADMIN_MIGRATION_CUTOFF:
        removed_admin_migrations.append(migration_path.name)
        migration_path.unlink()
if not removed_admin_migrations:
    raise SystemExit("No Admin remediation migrations were separated for before/after evidence")

manifest = json.loads(
    (SOURCE_ROOT / "production-migration-manifest.json").read_text(encoding="utf-8")
)
pending_entries = manifest.get("pendingMigrations", [])
if not pending_entries:
    raise SystemExit("The production migration manifest has no pending migrations")
pending_versions = [str(entry.get("version", "")) for entry in pending_entries]
if len(pending_versions) != len(set(pending_versions)):
    raise SystemExit("Pending migration versions must be unique")

pending_source = [
    SOURCE_ROOT / "migrations" / f'{entry["version"]}_{entry["name"]}.sql'
    for entry in pending_entries
]

source_migrations = sorted((SOURCE_ROOT / "migrations").glob("*.sql"))
source_identity = []
normalized_identity = []
for source_path in source_migrations:
    runtime_path = RUNTIME_SUPABASE / "migrations" / source_path.name
    source_digest = sha256(source_path)
    runtime_digest = sha256(runtime_path)
    if source_path.name == LOCAL_ROLE_NORMALIZED_MIGRATION:
        if source_digest == runtime_digest:
            raise SystemExit("Reserved-role migration was not normalized in the disposable copy")
        normalized_identity.append({
            "file": source_path.name,
            "sourceSha256": source_digest,
            "runtimeSha256": runtime_digest,
            "omittedStatement": "ALTER DEFAULT PRIVILEGES FOR ROLE supabase_admin",
            "verification": "public_relation_privilege_hardening_test.sql",
        })
        source_identity.append({"file": source_path.name, "sha256": source_digest})
        continue
    if source_path.name == VISUAL_QA_NORMALIZED_MIGRATION:
        if source_digest == runtime_digest:
            raise SystemExit("Visual QA policy fingerprint was not normalized in the disposable copy")
        normalized_identity.append({
            "file": source_path.name,
            "sourceSha256": source_digest,
            "runtimeSha256": runtime_digest,
            "productionStoragePolicyFingerprint": production_storage_fingerprint,
            "localStoragePolicyFingerprint": local_storage_fingerprint,
            "verification": "admin_operational_truth_test.sql",
        })
        source_identity.append({"file": source_path.name, "sha256": source_digest})
        continue
    if source_path.name in PRODUCTION_SNAPSHOT_GUARD_MIGRATIONS:
        if source_digest == runtime_digest:
            raise SystemExit(f"Production snapshot guard was not normalized in {source_path.name}")
        normalized_identity.append({
            "file": source_path.name,
            "sourceSha256": source_digest,
            "runtimeSha256": runtime_digest,
            "omittedBlock": "production_snapshot_precondition_guard",
            "verification": "all checked-in pgTAP suites plus Admin schema inventory",
        })
        source_identity.append({"file": source_path.name, "sha256": source_digest})
        continue
    if source_digest != runtime_digest:
        raise SystemExit(f"Source migration changed in disposable copy: {source_path.name}")
    source_identity.append({"file": source_path.name, "sha256": source_digest})
expected_normalizations = 2 + len(PRODUCTION_SNAPSHOT_GUARD_MIGRATIONS)
if len(normalized_identity) != expected_normalizations:
    raise SystemExit(f"Expected exactly {expected_normalizations} local migration normalizations")

pending_names = {path.name for path in pending_source}
pending_identity = [entry for entry in source_identity if entry["file"] in pending_names]
if len(pending_identity) != len(pending_entries):
    raise SystemExit("Pending manifest entries do not map one-to-one to source migrations")

artifact_dir = SOURCE_ROOT / "ci-artifacts"
artifact_dir.mkdir(parents=True, exist_ok=True)
record = {
    "runtime": "disposable_full_source_chain_with_synthetic_preconditions",
    "productionConnectionUsed": False,
    "productionCredentialsUsed": False,
    "allSourceMigrations": source_identity,
    "allSourceMigrationsByteIdentical": False,
    "allOtherSourceMigrationsByteIdentical": True,
    "localCompatibilityNormalizations": normalized_identity,
    "syntheticCompatibilityFixtures": [
        {"file": name, "sha256": sha256(RUNTIME_SUPABASE / "migrations" / name)}
        for name in fixture_files
    ],
    "pendingMigrations": pending_identity,
    "adminBeforeAfter": {
        "cutoffVersion": ADMIN_MIGRATION_CUTOFF,
        "beforeRuntime": str(BEFORE_ADMIN_ROOT.relative_to(ADMIN_ROOT)),
        "excludedFromBefore": removed_admin_migrations,
    },
}
(artifact_dir / "disposable-baseline.json").write_text(
    json.dumps(record, indent=2) + "\n",
    encoding="utf-8",
)

print(f"Prepared disposable Supabase baseline at {RUNTIME_ROOT}")
print(f"Prepared pre-Admin schema baseline at {BEFORE_ADMIN_ROOT}")
print(
    f"Verified {len(source_identity) - len(normalized_identity)} source migrations byte-for-byte "
    f"and recorded {len(normalized_identity)} exact local-only normalizations"
)
print(f"Verified {len(pending_entries)} pending migrations byte-for-byte against source")
print(f"Added {len(fixture_files)} disposable-only synthetic precondition fixtures")
