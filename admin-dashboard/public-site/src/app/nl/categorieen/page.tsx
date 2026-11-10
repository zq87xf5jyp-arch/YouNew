import Link from "next/link";
import { ArrowRight, Layers3 } from "lucide-react";
import { PageShell } from "@/components/page-shell";
import { getPublicContent } from "@/lib/content";
import { dutchCategoryLabel } from "@/lib/i18n/nl";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Categorieën", "Bekijk betrouwbare informatie en organisaties per onderwerp in Nederland.", "/nl/categorieen", { locale: "nl" });
export default function Page() {
  const { categories } = getPublicContent();
  return <PageShell locale="nl"><section className="app-hero section-shell compact-hero"><p className="section-label cyan">Onderwerpen</p><h1>Bekijk informatie per categorie</h1><p>Elke categorie bevat alleen gepubliceerde items. Bron en controledatum staan op de detailpagina.</p></section><section className="section-shell app-content-block category-index-grid">{categories.map((category) => <Link href={`/nl/categorieen/${category.slug}`} key={category.id}><Layers3 aria-hidden /><div><span>{category.entityCount} items</span><h2>{dutchCategoryLabel(category.slug)}</h2><p>Bekijk gecontroleerde informatie en lokale profielen binnen dit onderwerp.</p></div><ArrowRight aria-hidden /></Link>)}</section></PageShell>;
}
