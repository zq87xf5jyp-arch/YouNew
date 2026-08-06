import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const backup = await readFile(new URL("../scripts/backup-postgres.sh", import.meta.url), "utf8");
const restore = await readFile(new URL("../scripts/restore-postgres.sh", import.meta.url), "utf8");
const rehearsal = await readFile(new URL("../scripts/restore-rehearsal.sh", import.meta.url), "utf8");
const verification = await readFile(new URL("../supabase/verification/verify_after_migration.sql", import.meta.url), "utf8");
const restorePreparation = await readFile(new URL("../supabase/verification/prepare_restore_target.sql", import.meta.url), "utf8");
const restoreBoundaries = await readFile(new URL("../supabase/verification/restore_managed_boundaries.sql", import.meta.url), "utf8");
const config = await readFile(new URL("../playwright.config.ts", import.meta.url), "utf8");

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
  assert.match(restore, /restore_status = "pass"/);
  assert.match(restorePreparation, /alter default privileges for role supabase_admin/);
  assert.match(restoreBoundaries, /create trigger on_auth_user_created/);
  assert.match(verification, /younew_verification_results/);
  assert.match(verification, /where not passed/);
  assert.match(restore, /control_row_counts/);
  assert.match(restore, /restore-verification\.json/);
});

test("restore rehearsal uses an isolated Supabase stack and destroys its volume", () => {
  assert.match(rehearsal, /supabase start/);
  assert.match(rehearsal, /Docker daemon is not available/);
  assert.match(rehearsal, /PostgreSQL 17 or newer/);
  assert.match(rehearsal, /local supabase_admin role is not a superuser/);
  assert.match(rehearsal, /RESTORE_REHEARSAL_BASE_DIR/);
  assert.match(rehearsal, /refusing to use filesystem root/);
  assert.match(rehearsal, /production-migration-manifest\.json/);
  assert.match(rehearsal, /managed migration file is missing/);
  assert.match(rehearsal, /cp .*supabase\/migrations/);
  assert.match(rehearsal, /supabase migration repair/);
  assert.match(rehearsal, /historical bootstrap files stay untracked/);
  assert.match(rehearsal, /bash .*restore-postgres\.sh/);
  assert.match(rehearsal, /supabase stop.*--no-backup/);
});

test("Admin E2E has isolated and production-safe modes", () => {
  assert.match(config, /E2E_MUTATION_MODE/);
  assert.match(config, /YOUNEW_ADMIN_DEMO_MODE/);
  assert.match(config, /E2E_BASE_URL/);
  assert.match(config, /E2E_PORT/);
});
