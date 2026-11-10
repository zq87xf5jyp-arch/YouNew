import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { PilotRequestForm } from "@/components/pilot-request-form";
import { getGeographyProvinces, getMunicipalities } from "@/lib/geography";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Request a 90-day onboarding pilot",
  "Tell YouNew about recurring international-employee onboarding questions and request a scoped pilot proposal.",
  "/partners/apply"
);

export default function PartnerApplyPage() {
  return (
    <PageShell className="business-page business-apply-page pilot-offer-page">
      <section className="business-hero section-shell pilot-apply-hero">
        <Breadcrumbs items={[{ label: "For business", href: "/for-business" }, { label: "Request pilot" }]} />
        <p className="section-label orange">90-day employee onboarding pilot</p>
        <h1>Tell us what your team needs.</h1>
        <p>We will review the request and prepare a scoped pilot proposal. Submitting this form does not create a contract.</p>
      </section>
      <section className="business-application-section section-shell" aria-labelledby="pilot-application-title">
        <div className="business-application-intro">
          <h2 id="pilot-application-title">Pilot request</h2>
          <p>Share the recurring questions, target region and contact details needed for a fit review. Do not include employee personal data.</p>
          <p><strong>Founding pilot — €1,500 excl. VAT.</strong> Fixed scope confirmed before contract.</p>
        </div>
        <PilotRequestForm
          municipalities={getMunicipalities().map((municipality) => municipality.name)}
          provinces={getGeographyProvinces().map((province) => province.name)}
        />
      </section>
    </PageShell>
  );
}
