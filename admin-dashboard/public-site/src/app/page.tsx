import type { Metadata } from "next";
import Link from "next/link";
import type { LucideIcon } from "lucide-react";
import {
  ArrowRight,
  Banknote,
  Bike,
  BookOpen,
  BriefcaseBusiness,
  Building2,
  ExternalLink,
  FileCheck2,
  FileText,
  Globe2,
  GraduationCap,
  HandCoins,
  HeartHandshake,
  HeartPulse,
  Home,
  Landmark,
  Languages,
  LifeBuoy,
  ListChecks,
  Luggage,
  MapPinned,
  PawPrint,
  ReceiptText,
  RefreshCw,
  Search,
  ShieldCheck,
  ShoppingBasket,
  Sparkles,
  Smartphone,
  Stethoscope,
  TrainFront,
  Trees,
  Truck,
  Users,
  UtensilsCrossed
} from "lucide-react";
import { ContentMedia, preferredMedia } from "@/components/content-media";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
import { getPublicContent, type PublicMediaAsset } from "@/lib/content";

export const metadata: Metadata = {
  title: { absolute: "YouNew — Your guide to life in the Netherlands" },
  description: "Find housing, work, documents, healthcare, schools and trusted services in the Netherlands—with clear next steps and official sources.",
  alternates: { canonical: "https://younew.nl/" }
};

type Destination = Readonly<{
  title: string;
  example: string;
  href: string;
  icon: LucideIcon;
  urgent?: boolean;
}>;

type Direction = Readonly<{
  title: string;
  href: string;
  icon: LucideIcon;
}>;

const searchHref = (query: string) => `/search/?q=${encodeURIComponent(query)}`;

const heroSuggestions = [
  "I need housing in Leiden",
  "I need work",
  "I need a GP",
  "I need BSN"
] as const;

const taskDestinations: readonly Destination[] = [
  { title: "Find housing", example: "Rent a home", href: searchHref("housing"), icon: Home },
  { title: "Find work", example: "Search jobs", href: searchHref("work"), icon: BriefcaseBusiness },
  { title: "Healthcare", example: "Find a GP", href: searchHref("healthcare GP"), icon: HeartPulse },
  { title: "Documents", example: "Get a BSN", href: searchHref("BSN documents"), icon: FileText },
  { title: "Study", example: "Find a course", href: searchHref("study education"), icon: GraduationCap },
  { title: "Daily life", example: "Open a bank account", href: searchHref("daily life bank account"), icon: ShoppingBasket },
  { title: "Emergency", example: "Get urgent help", href: "/emergency/", icon: LifeBuoy, urgent: true },
  { title: "LGBTQ+", example: "Find support", href: searchHref("LGBTQ support"), icon: HeartHandshake },
  { title: "Pets", example: "Register your pet", href: searchHref("pets registration"), icon: PawPrint },
  { title: "Families", example: "Find childcare", href: searchHref("families childcare"), icon: Users }
];

const lifeDirections: readonly Direction[] = [
  { title: "Living", href: "/start/", icon: Home },
  { title: "Working", href: searchHref("work"), icon: BriefcaseBusiness },
  { title: "Studying", href: searchHref("education study"), icon: GraduationCap },
  { title: "Travelling", href: "/discover/", icon: Luggage },
  { title: "Moving", href: searchHref("moving registration"), icon: Truck },
  { title: "Business", href: "/business/", icon: Building2 },
  { title: "Culture", href: "/categories/culture/", icon: Landmark },
  { title: "History", href: "/discover/", icon: BookOpen },
  { title: "Nature", href: "/categories/outdoors/", icon: Trees },
  { title: "Cities", href: "/cities/", icon: MapPinned },
  { title: "Food", href: "/categories/food-drink/", icon: UtensilsCrossed },
  { title: "Transport", href: "/categories/transport/", icon: TrainFront }
];

const popularTasks: readonly Direction[] = [
  { title: "Get a BSN", href: "/guides/first-registration-in-amsterdam/", icon: FileCheck2 },
  { title: "Find housing", href: "/categories/housing/", icon: Home },
  { title: "Register with a municipality", href: "/municipalities/", icon: Building2 },
  { title: "Open a bank account", href: searchHref("open a bank account"), icon: Banknote },
  { title: "Find work", href: searchHref("find work"), icon: BriefcaseBusiness },
  { title: "Register with a huisarts", href: searchHref("register with a huisarts GP"), icon: Stethoscope },
  { title: "Get DigiD", href: searchHref("DigiD"), icon: Smartphone },
  { title: "Arrange health insurance", href: searchHref("health insurance"), icon: ShieldCheck },
  { title: "Learn Dutch", href: searchHref("Dutch lessons"), icon: Languages },
  { title: "Buy a bicycle", href: searchHref("buy a bicycle"), icon: Bike }
];

const usefulServices: readonly Destination[] = [
  { title: "Government", example: "National services and information", href: "/categories/government/", icon: Landmark },
  { title: "Municipalities", example: "Local services where you live", href: "/municipalities/", icon: Building2 },
  { title: "Healthcare", example: "Doctors, insurance and care", href: "/categories/healthcare/", icon: HeartPulse },
  { title: "Education", example: "Schools, study and diplomas", href: "/categories/education/", icon: GraduationCap },
  { title: "Housing", example: "Renting, rights and permits", href: "/categories/housing/", icon: Home },
  { title: "Transport", example: "Public transport and driving", href: "/categories/transport/", icon: TrainFront },
  { title: "Tax", example: "Returns, allowances and payments", href: searchHref("tax Belastingdienst"), icon: ReceiptText },
  { title: "Benefits", example: "Allowances and support", href: searchHref("benefits allowances"), icon: HandCoins },
  { title: "Immigration", example: "Visas, residence and citizenship", href: searchHref("immigration residence permit"), icon: Globe2 }
];

const proofPoints: readonly Destination[] = [
  { title: "Verified information", example: "Published content is checked before release.", href: "/status/", icon: ShieldCheck },
  { title: "Official sources", example: "Responsible Dutch institutions stay visible.", href: "/status/", icon: ExternalLink },
  { title: "Updated regularly", example: "Review dates and limitations are published.", href: "/updates/", icon: RefreshCw },
  { title: "Clear step-by-step guides", example: "Practical actions without invented steps.", href: "/guides/", icon: ListChecks },
  { title: "Built for newcomers", example: "Start with a real task, not bureaucracy.", href: "/start/", icon: Users },
  { title: "Fast search", example: "Find a useful route in a few words.", href: "/search/", icon: Search }
];

const leidenMedia: PublicMediaAsset = {
  id: "homepage.leiden-kanaal",
  role: "hero",
  url: "https://upload.wikimedia.org/wikipedia/commons/a/a5/Leiden_Kanaal.jpg",
  alt: "Canal, bridge and historic houses in Leiden",
  attribution: "K. Graf",
  license: "CC BY-SA 3.0",
  licenseUrl: "https://creativecommons.org/licenses/by-sa/3.0/",
  sourcePageUrl: "https://commons.wikimedia.org/wiki/File:Leiden_Kanaal.jpg",
  retrievedAt: "2026-08-06"
};

const featuredCityIds = [
  "city.amsterdam",
  "city.rotterdam",
  "city.den-haag",
  "city.utrecht",
  "city.eindhoven"
] as const;

const latestGuideIds = [
  "government_service.driving-licence-amsterdam",
  "housing.renting-a-home-in-amsterdam",
  "government_service.first-registration-in-amsterdam"
] as const;

const dateFormatter = new Intl.DateTimeFormat("en-GB", {
  day: "numeric",
  month: "long",
  year: "numeric",
  timeZone: "UTC"
});

function formatDate(value: string) {
  return dateFormatter.format(new Date(`${value}T00:00:00Z`));
}

function TaskCard({ destination }: { destination: Destination }) {
  const Icon = destination.icon;
  return (
    <Link className={destination.urgent ? "vision-task is-emergency" : "vision-task"} href={destination.href}>
      <Icon aria-hidden />
      <span>
        <strong>{destination.title}</strong>
        <small>{destination.example}</small>
      </span>
      <ArrowRight aria-hidden />
    </Link>
  );
}

function HomeSearch() {
  return (
    <div className="vision-search-assistant">
      <form action="/search/" method="get">
        <label htmlFor="home-search">What do you need in the Netherlands?</label>
        <div>
          <input id="home-search" name="q" placeholder="For example: housing in Leiden" type="search" />
          <button aria-label="Search YouNew" type="submit"><Search aria-hidden /></button>
        </div>
      </form>
      <nav aria-label="Search examples">
        {heroSuggestions.map((suggestion) => <Link href={searchHref(suggestion)} key={suggestion}>{suggestion}</Link>)}
      </nav>
    </div>
  );
}

export default function HomePage() {
  const content = getPublicContent();
  const cityEntities = featuredCityIds.flatMap((id) => {
    const entity = content.entities.find((candidate) => candidate.id === id);
    return entity ? [entity] : [];
  });
  const cities = [
    cityEntities.find((city) => city.id === "city.amsterdam"),
    { id: "city.leiden", title: "Leiden", route: "/municipalities/leiden/", images: [leidenMedia] },
    cityEntities.find((city) => city.id === "city.rotterdam"),
    cityEntities.find((city) => city.id === "city.den-haag"),
    cityEntities.find((city) => city.id === "city.utrecht"),
    cityEntities.find((city) => city.id === "city.eindhoven")
  ].filter((city): city is NonNullable<typeof city> => Boolean(city));
  const latestGuides = latestGuideIds.flatMap((id) => {
    const entity = content.entities.find((candidate) => candidate.id === id);
    return entity ? [entity] : [];
  });

  return (
    <div className="product-vision-home">
      <a className="skip-link" href="#main-content">Skip to content</a>
      <SiteHeader />

      <main id="main-content">
        <section className="vision-hero" aria-labelledby="vision-hero-title">
          <div className="section-shell vision-hero-grid">
            <div className="vision-hero-copy">
              <h1 id="vision-hero-title">Your guide to life in the Netherlands.</h1>
              <p>Find housing, work, documents, healthcare, schools and trusted services — with clear next steps and official sources.</p>
              <HomeSearch />
              <div className="vision-hero-actions">
                <Link className="vision-primary-action" href="/start/">Find my next step <ArrowRight aria-hidden /></Link>
                <Link className="vision-secondary-action vision-naruto-action" href="/naruto/"><Sparkles aria-hidden /> Ask Naruto</Link>
                <Link className="vision-secondary-action" href="/discover/">Explore the Netherlands <ArrowRight aria-hidden /></Link>
              </div>
            </div>
          </div>
        </section>

        <section className="vision-section vision-needs section-shell" aria-labelledby="needs-title">
          <div className="vision-heading"><h2 id="needs-title">What do you need?</h2><p>Choose one task. YouNew will narrow the next screen instead of opening another catalogue.</p></div>
          <div className="vision-task-grid">{taskDestinations.map((destination) => <TaskCard destination={destination} key={destination.title} />)}</div>
        </section>

        <section className="vision-life-band" aria-labelledby="life-title">
          <div className="section-shell">
            <div className="vision-heading"><h2 id="life-title">Life in the Netherlands</h2><p>Explore one part of everyday life at a time.</p></div>
            <nav className="vision-direction-rail" aria-label="Life in the Netherlands">
              {lifeDirections.map(({ title, href, icon: Icon }) => <Link href={href} key={title}><Icon aria-hidden /><span>{title}</span></Link>)}
            </nav>
          </div>
        </section>

        <section className="vision-section vision-popular section-shell" aria-labelledby="popular-tasks-title">
          <div className="vision-heading"><h2 id="popular-tasks-title">Popular tasks</h2><p>Direct routes to common newcomer actions.</p></div>
          <ol className="vision-popular-list">
            {popularTasks.map(({ title, href, icon: Icon }, index) => (
              <li key={title}><Link href={href}><span>{index + 1}</span><Icon aria-hidden /><strong>{title}</strong><ArrowRight aria-hidden /></Link></li>
            ))}
          </ol>
        </section>

        <section className="vision-section vision-cities" aria-labelledby="cities-title">
          <div className="section-shell">
            <div className="vision-heading is-row"><div><h2 id="cities-title">Cities</h2><p>Start with a place and continue to its responsible local services.</p></div><Link href="/cities/">View all cities <ArrowRight aria-hidden /></Link></div>
            <div className="vision-city-rail">
              {cities.map((city) => {
                const media = preferredMedia(city.images, ["gallery", "hero", "thumbnail"]);
                return (
                  <article key={city.id}>
                    {media ? <ContentMedia asset={media} variant="gallery" /> : null}
                    <h3><Link href={city.route}>{city.title}<ArrowRight aria-hidden /></Link></h3>
                  </article>
                );
              })}
            </div>
          </div>
        </section>

        <section className="vision-section vision-services" aria-label="Useful services and trusted resources">
          <div className="section-shell vision-services-grid">
            <div>
              <div className="vision-heading"><h2>Useful services</h2><p>Start with the service you need, not the institution behind it.</p></div>
              <div className="vision-service-list">{usefulServices.map((service) => <TaskCard destination={service} key={service.title} />)}</div>
            </div>
            <div>
              <div className="vision-heading"><h2>Trusted resources</h2><p>Use YouNew for orientation, then confirm important details with the responsible authority.</p></div>
              <div className="vision-official-list">
                <TrackedOfficialSourceLink contentId="home.government" href="https://www.government.nl/" rel="noreferrer" target="_blank"><Landmark aria-hidden /><span><strong>Government.nl</strong><small>Official information from the Dutch national government.</small></span><ExternalLink aria-hidden /></TrackedOfficialSourceLink>
                <Link href="/municipalities/"><Building2 aria-hidden /><span><strong>Your municipality</strong><small>Find local information and services where you live.</small></span><ArrowRight aria-hidden /></Link>
                <TrackedOfficialSourceLink contentId="home.belastingdienst" href="https://www.belastingdienst.nl/wps/wcm/connect/en/individuals/individuals" rel="noreferrer" target="_blank"><ReceiptText aria-hidden /><span><strong>Belastingdienst</strong><small>Official information about Dutch taxes and payments.</small></span><ExternalLink aria-hidden /></TrackedOfficialSourceLink>
                <TrackedOfficialSourceLink contentId="home.ind" href="https://ind.nl/en" rel="noreferrer" target="_blank"><FileCheck2 aria-hidden /><span><strong>IND</strong><small>Immigration and Naturalisation Service.</small></span><ExternalLink aria-hidden /></TrackedOfficialSourceLink>
              </div>
            </div>
          </div>
        </section>

        <section className="vision-section vision-why section-shell" aria-labelledby="why-title">
          <div className="vision-heading"><h2 id="why-title">Why YouNew</h2><p>Clear orientation without hiding uncertainty or official responsibility.</p></div>
          <div className="vision-proof-grid">
            {proofPoints.map(({ title, example, href, icon: Icon }) => <Link href={href} key={title}><Icon aria-hidden /><strong>{title}</strong><span>{example}</span></Link>)}
          </div>
        </section>

        <section className="vision-business" aria-labelledby="business-title">
          <div className="section-shell vision-business-panel">
            <div>
              <span>For businesses</span>
              <h2 id="business-title">Reach newcomers responsibly.</h2>
              <p>Advertising and partnerships remain separate from organic guidance. Campaigns appear only after review and activation.</p>
              <nav aria-label="Business options">
                <Link href="/business/advertise">Advertising standards <ArrowRight aria-hidden /></Link>
                <Link href="/business/partners">Explore partnerships <ArrowRight aria-hidden /></Link>
              </nav>
            </div>
            <div className="vision-campaign-state">
              <ShieldCheck aria-hidden />
              <strong>No live public campaigns</strong>
              <p>Sponsored placements are never shown in emergency guidance, never replace responsible official sources, and never change organic search ranking.</p>
            </div>
          </div>
        </section>

        <section className="vision-section vision-updates" aria-labelledby="updates-title">
          <div className="section-shell">
            <div className="vision-heading is-row"><div><h2 id="updates-title">Latest updates</h2><p>Recently checked additions from the published content snapshot.</p></div><Link href="/updates/">View all updates <ArrowRight aria-hidden /></Link></div>
            <div className="vision-update-list">
              {latestGuides.map((guide) => {
                const media = preferredMedia(guide.images, ["thumbnail", "hero", "gallery"]);
                return (
                  <article key={guide.id}>
                    {media ? <ContentMedia asset={media} variant="card" /> : null}
                    <div><span>{guide.categorySlugs.at(0)?.replaceAll("-", " ") ?? "Guide"}</span><h3><Link href={guide.route}>{guide.title}</Link></h3><p>{guide.summary}</p></div>
                    <time dateTime={guide.updatedAt}>{formatDate(guide.updatedAt)}</time>
                    <Link aria-label={`Open ${guide.title}`} href={guide.route}><ArrowRight aria-hidden /></Link>
                  </article>
                );
              })}
            </div>
          </div>
        </section>
      </main>
      <SiteFooter />
    </div>
  );
}
