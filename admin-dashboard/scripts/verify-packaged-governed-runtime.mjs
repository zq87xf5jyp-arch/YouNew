import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const adminRoot = resolve(scriptDirectory, "..");
const runtimePath = resolve(adminRoot, "src/generated/governed-runtime.json");
const manifestPath = resolve(adminRoot, "src/generated/governed-runtime-manifest.json");

function requireCondition(condition, message) {
  if (!condition) {
    throw new Error(`Packaged governed runtime verification failed: ${message}`);
  }
}

const [runtimeText, manifestText] = await Promise.all([
  readFile(runtimePath, "utf8"),
  readFile(manifestPath, "utf8")
]);
const runtime = JSON.parse(runtimeText);
const manifest = JSON.parse(manifestText);
const sourceSha256 = createHash("sha256").update(runtimeText).digest("hex");
const entityIDs = runtime.entities?.map((entity) => entity.id) ?? [];
const publishedReleaseIDs = runtime.releases?.map((release) => release.id).sort() ?? [];

requireCondition(runtime.schemaVersion === 1, "unsupported runtime schemaVersion");
requireCondition(runtime.mode === "production", "runtime is not production-scoped");
requireCondition(manifest.schemaVersion === 1, "unsupported manifest schemaVersion");
requireCondition(manifest.source === "YouNew/Resources/Data/younew-runtime-data.json", "unexpected canonical source");
requireCondition(sourceSha256 === manifest.sourceSha256, "runtime SHA-256 does not match the manifest");
requireCondition(runtime.datasetFingerprint === manifest.datasetFingerprint, "dataset fingerprint mismatch");
requireCondition(runtime.outputChecksum === manifest.outputChecksum, "output checksum mismatch");
requireCondition(/^[a-f0-9]{64}$/.test(runtime.datasetFingerprint ?? ""), "invalid dataset fingerprint");
requireCondition(/^[a-f0-9]{64}$/.test(runtime.outputChecksum ?? ""), "invalid output checksum");
requireCondition(entityIDs.length > 0, "runtime has no published entities");
requireCondition(entityIDs.length === manifest.entityCount, "entity count mismatch");
requireCondition(new Set(entityIDs).size === entityIDs.length, "runtime contains duplicate entity IDs");
requireCondition(
  runtime.entities.every((entity) => entity.publicationStatus === "published"),
  "runtime contains a non-published entity"
);
requireCondition(
  Array.isArray(runtime.releases) &&
    runtime.releases.length > 0 &&
    runtime.releases.every((release) => release.status === "published"),
  "runtime contains an unpublished release"
);
requireCondition(
  JSON.stringify(publishedReleaseIDs) === JSON.stringify(manifest.publishedReleaseIds),
  "published release IDs do not match the manifest"
);

console.log(
  `Verified packaged governed runtime: ${manifest.entityCount} entities, SHA-256 ${sourceSha256}`
);
