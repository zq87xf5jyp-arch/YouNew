import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { PageShell } from "@/components/page-shell";
import { NlEntityCard } from "@/components/nl-entity-card";
import { getCategory, getEntitiesForCategory, getPublicContent } from "@/lib/content";
import { dutchCategoryLabel } from "@/lib/i18n/nl";
import { metadataForPage } from "@/lib/seo/metadata";
import { getLifeDomain } from "@/lib/search/taxonomy";

export const dynamicParams = false;
export function generateStaticParams() { return getPublicContent().categories.map(({ slug }) => ({ slug })); }
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> {
  const category = getCategory((await params).slug);
  if (!category) return {};
  return metadataForPage(dutchCategoryLabel(category.slug), `Gepubliceerde en gecontroleerde informatie over ${dutchCategoryLabel(category.slug).toLocaleLowerCase("nl")}.`, `/nl/categorieen/${category.slug}`, {
    locale: "nl",
    noIndex: category.entityCount === 0 && !getLifeDomain(category.slug),
    follow: true
  });
}
export default async function Page({ params }: { params: Promise<{ slug: string }> }) { const category = getCategory((await params).slug); if (!category) notFound(); const entities = getEntitiesForCategory(category.slug); return <PageShell locale="nl"><section className="app-hero section-shell compact-hero"><p><Link href="/nl/categorieen/">Categorieën</Link></p><h1>{dutchCategoryLabel(category.slug)}</h1><p>{entities.length} gepubliceerde items. YouNew toont alleen gecontroleerde brongegevens; actuele voorwaarden controleer je altijd bij de verantwoordelijke organisatie.</p></section><section className="section-shell app-content-block"><div className="entity-grid">{entities.map((entity) => <NlEntityCard entity={entity} key={entity.id} />)}</div>{entities.length === 0 ? <div className="empty-state"><h2>Nog geen lokale profielen gepubliceerd</h2><p>We vullen deze pagina niet met onbevestigde informatie. Gebruik de zoekfunctie voor landelijke uitleg of bekijk een andere categorie.</p></div> : null}<nav className="content-index-tools" aria-label="Verder zoeken"><Link className="button button-outline" href={`/nl/zoeken/?q=${encodeURIComponent(dutchCategoryLabel(category.slug))}`}>Zoek dit onderwerp</Link><Link className="text-link" href="/nl/organisaties/">Bekijk organisaties</Link><Link className="text-link" href="/nl/stadsgidsen/amsterdam/">Bekijk stadsgidsen</Link></nav></section></PageShell>; }
