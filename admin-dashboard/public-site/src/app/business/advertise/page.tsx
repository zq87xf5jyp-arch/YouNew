import Link from "next/link";
import { BadgeEuro, ExternalLink, LayoutTemplate, MapPin, Megaphone, ShieldCheck, XCircle } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import {
  advertisingExcludedSurfaces,
  advertisingFormatCatalog,
  advertisingFormatLabel,
  advertisingSurfaceCatalog
} from "@/lib/business/catalog";
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
        <div className="advertising-inventory-status" aria-label="Current advertising inventory status">
          <div><strong>{advertisingSurfaceCatalog.length}</strong><span>defined placement surfaces</span></div>
          <div><strong>{advertisingFormatCatalog.length}</strong><span>reviewable formats</span></div>
          <div><strong>0</strong><span>live public campaigns</span></div>
        </div>
      </section>

      <section className="business-section section-shell" aria-labelledby="advertising-surfaces">
        <div className="section-intro"><p className="section-label cyan">Placement directory</p><h2 id="advertising-surfaces">Where advertising can appear</h2><p>Each position below is a reserved integration point, not currently available inventory. Sponsored content remains outside organic ranking, official-source cards and map markers.</p></div>
        <div className="advertising-surface-list">
          {advertisingSurfaceCatalog.map((surface, index) => (
            <article key={surface.id} data-ad-surface-preview={surface.id}>
              <div className="advertising-surface-wireframe" aria-hidden>
                <span className="wireframe-header" />
                <span className="wireframe-content" />
                <span className="wireframe-sponsored">Sponsored position</span>
                <span className="wireframe-content short" />
              </div>
              <div className="advertising-surface-number">{String(index + 1).padStart(2, "0")}</div>
              <div className="advertising-surface-copy">
                <div><span>{surface.routePattern}</span><strong>{surface.title}</strong></div>
                <p>{surface.position}</p>
                <small>{surface.rationale}</small>
                <ul aria-label={`Supported formats for ${surface.title}`}>
                  {surface.formatIds.map((formatId) => <li key={formatId}>{advertisingFormatLabel(formatId)}</li>)}
                </ul>
              </div>
              <span className="advertising-surface-state">Reserved · not live</span>
            </article>
          ))}
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
          <article><LayoutTemplate aria-hidden /><h3>Stable placement contract</h3><p>Every approved campaign must reference one defined surface ID and an allowed format.</p></article>
        </div>
        <div className="advertising-exclusions" aria-labelledby="advertising-exclusions-title">
          <h3 id="advertising-exclusions-title"><XCircle aria-hidden /> Advertising is excluded from</h3>
          {advertisingExcludedSurfaces.map((surface) => <div key={surface.routePattern}><strong>{surface.routePattern}</strong><p>{surface.reason}</p></div>)}
        </div>
        <p className="business-source-links">Review current <Link href="/cities">cities</Link> and <Link href="/categories">categories</Link>, or <a href="mailto:support@younew.nl">ask support@younew.nl <ExternalLink aria-hidden /></a> about a relevant proposal.</p>
      </section>
    </PageShell>
  );
}
