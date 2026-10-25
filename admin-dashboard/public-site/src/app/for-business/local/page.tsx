import Link from "next/link";
import { ArrowRight, BarChart3, Building2, Check, LockKeyhole, Megaphone, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Add or claim your business on YouNew",
  "Request a reviewed YouNew business profile for newcomers in the Netherlands. The basic profile request is free; paid local-business tiers are not yet for sale.",
  "/for-business/local"
);

const freeFeatures = [
  "Reviewed basic profile request",
  "Public address and contact details",
  "Source-backed service description",
  "Eligibility for organic search and directory discovery"
];

const businessFeatures = [
  "Expanded profile and additional media",
  "Consent-based interaction reporting",
  "Reviewed offers with visible terms",
  "Additional profile-management tools"
];

const premiumFeatures = [
  "Clearly labelled sponsored placements",
  "Campaign and content-partnership review",
  "Expanded bounded reporting",
  "Individually agreed integrations"
];

export default function LocalBusinessPage() {
  return (
    <PageShell className="business-page local-business-page">
      <section className="local-business-hero section-shell">
        <div>
          <Breadcrumbs items={[{ label: "For business", href: "/for-business" }, { label: "Local business" }]} />
          <p className="section-label orange">For local businesses and organizations</p>
          <h1>Help newcomers find and understand your business.</h1>
          <p>Request a new YouNew profile or claim an existing one. YouNew reviews identity, public claims, source links and location before any change is published.</p>
          <div className="hero-actions">
            <Link className="button button-primary" href="/for-business/local/apply">Add or claim your business <ArrowRight aria-hidden /></Link>
            <Link className="button button-outline" href="/organizations/">View published organizations</Link>
          </div>
          <p className="pilot-trust-note"><ShieldCheck aria-hidden />A request never buys organic ranking or official status. Emergency guidance and responsible official sources remain independent.</p>
        </div>
        <aside className="local-business-free-card" aria-label="Free profile request summary">
          <span>Available now</span>
          <strong>Free <small>reviewed profile request</small></strong>
          <ul>{freeFeatures.map((feature) => <li key={feature}><Check aria-hidden />{feature}</li>)}</ul>
          <p>Approval and publication are not automatic.</p>
        </aside>
      </section>

      <section className="business-section section-shell" aria-labelledby="local-business-tiers">
        <div className="section-intro">
          <p className="section-label cyan">Honest product ladder</p>
          <h2 id="local-business-tiers">Start free. Paid tiers stay unavailable until the tools exist.</h2>
          <p>YouNew can collect interest now without pretending that unfinished paid features are live.</p>
        </div>
        <div className="local-business-tier-grid">
          <article className="is-current">
            <span>Available now</span><Building2 aria-hidden /><h3>Free</h3><strong>€0</strong>
            <ul>{freeFeatures.map((feature) => <li key={feature}><Check aria-hidden />{feature}</li>)}</ul>
            <Link href="/for-business/local/apply">Request profile review <ArrowRight aria-hidden /></Link>
          </article>
          <article>
            <span>Planned · not for sale</span><BarChart3 aria-hidden /><h3>Business</h3><strong>Price not set</strong>
            <ul>{businessFeatures.map((feature) => <li key={feature}>{feature}</li>)}</ul>
            <p>Pricing will be tested only after profile editing and reporting are production-ready.</p>
          </article>
          <article>
            <span>Planned · not for sale</span><Megaphone aria-hidden /><h3>Premium</h3><strong>Individual scope</strong>
            <ul>{premiumFeatures.map((feature) => <li key={feature}>{feature}</li>)}</ul>
            <p>No campaign inventory, placement or reporting result is promised on this page.</p>
          </article>
        </div>
      </section>

      <section className="business-section section-shell" aria-labelledby="local-business-process">
        <div className="section-intro"><p className="section-label orange">Simple first process</p><h2 id="local-business-process">Three steps, with a human review before publication</h2></div>
        <ol className="business-steps">
          <li><span>1</span><div><h3>Send public business facts</h3><p>Choose add or claim, then provide the organization website, KvK number where required, location and services.</p></div></li>
          <li><span>2</span><div><h3>Identity and claim review</h3><p>YouNew checks that the contact can represent the organization and that public claims have support.</p></div></li>
          <li><span>3</span><div><h3>Approve before publishing</h3><p>Only reviewed information can enter the public catalogue. No payment changes organic ordering.</p></div></li>
        </ol>
        <aside className="business-truth-note"><LockKeyhole aria-hidden /><div><strong>Private contact details stay out of public profiles.</strong><p>The inquiry endpoint stores contact data for review; public pages use only approved business facts.</p></div></aside>
      </section>

      <section className="business-section section-shell pilot-final-cta" aria-labelledby="local-business-final-cta">
        <div><p className="section-label cyan">Free first step</p><h2 id="local-business-final-cta">Request a profile review.</h2><p>Submitting creates a review request only. It does not publish a page, verify ownership, start a paid plan or create a contract.</p></div>
        <Link className="button button-primary" href="/for-business/local/apply">Add or claim your business <ArrowRight aria-hidden /></Link>
      </section>
    </PageShell>
  );
}
