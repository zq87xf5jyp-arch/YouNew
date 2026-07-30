import Link from "next/link";
import { ArrowRight, Building2, MapPinned } from "lucide-react";
import { ContentIndexPage } from "@/components/content-index-page";
import { getContentEntities } from "@/lib/content";
import { getNetherlandsGeography } from "@/lib/geography";
import { metadataForPage } from "@/lib/seo/metadata";

const description = "Start with reviewed YouNew city guides, or search the complete official directory of 342 Dutch municipalities and 2,502 BAG settlements.";

export const metadata = metadataForPage("Cities and municipalities", description, "/cities");

export default function CitiesPage() {
  const cities = getContentEntities("city");
  const geography = getNetherlandsGeography();
  const largestMunicipalities = [...geography.municipalities]
    .filter((municipality) => municipality.population !== null)
    .sort((left, right) => (right.population ?? 0) - (left.population ?? 0))
    .slice(0, 6);
  return (
    <ContentIndexPage
      title="Cities and municipalities"
      description={description}
      entities={cities}
      featuredId="city.amsterdam"
      datasetNote={<><strong>{cities.length}</strong> reviewed city guides · <strong>{geography.stats.municipalities}</strong> official municipalities · <strong>{geography.stats.settlements}</strong> settlements</>}
      context={(
        <section className="section-shell geography-coverage-preview" aria-labelledby="geography-coverage-title">
          <div className="geography-coverage-heading">
            <div><Building2 aria-hidden /><span>Official national directory</span><h2 id="geography-coverage-title">Find every municipality and its settlements.</h2><p>The administrative directory is complete for 1 January 2026. It does not claim that every municipality already has a full YouNew city guide.</p></div>
            <Link className="button button-primary" href="/municipalities">Search all municipalities <ArrowRight aria-hidden /></Link>
          </div>
          <div className="geography-coverage-stats">
            <div><strong>{geography.stats.provinces}</strong><span>provinces</span></div>
            <div><strong>{geography.stats.municipalities}</strong><span>municipalities</span></div>
            <div><strong>{geography.stats.settlements}</strong><span>BAG settlements</span></div>
          </div>
          <div className="geography-coverage-links" aria-label="Large municipality starting points">
            {largestMunicipalities.map((municipality) => <Link href={`/municipalities/${municipality.slug}`} key={municipality.code}><MapPinned aria-hidden /><span><strong>{municipality.name}</strong><small>{municipality.provinceName}</small></span><ArrowRight aria-hidden /></Link>)}
          </div>
        </section>
      )}
    />
  );
}
