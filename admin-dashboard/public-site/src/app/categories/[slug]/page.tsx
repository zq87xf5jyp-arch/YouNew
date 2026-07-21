import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { EntityListing } from "@/components/entity-listing";
import { PageShell } from "@/components/page-shell";
import { getCategory, getEntitiesForCategory, getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const dynamicParams = false;
export function generateStaticParams() { return getPublicContent().categories.map(({ slug }) => ({ slug })); }
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> { const category = getCategory((await params).slug); return category ? metadataForPage(`${category.title} information`, category.summary, category.route) : {}; }
export default async function CategoryDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const category = getCategory((await params).slug); if (!category) notFound(); const entities = getEntitiesForCategory(category.slug);
  return <PageShell><section className="app-hero section-shell compact-hero"><Breadcrumbs items={[{ label: "Categories", href: "/categories" }, { label: category.title }]} /><h1>{category.title}</h1><p>{category.summary}</p><div className="dataset-note"><strong>{entities.length}</strong> released items across {category.entityTypes.join(", ")}</div></section><section className="section-shell app-content-block"><EntityListing entities={entities} viewAllHref={`/search?category=${category.slug}`} /></section></PageShell>;
}
