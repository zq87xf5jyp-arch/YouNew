import Link from "next/link";
import { ArrowRight, Map, MapPin, Search } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Provinces", "Province pages based only on published YouNew cities and source-checked content.", "/provinces");
export default function ProvincesPage() {
  const { provinces, entities, cities } = getPublicContent();
  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero">
        <Breadcrumbs items={[{ label: "Provinces" }]} />
        <h1>Published province coverage</h1>
        <p>Browse the Dutch provinces that currently contain published YouNew cities, organizations, places or guides. Coverage reflects the current published information and does not imply nationwide completeness.</p>
        <div className="dataset-note"><strong>{provinces.length}</strong> provinces · <strong>{cities.length}</strong> cities · <strong>{entities.length}</strong> published items</div>
      </section>
      <section className="section-shell province-index-grid" aria-label="Published provinces">
        {provinces.map((province) => <Link href={province.route} key={province.id}><Map aria-hidden /><div><span>{province.cityIds.length} published {province.cityIds.length === 1 ? "city" : "cities"} · {province.entityCount} records</span><h2>{province.title}</h2><p>{province.summary}</p></div><ArrowRight aria-hidden /></Link>)}
      </section>
      <section className="section-shell coverage-guidance" aria-labelledby="province-use-title">
        <div className="listing-heading"><div><span>Use the published coverage</span><h2 id="province-use-title">Choose the most useful route</h2></div></div>
        <div className="information-grid">
          <article><MapPin aria-hidden /><h3>Start with a city</h3><p>Open a published city page to see its connected places, organizations, guides and official municipal source.</p><Link href="/cities">Browse cities <ArrowRight aria-hidden /></Link></article>
          <article><Map aria-hidden /><h3>Compare locations</h3><p>Use the accessible coverage map to filter published items by city, province, category and content type.</p><Link href="/map">Open the map <ArrowRight aria-hidden /></Link></article>
          <article><Search aria-hidden /><h3>Search a specific need</h3><p>Search across the full published index when you know the service, place or topic you need.</p><Link href="/search">Search YouNew <ArrowRight aria-hidden /></Link></article>
        </div>
      </section>
    </PageShell>
  );
}
