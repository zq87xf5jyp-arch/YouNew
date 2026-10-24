import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const publicTruth = JSON.parse(
  await readFile(new URL("../src/generated/release-truth-public.json", import.meta.url), "utf8")
);
const adminTruth = JSON.parse(
  await readFile(new URL("../../src/generated/release-truth.json", import.meta.url), "utf8")
);

test("public and admin surfaces identify the same release-truth snapshot", () => {
  assert.equal(publicTruth.snapshotID, adminTruth.snapshotID);
  assert.equal(publicTruth.snapshotDigest, adminTruth.snapshotDigest);
  assert.equal(publicTruth.technicalVerdict, adminTruth.technicalVerdict);
  assert.equal(publicTruth.deploymentAuthorization, "not_granted");
});

test("public release truth is fail-closed without inventing zero link health", () => {
  assert.equal(publicTruth.technicalVerdict, "PARTIAL");
  assert.equal(publicTruth.publication.packagedPublishedRecords, 7);
  assert.equal(publicTruth.publication.inventoryRecords, 454);
  assert.deepEqual(publicTruth.publication.packagedCoverage, {
    kind: "ratio",
    unit: "percent",
    value: 1.5,
    numerator: 7,
    denominator: 454,
    state: "measured",
    reasonCode: null,
    formula: { id: "packaged-published-over-governed-inventory", version: 1 },
    sourceIDs: ["data-project-inventory", "packaged-runtime", "public-content-provenance"]
  });
  assert.equal(publicTruth.linkHealth.state, "unknown");
  assert.equal(publicTruth.linkHealth.value, null);
  assert.equal(publicTruth.linkHealth.denominator, null);
  assert.equal(publicTruth.gates.linkHealth, "blocked");
});

test("unobserved deployed metadata does not become an exact or declared deployed count", () => {
  assert.equal(publicTruth.publication.deployedState, "unknown");
  assert.equal(publicTruth.publication.deployedEvidenceLevel, "none");
  assert.equal(adminTruth.publication.deployed.entityCount, null);
  assert.equal(adminTruth.publication.deployed.declaredEntityCount, null);
});
