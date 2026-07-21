import Link from "next/link";
import { Building2, FileText, MapPin, Navigation, ShieldCheck } from "lucide-react";
import { SaveButton } from "@/components/save-button";
import type { ContentEntity } from "@/lib/content";

const icons = { city: Navigation, guide: FileText, organization: Building2, place: MapPin } as const;

export function EntityCard({ entity }: { entity: ContentEntity }) {
  const Icon = icons[entity.type];
  return (
    <article className="entity-card">
      <div className="entity-card-top">
        <span className="entity-kind"><Icon aria-hidden /> {entity.type}</span>
        <SaveButton item={{ id: entity.id, route: entity.route, title: entity.title, kind: entity.type }} compact />
      </div>
      <Link className="entity-card-link" href={entity.route}>
        <h2>{entity.title}</h2>
        <p>{entity.summary}</p>
      </Link>
      <div className="entity-card-meta">
        {entity.cityId ? <span>{entity.cityId.replaceAll("-", " ")}</span> : null}
        <span><ShieldCheck aria-hidden /> Source checked {entity.verifiedAt}</span>
      </div>
    </article>
  );
}

