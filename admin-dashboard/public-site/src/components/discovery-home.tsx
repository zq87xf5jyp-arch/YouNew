import Link from "next/link";
import { ArrowRight, BookOpen, Building2, Compass, Landmark, MapPin, ShieldCheck, Trees, UtensilsCrossed } from "lucide-react";
import { ContentMedia } from "@/components/content-media";
import { HomeSearchForm } from "@/components/home-search-form";
import { PageShell } from "@/components/page-shell";
import { cityGuides } from "@/content/city-guides";
import discoveryMedia from "@/content/discovery-media.json";
import { getContentEntityById, type PublicMediaAsset } from "@/lib/content";

export const discoveryHero = discoveryMedia.rotterdam as PublicMediaAsset;

const cityNotes = {
  amsterdam: { en: "Canals, culture & a new beginning", nl: "Grachten, cultuur & een nieuw begin" },
  rotterdam: { en: "A fresh perspective on city life", nl: "Een frisse blik op het stadsleven" },
  "den-haag": { en: "City life, with the coast nearby", nl: "Stadsleven, met de kust dichtbij" },
  utrecht: { en: "Find your way around the centre", nl: "Vind je weg door het centrum" },
  eindhoven: { en: "A city to make your own", nl: "Een stad om je thuis te voelen" }
};

export function DiscoveryHome({ locale }: { locale: "en" | "nl" }) {
  const nl = locale === "nl";
  const search = nl ? "/nl/zoeken/" : "/search/";
  const categoryBase = nl ? "/nl/categorieen/" : "/categories/";
  const categories = [
    { icon: Compass, label: nl ? "Plekken & cultuur" : "Places & culture", text: nl ? "Ontdek de stad om je heen" : "Get to know the city around you", href: `${categoryBase}culture/` },
    { icon: UtensilsCrossed, label: nl ? "Eten & drinken" : "Food & drink", text: nl ? "Lokale informatie en bronnen" : "Local information and sources", href: `${categoryBase}food-drink/` },
    { icon: Trees, label: nl ? "Buiten & activiteiten" : "Outdoors & activities", text: nl ? "Maak ruimte om te ontdekken" : "Make time to explore", href: `${categoryBase}outdoors/` },
    { icon: Building2, label: nl ? "Lokale diensten" : "Local services", text: nl ? "Vind een bruikbaar vertrekpunt" : "Find a useful starting point", href: nl ? "/nl/organisaties/" : "/organizations/" },
    { icon: Landmark, label: nl ? "Overheid & documenten" : "Government & documents", text: nl ? "De juiste officiële route" : "The right official route", href: `${categoryBase}government/` },
    { icon: BookOpen, label: nl ? "Wonen in Nederland" : "Living in the Netherlands", text: nl ? "Van je eerste stap tot elke dag" : "From your first steps to everyday life", href: nl ? `${search}?q=wonen` : "/start/" }
  ];
  const guides = [
    { title: nl ? "Je eerste stappen in Nederland" : "Your first steps in the Netherlands", text: nl ? "Begin bij inschrijving en vind de officiële route voor jouw situatie." : "Start with registration and find the official route for your situation.", query: "BSN BRP", tag: nl ? "Beginnen" : "Getting started" },
    { title: nl ? "Een huisarts en zorg regelen" : "Finding your way through healthcare", text: nl ? "Praktische uitleg over huisarts, zorgverzekering en verantwoordelijke instanties." : "Practical guidance on GPs, health insurance and the responsible institutions.", query: nl ? "huisarts zorgverzekering" : "GP health insurance", tag: nl ? "Dagelijks leven" : "Everyday life" },
    { title: nl ? "Op weg naar een nieuw thuis" : "On your way to a new home", text: nl ? "Vind informatie over huren, rechten en volgende stappen." : "Find information on renting, your rights and what to do next.", query: nl ? "wonen huren" : "housing renting", tag: nl ? "Wonen" : "Housing" }
  ];
  return <PageShell locale={locale} className="discovery-home">
    <section className="experience-hero section-shell" aria-labelledby="home-title">
      <div className="experience-hero-copy"><h1 id="home-title">{nl ? <>Wat wil je doen<br />in <em>Nederland?</em></> : <>What would you like<br />to do in <em>the Netherlands?</em></>}</h1>
      <p>{nl ? "Je leven regelen. Een stad ontdekken. Je bedrijf laten zien. Vind je volgende stap, met bronnen die je kunt controleren." : "Make life easier. Discover a city. Share your business. Find your next step, with sources you can check."}</p>
      <div className="discovery-search"><HomeSearchForm locale={locale} /></div></div>
      <div className="experience-hero-photo"><ContentMedia asset={{ ...discoveryHero, alt: nl ? "De Erasmusbrug en de skyline van Rotterdam, gezien vanaf de Euromast" : discoveryHero.alt }} variant="hero" sizes="(max-width: 760px) 100vw, (max-width: 1000px) 40vw, 520px" eager eagerMedia="(min-width: 761px)" /><span className="discovery-photo-label"><MapPin aria-hidden />Rotterdam, Erasmusbrug</span></div>
    </section>
    <nav className="experience-paths section-shell" aria-label={nl ? "Kies je route" : "Choose your path"}>
      <Link prefetch={false} href="#live"><span>{nl ? "Wonen" : "Live"}</span><strong>{nl ? "Ik woon hier" : "I live here"}</strong><p>{nl ? "Van BSN tot huisarts" : "From BSN to finding a GP"}</p><ArrowRight aria-hidden /></Link>
      <Link prefetch={false} href="#cities-title"><span>{nl ? "Ontdekken" : "Explore"}</span><strong>{nl ? "Ik wil op ontdekking" : "I want to explore"}</strong><p>{nl ? "Vind jouw volgende stad" : "Find your next city"}</p><ArrowRight aria-hidden /></Link>
      <Link prefetch={false} href={nl ? "/nl/voor-bedrijven/" : "/for-business/"}><span>{nl ? "Ondernemen" : "Business"}</span><strong>{nl ? "Ik heb een bedrijf" : "I own a business"}</strong><p>{nl ? "Een gratis profiel, na controle" : "A free profile, after review"}</p><ArrowRight aria-hidden /></Link>
    </nav>
    <section className="experience-tasks section-shell" id="live" aria-labelledby="tasks-title"><div><p className="discovery-kicker">{nl ? "Wonen in Nederland" : "Live in the Netherlands"}</p><h2 id="tasks-title">{nl ? "Eerst even dit regelen." : "Let’s get that sorted."}</h2></div><nav aria-label={nl ? "Populaire taken" : "Popular tasks"}>{[
      ["BSN & DigiD", "BSN DigiD"], [nl ? "Een huisarts vinden" : "Find a doctor", nl ? "huisarts" : "doctor"], [nl ? "Een woning huren" : "Rent a home", "housing renting"], [nl ? "Werk & rechten" : "Work & rights", "work rights"], [nl ? "Onderwijs" : "Education", "education"], [nl ? "Zorgverzekering" : "Health insurance", "health insurance"]
    ].map(([label,query])=><Link prefetch={false} key={label} href={`${search}?q=${encodeURIComponent(query)}`}>{label}<ArrowRight aria-hidden /></Link>)}</nav></section>
    <section className="discovery-section section-shell" aria-labelledby="cities-title">
      <div className="discovery-section-heading"><div><p className="discovery-kicker">{nl ? "Een lokale blik" : "A local perspective"}</p><h2 id="cities-title">{nl ? "Welke stad wordt het?" : "Every city, a different story."}</h2></div><p>{nl ? "Vijf steden. Praktische stadsgidsen. Vind je eigen vertrekpunt." : "Five cities. Practical local guides. Find your own starting point."}</p></div>
      <div className="discovery-city-rail">{cityGuides.map((guide) => {
        const city = getContentEntityById(guide.cityEntityId);
        const photo = discoveryMedia[guide.slug] as PublicMediaAsset;
        return <article className="discovery-city" key={guide.slug}>
          {photo ? <ContentMedia asset={photo} variant="gallery" deferUntilVisible sizes="(max-width: 760px) 70vw, (max-width: 1000px) 30vw, 240px" /> : null}
          <Link prefetch={false} href={nl ? `/nl/stadsgidsen/${guide.slug}/` : `/city-guides/${guide.slug}/`}><h3>{city?.title ?? guide.slug}</h3><ArrowRight aria-hidden /><p>{cityNotes[guide.slug][locale]}</p></Link>
        </article>;
      })}</div>
      <p className="experience-all-cities">{nl ? "Een andere stad?" : "Somewhere else?"} <Link prefetch={false} href={nl ? "/nl/leiden/" : "/leiden/"}>Leiden</Link> · <Link prefetch={false} href="/municipalities/">{nl ? "Alle gemeenten (EN)" : "All municipalities"}<ArrowRight aria-hidden /></Link></p>
    </section>
    <section className="discovery-section section-shell discovery-guides" aria-labelledby="guides-title">
      <div className="discovery-guide-intro"><p className="discovery-kicker">{nl ? "Een stap verder" : "A little local know-how"}</p><h2 id="guides-title">{nl ? "Meer weten. Makkelijker beginnen." : "Less searching. More getting started."}</h2><p>{nl ? "Duidelijke uitleg, praktische vervolgstappen en links naar de verantwoordelijke instanties. Controleer belangrijke details altijd bij de bron." : "Clear explanations, practical next steps and links to the responsible institutions. Always confirm important details at the source."}</p><Link prefetch={false} className="discovery-text-link" href={nl ? "/nl/categorieen/" : "/guides/"}>{nl ? "Bekijk alle onderwerpen" : "Explore practical guides"}<ArrowRight aria-hidden /></Link></div>
      <div className="discovery-guide-list">{guides.map((guide, i) => <Link prefetch={false} href={`${search}?q=${encodeURIComponent(guide.query)}`} key={guide.query}><span className="discovery-guide-number">0{i + 1}</span><div><small>{guide.tag}</small><h3>{guide.title}</h3><p>{guide.text}</p></div><ArrowRight aria-hidden /></Link>)}</div>
    </section>
    <section className="discovery-categories-band" aria-labelledby="categories-title"><div className="discovery-section section-shell">
      <div className="discovery-section-heading"><div><p className="discovery-kicker">{nl ? "Maak het jouw dag" : "Make it your day"}</p><h2 id="categories-title">{nl ? "Wat zoek je vandaag?" : "What brings you here?"}</h2></div><p>{nl ? "Van iets moois ontdekken tot iets belangrijks regelen." : "From discovering somewhere new to getting something important sorted."}</p></div>
      <div className="discovery-category-list">{categories.map(({ icon: Icon, label, text, href }) => <Link prefetch={false} href={href} key={label}><Icon aria-hidden /><span><strong>{label}</strong><small>{text}</small></span><ArrowRight aria-hidden /></Link>)}</div>
    </div></section>
    <section className="discovery-business section-shell" aria-labelledby="business-title"><div><p className="discovery-kicker">YouNew for Business</p><h2 id="business-title">{nl ? "Een plek voor jouw bedrijf." : "Bring your business to YouNew."}</h2><p>{nl ? "Help nieuwe inwoners je bedrijf te vinden en begrijpen. Vraag een gratis profiel aan; publicatie volgt na controle." : "Help new residents find and understand your business. Request a free profile, with publication after review."}</p></div><div className="discovery-business-action"><Link prefetch={false} className="button button-primary" href={nl ? "/nl/voor-bedrijven/aanmelden/" : "/for-business/local/apply/"}>{nl ? "Gratis profiel aanvragen" : "Request a free profile"}<ArrowRight aria-hidden /></Link><Link prefetch={false} href={nl ? "/nl/voor-bedrijven/" : "/for-business/"}>{nl ? "Zo werkt het" : "See how it works"}<ArrowRight aria-hidden /></Link><small>{nl ? "Geen betaling. Geen automatische publicatie." : "No payment. No automatic publication."}</small></div></section>
    <section className="discovery-section section-shell discovery-trust" aria-labelledby="trust-title"><ShieldCheck aria-hidden /><div><h2 id="trust-title">{nl ? "Vertrouwen begint bij de bron." : "Trust starts with the source."}</h2><p>{nl ? "Bronnen en controledatums blijven zichtbaar. Onbevestigde profielen en kandidaten voor publicatie blijven buiten de zoekresultaten. Je ziet alleen wat we kunnen onderbouwen." : "Sources and review dates stay visible. Unconfirmed profiles and publication candidates stay outside search results. You see only what we can substantiate."}</p></div><Link prefetch={false} className="discovery-text-link" href="/status/">{nl ? "Onze inhoudsstatus (EN)" : "Our content status"}<ArrowRight aria-hidden /></Link></section>
  </PageShell>;
}
