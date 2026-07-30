import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ArrowRight, Building2, CalendarCheck, ExternalLink, Mail, MapPinned, Phone, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { EntityListing } from "@/components/entity-listing";
import { PageShell } from "@/components/page-shell";
import { getContentEntities } from "@/lib/content";
import { getMunicipalities, getMunicipality } from "@/lib/geography";
import { serializeJsonLd } from "@/lib/seo/json-ld";
import { metadataForPage } from "@/lib/seo/metadata";

export const dynamicParams = false;
export function generateStaticParams() {
  return getMunicipalities().map(({ slug }) => ({ slug }));
}

export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const municipality = getMunicipality((await params).slug);
  if (!municipality) return {};
  return metadataForPage(
    `${municipality.name} municipality`,
    `Official 2026 municipality directory entry for ${municipality.name} in ${municipality.provinceName}, with settlements and responsible government links.`,
    `/municipalities/${municipality.slug}`
  );
}

export default async function MunicipalityDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const municipality = getMunicipality((await params).slug);
  if (!municipality) notFound();
  const related = getContentEntities().filter((entity) => (
    entity.cityId === municipality.slug
    || (entity.type === "city" && entity.slug === municipality.slug)
  ));
  const population = municipality.population
    ? new Intl.NumberFormat("en-NL").format(municipality.population)
    : null;
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "AdministrativeArea",
    name: municipality.name,
    identifier: municipality.code,
    containedInPlace: {
      "@type": "AdministrativeArea",
      name: municipality.provinceName
    },
    url: `https://younew.nl/municipalities/${municipality.slug}/`,
    sameAs: municipality.officialWebsite ?? undefined
  };

  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero municipality-detail-hero">
        <Breadcrumbs items={[{ label: "Municipalities", href: "/municipalities" }, { label: municipality.name }]} />
        <Building2 className="hero-line-icon" aria-hidden />
        <h1>{municipality.name}</h1>
        <p>Official municipality directory entry in {municipality.provinceName}. This page separates administrative facts from YouNew’s editorial city coverage.</p>
        <div className="dataset-note">
          <strong>{municipality.code}</strong> · <strong>{municipality.settlements.length}</strong> official settlement{municipality.settlements.length === 1 ? "" : "s"}{population ? <> · <strong>{population}</strong> residents in the current ROO record</> : null}
        </div>
      </section>

      <div className="section-shell municipality-detail-layout">
        <article className="municipality-detail-main">
          <section aria-labelledby="municipality-facts-title">
            <h2 id="municipality-facts-title">Municipality facts</h2>
            <dl className="municipality-facts">
              <div><dt>Province</dt><dd><Link href={`/provinces/${municipality.provinceSlug}`}>{municipality.provinceName}</Link></dd></div>
              <div><dt>Administrative code</dt><dd>{municipality.code}</dd></div>
              {municipality.administrativeSeat ? <div><dt>Municipal office locality</dt><dd>{municipality.administrativeSeat}</dd></div> : null}
              {population ? <div><dt>Population in source record</dt><dd>{population}</dd></div> : null}
              <div><dt>Reference date</dt><dd>Municipal division on 1 January 2026</dd></div>
              <div><dt>Contact data checked</dt><dd>{municipality.sourceCheckedAt ?? "See official register"}</dd></div>
            </dl>
          </section>

          <section className="municipality-settlements" aria-labelledby="municipality-settlements-title">
            <div className="listing-heading">
              <div><span>CBS BAG 2026</span><h2 id="municipality-settlements-title">Official settlements in {municipality.name}</h2><p>These are official BAG woonplaats names, not a ranking of cities, neighbourhoods or tourist destinations.</p></div>
            </div>
            {municipality.settlements.length ? (
              <ul>{municipality.settlements.map((settlement) => <li key={settlement.code}><span>{settlement.code}</span><strong>{settlement.name}</strong></li>)}</ul>
            ) : <p>No BAG settlement was linked to this municipality in the imported 2026 table.</p>}
          </section>

          <div className="detail-map-callout">
            <MapPinned aria-hidden />
            <div><strong>Locate {municipality.name} on the coverage map</strong><p>The municipality marker uses public government coordinates and never requests your location.</p></div>
            <Link href={`/map?type=municipality&q=${encodeURIComponent(municipality.name).replaceAll("'", "%27")}`}>Open map <ArrowRight aria-hidden /></Link>
          </div>
        </article>

        <aside className="municipality-contact-card">
          <ShieldCheck aria-hidden />
          <p className="source-label">Responsible public organization</p>
          <h2>Municipality of {municipality.name}</h2>
          <p>Use the official municipal channel for current appointments, documents, local taxes and procedures.</p>
          <div className="municipality-contact-links">
            {municipality.officialWebsite ? <a className="button button-primary" href={municipality.officialWebsite} rel="noreferrer" target="_blank">Official website <ExternalLink aria-hidden /></a> : null}
            {municipality.appointmentUrl ? <a href={municipality.appointmentUrl} rel="noreferrer" target="_blank"><CalendarCheck aria-hidden /> Appointments</a> : null}
            {municipality.phone ? <a href={`tel:${municipality.phone.replace(/[^\d+]/g, "")}`}><Phone aria-hidden /> {municipality.phone}</a> : null}
            {municipality.email ? <a href={`mailto:${municipality.email}`}><Mail aria-hidden /> {municipality.email}</a> : null}
          </div>
          <p className="municipality-source-note">Contact details: Register of Government Organisations. Boundaries: Kadaster/PDOK. Settlement structure: CBS.</p>
        </aside>
      </div>

      {related.length ? (
        <section className="section-shell municipality-published-coverage" aria-labelledby="municipality-published-title">
          <div className="listing-heading"><div><span>Editorial coverage</span><h2 id="municipality-published-title">Published YouNew material for {municipality.name}</h2><p>These records passed the separate YouNew publication process.</p></div></div>
          <EntityListing entities={related} variant="editorial" viewAllHref={`/search?city=${municipality.slug}`} />
        </section>
      ) : (
        <section className="section-shell municipality-coverage-gap" aria-labelledby="municipality-gap-title">
          <div><span>Editorial status</span><h2 id="municipality-gap-title">A full YouNew city guide is not published yet.</h2><p>The official municipality entry is available now. Practical guides, places and local organizations will appear only after source review.</p></div>
          <Link className="button button-outline" href="/support">Suggest a local source</Link>
        </section>
      )}
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: serializeJsonLd(structuredData) }} />
    </PageShell>
  );
}
