import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { PartnerApplicationForm } from "@/components/partner-application-form";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Business inquiry", "Prepare a partnership, advertising or request-for-quote inquiry for YouNew using a transparent email handoff.", "/business/apply");

export default function BusinessApplyPage() {
  return (
    <PageShell className="business-page business-apply-page">
      <section className="business-hero section-shell">
        <Breadcrumbs items={[{ label: "Business", href: "/business" }, { label: "Apply" }]} />
        <p className="section-label orange">Business inquiry</p>
        <h1>Tell us what you want to make useful</h1>
        <p>Prepare an advertising, local-partner, content-partnership or request-for-quote inquiry. YouNew reviews relevance, claims, safety and the separation between paid and editorial content before discussing availability.</p>
      </section>

      <section className="business-application-section section-shell" aria-labelledby="application-form-title">
        <div className="business-application-intro">
          <h2 id="application-form-title">Inquiry details</h2>
          <p>This static website has no secure upload or form backend. It will validate the fields in your browser and prepare a prefilled email; nothing is submitted automatically.</p>
          <p>Logo and image upload is intentionally unavailable. If the inquiry proceeds, support will explain a safe way to provide approved media.</p>
        </div>
        <PartnerApplicationForm />
      </section>
    </PageShell>
  );
}
