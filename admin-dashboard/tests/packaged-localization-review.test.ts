import assert from "node:assert/strict";
import { execFileSync } from "node:child_process";
import { copyFileSync, mkdirSync, mkdtempSync, readFileSync, rmSync, writeFileSync } from "node:fs";
import { tmpdir } from "node:os";
import { dirname, join, resolve } from "node:path";
import test from "node:test";
import { fileURLToPath } from "node:url";

const adminRoot = resolve(dirname(fileURLToPath(import.meta.url)), "..");
const verifierPath = resolve(adminRoot, "scripts/verify-packaged-localization-review.mjs");
const snapshotPath = resolve(adminRoot, "src/generated/localization-review.json");

function createPackagedFixture() {
  const fixtureRoot = mkdtempSync(join(tmpdir(), "younew-packaged-localization-"));
  mkdirSync(resolve(fixtureRoot, "scripts"), { recursive: true });
  mkdirSync(resolve(fixtureRoot, "src/generated"), { recursive: true });
  copyFileSync(verifierPath, resolve(fixtureRoot, "scripts/verify-packaged-localization-review.mjs"));
  copyFileSync(snapshotPath, resolve(fixtureRoot, "src/generated/localization-review.json"));
  return fixtureRoot;
}

function runVerifier(fixtureRoot: string) {
  return execFileSync(
    process.execPath,
    [resolve(fixtureRoot, "scripts/verify-packaged-localization-review.mjs")],
    { encoding: "utf8", stdio: "pipe" }
  );
}

test("Hostinger package accepts the fail-closed localization review snapshot", (context) => {
  const fixtureRoot = createPackagedFixture();
  context.after(() => rmSync(fixtureRoot, { recursive: true, force: true }));
  assert.match(runVerifier(fixtureRoot), /Verified packaged localization review: 16 records, 16 review packets, 64 required human checks/);
});

test("Hostinger package rejects publication eligibility before human review passes", (context) => {
  const fixtureRoot = createPackagedFixture();
  context.after(() => rmSync(fixtureRoot, { recursive: true, force: true }));
  const fixtureSnapshotPath = resolve(fixtureRoot, "src/generated/localization-review.json");
  const snapshot = JSON.parse(readFileSync(fixtureSnapshotPath, "utf8"));
  snapshot.records[0].publication_eligible = true;
  writeFileSync(fixtureSnapshotPath, `${JSON.stringify(snapshot, null, 2)}\n`);

  assert.throws(
    () => runVerifier(fixtureRoot),
    /is eligible before passing review/
  );
});

test("Hostinger package rejects review packets with unresolved source evidence", (context) => {
  const fixtureRoot = createPackagedFixture();
  context.after(() => rmSync(fixtureRoot, { recursive: true, force: true }));
  const fixtureSnapshotPath = resolve(fixtureRoot, "src/generated/localization-review.json");
  const snapshot = JSON.parse(readFileSync(fixtureSnapshotPath, "utf8"));
  snapshot.review_packets[0].fields[0].source_ids.push("src.missing");
  writeFileSync(fixtureSnapshotPath, `${JSON.stringify(snapshot, null, 2)}\n`);

  assert.throws(
    () => runVerifier(fixtureRoot),
    /has an unresolved source ID/
  );
});
