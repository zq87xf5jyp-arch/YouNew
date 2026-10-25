import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { ExternalLink, Flag, MapPin, ShieldCheck } from "lucide-react";
import { ContentMedia, preferredMedia } from "@/components/content-media";
import { NlEntityCard } from "@/components/nl-entity-card";
import { PageShell } from "@/components/page-shell";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
import { getContentEntity, getStaticEntityParams } from "@/lib/content";
import { relatedForEntity } from "@/lib/content/page-helpers";
import { dutchCategoryLabel, dutchEntityDescription } from "@/lib/i18n/nl";
import { metadataForPage } from "@/lib/seo/metadata";

export const dynamicParams = false;
export function generateStaticParams() {
  const params = getStaticEntityParams("organization");
  // Keep static export valid when the freshness gate intentionally publishes
  // no organization profiles. This sentinel resolves through notFound() and
  // therefore never creates a public, indexable placeholder profile.
  return params.length ? params : [{ slug: "__no-published-organizations__" }];
}
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> { const entity = getContentEntity("organization", (await params).slug); return entity ? metadataForPage(`${entity.title} — organisatieprofiel`, dutchEntityDescription(entity), `/nl/organisaties/${entity.slug}`, { locale: "nl" }) : {}; }
export default async function Page({ params }: { params: Promise<{ slug: string }> }) { const entity = getContentEntity("organization", (await params).slug); if (!entity) notFound(); const image = preferredMedia(entity.images, ["hero", "gallery", "thumbnail"]); const related = relatedForEntity(entity).filter((item) => item.type === "organization").slice(0, 3); const reportSubject = encodeURIComponent(`Verouderde informatie: ${entity.title} (${entity.id})`); return <PageShell locale="nl"><section className="entity-detail-hero section-shell"><p><Link href="/nl/organisaties/">Organisaties</Link></p><div className="entity-detail-heading"><div><span className="entity-kind">Organisatie</span><h1>{entity.title}</h1><p>{dutchEntityDescription(entity)}</p></div></div>{entity.cityId ? <p className="detail-location"><MapPin aria-hidden /> {entity.cityId.replaceAll("-", " ")}</p> : null}{image ? <ContentMedia asset={image} variant="hero" eager /> : null}</section><div className="section-shell entity-detail-layout"><article className="entity-main-copy"><h2>Wat is gecontroleerd?</h2><p>Dit profiel toont alleen de gepubliceerde organisatie-identiteit, locatie, categorie en verantwoordelijke bron uit de YouNew-dataset. Diensten, openingstijden en beschikbaarheid kunnen veranderen.</p><dl className="content-facts"><div><dt>Categorie</dt><dd>{entity.categorySlugs.map(dutchCategoryLabel).join(", ")}</dd></div>{entity.cityId ? <div><dt>Stad</dt><dd>{entity.cityId.replaceAll("-", " ")}</dd></div> : null}<div><dt>Bron gecontroleerd</dt><dd>{entity.verifiedAt}</dd></div></dl><h2>Wat kun je nu doen?</h2><ol className="next-steps"><li><span>1</span><div><strong>Open de officiële bron</strong><p>Controleer actuele diensten, voorwaarden en contactmogelijkheden.</p></div></li><li><span>2</span><div><strong>Vergelijk de locatie</strong><p>Controleer of deze organisatie jouw woonplaats of situatie bedient.</p></div></li><li><span>3</span><div><strong>Meld een fout</strong><p>Geef verouderde informatie door zodat die opnieuw kan worden beoordeeld.</p></div></li></ol></article><aside className="source-card"><ShieldCheck aria-hidden /><p className="source-label">Verantwoordelijke bron</p><h2>{entity.source.publisher}</h2><p>{entity.source.title}</p><TrackedOfficialSourceLink className="button button-primary" contentId={entity.id} href={entity.source.url} rel="noreferrer" target="_blank">Open bron <ExternalLink aria-hidden /></TrackedOfficialSourceLink><a className="report-link" href={`mailto:support@younew.nl?subject=${reportSubject}`}><Flag aria-hidden /> Meld verouderde informatie</a></aside></div>{related.length ? <section className="section-shell related-section"><div className="listing-heading"><div><span>Verder kijken</span><h2>Vergelijkbare organisaties</h2></div></div><div className="entity-grid compact-grid">{related.map((item) => <NlEntityCard entity={item} key={item.id} />)}</div></section> : null}</PageShell>; }
