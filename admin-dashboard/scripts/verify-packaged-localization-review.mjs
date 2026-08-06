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
const packets = snapshot.review_packets ?? [];
const recordPairs = records.map((record) => `${record.source_guide_id}:${record.locale}`);
const recordsByPair = new Map(records.map((record) => [`${record.source_guide_id}:${record.locale}`, record]));

requireCondition(snapshot.schema_version === 1, "unsupported schema version");
requireCondition(snapshot.policy?.automated_reviewers_allowed === false, "automated review is not forbidden");
requireCondition(snapshot.policy?.registered_human_reviewer_required === true, "human reviewer gate is missing");
requireCondition(snapshot.policy?.passed_evidence_registry_entry_required === true, "evidence gate is missing");
requireCondition(snapshot.policy?.all_review_dimensions_required === true, "all-dimensions gate is missing");
requireCondition(JSON.stringify(snapshot.review_dimensions) === JSON.stringify(requiredDimensions), "review dimensions mismatch");
requireCondition(records.length === 16, "snapshot must contain 16 guide-locale records");
requireCondition(new Set(recordPairs).size === records.length, "snapshot contains duplicate guide-locale records");
requireCondition(snapshot.admin_snapshot?.record_count === records.length, "record count metadata mismatch");
requireCondition(packets.length === records.length, "snapshot must contain one review packet per record");
requireCondition(snapshot.admin_snapshot?.review_packet_count === packets.length, "review packet count metadata mismatch");
requireCondition(snapshot.admin_snapshot?.review_packet_field_count === packets.reduce((total, packet) => total + (packet.fields?.length ?? 0), 0), "review packet field count metadata mismatch");
requireCondition(snapshot.admin_snapshot?.required_review_checks === records.length * requiredDimensions.length, "required check count mismatch");

for (const digestName of ["source_sha256", "translation_bundle_sha256", "source_bundle_sha256", "search_surface_bundle_sha256", "reviewer_registry_sha256", "evidence_registry_sha256"]) {
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

requireCondition(new Set(packets.map((packet) => packet.packet_id)).size === packets.length, "snapshot contains duplicate review packet IDs");
for (const packet of packets) {
  const pair = `${packet.source_guide_id}:${packet.locale}`;
  const record = recordsByPair.get(pair);
  requireCondition(record, `${pair} review packet has no governed record`);
  requireCondition(typeof packet.packet_id === "string" && /^[a-z0-9-]+$/.test(packet.packet_id), `${pair} has an invalid review packet ID`);
  requireCondition(packet.review_category === record.review_category, `${pair} review packet category mismatch`);
  requireCondition(packet.fields?.length === record.translated_field_count, `${pair} review packet field count mismatch`);
  requireCondition(packet.review_state?.review_status === record.review_status, `${pair} review packet status mismatch`);
  requireCondition(packet.review_state?.reviewer_id === record.reviewer_id, `${pair} review packet reviewer mismatch`);
  requireCondition(packet.review_state?.evidence_registry_entry_id === record.evidence_registry_entry_id, `${pair} review packet evidence mismatch`);
  requireCondition(packet.review_state?.checked_at === record.checked_at, `${pair} review packet timestamp mismatch`);
  requireCondition(packet.review_state?.publication_eligible === record.publication_eligible, `${pair} review packet publication state mismatch`);
  requireCondition(typeof packet.source_title === "string" && packet.source_title.trim(), `${pair} source title is missing`);
  requireCondition(typeof packet.target_title === "string" && packet.target_title.trim(), `${pair} target title is missing`);
  requireCondition(typeof packet.search_surface?.source_summary === "string" && packet.search_surface.source_summary.trim(), `${pair} source summary is missing`);
  requireCondition(typeof packet.search_surface?.target_summary === "string" && packet.search_surface.target_summary.trim(), `${pair} target summary is missing`);
  requireCondition(Array.isArray(packet.search_surface?.source_synonyms) && packet.search_surface.source_synonyms.length > 0, `${pair} source synonyms are missing`);
  requireCondition(Array.isArray(packet.search_surface?.target_synonyms) && packet.search_surface.target_synonyms.length >= 8, `${pair} target synonyms are incomplete`);
  requireCondition(Array.isArray(packet.search_surface?.source_common_questions) && packet.search_surface.source_common_questions.length >= 3, `${pair} source questions are incomplete`);
  requireCondition(Array.isArray(packet.search_surface?.target_common_questions) && packet.search_surface.target_common_questions.length >= 3, `${pair} target questions are incomplete`);
  requireCondition(Array.isArray(packet.search_surface?.terminology) && packet.search_surface.terminology.length > 0, `${pair} terminology notes are missing`);

  const sourceIds = new Set();
  for (const source of packet.official_sources ?? []) {
    requireCondition(typeof source.id === "string" && !sourceIds.has(source.id), `${pair} contains a missing or duplicate official source ID`);
    requireCondition(typeof source.url === "string" && source.url.startsWith("https://"), `${pair} official source ${source.id} has an unsafe URL`);
    sourceIds.add(source.id);
  }

  const paths = new Set();
  for (const field of packet.fields) {
    requireCondition(typeof field.path === "string" && !paths.has(field.path), `${pair} contains a missing or duplicate field path`);
    requireCondition(typeof field.source_text === "string" && field.source_text.trim(), `${pair} field ${field.path} has no source text`);
    requireCondition(typeof field.target_text === "string" && field.target_text.trim(), `${pair} field ${field.path} has no target text`);
    requireCondition(Array.isArray(field.source_ids) && field.source_ids.every((sourceId) => sourceIds.has(sourceId)), `${pair} field ${field.path} has an unresolved source ID`);
    paths.add(field.path);
  }
}

requireCondition(
  snapshot.publication_authorized === false || records.every((record) => record.review_status === "passed" && record.publication_eligible === true),
  "publication is authorized before every review record passed"
);

console.log(
  `Verified packaged localization review: ${records.length} records, ${packets.length} review packets, ${snapshot.admin_snapshot.required_review_checks} required human checks`
);
