import { readFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

const scriptDirectory = dirname(fileURLToPath(import.meta.url));
const adminRoot = resolve(scriptDirectory, "..");
const snapshotPath = resolve(adminRoot, "src/generated/localization-review.json");
const requiredDimensions = [
  "independent_language_review",
  "source_to_translation_review",
  "editorial_and_domain_review",
  "media_and_accessibility_review"
];

function requireCondition(condition, message) {
  if (!condition) {
    throw new Error(`Packaged localization review verification failed: ${message}`);
  }
}

const snapshot = JSON.parse(await readFile(snapshotPath, "utf8"));
const records = snapshot.records ?? [];
const recordPairs = records.map((record) => `${record.source_guide_id}:${record.locale}`);

requireCondition(snapshot.schema_version === 1, "unsupported schema version");
requireCondition(snapshot.policy?.automated_reviewers_allowed === false, "automated review is not forbidden");
requireCondition(snapshot.policy?.registered_human_reviewer_required === true, "human reviewer gate is missing");
requireCondition(snapshot.policy?.passed_evidence_registry_entry_required === true, "evidence gate is missing");
requireCondition(snapshot.policy?.all_review_dimensions_required === true, "all-dimensions gate is missing");
requireCondition(JSON.stringify(snapshot.review_dimensions) === JSON.stringify(requiredDimensions), "review dimensions mismatch");
requireCondition(records.length === 16, "snapshot must contain 16 guide-locale records");
requireCondition(new Set(recordPairs).size === records.length, "snapshot contains duplicate guide-locale records");
requireCondition(snapshot.admin_snapshot?.record_count === records.length, "record count metadata mismatch");
requireCondition(snapshot.admin_snapshot?.required_review_checks === records.length * requiredDimensions.length, "required check count mismatch");

for (const digestName of ["source_sha256", "translation_bundle_sha256", "reviewer_registry_sha256", "evidence_registry_sha256"]) {
  requireCondition(/^[a-f0-9]{64}$/.test(snapshot.admin_snapshot?.[digestName] ?? ""), `invalid ${digestName}`);
}

for (const record of records) {
  const pair = `${record.source_guide_id}:${record.locale}`;
  requireCondition(["nl", "ru"].includes(record.locale), `unsupported locale for ${pair}`);
  requireCondition(/^[a-z][a-z0-9_-]+$/.test(record.review_category ?? ""), `invalid review category for ${pair}`);
  requireCondition(Number.isInteger(record.translated_field_count) && record.translated_field_count > 0, `invalid field count for ${pair}`);
  requireCondition(["not_started", "in_progress", "failed", "passed"].includes(record.review_status), `unsupported status for ${pair}`);
  if (record.review_status === "passed") {
    requireCondition(typeof record.reviewer_id === "string" && record.reviewer_id, `${pair} passed without a reviewer`);
    requireCondition(typeof record.evidence_registry_entry_id === "string" && record.evidence_registry_entry_id, `${pair} passed without evidence`);
    requireCondition(typeof record.checked_at === "string" && !Number.isNaN(Date.parse(record.checked_at)), `${pair} passed without a valid timestamp`);
    requireCondition(record.publication_eligible === true, `${pair} passed but is not eligible`);
  } else {
    requireCondition(record.publication_eligible === false, `${pair} is eligible before passing review`);
    if (record.review_status === "not_started") {
      requireCondition(record.reviewer_id === null && record.evidence_registry_entry_id === null && record.checked_at === null, `${pair} contains review claims before review started`);
    }
  }
}

requireCondition(
  snapshot.publication_authorized === false || records.every((record) => record.review_status === "passed" && record.publication_eligible === true),
  "publication is authorized before every review record passed"
);

console.log(
  `Verified packaged localization review: ${records.length} records, ${snapshot.admin_snapshot.required_review_checks} required human checks`
);
