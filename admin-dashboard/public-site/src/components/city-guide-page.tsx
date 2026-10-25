import Link from "next/link";
import { ArrowRight, ExternalLink, MapPin, ShieldCheck } from "lucide-react";
import { ContentMedia, preferredMedia } from "@/components/content-media";
import { PageShell } from "@/components/page-shell";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
import { cityGuides, type CityGuide } from "@/content/city-guides";
import { getContentEntityById } from "@/lib/content";
import { serializeJsonLd } from "@/lib/seo/json-ld";

export function CityGuidePage({ guide, locale }: { guide: CityGuide; locale: "en" | "nl" }) {
  const nl = locale === "nl";
  const city = getContentEntityById(guide.cityEntityId);
  const image = city ? preferredMedia(city.images, ["hero", "gallery", "thumbnail"]) : null;
  const guideRoute = nl ? `/nl/stadsgidsen/${guide.slug}` : `/city-guides/${guide.slug}`;
  const searchRoute = nl ? "/nl/zoeken" : "/search";
  const categoriesRoute = nl ? "/nl/categorieen" : "/categories";
  const organizationRoute = nl ? "/nl/organisaties" : "/organizations";
  const structuredData = {
    "@context": "https://schema.org",
    "@type": "Article",
    headline: guide.title[locale],
    description: guide.description[locale],
    inLanguage: locale,
    dateModified: guide.verifiedAt,
    url: `https://younew.nl${guideRoute}/`,
    isBasedOn: guide.sourceUrl,
    image: image?.url
  };

  return (
    <PageShell locale={locale} className="city-guide-page">
      <section className="app-hero section-shell compact-hero content-index-hero">
        <nav className="breadcrumbs" aria-label={nl ? "Kruimelpad" : "Breadcrumb"}>
          <ol><li><Link href={nl ? "/nl/" : "/"}>{nl ? "Home" : "Home"}</Link></li><li><span aria-current="page">{guide.title[locale]}</span></li></ol>
        </nav>
        <p className="section-label cyan">{nl ? "Gecontroleerde stadsgids" : "Source-checked city guide"}</p>
        <h1>{guide.title[locale]}</h1>
        <p>{guide.description[locale]}</p>
        <div className="dataset-note"><ShieldCheck aria-hidden /><strong>{nl ? "Bron gecontroleerd" : "Source checked"}</strong> · {guide.verifiedAt} · {guide.municipalityName}</div>
      </section>

      <section className="section-shell content-index-showcase" aria-labelledby="registration-title">
        <article className="content-index-featured">
          {image ? <ContentMedia asset={image} variant="hero" eager /> : null}
          <div className="content-index-featured-copy">
            <span><MapPin aria-hidden /> {guide.municipalityName}</span>
            <h2 id="registration-title">{nl ? "1. Begin bij de gemeente" : "1. Start with the municipality"}</h2>
            <p>{guide.registration[locale]}</p>
            <div className="content-index-featured-actions">
              <TrackedOfficialSourceLink className="button button-primary" contentId={guide.cityEntityId} href={guide.sourceUrl} rel="noreferrer" target="_blank">{nl ? "Open de officiële bron" : "Open the official source"} <ExternalLink aria-hidden /></TrackedOfficialSourceLink>
              <Link className="button button-outline" href={`${searchRoute}?q=${encodeURIComponent(`${guide.slug} gemeente`)}`}>{nl ? "Zoek lokale informatie" : "Search local information"}</Link>
            </div>
          </div>
        </article>
      </section>

      <section className="business-section section-shell" aria-labelledby="city-prepare-title">
        <div className="section-intro"><p className="section-label cyan">{nl ? "Voor je begint" : "Before you start"}</p><h2 id="city-prepare-title">{nl ? `Bereid je gemeentelijke stap in ${city?.title ?? guide.slug} voor` : `Prepare your municipality step in ${city?.title ?? guide.slug}`}</h2><p>{nl ? "Deze checklist vat geen documentenlijst samen: de officiële gemeentepagina blijft leidend." : "This checklist does not copy a document list: the official municipality page remains authoritative."}</p></div>
        <ol className="business-steps">{guide.preparation.map((item, index) => <li key={item.en}><span>{index + 1}</span><div><p>{item[locale]}</p></div></li>)}</ol>
        <nav className="content-index-tools" aria-label={nl ? "Zoek lokaal per onderwerp" : "Search locally by topic"}>{guide.localSearches.map((item) => <Link href={`${searchRoute}?q=${encodeURIComponent(item.query[locale])}`} key={item.query.en}>{item.label[locale]} <ArrowRight aria-hidden /></Link>)}</nav>
      </section>

      <section className="business-section section-shell" aria-labelledby="city-next-steps">
        <div className="section-intro"><p className="section-label orange">{nl ? "Vaste basis" : "Reliable sequence"}</p><h2 id="city-next-steps">{nl ? "Daarna: drie landelijke stappen" : "Then: three national steps"}</h2><p>{nl ? "Controleer altijd de officiële pagina voordat je documenten aanlevert of een afspraak maakt." : "Always recheck the official page before providing documents or booking an appointment."}</p></div>
        <ol className="business-steps">
          <li><span>2</span><div><h3>{nl ? "Controleer je BSN en BRP" : "Check your BSN and BRP"}</h3><p>{nl ? "Inschrijving in de BRP leidt normaal tot een BSN. Welke procedure geldt, hangt af van je verblijfsduur en situatie." : "BRP registration normally creates a BSN. The applicable route depends on your stay and circumstances."}</p><Link href={`${searchRoute}?q=BSN BRP`}>{nl ? "Zoek BSN en BRP" : "Find BSN and BRP guidance"} <ArrowRight aria-hidden /></Link></div></li>
          <li><span>3</span><div><h3>{nl ? "Vraag DigiD aan" : "Apply for DigiD"}</h3><p>{nl ? "Voor de standaardaanvraag noemt DigiD een BSN, een gemeentelijk inschrijfadres en een mobiele telefoon." : "The standard DigiD application lists a BSN, municipal registration address and mobile phone as requirements."}</p><Link href={`${searchRoute}?q=DigiD`}>{nl ? "Zoek DigiD" : "Find DigiD guidance"} <ArrowRight aria-hidden /></Link></div></li>
          <li><span>4</span><div><h3>{nl ? "Regel zorgverzekering als dat voor jou geldt" : "Arrange health insurance when required"}</h3><p>{nl ? "Wie in Nederland woont of werkt, moet doorgaans een Nederlandse basisverzekering afsluiten. Controleer de officiële uitzonderingen." : "People who live or work in the Netherlands generally need Dutch basic health insurance. Check the official exceptions."}</p><Link href={`${searchRoute}?q=zorgverzekering`}>{nl ? "Zoek zorgverzekering" : "Find health insurance guidance"} <ArrowRight aria-hidden /></Link></div></li>
        </ol>
      </section>

      <section className="section-shell app-content-block category-index-grid" aria-labelledby="city-explore-title">
        <div className="listing-heading"><div><span>{nl ? "Praktisch verder" : "Continue locally"}</span><h2 id="city-explore-title">{nl ? `Vind betrouwbare adressen in ${city?.title ?? guide.slug}` : `Find useful places in ${city?.title ?? guide.slug}`}</h2></div></div>
        <Link href={`${categoriesRoute}/healthcare`}><div><span>{nl ? "Categorie" : "Category"}</span><h2>{nl ? "Zorg" : "Healthcare"}</h2><p>{nl ? "Bekijk gecontroleerde zorgorganisaties en landelijke uitleg." : "Browse reviewed healthcare organizations and national guidance."}</p></div><ArrowRight aria-hidden /></Link>
        <Link href={`${categoriesRoute}/transport`}><div><span>{nl ? "Categorie" : "Category"}</span><h2>{nl ? "Vervoer" : "Transport"}</h2><p>{nl ? "Vind stations, vervoersinformatie en officiële vertrekpunten." : "Find stations, transport information and official starting points."}</p></div><ArrowRight aria-hidden /></Link>
        <Link href={`${categoriesRoute}/food-drink`}><div><span>{nl ? "Categorie" : "Category"}</span><h2>{nl ? "Eten en drinken" : "Food and drink"}</h2><p>{nl ? "Bekijk lokale profielen met zichtbare bron en controledatum." : "Browse local profiles with visible sources and review dates."}</p></div><ArrowRight aria-hidden /></Link>
        <Link href={organizationRoute}><div><span>{nl ? "Overzicht" : "Directory"}</span><h2>{nl ? "Organisaties" : "Organizations"}</h2><p>{nl ? "Vergelijk gepubliceerde organisaties zonder betaalde voorkeursvolgorde." : "Compare published organizations without paid organic ranking."}</p></div><ArrowRight aria-hidden /></Link>
      </section>

      <section className="section-shell content-index-trust" aria-label={nl ? "Andere stadsgidsen" : "Other city guides"}>
        {cityGuides.filter((item) => item.slug !== guide.slug).map((item) => <Link href={nl ? `/nl/stadsgidsen/${item.slug}` : `/city-guides/${item.slug}`} key={item.slug}>{item.title[locale]} <ArrowRight aria-hidden /></Link>)}
      </section>
      <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: serializeJsonLd(structuredData) }} />
    </PageShell>
  );
}
