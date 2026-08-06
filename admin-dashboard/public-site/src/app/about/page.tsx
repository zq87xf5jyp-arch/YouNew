import Link from "next/link";
import { ArrowRight, CheckCircle2, ExternalLink, MapPin, ShieldCheck } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "About YouNew",
  "How YouNew helps newcomers move from a real-life task to a useful next action and responsible official source.",
  "/about"
);

export default function AboutPage() {
  return (
    <PageShell className="about-younew-page">
      <article className="section-shell about-younew">
        <Breadcrumbs items={[{ label: "About YouNew" }]} />
        <header>
          <p className="section-label">About YouNew</p>
          <h1>A solution route for life in the Netherlands.</h1>
          <p>YouNew helps newcomers move from a real-life need to a clear next step. Information is useful only when it leads to an answer, checklist, decision or responsible official action.</p>
        </header>

        <section className="about-golden-rule" aria-labelledby="golden-rule-title">
          <ShieldCheck aria-hidden />
          <div><p className="section-label">The Golden Rule</p><h2 id="golden-rule-title">The user comes to solve a problem, not to browse a catalogue.</h2><p>Every route is designed around task → clarification → solution → official source.</p></div>
        </section>

        <section className="about-principles" aria-labelledby="principles-title">
          <h2 id="principles-title">What the product promises</h2>
          <div>
            <article><CheckCircle2 aria-hidden /><h3>Useful next action</h3><p>A page should end with something the user can understand or do.</p></article>
            <article><ExternalLink aria-hidden /><h3>Visible responsibility</h3><p>Official sources remain visible where important requirements need confirmation.</p></article>
            <article><MapPin aria-hidden /><h3>Honest local context</h3><p>National guidance stays available when local coverage is incomplete.</p></article>
          </div>
        </section>

        <nav className="about-actions" aria-label="Learn more about YouNew">
          <Link href="/#needs-title">Choose a task <ArrowRight aria-hidden /></Link>
          <Link href="/status/">See verification status <ArrowRight aria-hidden /></Link>
        </nav>
      </article>
    </PageShell>
  );
}
