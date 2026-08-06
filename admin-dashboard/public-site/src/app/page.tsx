import type { Metadata } from "next";
import Link from "next/link";
import type { LucideIcon } from "lucide-react";
import {
  ArrowRight,
  Banknote,
  BriefcaseBusiness,
  Building2,
  CheckCircle2,
  ExternalLink,
  FileCheck2,
  FileText,
  Globe2,
  GraduationCap,
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
  Search,
  ShieldCheck,
  ShoppingBasket,
  Sparkles,
  Stethoscope,
  TrainFront,
  Trees,
  Truck,
  Users
} from "lucide-react";
import { ContentMedia, preferredMedia } from "@/components/content-media";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
import { getPublicContent, type PublicMediaAsset } from "@/lib/content";
import {
  taskHref,
  type TaskIconName,
  youNewTasks
} from "@/lib/product/task-taxonomy";
import { getNationalGuides, nationalGuidesVerifiedAt } from "@/lib/search/national-guides";

export const metadata: Metadata = {
  title: { absolute: "YouNew — Your new life in the Netherlands" },
  description: "Solve practical tasks in the Netherlands with clear next steps, checked guidance and responsible official sources.",
  alternates: { canonical: "https://younew.nl/" }
};

type Direction = Readonly<{ title: string; href: string; icon: LucideIcon }>;

const taskIcons: Record<TaskIconName, LucideIcon> = {
  home: Home,
  work: BriefcaseBusiness,
  healthcare: HeartPulse,
  documents: FileText,
  study: GraduationCap,
  "daily-life": ShoppingBasket,
  emergency: LifeBuoy,
  lgbtiq: HeartHandshake,
  pets: PawPrint,
  family: Users
};

const searchHref = (query: string) => `/search/?q=${encodeURIComponent(query)}`;

const heroSuggestions = ["Housing in Leiden", "Find work", "Register with a GP", "Get a BSN"] as const;

const lifeDirections: readonly Direction[] = [
  { title: "Living", href: "/tasks/housing/", icon: Home },
  { title: "Working", href: "/tasks/work/", icon: BriefcaseBusiness },
  { title: "Studying", href: "/tasks/study/", icon: GraduationCap },
  { title: "Travelling", href: "/discover/", icon: Luggage },
  { title: "Moving", href: "/essentials/utilities-and-moving-home/", icon: Truck },
  { title: "Culture", href: "/categories/culture/", icon: Landmark },
  { title: "Nature", href: "/categories/outdoors/", icon: Trees },
  { title: "Cities", href: "/cities/", icon: MapPinned }
];

const popularTasks: readonly Direction[] = [
  { title: "Get a BSN", href: "/essentials/documents-registration-and-digid/", icon: FileCheck2 },
  { title: "Find housing", href: "/essentials/housing-and-renting/", icon: Home },
  { title: "Open a bank account", href: "/essentials/bank-account-and-payments/", icon: Banknote },
  { title: "Register with a huisarts", href: "/essentials/healthcare-doctor-and-insurance/", icon: Stethoscope },
  { title: "Arrange health insurance", href: "/essentials/healthcare-doctor-and-insurance/", icon: ShieldCheck },
  { title: "Learn Dutch", href: "/essentials/education-and-learning-dutch/", icon: Languages }
];

const usefulServices: readonly Direction[] = [
  { title: "Government services", href: "/categories/government/", icon: Landmark },
  { title: "Your municipality", href: "/municipalities/", icon: Building2 },
  { title: "Healthcare", href: "/tasks/healthcare/", icon: HeartPulse },
  { title: "Housing", href: "/tasks/housing/", icon: Home },
  { title: "Transport", href: "/essentials/public-transport-and-cycling/", icon: TrainFront },
  { title: "Immigration", href: "/essentials/immigration-visas-and-residence-permits/", icon: Globe2 }
];

const proofPoints = [
  { title: "Checked guidance", description: "Published routes keep a visible source-check date.", href: "/status/", icon: ShieldCheck },
  { title: "Official sources", description: "The responsible Dutch authority stays visible at the point of action.", href: "/status/", icon: ExternalLink },
  { title: "Useful next step", description: "Every solution should end with an answer, checklist, decision or action.", href: "/guides/", icon: ListChecks },
  { title: "Honest local limits", description: "National guidance remains visible when verified local coverage is missing.", href: "/municipalities/", icon: MapPinned }
] as const;

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

const featuredCityIds = ["city.amsterdam", "city.rotterdam", "city.den-haag", "city.utrecht", "city.eindhoven"] as const;
const latestNationalGuideIds = ["national.business-zzp", "national.pregnancy", "national.mental-health"] as const;

const dateFormatter = new Intl.DateTimeFormat("en-GB", {
  day: "numeric",
  month: "long",
  year: "numeric",
  timeZone: "UTC"
});

function formatDate(value: string) {
  return dateFormatter.format(new Date(`${value}T00:00:00Z`));
}

function HomeSearch() {
  return (
    <div className="vision-search-assistant">
      <form action="/search/" method="get">
        <label htmlFor="home-search">What do you need in the Netherlands?</label>
        <div>
          <input id="home-search" name="q" placeholder="For example: I need housing in Leiden" type="search" />
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
  const nationalGuides = getNationalGuides();
  const latestGuides = latestNationalGuideIds.flatMap((id) => {
    const guide = nationalGuides.find((candidate) => candidate.id === id);
    return guide ? [guide] : [];
  });
  const nationalVerifiedAt = nationalGuidesVerifiedAt();

  return (
    <div className="product-vision-home solution-first-home">
      <a className="skip-link" href="#main-content">Skip to content</a>
      <SiteHeader />

      <main id="main-content">
        <section className="vision-hero" aria-labelledby="vision-hero-title">
          <div className="section-shell vision-hero-grid">
            <div className="vision-hero-copy">
              <h1 id="vision-hero-title">Your new life in the Netherlands</h1>
              <p>Start with one real-life task. YouNew helps you clarify it, take the next step and confirm important details with the responsible source.</p>
              <HomeSearch />
              <p className="vision-hero-promise"><CheckCircle2 aria-hidden /> One task, one useful next action — usually within three clicks.</p>
            </div>
          </div>
        </section>

        <section className="vision-section vision-needs section-shell" aria-labelledby="needs-title">
          <div className="vision-heading"><h2 id="needs-title">What do you need?</h2><p>Choose one task. The next screen asks only the clarification needed to reach a useful solution.</p></div>
          <div className="vision-task-grid">
            {youNewTasks.map((task) => {
              const Icon = taskIcons[task.icon];
              return (
                <Link className={task.id === "emergency" ? "vision-task is-emergency" : "vision-task"} href={taskHref(task)} key={task.id}>
                  <Icon aria-hidden /><span><strong>{task.label}</strong><small>{task.example}</small></span><ArrowRight aria-hidden />
                </Link>
              );
            })}
          </div>
        </section>

        <section className="vision-life-band" aria-labelledby="life-title">
          <div className="section-shell">
            <div className="vision-heading"><h2 id="life-title">Life in the Netherlands</h2><p>Explore a direction when you do not yet have one specific task.</p></div>
            <nav className="vision-direction-rail" aria-label="Life in the Netherlands">
              {lifeDirections.map(({ title, href, icon: Icon }) => <Link href={href} key={title}><Icon aria-hidden /><span>{title}</span></Link>)}
            </nav>
          </div>
        </section>

        <section className="vision-section vision-popular section-shell" aria-labelledby="popular-tasks-title">
          <div className="vision-heading"><h2 id="popular-tasks-title">Popular tasks</h2><p>Go directly to a reviewed national solution.</p></div>
          <div className="vision-popular-layout">
            <ol className="vision-popular-list">
              {popularTasks.map(({ title, href, icon: Icon }, index) => (
                <li key={title}><Link href={href}><span>{index + 1}</span><Icon aria-hidden /><strong>{title}</strong><ArrowRight aria-hidden /></Link></li>
              ))}
            </ol>
            <aside className="vision-naruto-tip">
              <Sparkles aria-hidden />
              <span>Need help choosing?</span>
              <h3>Naruto clarifies your situation first.</h3>
              <p>Answer a short follow-up question, then continue to a published YouNew route with visible sources.</p>
              <Link href="/naruto/">Ask Naruto <ArrowRight aria-hidden /></Link>
            </aside>
          </div>
        </section>

        <section className="vision-section vision-cities" aria-labelledby="cities-title">
          <div className="section-shell">
            <div className="vision-heading is-row"><div><h2 id="cities-title">Big cities</h2><p>Add local context without losing national guidance.</p></div><Link href="/cities/">View all cities <ArrowRight aria-hidden /></Link></div>
            <div className="vision-city-rail">
              {cities.map((city) => {
                const media = preferredMedia(city.images, ["gallery", "hero", "thumbnail"]);
                return <article key={city.id}>{media ? <ContentMedia asset={media} variant="gallery" /> : null}<h3><Link href={city.route}>{city.title}<ArrowRight aria-hidden /></Link></h3></article>;
              })}
            </div>
          </div>
        </section>

        <section className="vision-section vision-services" aria-labelledby="trusted-services-title">
          <div className="section-shell">
            <div className="vision-heading"><h2 id="trusted-services-title">Trusted services and sources</h2><p>Start with the service you need. Confirm important requirements with the responsible authority.</p></div>
            <div className="vision-services-grid">
              <nav className="vision-service-list" aria-label="Useful service routes">
                {usefulServices.map(({ title, href, icon: Icon }) => <Link className="vision-service-route" href={href} key={title}><Icon aria-hidden /><strong>{title}</strong><ArrowRight aria-hidden /></Link>)}
              </nav>
              <div className="vision-official-list">
                <TrackedOfficialSourceLink contentId="home.government" href="https://www.government.nl/" rel="noreferrer" target="_blank"><Landmark aria-hidden /><span><strong>Government.nl</strong><small>Official national government information.</small></span><ExternalLink aria-hidden /></TrackedOfficialSourceLink>
                <Link href="/municipalities/"><Building2 aria-hidden /><span><strong>Your municipality</strong><small>Responsible local information and services.</small></span><ArrowRight aria-hidden /></Link>
                <TrackedOfficialSourceLink contentId="home.belastingdienst" href="https://www.belastingdienst.nl/wps/wcm/connect/en/individuals/individuals" rel="noreferrer" target="_blank"><ReceiptText aria-hidden /><span><strong>Belastingdienst</strong><small>Official taxes, allowances and payments.</small></span><ExternalLink aria-hidden /></TrackedOfficialSourceLink>
                <TrackedOfficialSourceLink contentId="home.ind" href="https://ind.nl/en" rel="noreferrer" target="_blank"><FileCheck2 aria-hidden /><span><strong>IND</strong><small>Immigration and naturalisation authority.</small></span><ExternalLink aria-hidden /></TrackedOfficialSourceLink>
              </div>
            </div>
          </div>
        </section>

        <section className="vision-section vision-why section-shell" aria-labelledby="why-title">
          <div className="vision-heading"><h2 id="why-title">Why YouNew</h2><p>Useful orientation without hiding uncertainty or official responsibility.</p></div>
          <div className="vision-proof-grid">
            {proofPoints.map(({ title, description, href, icon: Icon }) => <Link href={href} key={title}><Icon aria-hidden /><strong>{title}</strong><span>{description}</span></Link>)}
          </div>
        </section>

        <section className="vision-section vision-updates" aria-labelledby="updates-title">
          <div className="section-shell">
            <div className="vision-heading is-row"><div><h2 id="updates-title">Latest updates</h2><p>Three recently checked national additions.</p></div><Link href="/updates/">View all updates <ArrowRight aria-hidden /></Link></div>
            <div className="vision-update-list">
              {latestGuides.map((guide) => (
                <article key={guide.id}>
                  <div><span>{guide.category.replaceAll("-", " ")}</span><h3><Link href={`/essentials/${guide.slug}/`}>{guide.title}</Link></h3><p>{guide.summary}</p></div>
                  <time dateTime={nationalVerifiedAt}>{formatDate(nationalVerifiedAt)}</time>
                  <Link aria-label={`Open ${guide.title}`} href={`/essentials/${guide.slug}/`}><ArrowRight aria-hidden /></Link>
                </article>
              ))}
            </div>
          </div>
        </section>
      </main>
      <SiteFooter />
    </div>
  );
}
