"use server";

import { revalidatePath } from "next/cache";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { requireAdmin } from "@/lib/auth";
import { canEditContent } from "@/lib/authorization";
import type { ManagedArticle } from "@/components/admin/content-manager";
import { CONTENT_IMAGES_BUCKET, normalizeManagedContentImages } from "@/lib/content-images";

type ArticleInput = Omit<ManagedArticle, "id" | "updatedAt">;

async function getAuthorizedClient() {
  const admin = await requireAdmin();
  if (!canEditContent(admin.role)) throw new Error("Недостаточно прав: требуется роль Admin или Editor.");
  const supabase = await createSupabaseServerClient();
  if (!supabase) throw new Error("Supabase не настроен.");

  const { data: { user }, error } = await supabase.auth.getUser();
  if (error || !user) throw new Error("Войдите в аккаунт администратора.");
  return { admin, supabase, user };
}

async function resolveCategoryId(
  supabase: NonNullable<Awaited<ReturnType<typeof createSupabaseServerClient>>>,
  slug: string
) {
  const { data, error } = await supabase.from("categories").select("id").eq("slug", slug).maybeSingle();
  if (error) throw new Error(error.message);
  return data?.id ?? null;
}

function contentValidationErrors(input: ArticleInput, categoryId: string | null) {
  const errors: string[] = [];
  if (!input.title.trim()) errors.push("title");
  if (!input.description?.trim()) errors.push("short_description");
  if (!input.content?.trim()) errors.push("full_content");
  if (!categoryId) errors.push("public_category");
  if (!input.source?.trim().startsWith("https://")) errors.push("official_source");
  if (input.requiresMedia && input.images.length === 0) errors.push("required_media");
  return errors;
}

function commaSeparated(value: string) {
  return [...new Set(value.split(",").map((item) => item.trim()).filter(Boolean))];
}

function articlePayload(input: ArticleInput, categoryId: string | null, authorId: string) {
  if (input.status === "published") {
    throw new Error(
      "Прямая публикация из редактора заблокирована. Сохраните draft/qa и используйте Human Review Queue."
    );
  }
  const errors = contentValidationErrors(input, categoryId);
  const source = input.source?.trim() || null;
  return {
    title: input.title.trim(),
    slug: input.slug.trim(),
    category_id: categoryId,
    language: input.language.trim(),
    status: input.status,
    priority: input.priority,
    short_description: input.description?.trim() || null,
    full_content: input.content?.trim() || null,
    source_url: source,
    official_source: Boolean(source?.startsWith("https://")),
    tags: input.tags?.split(",").map((tag) => tag.trim()).filter(Boolean) ?? [],
    canonical_title: input.canonicalTitle.trim() || input.title.trim(),
    search_subcategory: input.searchSubcategory.trim() || null,
    search_intents: commaSeparated(input.searchIntents),
    search_synonyms: {
      en: commaSeparated(input.synonymsEn),
      nl: commaSeparated(input.synonymsNl),
      ru: commaSeparated(input.synonymsRu)
    },
    search_keywords: commaSeparated(input.searchKeywords),
    search_languages: commaSeparated(input.searchLanguages),
    content_scope: input.contentScope,
    province_id: input.provinceId.trim() || null,
    municipality_id: input.municipalityId.trim() || null,
    city_id: input.cityId.trim() || null,
    national_fallback: input.nationalFallback,
    audience_profiles: commaSeparated(input.audienceProfiles),
    images: normalizeManagedContentImages(input.images),
    requires_media: input.requiresMedia,
    source_mapping: source ? [{ url: source, type: "official" }] : [],
    publication_evidence: {},
    validation_passed: false,
    validation_errors: errors,
    author_id: authorId,
    published_at: null
  };
}

export async function createArticle(input: ArticleInput) {
  const { supabase, user } = await getAuthorizedClient();
  const categoryId = await resolveCategoryId(supabase, input.category);
  const { data, error } = await supabase
    .from("articles")
    .insert(articlePayload(input, categoryId, user.id))
    .select("id,updated_at,search_quality_score,search_indexed,search_warnings")
    .single();

  if (error) throw new Error(error.code === "23505" ? "Материал с таким слагом уже существует." : error.message);
  revalidatePath("/content");
  return {
    ...input,
    id: data.id,
    updatedAt: data.updated_at,
    searchQualityScore: data.search_quality_score,
    searchIndexed: data.search_indexed,
    searchWarnings: data.search_warnings
  } satisfies ManagedArticle;
}

export async function updateArticle(id: string, input: ArticleInput) {
  const { supabase, user } = await getAuthorizedClient();
  const categoryId = await resolveCategoryId(supabase, input.category);
  const { data, error } = await supabase
    .from("articles")
    .update(articlePayload(input, categoryId, user.id))
    .eq("id", id)
    .select("id,updated_at,search_quality_score,search_indexed,search_warnings")
    .single();

  if (error) throw new Error(error.code === "23505" ? "Материал с таким слагом уже существует." : error.message);
  revalidatePath("/content");
  return {
    ...input,
    id: data.id,
    updatedAt: data.updated_at,
    searchQualityScore: data.search_quality_score,
    searchIndexed: data.search_indexed,
    searchWarnings: data.search_warnings
  } satisfies ManagedArticle;
}

export async function deleteArticle(id: string) {
  const { supabase } = await getAuthorizedClient();
  const { data: article, error: readError } = await supabase.from("articles").select("images").eq("id", id).maybeSingle();
  if (readError) throw new Error(readError.message);
  const { error } = await supabase.from("articles").delete().eq("id", id);
  if (error) throw new Error(error.message);
  const paths = normalizeManagedContentImages(article?.images).map((image) => image.path);
  const { error: storageError } = paths.length > 0
    ? await supabase.storage.from(CONTENT_IMAGES_BUCKET).remove(paths)
    : { error: null };
  revalidatePath("/content");
  return {
    cleanupWarning: storageError
      ? "Материал удалён, но часть файлов не удалось очистить из Supabase Storage."
      : null
  };
}
