import Link from "next/link";
import { ArrowRight, BadgeCheck, Building2, Megaphone, ShieldCheck, Users } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Business and partnerships", "Explore clearly labelled advertising and partnership opportunities with YouNew in the Netherlands.", "/business");

export default function BusinessPage() {
  return (
    <PageShell className="business-page">
      <section className="business-hero section-shell">
        <Breadcrumbs items={[{ label: "Business" }]} />
        <p className="section-label orange">YouNew for organizations</p>
        <h1>Useful local visibility, with trust kept intact</h1>
        <p>YouNew helps tourists, students, expats, refugees and new residents find practical information in the Netherlands. We welcome inquiries from relevant organizations and local businesses without blurring the line between editorial guidance and paid placement.</p>
        <div className="hero-actions">
          <Link className="button button-primary" href="/business/apply">Start an inquiry <ArrowRight aria-hidden /></Link>
          <Link className="button button-outline" href="/business/advertise">Explore formats</Link>
        </div>
      </section>

      <nav className="business-subnav section-shell" aria-label="Business portal">
        <Link href="/business/advertise">Advertise</Link>
        <Link href="/business/partners">Partners</Link>
        <Link href="/business/media-kit">Media kit</Link>
        <Link href="/business/pricing">Request a quote</Link>
        <Link href="/business/apply">Apply</Link>
      </nav>

      <section className="business-section section-shell" aria-labelledby="business-audience">
        <div className="section-intro">
          <p className="section-label cyan">Audience context</p>
          <h2 id="business-audience">Meet people at practical decision points</h2>
          <p>Placement discussions can be scoped to the profiles, cities, provinces and categories that YouNew actually publishes. We do not publish unverified audience-size claims.</p>
        </div>
        <div className="business-card-grid">
          <article><Users aria-hidden /><h3>Four user profiles</h3><p>Tourist, Student, Expat and Refugee pathways provide useful context for a relevant proposal.</p></article>
          <article><Building2 aria-hidden /><h3>Local context</h3><p>City, province and topic relationships make regional placement possible where coverage is published.</p></article>
          <article><Megaphone aria-hidden /><h3>Transparent promotion</h3><p>Commercial placements are clearly labelled and remain separate from organic search and editorial content.</p></article>
          <article><ShieldCheck aria-hidden /><h3>Safety boundaries</h3><p>Advertising never controls emergency guidance or the order of life-critical instructions.</p></article>
        </div>
      </section>

      <section className="business-section business-process section-shell" aria-labelledby="business-process">
        <div className="section-intro">
          <p className="section-label orange">Current process</p>
          <h2 id="business-process">A reviewed inquiry, not self-service advertising</h2>
        </div>
        <ol className="business-steps">
          <li><span>1</span><div><h3>Share the proposal</h3><p>Describe the organization, intended audience, location, goal, timing and indicative budget.</p></div></li>
          <li><span>2</span><div><h3>Relevance and safety review</h3><p>YouNew checks fit, claims, destination links and whether the proposal respects editorial boundaries.</p></div></li>
          <li><span>3</span><div><h3>Agree the scope</h3><p>Any format, price, dates, reporting and creative requirements are confirmed directly before work starts.</p></div></li>
        </ol>
        <aside className="business-truth-note">
          <BadgeCheck aria-hidden />
          <div><strong>Current availability</strong><p>There is no public advertiser login, automatic campaign purchase, live campaign dashboard or guaranteed analytics product yet. Business inquiries are handled through <a href="mailto:support@younew.nl">support@younew.nl</a>.</p></div>
        </aside>
      </section>
    </PageShell>
  );
}
