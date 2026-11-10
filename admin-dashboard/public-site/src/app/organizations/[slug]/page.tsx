import { notFound } from "next/navigation";
import { EntityDetail } from "@/components/entity-detail";
import { PageShell } from "@/components/page-shell";
import { getContentEntity, getStaticEntityParams } from "@/lib/content";
import { metadataForEntity, relatedForEntity } from "@/lib/content/page-helpers";

export const dynamicParams = false;
export function generateStaticParams() {
  const params = getStaticEntityParams("organization");
  // Next static export treats an empty parameter set as if this function were
  // absent. The sentinel is rendered through notFound(), so no public profile
  // is emitted while the freshness gate has excluded every organization.
  return params.length ? params : [{ slug: "__no-published-organizations__" }];
}
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) { const entity = getContentEntity("organization", (await params).slug); return entity ? metadataForEntity(entity) : {}; }
export default async function OrganizationDetailPage({ params }: { params: Promise<{ slug: string }> }) { const entity = getContentEntity("organization", (await params).slug); if (!entity) notFound(); return <PageShell><EntityDetail entity={entity} related={relatedForEntity(entity)} /></PageShell>; }

