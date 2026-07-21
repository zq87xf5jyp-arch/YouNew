import Link from "next/link";
import {
  BadgeCheck,
  Ban,
  BarChart3,
  Building2,
  FileCheck2,
  LockKeyhole,
  Scale,
  ShieldCheck,
  Users
} from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { MediaKitPrintButton } from "@/components/media-kit-print-button";
import { PageShell } from "@/components/page-shell";
import { advertisingFormatCatalog } from "@/lib/business/catalog";
import { getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "YouNew media kit",
  "Review YouNew's published coverage, advertising formats, editorial safeguards, partner checks and request-for-quote process.",
  "/business/media-kit"
);

const reviewSteps = [
  ["Proposal review", "We check the requested format, location, audience, timing and whether the service is relevant to published YouNew coverage."],
  ["Identity and claims", "Organization details, destination links, registration information where relevant, offer terms and promotional claims must be supportable."],
  ["Safety and editorial review", "We assess privacy, accessibility, targeting and whether the proposal respects the separation between commercial and public-interest information."],
  ["Written scope", "Availability, deliverables, dates, creative responsibilities, measurement limits and a quote must be agreed before anything is placed."]
] as const;

const refusalCriteria = [
  "The organization, responsible contact or relevant registration details cannot be verified.",
  "Claims, prices, conditions, affiliations or destination links are misleading, incomplete or unsupported.",
  "The proposal asks to influence editorial ranking, official-source status, critical guidance or emergency information.",
  "The product, targeting or creative could exploit, discriminate against or create avoidable risk for YouNew users.",
  "The handling of personal data, consent or tracking is unclear or incompatible with the agreed privacy boundaries.",
  "The proposal is not relevant to published coverage, suitable inventory is unavailable, or YouNew cannot review it responsibly."
] as const;

export default function MediaKitPage() {
  const content = getPublicContent();

  return (
    <PageShell className="business-page business-media-kit">
      <section className="business-hero section-shell">
        <Breadcrumbs items={[{ label: "Business", href: "/business" }, { label: "Media kit" }]} />
        <p className="section-label orange">YouNew media kit</p>
        <h1>Relevant reach, without borrowed trust</h1>
        <p>This page documents the formats YouNew is prepared to discuss, the safeguards around them and the current limits of business delivery. It is not a rate card or a claim of live inventory.</p>
        <div className="hero-actions media-kit-actions">
          <Link className="button button-primary" href="/business/apply">Request a quote</Link>
          <MediaKitPrintButton />
        </div>
        <p className="media-kit-print-note">The complete media kit can be printed or saved as a PDF from your browser. All content remains available without JavaScript.</p>
      </section>

      <nav className="business-subnav section-shell" aria-label="Business portal">
        <Link href="/business">Overview</Link>
        <Link href="/business/media-kit" aria-current="page">Media kit</Link>
        <Link href="/business/advertise">Formats</Link>
        <Link href="/business/partners">Partners</Link>
        <Link href="/business/pricing">Request a quote</Link>
        <Link href="/business/apply">Apply</Link>
      </nav>

      <section className="business-section section-shell" aria-labelledby="media-kit-audience">
        <div className="section-intro">
          <p className="section-label cyan">Published footprint</p>
          <h2 id="media-kit-audience">Context, not inflated audience claims</h2>
          <p>YouNew serves Tourist, Student, Expat and Refugee profiles. The figures below describe the current published content package—not visitors, impressions, reach or guaranteed advertising availability.</p>
        </div>
        <dl className="media-kit-stat-grid" aria-label="Current published YouNew coverage">
          <div><dt>{content.stats.entities}</dt><dd>published content records</dd></div>
          <div><dt>{content.stats.cities}</dt><dd>published city records</dd></div>
          <div><dt>{content.stats.categories}</dt><dd>published content categories</dd></div>
          <div><dt>4</dt><dd>user profiles for relevance</dd></div>
        </dl>
        <div className="business-card-grid media-kit-audience-grid">
          <article><Users aria-hidden /><h3>People in transition</h3><p>Proposals should help people make a practical choice while travelling, studying, moving, settling or seeking support.</p></article>
          <article><Building2 aria-hidden /><h3>Local applicability</h3><p>City, province, category and profile context is considered only where corresponding coverage is published.</p></article>
          <article><BadgeCheck aria-hidden /><h3>Source-aware product</h3><p>Commercial status never grants an official-source badge or changes the verification status of editorial records.</p></article>
          <article><ShieldCheck aria-hidden /><h3>Emergency excluded</h3><p>Emergency instructions do not depend on advertising and paid placements cannot alter their order or visibility.</p></article>
        </div>
      </section>

      <section className="business-section section-shell" aria-labelledby="media-kit-formats">
        <div className="section-intro">
          <p className="section-label orange">Formats for review</p>
          <h2 id="media-kit-formats">One catalogue, scoped by relevance</h2>
          <p>Every format is subject to review, suitable published context and a written quote. Newsletter placement remains a future possibility and is not currently offered.</p>
        </div>
        <div className="business-format-list media-kit-format-list">
          {advertisingFormatCatalog.map((format) => (
            <article key={format.id}>
              <FileCheck2 aria-hidden />
              <div><h3>{format.title}</h3><p>{format.description}</p></div>
            </article>
          ))}
        </div>
      </section>

      <section className="business-section section-shell" aria-labelledby="media-kit-demo-preview">
        <div className="section-intro">
          <p className="section-label cyan">Clearly labelled examples</p>
          <h2 id="media-kit-demo-preview">What transparent delivery could look like</h2>
          <p>Both examples are design demonstrations. They are not active advertising, customer results, live analytics or evidence of an available campaign.</p>
        </div>
        <div className="media-kit-demo-grid">
          <article className="media-kit-partner-demo" aria-labelledby="demo-partner-title">
            <div className="media-kit-demo-label">DEMO PARTNER CARD · NOT LIVE</div>
            <div className="media-kit-sponsored-label"><span>Sponsored · DEMO</span><span>Fictional example</span></div>
            <div className="media-kit-demo-logo" aria-hidden>YN</div>
            <div>
              <h3 id="demo-partner-title">Example neighbourhood service</h3>
              <p>Illustrative copy showing the maximum context a short sponsored card might provide. It contains no real offer or endorsement.</p>
              <button className="button button-outline media-kit-inactive-cta" type="button" disabled>Example CTA · inactive</button>
            </div>
          </article>

          <article className="media-kit-report-demo" aria-labelledby="demo-report-title">
            <div className="media-kit-demo-label">DEMO REPORT · ILLUSTRATIVE DATA</div>
            <h3 id="demo-report-title">Example campaign summary</h3>
            <table>
              <caption>Rounded demonstration values, not advertiser or YouNew performance data</caption>
              <tbody>
                <tr><th scope="row">Example reporting period</th><td>30 days</td></tr>
                <tr><th scope="row">Illustrative impressions</th><td>10,000</td></tr>
                <tr><th scope="row">Illustrative CTA clicks</th><td>240</td></tr>
                <tr><th scope="row">Illustrative CTR</th><td>2.4%</td></tr>
                <tr><th scope="row">Illustrative landing-page visits</th><td>196</td></tr>
              </tbody>
            </table>
            <p><BarChart3 aria-hidden /> In this example, CTR is CTA clicks divided by impressions. Actual definitions, available signals and limitations must be agreed in writing.</p>
          </article>
        </div>
        <aside className="business-truth-note media-kit-measurement-note">
          <BarChart3 aria-hidden />
          <div><strong>No live advertiser analytics product</strong><p>YouNew does not currently offer a public advertiser dashboard or guarantee impression, unique-click, conversion or landing-page measurement. Reporting can be included only when the implementation is available, privacy-compatible and documented in the agreed scope.</p></div>
        </aside>
      </section>

      <section className="business-section section-shell" aria-labelledby="media-kit-independence">
        <div className="section-intro">
          <p className="section-label orange">Editorial independence</p>
          <h2 id="media-kit-independence">Commercial context stays visible</h2>
        </div>
        <div className="business-comparison media-kit-principles">
          <article><Scale aria-hidden /><h3>Editorial content</h3><p>Selected for user relevance and source quality. It cannot be purchased, suppressed by an advertiser or reordered for commercial benefit.</p></article>
          <article><BadgeCheck aria-hidden /><h3>Sponsored content</h3><p>Uses an explicit sponsored label and advertiser name, a distinct visual treatment and a disclosed commercial destination.</p></article>
          <article><ShieldCheck aria-hidden /><h3>Public-interest safeguards</h3><p>Official-source status, critical steps, warnings and emergency guidance remain outside advertiser control.</p></article>
        </div>
      </section>

      <section className="business-section section-shell" aria-labelledby="media-kit-review">
        <div className="section-intro">
          <p className="section-label cyan">Partner review</p>
          <h2 id="media-kit-review">Approval is manual, never automatic</h2>
          <p>An inquiry does not reserve inventory, create a contract or guarantee publication. YouNew may request evidence, revisions or additional context before making a decision.</p>
        </div>
        <ol className="business-steps media-kit-review-steps">
          {reviewSteps.map(([title, description], index) => (
            <li key={title}><span>{index + 1}</span><div><h3>{title}</h3><p>{description}</p></div></li>
          ))}
        </ol>
        <div className="media-kit-refusal" aria-labelledby="media-kit-refusal-title">
          <Ban aria-hidden />
          <div>
            <h3 id="media-kit-refusal-title">Reasons YouNew may refuse or stop a placement</h3>
            <ul>{refusalCriteria.map((criterion) => <li key={criterion}>{criterion}</li>)}</ul>
          </div>
        </div>
      </section>

      <section className="business-section section-shell" aria-labelledby="media-kit-data">
        <div className="section-intro">
          <p className="section-label orange">Data handling now</p>
          <h2 id="media-kit-data">A browser-to-email inquiry, not a hidden submission</h2>
        </div>
        <div className="media-kit-data-grid">
          <article><LockKeyhole aria-hidden /><h3>Before you send</h3><p>The application is validated in your browser. YouNew receives nothing when you fill it in or press “Review and prepare email”. No file upload is offered.</p></article>
          <article><FileCheck2 aria-hidden /><h3>When you choose to send</h3><p>The site opens a prefilled draft in your email application. Only after you review and send it do the chosen email providers and support@younew.nl receive the details.</p></article>
          <article><ShieldCheck aria-hidden /><h3>Data minimisation</h3><p>Do not include identity documents, health information, payment details or other sensitive personal data. Inquiry data is not a purchase or blanket marketing consent.</p></article>
        </div>
        <p className="business-source-links">Read the <Link href="/privacy">Privacy Policy</Link>. For access, correction or deletion questions about business correspondence, email <a href="mailto:support@younew.nl">support@younew.nl</a>.</p>
      </section>

      <section className="media-kit-final-cta section-shell" aria-labelledby="media-kit-cta">
        <p className="section-label cyan">Next step</p>
        <h2 id="media-kit-cta">Request a reviewed quote</h2>
        <p>Describe the organization, audience, location, intended outcome and timing. YouNew will discuss suitability and scope before any commercial commitment.</p>
        <div className="hero-actions media-kit-actions">
          <Link className="button button-primary" href="/business/apply">Prepare an inquiry</Link>
          <a className="button button-outline" href="mailto:support@younew.nl">support@younew.nl</a>
        </div>
      </section>
    </PageShell>
  );
}
