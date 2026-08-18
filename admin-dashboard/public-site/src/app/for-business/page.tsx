import Link from "next/link";
import { ArrowRight, Building2, FileCheck2, MapPin, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Employee onboarding for international teams",
  "A focused 90-day YouNew pilot for employers and relocation teams onboarding international employees in the Netherlands.",
  "/for-business"
);

export default function ForBusinessPage() {
  return (
    <PageShell className="business-page pilot-offer-page">
      <section className="pilot-hero section-shell">
        <div className="pilot-hero-copy">
          <Breadcrumbs items={[{ label: "For business" }]} />
          <p className="section-label orange">For employers and relocation teams</p>
          <h1>Give international employees one clear place to start in the Netherlands.</h1>
          <p className="pilot-lead">YouNew turns verified public information about registration, healthcare, housing, work and daily life into practical, location-aware steps.</p>
          <div className="hero-actions">
            <Link className="button button-primary" href="/for-business/pilot">Request a 90-day pilot <ArrowRight aria-hidden /></Link>
            <Link className="button button-outline" href="/for-business/demo-report">View sample report</Link>
          </div>
          <p className="pilot-trust-note"><ShieldCheck aria-hidden />YouNew provides practical navigation, not individual legal, medical or tax advice. Critical guidance links to official sources and displays its latest verification date.</p>
        </div>
        <aside className="pilot-offer-card" aria-label="Founding pilot summary">
          <span>90-day employee onboarding pilot</span>
          <strong>€1,500 <small>excl. VAT</small></strong>
          <p>Fixed scope confirmed before contract.</p>
          <dl>
            <div><dt>Routes</dt><dd>10 verified</dd></div>
            <div><dt>Coverage</dt><dd>1 city or region</dd></div>
            <div><dt>Reports</dt><dd>Summary + final</dd></div>
          </dl>
        </aside>
      </section>

      <section className="business-section section-shell" aria-labelledby="pilot-problem">
        <div className="section-intro"><p className="section-label cyan">A focused starting point</p><h2 id="pilot-problem">One maintained hub for recurring employee questions</h2><p>The pilot is designed for teams that repeatedly explain the same practical steps after an international employee arrives in the Netherlands.</p></div>
        <div className="business-card-grid pilot-card-grid">
          <article><Building2 aria-hidden /><h3>For employers</h3><p>Give new international hires a consistent starting point alongside your existing people and relocation processes.</p></article>
          <article><MapPin aria-hidden /><h3>Location-aware</h3><p>Scope the first version to one selected Dutch city or region instead of promising nationwide customization.</p></article>
          <article><FileCheck2 aria-hidden /><h3>Source-dated routes</h3><p>Each critical route links to official information and shows when the guidance was last verified.</p></article>
          <article><ShieldCheck aria-hidden /><h3>Privacy boundary</h3><p>Usage analytics require consent and the pilot does not ask for employee case files or sensitive personal data.</p></article>
        </div>
      </section>

      <section className="business-section section-shell pilot-final-cta" aria-labelledby="pilot-next-step">
        <div><p className="section-label orange">Founding pilot</p><h2 id="pilot-next-step">Start with a fixed scope, then validate the need.</h2><p>The first three accepted pilots use the approved founding price. Proposal, contract and manual invoice follow only after scope review.</p></div>
        <Link className="button button-primary" href="/partners/apply">Request a 90-day pilot <ArrowRight aria-hidden /></Link>
      </section>
    </PageShell>
  );
}
