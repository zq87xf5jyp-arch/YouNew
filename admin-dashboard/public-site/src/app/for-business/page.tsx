import Link from "next/link";
import { ArrowRight, BadgeCheck, Building2, FileCheck2, MapPin, ShieldCheck, Users } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "YouNew for business",
  "Add or claim a reviewed local-business profile, or explore a focused 90-day employee-onboarding pilot for international teams in the Netherlands.",
  "/for-business"
);

export default function ForBusinessPage() {
  return (
    <PageShell className="business-page pilot-offer-page">
      <section className="pilot-hero section-shell">
        <div className="pilot-hero-copy">
          <Breadcrumbs items={[{ label: "For business" }]} />
          <p className="section-label orange">For local businesses, employers and relocation teams</p>
          <h1>Build a useful, trusted presence for newcomers.</h1>
          <p className="pilot-lead">Choose a reviewed local-business profile or a focused employee-onboarding pilot. Commercial activity never buys official status or organic ranking.</p>
          <div className="hero-actions">
            <Link className="button button-primary" href="/for-business/local">Add or claim a business <ArrowRight aria-hidden /></Link>
            <Link className="button button-outline" href="/for-business/pilot">Explore employee pilot</Link>
          </div>
          <p className="pilot-trust-note"><ShieldCheck aria-hidden />YouNew provides practical navigation, not individual legal, medical or tax advice. Critical guidance links to responsible sources and shows its source-check status.</p>
        </div>
        <aside className="business-route-card" aria-label="Choose a YouNew business route">
          <span>Choose your route</span>
          <Link href="/for-business/local">
            <BadgeCheck aria-hidden />
            <span><strong>Local business profile</strong><small>Free reviewed request · add or claim</small></span>
            <ArrowRight aria-hidden />
          </Link>
          <Link href="/for-business/pilot">
            <Users aria-hidden />
            <span><strong>Employee onboarding</strong><small>90-day pilot · €1,500 excl. VAT</small></span>
            <ArrowRight aria-hidden />
          </Link>
          <p>Submission starts a review. Nothing is published or purchased automatically.</p>
        </aside>
      </section>

      <section className="business-section section-shell" aria-labelledby="business-routes">
        <div className="section-intro"><p className="section-label cyan">Two clear starting points</p><h2 id="business-routes">Choose the outcome you need today.</h2></div>
        <div className="business-route-grid">
          <article><BadgeCheck aria-hidden /><div><h3>Be found as a local business</h3><p>Request a new profile or claim an existing page. The first reviewed profile request is free; paid tiers remain unavailable until their tools exist.</p><Link href="/for-business/local">Review local-business options <ArrowRight aria-hidden /></Link></div></article>
          <article><Users aria-hidden /><div><h3>Support international employees</h3><p>Give a team one source-dated hub for recurring registration, healthcare, housing, work and daily-life questions.</p><Link href="/for-business/pilot">Review the 90-day pilot <ArrowRight aria-hidden /></Link></div></article>
        </div>
      </section>

      <section className="business-section section-shell" aria-labelledby="pilot-problem">
        <div className="section-intro"><p className="section-label cyan">Employee onboarding pilot</p><h2 id="pilot-problem">One maintained hub for recurring employee questions</h2><p>The pilot is designed for teams that repeatedly explain the same practical steps after an international employee arrives in the Netherlands.</p></div>
        <div className="business-card-grid pilot-card-grid">
          <article><Building2 aria-hidden /><h3>For employers</h3><p>Give new international hires a consistent starting point alongside your existing people and relocation processes.</p></article>
          <article><MapPin aria-hidden /><h3>Location-aware</h3><p>Scope the first version to one selected Dutch city or region instead of promising nationwide customization.</p></article>
          <article><FileCheck2 aria-hidden /><h3>Source-dated routes</h3><p>Each critical route links to official information and shows when the guidance was last verified.</p></article>
          <article><ShieldCheck aria-hidden /><h3>Privacy boundary</h3><p>Usage analytics require consent and the pilot does not ask for employee case files or sensitive personal data.</p></article>
        </div>
      </section>

      <section className="business-section section-shell pilot-final-cta" aria-labelledby="pilot-next-step">
        <div><p className="section-label orange">Choose a next step</p><h2 id="pilot-next-step">Start with one measurable need.</h2><p>Local businesses can request a free profile review. Employers can validate the onboarding need through the fixed-scope pilot.</p></div>
        <div className="hero-actions"><Link className="button button-primary" href="/for-business/local/apply">Add or claim a business <ArrowRight aria-hidden /></Link><Link className="button button-outline" href="/partners/apply">Request employee pilot</Link></div>
      </section>
    </PageShell>
  );
}
