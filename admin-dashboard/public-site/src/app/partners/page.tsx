import Link from "next/link";
import { ArrowRight, BadgeCheck, Eye, Scale, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "YouNew partners",
  "How YouNew labels partnerships and protects factual guidance, emergency information and editorial conclusions.",
  "/partners"
);

export default function PartnersPage() {
  return (
    <PageShell className="business-page pilot-offer-page">
      <section className="business-hero section-shell">
        <Breadcrumbs items={[{ label: "Partners" }]} />
        <p className="section-label orange">Partnership principles</p>
        <h1>Useful partners, clearly identified.</h1>
        <p>Paid placement never changes YouNew’s factual guidance, emergency information or editorial conclusions. Partnerships and sponsored content are always labelled.</p>
        <div className="hero-actions"><Link className="button button-primary" href="/partners/apply">Request a pilot <ArrowRight aria-hidden /></Link><Link className="button button-outline" href="/for-business">For employers and relocation teams</Link></div>
      </section>

      <section className="business-section section-shell" aria-labelledby="partner-boundaries">
        <div className="section-intro"><p className="section-label cyan">Trust boundaries</p><h2 id="partner-boundaries">Commercial relationships stay separate from practical guidance.</h2></div>
        <div className="business-card-grid pilot-card-grid">
          <article><BadgeCheck aria-hidden /><h3>Identity review</h3><p>Organization identity, public website and relevant professional details must be verifiable before a commercial relationship is considered.</p></article>
          <article><Eye aria-hidden /><h3>Visible labels</h3><p>Sponsored and paid relationships are identified in language users can see and understand.</p></article>
          <article><Scale aria-hidden /><h3>Editorial independence</h3><p>Payment cannot suppress critical information, buy an editorial conclusion or influence emergency ordering.</p></article>
          <article><ShieldCheck aria-hidden /><h3>User safety</h3><p>Privacy, accessibility, claims and destination links remain subject to review and may be refused.</p></article>
        </div>
        <aside className="business-truth-note"><ShieldCheck aria-hidden /><div><strong>Current priority</strong><p>The 90-day employee onboarding pilot is the primary commercial offer. Founding Partner Page and Sponsored Practical Guide remain draft concepts until the pilot is validated.</p></div></aside>
      </section>
    </PageShell>
  );
}
