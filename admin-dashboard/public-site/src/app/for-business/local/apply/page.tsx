import { Breadcrumbs } from "@/components/breadcrumbs";
import { LocalBusinessApplicationForm } from "@/components/local-business-application-form";
import { PageShell } from "@/components/page-shell";
import { getGeographyProvinces, getMunicipalities } from "@/lib/geography";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage(
  "Add or claim a business profile",
  "Submit a protected request to add a new YouNew business profile or claim an existing profile for review.",
  "/for-business/local/apply",
  { noIndex: true, follow: true }
);

export default function LocalBusinessApplyPage() {
  return (
    <PageShell className="business-page business-apply-page local-business-apply-page">
      <section className="business-hero section-shell">
        <Breadcrumbs items={[
          { label: "For business", href: "/for-business" },
          { label: "Local business", href: "/for-business/local" },
          { label: "Add or claim" }
        ]} />
        <p className="section-label orange">Free reviewed profile request</p>
        <h1>Add or claim your business.</h1>
        <p>Share only public business facts and an authorized contact. YouNew checks identity, location and claims before any public change.</p>
      </section>
      <section className="business-application-section section-shell" aria-labelledby="local-business-application-title">
        <div className="business-application-intro">
          <h2 id="local-business-application-title">Profile request</h2>
          <p>Use this form for a new profile or to request control of an existing YouNew organization page.</p>
          <p><strong>No payment is requested.</strong> Submission does not guarantee publication or verified ownership.</p>
        </div>
        <LocalBusinessApplicationForm
          municipalities={getMunicipalities().map((municipality) => municipality.name)}
          provinces={getGeographyProvinces().map((province) => province.name)}
        />
      </section>
    </PageShell>
  );
}
