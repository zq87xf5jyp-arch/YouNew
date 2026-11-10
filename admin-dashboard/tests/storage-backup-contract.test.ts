import assert from "node:assert/strict";
import { readFileSync } from "node:fs";
import test from "node:test";

const script = readFileSync(new URL("../scripts/backup-storage.sh", import.meta.url), "utf8");
const verifier = readFileSync(new URL("../scripts/verify-storage-backup.sh", import.meta.url), "utf8");

test("storage payload backup requires exact owner-authorized release identity", () => {
  assert.match(script, /PHASE6_OWNER_AUTHORIZATION_SHA/);
  assert.match(script, /APPROVED_RELEASE_SHA256/);
  assert.match(script, /must exactly match APPROVED_RELEASE_SHA256/);
});

test("storage payload backup is encrypted, reconciled and read-only remotely", () => {
  assert.match(script, /age --recipient/);
  assert.match(script, /downloaded object count/);
  assert.match(script, /remote_mutation_performed: false/);
  assert.doesNotMatch(script, /supabase storage (rm|mv)/);
  assert.doesNotMatch(script, /\.storage[\s\S]*?\.remove\(/);
});

test("storage restore rehearsal verifies archive identity, paths and every payload checksum", () => {
  assert.match(verifier, /archive SHA-256 does not match its manifest/);
  assert.match(verifier, /archive contains an unsafe path/);
  assert.match(verifier, /shasum -a 256 -c/);
  assert.match(verifier, /remote_restore_performed: false/);
});
