import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import test from "node:test";

import { summarizeLocalizationReview, type LocalizationReviewSnapshot } from "../src/lib/localization-review.ts";

const sourceText = await readFile(
  new URL("../../DataProject/staging/release-critical-practical-guides-v2-localization-review-matrix.json", import.meta.url),
  "utf8"
);
const source = JSON.parse(sourceText) as LocalizationReviewSnapshot;
const generated = JSON.parse(
  await readFile(new URL("../src/generated/localization-review.json", import.meta.url), "utf8")
) as LocalizationReviewSnapshot;
const page = await readFile(new URL("../src/app/(admin)/localization-review/page.tsx", import.meta.url), "utf8");
const nav = await readFile(new URL("../src/components/admin/nav.tsx", import.meta.url), "utf8");

test("generated review snapshot is pinned to the governed source matrix", () => {
  const sourceSha256 = createHash("sha256").update(sourceText).digest("hex");
  assert.equal(generated.admin_snapshot.source_sha256, sourceSha256);
  assert.deepEqual(generated.records, source.records);
  assert.deepEqual(generated.review_dimensions, source.review_dimensions);
  assert.equal(generated.admin_snapshot.record_count, 16);
  assert.equal(generated.admin_snapshot.required_review_checks, 64);
});

test("review summary fails closed while human evidence is absent", () => {
  const summary = summarizeLocalizationReview(generated);
  assert.deepEqual(summary, {
    drafts: 16,
    reviewed: 0,
    eligible: 0,
    fieldCount: 796,
    requiredChecks: 64,
    releaseStatus: "NO-GO"
  });
  assert.equal(generated.publication_authorized, false);
  assert.ok(generated.records.every((record) => record.reviewer_id === null));
  assert.ok(generated.records.every((record) => record.evidence_registry_entry_id === null));
  assert.ok(generated.records.every((record) => record.publication_eligible === false));
  assert.deepEqual(new Set(generated.records.map((record) => record.review_category)), new Set(["government", "healthcare", "housing", "work", "education", "telecom", "transport"]));
});

test("Admin exposes a read-only evidence matrix without approval controls", () => {
  assert.match(nav, /href: "\/localization-review"/);
  assert.match(page, /Machine-assisted drafts are never treated as human approval/);
  assert.match(page, /No automated reviewer may satisfy these gates/);
  assert.match(page, /summary\.releaseStatus/);
  assert.match(page, /overflow-x-auto/);
  assert.match(page, /min-w-\[960px\]/);
  assert.doesNotMatch(page, /<form|<button|action=/i);
});
