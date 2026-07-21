import { Breadcrumbs } from "@/components/breadcrumbs";
import { EntityListing } from "@/components/entity-listing";
import { PageShell } from "@/components/page-shell";
import type { ContentEntity } from "@/lib/content";

export function ContentIndexPage({ title, description, entities }: { title: string; description: string; entities: readonly ContentEntity[] }) {
  const type = entities[0]?.type;
  return (
    <PageShell>
      <section className="app-hero section-shell compact-hero">
        <Breadcrumbs items={[{ label: title }]} />
        <h1>{title}</h1>
        <p>{description}</p>
        <div className="dataset-note"><strong>{entities.length}</strong> released item{entities.length === 1 ? "" : "s"} · English reviewed content · source dates shown on every detail page</div>
      </section>
      <section className="section-shell app-content-block"><EntityListing entities={entities} viewAllHref={type ? `/search?type=${type}` : undefined} /></section>
    </PageShell>
  );
}
