import Image from "next/image";
import Link from "next/link";
import {
  ArrowRight,
  BookOpen,
  Building2,
  CheckCircle2,
  Compass,
  ExternalLink,
  Landmark,
  Layers3,
  LayoutGrid,
  MapPinned,
  Megaphone,
  Newspaper,
  Route,
  Search,
  ShieldCheck,
  Smartphone,
  Waypoints
} from "lucide-react";
import { ContentMedia, preferredMedia } from "@/components/content-media";
import { HomepageProfileSelector } from "@/components/homepage-profile-selector";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
import { advertisingSurfaceCatalog } from "@/lib/business/catalog";
import { SPONSORED_PLACEMENTS_ENABLED } from "@/lib/business/sponsored";
import { getPublicContent } from "@/lib/content";
import { getNetherlandsGeography } from "@/lib/geography/repository";
import { links } from "@/lib/site-data";
import statusSnapshot from "@/config/status.json";

const publicDate = new Intl.DateTimeFormat("en-GB", {
  day: "numeric",
  month: "long",
  year: "numeric",
  timeZone: "UTC"
});

const popularTasks: readonly Readonly<{
  title: string;
  text: string;
  href: string;
  label: string;
  urgent?: boolean;
}>[] = [
  {
    title: "Register in Amsterdam and get a BSN",
    text: "Start with registration in Amsterdam and check the municipality requirements.",
    href: "/guides/first-registration-in-amsterdam",
    label: "Registration"
  },
  {
    title: "Renting a home in Amsterdam",
    text: "Review the published Amsterdam renting summary and its responsible sources.",
    href: "/guides/renting-a-home-in-amsterdam",
    label: "Housing"
  },
  {
    title: "Driving licence in Amsterdam",
    text: "See the current Amsterdam starting points for applying or exchanging a licence.",
    href: "/guides/driving-licence-amsterdam",
    label: "Transport"
  },
  {
    title: "Amsterdam municipal taxes",
    text: "Find the published Amsterdam overview and continue to the official source.",
    href: "/guides/municipal-taxes-amsterdam",
    label: "Money"
  },
  {
    title: "Report a street problem in Amsterdam",
    text: "Find where Amsterdam accepts reports about streets and public areas.",
    href: "/guides/report-a-problem-in-public-space-amsterdam",
    label: "Local services"
  },
  {
    title: "Get emergency help",
    text: "Use 112 for immediate danger or find the right non-emergency route.",
    href: "/emergency",
    label: "Safety",
    urgent: true
  }
];

const cities = ["Amsterdam", "Rotterdam", "Den Haag", "Utrecht", "Eindhoven"] as const;
const galleryCityIds = ["city.amsterdam", "city.rotterdam", "city.den-haag", "city.utrecht", "city.eindhoven"] as const;

function humanDate(value: string) {
  return publicDate.format(new Date(`${value}T00:00:00Z`));
}

function HomeRouteVisual() {
  return (
    <div className="home-route-visual" aria-hidden="true">
      <svg viewBox="0 0 560 500" role="presentation">
        <path className="home-route-map-line" d="M24 394C92 322 112 244 185 252c76 9 78 106 157 92 76-13 63-120 178-173" />
        <path className="home-route-street" d="M-12 112c123 19 213-42 318-13 83 23 126 7 268-48M55 502c92-139 201-190 313-212 70-14 125-52 196-125" />
        <circle cx="189" cy="253" r="13" />
        <circle cx="341" cy="344" r="13" />
        <circle className="home-route-destination" cx="520" cy="171" r="19" />
      </svg>
      <span className="home-route-label home-route-label-start">Your question</span>
      <span className="home-route-label home-route-label-guide">Useful guidance</span>
      <span className="home-route-label home-route-label-source">Official source</span>
    </div>
  );
}

export default function HomePage() {
  const checkedDate = humanDate(statusSnapshot.content.asOf);
  const content = getPublicContent();
  const geography = getNetherlandsGeography();
  const galleryCities = galleryCityIds.flatMap((id) => {
    const entity = content.entities.find((candidate) => candidate.id === id);
    return entity ? [entity] : [];
  });
  const netherlandsDirectory = [
    { title: "Cities", text: "Published local guides for the five current focus cities.", href: "/cities", value: content.stats.cities, icon: MapPinned },
    { title: "Provinces", text: "Browse all Dutch provinces and their municipality directories.", href: "/provinces", value: geography.stats.provinces, icon: Layers3 },
    { title: "Municipalities", text: "Find local authority details across the Netherlands.", href: "/municipalities", value: geography.stats.municipalities, icon: Landmark },
    { title: "Places", text: "Explore published cultural, practical and public places.", href: "/places", value: content.stats.places, icon: Compass },
    { title: "Organizations", text: "Find published public and community organizations.", href: "/organizations", value: content.stats.organizations, icon: Building2 },
    { title: "Journeys", text: "Follow connected routes through practical newcomer tasks.", href: "/journeys", value: null, icon: Route },
    { title: "Updates", text: "See the latest published additions and content changes.", href: "/updates", value: null, icon: Newspaper },
    { title: "Categories", text: "Browse the full catalogue by practical topic.", href: "/categories", value: content.stats.categories, icon: LayoutGrid }
  ] as const;

  return (
    <div id="top" className="marketing-page user-first-home">
      <a className="skip-link" href="#main-content">Skip to content</a>
      <SiteHeader />

      <main id="main-content">
        <section className="uf-hero section-shell" aria-labelledby="hero-title">
          <div className="uf-hero-copy">
            <p className="uf-eyebrow">Practical guidance for life in the Netherlands</p>
            <h1 id="hero-title">Find your next step in the Netherlands.</h1>
            <p className="uf-hero-summary">YouNew helps newcomers understand everyday tasks, find relevant local guidance and continue to the responsible official source.</p>
            <div className="uf-hero-actions">
              <Link className="button button-primary" href="/start">Find my next step <ArrowRight aria-hidden /></Link>
              <Link className="button button-outline" href="/search">Search guides <Search aria-hidden /></Link>
            </div>
            <p className="uf-trust-line"><ShieldCheck aria-hidden /> Source links visible <span aria-hidden>·</span> Published content snapshot checked <time dateTime={statusSnapshot.content.asOf}>{checkedDate}</time></p>
          </div>
          <HomeRouteVisual />
        </section>

        <section className="uf-section uf-popular section-shell" aria-labelledby="popular-title">
          <div className="uf-section-heading">
            <p className="uf-eyebrow">Popular tasks</p>
            <h2 id="popular-title">Start with what you need to do.</h2>
          </div>
          <div className="uf-task-grid">
            {popularTasks.map((task) => (
              <Link className={task.urgent ? "uf-task-card is-safety" : "uf-task-card"} href={task.href} key={task.title}>
                <span>{task.label}</span>
                <h3>{task.title}</h3>
                <p>{task.text}</p>
                <strong>Open guidance <ArrowRight aria-hidden /></strong>
              </Link>
            ))}
          </div>
        </section>

        <section className="uf-section uf-discover-section" aria-labelledby="discover-title">
          <div className="section-shell">
            <div className="uf-section-heading uf-discover-heading">
              <div>
                <p className="uf-eyebrow">Discover the Netherlands</p>
                <h2 id="discover-title">See more than the next task.</h2>
              </div>
              <div>
                <p>Explore verified city imagery and continue to the wider catalogue of places, organizations and local context.</p>
                <Link href="/discover">Open Discover <ArrowRight aria-hidden /></Link>
              </div>
            </div>
            <div className="uf-discover-gallery">
              {galleryCities.map((city, index) => {
                const media = preferredMedia(city.images, ["gallery", "hero", "thumbnail"]);
                if (!media) return null;
                return (
                  <article className={index === 0 ? "uf-discover-card is-featured" : "uf-discover-card"} key={city.id}>
                    <ContentMedia asset={media} variant="gallery" />
                    <div>
                      <span>City guide</span>
                      <h3><Link href={city.route}>{city.title}</Link></h3>
                      <p>{city.summary}</p>
                      <Link href={city.route} aria-label={`Explore ${city.title}`}>Explore <ArrowRight aria-hidden /></Link>
                    </div>
                  </article>
                );
              })}
            </div>
          </div>
        </section>

        <section className="uf-section uf-profile-section" aria-labelledby="profile-title">
          <div className="section-shell">
            <div className="uf-section-heading">
              <p className="uf-eyebrow">Choose your situation</p>
              <h2 id="profile-title">See a more relevant starting point.</h2>
              <p>Your choice changes the suggested links below. It does not hide other published material.</p>
            </div>
            <HomepageProfileSelector />
          </div>
        </section>

        <section className="uf-section section-shell uf-how" aria-labelledby="how-title">
          <div className="uf-section-heading">
            <p className="uf-eyebrow">How YouNew works</p>
            <h2 id="how-title">From a question to a responsible source.</h2>
          </div>
          <ol className="uf-steps">
            <li><span>1</span><div><h3>Choose what you need help with.</h3><p>Start with one task and add your situation and area.</p></div></li>
            <li><span>2</span><div><h3>Review the available guidance.</h3><p>YouNew shows published information without inventing missing steps.</p></div></li>
            <li><span>3</span><div><h3>Verify the latest details.</h3><p>Continue to the responsible institution before you act.</p></div></li>
          </ol>
          <article className="uf-example">
            <div>
              <span>Example · First registration in Amsterdam</span>
              <h3>Prepare for a BSN registration appointment.</h3>
              <p>Understand what registration is, review the published preparation summary and confirm the current documents with the municipality.</p>
              <Link href="/guides/first-registration-in-amsterdam">Open the published summary <ArrowRight aria-hidden /></Link>
            </div>
            <div className="uf-example-source">
              <ShieldCheck aria-hidden />
              <p><strong>Responsible source</strong> Government.nl explains what a citizen service number is.</p>
              <TrackedOfficialSourceLink contentId="home.bsn-government" href="https://www.government.nl/topics/personal-data/question-and-answer/what-is-a-citizen-service-number-bsn" rel="noreferrer" target="_blank">Open the official source <ExternalLink aria-hidden /></TrackedOfficialSourceLink>
            </div>
          </article>
        </section>

        <section className="uf-section uf-netherlands-section" aria-labelledby="netherlands-title">
          <div className="section-shell">
            <div className="uf-section-heading">
              <p className="uf-eyebrow">Across the Netherlands</p>
              <h2 id="netherlands-title">Cities, provinces, places and organizations.</h2>
              <p>Use the national directory when your question is broader than one guide or one city.</p>
            </div>
            <div className="uf-netherlands-directory">
              {netherlandsDirectory.map((item) => {
                const Icon = item.icon;
                return (
                  <Link href={item.href} className="uf-directory-card" key={item.title}>
                    <Icon aria-hidden />
                    <span>{item.value === null ? "Explore" : item.value.toLocaleString("en-GB")}</span>
                    <h3>{item.title}</h3>
                    <p>{item.text}</p>
                    <strong>Open directory <ArrowRight aria-hidden /></strong>
                  </Link>
                );
              })}
            </div>
          </div>
        </section>

        <section className="uf-section uf-product-section" aria-labelledby="product-title">
          <div className="section-shell">
            <div className="uf-section-heading">
              <p className="uf-eyebrow">Website and iPhone app</p>
              <h2 id="product-title">Use the format that fits the moment.</h2>
              <p>The website works without installation. The iPhone app is a separate experience with its own current features and release cycle.</p>
            </div>
            <div className="uf-product-grid">
              <article className="uf-product-card">
                <BookOpen aria-hidden />
                <h3>On the website</h3>
                <ul>
                  <li>Search published guidance</li>
                  <li>Open responsible source links</li>
                  <li>Browse cities, places and organizations</li>
                  <li>Save shortcuts in this browser</li>
                  <li>Works without installation</li>
                </ul>
                <Link href="/search">Search the website <ArrowRight aria-hidden /></Link>
              </article>
              <figure className="uf-app-preview">
                <Image src="/images/app-home-nl.webp" alt="Current YouNew iPhone home screen in Dutch showing Leiden, search, emergency help, next actions and categories" width={437} height={946} loading="lazy" sizes="(max-width: 760px) 62vw, 260px" />
                <figcaption>Current app preview: Leiden local context. Detailed web city guides are listed below.</figcaption>
              </figure>
              <article className="uf-product-card">
                <Smartphone aria-hidden />
                <h3>In the iPhone app</h3>
                <ul>
                  <li>Personal starting view</li>
                  <li>Saved materials</li>
                  <li>Map and city context</li>
                  <li>Quick access to next actions</li>
                  <li>Assistant or labelled local guide mode</li>
                </ul>
                <p>App Store listing available · iOS 17.6 or later</p>
                <Link href="/app">Check app availability <ArrowRight aria-hidden /></Link>
              </article>
            </div>
          </div>
        </section>

        <section className="uf-section section-shell uf-coverage" aria-labelledby="coverage-title">
          <div className="uf-coverage-copy">
            <p className="uf-eyebrow">Current coverage</p>
            <h2 id="coverage-title">City coverage for five Dutch cities.</h2>
            <p>YouNew currently focuses its detailed city pages on Amsterdam, Rotterdam, Den Haag, Utrecht and Eindhoven. Other municipalities remain available through the directory, with national guidance where published.</p>
            <div className="uf-coverage-actions">
              <Link href="/cities">View city guidance <ArrowRight aria-hidden /></Link>
              <Link href="/municipalities">Find a municipality <ArrowRight aria-hidden /></Link>
            </div>
          </div>
          <nav className="uf-city-list" aria-label="Published city guides">
            {cities.map((city) => <Link href={`/cities/${city.toLowerCase().replaceAll(" ", "-")}`} key={city}><MapPinned aria-hidden /><span>{city}</span><ArrowRight aria-hidden /></Link>)}
          </nav>
        </section>

        <section className="uf-section uf-business-section" aria-labelledby="business-title">
          <div className="section-shell uf-business-layout">
            <div className="uf-business-copy">
              <p className="uf-eyebrow">Business on YouNew</p>
              <h2 id="business-title">A reviewed route for relevant local organizations.</h2>
              <p>Organizations can propose advertising or partnership ideas. Submission does not create a public placement: identity, destination, relevance and campaign dates must be checked before activation.</p>
              <div className="uf-business-actions">
                <Link className="button button-primary" href="/business">Business overview <ArrowRight aria-hidden /></Link>
                <Link className="button button-outline" href="/business/advertise">Advertising standards <ArrowRight aria-hidden /></Link>
              </div>
            </div>
            <aside className="uf-business-status" aria-label="Current advertising status">
              <div className="uf-business-status-label"><Megaphone aria-hidden /><span>Current public status</span></div>
              <strong>0</strong>
              <h3>live public campaigns</h3>
              <p>{SPONSORED_PLACEMENTS_ENABLED ? "Eligible reviewed campaigns may be delivered." : "Sponsored placements are off."} {advertisingSurfaceCatalog.length} surfaces are defined as reserved, not live.</p>
              <ul>
                <li><ShieldCheck aria-hidden /> Never shown in emergency guidance</li>
                <li><ShieldCheck aria-hidden /> Never replaces responsible official sources</li>
                <li><ShieldCheck aria-hidden /> Never changes organic search ranking</li>
              </ul>
              <Link href="/business/apply">Start a reviewed inquiry <Waypoints aria-hidden /></Link>
            </aside>
          </div>
        </section>

        <section className="uf-section uf-trust-section" aria-labelledby="trust-title">
          <div className="section-shell uf-trust-grid">
            <div>
              <p className="uf-eyebrow">Trust and sources</p>
              <h2 id="trust-title">Guidance is not an official decision.</h2>
            </div>
            <div>
              <p>YouNew explains published information and keeps source links visible. Rules can change, so check important details with the responsible institution.</p>
              <p><CheckCircle2 aria-hidden /> Published content snapshot checked <time dateTime={statusSnapshot.content.asOf}>{checkedDate}</time>.</p>
              <div className="uf-trust-actions">
                <Link href="/status">Read the verification method <ArrowRight aria-hidden /></Link>
                <a href={`mailto:${links.contactEmail}?subject=Incorrect%20website%20information`}>Report incorrect information <ArrowRight aria-hidden /></a>
              </div>
            </div>
          </div>
        </section>

        <section className="uf-final" aria-labelledby="final-title">
          <div className="section-shell">
            <Landmark aria-hidden />
            <h2 id="final-title">Start with the question in front of you.</h2>
            <p>Build a route from the guidance that is published now, or search the catalogue directly.</p>
            <div>
              <Link className="button button-primary" href="/start">Find my next step <ArrowRight aria-hidden /></Link>
              <Link className="button button-outline" href="/search">Search guides <Search aria-hidden /></Link>
            </div>
          </div>
        </section>
      </main>
      <SiteFooter />
    </div>
  );
}
