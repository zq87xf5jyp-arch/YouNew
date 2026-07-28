import Link from "next/link";
import { ArrowRight, Building2, FileText, MapPin, Navigation, ShieldCheck } from "lucide-react";
import { EntityCardMedia } from "@/components/entity-card-media";
import { SaveButton } from "@/components/save-button";
import type { ContentEntity } from "@/lib/content";
import { cardMediaForEntity } from "@/lib/content/card-media";

const icons = { city: Navigation, guide: FileText, organization: Building2, place: MapPin } as const;
const actionLabels = { city: "Open city guide", guide: "Open guide", organization: "Open organization", place: "Open place" } as const;

export function EntityCard({ entity }: { entity: ContentEntity }) {
  const Icon = icons[entity.type];
  const media = cardMediaForEntity(entity);
  return (
    <article className="entity-card">
      {media ? <EntityCardMedia media={media} /> : null}
      <div className="entity-card-body">
        <div className="entity-card-top">
          <span className="entity-kind"><Icon aria-hidden /> {entity.type}</span>
          <SaveButton item={{ id: entity.id, route: entity.route, title: entity.title, kind: entity.type }} compact />
        </div>
        <Link className="entity-card-link" href={entity.route}>
          <h2>{entity.title}</h2>
          <p>{entity.summary}</p>
          <span className="entity-card-action">{actionLabels[entity.type]} <ArrowRight aria-hidden /></span>
        </Link>
        <div className="entity-card-meta">
          {entity.cityId ? <span>{entity.cityId.replaceAll("-", " ")}</span> : null}
          <span><ShieldCheck aria-hidden /> Source checked {entity.verifiedAt}</span>
        </div>
      </div>
    </article>
  );
}
