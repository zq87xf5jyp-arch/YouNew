import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { SearchExperience } from "@/components/search-experience";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Search", "Find practical guides, local information and official municipality pages on YouNew.", "/search", { noIndex: true, follow: true });
export default function SearchPage() { return <PageShell><section className="app-hero section-shell search-hero"><Breadcrumbs items={[{ label: "Search" }]} /><h1>What are you looking for?</h1><p>Find practical guides, local information and the right municipality. Refine your search by city or topic.</p></section><section className="section-shell app-content-block search-page-content"><SearchExperience /></section></PageShell>; }
