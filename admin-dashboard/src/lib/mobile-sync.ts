import runtimeArtifact from "@/generated/governed-runtime.json";
import runtimeManifest from "@/generated/governed-runtime-manifest.json";

const etag = `"${runtimeManifest.datasetFingerprint}"`;

const payload = {
  available: true,
  schema_version: 1,
  content_version: runtimeManifest.datasetFingerprint,
  generated_at: runtimeManifest.generatedAt,
  entity_count: runtimeManifest.entityCount,
  published_release_ids: runtimeManifest.publishedReleaseIds,
  artifact: runtimeArtifact
} as const;

const serializedPayload = JSON.stringify(payload);

export function buildMobileSyncPayload() {
  return {
    body: serializedPayload,
    contentVersion: runtimeManifest.datasetFingerprint,
    entityCount: runtimeManifest.entityCount,
    etag,
    generatedAt: runtimeManifest.generatedAt,
    publishedReleaseIds: runtimeManifest.publishedReleaseIds,
    sourceSha256: runtimeManifest.sourceSha256
  } as const;
}

export function requestMatchesCurrentVersion(ifNoneMatch: string | null) {
  return ifNoneMatch
    ?.split(",")
    .map((value) => value.trim())
    .some((value) => value === etag || value === `W/${etag}`) ?? false;
}
