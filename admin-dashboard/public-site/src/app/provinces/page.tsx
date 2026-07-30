import Link from "next/link";
import { ArrowRight, MapPinned } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { ProvinceShape } from "@/components/province-shape";
import { getGeographyProvinces, getNetherlandsGeography } from "@/lib/geography";
import { metadataForPage } from "@/lib/seo/metadata";

const description = "Explore all 12 provinces of the Netherlands with their complete 2026 municipality and settlement counts.";

export const metadata = metadataForPage("Provinces of the Netherlands", description, "/provinces");

export default function ProvincesPage() {
  const geography = getNetherlandsGeography();
  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero province-directory-hero">
        <Breadcrumbs items={[{ label: "Provinces" }]} />
        <MapPinned className="hero-line-icon" aria-hidden />
        <h1>All provinces of the Netherlands.</h1>
        <p>{description}</p>
        <div className="dataset-note"><strong>{geography.stats.provinces}</strong> provinces · <strong>{geography.stats.municipalities}</strong> municipalities · <strong>{geography.stats.settlements}</strong> official settlements</div>
      </section>
      <section className="section-shell geography-method-note" aria-label="Province directory scope">
        <strong>Complete administrative directory</strong>
        <p>Counts use the official municipal division and BAG settlement table for 1 January 2026. YouNew editorial coverage is shown separately on each province page.</p>
      </section>
      <section className="section-shell app-content-block province-directory-grid">
        {getGeographyProvinces().map((province) => (
          <Link href={province.route} key={province.code}>
            <span className="province-directory-map"><ProvinceShape slug={province.slug} label={province.name} /></span>
            <span className="province-directory-copy">
              <small>{province.code}</small>
              <strong>{province.name}</strong>
              <span>{province.municipalityCount} municipalities · {province.settlementCount} settlements</span>
            </span>
            <ArrowRight aria-hidden />
          </Link>
        ))}
      </section>
    </PageShell>
  );
}
