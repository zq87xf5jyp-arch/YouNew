import Link from "next/link";
import { ArrowRight, Map } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Provinces", "Province pages derived only from governed cities in the published YouNew dataset.", "/provinces");
export default function ProvincesPage() {
  const { provinces } = getPublicContent();
  return <PageShell><section className="app-hero section-shell compact-hero"><Breadcrumbs items={[{ label: "Provinces" }]} /><h1>Published province coverage</h1><p>These aggregate pages are derived from the four province IDs present in the production content artifact. They do not imply full nationwide coverage.</p></section><section className="section-shell app-content-block province-index-grid">{provinces.map((province) => <Link href={province.route} key={province.id}><Map aria-hidden /><div><span>{province.cityIds.length} published {province.cityIds.length === 1 ? "city" : "cities"}</span><h2>{province.title}</h2><p>{province.summary}</p></div><ArrowRight aria-hidden /></Link>)}</section></PageShell>;
}
