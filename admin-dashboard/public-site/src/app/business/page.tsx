import Link from "next/link";
import {
  ArrowRight,
  BadgeCheck,
  Building2,
  FileCheck2,
  Link2,
  MapPin,
  Megaphone,
  ShieldCheck
} from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { advertisingFormatCatalog, advertisingSurfaceCatalog } from "@/lib/business/catalog";
import { getNetherlandsGeography } from "@/lib/geography";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Business and partnerships",
  "Reach newcomers through reviewed YouNew organization profiles, local placements and useful content partnerships without buying editorial authority.",
  "/business"
);

const featuredFormatIds = [
  "verified-organization-profile",
  "sponsored-city-placement",
  "content-partnership",
  "referral-affiliate"
] as const;

const formatIcons = {
  "verified-organization-profile": BadgeCheck,
  "sponsored-city-placement": MapPin,
  "content-partnership": FileCheck2,
  "referral-affiliate": Link2
} as const;

export default function BusinessPage() {
  const geography = getNetherlandsGeography();
  const featuredFormats = featuredFormatIds.map((id) => {
    const format = advertisingFormatCatalog.find((candidate) => candidate.id === id);
    if (!format) throw new Error(`Missing advertising format: ${id}`);
    return format;
  });

  return (
    <PageShell className="business-page business-v18">
      <section className="business-hero business-v18-hero section-shell">
        <Breadcrumbs items={[{ label: "Business" }]} />
        <div className="business-v18-hero-copy">
          <h1>Reach newcomers when a local service matters.</h1>
          <p>Partner with YouNew through clearly labelled placements, verified organization profiles and useful content collaborations—without buying editorial authority.</p>
          <div className="hero-actions">
            <Link className="button button-primary" href="/business/workspace">Open business workspace <ArrowRight aria-hidden /></Link>
            <Link className="button button-outline" href="/business/apply">Start a reviewed inquiry</Link>
            <Link className="text-link" href="/business/media-kit">View media kit</Link>
          </div>
        </div>
        <dl className="business-coverage-proof" aria-label="Current product coverage, not audience size">
          <div><Building2 aria-hidden /><dt>{geography.stats.municipalities}</dt><dd>municipalities in the directory</dd></div>
          <div><MapPin aria-hidden /><dt>{geography.stats.provinces}</dt><dd>provinces</dd></div>
          <div><FileCheck2 aria-hidden /><dt>{advertisingSurfaceCatalog.length}</dt><dd>defined placement surfaces</dd></div>
          <div><Megaphone aria-hidden /><dt>0</dt><dd>live public campaigns</dd></div>
        </dl>
        <p className="business-metric-note">These figures describe product coverage and commercial readiness—not visitors, reach, impressions or guaranteed inventory.</p>
      </section>

      <nav className="business-subnav section-shell" aria-label="Business portal">
        <Link href="/business/workspace">Workspace</Link>
        <Link href="/business/advertise">Advertise</Link>
        <Link href="/business/partners">Partners</Link>
        <Link href="/business/media-kit">Media kit</Link>
        <Link href="/business/pricing">Request a quote</Link>
        <Link href="/business/apply">Apply</Link>
      </nav>

      <section className="business-section section-shell business-format-rail-section" aria-labelledby="business-formats">
        <div className="section-intro">
          <h2 id="business-formats">Choose how to work with YouNew</h2>
          <p>Every proposal is reviewed for identity, relevance, claims, privacy, accessibility and user safety before any commercial commitment.</p>
        </div>
        <div className="business-format-rail">
          {featuredFormats.map((format) => {
            const Icon = formatIcons[format.id as keyof typeof formatIcons];
            return (
              <article key={format.id}>
                <Icon aria-hidden />
                <div><h3>{format.title}</h3><p>{format.description}</p></div>
                <Link href="/business/advertise">Explore format <ArrowRight aria-hidden /></Link>
              </article>
            );
          })}
        </div>
      </section>

      <section className="business-section section-shell business-placement-section" aria-labelledby="placement-preview-title">
        <div className="business-placement-heading">
          <div>
            <h2 id="placement-preview-title">See the placement before it goes live</h2>
            <p>This demonstration shows where a reviewed placement can appear. It is not an active advertisement, real offer or endorsement.</p>
          </div>
          <aside>
            <ShieldCheck aria-hidden />
            <strong>Paid placement never changes organic ranking, official-source cards or emergency guidance.</strong>
          </aside>
        </div>

        <div className="business-placement-demo" aria-label="Demonstration of a sponsored city placement">
          <div className="placement-demo-header">
            <span>YouNew city page demonstration</span>
            <strong>Amsterdam</strong>
            <p>Official information, local services and practical guides for newcomers.</p>
          </div>
          <div className="placement-demo-topics" aria-label="Example city topics">
            <span>Overview</span><span>Housing</span><span>Work</span><span>Education</span><span>Health</span><span>Transport</span>
          </div>
          <div className="placement-demo-organic">
            <span><strong>Municipality of Amsterdam</strong><small>Official source</small></span>
            <span><strong>Housing in Amsterdam</strong><small>Published guide</small></span>
            <span><strong>Work and local services</strong><small>Organic YouNew coverage</small></span>
          </div>
          <div className="placement-demo-sponsored">
            <span>Sponsored · demonstration · not live</span>
            <div>
              <span className="placement-demo-mark" aria-hidden>YN</span>
              <span><strong>Example reviewed local service</strong><small>Illustrative copy only; no real advertiser, offer or destination.</small></span>
              <button disabled type="button">Example CTA · inactive</button>
            </div>
          </div>
        </div>
      </section>

      <section className="business-section section-shell business-v18-process" aria-labelledby="business-process">
        <div className="section-intro">
          <h2 id="business-process">A reviewed inquiry, not an automatic ad marketplace</h2>
          <p>The current workflow protects users and gives suitable partners a clear route to discuss scope.</p>
        </div>
        <ol className="business-steps">
          <li><span>1</span><div><h3>Share the proposal</h3><p>Describe the organization, service, audience, location, goal, timing and indicative budget.</p></div></li>
          <li><span>2</span><div><h3>Relevance and safety review</h3><p>YouNew checks identity, claims, destination links, privacy, accessibility and fit with published coverage.</p></div></li>
          <li><span>3</span><div><h3>Agree scope and reporting</h3><p>Placement, dates, creative responsibilities, measurement limits and price are confirmed in writing.</p></div></li>
        </ol>
        <div className="business-exclusion-strip">
          <ShieldCheck aria-hidden />
          <p><strong>Excluded:</strong> emergency pages, official-source ranking and life-critical instructions.</p>
          <Link href="/business/advertise">Read placement rules <ArrowRight aria-hidden /></Link>
        </div>
        <div className="business-v18-final-actions">
          <Link className="button button-primary" href="/business/apply">Start a reviewed inquiry <ArrowRight aria-hidden /></Link>
          <Link className="button button-outline" href="/business/media-kit">Review the media kit</Link>
        </div>
      </section>
    </PageShell>
  );
}
