import assert from "node:assert/strict";
import { spawnSync } from "node:child_process";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import test from "node:test";

const backup = await readFile(new URL("../scripts/backup-postgres.sh", import.meta.url), "utf8");
const restore = await readFile(new URL("../scripts/restore-postgres.sh", import.meta.url), "utf8");
const rehearsal = await readFile(new URL("../scripts/restore-rehearsal.sh", import.meta.url), "utf8");
const verification = await readFile(new URL("../supabase/verification/verify_after_migration.sql", import.meta.url), "utf8");
const restorePreparation = await readFile(new URL("../supabase/verification/prepare_restore_target.sql", import.meta.url), "utf8");
const restoreBoundaries = await readFile(new URL("../supabase/verification/restore_managed_boundaries.sql", import.meta.url), "utf8");
const dsnValidatorURL = new URL("../scripts/validate-local-postgres-dsn.py", import.meta.url);
const config = await readFile(new URL("../playwright.config.ts", import.meta.url), "utf8");
const disposableWorkflow = await readFile(new URL("../../.github/workflows/supabase-disposable-ci.yml", import.meta.url), "utf8");

test("backup is encrypted before persistence and excludes non-database assets explicitly", () => {
  assert.match(backup, /set -euo pipefail/);
  assert.match(backup, /--file \/dev\/stdout/);
  assert.match(backup, /SUPABASE_TEMPORARY_ACCESS/);
  assert.match(backup, /PGOPTIONS=.*jit=true/);
  assert.match(backup, /PGSSLMODE=.*require/);
  assert.match(backup, /--dry-run/);
  assert.match(backup, /--role .*postgres/);
  assert.match(backup, /age --recipient/);
  assert.match(backup, /storage_objects_included.*false/);
  assert.match(backup, /edge_functions_included.*false/);
  assert.doesNotMatch(backup, /younew-\$timestamp\.dump["']/);
});

test("restore refuses non-local database targets", () => {
  assert.match(restore, /set -euo pipefail/);
  assert.match(restore, /must target an isolated local database/);
  assert.match(restore, /--single-transaction/);
  assert.match(restore, /checksum does not match manifest/);
  assert.match(restore, /prepare_restore_target\.sql/);
  assert.match(restore, /restore_managed_boundaries\.sql/);
  assert.match(restore, /RESTORE_TARGET_MARKER is required/);
  assert.match(restore, /RESTORE_EXPECTED_MIGRATION_COUNT/);
  assert.match(restore, /--set expected_migration_count=/);
  assert.match(restore, /younew_restore_guard\.target_marker/);
  assert.ok(
    restore.indexOf("younew_restore_guard.target_marker") < restore.indexOf('psql --dbname "$restore_url" --set ON_ERROR_STOP=1 --file "$prepare_sql"'),
    "the disposable marker must be verified before destructive prepare SQL"
  );
  assert.match(restore, /restore_status = "pass"/);
  assert.match(restorePreparation, /alter default privileges for role postgres[\s\S]*revoke all privileges on tables from public, anon, authenticated, service_role/);
  assert.match(restorePreparation, /alter default privileges for role postgres[\s\S]*revoke all privileges on sequences from public, anon, authenticated, service_role/);
  assert.match(restorePreparation, /alter default privileges for role postgres[\s\S]*revoke execute on functions from public, anon, authenticated, service_role/);
  assert.match(restorePreparation, /alter default privileges for role supabase_admin[\s\S]*revoke all privileges on tables from public, anon, authenticated/);
  assert.match(restoreBoundaries, /RESTORE_EXPECTED_MANAGED_BOUNDARIES_JSON/);
  assert.match(restoreBoundaries, /RESTORE_EXPECTED_MANAGED_BOUNDARIES_SHA256/);
  assert.match(restoreBoundaries, /younew_restore_guard\.target_marker/);
  assert.match(restoreBoundaries, /extensions\.digest\(convert_to\(raw_text, 'UTF8'\), 'sha256'\)/);
  assert.match(restoreBoundaries, /expected->'buckets'/);
  assert.match(restoreBoundaries, /expected->'storage_policies'/);
  assert.match(restoreBoundaries, /expected->'auth_user_triggers'/);
  assert.match(restoreBoundaries, /from storage\.buckets/);
  assert.match(restoreBoundaries, /from pg_policies where schemaname='storage'/);
  assert.match(restoreBoundaries, /pg_get_triggerdef\(oid\)/);
  assert.doesNotMatch(restoreBoundaries, /create trigger on_auth_user_created/);
  assert.match(restoreBoundaries, /for item in select value from jsonb_array_elements\(expected->'storage_policies'\)/);
  assert.match(restoreBoundaries, /format\(\s*'create policy %I on storage\.objects as %s for %s to %s'/);
  assert.match(restoreBoundaries, /format\('drop policy %I on storage\.objects'/);
  assert.match(verification, /younew_verification_results/);
  assert.match(verification, /where not passed/);
  assert.match(restore, /control_row_counts/);
  assert.match(restore, /restore-verification\.json/);
});

test("restore DSN parsing rejects userinfo and query substring bypasses", () => {
  const validator = fileURLToPath(dsnValidatorURL);
  for (const dsn of [
    "postgresql://user:pass@localhost:5432/postgres",
    "postgresql://user:pass@[::1]:5432/postgres",
    "host=/tmp dbname=postgres user=postgres"
  ]) {
    assert.equal(spawnSync("python3", [validator, dsn]).status, 0, `${dsn} should be accepted as explicitly local`);
  }
  for (const dsn of [
    "postgresql://user:pass@localhost@remote.example/postgres",
    "postgresql://user:pass@remote.example/postgres?note=@localhost",
    "postgresql:///postgres?host=remote.example&note=@127.0.0.1",
    "host=remote.example application_name=@localhost dbname=postgres",
    "host=127.0.0.1 dbname=postgresql://remote.example/prod",
    "dbname='host=remote.example dbname=prod' host=127.0.0.1",
    "postgresql://localhost/postgres?dbname=postgresql%3A%2F%2Fremote.example%2Fprod",
    "postgresql://localhost/postgres?dbname=host%3Dremote.example%20dbname%3Dprod",
    "service=production host=127.0.0.1"
  ]) {
    assert.notEqual(spawnSync("python3", [validator, dsn]).status, 0, `${dsn} must be rejected`);
  }
});

test("restore rehearsal uses an isolated Supabase stack and destroys its volume", () => {
  assert.match(rehearsal, /supabase start/);
  assert.match(rehearsal, /Docker daemon is not available/);
  assert.match(rehearsal, /PostgreSQL 17 or newer/);
  assert.match(rehearsal, /local supabase_admin role is not a superuser/);
  assert.match(rehearsal, /RESTORE_REHEARSAL_BASE_DIR/);
  assert.match(rehearsal, /refusing to use filesystem root/);
  assert.match(rehearsal, /production-migration-manifest\.json/);
  assert.match(rehearsal, /migration file is missing/);
  assert.match(rehearsal, /cp .*supabase\/migrations/);
  assert.match(rehearsal, /supabase migration repair/);
  assert.match(rehearsal, /historical bootstrap files stay (?:intentionally )?untracked/);
  assert.match(rehearsal, /\.managedMigrations \+ \.pendingMigrations/);
  assert.match(rehearsal, /expected_migration_count/);
  assert.match(rehearsal, /RESTORE_EXPECTED_MIGRATION_COUNT="\$migration_count"/);
  assert.match(rehearsal, /RESTORE_SCHEMA_INVENTORY_SQL/);
  assert.match(rehearsal, /RESTORE_SCHEMA_INVENTORY_PATH/);
  assert.match(rehearsal, /bash .*restore-postgres\.sh/);
  assert.match(rehearsal, /RESTORE_TARGET_MARKER="\$restore_target_marker"/);
  assert.match(rehearsal, /supabase stop.*--no-backup/);
  assert.match(disposableWorkflow, /cp -R \.supabase-ci-runtime \.supabase-ci-restore-source/);
  assert.match(disposableWorkflow, /test -f \.supabase-ci-restore-source\/supabase\/config\.toml/);
});

test("Admin E2E has isolated and production-safe modes", () => {
  assert.match(config, /E2E_MUTATION_MODE/);
  assert.match(config, /YOUNEW_ADMIN_DEMO_MODE/);
  assert.match(config, /E2E_BASE_URL/);
});
