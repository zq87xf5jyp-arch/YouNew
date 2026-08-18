import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const migration = await readFile(
  new URL("../supabase/migrations/20260818192423_deduplicate_business_inquiry_submissions.sql", import.meta.url),
  "utf8"
);
const sqlTest = await readFile(
  new URL("../supabase/tests/business_inquiry_deduplication_test.sql", import.meta.url),
  "utf8"
);
const edge = await readFile(
  new URL("../supabase/functions/submit-business-inquiry/index.ts", import.meta.url),
  "utf8"
);

test("duplicate suppression is transaction-safe, bounded, and does not persist a PII fingerprint", () => {
  assert.match(migration, /pg_advisory_xact_lock\(hashtextextended\(/);
  assert.match(migration, /created_at >= v_now - interval '15 minutes'/);
  assert.match(migration, /is not distinct from v_phone/);
  assert.match(migration, /target_audience = v_audience/);
  assert.match(migration, /requested_placements = v_placements/);
  assert.doesNotMatch(migration, /add column[\s\S]*(fingerprint|dedupe_hash|email_hash)/i);
});

test("an exact valid retry returns the original safe receipt before the insert", () => {
  const duplicateLookup = migration.indexOf("business_inquiry_duplicate_suppressed");
  const insert = migration.indexOf("insert into public.business_inquiries");
  assert.ok(duplicateLookup > 0 && insert > duplicateLookup);
  assert.match(migration, /select v_existing_id, v_existing_code, v_existing_created_at/);
  assert.match(migration, /return;/);
  assert.match(migration, /returns table \(id uuid, confirmation_code text, created_at timestamptz\)/);
});

test("duplicate audit metadata and API receipt remain PII-minimised", () => {
  assert.match(migration, /'business_inquiry_duplicate_suppressed'/);
  assert.match(migration, /jsonb_build_object\('status', v_existing_status, 'source_page', v_source_page, 'window_minutes', 15\)/);
  assert.doesNotMatch(migration, /jsonb_build_object\([^)]*(email|company|contact|message)/);
  assert.match(edge, /confirmationId: receipt\.confirmation_code/);
  assert.match(edge, /createdAt: receipt\.created_at/);
});

test("pgTAP covers exact retry, material changes, expiry, validation, and rate limiting", () => {
  for (const evidence of [
    "an exact retry returns the original receipt",
    "an exact retry creates one correctly classified pilot inquiry row",
    "a material payload change creates a new inquiry",
    "an expired dedupe window creates a new receipt",
    "invalid consent cannot recover an existing receipt",
    "duplicate retries still consume the rate limit"
  ]) {
    assert.match(sqlTest, new RegExp(evidence));
  }
});
