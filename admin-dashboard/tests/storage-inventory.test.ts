import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const script = readFileSync(new URL("../scripts/storage-inventory.sh", import.meta.url), "utf8");

test("storage inventory is metadata-only and excludes object-level personal data", () => {
  assert.match(script, /payload_backup_status: "not_performed_metadata_only"/);
  assert.match(script, /object names and owner identifiers intentionally excluded/);
  assert.doesNotMatch(script, /select[\s\S]*?o\.name,/i);
  assert.doesNotMatch(script, /select[\s\S]*?owner_id/i);
});

test("storage inventory fails closed without an explicit database target", () => {
  assert.match(script, /DATABASE_URL is required/);
  assert.match(script, /--set ON_ERROR_STOP=1/);
  assert.match(script, /umask 077/);
});
