export const ADMIN_CONTENT_FEED_URL =
  process.env.NEXT_PUBLIC_ADMIN_CONTENT_FEED_URL
  ?? "https://admin.younew.nl/api/public/content-sync";

const fingerprintPattern = /^[a-f0-9]{64}$/;
const slugPattern = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;
const supportedLanguages = new Set(["en", "nl", "ru", "uk", "pl"]);

export type AdminContentRecord = {
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

export type AdminContentFeed =
  | {
      available: false;
      schemaVersion: 1;
      recordCount: 0;
      records: [];
    }
  | {
      available: true;
      schemaVersion: 1;
      sourceVersion: string;
      fingerprint: string;
      recordCount: number;
      activatedAt: string;
      records: AdminContentRecord[];
    };

function objectValue(value: unknown): Record<string, unknown> | null {
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? value as Record<string, unknown>
    : null;
}

function text(value: unknown, maxLength: number) {
  return typeof value === "string" && value.trim().length > 0 && value.length <= maxLength
    ? value.trim()
    : null;
}

function nullableText(value: unknown, maxLength: number) {
  if (value === null) return null;
  return text(value, maxLength);
}

function date(value: unknown, dateOnly = false) {
  if (typeof value !== "string") return null;
  if (dateOnly && !/^\d{4}-\d{2}-\d{2}$/.test(value)) return null;
  return Number.isNaN(Date.parse(dateOnly ? `${value}T00:00:00Z` : value)) ? null : value;
}

function httpsUrl(value: unknown) {
  if (typeof value !== "string") return null;
  try {
    const parsed = new URL(value);
    return parsed.protocol === "https:" ? parsed.toString() : null;
  } catch {
    return null;
  }
}

function parseRecord(value: unknown): AdminContentRecord | null {
  const record = objectValue(value);
  if (!record || record.kind !== "article") return null;
  const id = text(record.id, 100);
  const title = text(record.title, 240);
  const slug = text(record.slug, 180);
  const language = text(record.language, 8);
  const categorySlug = nullableText(record.categorySlug, 180);
  const officialSourceUrl = httpsUrl(record.officialSourceUrl);
  const verifiedDate = date(record.verifiedDate, true);
  const updatedAt = date(record.updatedAt);
  const publishedAt = date(record.publishedAt);
  const summary = nullableText(record.summary, 2_000);
  const content = nullableText(record.content, 100_000);
  if (
    !id ||
    !title ||
    !slug ||
    !slugPattern.test(slug) ||
    !language ||
    !supportedLanguages.has(language) ||
    (record.categorySlug !== null && categorySlug === null) ||
    (categorySlug !== null && !slugPattern.test(categorySlug)) ||
    (record.summary !== null && summary === null) ||
    (record.content !== null && content === null) ||
    !officialSourceUrl ||
    !verifiedDate ||
    !updatedAt ||
    !publishedAt
  ) return null;

  return {
    id,
    kind: "article",
    title,
    slug,
    summary,
    content,
    language: language as AdminContentRecord["language"],
    categorySlug,
    officialSourceUrl,
    verifiedDate,
    updatedAt,
    publishedAt
  };
}

export function parseAdminContentFeed(value: unknown): AdminContentFeed | null {
  const feed = objectValue(value);
  if (!feed || feed.schemaVersion !== 1 || !Array.isArray(feed.records)) return null;

  if (feed.available === false) {
    return feed.recordCount === 0 && feed.records.length === 0
      ? { available: false, schemaVersion: 1, recordCount: 0, records: [] }
      : null;
  }
  if (feed.available !== true) return null;

  const sourceVersion = text(feed.sourceVersion, 180);
  const fingerprint = text(feed.fingerprint, 64);
  const activatedAt = date(feed.activatedAt);
  const recordCount = typeof feed.recordCount === "number" && Number.isInteger(feed.recordCount)
    ? feed.recordCount
    : -1;
  if (
    !sourceVersion ||
    !fingerprint ||
    !fingerprintPattern.test(fingerprint) ||
    !activatedAt ||
    recordCount <= 0 ||
    recordCount > 500 ||
    feed.records.length !== recordCount
  ) return null;

  const records = feed.records.map(parseRecord);
  if (records.some((record) => record === null)) return null;
  const safeRecords = records as AdminContentRecord[];
  if (new Set(safeRecords.map(({ id }) => id)).size !== safeRecords.length) return null;
  if (new Set(safeRecords.map(({ slug }) => slug)).size !== safeRecords.length) return null;

  return {
    available: true,
    schemaVersion: 1,
    sourceVersion,
    fingerprint,
    recordCount,
    activatedAt,
    records: safeRecords
  };
}
