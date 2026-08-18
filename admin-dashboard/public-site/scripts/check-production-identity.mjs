import { createHash } from "node:crypto";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";
import { spawnSync } from "node:child_process";

const scriptPath = fileURLToPath(import.meta.url);
const siteRoot = resolve(dirname(scriptPath), "..");
const repositoryRoot = resolve(siteRoot, "../..");
const defaultRecordPath = resolve(
  repositoryRoot,
  "docs/reports/production-identity/production-observation-2026-08-18.json"
);

const isObject = (value) => value !== null && typeof value === "object" && !Array.isArray(value);
const shaPattern = /^[a-f0-9]{64}$/;
const commitPattern = /^[a-f0-9]{40}$/;
const cacheVersionPattern = /^younew-web-[a-f0-9]{12}$/;

function sha256(value) {
  return createHash("sha256").update(value).digest("hex");
}

export function artifactSubsetFingerprint(artifacts) {
  const digest = createHash("sha256");
  for (const artifact of [...artifacts].sort((left, right) => left.path.localeCompare(right.path))) {
    digest.update(artifact.path);
    digest.update("\0");
    digest.update(artifact.sha256);
    digest.update("\n");
  }
  return digest.digest("hex");
}

export function validateProductionIdentity(record) {
  const errors = [];
  if (!isObject(record)) return ["record must be an object"];

  if (record.schemaVersion !== 1) errors.push("schemaVersion must be 1");
  if (record.recordType !== "production_identity_observation") errors.push("recordType is invalid");
  if (record.environment !== "production") errors.push("environment must be production");
  if (record.origin !== "https://younew.nl") errors.push("origin must be the canonical HTTPS origin");
  if (Number.isNaN(Date.parse(record.observedAt))) errors.push("observedAt must be an ISO timestamp");

  if (!isObject(record.provider) || record.provider.name !== "OpenAI Sites / Cloudflare") {
    errors.push("provider name is invalid");
  }
  if (!Number.isInteger(record.provider?.sitesVersion) || record.provider.sitesVersion < 1) {
    errors.push("provider Sites version must be a positive integer");
  }

  if (!isObject(record.source) || !commitPattern.test(record.source.commitSha ?? "")) {
    errors.push("source commitSha must be a full lowercase Git SHA");
  }
  if (record.source?.repository !== "https://github.com/zq87xf5jyp-arch/YouNew.git") {
    errors.push("source repository is invalid");
  }
  if (record.source?.branch !== "main") errors.push("source branch must be main");
  if (record.source?.commitUrl !== `https://github.com/zq87xf5jyp-arch/YouNew/commit/${record.source?.commitSha}`) {
    errors.push("source commitUrl does not match commitSha");
  }

  if (!isObject(record.verification)) {
    errors.push("verification is required");
    return errors;
  }
  if (record.verification.level !== "artifact_subset_match") errors.push("verification level is invalid");
  if (record.verification.providerDeploymentRecordHasSourceSha !== false) {
    errors.push("provider SHA evidence must remain false until a provider record proves it");
  }
  if (!cacheVersionPattern.test(record.verification.serviceWorkerCacheVersion ?? "")) {
    errors.push("service-worker cache version is invalid");
  }
  if (!Array.isArray(record.verification.artifacts) || record.verification.artifacts.length < 3) {
    errors.push("at least three production artifacts are required");
  } else {
    const paths = new Set();
    for (const artifact of record.verification.artifacts) {
      if (!isObject(artifact) || typeof artifact.path !== "string" || !artifact.path.startsWith("/")) {
        errors.push("every artifact needs an absolute origin path");
        continue;
      }
      if (paths.has(artifact.path)) errors.push(`duplicate artifact path: ${artifact.path}`);
      paths.add(artifact.path);
      if (!shaPattern.test(artifact.sha256 ?? "")) errors.push(`invalid artifact SHA-256: ${artifact.path}`);
      if (!isObject(artifact.sourceEvidence) || !["commit_blob", "clean_build"].includes(artifact.sourceEvidence.kind)) {
        errors.push(`invalid source evidence: ${artifact.path}`);
      }
    }
    if (!shaPattern.test(record.verification.artifactSubsetSha256 ?? "")) {
      errors.push("artifactSubsetSha256 is invalid");
    } else if (artifactSubsetFingerprint(record.verification.artifacts) !== record.verification.artifactSubsetSha256) {
      errors.push("artifactSubsetSha256 does not match the artifact list");
    }
  }

  if (!isObject(record.versionReconciliation)) {
    errors.push("versionReconciliation is required");
  } else {
    if (record.versionReconciliation.auditInputLabel !== 54) errors.push("audit input label must record v54");
    if (record.versionReconciliation.sameNamespace !== false) errors.push("audit and Sites versions must remain separate namespaces");
    if (record.versionReconciliation.decision !== "not_comparable") errors.push("version reconciliation decision is invalid");
  }

  if (!Array.isArray(record.limitations) || record.limitations.length === 0) errors.push("limitations are required");
  return errors;
}

function gitBytes(args) {
  const result = spawnSync(process.env.GIT_BINARY ?? "git", args, {
    cwd: repositoryRoot,
    encoding: null,
    maxBuffer: 20 * 1024 * 1024
  });
  if (result.status !== 0) {
    const error = result.stderr?.toString("utf8").trim() || `git ${args.join(" ")} failed`;
    throw new Error(error);
  }
  return result.stdout;
}

export function verifyRepositoryEvidence(record) {
  const errors = [];
  const commitSha = record.source.commitSha;
  try {
    gitBytes(["cat-file", "-e", `${commitSha}^{commit}`]);
  } catch (error) {
    return [`source commit is unavailable: ${error.message}`];
  }

  for (const artifact of record.verification.artifacts) {
    const evidence = artifact.sourceEvidence;
    try {
      if (evidence.kind === "commit_blob") {
        const bytes = gitBytes(["show", `${commitSha}:${evidence.repositoryPath}`]);
        if (sha256(bytes) !== artifact.sha256) errors.push(`${artifact.path} does not match its source-commit blob`);
      } else if (evidence.kind === "clean_build") {
        const template = gitBytes(["show", `${commitSha}:${evidence.templatePath}`]).toString("utf8");
        const version = template.match(/^const CACHE_VERSION = "([^"]+)";/)?.[1];
        if (version !== record.verification.serviceWorkerCacheVersion) {
          errors.push(`${artifact.path} cache version does not match the source-commit template`);
        }
      }
    } catch (error) {
      errors.push(`${artifact.path} source evidence failed: ${error.message}`);
    }
  }
  return errors;
}

export async function verifyLiveArtifacts(record) {
  const errors = [];
  for (const artifact of record.verification.artifacts) {
    const url = new URL(artifact.path, record.origin);
    try {
      const response = await fetch(url, { cache: "no-store", signal: AbortSignal.timeout(30_000) });
      if (!response.ok) {
        errors.push(`${artifact.path} returned HTTP ${response.status}`);
        continue;
      }
      const digest = sha256(Buffer.from(await response.arrayBuffer()));
      if (digest !== artifact.sha256) errors.push(`${artifact.path} live SHA-256 changed`);
    } catch (error) {
      errors.push(`${artifact.path} live verification failed: ${error.message}`);
    }
  }
  return errors;
}

async function main() {
  const args = process.argv.slice(2);
  const verifyLive = args.includes("--live");
  const recordArgument = args.find((argument) => !argument.startsWith("--"));
  const recordPath = resolve(process.cwd(), recordArgument ?? defaultRecordPath);
  const record = JSON.parse(await readFile(recordPath, "utf8"));
  const errors = [
    ...validateProductionIdentity(record),
    ...verifyRepositoryEvidence(record),
    ...(verifyLive ? await verifyLiveArtifacts(record) : [])
  ];
  if (errors.length > 0) throw new Error(`Production identity verification failed:\n- ${errors.join("\n- ")}`);

  process.stdout.write(
    `Production identity verified: Sites v${record.provider.sitesVersion}, ${record.source.commitSha}, ` +
    `artifact subset ${record.verification.artifactSubsetSha256}, live=${verifyLive ? "verified" : "not-requested"}.\n`
  );
}

if (resolve(process.argv[1] ?? "") === scriptPath) {
  main().catch((error) => {
    process.stderr.write(`${error.stack ?? error.message}\n`);
    process.exitCode = 1;
  });
}
