"use server";

import { revalidatePath } from "next/cache";
import { createSupabaseServerClient } from "@/lib/supabase/server";
import { requireContentEditor } from "@/lib/auth";
import type { ManagedArticle } from "@/components/admin/content-manager";
import { CONTENT_IMAGES_BUCKET, normalizeManagedContentImages } from "@/lib/content-images";

type ArticleInput = Omit<ManagedArticle, "id" | "updatedAt">;

async function getAuthorizedClient() {
  await requireContentEditor();
  const supabase = await createSupabaseServerClient();
  if (!supabase) throw new Error("Supabase не настроен.");

  const { data: { user }, error } = await supabase.auth.getUser();
  if (error || !user) throw new Error("Войдите в аккаунт администратора.");
  return { supabase, user };
}

async function resolveCategoryId(
  supabase: NonNullable<Awaited<ReturnType<typeof createSupabaseServerClient>>>,
  slug: string
) {
  const { data, error } = await supabase.from("categories").select("id").eq("slug", slug).maybeSingle();
  if (error) throw new Error(error.message);
  return data?.id ?? null;
}

function articlePayload(input: ArticleInput, categoryId: string | null, authorId: string) {
  return {
    title: input.title.trim(),
    slug: input.slug.trim(),
    category_id: categoryId,
    language: input.language.trim(),
    status: input.status,
    priority: input.priority,
    short_description: input.description?.trim() || null,
    full_content: input.content?.trim() || null,
    source_url: input.source?.trim() || null,
    tags: input.tags?.split(",").map((tag) => tag.trim()).filter(Boolean) ?? [],
    images: normalizeManagedContentImages(input.images),
    author_id: authorId,
    published_at: input.status === "published" ? new Date().toISOString() : null
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
