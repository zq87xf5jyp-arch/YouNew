import Link from "next/link";
import { ArrowRight, Layers3 } from "lucide-react";
import { Breadcrumbs } from "@/components/breadcrumbs";
import { ContentMedia, preferredMedia } from "@/components/content-media";
import { PageShell } from "@/components/page-shell";
import { getEntitiesForCategory, getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const metadata = metadataForPage("Categories", "Browse every non-empty category in the published YouNew web dataset.", "/categories");

export default function CategoriesPage() {
  const { categories } = getPublicContent();
  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero"><Breadcrumbs items={[{ label: "Categories" }]} /><h1>Browse by category</h1><p>Only categories with published, source-checked content appear here. Draft and review materials remain private.</p></section>
      <section className="section-shell app-content-block category-index-grid">
        {categories.map((category) => {
          const representative = getEntitiesForCategory(category.slug).find((entity) => entity.images.length > 0);
          const image = representative ? preferredMedia(representative.images, ["thumbnail", "hero", "gallery"]) : null;
          return (
            <Link href={category.route} key={category.id}>
              {image ? <span className="collection-index-media"><ContentMedia asset={image} variant="card" /></span> : <Layers3 aria-hidden />}
              <div><span>{category.entityCount} items</span><h2>{category.title}</h2><p>{category.summary}</p></div>
              <ArrowRight aria-hidden />
            </Link>
          );
        })}
      </section>
    </PageShell>
  );
}
