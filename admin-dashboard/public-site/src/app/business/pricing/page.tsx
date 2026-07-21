import Link from "next/link";
import { CalendarDays, Layers3, MapPinned, ReceiptText, Target } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Business pricing", "YouNew advertising and partnership pricing is currently handled by request for quote; no fixed public tariff is approved.", "/business/pricing");

export default function PricingPage() {
  return (
    <PageShell className="business-page">
      <section className="business-hero section-shell">
        <Breadcrumbs items={[{ label: "Business", href: "/business" }, { label: "Pricing" }]} />
        <p className="section-label orange">Request a quote</p>
        <h1>Scope first, price second</h1>
        <p>YouNew does not publish fixed advertising prices because no public tariff has been approved. A quote can be prepared only after the format, relevance, coverage, dates, creative work and reporting scope are understood.</p>
        <div className="hero-actions"><Link className="button button-primary" href="/business/apply">Request a quote</Link><a className="button button-outline" href="mailto:support@younew.nl">support@younew.nl</a></div>
      </section>

      <section className="business-section section-shell" aria-labelledby="quote-factors">
        <div className="section-intro"><p className="section-label cyan">Quote factors</p><h2 id="quote-factors">What shapes a proposal</h2></div>
        <div className="business-card-grid">
          <article><Layers3 aria-hidden /><h3>Format</h3><p>Listing, offer, banner, city/category placement or a reviewed content partnership.</p></article>
          <article><MapPinned aria-hidden /><h3>Coverage</h3><p>The eligible cities, provinces, categories and profiles included in the requested scope.</p></article>
          <article><CalendarDays aria-hidden /><h3>Campaign period</h3><p>Proposed start and end dates, availability and any time-sensitive offer terms.</p></article>
          <article><Target aria-hidden /><h3>Work and measurement</h3><p>Creative preparation, review effort, destination setup and an honestly supportable reporting scope.</p></article>
        </div>
      </section>

      <section className="business-section section-shell" aria-labelledby="pricing-current-state">
        <div className="section-intro"><p className="section-label orange">Current state</p><h2 id="pricing-current-state">No instant checkout or billing portal</h2></div>
        <div className="business-pricing-note">
          <ReceiptText aria-hidden />
          <div>
            <p>Submitting an inquiry does not purchase inventory, reserve dates or create a contract. There is currently no public self-service billing, invoicing or campaign dashboard.</p>
            <p>If a proposal is suitable, commercial terms, deliverables, privacy responsibilities, reporting limits and payment arrangements must be agreed directly in writing.</p>
          </div>
        </div>
      </section>
    </PageShell>
  );
}
