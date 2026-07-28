import { createHash } from "node:crypto";
import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const adminRoot = resolve(scriptDirectory, "..");
const repositoryRoot = resolve(adminRoot, "..");
const sourcePath = resolve(repositoryRoot, "YouNew/Resources/Data/younew-runtime-data.json");
const generatedDirectory = resolve(adminRoot, "src/generated");
const runtimePath = resolve(generatedDirectory, "governed-runtime.json");
const manifestPath = resolve(generatedDirectory, "governed-runtime-manifest.json");

function requireCondition(condition, message) {
  if (!condition) {
    throw new Error(`Governed runtime generation failed: ${message}`);
  }
}

async function writeAtomically(path, contents) {
  const temporaryPath = `${path}.tmp`;
  await writeFile(temporaryPath, contents, "utf8");
  await rename(temporaryPath, path);
}

const sourceText = await readFile(sourcePath, "utf8");
const artifact = JSON.parse(sourceText);
const entityIDs = artifact.entities?.map((entity) => entity.id) ?? [];

requireCondition(artifact.schemaVersion === 1, "unsupported schemaVersion");
requireCondition(artifact.mode === "production", "source artifact is not production-scoped");
requireCondition(/^[a-f0-9]{64}$/.test(artifact.datasetFingerprint ?? ""), "invalid dataset fingerprint");
requireCondition(/^[a-f0-9]{64}$/.test(artifact.outputChecksum ?? ""), "invalid output checksum");
requireCondition(entityIDs.length > 0, "source artifact has no published entities");
requireCondition(new Set(entityIDs).size === entityIDs.length, "source artifact contains duplicate entity IDs");
requireCondition(
  artifact.entities.every((entity) => entity.publicationStatus === "published"),
  "source artifact contains a non-published entity"
);
requireCondition(
  Array.isArray(artifact.releases) && artifact.releases.length > 0 && artifact.releases.every((release) => release.status === "published"),
  "source artifact contains an unpublished release"
);

const sourceSha256 = createHash("sha256").update(sourceText).digest("hex");
const manifest = {
  schemaVersion: 1,
  source: "YouNew/Resources/Data/younew-runtime-data.json",
  generatedAt: artifact.generatedAt,
  datasetFingerprint: artifact.datasetFingerprint,
  outputChecksum: artifact.outputChecksum,
  sourceSha256,
  entityCount: entityIDs.length,
  publishedReleaseIds: artifact.releases.map((release) => release.id).sort()
};

await mkdir(generatedDirectory, { recursive: true });
await writeAtomically(runtimePath, sourceText.endsWith("\n") ? sourceText : `${sourceText}\n`);
await writeAtomically(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`);

console.log(
  `Generated governed admin runtime: ${manifest.entityCount} entities, fingerprint ${manifest.datasetFingerprint}`
);
