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

function resolveRepositoryFile(relativePath, label) {
  requireCondition(typeof relativePath === "string" && relativePath.length > 0 && !isAbsolute(relativePath), `${label} has an unsafe path`);
  const absolutePath = resolve(repositoryRoot, relativePath);
  requireCondition(!relative(repositoryRoot, absolutePath).startsWith(".."), `${label} escapes the repository`);
  return absolutePath;
}

function sourceField(guide, path, pair) {
  const segments = path.split(".");
  let owner;
  let value;

  if (segments.length === 1) {
    owner = guide;
    value = guide[segments[0]];
  } else if (segments.length === 2) {
    owner = guide[segments[0]];
    value = owner?.[segments[1]];
  } else if (segments.length >= 3) {
    const collection = guide[segments[0]];
    requireCondition(Array.isArray(collection), `${pair} source path ${path} does not reference a collection`);
    const itemId = segments.slice(1, -1).join(".");
    owner = collection.find((item) => item?.id === itemId);
    value = owner?.[segments.at(-1)];
  } else {
    requireCondition(false, `${pair} source path ${path} has an unsupported shape`);
  }

  requireCondition(typeof value === "string" && value.trim().length > 0, `${pair} source path ${path} does not resolve to text`);
  return {
    path,
    source_text: value,
    source_ids: Array.isArray(owner?.source_ids) ? owner.source_ids : []
  };
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
const translationPath = resolveRepositoryFile(matrix.translation_bundle, "translation bundle");
const translationText = await readFile(translationPath, "utf8");
const translation = JSON.parse(translationText);
const sourceBundlePath = resolveRepositoryFile(translation.source_bundle, "English source bundle");
const sourceBundleText = await readFile(sourceBundlePath, "utf8");
const sourceBundle = JSON.parse(sourceBundleText);
const searchSurfacePath = resolveRepositoryFile(translation.search_surface_bundle, "search-surface bundle");
const searchSurfaceText = await readFile(searchSurfacePath, "utf8");
const searchSurface = JSON.parse(searchSurfaceText);
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
requireCondition(sha256(sourceBundleText) === translation.source_bundle_sha256, "English source bundle SHA-256 mismatch");
requireCondition(sourceBundle.schema_version === 2 && sourceBundle.guides?.length === 8, "English source bundle must contain eight schema-v2 guides");
requireCondition(sha256(searchSurfaceText) === translation.search_surface_bundle_sha256, "search-surface bundle SHA-256 mismatch");
requireCondition(searchSurface.publication_authorized === false, "search-surface bundle is unexpectedly publication-authorized");
requireCondition(searchSurface.entries?.length === 16, "search-surface bundle must contain 16 guide-locale drafts");
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
const sourceGuides = new Map();
for (const sourceRecord of sourceBundle.guides) {
  const guide = sourceRecord?.practical_guide;
  requireCondition(typeof guide?.id === "string" && !sourceGuides.has(guide.id), "English source bundle contains a missing or duplicate guide ID");
  requireCondition(guide.locale === "en", `English source guide ${guide.id} has an unexpected locale`);
  sourceGuides.set(guide.id, guide);
}

const searchSurfacePairs = new Map();
for (const entry of searchSurface.entries) {
  const pair = `${entry.source_guide_id}:${entry.locale}`;
  requireCondition(!searchSurfacePairs.has(pair), `duplicate search-surface record ${pair}`);
  requireCondition(entry.translation_status === "search_surface_draft", `${pair} has an unexpected search-surface status`);
  requireCondition(entry.publication_authorized === false && entry.reviewer === null && entry.verified_at === null, `${pair} contains premature search-surface approval`);
  requireCondition(typeof entry.title === "string" && entry.title.trim(), `${pair} has no localized title`);
  requireCondition(typeof entry.short_summary === "string" && entry.short_summary.trim(), `${pair} has no localized summary`);
  requireCondition(Array.isArray(entry.synonyms) && entry.synonyms.length >= 8, `${pair} has incomplete localized synonyms`);
  requireCondition(Array.isArray(entry.common_questions) && entry.common_questions.length >= 3, `${pair} has incomplete localized questions`);
  requireCondition(Array.isArray(entry.terminology) && entry.terminology.length > 0, `${pair} has no terminology review notes`);
  searchSurfacePairs.set(pair, entry);
}

const reviewPairs = new Set();
const reviewRecords = new Map();

for (const record of matrix.records) {
  const pair = `${record.source_guide_id}:${record.locale}`;
  requireCondition(!reviewPairs.has(pair), `duplicate review record ${pair}`);
  reviewPairs.add(pair);
  reviewRecords.set(pair, record);
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
requireCondition(reviewPairs.size === searchSurfacePairs.size, "search-surface and review pair sets differ");
requireCondition(
  matrix.publication_authorized === false || matrix.records.every((record) => record.review_status === "passed" && record.publication_eligible === true),
  "publication authorization exists before every review record passed"
);

const reviewPackets = translation.entries.map((entry) => {
  const pair = `${entry.source_guide_id}:${entry.locale}`;
  const guide = sourceGuides.get(entry.source_guide_id);
  const surface = searchSurfacePairs.get(pair);
  const reviewRecord = reviewRecords.get(pair);
  requireCondition(guide, `${pair} has no English source guide`);
  requireCondition(surface, `${pair} has no search-surface draft`);
  requireCondition(reviewRecord, `${pair} has no review record`);
  requireCondition(entry.translation_status === "machine_assisted_full_body_draft", `${pair} has an unexpected full-body status`);
  requireCondition(entry.publication_authorized === false && entry.reviewer === null && entry.verified_at === null, `${pair} contains premature full-body approval`);

  const officialSources = new Map((guide.official_sources ?? []).map((source) => [source.id, source]));
  const fields = Object.entries(entry.fields ?? {})
    .sort(([left], [right]) => left.localeCompare(right))
    .map(([path, targetText]) => {
      requireCondition(typeof targetText === "string" && targetText.trim().length > 0, `${pair} target path ${path} has no text`);
      const source = sourceField(guide, path, pair);
      for (const sourceId of source.source_ids) {
        requireCondition(officialSources.has(sourceId), `${pair} field ${path} references missing source ${sourceId}`);
      }
      return { ...source, target_text: targetText };
    });

  requireCondition(fields.length === reviewRecord.translated_field_count, `${pair} review packet field count mismatch`);

  return {
    packet_id: `${guide.slug}-${entry.locale}`,
    source_guide_id: entry.source_guide_id,
    locale: entry.locale,
    review_category: reviewRecord.review_category,
    source_title: guide.title,
    target_title: surface.title,
    search_surface: {
      source_summary: guide.short_summary.text,
      target_summary: surface.short_summary,
      source_synonyms: guide.synonyms,
      target_synonyms: surface.synonyms,
      source_common_questions: guide.common_questions,
      target_common_questions: surface.common_questions,
      terminology: surface.terminology
    },
    review_state: {
      review_status: reviewRecord.review_status,
      reviewer_id: reviewRecord.reviewer_id,
      evidence_registry_entry_id: reviewRecord.evidence_registry_entry_id,
      checked_at: reviewRecord.checked_at,
      publication_eligible: reviewRecord.publication_eligible
    },
    fields,
    official_sources: [...officialSources.values()]
  };
});

requireCondition(new Set(reviewPackets.map((packet) => packet.packet_id)).size === reviewPackets.length, "review packet IDs are not unique");

const artifact = {
  ...matrix,
  review_packets: reviewPackets,
  admin_snapshot: {
    source: sourceRelativePath,
    source_sha256: sourceSha256,
    translation_bundle_sha256: translationSha256,
    source_bundle_sha256: sha256(sourceBundleText),
    search_surface_bundle_sha256: sha256(searchSurfaceText),
    reviewer_registry_sha256: sha256(reviewerRegistryText),
    evidence_registry_sha256: sha256(evidenceRegistryText),
    record_count: matrix.records.length,
    review_packet_count: reviewPackets.length,
    review_packet_field_count: reviewPackets.reduce((total, packet) => total + packet.fields.length, 0),
    required_review_checks: matrix.records.length * requiredDimensions.length
  }
};

await mkdir(generatedDirectory, { recursive: true });
await writeAtomically(generatedPath, `${JSON.stringify(artifact, null, 2)}\n`);

console.log(
  `Generated localization review snapshot: ${artifact.admin_snapshot.record_count} records, ${artifact.admin_snapshot.required_review_checks} required human checks`
);
