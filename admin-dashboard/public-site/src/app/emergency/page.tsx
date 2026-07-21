import { ExternalLink, Phone, ShieldAlert, Stethoscope } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Emergency help in the Netherlands", "When to call 112 in the Netherlands and where to find official non-emergency guidance.", "/emergency");

export default function EmergencyPage() {
  return (
    <PageShell className="emergency-page">
      <section className="app-hero section-shell compact-hero">
        <Breadcrumbs items={[{ label: "Emergency" }]} />
        <ShieldAlert aria-hidden className="hero-line-icon emergency-icon" />
        <h1>Emergency help</h1>
        <p>Use 112 only when every second counts: immediate danger, a serious crime in progress, fire or life-threatening medical help.</p>
      </section>
      <section className="section-shell emergency-content">
        <article className="emergency-primary">
          <div><Phone aria-hidden /><span>Primary emergency number</span></div>
          <strong>112</strong>
          <p>The operator will ask what happened and where help is needed, then connect police, fire or ambulance services.</p>
          <div className="emergency-actions">
            <a className="button emergency-call" href="tel:112">Call 112</a>
            <a className="button button-outline" href="https://www.government.nl/topics/emergency-number-112" rel="noreferrer" target="_blank">Government.nl guidance <ExternalLink aria-hidden /></a>
          </div>
        </article>
        <div className="emergency-secondary-grid">
          <article><ShieldAlert aria-hidden /><h2>Police, no immediate danger</h2><p>Use the official police contact routes for reports or questions that are not urgent. If danger becomes immediate, call 112.</p><a href="https://www.politie.nl/en/contact/" rel="noreferrer" target="_blank">Open Politie.nl <ExternalLink aria-hidden /></a></article>
          <article><Stethoscope aria-hidden /><h2>Urgent but not life-threatening care</h2><p>Contact your GP during office hours or your local out-of-hours GP service. Phone numbers differ by region.</p><a href="https://www.thuisarts.nl/dutch-healthcare/in-case-of-emergency" rel="noreferrer" target="_blank">Open Thuisarts guidance <ExternalLink aria-hidden /></a></article>
        </div>
        <aside className="safety-note"><strong>Important</strong> This is a static safety page, not live emergency monitoring or medical advice. It is deliberately excluded from long-lived offline caching. Verify non-urgent details with the official source.</aside>
      </section>
    </PageShell>
  );
}
