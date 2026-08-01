import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const backup = await readFile(new URL("../scripts/backup-postgres.sh", import.meta.url), "utf8");
const restore = await readFile(new URL("../scripts/restore-postgres.sh", import.meta.url), "utf8");
const rehearsal = await readFile(new URL("../scripts/restore-rehearsal.sh", import.meta.url), "utf8");
const config = await readFile(new URL("../playwright.config.ts", import.meta.url), "utf8");

test("backup is encrypted before persistence and excludes non-database assets explicitly", () => {
  assert.match(backup, /--file \/dev\/stdout/);
  assert.match(backup, /age --recipient/);
  assert.match(backup, /storage_objects_included.*false/);
  assert.match(backup, /edge_functions_included.*false/);
  assert.doesNotMatch(backup, /younew-\$timestamp\.dump["']/);
});

test("restore refuses non-local database targets", () => {
  assert.match(restore, /must target an isolated local database/);
  assert.match(restore, /--single-transaction/);
  assert.match(restore, /checksum does not match manifest/);
  assert.match(restore, /control_row_counts/);
  assert.match(restore, /restore-verification\.json/);
});

test("restore rehearsal uses an isolated Supabase stack and destroys its volume", () => {
  assert.match(rehearsal, /supabase start/);
  assert.match(rehearsal, /Docker daemon is not available/);
  assert.match(rehearsal, /PostgreSQL 17 or newer/);
  assert.match(rehearsal, /supabase stop.*--no-backup/);
});

test("Admin E2E has isolated and production-safe modes", () => {
  assert.match(config, /E2E_MUTATION_MODE/);
  assert.match(config, /YOUNEW_ADMIN_DEMO_MODE/);
  assert.match(config, /E2E_BASE_URL/);
});
