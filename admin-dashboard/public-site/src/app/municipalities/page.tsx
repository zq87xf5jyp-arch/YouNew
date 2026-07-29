import { Building2 } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { MunicipalityDirectory } from "@/components/municipality-directory";
import { PageShell } from "@/components/page-shell";
import { getMunicipalities, getNetherlandsGeography } from "@/lib/geography";
import { metadataForPage } from "@/lib/seo/metadata";

const description = "Search all 342 Dutch municipalities and the 2,502 official BAG settlements assigned to them on 1 January 2026.";

export const metadata = metadataForPage("Municipalities of the Netherlands", description, "/municipalities");

export default function MunicipalitiesPage() {
  const geography = getNetherlandsGeography();
  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero municipality-hero">
        <Breadcrumbs items={[{ label: "Municipalities" }]} />
        <Building2 className="hero-line-icon" aria-hidden />
        <h1>Every Dutch municipality, in one directory.</h1>
        <p>{description}</p>
        <div className="dataset-note">
          <strong>{geography.stats.municipalities}</strong> municipalities · <strong>{geography.stats.settlements}</strong> official settlements · <strong>{geography.stats.provinces}</strong> provinces
        </div>
      </section>
      <section className="section-shell geography-method-note" aria-label="Directory scope">
        <strong>Official administrative geography</strong>
        <p>A municipality is a local government area; it is not always the same as a city. Settlement names come from the CBS 2026 BAG table. Full YouNew city guides remain a separate, editorially reviewed collection.</p>
      </section>
      <section className="section-shell app-content-block">
        <MunicipalityDirectory municipalities={getMunicipalities()} />
      </section>
    </PageShell>
  );
}
