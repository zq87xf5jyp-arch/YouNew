import { createHash } from "node:crypto";
import { mkdir, readFile, rename, writeFile } from "node:fs/promises";
import { dirname, isAbsolute, relative, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const adminRoot = resolve(scriptDirectory, "..");
const repositoryRoot = resolve(adminRoot, "..");
const sourceRelativePath = "DataProject/staging/release-critical-practical-guides-v2-localization-review-matrix.json";
const sourcePath = resolve(repositoryRoot, sourceRelativePath);
const reviewerRegistryRelativePath = "DataProject/operations/reviewer-registry.json";
const evidenceRegistryRelativePath = "DataProject/operations/guide-evidence-registry.json";
const generatedDirectory = resolve(adminRoot, "src/generated");
const generatedPath = resolve(generatedDirectory, "localization-review.json");

const requiredDimensions = [
  "independent_language_review",
  "source_to_translation_review",
  "editorial_and_domain_review",
  "media_and_accessibility_review"
];

function requireCondition(condition, message) {
  if (!condition) {
    throw new Error(`Localization review generation failed: ${message}`);
  }
}

function sha256(value) {
  return createHash("sha256").update(value).digest("hex");
}

async function writeAtomically(path, contents) {
  const temporaryPath = `${path}.tmp`;
  await writeFile(temporaryPath, contents, "utf8");
  await rename(temporaryPath, path);
}

const sourceText = await readFile(sourcePath, "utf8");
const matrix = JSON.parse(sourceText);
const reviewerRegistryText = await readFile(resolve(repositoryRoot, reviewerRegistryRelativePath), "utf8");
const evidenceRegistryText = await readFile(resolve(repositoryRoot, evidenceRegistryRelativePath), "utf8");
const reviewerRegistry = JSON.parse(reviewerRegistryText);
const evidenceRegistry = JSON.parse(evidenceRegistryText);
const translationPath = resolve(repositoryRoot, matrix.translation_bundle ?? "");
const translationText = await readFile(translationPath, "utf8");
const translation = JSON.parse(translationText);
const sourceSha256 = sha256(sourceText);
const translationSha256 = sha256(translationText);

requireCondition(matrix.schema_version === 1, "unsupported review matrix schema");
requireCondition(matrix.publication_authorized === false, "source matrix must remain non-authorizing");
requireCondition(matrix.policy?.automated_reviewers_allowed === false, "automated reviewers must remain forbidden");
requireCondition(matrix.policy?.registered_human_reviewer_required === true, "human reviewer gate is missing");
requireCondition(matrix.policy?.passed_evidence_registry_entry_required === true, "evidence registry gate is missing");
requireCondition(matrix.policy?.all_review_dimensions_required === true, "all-dimensions gate is missing");
requireCondition(
  JSON.stringify(matrix.review_dimensions) === JSON.stringify(requiredDimensions),
  "review dimensions do not match the governed four-dimension policy"
);
requireCondition(translationSha256 === matrix.translation_bundle_sha256, "translation bundle SHA-256 mismatch");
requireCondition(translation.publication_authorized === false, "translation bundle is unexpectedly publication-authorized");
requireCondition(translation.entries?.length === 16, "translation bundle must contain 16 guide-locale drafts");
requireCondition(matrix.records?.length === 16, "review matrix must contain 16 guide-locale records");
requireCondition(reviewerRegistry.schema_version === 1, "unsupported reviewer registry schema");
requireCondition(reviewerRegistry.policy?.automated_reviewers_allowed === false, "unsafe reviewer registry policy");
requireCondition(Array.isArray(reviewerRegistry.reviewers), "reviewer registry must contain an array");
requireCondition(evidenceRegistry.schema_version === 1, "unsupported evidence registry schema");
requireCondition(evidenceRegistry.policy?.unresolved_evidence_blocks_publication === true, "unsafe evidence registry policy");
requireCondition(Array.isArray(evidenceRegistry.evidence), "evidence registry must contain an array");

const reviewers = new Map();
for (const reviewer of reviewerRegistry.reviewers) {
  requireCondition(typeof reviewer?.id === "string" && !reviewers.has(reviewer.id), "reviewer registry contains a missing or duplicate ID");
  requireCondition(reviewer.reviewer_type === "human_editor" || reviewer.reviewer_type === "subject_matter_expert" || reviewer.reviewer_type === "official_owner", `reviewer ${reviewer.id} is not human`);
  requireCondition(typeof reviewer.name === "string" && reviewer.name.trim(), `reviewer ${reviewer.id} has no visible name`);
  requireCondition(typeof reviewer.role === "string" && reviewer.role.trim(), `reviewer ${reviewer.id} has no visible role`);
  requireCondition(typeof reviewer.active === "boolean", `reviewer ${reviewer.id} has no active flag`);
  requireCondition(Array.isArray(reviewer.locales) && reviewer.locales.length > 0, `reviewer ${reviewer.id} has no locale scope`);
  requireCondition(Array.isArray(reviewer.categories) && reviewer.categories.length > 0, `reviewer ${reviewer.id} has no category scope`);
  reviewers.set(reviewer.id, reviewer);
}

const evidenceCatalog = new Map();
for (const evidence of evidenceRegistry.evidence) {
  requireCondition(typeof evidence?.id === "string" && !evidenceCatalog.has(evidence.id), "evidence registry contains a missing or duplicate ID");
  requireCondition(typeof evidence.artifact_path === "string" && !isAbsolute(evidence.artifact_path), `evidence ${evidence.id} has an unsafe artifact path`);
  const artifactPath = resolve(repositoryRoot, evidence.artifact_path);
  requireCondition(!relative(repositoryRoot, artifactPath).startsWith(".."), `evidence ${evidence.id} escapes the repository`);
  const artifactText = await readFile(artifactPath);
  requireCondition(evidence.sha256 === sha256(artifactText), `evidence ${evidence.id} SHA-256 mismatch`);
  evidenceCatalog.set(evidence.id, evidence);
}

const translationPairs = new Map(
  translation.entries.map((entry) => [
    `${entry.source_guide_id}:${entry.locale}`,
    Object.keys(entry.fields ?? {}).length
  ])
);
const reviewPairs = new Set();

for (const record of matrix.records) {
  const pair = `${record.source_guide_id}:${record.locale}`;
  requireCondition(!reviewPairs.has(pair), `duplicate review record ${pair}`);
  reviewPairs.add(pair);
  requireCondition(translationPairs.has(pair), `review record ${pair} has no translation draft`);
  requireCondition(record.translated_field_count === translationPairs.get(pair), `field count mismatch for ${pair}`);
  requireCondition(["nl", "ru"].includes(record.locale), `unsupported locale for ${pair}`);
  requireCondition(/^[a-z][a-z0-9_-]+$/.test(record.review_category ?? ""), `invalid review category for ${pair}`);
  requireCondition(["not_started", "in_progress", "failed", "passed"].includes(record.review_status), `unsupported review status for ${pair}`);

  if (record.reviewer_id !== null) {
    const reviewer = reviewers.get(record.reviewer_id);
    requireCondition(reviewer?.active === true, `${pair} reviewer is not active in the human registry`);
    requireCondition(reviewer.locales.includes(record.locale), `${pair} reviewer is outside the locale scope`);
    requireCondition(reviewer.categories.includes("*") || reviewer.categories.includes(record.review_category), `${pair} reviewer is outside the category scope`);
  }

  if (record.evidence_registry_entry_id !== null) {
    const evidence = evidenceCatalog.get(record.evidence_registry_entry_id);
    requireCondition(evidence?.status === "passed", `${pair} evidence is not passed`);
    requireCondition(evidence.guide_id === record.source_guide_id, `${pair} evidence belongs to another guide`);
    requireCondition(evidence.locale === record.locale, `${pair} evidence belongs to another locale`);
    requireCondition(evidence.checked_at === record.checked_at, `${pair} evidence timestamp mismatch`);
    requireCondition(requiredDimensions.every((dimension) => evidence.checks?.includes(dimension)), `${pair} evidence does not cover every review dimension`);
  }

  if (record.review_status === "passed") {
    requireCondition(typeof record.reviewer_id === "string", `${pair} passed without a human reviewer`);
    requireCondition(typeof record.evidence_registry_entry_id === "string", `${pair} passed without hashed evidence`);
    requireCondition(typeof record.checked_at === "string" && !Number.isNaN(Date.parse(record.checked_at)), `${pair} passed without a valid timestamp`);
    requireCondition(record.publication_eligible === true, `${pair} passed but is not publication-eligible`);
  } else {
    requireCondition(record.publication_eligible === false, `${pair} is publication-eligible before passing review`);
    if (record.review_status === "not_started") {
      requireCondition(record.reviewer_id === null, `${pair} not started but has a reviewer claim`);
      requireCondition(record.evidence_registry_entry_id === null, `${pair} not started but has an evidence claim`);
      requireCondition(record.checked_at === null, `${pair} not started but has a review timestamp`);
    }
  }
}

requireCondition(reviewPairs.size === translationPairs.size, "translation and review pair sets differ");
requireCondition(
  matrix.publication_authorized === false || matrix.records.every((record) => record.review_status === "passed" && record.publication_eligible === true),
  "publication authorization exists before every review record passed"
);

const artifact = {
  ...matrix,
  admin_snapshot: {
    source: sourceRelativePath,
    source_sha256: sourceSha256,
    translation_bundle_sha256: translationSha256,
    reviewer_registry_sha256: sha256(reviewerRegistryText),
    evidence_registry_sha256: sha256(evidenceRegistryText),
    record_count: matrix.records.length,
    required_review_checks: matrix.records.length * requiredDimensions.length
  }
};

await mkdir(generatedDirectory, { recursive: true });
await writeAtomically(generatedPath, `${JSON.stringify(artifact, null, 2)}\n`);

console.log(
  `Generated localization review snapshot: ${artifact.admin_snapshot.record_count} records, ${artifact.admin_snapshot.required_review_checks} required human checks`
);
