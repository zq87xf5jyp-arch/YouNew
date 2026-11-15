import {guideNavigation} from "@/lib/content/guide-navigation";
import "@/styles/guide.css";
import {PracticalGuideArticle} from "@/components/practical-guide-article";
import { notFound } from "next/navigation";
import { GuideDetail } from "@/components/guide-detail";
import {EditorialDetail} from "@/components/editorial-detail";
import {editorialMetadata} from "@/lib/content/editorial-metadata";
import { PageShell } from "@/components/page-shell";
import { getContentEntity, getStaticEntityParams } from "@/lib/content";
import { metadataForEntity, relatedForEntity } from "@/lib/content/page-helpers";

export const dynamicParams = false;
export function generateStaticParams() {
  const params = getStaticEntityParams("guide");
  return params.length ? params : [{slug: "__no-published-guides__"}];
}
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) { const entity = getContentEntity("guide", (await params).slug); return entity ? entity.practicalGuide ? metadataForEntity(entity) : entity.editorial ? editorialMetadata(entity) : metadataForEntity(entity) : {}; }
export default async function GuideDetailPage({ params }: { params: Promise<{ slug: string }> }) { const entity = getContentEntity("guide", (await params).slug); if (!entity) notFound(); return <PageShell>{entity.practicalGuide?<PracticalGuideArticle {...guideNavigation(entity.slug,"en")} guide={entity.practicalGuide} media={entity.images[0]} alternate={entity.editorial || entity.practicalGuideLocales?.nl ? {title:"Lees in het Nederlands",href:`/nl/gidsen/${entity.slug}/`} : undefined}/>:entity.editorial?<EditorialDetail entity={entity}/>:<GuideDetail entity={entity} related={relatedForEntity(entity)} />}</PageShell>; }
