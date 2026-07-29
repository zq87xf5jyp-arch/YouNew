import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowRight, ExternalLink, Mail, MapPinned, Phone, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { EntityListing } from "@/components/entity-listing";
import { PageShell } from "@/components/page-shell";
import { ProvinceShape } from "@/components/province-shape";
import { getEntitiesForProvince } from "@/lib/content";
import {
  getGeographyProvince,
  getGeographyProvinces,
  getMunicipalitiesForProvince
} from "@/lib/geography";
import { metadataForPage } from "@/lib/seo/metadata";

export const dynamicParams = false;
export function generateStaticParams() {
  return getGeographyProvinces().map(({ slug }) => ({ slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const province = getGeographyProvince((await params).slug);
  return province
    ? metadataForPage(
      `${province.name} province`,
      `${province.name} contains ${province.municipalityCount} municipalities and ${province.settlementCount} official settlements in the 2026 Dutch administrative directory.`,
      province.route
    )
    : {};
}

export default async function ProvinceDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const province = getGeographyProvince((await params).slug);
  if (!province) notFound();
  const municipalities = getMunicipalitiesForProvince(province.slug);
  const entities = getEntitiesForProvince(province.slug);
  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero province-detail-hero">
        <Breadcrumbs items={[{ label: "Provinces", href: "/provinces" }, { label: province.name }]} />
        <div className="province-detail-hero-grid">
          <div>
            <h1>{province.name}</h1>
            <p>Official province overview with all municipalities and BAG settlements assigned on 1 January 2026. Published YouNew material remains separately labelled.</p>
            <div className="dataset-note"><strong>{province.municipalityCount}</strong> municipalities · <strong>{province.settlementCount}</strong> settlements · <strong>{entities.length}</strong> published YouNew records</div>
          </div>
          <ProvinceShape slug={province.slug} label={province.name} />
        </div>
      </section>

      <div className="section-shell province-detail-layout">
        <section className="province-municipality-section" aria-labelledby="province-municipalities-title">
          <div className="listing-heading">
            <div><span>Complete 2026 directory</span><h2 id="province-municipalities-title">Municipalities in {province.name}</h2><p>Open a municipality for its official contact channels and complete settlement list.</p></div>
            <Link href={`/municipalities?province=${province.slug}`}>All municipalities <ArrowRight aria-hidden /></Link>
          </div>
          <ol className="province-municipality-list">
            {municipalities.map((municipality) => (
              <li key={municipality.code}>
                <Link href={`/municipalities/${municipality.slug}`}>
                  <span>{municipality.code}</span>
                  <strong>{municipality.name}</strong>
                  <small>{municipality.settlements.length} settlement{municipality.settlements.length === 1 ? "" : "s"}</small>
                  <ArrowRight aria-hidden />
                </Link>
              </li>
            ))}
          </ol>
        </section>

        <aside className="province-contact-card">
          <ShieldCheck aria-hidden />
          <p className="source-label">Responsible provincial authority</p>
          <h2>Province of {province.name}</h2>
          {province.administrativeSeat ? <p>Provincial office locality: {province.administrativeSeat}</p> : null}
          <div>
            {province.officialWebsite ? <a className="button button-primary" href={province.officialWebsite} rel="noreferrer" target="_blank">Official website <ExternalLink aria-hidden /></a> : null}
            {province.phone ? <a href={`tel:${province.phone.replace(/[^\d+]/g, "")}`}><Phone aria-hidden /> {province.phone}</a> : null}
            {province.email ? <a href={`mailto:${province.email}`}><Mail aria-hidden /> {province.email}</a> : null}
          </div>
          <p>Contact record checked {province.sourceCheckedAt ?? "in the official register"}.</p>
          <Link className="text-link" href={`/map?province=${province.slug}`}><MapPinned aria-hidden /> View on map</Link>
        </aside>
      </div>

      {entities.length ? (
        <section className="section-shell province-published-section" aria-labelledby="province-published-title">
          <div className="listing-heading"><div><span>Editorial coverage</span><h2 id="province-published-title">Published YouNew material in {province.name}</h2><p>These records come from the governed YouNew content release.</p></div></div>
          <EntityListing entities={entities} variant="editorial" viewAllHref={`/search?province=${province.slug}`} />
        </section>
      ) : (
        <section className="section-shell municipality-coverage-gap">
          <div><span>Editorial status</span><h2>No local YouNew records are published for {province.name} yet.</h2><p>The complete administrative directory is available now; local guides and organizations require a separate source review.</p></div>
          <Link className="button button-outline" href="/support">Suggest a source</Link>
        </section>
      )}
    </PageShell>
  );
}
