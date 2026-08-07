import assert from "node:assert/strict";
import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import test from "node:test";

const root = new URL("../", import.meta.url);
const [evidence, status, content, guidePack, geography, searchQa, searchIndex] = await Promise.all([
  readFile(new URL("src/generated/release-evidence.json", root), "utf8").then(JSON.parse),
  readFile(new URL("src/generated/status.json", root), "utf8").then(JSON.parse),
  readFile(new URL("src/generated/public-content.json", root), "utf8").then(JSON.parse),
  readFile(new URL("src/content/national-guides.json", root), "utf8").then(JSON.parse),
  readFile(new URL("src/generated/netherlands-geography.json", root), "utf8").then(JSON.parse),
  readFile(new URL("../../docs/reports/SEARCH_QA_MATRIX.json", root), "utf8").then(JSON.parse),
  readFile(new URL("public/data/search-index.json", root))
]);

test("release evidence is generated from current governed artifacts", () => {
  assert.equal(evidence.metrics.localRecords, content.stats.entities);
  assert.equal(evidence.metrics.nationalGuides, guidePack.guides.length);
  assert.equal(evidence.metrics.publishedRecords, content.stats.entities + guidePack.guides.length);
  assert.equal(evidence.metrics.municipalityRoutes, geography.stats.municipalities);
  assert.equal(evidence.metrics.searchQualityChecks, searchQa.totals.passed);
  assert.equal(evidence.searchQuality.failedChecks, 0);
  assert.equal(evidence.searchQuality.searchIndexSha256, createHash("sha256").update(searchIndex).digest("hex"));
});

test("public status uses the same generated counts and keeps open release gates explicit", () => {
  assert.equal(status.checkedAt, evidence.asOf);
  assert.equal(status.content.asOf, evidence.asOf);
  assert.match(status.website.summary, new RegExp(evidence.metrics.searchQualityChecks.toLocaleString("en-US")));
  assert.match(status.content.summary, new RegExp(String(evidence.metrics.localRecords)));
  assert.match(status.content.summary, new RegExp(String(evidence.metrics.nationalGuides)));
  assert.ok(status.limitations.some((item: string) => /Admin E2E and backup-and-restore remain release gates/i.test(item)));
});
