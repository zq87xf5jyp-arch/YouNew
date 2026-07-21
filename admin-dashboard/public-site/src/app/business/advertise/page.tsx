import Link from "next/link";
import { BadgeEuro, ExternalLink, MapPin, Megaphone, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { advertisingFormatCatalog } from "@/lib/business/catalog";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Advertise with YouNew", "Request a clearly labelled, relevant advertising placement on YouNew without compromising editorial guidance.", "/business/advertise");

export default function AdvertisePage() {
  return (
    <PageShell className="business-page">
      <section className="business-hero section-shell">
        <Breadcrumbs items={[{ label: "Business", href: "/business" }, { label: "Advertise" }]} />
        <p className="section-label orange">Advertising</p>
        <h1>Promotion people can recognize</h1>
        <p>Commercial formats are considered through a manual inquiry and review. Every paid placement must identify the advertiser and use an explicit sponsored label.</p>
        <div className="hero-actions">
          <Link className="button button-primary" href="/business/apply">Request a placement</Link>
          <Link className="button button-outline" href="/business/pricing">Request-quote policy</Link>
        </div>
      </section>

      <section className="business-section section-shell" aria-labelledby="advertising-formats">
        <div className="section-intro"><p className="section-label cyan">Formats for discussion</p><h2 id="advertising-formats">Choose a relevant context</h2><p>These formats describe what can be discussed; they are not a promise that inventory is currently available in every city, province, category or profile.</p></div>
        <div className="business-format-list">
          {advertisingFormatCatalog.map((format) => <article key={format.id}><Megaphone aria-hidden /><div><h3>{format.title}</h3><p>{format.description}</p></div></article>)}
        </div>
        <aside className="business-future-note"><strong>Future only:</strong> Newsletter placement is not currently offered because a YouNew newsletter has not been verified as live.</aside>
      </section>

      <section className="business-section business-boundaries section-shell" aria-labelledby="advertising-boundaries">
        <div className="section-intro"><p className="section-label orange">Placement rules</p><h2 id="advertising-boundaries">Editorial and sponsored stay separate</h2></div>
        <div className="business-card-grid">
          <article><ShieldCheck aria-hidden /><h3>No disguised advertising</h3><p>Promotions cannot look like a government recommendation, organic search result or product control.</p></article>
          <article><MapPin aria-hidden /><h3>Published coverage only</h3><p>Location and topic targeting is limited to suitable coverage that exists in YouNew.</p></article>
          <article><BadgeEuro aria-hidden /><h3>No purchased authority</h3><p>Payment cannot change editorial guidance, official-source badges or emergency instructions.</p></article>
        </div>
        <p className="business-source-links">Review current <Link href="/cities">cities</Link> and <Link href="/categories">categories</Link>, or <a href="mailto:support@younew.nl">ask support@younew.nl <ExternalLink aria-hidden /></a> about a relevant proposal.</p>
      </section>
    </PageShell>
  );
}
