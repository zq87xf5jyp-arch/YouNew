import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { EntityListing } from "@/components/entity-listing";
import { PageShell } from "@/components/page-shell";
import { getEntitiesForProvince, getProvince, getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const dynamicParams = false;
export function generateStaticParams() { return getPublicContent().provinces.map(({ slug }) => ({ slug })); }
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> { const province = getProvince((await params).slug); return province ? metadataForPage(`${province.title} province`, province.summary, province.route) : {}; }
export default async function ProvinceDetailPage({ params }: { params: Promise<{ slug: string }> }) { const province = getProvince((await params).slug); if (!province) notFound(); const entities = getEntitiesForProvince(province.slug); return <PageShell><section className="app-hero section-shell compact-hero"><Breadcrumbs items={[{ label: "Provinces", href: "/provinces" }, { label: province.title }]} /><h1>{province.title}</h1><p>{province.summary} Coverage is limited to content already approved in the shared production release.</p><div className="dataset-note"><strong>{province.cityIds.length}</strong> published cities · <strong>{entities.length}</strong> linked records</div></section><section className="section-shell app-content-block"><EntityListing entities={entities} viewAllHref={`/search?province=${province.slug}`} /></section></PageShell>; }
