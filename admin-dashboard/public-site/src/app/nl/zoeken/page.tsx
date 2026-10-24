import { NlSearchExperience } from "@/components/nl-search-experience";
import { PageShell } from "@/components/page-shell";
import { metadataForPage } from "@/lib/seo/metadata";
import Link from "next/link";

export const metadata = metadataForPage("Zoeken", "Zoek in gepubliceerde gidsen, organisaties, plaatsen en gemeenten.", "/nl/zoeken", { locale: "nl" });
export default function Page() { return <PageShell locale="nl"><section className="app-hero section-shell search-hero"><p className="section-label cyan">Lokale zoekindex</p><h1>Zoek betrouwbare informatie in Nederland</h1><p>Zoek in gepubliceerde gidsen, organisaties, plaatsen en gemeenten. De index wordt tijdens de build gemaakt; je zoekopdracht gaat niet naar een externe zoekdienst.</p></section><section className="section-shell app-content-block search-page-content"><NlSearchExperience /><nav className="content-index-tools" aria-label="Andere manieren om te zoeken"><Link href="/nl/categorieen/">Bekijk categorieën</Link><Link href="/nl/organisaties/">Bekijk organisaties</Link><Link href="/nl/stadsgidsen/amsterdam/">Bekijk stadsgidsen</Link></nav></section></PageShell>; }
