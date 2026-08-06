export type LocalizationReviewRecord = {
  source_guide_id: string;
  locale: "nl" | "ru";
  review_category: string;
  translated_field_count: number;
  review_status: string;
  reviewer_id: string | null;
  evidence_registry_entry_id: string | null;
  checked_at: string | null;
  publication_eligible: boolean;
};

export type LocalizationReviewField = {
  path: string;
  source_text: string;
  target_text: string;
  source_ids: string[];
};

export type LocalizationReviewPacket = {
  packet_id: string;
  source_guide_id: string;
  locale: "nl" | "ru";
  review_category: string;
  source_title: string;
  target_title: string;
  search_surface: {
    source_summary: string;
    target_summary: string;
    source_synonyms: string[];
    target_synonyms: string[];
    source_common_questions: string[];
    target_common_questions: string[];
    terminology: Array<{ source: string; target: string; note: string }>;
  };
  review_state: {
    review_status: string;
    reviewer_id: string | null;
    evidence_registry_entry_id: string | null;
    checked_at: string | null;
    publication_eligible: boolean;
  };
  fields: LocalizationReviewField[];
  official_sources: Array<{
    id: string;
    title: string;
    publisher: string;
    url: string;
    checked_at: string;
    status: string;
  }>;
};

export type LocalizationReviewSnapshot = {
  status: string;
  publication_authorized: boolean;
  review_dimensions: string[];
  records: LocalizationReviewRecord[];
  review_packets: LocalizationReviewPacket[];
  admin_snapshot: {
    source: string;
    source_sha256: string;
    translation_bundle_sha256: string;
    source_bundle_sha256: string;
    search_surface_bundle_sha256: string;
    reviewer_registry_sha256: string;
    evidence_registry_sha256: string;
    record_count: number;
    review_packet_count: number;
    review_packet_field_count: number;
    required_review_checks: number;
  };
};

export const guideLabels: Record<string, string> = {
  "guide.getting-a-bsn": "Getting a BSN",
  "guide.finding-a-huisarts": "Finding a huisarts",
  "guide.renting-a-home": "Renting a home",
  "guide.finding-work": "Finding work",
  "guide.understanding-an-employment-contract": "Employment contract",
  "guide.registering-a-child-at-school": "Registering a child at school",
  "guide.choosing-a-sim-card": "Choosing a SIM card",
  "guide.handling-a-parking-fine": "Handling a parking fine"
};

export const dimensionLabels: Record<string, string> = {
  independent_language_review: "Language",
  source_to_translation_review: "Source match",
  editorial_and_domain_review: "Editorial & domain",
  media_and_accessibility_review: "Media & accessibility"
};

export const categoryLabels: Record<string, string> = {
  government: "Government",
  healthcare: "Healthcare",
  housing: "Housing",
  work: "Work",
  education: "Education",
  telecom: "Telecom",
  transport: "Transport"
};

export function reviewPacketHref(packetId: string) {
  return `/localization-review/${encodeURIComponent(packetId)}`;
}

export function summarizeLocalizationReview(snapshot: LocalizationReviewSnapshot) {
  const reviewed = snapshot.records.filter((record) => record.review_status === "passed").length;
  const eligible = snapshot.records.filter((record) => record.publication_eligible).length;
  const fieldCount = snapshot.records.reduce((total, record) => total + record.translated_field_count, 0);
  const complete =
    snapshot.publication_authorized &&
    reviewed === snapshot.records.length &&
    eligible === snapshot.records.length;

  return {
    drafts: snapshot.records.length,
    reviewed,
    eligible,
    fieldCount,
    requiredChecks: snapshot.records.length * snapshot.review_dimensions.length,
    releaseStatus: complete ? "GO" : "NO-GO"
  } as const;
}
