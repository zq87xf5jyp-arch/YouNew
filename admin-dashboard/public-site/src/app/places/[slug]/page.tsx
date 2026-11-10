import { notFound } from "next/navigation";
import { EntityDetail } from "@/components/entity-detail";
import {EditorialDetail} from "@/components/editorial-detail";
import {editorialMetadata} from "@/lib/content/editorial-metadata";
import { PageShell } from "@/components/page-shell";
import { getContentEntity, getStaticEntityParams } from "@/lib/content";
import { metadataForEntity, relatedForEntity } from "@/lib/content/page-helpers";

export const dynamicParams = false;
export function generateStaticParams() {
  const params = getStaticEntityParams("place");
  return params.length ? params : [{slug: "__no-published-places__"}];
}
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) { const entity = getContentEntity("place", (await params).slug); return entity ? entity.editorial ? editorialMetadata(entity) : metadataForEntity(entity) : {}; }
export default async function PlaceDetailPage({ params }: { params: Promise<{ slug: string }> }) { const entity = getContentEntity("place", (await params).slug); if (!entity) notFound(); return <PageShell>{entity.editorial?<EditorialDetail entity={entity}/>:<EntityDetail entity={entity} related={relatedForEntity(entity)} />}</PageShell>; }

