import { PageHeader } from "@/components/admin/page-header";
import { ContentManager, type ManagedArticle } from "@/components/admin/content-manager";
import { sampleArticles } from "@/lib/data";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { requireAdmin } from "@/lib/auth";
import { canEditContent } from "@/lib/authorization";
import { normalizeManagedContentImages } from "@/lib/content-images";

export default async function ContentPage() {
  const admin = await requireAdmin();
  const supabase = await createSupabaseServerClient();
  const { data } = supabase
    ? await supabase
        .from("articles")
        .select("id,title,slug,short_description,full_content,language,status,priority,source_url,tags,images,verified_date,reviewer_id,requires_media,canonical_title,search_subcategory,search_intents,search_synonyms,search_keywords,search_languages,content_scope,province_id,municipality_id,city_id,national_fallback,audience_profiles,search_quality_score,search_indexed,search_warnings,updated_at,categories(slug)")
        .order("updated_at", { ascending: false })
        .limit(100)
    : { data: null };
  const rows = data ?? (process.env.NODE_ENV !== "production" && process.env.YOUNEW_ADMIN_DEMO_MODE === "true" ? sampleArticles : []);
  const initialRows: ManagedArticle[] = rows.map((row, index) => ({
    id: String((row as { id?: unknown }).id ?? `initial-${index + 1}`),
    title: String((row as { title?: unknown }).title ?? "Без названия"),
    slug: String((row as { slug?: unknown }).slug ?? `material-${index + 1}`),
    category: String(
      (row as { categories?: { slug?: unknown } | null }).categories?.slug ??
      (row as { category?: unknown }).category ??
      "documents-services"
    ),
    language: String((row as { language?: unknown }).language ?? "ru"),
    status: ((row as { status?: unknown }).status ?? "draft") as ManagedArticle["status"],
    priority: Number((row as { priority?: unknown }).priority ?? index + 1),
    description: String((row as { short_description?: unknown }).short_description ?? ""),
    content: String((row as { full_content?: unknown }).full_content ?? ""),
    source: String((row as { source_url?: unknown }).source_url ?? ""),
    tags: Array.isArray((row as { tags?: unknown }).tags) ? (row as { tags: unknown[] }).tags.join(", ") : "",
    images: normalizeManagedContentImages((row as { images?: unknown }).images),
    verifiedDate: String((row as { verified_date?: unknown }).verified_date ?? ""),
    reviewConfirmed: Boolean((row as { reviewer_id?: unknown }).reviewer_id),
    requiresMedia: Boolean((row as { requires_media?: unknown }).requires_media),
    canonicalTitle: String((row as { canonical_title?: unknown }).canonical_title ?? (row as { title?: unknown }).title ?? ""),
    searchSubcategory: String((row as { search_subcategory?: unknown }).search_subcategory ?? ""),
    searchIntents: Array.isArray((row as { search_intents?: unknown }).search_intents) ? (row as { search_intents: unknown[] }).search_intents.join(", ") : "",
    synonymsEn: Array.isArray((row as { search_synonyms?: { en?: unknown } }).search_synonyms?.en) ? ((row as { search_synonyms: { en: unknown[] } }).search_synonyms.en).join(", ") : "",
    synonymsNl: Array.isArray((row as { search_synonyms?: { nl?: unknown } }).search_synonyms?.nl) ? ((row as { search_synonyms: { nl: unknown[] } }).search_synonyms.nl).join(", ") : "",
    synonymsRu: Array.isArray((row as { search_synonyms?: { ru?: unknown } }).search_synonyms?.ru) ? ((row as { search_synonyms: { ru: unknown[] } }).search_synonyms.ru).join(", ") : "",
    searchKeywords: Array.isArray((row as { search_keywords?: unknown }).search_keywords) ? (row as { search_keywords: unknown[] }).search_keywords.join(", ") : "",
    searchLanguages: Array.isArray((row as { search_languages?: unknown }).search_languages) ? (row as { search_languages: unknown[] }).search_languages.join(", ") : "",
    contentScope: String((row as { content_scope?: unknown }).content_scope ?? "national") as ManagedArticle["contentScope"],
    provinceId: String((row as { province_id?: unknown }).province_id ?? ""),
    municipalityId: String((row as { municipality_id?: unknown }).municipality_id ?? ""),
    cityId: String((row as { city_id?: unknown }).city_id ?? ""),
    nationalFallback: Boolean((row as { national_fallback?: unknown }).national_fallback ?? true),
    audienceProfiles: Array.isArray((row as { audience_profiles?: unknown }).audience_profiles) ? (row as { audience_profiles: unknown[] }).audience_profiles.join(", ") : "",
    searchQualityScore: Number((row as { search_quality_score?: unknown }).search_quality_score ?? 0),
    searchIndexed: Boolean((row as { search_indexed?: unknown }).search_indexed),
    searchWarnings: Array.isArray((row as { search_warnings?: unknown }).search_warnings) ? (row as { search_warnings: unknown[] }).search_warnings.map(String) : [],
    updatedAt: String((row as { updated_at?: unknown }).updated_at ?? "")
  }));
  return (
    <>
      <PageHeader title="Управление контентом" description="Создавайте и проверяйте статьи, транспортные гайды, справочные материалы, FAQ, экстренные контакты и источники знаний для AI." />
      <ContentManager
        initialRows={initialRows}
        supabaseEnabled={Boolean(supabase)}
        canEdit={canEditContent(admin.role)}
      />
    </>
  );
}
