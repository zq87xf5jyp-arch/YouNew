import Image from "next/image";
import Link from "next/link";
import {
  ArrowRight,
  BookOpen,
  Bookmark,
  Building2,
  CheckCircle2,
  CircleHelp,
  ExternalLink,
  GraduationCap,
  HeartHandshake,
  Landmark,
  MapPinned,
  MessageCircleMore,
  Plane,
  Search,
  ShieldCheck,
  Sparkles,
  Stethoscope,
  Users,
  Waypoints
} from "lucide-react";
import { SiteFooter } from "@/components/site-footer";
import { SiteHeader } from "@/components/site-header";
import { getPublicContent } from "@/lib/content";
import { links } from "@/lib/site-data";

const profiles = [
  { name: "Tourist", text: "Essentials for a short stay, transport and places.", icon: Plane },
  { name: "Student", text: "Arrival, registration, study and everyday life.", icon: GraduationCap },
  { name: "Expat", text: "Moving, work, housing and settling in.", icon: Building2 },
  { name: "Refugee", text: "A clearer start with relevant services and support.", icon: Users }
];

const capabilities = [
  { title: "Web search", text: "Search published guides, organizations and places with typo-friendly suggestions.", icon: Search },
  { title: "Source-backed guides", text: "Find released local starting points, then verify current procedures with the responsible source.", icon: BookOpen },
  { title: "Saved materials", text: "Keep useful guides and places ready for later.", icon: Bookmark },
  { title: "Source links", text: "Continue to the responsible institution when details matter.", icon: ShieldCheck }
];

const scenarios = [
  { title: "BSN registration", text: "Prepare for municipality registration.", icon: Landmark },
  { title: "Finding a GP", text: "Understand the usual route to primary care.", icon: Stethoscope },
  { title: "Student arrival", text: "Find relevant sources and local starting points after arrival.", icon: GraduationCap },
  { title: "Emergency help", text: "Find the right emergency information quickly.", icon: CircleHelp }
];

const faqs = [
  ["What is YouNew?", "YouNew is an iPhone guide that organises practical information, city context, places, saved materials and source links for life in the Netherlands."],
  ["Who is it for?", "It is designed for tourists, international students, expats, refugees and people who are new to the Netherlands."],
  ["Is the app available now?", "Public App Store and TestFlight access are not confirmed yet. Follow release updates or contact support to hear when a verified download channel is available."],
  ["How does the assistant work?", "The assistant uses YouNew’s curated knowledge to suggest practical next steps and related in-app guides. If live AI is unavailable, the app clearly labels its local guide mode."],
  ["How can I report incorrect information?", `Email ${links.contactEmail} with the page, the issue and—when possible—the official source that should be checked.`]
];

export default function HomePage() {
  const { stats } = getPublicContent();

  return (
    <div id="top" className="marketing-page">
      <a className="skip-link" href="#main-content">Skip to content</a>
      <SiteHeader />

      <main id="main-content">
        <section className="hero-section section-shell" aria-labelledby="hero-title" data-reveal>
          <div className="hero-copy">
            <p className="hero-kicker"><ShieldCheck aria-hidden /> Source-backed web companion for the Netherlands</p>
            <h1 id="hero-title">Your next step in the Netherlands, <span>made clearer.</span></h1>
            <p>YouNew brings practical guides, trusted source links, city context and personalised paths into one calm web guide—with the iPhone app alongside it.</p>
            <div className="hero-actions">
              <Link className="button button-primary" href="/discover">Use YouNew on the web <ArrowRight aria-hidden /></Link>
              <Link className="button button-ghost" href="/search"><Search aria-hidden /> Search published content</Link>
            </div>
            <dl className="hero-proof" aria-label="Current published web coverage">
              <div><dt>{stats.entities}</dt><dd>published records</dd></div>
              <div><dt>{stats.cities}</dt><dd>city guides</dd></div>
              <div><dt>{stats.categories}</dt><dd>published categories</dd></div>
            </dl>
            <p className="availability-note"><CheckCircle2 aria-hidden /> Web guide available now. The iPhone public download is not yet confirmed.</p>
          </div>
          <figure className="hero-product">
            <span className="hero-route-line" aria-hidden />
            <aside className="hero-float-card hero-float-source"><ShieldCheck aria-hidden /><span><strong>Source trail</strong>Responsible links stay visible.</span></aside>
            <div className="device-frame">
              <Image src="/images/app-home-nl.webp" alt="Current YouNew iPhone home screen in Dutch showing Leiden, search, emergency help, next actions and categories" width={437} height={946} priority sizes="(max-width: 760px) 76vw, 390px" />
            </div>
            <aside className="hero-float-card hero-float-web"><Waypoints aria-hidden /><span><strong>Web fallback</strong>Search, save and share in the browser.</span></aside>
            <figcaption>Current Dutch iPhone preview · English web companion available now</figcaption>
          </figure>
          <a className="hero-scroll-cue" href="#features"><span>Explore the web guide</span><ArrowRight aria-hidden /></a>
        </section>

        <section className="contrast-band" aria-labelledby="difference-title" data-reveal>
          <div className="section-shell difference-grid">
            <div>
              <p className="section-label orange">The challenge</p>
              <h2>Starting somewhere new comes with a lot to figure out.</h2>
              <p>Information is scattered, rules vary by situation and official language can be difficult to understand.</p>
            </div>
            <ArrowRight className="difference-arrow" aria-hidden />
            <div>
              <p className="section-label cyan">The YouNew approach</p>
              <h2 id="difference-title">More than a tourist guide. A practical companion.</h2>
              <p>YouNew connects context, clear explanations, local discovery and responsible source links in one place.</p>
            </div>
          </div>
        </section>

        <section id="features" className="section-shell section-block" aria-labelledby="features-title" data-reveal>
          <div className="section-intro">
            <h2 id="features-title">Useful now, without an install.</h2>
            <p>Start with the question in front of you, move from explanation to source, and save useful pages locally in your browser.</p>
          </div>
          <div className="capability-rail">
            {capabilities.map(({ title, text, icon: Icon }, index) => (
              <article className="capability" key={title}>
                <div className="icon-box"><Icon aria-hidden /></div>
                <div><span>0{index + 1}</span><h3>{title}</h3><p>{text}</p></div>
              </article>
            ))}
          </div>
        </section>

        <section id="profiles" className="profile-section section-block" aria-labelledby="profiles-title" data-reveal>
          <div className="section-shell profile-layout">
            <div className="section-intro sticky-intro">
              <p className="section-label orange">Personal paths</p>
              <h2 id="profiles-title">A path that starts with you.</h2>
              <p>Choose a profile and YouNew adapts recommendations to what matters most. All guides remain available.</p>
            </div>
            <div className="profile-list">
              {profiles.map(({ name, text, icon: Icon }, index) => (
                <Link className="profile-row" href={`/discover?profile=${name.toLowerCase()}`} key={name} aria-label={`Choose the ${name} starting path`}>
                  <span className="profile-number">0{index + 1}</span>
                  <Icon aria-hidden />
                  <div><h3>{name}</h3><p>{text}</p></div>
                  <ArrowRight aria-hidden />
                </Link>
              ))}
            </div>
          </div>
        </section>

        <section id="assistant" className="section-shell section-block split-section" aria-labelledby="assistant-title" data-reveal>
          <div className="section-intro assistant-copy">
            <p className="section-label cyan">AI Assistant</p>
            <h2 id="assistant-title">Ask for the next practical step.</h2>
            <p>The assistant uses YouNew’s curated knowledge and can point you to relevant in-app guidance. When live AI is unavailable, YouNew clearly labels its local guide mode.</p>
            <ul className="proof-list">
              <li><ShieldCheck aria-hidden /><span><strong>Curated context</strong> built around YouNew content</span></li>
              <li><Waypoints aria-hidden /><span><strong>Actionable guidance</strong> with related routes</span></li>
              <li><MessageCircleMore aria-hidden /><span><strong>Clear origin label</strong> instead of pretending fallback is live AI</span></li>
            </ul>
          </div>
          <aside className="assistant-demo" aria-labelledby="assistant-demo-title">
            <div className="demo-top"><span id="assistant-demo-title">Assistant example</span><span className="mode-label">Local guide mode</span></div>
            <div className="chat-question">How do I get a BSN?</div>
            <div className="chat-answer">
              <p>Register with the municipality where you live. Requirements differ, so check your gemeente’s appointment list before you go.</p>
              <ol><li>Book the correct appointment</li><li>Prepare identity and address documents</li><li>Open the related YouNew guide</li></ol>
            </div>
            <Link href="/guides" className="demo-action">Open published guides <ArrowRight aria-hidden /></Link>
            <p className="demo-disclaimer">Information only. Verify important details with the responsible institution.</p>
          </aside>
        </section>

        <section id="cities" className="map-section section-block" aria-labelledby="cities-title" data-reveal>
          <div className="section-shell map-layout">
            <div className="map-copy">
              <p className="section-label orange">Places</p>
              <h2 id="cities-title">Cities, provinces and useful places.</h2>
              <p>Explore local guidance and discover services around your selected city. The current app includes growing coverage across the Netherlands.</p>
              <nav className="city-list" aria-label="Published city guides"><Link href="/cities/amsterdam">Amsterdam</Link><Link href="/cities/rotterdam">Rotterdam</Link><Link href="/cities/den-haag">Den Haag</Link><Link href="/cities/utrecht">Utrecht</Link><Link href="/cities/eindhoven">Eindhoven</Link></nav>
            </div>
            <div className="map-product">
              <Image src="/images/app-map-en.webp" alt="Current YouNew iPhone map screen showing the Netherlands and Leiden" width={1206} height={2622} loading="lazy" sizes="(max-width: 760px) 76vw, 350px" />
            </div>
            <div className="place-types">
              <h3>Discover nearby</h3>
              <p><Landmark aria-hidden /><span><strong>Municipal services</strong>Appointments and documents</span></p>
              <p><Stethoscope aria-hidden /><span><strong>Healthcare</strong>GPs, hospitals and pharmacies</span></p>
              <p><MapPinned aria-hidden /><span><strong>Transport and places</strong>Useful local destinations</span></p>
              <p><HeartHandshake aria-hidden /><span><strong>Community and support</strong>Relevant local organisations</span></p>
            </div>
          </div>
        </section>

        <section id="how-it-works" className="section-shell section-block" aria-labelledby="steps-title" data-reveal>
          <div className="section-intro scenario-heading">
            <p className="section-label cyan">How it works</p>
            <h2 id="steps-title">From a question to a clear next step.</h2>
          </div>
          <ol className="steps-list">
            <li><span>1</span><div><h3>Choose your situation</h3><p>Pick what you need help with.</p></div></li>
            <li><span>2</span><div><h3>Review the guidance</h3><p>Read the available context and related next actions.</p></div></li>
            <li><span>3</span><div><h3>Open the official source</h3><p>Verify the latest information.</p></div></li>
          </ol>
          <div className="scenario-grid">
            {scenarios.map(({ title, text, icon: Icon }) => <article key={title}><Icon aria-hidden /><h3>{title}</h3><p>{text}</p></article>)}
          </div>
        </section>

        <section id="trust" className="trust-section section-block" aria-labelledby="trust-title" data-reveal>
          <div className="section-shell trust-layout">
            <div><p className="section-label orange">Our approach</p><h2 id="trust-title">Guidance with a source trail.</h2><p>YouNew organises clear explanations and links back to responsible institutions. Rules and procedures can change, so important information should always be verified.</p></div>
            <div className="source-panel">
              <h3>Example: registering for a BSN</h3>
              <div><span>Clear explanation</span><CheckCircle2 aria-hidden /></div>
              <div><span>Responsible source</span><CheckCircle2 aria-hidden /></div>
              <a href="https://www.government.nl/topics/personal-data/question-and-answer/what-is-a-citizen-service-number-bsn" rel="noreferrer" target="_blank">Government.nl source <ExternalLink aria-hidden /></a>
            </div>
          </div>
        </section>

        <section id="partners" className="section-shell partner-section section-block" aria-labelledby="partners-title" data-reveal>
          <div className="partner-visual" aria-hidden><Building2 /><Users /><HeartHandshake /></div>
          <div><p className="section-label cyan">Local communities</p><h2 id="partners-title">Built with local communities.</h2><p>Local organisations and businesses can help newcomers discover relevant services. Editorial guidance stays separate from clearly labelled future sponsored placements.</p><Link className="button button-outline" href="/business">Explore partnership options <ArrowRight aria-hidden /></Link></div>
        </section>

        <section id="faq" className="section-shell faq-section section-block" aria-labelledby="faq-title" data-reveal>
          <div className="section-intro"><p className="section-label orange">FAQ</p><h2 id="faq-title">Frequently asked questions.</h2></div>
          <div className="faq-list">
            {faqs.map(([question, answer], index) => <details key={question} open={index === 0}><summary>{question}<span aria-hidden>+</span></summary><p>{answer}</p></details>)}
          </div>
        </section>

        <section className="final-cta" aria-labelledby="cta-title">
          <div className="section-shell"><Sparkles aria-hidden /><h2 id="cta-title">Start with the web guide today.</h2><p>Search published content now, or follow verified iPhone release updates.</p><div><Link className="button button-primary" href="/discover">Open YouNew web <ArrowRight aria-hidden /></Link><Link className="button button-outline" href="/app">iPhone app status</Link></div></div>
        </section>
      </main>
      <SiteFooter />
    </div>
  );
}
