import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { SearchExperience } from "@/components/search-experience";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Search", "Search YouNew guides, cities, organizations and places from a local build-time index.", "/search", { noIndex: true, follow: true });
export default function SearchPage() { return <PageShell><section className="app-hero section-shell search-hero"><Breadcrumbs items={[{ label: "Search" }]} /><h1>Search published YouNew content</h1><p>Search titles, summaries, keywords, cities, provinces, categories and organizations. The index is generated during build—no search profile is sent to a third party.</p></section><section className="section-shell app-content-block search-page-content"><SearchExperience /></section></PageShell>; }
