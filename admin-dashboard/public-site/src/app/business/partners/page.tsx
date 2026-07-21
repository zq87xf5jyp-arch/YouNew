import Link from "next/link";
import { BadgeCheck, FileCheck2, Handshake, Scale, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Partner with YouNew", "Learn how YouNew reviews local organizations, content partnerships and clearly disclosed commercial relationships.", "/business/partners");

export default function PartnersPage() {
  return (
    <PageShell className="business-page">
      <section className="business-hero section-shell">
        <Breadcrumbs items={[{ label: "Business", href: "/business" }, { label: "Partners" }]} />
        <p className="section-label orange">Partnerships</p>
        <h1>Local knowledge with clear responsibilities</h1>
        <p>YouNew considers organizations that can provide relevant, lawful and understandable value for people navigating life in the Netherlands. A partnership does not grant control over editorial or emergency content.</p>
        <div className="hero-actions"><Link className="button button-primary" href="/business/apply">Propose a partnership</Link><a className="button button-outline" href="mailto:support@younew.nl">Email support</a></div>
      </section>

      <section className="business-section section-shell" aria-labelledby="partner-criteria">
        <div className="section-intro"><p className="section-label cyan">Selection criteria</p><h2 id="partner-criteria">What YouNew reviews</h2></div>
        <div className="business-card-grid">
          <article><BadgeCheck aria-hidden /><h3>Identity and legitimacy</h3><p>Organization details, website, contact information and relevant registration data must be verifiable.</p></article>
          <article><Handshake aria-hidden /><h3>User relevance</h3><p>The service or proposal must fit the selected profile, location and category without exploitative targeting.</p></article>
          <article><FileCheck2 aria-hidden /><h3>Claims and destinations</h3><p>Promotional claims, offers, terms and outbound links need to be clear and supportable.</p></article>
          <article><ShieldCheck aria-hidden /><h3>Safety and privacy</h3><p>Organizations must respect data protection, accessibility and YouNew&apos;s content boundaries.</p></article>
        </div>
      </section>

      <section className="business-section section-shell" aria-labelledby="partner-separation">
        <div className="section-intro"><p className="section-label orange">Trust model</p><h2 id="partner-separation">Three different relationships</h2></div>
        <div className="business-comparison">
          <article><h3>Editorial reference</h3><p>Selected for informational relevance and sources. It cannot be purchased and does not imply endorsement.</p></article>
          <article><h3>Sponsored placement</h3><p>A paid relationship, always identified as sponsored and kept out of emergency decision ordering.</p></article>
          <article><h3>Content partnership</h3><p>A collaboration with explicit authorship, review responsibility, sponsorship disclosure where applicable and cited sources.</p></article>
        </div>
        <aside className="business-truth-note"><Scale aria-hidden /><div><strong>Editorial independence</strong><p>Advertisers and partners cannot edit official-source status, suppress critical information, influence organic ranking, or change emergency instructions.</p></div></aside>
      </section>
    </PageShell>
  );
}
