import type { Metadata } from "next";
import Link from "next/link";
import { ArrowRight, BriefcaseBusiness, Building2, FileText, HeartPulse, Home, MapPinned, Search, ShieldCheck } from "lucide-react";
import { ContentMedia } from "@/components/content-media";
import { PageShell } from "@/components/page-shell";
import { NlEntityCard } from "@/components/nl-entity-card";
import { cityGuides } from "@/content/city-guides";
import { getContentEntities, getPublicContent, type PublicMediaAsset } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata: Metadata = metadataForPage(
  "YouNew — Wegwijs in Nederland",
  "Vind betrouwbare informatie over wonen, werk, documenten, zorg en lokale organisaties in Nederland.",
  "/nl",
  { locale: "nl" }
);

const tasks = [
  ["Wonen", "Huur, rechten en praktische stappen", "/nl/categorieen/housing", Home],
  ["Werk", "Vind landelijke en lokale informatie", "/nl/zoeken/?q=werk", BriefcaseBusiness],
  ["Zorg", "Huisarts, verzekering en zorgorganisaties", "/nl/categorieen/healthcare", HeartPulse],
  ["Documenten", "BSN, BRP, DigiD en verblijf", "/nl/zoeken/?q=BSN BRP DigiD", FileText],
  ["Organisaties", "Gecontroleerde lokale profielen", "/nl/organisaties", Building2],
  ["Zoeken", "Zoek zonder extern zoekprofiel", "/nl/zoeken", Search]
] as const;

const homeHeroMedia: PublicMediaAsset = {
  id: "homepage.amsterdam-damrak",
  role: "hero",
  url: "/images/app-amsterdam-evening-background.webp",
  alt: "Grachtenpanden aan het Damrak in Amsterdam tijdens het blauwe uur",
  attribution: "Basile Morin",
  license: "CC BY-SA 4.0",
  licenseUrl: "https://creativecommons.org/licenses/by-sa/4.0/",
  sourcePageUrl: "https://commons.wikimedia.org/wiki/File:Water_reflection_of_canal_houses_at_blue_hour_in_Damrak_Amsterdam_the_Netherlands.jpg",
  retrievedAt: "2026-07-14"
};

export default function DutchHomePage() {
  const content = getPublicContent();
  const featured = getContentEntities("organization").slice(0, 3);
  return (
    <PageShell locale="nl" className="product-vision-home">
      <section className="vision-hero" aria-labelledby="nl-home-title">
        <div className="section-shell vision-hero-grid">
          <div className="vision-hero-copy">
            <p className="section-label cyan">Nieuw in Nederland</p>
            <h1 id="nl-home-title">Praktische informatie. Zichtbare bronnen. Een duidelijke volgende stap.</h1>
            <p>Vind informatie over wonen, werk, documenten, zorg en lokale organisaties. YouNew toont waar informatie vandaan komt en wanneer die voor het laatst is gecontroleerd.</p>
            <div className="vision-search-assistant"><form action="/nl/zoeken/" role="search"><label htmlFor="nl-home-search">Waar ben je naar op zoek?</label><div><input id="nl-home-search" name="q" placeholder="Bijvoorbeeld: BSN, huisarts of woning" /><button type="submit" aria-label="Zoeken op YouNew"><Search aria-hidden /><span className="visually-hidden">Zoeken</span></button></div></form></div>
            <div className="vision-hero-actions"><Link className="vision-primary-action" href="/nl/zoeken/">Begin met zoeken <ArrowRight aria-hidden /></Link><Link className="vision-secondary-action" href="/nl/categorieen/">Bekijk categorieën <ArrowRight aria-hidden /></Link></div>
          </div>
          <div className="vision-hero-media"><ContentMedia asset={homeHeroMedia} variant="hero" eager /></div>
        </div>
      </section>

      <section className="vision-section vision-needs section-shell" aria-labelledby="nl-needs-title">
        <div className="vision-heading"><h2 id="nl-needs-title">Wat wil je regelen?</h2><p>Kies een onderwerp en ga direct naar gecontroleerde informatie.</p></div>
        <div className="vision-task-grid">{tasks.map(([title, text, href, Icon]) => <Link className="vision-task" href={href} key={title}><Icon aria-hidden /><span><strong>{title}</strong><small>{text}</small></span><ArrowRight aria-hidden /></Link>)}</div>
      </section>

      <section className="business-section section-shell" aria-labelledby="nl-city-guides-title">
        <div className="section-intro"><p className="section-label orange">Lokale start</p><h2 id="nl-city-guides-title">Vijf gecontroleerde stadsgidsen</h2><p>Elke gids begint bij de officiële gemeentelijke route en linkt door naar relevante categorieën en profielen.</p></div>
        <div className="category-index-grid">{cityGuides.map((guide) => <Link href={`/nl/stadsgidsen/${guide.slug}`} key={guide.slug}><MapPinned aria-hidden /><div><span>Bron gecontroleerd {guide.verifiedAt}</span><h2>{guide.title.nl}</h2><p>{guide.description.nl}</p></div><ArrowRight aria-hidden /></Link>)}</div>
      </section>

      <section className="section-shell app-content-block content-index-listing" aria-labelledby="nl-organizations-title">
        <div className="listing-heading"><div><span>{content.organizations.length} gepubliceerde organisaties</span><h2 id="nl-organizations-title">Lokale organisaties met bronvermelding</h2><p>De organisatienaam blijft ongewijzigd; labels, context en vervolgstappen zijn in het Nederlands.</p></div><Link href="/nl/organisaties/">Bekijk alle organisaties <ArrowRight aria-hidden /></Link></div>
        <div className="entity-grid compact-grid">{featured.map((entity) => <NlEntityCard entity={entity} key={entity.id} />)}</div>
      </section>

      <section className="section-shell content-index-trust" aria-label="Waarom YouNew"><div><ShieldCheck aria-hidden /><span><strong>Geen verzonnen informatie</strong><small>Onbevestigde gegevens krijgen geen gecontroleerd label.</small></span></div><Link href="/status/">Bekijk de inhoudsstatus <ArrowRight aria-hidden /></Link><Link href="/nl/voor-bedrijven/">Voor bedrijven <ArrowRight aria-hidden /></Link></section>
    </PageShell>
  );
}
