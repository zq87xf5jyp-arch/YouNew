"use server";

import { revalidatePath } from "next/cache";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { createSupabaseAdminClient } from "@/lib/supabase/admin";
import { requireAdmin } from "@/lib/auth";
import { canEditArticle, canEditContent } from "@/lib/authorization";
import type { ManagedArticle } from "@/components/admin/content-manager";
import {
  CONTENT_IMAGE_CLEANUP_CANDIDATE_LIMIT,
  CONTENT_IMAGE_LIMIT,
  CONTENT_IMAGES_BUCKET,
  isManagedContentImagePath,
  normalizeManagedContentImages
} from "@/lib/content-images";

type ArticleInput = Omit<ManagedArticle, "id" | "updatedAt">;
const CONTENT_IMAGE_CLEANUP_BATCH_LIMIT = CONTENT_IMAGE_CLEANUP_CANDIDATE_LIMIT + CONTENT_IMAGE_LIMIT;

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

function normalizeCleanupCandidatePaths(
  candidatePaths: unknown,
  limit = CONTENT_IMAGE_CLEANUP_CANDIDATE_LIMIT
) {
  if (!Array.isArray(candidatePaths)) return [];
  return [...new Set(candidatePaths.slice(0, limit).filter(isManagedContentImagePath))];
}

async function removeUnreferencedContentImages(candidatePaths: unknown) {
  const paths = normalizeCleanupCandidatePaths(candidatePaths, CONTENT_IMAGE_CLEANUP_BATCH_LIMIT);
  if (paths.length === 0) return { cleanupWarning: null };

  try {
    const adminClient = createSupabaseAdminClient();
    if (!adminClient) {
      return {
        cleanupWarning: "Материал сохранён, но серверная очистка удалённых изображений не настроена."
      };
    }

    const { data: referencedRows, error: referenceError } = await adminClient.rpc(
      "content_image_paths_in_use",
      { p_paths: paths }
    );
    if (referenceError) {
      return {
        cleanupWarning: "Материал сохранён, но безопасную проверку ссылок на удалённые изображения выполнить не удалось."
      };
    }

    const referencedPaths = new Set(
      ((referencedRows ?? []) as Array<{ path?: unknown }>)
        .map((row) => typeof row.path === "string" ? row.path : "")
        .filter(Boolean)
    );
    const removablePaths = paths.filter((path) => !referencedPaths.has(path));
    if (removablePaths.length === 0) return { cleanupWarning: null };

    const { error: storageError } = await adminClient.storage
      .from(CONTENT_IMAGES_BUCKET)
      .remove(removablePaths);
    return {
      cleanupWarning: storageError
        ? "Материал сохранён, но часть неиспользуемых изображений не удалось очистить из Supabase Storage."
        : null
    };
  } catch {
    return {
      cleanupWarning: "Материал сохранён, но серверная очистка не завершилась."
    };
  }
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
    author_id: authorId,
    publication_evidence: {},
    validation_passed: false,
    validation_errors: errors,
    published_at: null
  };
}

export async function createArticle(input: ArticleInput, cleanupCandidatePaths: unknown = []) {
  const { admin, supabase, user } = await getAuthorizedClient();
  if (!canEditArticle(admin.role, input.status)) {
    throw new Error("Редактор может создавать материалы только в статусах draft, review или qa.");
  }
  if (input.status === "published") {
    throw new Error("Прямая публикация запрещена. Используйте Human Review Queue.");
  }
  const categoryId = await resolveCategoryId(supabase, input.category);
  const { data, error } = await supabase
    .from("articles")
    .insert(articlePayload(input, categoryId, user.id))
    .select("id,updated_at")
    .single();

  if (error) throw new Error(error.code === "23505" ? "Материал с таким слагом уже существует." : error.message);
  const images = normalizeManagedContentImages(input.images);
  const { cleanupWarning } = await removeUnreferencedContentImages(
    normalizeCleanupCandidatePaths(cleanupCandidatePaths)
  );
  revalidatePath("/content");
  return {
    article: { ...input, images, id: data.id, updatedAt: data.updated_at } satisfies ManagedArticle,
    cleanupWarning
  };
}

export async function updateArticle(id: string, input: ArticleInput, cleanupCandidatePaths: unknown = []) {
  const { admin, supabase, user } = await getAuthorizedClient();
  const { data: current, error: readError } = await supabase
    .from("articles")
    .select("status,images,updated_at")
    .eq("id", id)
    .maybeSingle();
  if (readError) throw new Error(readError.message);
  if (!current) throw new Error("Материал не найден или уже изменён.");
  if (!canEditArticle(admin.role, String(current.status))) {
    throw new Error("Редактор не может изменять опубликованный материал. Верните его в review через Owner/Admin workflow.");
  }
  if (!canEditArticle(admin.role, String(current.status), input.status)) {
    throw new Error("Редактор может сохранять материалы только в статусах draft, review или qa.");
  }
  if (input.status === "published") {
    throw new Error("Изменение опубликованного материала требует перевода в review и новой Human Review Queue проверки.");
  }

  const categoryId = await resolveCategoryId(supabase, input.category);
  const nextImages = normalizeManagedContentImages(input.images);
  const { data, error } = await supabase
    .from("articles")
    .update(articlePayload(input, categoryId, user.id))
    .eq("id", id)
    .eq("status", current.status)
    .eq("updated_at", current.updated_at)
    .select("id,updated_at")
    .maybeSingle();

  if (error) throw new Error(error.code === "23505" ? "Материал с таким слагом уже существует." : error.message);
  if (!data) throw new Error("Материал был изменён другим пользователем. Обновите страницу и повторите попытку.");
  const nextPaths = new Set(nextImages.map((image) => image.path));
  const removedPaths = normalizeManagedContentImages(current.images)
    .map((image) => image.path)
    .filter((path) => !nextPaths.has(path));
  const { cleanupWarning } = await removeUnreferencedContentImages([
    ...removedPaths,
    ...normalizeCleanupCandidatePaths(cleanupCandidatePaths)
  ]);
  revalidatePath("/content");
  return {
    article: { ...input, images: nextImages, id: data.id, updatedAt: data.updated_at } satisfies ManagedArticle,
    cleanupWarning
  };
}

export async function deleteArticle(id: string) {
  const { admin, supabase } = await getAuthorizedClient();
  const { data: article, error: readError } = await supabase
    .from("articles")
    .select("status,images,updated_at")
    .eq("id", id)
    .maybeSingle();
  if (readError) throw new Error(readError.message);
  if (!article) throw new Error("Материал не найден или уже удалён.");
  if (!canEditArticle(admin.role, String(article.status))) {
    throw new Error("Редактор не может удалять опубликованный материал.");
  }

  const { data: deleted, error } = await supabase
    .from("articles")
    .delete()
    .eq("id", id)
    .eq("status", article.status)
    .eq("updated_at", article.updated_at)
    .select("id")
    .maybeSingle();
  if (error) throw new Error(error.message);
  if (!deleted) throw new Error("Материал был изменён другим пользователем. Обновите страницу и повторите попытку.");
  const paths = normalizeManagedContentImages(article?.images).map((image) => image.path);
  const { cleanupWarning } = await removeUnreferencedContentImages(paths);
  revalidatePath("/content");
  return { cleanupWarning };
}
