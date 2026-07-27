import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowRight } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { EntityListing } from "@/components/entity-listing";
import { PageShell } from "@/components/page-shell";
import { getEntitiesForProvince, getProvince, getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const dynamicParams = false;
export function generateStaticParams() { return getPublicContent().provinces.map(({ slug }) => ({ slug })); }
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> { const province = getProvince((await params).slug); return province ? metadataForPage(`${province.title} province`, province.summary, province.route) : {}; }
export default async function ProvinceDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const province = getProvince((await params).slug);
  if (!province) notFound();
  const entities = getEntitiesForProvince(province.slug);
  const counts = {
    cities: entities.filter((entity) => entity.type === "city").length,
    guides: entities.filter((entity) => entity.type === "guide").length,
    organizations: entities.filter((entity) => entity.type === "organization").length,
    places: entities.filter((entity) => entity.type === "place").length
  };
  const categories = getPublicContent().categories.filter((category) => province.categorySlugs.includes(category.slug));
  const cities = getPublicContent().cities.filter((city) => city.cityId !== null && province.cityIds.includes(city.cityId));

  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero">
        <Breadcrumbs items={[{ label: "Provinces", href: "/provinces" }, { label: province.title }]} />
        <h1>{province.title}</h1>
        <p>{province.summary} This page groups only records already approved in the shared production release.</p>
        <div className="dataset-note"><strong>{province.cityIds.length}</strong> published {province.cityIds.length === 1 ? "city" : "cities"} · <strong>{entities.length}</strong> linked records · <strong>{categories.length}</strong> categories</div>
      </section>
      <section className="section-shell province-coverage-summary" aria-labelledby="coverage-summary-title">
        <div className="listing-heading"><div><span>Current dataset</span><h2 id="coverage-summary-title">Coverage snapshot</h2></div></div>
        <dl className="coverage-stat-grid">
          <div><dt>Cities</dt><dd>{counts.cities}</dd></div>
          <div><dt>Guides</dt><dd>{counts.guides}</dd></div>
          <div><dt>Organizations</dt><dd>{counts.organizations}</dd></div>
          <div><dt>Places</dt><dd>{counts.places}</dd></div>
        </dl>
        <div className="province-link-groups">
          <div><h3>Published cities</h3><div className="topic-links">{cities.map((city) => <Link href={city.route} key={city.id}>{city.title}</Link>)}</div></div>
          <div><h3>Available categories</h3><div className="topic-links">{categories.map((category) => <Link href={category.route} key={category.id}>{category.title}</Link>)}</div></div>
        </div>
        <Link className="text-link" href={`/search?province=${province.slug}`}>Search all {province.title} records <ArrowRight aria-hidden /></Link>
      </section>
      <section className="section-shell app-content-block"><EntityListing entities={entities} viewAllHref={`/search?province=${province.slug}`} /></section>
    </PageShell>
  );
}
