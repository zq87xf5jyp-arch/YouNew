import { Breadcrumbs } from "@/components/breadcrumbs";
import { PageShell } from "@/components/page-shell";
import { SearchExperience } from "@/components/search-experience";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Search", "Search YouNew content and the official 2026 municipality and province directory from a local build-time index.", "/search", { noIndex: true, follow: true });
export default function SearchPage() { return <PageShell><section className="app-hero section-shell search-hero"><Breadcrumbs items={[{ label: "Search" }]} /><h1>Search YouNew and Dutch municipalities</h1><p>Search published guides, places and organizations together with all municipalities, provinces and official settlement names. The index is generated during build—no search profile is sent to a third party.</p></section><section className="section-shell app-content-block search-page-content"><SearchExperience /></section></PageShell>; }
