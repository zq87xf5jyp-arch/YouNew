"use server";

import { revalidatePath } from "next/cache";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { requireAdmin } from "@/lib/auth";
import { canEditContent } from "@/lib/authorization";
import type { ManagedArticle } from "@/components/admin/content-manager";
import { CONTENT_IMAGES_BUCKET, normalizeManagedContentImages } from "@/lib/content-images";

type ArticleInput = Omit<ManagedArticle, "id" | "updatedAt">;

function listValues(value: string, { lowercase = true }: { lowercase?: boolean } = {}) {
  return [...new Set(value
    .split(/[\n,]/u)
    .map((item) => item.trim())
    .filter(Boolean)
    .map((item) => lowercase ? item.toLocaleLowerCase("und") : item))];
}

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
  if (!input.canonicalTitle.trim()) errors.push("canonical_title");
  if (listValues(input.intents).length === 0) errors.push("search_intents");
  if (listValues(input.synonyms).length === 0) errors.push("search_synonyms");
  if (listValues(input.keywords).length === 0) errors.push("search_keywords");
  if (listValues(input.supportedLanguages).length === 0) errors.push("supported_languages");
  if (listValues(input.applicableProfiles).length === 0) errors.push("applicable_profiles");
  if (["municipality", "city", "neighbourhood"].includes(input.scopeLevel) && !input.municipality.trim() && !input.city.trim()) errors.push("city_mapping");
  if (input.contentQualityScore <= 0) errors.push("content_quality_score");
  if (!input.searchIndexed) errors.push("search_indexed");
  if (input.requiresMedia && input.images.length === 0) errors.push("required_media");
  return errors;
}

function articlePayload(input: ArticleInput, categoryId: string | null, authorId: string) {
  if (input.status === "published") {
    throw new Error(
      "Прямая публикация из редактора заблокирована. Сохраните draft/qa и используйте Human Review Queue."
    );
  }
  const errors = contentValidationErrors(input, categoryId);
  const source = input.source?.trim() || null;
  const sourceUrls = [...new Set([
    ...(source ? [source] : []),
    ...listValues(input.sourceUrls, { lowercase: false })
  ])];
  return {
    title: input.title.trim(),
    canonical_title: input.canonicalTitle.trim(),
    slug: input.slug.trim(),
    category_id: categoryId,
    subcategory: input.subcategory.trim() || null,
    language: input.language.trim(),
    supported_languages: listValues(input.supportedLanguages),
    status: input.status,
    priority: input.priority,
    short_description: input.description?.trim() || null,
    full_content: input.content?.trim() || null,
    source_url: source,
    official_source: Boolean(source?.startsWith("https://")),
    tags: input.tags?.split(",").map((tag) => tag.trim()).filter(Boolean) ?? [],
    search_intents: listValues(input.intents),
    search_synonyms: listValues(input.synonyms),
    search_keywords: listValues(input.keywords),
    country_scope: "NL",
    scope_level: input.scopeLevel,
    province: input.province.trim() || null,
    municipality: input.municipality.trim() || null,
    city: input.city.trim() || null,
    national_fallback: input.nationalFallback,
    applicable_profiles: listValues(input.applicableProfiles),
    source_urls: sourceUrls,
    content_quality_score: Math.max(0, Math.min(100, Math.round(input.contentQualityScore))),
    search_indexed: input.searchIndexed,
    images: normalizeManagedContentImages(input.images),
    requires_media: input.requiresMedia,
    source_mapping: sourceUrls.map((url) => ({ url, type: "official" })),
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
    .select("id,updated_at")
    .single();

  if (error) throw new Error(error.code === "23505" ? "Материал с таким слагом уже существует." : error.message);
  revalidatePath("/content");
  return { ...input, id: data.id, updatedAt: data.updated_at } satisfies ManagedArticle;
}

export async function updateArticle(id: string, input: ArticleInput) {
  const { supabase, user } = await getAuthorizedClient();
  const categoryId = await resolveCategoryId(supabase, input.category);
  const { data, error } = await supabase
    .from("articles")
    .update(articlePayload(input, categoryId, user.id))
    .eq("id", id)
    .select("id,updated_at")
    .single();

  if (error) throw new Error(error.code === "23505" ? "Материал с таким слагом уже существует." : error.message);
  revalidatePath("/content");
  return { ...input, id: data.id, updatedAt: data.updated_at } satisfies ManagedArticle;
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
