import { notFound } from "next/navigation";
import { GuideDetail } from "@/components/guide-detail";
import { PageShell } from "@/components/page-shell";
import { getContentEntity, getStaticEntityParams } from "@/lib/content";
import { metadataForEntity, relatedForEntity } from "@/lib/content/page-helpers";

export const dynamicParams = false;
export function generateStaticParams() { return getStaticEntityParams("guide"); }
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }) { const entity = getContentEntity("guide", (await params).slug); return entity ? metadataForEntity(entity) : {}; }
export default async function GuideDetailPage({ params }: { params: Promise<{ slug: string }> }) { const entity = getContentEntity("guide", (await params).slug); if (!entity) notFound(); return <PageShell><GuideDetail entity={entity} related={relatedForEntity(entity)} /></PageShell>; }
