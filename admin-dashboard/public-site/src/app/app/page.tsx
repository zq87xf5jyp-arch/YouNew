import Link from "next/link";
import Image from "next/image";
import { ArrowRight, BookOpen, CheckCircle2, Download, MapPinned, Search, ShieldCheck, Smartphone } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";
import { appStore } from "@/lib/site-config";

export const metadata = metadataForPage("Download YouNew for iPhone", "Download YouNew from the App Store for practical guidance about life in the Netherlands.", "/app");

export default function AppPage() {
  return (
    <PageShell>
      <section className="app-hero section-shell app-download-hero">
        <div>
          <Breadcrumbs items={[{ label: "App" }]} />
          <Smartphone aria-hidden className="hero-line-icon" />
          <h1>YouNew on iPhone</h1>
          <p>YouNew is available free on the App Store for iPhone and iPad. Download the app for practical guidance, Dutch cities, services, healthcare, housing and everyday life in the Netherlands.</p>
          <div className="hero-actions">
            <a className="button button-primary" href={appStore.url} rel="noreferrer" target="_blank">
              <Download aria-hidden /> {appStore.label}
            </a>
            <Link className="button button-outline" href="/discover">Use the web guide <ArrowRight aria-hidden /></Link>
          </div>
          <p className="availability-note"><CheckCircle2 aria-hidden /> Version {appStore.version} · Free download · {appStore.minimumOS}</p>
        </div>
        <div className="device-frame app-page-device">
          <Image src="/images/app-home-nl.webp" alt="Current YouNew iPhone home screen in Dutch" width={437} height={946} priority sizes="(max-width: 760px) 72vw, 330px" />
        </div>
      </section>
      <section className="section-shell app-ecosystem" aria-labelledby="app-ecosystem-title">
        <div className="listing-heading"><div><span>One YouNew ecosystem</span><h2 id="app-ecosystem-title">Choose the experience that fits the moment</h2></div></div>
        <div className="information-grid">
          <article><Smartphone aria-hidden /><h3>Use the iPhone app</h3><p>Keep YouNew on your device for city guidance, places, maps, saved items and the app’s emergency route.</p><a href={appStore.url} rel="noreferrer" target="_blank">Open App Store <ArrowRight aria-hidden /></a></article>
          <article><BookOpen aria-hidden /><h3>Continue on the web</h3><p>Browse released guides, organizations and places without installing anything. Every detail page keeps its responsible source visible.</p><Link href="/discover">Open the web guide <ArrowRight aria-hidden /></Link></article>
          <article><ShieldCheck aria-hidden /><h3>Verify before acting</h3><p>YouNew shows publication status and source dates, then links to the responsible institution or provider for current details.</p><Link href="/status">View service status <ArrowRight aria-hidden /></Link></article>
        </div>
      </section>
      <section className="section-shell app-details-section" aria-labelledby="app-details-title">
        <div>
          <span className="section-label">Available now</span>
          <h2 id="app-details-title">A practical companion for the Netherlands</h2>
          <p>The current app provides a Dutch interface for exploring guidance, places and city context. The website adds an English reviewed route to the same published YouNew ecosystem.</p>
          <ul className="app-capability-list">
            <li><Search aria-hidden /><span><strong>Find relevant information</strong>Search guides, services and places by the need in front of you.</span></li>
            <li><MapPinned aria-hidden /><span><strong>Explore published locations</strong>Move from city context to places and map-based coverage.</span></li>
            <li><ShieldCheck aria-hidden /><span><strong>Keep the source trail</strong>Use YouNew for orientation, then verify changing requirements with the responsible source.</span></li>
          </ul>
        </div>
        <aside className="app-release-card" aria-label="Current YouNew App Store release">
          <h3>Current App Store release</h3>
          <dl>
            <div><dt>Version</dt><dd>{appStore.version}</dd></div>
            <div><dt>Price</dt><dd>Free</dd></div>
            <div><dt>Requires</dt><dd>{appStore.minimumOS}</dd></div>
            <div><dt>App Store ID</dt><dd>{appStore.id}</dd></div>
          </dl>
          <a className="button button-primary" href={appStore.url} rel="noreferrer" target="_blank"><Download aria-hidden /> {appStore.label}</a>
          <p>Saved items on the website currently stay in this browser and do not yet synchronize with the iOS app.</p>
        </aside>
      </section>
      <section className="section-shell app-final-cta" aria-labelledby="app-final-title">
        <h2 id="app-final-title">Start in the app or continue in your browser</h2>
        <p>Both routes keep the next useful YouNew destination close, while official sources remain the final reference for changing procedures and availability.</p>
        <div className="hero-actions">
          <a className="button button-primary" href={appStore.url} rel="noreferrer" target="_blank"><Download aria-hidden /> Download the app</a>
          <Link className="button button-outline" href="/search">Search the website <ArrowRight aria-hidden /></Link>
        </div>
      </section>
    </PageShell>
  );
}
