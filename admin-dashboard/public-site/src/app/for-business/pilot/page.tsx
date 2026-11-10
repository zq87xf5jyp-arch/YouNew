import Link from "next/link";
import { ArrowRight, Ban, BarChart3, Check, FileText, MapPin, RefreshCw, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "90-day employee onboarding pilot",
  "Review the fixed scope, safeguards, reporting and founding price for YouNew's employee onboarding pilot.",
  "/for-business/pilot"
);

const included = [
  "One branded onboarding hub",
  "10 verified practical routes",
  "One selected Dutch city or region",
  "Official sources and verification dates",
  "Consent-based usage analytics",
  "One summary report and one final report",
  "One client revision round",
  "90-day content-maintenance period"
];

const excluded = [
  "HRIS, SSO or custom enterprise integrations",
  "Individual legal, medical, immigration or tax advice",
  "Guaranteed employee outcomes",
  "Custom translations outside the approved scope"
];

export default function PilotPage() {
  return (
    <PageShell className="business-page pilot-offer-page">
      <section className="pilot-hero pilot-detail-hero section-shell">
        <div className="pilot-hero-copy">
          <Breadcrumbs items={[{ label: "For business", href: "/for-business" }, { label: "90-day pilot" }]} />
          <p className="section-label orange">YouNew 90-Day Employee Onboarding Pilot</p>
          <h1>A 90-day onboarding pilot built around real employee questions.</h1>
          <p className="pilot-lead">Launch a focused onboarding hub with 10 verified practical routes, one selected region and consent-based usage reporting.</p>
          <div className="pilot-price-line"><strong>Founding pilot — €1,500 excl. VAT</strong><span>Available for the first three accepted pilots. Final scope is confirmed before contract.</span></div>
          <div className="hero-actions"><Link className="button button-primary" href="/partners/apply">Request pilot <ArrowRight aria-hidden /></Link><Link className="button button-outline" href="/for-business/demo-report">View sample report</Link></div>
        </div>
        <aside className="pilot-process-card">
          <span>Commercial flow</span>
          <ol>
            <li><b>1</b><div><strong>Review fit</strong><p>Recurring questions, audience and region.</p></div></li>
            <li><b>2</b><div><strong>Confirm scope</strong><p>Proposal and contract before work starts.</p></div></li>
            <li><b>3</b><div><strong>Manual invoice</strong><p>No live checkout or card collection.</p></div></li>
          </ol>
        </aside>
      </section>

      <section className="business-section section-shell pilot-scope-grid" aria-label="Pilot scope">
        <article className="pilot-scope-panel">
          <div className="section-intro"><p className="section-label cyan">Included</p><h2>A deliberate first scope</h2></div>
          <ul>{included.map((item) => <li key={item}><Check aria-hidden />{item}</li>)}</ul>
        </article>
        <article className="pilot-scope-panel pilot-scope-panel-muted">
          <div className="section-intro"><p className="section-label orange">Excluded</p><h2>Clear delivery boundaries</h2></div>
          <ul>{excluded.map((item) => <li key={item}><Ban aria-hidden />{item}</li>)}</ul>
        </article>
      </section>

      <section className="business-section section-shell" aria-labelledby="pilot-delivery">
        <div className="section-intro"><p className="section-label cyan">Delivery</p><h2 id="pilot-delivery">What the 90 days produce</h2></div>
        <div className="business-card-grid pilot-card-grid">
          <article><MapPin aria-hidden /><h3>Focused hub</h3><p>A branded entry point for one agreed region and ten practical routes based on the client&apos;s recurring questions.</p></article>
          <article><FileText aria-hidden /><h3>Verified guidance</h3><p>Official-source links, latest verification dates and explicit review status for sensitive subject matter.</p></article>
          <article><BarChart3 aria-hidden /><h3>Bounded reporting</h3><p>A summary and final report based on consented usage, with no promise of employee outcomes or ROI.</p></article>
          <article><RefreshCw aria-hidden /><h3>Maintenance</h3><p>A 90-day content-maintenance period and one client revision round within the confirmed scope.</p></article>
        </div>
        <aside className="business-truth-note"><ShieldCheck aria-hidden /><div><strong>Advice boundary</strong><p>YouNew helps people navigate public information. It does not replace qualified legal, medical, immigration or tax professionals.</p></div></aside>
      </section>

      <section className="business-section section-shell pilot-final-cta" aria-labelledby="pilot-request-final">
        <div><p className="section-label orange">Next step</p><h2 id="pilot-request-final">Tell us what employees ask today.</h2><p>Submitting the form starts a fit review. It does not create a contract or payment obligation.</p></div>
        <Link className="button button-primary" href="/partners/apply">Request pilot <ArrowRight aria-hidden /></Link>
      </section>
    </PageShell>
  );
}
