import Link from "next/link";
import { ArrowRight, ShieldCheck } from "lucide-react";
import { ContentMedia, preferredMedia } from "@/components/content-media";
import type { ContentEntity } from "@/lib/content";
import { dutchCategoryLabel, dutchEntityDescription, dutchEntityRoute, dutchEntityTypeLabel } from "@/lib/i18n/nl";

export function NlEntityCard({ entity }: { entity: ContentEntity }) {
  const image = preferredMedia(entity.images, ["thumbnail", "hero", "gallery"]);
  const route = dutchEntityRoute(entity);
  return (
    <article className="entity-card" lang="nl">
      {image ? <Link className="entity-card-media" href={route} aria-label={`Open ${entity.title}`}><ContentMedia asset={image} variant="card" /></Link> : null}
      <div className="entity-card-top"><span className="entity-kind">{dutchEntityTypeLabel(entity.type)}</span></div>
      <Link className="entity-card-link" href={route}>
        <h2>{entity.title}</h2>
        <p>{dutchEntityDescription(entity)}</p>
      </Link>
      <div className="entity-card-meta">
        <span>{entity.categorySlugs[0] ? dutchCategoryLabel(entity.categorySlugs[0]) : dutchEntityTypeLabel(entity.type)}</span>
        {entity.cityId ? <span>{entity.cityId.replaceAll("-", " ")}</span> : null}
        <span><ShieldCheck aria-hidden /> Bron gecontroleerd {entity.verifiedAt}</span>
      </div>
      <Link className="text-link" href={route}>Bekijk profiel <ArrowRight aria-hidden /></Link>
    </article>
  );
}
