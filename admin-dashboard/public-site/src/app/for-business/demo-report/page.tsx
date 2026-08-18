import Link from "next/link";
import { ArrowRight, CalendarCheck, CheckCircle2, FileSearch, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Sample onboarding pilot report",
  "View an illustrative, synthetic example of the reporting structure proposed for a YouNew employee onboarding pilot.",
  "/for-business/demo-report"
);

export default function DemoReportPage() {
  return (
    <PageShell className="business-page pilot-offer-page">
      <section className="business-hero section-shell demo-report-hero">
        <Breadcrumbs items={[{ label: "For business", href: "/for-business" }, { label: "Sample report" }]} />
        <p className="section-label orange">Sample report · illustrative only</p>
        <h1>See the reporting structure before a pilot is scoped.</h1>
        <p>This page uses synthetic examples to demonstrate the proposed format. It is not a customer result, case study, performance claim or evidence of existing clients.</p>
        <div className="hero-actions"><Link className="button button-primary" href="/partners/apply">Request a pilot <ArrowRight aria-hidden /></Link><Link className="button button-outline" href="/for-business/pilot">Review pilot scope</Link></div>
      </section>

      <section className="business-section section-shell demo-report-shell" aria-labelledby="demo-report-title">
        <header className="demo-report-header"><div><span>Illustrative YouNew report</span><h2 id="demo-report-title">90-day employee onboarding pilot</h2><p>Example region: one selected Dutch city or region · Example route count: 10</p></div><strong>SAMPLE<br />NO LIVE DATA</strong></header>
        <div className="demo-report-grid">
          <article><FileSearch aria-hidden /><span>01</span><h3>Questions and route coverage</h3><p>Summarizes the recurring employee questions supplied during scoping and maps them to the ten agreed practical routes.</p><small>Example topics: registration, healthcare, housing, work and daily life.</small></article>
          <article><CalendarCheck aria-hidden /><span>02</span><h3>Official-source verification</h3><p>Lists the source, latest check date and review status for every route, with sensitive guidance separated for explicit review.</p><small>No unsupported legal, medical, tax or immigration conclusions.</small></article>
          <article><CheckCircle2 aria-hidden /><span>03</span><h3>Consent-based usage summary</h3><p>Shows bounded aggregate use only where analytics consent exists. Values are intentionally omitted from this synthetic sample.</p><small>No individual employee profiles or guaranteed outcome claims.</small></article>
          <article><ShieldCheck aria-hidden /><span>04</span><h3>Actions and maintenance</h3><p>Records approved revisions, content checks and the follow-up decisions for the remaining maintenance period.</p><small>One client revision round is included in the fixed scope.</small></article>
        </div>
        <footer className="demo-report-footer"><strong>Reporting boundary</strong><p>Actual reports describe observed, consented product usage and source-maintenance work. They do not claim causation, individual outcomes, reach, conversions or ROI without evidence.</p></footer>
      </section>
    </PageShell>
  );
}
