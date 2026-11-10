import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const checker = (await import(new URL("../scripts/check-production-identity.mjs", import.meta.url).href)) as {
  artifactSubsetFingerprint: (artifacts: Array<{ path: string; sha256: string }>) => string;
  validateProductionIdentity: (record: unknown) => string[];
};

const record = JSON.parse(
  await readFile(
    new URL("../../../docs/reports/production-identity/production-observation-2026-08-18.json", import.meta.url),
    "utf8"
  )
);

test("production identity record is complete and fail-closed", () => {
  assert.deepEqual(checker.validateProductionIdentity(record), []);
  assert.equal(record.source.commitSha.length, 40);
  assert.equal(record.verification.providerDeploymentRecordHasSourceSha, false);
  assert.equal(record.verification.level, "artifact_subset_match");
});

test("production identity rejects ambiguous or upgraded claims", () => {
  const invalid = structuredClone(record);
  invalid.source.commitSha = "main";
  invalid.verification.providerDeploymentRecordHasSourceSha = true;
  invalid.versionReconciliation.sameNamespace = true;
  assert.deepEqual(checker.validateProductionIdentity(invalid), [
    "source commitSha must be a full lowercase Git SHA",
    "source commitUrl does not match commitSha",
    "provider SHA evidence must remain false until a provider record proves it",
    "audit and Sites versions must remain separate namespaces"
  ]);
});

test("production identity fingerprint is deterministic", () => {
  assert.equal(
    checker.artifactSubsetFingerprint(record.verification.artifacts),
    record.verification.artifactSubsetSha256
  );
  assert.equal(
    checker.artifactSubsetFingerprint([...record.verification.artifacts].reverse()),
    record.verification.artifactSubsetSha256
  );
});

test("audit v54 is not misrepresented as a Sites deployment version", () => {
  assert.equal(record.provider.sitesVersion, 53);
  assert.equal(record.versionReconciliation.auditInputLabel, 54);
  assert.equal(record.versionReconciliation.sameNamespace, false);
  assert.equal(record.versionReconciliation.decision, "not_comparable");
});
