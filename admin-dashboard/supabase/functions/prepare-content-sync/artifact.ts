export type PublishedArticleRecord = {
  id: string;
  title: string;
  slug: string;
  short_description: string | null;
  full_content: string | null;
  language: string;
  source_url: string | null;
  verified_date: string | null;
  updated_at: string;
  published_at: string | null;
  category_id: string | null;
  categories?:
    | { slug?: string | null }
    | Array<{ slug?: string | null }>
    | null;
};

function categorySlug(value: PublishedArticleRecord["categories"]) {
  if (Array.isArray(value)) return value[0]?.slug ?? null;
  return value?.slug ?? null;
}

export function buildPublishedContentArtifact(
  records: PublishedArticleRecord[],
) {
  const normalized = records
    .map((record) => ({
      id: record.id,
      kind: "article",
      title: record.title,
      slug: record.slug,
      summary: record.short_description,
      content: record.full_content,
      language: record.language,
      categoryId: record.category_id,
      categorySlug: categorySlug(record.categories),
      officialSourceUrl: record.source_url,
      verifiedDate: record.verified_date,
      updatedAt: record.updated_at,
      publishedAt: record.published_at,
    }))
    .sort((left, right) => left.id.localeCompare(right.id));
  const sourceVersion = normalized.reduce(
    (latest, record) => record.updatedAt > latest ? record.updatedAt : latest,
    "1970-01-01T00:00:00.000Z",
  );
  return {
    schemaVersion: 1,
    source: "supabase-operational",
    sourceVersion,
    generatedAt: sourceVersion,
    recordCount: normalized.length,
    records: normalized,
  };
}

export async function fingerprintArtifact(
  artifact: ReturnType<typeof buildPublishedContentArtifact>,
) {
  const digest = await crypto.subtle.digest(
    "SHA-256",
    new TextEncoder().encode(JSON.stringify(artifact)),
  );
  return Array.from(
    new Uint8Array(digest),
    (byte) => byte.toString(16).padStart(2, "0"),
  ).join("");
}
