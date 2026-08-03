import Image from "next/image";
import Link from "next/link";
import {
  ArrowRight,
  BookOpen,
  CheckCircle2,
  ExternalLink,
  Landmark,
  MapPinned,
  Search,
  ShieldCheck,
  Smartphone
} from "lucide-react";
import { HomepageProfileSelector } from "@/components/homepage-profile-selector";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { TrackedOfficialSourceLink } from "@/components/tracked-official-source-link";
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
