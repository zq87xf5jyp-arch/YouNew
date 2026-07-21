import { notFound } from "next/navigation";
import { EntityDetail } from "@/components/entity-detail";
import { PageShell } from "@/components/page-shell";
import { getContentEntity, getStaticEntityParams } from "@/lib/content";
import { metadataForEntity, relatedForEntity } from "@/lib/content/page-helpers";

export const dynamicParams = false;
export function generateStaticParams() { return getStaticEntityParams("city"); }
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) { const entity = getContentEntity("city", (await params).slug); return entity ? metadataForEntity(entity) : {}; }
export default async function CityDetailPage({ params }: { params: Promise<{ slug: string }> }) { const entity = getContentEntity("city", (await params).slug); if (!entity) notFound(); return <PageShell><EntityDetail entity={entity} related={relatedForEntity(entity)} /></PageShell>; }

