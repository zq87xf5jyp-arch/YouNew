export const PUBLIC_CONTENT_FEED_SCHEMA_VERSION = 1;

const fingerprintPattern = /^[a-f0-9]{64}$/;
const slugPattern = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const supportedLanguages = new Set(["en", "nl", "ru", "uk", "pl"]);

export type PublicContentFeedRecord = {
  id: string;
  kind: "article";
  title: string;
  slug: string;
  summary: string | null;
  content: string | null;
  language: "en" | "nl" | "ru" | "uk" | "pl";
  categorySlug: string | null;
  officialSourceUrl: string;
  verifiedDate: string;
  updatedAt: string;
  publishedAt: string;
};

export type PublicContentFeedPayload =
  | {
      available: false;
      schemaVersion: typeof PUBLIC_CONTENT_FEED_SCHEMA_VERSION;
      recordCount: 0;
      records: [];
    }
  | {
      available: true;
      schemaVersion: typeof PUBLIC_CONTENT_FEED_SCHEMA_VERSION;
      sourceVersion: string;
      fingerprint: string;
      recordCount: number;
      activatedAt: string;
      records: PublicContentFeedRecord[];
    };

type FeedRow = {
  source_version?: unknown;
  artifact?: unknown;
  artifact_fingerprint?: unknown;
  record_count?: unknown;
  activated_at?: unknown;
};

function objectValue(value: unknown): Record<string, unknown> | null {
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? value as Record<string, unknown>
    : null;
}

function requiredText(value: unknown, maxLength: number) {
  return typeof value === "string" && value.trim().length > 0 && value.length <= maxLength
    ? value.trim()
    : null;
}

function optionalText(value: unknown, maxLength: number) {
  if (value === null || value === undefined) return null;
  return typeof value === "string" && value.length <= maxLength ? value.trim() || null : null;
}

function isValidOptionalText(value: unknown, maxLength: number) {
  return value === null || value === undefined || (typeof value === "string" && value.length <= maxLength);
}

function isoDate(value: unknown, dateOnly = false) {
  if (typeof value !== "string") return null;
  if (dateOnly && !/^\d{4}-\d{2}-\d{2}$/.test(value)) return null;
  return Number.isNaN(Date.parse(dateOnly ? `${value}T00:00:00Z` : value)) ? null : value;
}

function httpsUrl(value: unknown) {
  if (typeof value !== "string") return null;
  try {
    const url = new URL(value);
    return url.protocol === "https:" ? url.toString() : null;
  } catch {
    return null;
  }
}

function parseRecord(value: unknown): PublicContentFeedRecord | null {
  const record = objectValue(value);
  if (!record || record.kind !== "article") return null;
  const id = requiredText(record.id, 100);
  const title = requiredText(record.title, 240);
  const slug = requiredText(record.slug, 180);
  const language = requiredText(record.language, 8);
  const officialSourceUrl = httpsUrl(record.officialSourceUrl);
  const verifiedDate = isoDate(record.verifiedDate, true);
  const updatedAt = isoDate(record.updatedAt);
  const publishedAt = isoDate(record.publishedAt);
  const summary = optionalText(record.summary, 2_000);
  const content = optionalText(record.content, 100_000);
  const categorySlug = optionalText(record.categorySlug, 180);
  if (
    !id ||
    !title ||
    !slug ||
    !slugPattern.test(slug) ||
    !language ||
    !supportedLanguages.has(language) ||
    !officialSourceUrl ||
    !verifiedDate ||
    !updatedAt ||
    !publishedAt ||
    !isValidOptionalText(record.summary, 2_000) ||
    !isValidOptionalText(record.content, 100_000) ||
    !isValidOptionalText(record.categorySlug, 180) ||
    (categorySlug !== null && !slugPattern.test(categorySlug))
  ) return null;

  return {
    id,
    kind: "article",
    title,
    slug,
    summary,
    content,
    language: language as PublicContentFeedRecord["language"],
    categorySlug,
    officialSourceUrl,
    verifiedDate,
    updatedAt,
    publishedAt
  };
}

export function emptyPublicContentFeed(): PublicContentFeedPayload {
  return {
    available: false,
    schemaVersion: PUBLIC_CONTENT_FEED_SCHEMA_VERSION,
    recordCount: 0,
    records: []
  };
}

export function buildPublicContentFeed(row: FeedRow): PublicContentFeedPayload {
  const artifact = objectValue(row.artifact);
  const sourceVersion = requiredText(row.source_version, 180);
  const artifactSourceVersion = requiredText(artifact?.sourceVersion, 180);
  const fingerprint = requiredText(row.artifact_fingerprint, 64);
  const activatedAt = isoDate(row.activated_at);
  const storedCount = typeof row.record_count === "number" && Number.isInteger(row.record_count)
    ? row.record_count
    : -1;
  if (
    !artifact ||
    artifact.schemaVersion !== PUBLIC_CONTENT_FEED_SCHEMA_VERSION ||
    artifact.source !== "supabase-operational" ||
    !Array.isArray(artifact.records) ||
    !sourceVersion ||
    artifactSourceVersion !== sourceVersion ||
    !fingerprint ||
    !fingerprintPattern.test(fingerprint) ||
    !activatedAt ||
    storedCount <= 0 ||
    artifact.recordCount !== storedCount ||
    artifact.records.length !== storedCount
  ) throw new Error("invalid_public_content_feed");

  const records = artifact.records.map(parseRecord);
  if (records.some((record) => record === null)) throw new Error("invalid_public_content_record");
  const safeRecords = records as PublicContentFeedRecord[];
  if (new Set(safeRecords.map(({ id }) => id)).size !== safeRecords.length) {
    throw new Error("duplicate_public_content_record_id");
  }
  if (new Set(safeRecords.map(({ slug }) => slug)).size !== safeRecords.length) {
    throw new Error("duplicate_public_content_record_slug");
  }

  return {
    available: true,
    schemaVersion: PUBLIC_CONTENT_FEED_SCHEMA_VERSION,
    sourceVersion,
    fingerprint,
    recordCount: safeRecords.length,
    activatedAt,
    records: safeRecords
  };
}
