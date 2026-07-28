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
        .select("id,title,slug,short_description,full_content,language,status,priority,source_url,tags,images,updated_at,categories(slug)")
        .order("updated_at", { ascending: false })
        .limit(100)
    : { data: null };
  const rows = data ?? sampleArticles;
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
    updatedAt: String((row as { updated_at?: unknown }).updated_at ?? "")
  }));
  return (
    <>
      <PageHeader title="Управление контентом" description="Создавайте и проверяйте статьи, транспортные гайды, справочные материалы, FAQ, экстренные контакты и источники знаний для AI." />
      <ContentManager initialRows={initialRows} supabaseEnabled={Boolean(supabase)} canEdit={canEditContent(admin.role)} />
    </>
  );
}
