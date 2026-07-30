import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { ContentIndexPage } from "@/components/content-index-page";
import { getCategory, getEntitiesForCategory, getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const dynamicParams = false;
export function generateStaticParams() { return getPublicContent().categories.map(({ slug }) => ({ slug })); }
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> { const category = getCategory((await params).slug); return category ? metadataForPage(`${category.title} information`, category.summary, category.route) : {}; }
export default async function CategoryDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const category = getCategory((await params).slug); if (!category) notFound(); const entities = getEntitiesForCategory(category.slug);
  return (
    <ContentIndexPage
      title={category.title}
      description={category.summary}
      entities={entities}
      datasetNote={<><strong>{entities.length}</strong> published items across {category.entityTypes.join(", ")} · source dates shown on detail pages</>}
    />
  );
}
