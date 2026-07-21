import { EntityCard } from "@/components/entity-card";
import type { ContentEntity } from "@/lib/content";
import Link from "next/link";

export function EntityListing({
  entities,
  emptyMessage = "No published items match this view.",
  limit = 24,
  viewAllHref
}: {
  entities: readonly ContentEntity[];
  emptyMessage?: string;
  limit?: number;
  viewAllHref?: string;
}) {
  if (entities.length === 0) return <div className="empty-state"><h2>No published items</h2><p>{emptyMessage}</p></div>;
  const visible = viewAllHref ? entities.slice(0, limit) : entities;
  return <>
    <div className="entity-grid">{visible.map((entity) => <EntityCard entity={entity} key={entity.id} />)}</div>
    {entities.length > visible.length && viewAllHref ? (
      <div className="listing-continuation">
        <p>Showing {visible.length} of {entities.length} published items to keep this page fast.</p>
        <Link className="button button-outline" href={viewAllHref}>Search all {entities.length} items</Link>
      </div>
    ) : null}
  </>;
}
