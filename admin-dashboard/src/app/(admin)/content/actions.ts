"use server";

import { revalidatePath } from "next/cache";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { requireAdmin } from "@/lib/auth";
import { canEditContent, canPublishContent } from "@/lib/authorization";
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

function publicationErrors(input: ArticleInput, categoryId: string | null) {
  const errors: string[] = [];
  if (!input.title.trim()) errors.push("title");
  if (!input.description?.trim()) errors.push("short_description");
  if (!input.content?.trim()) errors.push("full_content");
  if (!categoryId) errors.push("public_category");
  if (!input.source?.trim().startsWith("https://")) errors.push("official_source");
  if (!input.verifiedDate) errors.push("verified_date");
  if (input.verifiedDate && input.verifiedDate > new Date().toISOString().slice(0, 10)) errors.push("verified_date_future");
  if (!input.reviewConfirmed) errors.push("reviewer");
  if (input.requiresMedia && input.images.length === 0) errors.push("required_media");
  return errors;
}

function articlePayload(input: ArticleInput, categoryId: string | null, authorId: string) {
  const publishing = input.status === "published";
  const validatedAt = new Date().toISOString();
  const errors = publicationErrors(input, categoryId);
  if (publishing && errors.length > 0) {
    throw new Error(`Публикация заблокирована: ${errors.join(", ")}.`);
  }
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
    images: normalizeManagedContentImages(input.images),
    verified_date: input.verifiedDate || null,
    reviewer_id: input.reviewConfirmed ? authorId : null,
    reviewed_at: input.reviewConfirmed ? validatedAt : null,
    requires_media: input.requiresMedia,
    source_mapping: source ? [{ url: source, type: "official" }] : [],
    publication_evidence: publishing ? {
      validation_status: "passed",
      validated_at: validatedAt,
      validator_id: authorId
    } : {},
    validation_passed: publishing,
    validation_errors: publishing ? [] : errors,
    author_id: authorId,
    published_at: input.status === "published" ? new Date().toISOString() : null
  };
}

export async function createArticle(input: ArticleInput) {
  const { admin, supabase, user } = await getAuthorizedClient();
  if (input.status === "published" && !canPublishContent(admin.role)) {
    throw new Error("Публикация доступна только владельцу или администратору.");
  }
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
  const { admin, supabase, user } = await getAuthorizedClient();
  if (input.status === "published" && !canPublishContent(admin.role)) {
    throw new Error("Публикация доступна только владельцу или администратору.");
  }
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
