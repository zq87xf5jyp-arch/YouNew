import { PageHeader } from "@/components/admin/page-header";
import { ContentManager, type ManagedArticle } from "@/components/admin/content-manager";
import { ReadOnlySource, type ReadOnlySourceState } from "@/components/admin/read-only-source";
import { sampleArticles } from "@/lib/data";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { requireAdmin } from "@/lib/auth";
import { canEditContent, canPublishContent } from "@/lib/authorization";
import { normalizeManagedContentImages } from "@/lib/content-images";

export default async function ContentPage() {
  const admin = await requireAdmin();
  const supabase = await createSupabaseServerClient();
  const queryResult = supabase
    ? await supabase
        .from("articles")
        .select("id,title,slug,short_description,full_content,language,status,priority,source_url,tags,images,verified_date,reviewer_id,requires_media,updated_at,canonical_title,subcategory,search_intents,search_synonyms,search_keywords,supported_languages,country_scope,scope_level,province,municipality,city,national_fallback,applicable_profiles,source_urls,content_quality_score,search_indexed,categories(slug)")
        .order("updated_at", { ascending: false })
        .limit(100)
    : { data: null, error: null };
  const explicitDemo = !supabase && process.env.NODE_ENV !== "production" && process.env.YOUNEW_ADMIN_DEMO_MODE === "true";
  const forbidden = Boolean(queryResult.error && (
    ["42501", "PGRST301", "PGRST302"].includes(String(queryResult.error.code ?? ""))
    || String(queryResult.error.message ?? "").toLowerCase().includes("permission denied")
    || String(queryResult.error.message ?? "").toLowerCase().includes("row-level security")
  ));
  const sourceState: ReadOnlySourceState = explicitDemo
    ? "demo"
    : !supabase || queryResult.error
      ? forbidden ? "forbidden" : "unavailable"
      : (queryResult.data?.length ?? 0) > 0 ? "data" : "empty";
  const dataMode = sourceState === "data" || sourceState === "empty"
    ? "supabase"
    : sourceState === "demo" ? "demo" : sourceState === "forbidden" ? "forbidden" : "unavailable";
  const rows = explicitDemo ? sampleArticles : queryResult.data ?? [];
  const initialRows: ManagedArticle[] = rows.map((row, index) => ({
    id: String((row as { id?: unknown }).id ?? `initial-${index + 1}`),
    title: String((row as { title?: unknown }).title ?? "Без названия"),
    slug: String((row as { slug?: unknown }).slug ?? `material-${index + 1}`),
    category: String(
      (row as { categories?: { slug?: unknown } | null }).categories?.slug ??
      (row as { category?: unknown }).category ??
      "documents"
    ),
    language: String((row as { language?: unknown }).language ?? "ru"),
    status: ((row as { status?: unknown }).status ?? "draft") as ManagedArticle["status"],
    priority: Number((row as { priority?: unknown }).priority ?? index + 1),
    description: String((row as { short_description?: unknown }).short_description ?? ""),
    content: String((row as { full_content?: unknown }).full_content ?? ""),
    source: String((row as { source_url?: unknown }).source_url ?? ""),
    tags: Array.isArray((row as { tags?: unknown }).tags) ? (row as { tags: unknown[] }).tags.join(", ") : "",
    canonicalTitle: String((row as { canonical_title?: unknown }).canonical_title ?? (row as { title?: unknown }).title ?? ""),
    subcategory: String((row as { subcategory?: unknown }).subcategory ?? ""),
    intents: Array.isArray((row as { search_intents?: unknown }).search_intents) ? (row as { search_intents: unknown[] }).search_intents.join(", ") : "",
    synonyms: Array.isArray((row as { search_synonyms?: unknown }).search_synonyms) ? (row as { search_synonyms: unknown[] }).search_synonyms.join(", ") : "",
    keywords: Array.isArray((row as { search_keywords?: unknown }).search_keywords) ? (row as { search_keywords: unknown[] }).search_keywords.join(", ") : "",
    supportedLanguages: Array.isArray((row as { supported_languages?: unknown }).supported_languages) ? (row as { supported_languages: unknown[] }).supported_languages.join(", ") : String((row as { language?: unknown }).language ?? "en"),
    countryScope: "NL",
    scopeLevel: String((row as { scope_level?: unknown }).scope_level ?? "national") as ManagedArticle["scopeLevel"],
    province: String((row as { province?: unknown }).province ?? ""),
    municipality: String((row as { municipality?: unknown }).municipality ?? ""),
    city: String((row as { city?: unknown }).city ?? ""),
    nationalFallback: (row as { national_fallback?: unknown }).national_fallback !== false,
    applicableProfiles: Array.isArray((row as { applicable_profiles?: unknown }).applicable_profiles) ? (row as { applicable_profiles: unknown[] }).applicable_profiles.join(", ") : "",
    sourceUrls: Array.isArray((row as { source_urls?: unknown }).source_urls) ? (row as { source_urls: unknown[] }).source_urls.join("\n") : "",
    contentQualityScore: Number((row as { content_quality_score?: unknown }).content_quality_score ?? 0),
    searchIndexed: Boolean((row as { search_indexed?: unknown }).search_indexed),
    images: normalizeManagedContentImages((row as { images?: unknown }).images),
    verifiedDate: String((row as { verified_date?: unknown }).verified_date ?? ""),
    reviewConfirmed: Boolean((row as { reviewer_id?: unknown }).reviewer_id),
    requiresMedia: Boolean((row as { requires_media?: unknown }).requires_media),
    updatedAt: String((row as { updated_at?: unknown }).updated_at ?? "")
  }));
  return (
    <>
      <PageHeader title="Управление контентом" description="Создавайте и проверяйте статьи, транспортные гайды, справочные материалы, FAQ, экстренные контакты и источники знаний для AI." />
      <ReadOnlySource
        state={sourceState}
        label={sourceState === "demo" ? "explicit synthetic demo" : "Supabase articles"}
        detail={sourceState === "data" || sourceState === "empty"
          ? `Authoritative query completed; ${initialRows.length} rows returned.`
          : sourceState === "demo"
            ? "No Supabase connection is used. Demo rows are visibly non-operational."
            : "Authoritative read failed, so remote mutations are disabled and no zero count is claimed."}
      />
      <ContentManager
        initialRows={initialRows}
        dataMode={dataMode}
        canEdit={canEditContent(admin.role) && (dataMode === "supabase" || dataMode === "demo")}
        canManagePublished={canPublishContent(admin.role)}
      />
    </>
  );
}
