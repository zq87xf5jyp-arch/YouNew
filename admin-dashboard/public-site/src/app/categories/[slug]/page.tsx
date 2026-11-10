import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { ContentIndexPage } from "@/components/content-index-page";
import { LifeDomainGuide } from "@/components/life-domain-guide";
import { getCategory, getEntitiesForCategory, getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";
import { getLifeDomain } from "@/lib/search/taxonomy";

export const dynamicParams = false;
export function generateStaticParams() { return getPublicContent().categories.map(({ slug }) => ({ slug })); }
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const category = getCategory((await params).slug);
  if (!category) return {};
  return metadataForPage(`${category.title} information`, category.summary, category.route, {
    noIndex: category.entityCount === 0 && !getLifeDomain(category.slug),
    follow: true
  });
}
export default async function CategoryDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const category = getCategory((await params).slug); if (!category) notFound(); const entities = getEntitiesForCategory(category.slug); const domain = getLifeDomain(category.slug);
  return (
    <ContentIndexPage
      title={category.title}
      description={category.summary}
      entities={entities}
      datasetNote={domain
        ? <><strong>National starting route</strong> · local content is added only after source review{entities.length ? ` · ${entities.length} published related item${entities.length === 1 ? "" : "s"}` : ""}</>
        : entities.length
          ? <><strong>{entities.length}</strong> published items across {category.entityTypes.join(", ")} · source dates shown on detail pages</>
          : <><strong>0</strong> current profiles · stale records stay hidden until field-level review</>}
      context={domain ? <LifeDomainGuide domain={domain} /> : undefined}
    />
  );
}
