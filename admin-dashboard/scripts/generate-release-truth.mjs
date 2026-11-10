import { createHash } from "node:crypto";
import { spawnSync } from "node:child_process";
import { readFile, readdir, writeFile } from "node:fs/promises";
import { dirname, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const adminRoot = resolve(scriptDirectory, "..");
const repositoryRoot = resolve(adminRoot, "..");
const productionEvidenceDirectory = resolve(repositoryRoot, "docs/reports/production-identity");
const outputPath = resolve(adminRoot, "src/generated/release-truth.json");
const publicOutputPath = resolve(repositoryRoot, "admin-dashboard/public-site/src/generated/release-truth-public.json");
const compatibilityOutputPaths = {
  releaseReadiness: resolve(adminRoot, "src/generated/release-readiness.json"),
  adminTrustDashboard: resolve(adminRoot, "src/generated/trust-dashboard.json"),
  publicTrustDashboard: resolve(repositoryRoot, "admin-dashboard/public-site/src/generated/trust-dashboard.json")
};
const releaseGeneratedPaths = [
  outputPath,
  publicOutputPath,
  ...Object.values(compatibilityOutputPaths)
];

const paths = {
  dataProject: resolve(adminRoot, "src/generated/data-project-dashboard.json"),
  runtimeManifest: resolve(adminRoot, "src/generated/governed-runtime-manifest.json"),
  contentProvenance: resolve(repositoryRoot, "admin-dashboard/public-site/public/data/content-provenance.json")
};

const sha256 = (value) => createHash("sha256").update(value).digest("hex");
const stableJSONString = (value) => `${JSON.stringify(value, null, 2)}\n`;

function gitOutput(args) {
  const result = spawnSync(process.env.GIT_BINARY ?? "git", args, {
    cwd: repositoryRoot,
    encoding: "utf8",
    maxBuffer: 10 * 1024 * 1024
  });
  if (result.status !== 0) throw new Error(result.stderr.trim() || `git ${args.join(" ")} failed`);
  return result.stdout.trim();
}

function candidateSourceIdentity() {
  const environmentSHA = process.env.GITHUB_SHA?.toLowerCase();
  const checkoutCommit = gitOutput(["rev-parse", "HEAD"]).toLowerCase();
  if (!/^[a-f0-9]{40}$/.test(checkoutCommit)) throw new Error("Checked-out commit must be a full lowercase Git SHA.");
  if (environmentSHA && /^[a-f0-9]{40}$/.test(environmentSHA) && environmentSHA !== checkoutCommit) {
    throw new Error("GITHUB_SHA does not match the checked-out commit.");
  }
  const candidateCommit = (/^[a-f0-9]{40}$/.test(environmentSHA ?? "")
    ? environmentSHA
    : checkoutCommit).toLowerCase();
  if (!/^[a-f0-9]{40}$/.test(candidateCommit)) throw new Error("Candidate commit must be a full lowercase Git SHA.");
  const sourceTreeExclusions = releaseGeneratedPaths.map((path) => relative(repositoryRoot, path));
  const sourceTreeStatus = gitOutput([
    "status",
    "--porcelain",
    "--untracked-files=all",
    "--",
    ".",
    ...sourceTreeExclusions.map((path) => `:(exclude)${path}`)
  ]);
  const sourceTreeState = sourceTreeStatus === "" ? "clean" : "dirty";
  return { candidateCommit, sourceTreeState, sourceTreeExclusions };
}

async function readJSON(path) {
  const bytes = await readFile(path);
  return { path, bytes, sha256: sha256(bytes), value: JSON.parse(bytes.toString("utf8")) };
}

async function latestProductionObservation() {
  const candidates = (await readdir(productionEvidenceDirectory))
    .filter((name) => /^production-observation-.*\.json$/.test(name));
  const observations = await Promise.all(candidates.map((name) => readJSON(resolve(productionEvidenceDirectory, name))));
  observations.sort((left, right) => String(left.value.observedAt).localeCompare(String(right.value.observedAt)));
  const latest = observations.at(-1);
  if (!latest) throw new Error("No production identity observation is available.");
  return latest;
}

function evidenceMetric({ kind, unit, value, numerator, denominator, state, reasonCode, formulaID, sourceIDs }) {
  return {
    kind,
    unit,
    value,
    numerator: numerator ?? null,
    denominator: denominator ?? null,
    state,
    reasonCode: reasonCode ?? null,
    formula: { id: formulaID, version: 1 },
    sourceIDs
  };
}

function maxTimestamp(values) {
  return values
    .filter((value) => typeof value === "string" && !Number.isNaN(Date.parse(value)))
    .map((value) => new Date(value).toISOString())
    .sort()
    .at(-1) ?? null;
}

function productionMetadataMatch(observation, provenanceInput, runtimeManifest) {
  const deployedProvenance = observation.value.verification?.artifacts?.find((artifact) => artifact.path === "/data/content-provenance.json");
  return Boolean(
    deployedProvenance &&
    deployedProvenance.sha256 === provenanceInput.sha256 &&
    provenanceInput.value.datasetFingerprint === runtimeManifest.datasetFingerprint &&
    provenanceInput.value.sourceOutputChecksum === runtimeManifest.outputChecksum &&
    provenanceInput.value.counts?.sourceRecords === runtimeManifest.entityCount
  );
}

async function buildSnapshot() {
  const [dataProjectInput, runtimeInput, provenanceInput, productionObservation] = await Promise.all([
    readJSON(paths.dataProject),
    readJSON(paths.runtimeManifest),
    readJSON(paths.contentProvenance),
    latestProductionObservation()
  ]);
  const dataProject = dataProjectInput.value;
  const runtime = runtimeInput.value;
  const production = productionObservation.value;

  if (dataProject.summary.published !== runtime.entityCount) {
    throw new Error(`Published count mismatch: DATA PROJECT=${dataProject.summary.published}, runtime=${runtime.entityCount}.`);
  }
  if (provenanceInput.value.datasetFingerprint !== runtime.datasetFingerprint) {
    throw new Error("Public content provenance does not match the packaged runtime fingerprint.");
  }
  const sourceCount = provenanceInput.value.counts?.sourceRecords;
  const packagedCount = provenanceInput.value.counts?.acceptedRecords;
  const freshnessExcludedCount = provenanceInput.value.counts?.freshnessExcludedRecords;
  if (![sourceCount, packagedCount, freshnessExcludedCount].every(Number.isInteger)
      || sourceCount !== runtime.entityCount
      || packagedCount + freshnessExcludedCount !== sourceCount) {
    throw new Error("Public freshness provenance must partition every packaged source record into accepted or explicitly excluded records.");
  }

  const metadataAttested = productionMetadataMatch(productionObservation, provenanceInput, runtime);
  const { candidateCommit, sourceTreeState, sourceTreeExclusions } = candidateSourceIdentity();
  const inventoryCount = dataProject.summary.records;
  const coverage = inventoryCount > 0 ? Number(((packagedCount / inventoryCount) * 100).toFixed(1)) : null;
  const generatedAt = maxTimestamp([
    dataProject.generated_at,
    runtime.generatedAt,
    provenanceInput.value.generatedAt,
    production.observedAt
  ]);

  const sources = [
    {
      id: "candidate-source",
      kind: "git_source_identity",
      sourceRef: `git:${candidateCommit}`,
      sha256: null,
      observedAt: null,
      validThrough: null,
      state: sourceTreeState === "clean" ? "measured" : "provisional",
      scope: sourceTreeState === "clean"
        ? "Candidate source tree matches the recorded commit after excluding the five deterministic release projections generated from that commit."
        : "Candidate commit is recorded, but uncommitted source-tree changes are not represented by that commit."
    },
    {
      id: "data-project-inventory",
      kind: "generated_inventory",
      sourceRef: "admin-dashboard/src/generated/data-project-dashboard.json",
      sha256: dataProjectInput.sha256,
      observedAt: dataProject.generated_at,
      validThrough: null,
      state: "measured",
      scope: "Governed candidate inventory; link-health sentinel is explicitly excluded."
    },
    {
      id: "packaged-runtime",
      kind: "packaged_artifact_manifest",
      sourceRef: "admin-dashboard/src/generated/governed-runtime-manifest.json",
      sha256: runtimeInput.sha256,
      observedAt: runtime.generatedAt,
      validThrough: null,
      state: "measured",
      scope: `Governed source runtime with ${sourceCount} records; public packaging accepts ${packagedCount} and explicitly excludes ${freshnessExcludedCount} stale records.`
    },
    {
      id: "public-content-provenance",
      kind: "packaged_provenance",
      sourceRef: "admin-dashboard/public-site/public/data/content-provenance.json",
      sha256: provenanceInput.sha256,
      observedAt: provenanceInput.value.generatedAt,
      validThrough: null,
      state: "measured",
      scope: "Generated public-content provenance bound to the packaged runtime."
    },
    {
      id: "production-identity",
      kind: "production_observation",
      sourceRef: productionObservation.path.slice(repositoryRoot.length + 1),
      sha256: productionObservation.sha256,
      observedAt: production.observedAt,
      validThrough: null,
      state: metadataAttested ? "provisional" : "unknown",
      scope: metadataAttested
        ? "Production byte-matches provenance metadata, but the complete deployed payload/provider source SHA is not independently attested."
        : "Production observation does not match current packaged provenance metadata."
    },
    {
      id: "link-health",
      kind: "network_observation",
      sourceRef: "not_available_in_deterministic_build",
      sha256: null,
      observedAt: null,
      validThrough: null,
      state: "unknown",
      scope: "A fresh network link check is required; offline generation never fabricates 0/0 evidence."
    },
    {
      id: "candidate-ci",
      kind: "candidate_ci_evidence",
      sourceRef: "not_attached",
      sha256: null,
      observedAt: null,
      validThrough: null,
      state: "unknown",
      scope: "No exact-commit CI evidence manifest is attached to this repository snapshot."
    }
  ];

  const snapshot = {
    schemaVersion: 2,
    snapshotID: "",
    snapshotDigest: "",
    generatedAt,
    candidateCommit,
    sourceTreeState,
    sourceTreeExclusions,
    technicalVerdict: "PARTIAL",
    deploymentAuthorization: "not_granted",
    verdictReason: "Packaged content is measured, while link health, exact-candidate CI, and full deployed-payload verification are not established.",
    sources,
    publication: {
      inventory: {
        state: "measured",
        total: inventoryCount,
        verified: dataProject.summary.verified,
        outdated: dataProject.summary.outdated,
        nextReleaseID: dataProject.next_release?.id ?? null,
        nextReleaseStatus: dataProject.next_release?.status ?? null
      },
      packaged: {
        state: "measured",
        entityCount: packagedCount,
        sourceEntityCount: sourceCount,
        freshnessExcludedEntityCount: freshnessExcludedCount,
        releaseIDs: runtime.publishedReleaseIds,
        datasetFingerprint: runtime.datasetFingerprint,
        outputChecksum: runtime.outputChecksum
      },
      deployed: {
        state: metadataAttested ? "provisional" : "unknown",
        evidenceLevel: metadataAttested ? "metadata_attested" : "none",
        entityCount: null,
        declaredEntityCount: metadataAttested ? provenanceInput.value.counts.acceptedRecords : null,
        datasetFingerprint: metadataAttested ? provenanceInput.value.datasetFingerprint : null,
        observationRef: productionObservation.path.slice(repositoryRoot.length + 1)
      }
    },
    metrics: {
      inventoryRecords: evidenceMetric({
        kind: "count", unit: "count", value: inventoryCount, state: "measured",
        formulaID: "effective-governed-inventory-count", sourceIDs: ["data-project-inventory"]
      }),
      packagedPublishedRecords: evidenceMetric({
        kind: "count", unit: "count", value: packagedCount, state: "measured",
        formulaID: "packaged-published-record-count", sourceIDs: ["packaged-runtime", "public-content-provenance"]
      }),
      packagedCoverage: inventoryCount > 0
        ? evidenceMetric({
            kind: "ratio", unit: "percent", value: coverage, numerator: packagedCount, denominator: inventoryCount,
            state: "measured", formulaID: "packaged-published-over-governed-inventory", sourceIDs: ["data-project-inventory", "packaged-runtime", "public-content-provenance"]
          })
        : evidenceMetric({
            kind: "ratio", unit: "percent", value: null, numerator: 0, denominator: 0,
            state: "not_applicable", reasonCode: "empty_inventory", formulaID: "packaged-published-over-governed-inventory",
            sourceIDs: ["data-project-inventory", "packaged-runtime"]
          }),
      linkHealth: evidenceMetric({
        kind: "ratio", unit: "percent", value: null, state: "unknown", reasonCode: "network_check_not_run",
        formulaID: "reachable-links-over-inspected-links", sourceIDs: ["link-health"]
      })
    },
    gates: {
      sourceIntegrity: {
        result: "pass",
        reason: `Public provenance partitions all ${sourceCount} governed source records into ${packagedCount} packaged public records and ${freshnessExcludedCount} fail-closed freshness exclusions.`,
        sourceIDs: ["data-project-inventory", "packaged-runtime", "public-content-provenance"]
      },
      packagedPublication: {
        result: "pass",
        reason: `The public package contains ${packagedCount} accepted records and no freshness-excluded record.`,
        sourceIDs: ["packaged-runtime", "public-content-provenance"]
      },
      deployedPayload: {
        result: "blocked",
        reason: metadataAttested
          ? "Production metadata is attested, but the complete deployed payload/provider SHA is not independently verified."
          : "Production metadata does not match the packaged artifact.",
        sourceIDs: ["production-identity", "public-content-provenance"]
      },
      linkHealth: {
        result: "blocked",
        reason: "No fresh non-empty network observation is attached.",
        sourceIDs: ["link-health"]
      },
      candidateCI: {
        result: "blocked",
        reason: sourceTreeState === "clean"
          ? "No exact-commit CI evidence manifest is attached."
          : "The source tree is dirty and no exact-commit CI evidence manifest is attached.",
        sourceIDs: ["candidate-source", "candidate-ci"]
      },
      legacyCompatibilityArtifacts: {
        result: "pass",
        reason: "Three deprecated compatibility projections are deterministically generated from this snapshot and byte-checked by --check.",
        sourceIDs: ["candidate-source"]
      }
    },
    limitations: [
      "This snapshot does not authorize production deployment.",
      sourceTreeState === "clean"
        ? "The source tree matched the recorded candidate commit after excluding the five deterministic release projection outputs."
        : "The recorded candidate commit does not include current uncommitted source-tree changes.",
      "Production evidence is metadata-attested, not a complete deployed-payload verification.",
      "Link reachability is unknown until a fresh network check inspects a non-empty URL set.",
      "Legacy release-readiness and trust-dashboard JSON files are deprecated compatibility projections, not independent release authorities.",
      "Operational Supabase data is loaded independently and cannot upgrade this build-time verdict."
    ]
  };
  const digestPayload = { ...snapshot, snapshotID: undefined, snapshotDigest: undefined };
  snapshot.snapshotDigest = sha256(JSON.stringify(digestPayload));
  snapshot.snapshotID = `release-truth.${snapshot.snapshotDigest.slice(0, 16)}`;
  return snapshot;
}

function publicSnapshot(snapshot) {
  return {
    schemaVersion: 1,
    snapshotID: snapshot.snapshotID,
    snapshotDigest: snapshot.snapshotDigest,
    generatedAt: snapshot.generatedAt,
    technicalVerdict: snapshot.technicalVerdict,
    deploymentAuthorization: snapshot.deploymentAuthorization,
    verdictReason: snapshot.verdictReason,
    publication: {
      inventoryRecords: snapshot.publication.inventory.total,
      packagedPublishedRecords: snapshot.publication.packaged.entityCount,
      packagedCoverage: snapshot.metrics.packagedCoverage,
      deployedState: snapshot.publication.deployed.state,
      deployedEvidenceLevel: snapshot.publication.deployed.evidenceLevel
    },
    linkHealth: snapshot.metrics.linkHealth,
    gates: Object.fromEntries(Object.entries(snapshot.gates).map(([id, gate]) => [id, gate.result])),
    limitations: snapshot.limitations
  };
}

function compatibilityReleaseReadiness(snapshot) {
  return {
    schemaVersion: "release-truth-compatibility-v1",
    deprecated: true,
    replacement: "release-truth.json",
    generatedAt: snapshot.generatedAt,
    snapshotID: snapshot.snapshotID,
    snapshotDigest: snapshot.snapshotDigest,
    release_identity: {
      candidate_commit: snapshot.candidateCommit,
      source_tree_state: snapshot.sourceTreeState,
      packaged_fingerprint: snapshot.publication.packaged.datasetFingerprint
    },
    posture: snapshot.technicalVerdict,
    release_status_label: snapshot.technicalVerdict,
    release_summary: snapshot.verdictReason,
    proven: {
      inventory_records: snapshot.publication.inventory.total,
      packaged_published_records: snapshot.publication.packaged.entityCount,
      packaged_release_ids: snapshot.publication.packaged.releaseIDs
    },
    remaining_items: Object.entries(snapshot.gates)
      .filter(([, gate]) => gate.result !== "pass" && gate.result !== "not_applicable")
      .map(([id]) => id),
    evidence: {
      deployed_state: snapshot.publication.deployed.state,
      link_health_state: snapshot.metrics.linkHealth.state,
      deployment_authorization: snapshot.deploymentAuthorization
    }
  };
}

function compatibilityTrustDashboard(snapshot, replacement) {
  return {
    schemaVersion: "release-truth-compatibility-v1",
    deprecated: true,
    replacement,
    title: "Deprecated release-truth compatibility projection",
    generatedAt: snapshot.generatedAt,
    snapshotID: snapshot.snapshotID,
    snapshotDigest: snapshot.snapshotDigest,
    currentReleaseAuthority: "packaged-governed-runtime",
    releaseAuthorityReason: snapshot.verdictReason,
    readiness: {
      status: snapshot.technicalVerdict,
      deploymentAuthorization: snapshot.deploymentAuthorization
    },
    knowledgeCoverage: snapshot.metrics.packagedCoverage,
    metrics: {
      inventoryRecords: snapshot.metrics.inventoryRecords,
      packagedPublishedRecords: snapshot.metrics.packagedPublishedRecords,
      linkHealth: snapshot.metrics.linkHealth
    },
    topRiskAreas: Object.entries(snapshot.gates)
      .filter(([, gate]) => gate.result === "blocked" || gate.result === "fail")
      .map(([id, gate]) => ({ id, result: gate.result, reason: gate.reason })),
    limitations: snapshot.limitations
  };
}

async function main() {
  const checkOnly = process.argv.includes("--check");
  const snapshot = await buildSnapshot();
  const outputs = new Map([
    [outputPath, stableJSONString(snapshot)],
    [publicOutputPath, stableJSONString(publicSnapshot(snapshot))],
    [compatibilityOutputPaths.releaseReadiness, stableJSONString(compatibilityReleaseReadiness(snapshot))],
    [compatibilityOutputPaths.adminTrustDashboard, stableJSONString(compatibilityTrustDashboard(snapshot, "release-truth.json"))],
    [compatibilityOutputPaths.publicTrustDashboard, stableJSONString(compatibilityTrustDashboard(snapshot, "release-truth-public.json"))]
  ]);
  if (checkOnly) {
    for (const [path, expected] of outputs) {
      const actual = await readFile(path, "utf8");
      if (actual !== expected) throw new Error(`${path} is stale; run generate-release-truth.mjs.`);
    }
  } else {
    for (const [path, expected] of outputs) await writeFile(path, expected, "utf8");
  }
  process.stdout.write(`${checkOnly ? "Verified" : "Generated"} deterministic release truth (${outputs.size} artifacts).\n`);
}

main().catch((error) => {
  process.stderr.write(`${error.stack ?? error.message}\n`);
  process.exitCode = 1;
});
