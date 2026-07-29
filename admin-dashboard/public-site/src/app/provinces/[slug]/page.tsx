import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { ContentIndexPage } from "@/components/content-index-page";
import { getEntitiesForProvince, getProvince, getPublicContent } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export const dynamicParams = false;
export function generateStaticParams() { return getPublicContent().provinces.map(({ slug }) => ({ slug })); }
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> { const province = getProvince((await params).slug); return province ? metadataForPage(`${province.title} province`, province.summary, province.route) : {}; }
export default async function ProvinceDetailPage({ params }: { params: Promise<{ slug: string }> }) {
  const province = getProvince((await params).slug);
  if (!province) notFound();
  const entities = getEntitiesForProvince(province.slug);
  return (
    <ContentIndexPage
      title={province.title}
      description={`${province.summary} Coverage is limited to content already approved in the shared production release.`}
      entities={entities}
      datasetNote={<><strong>{province.cityIds.length}</strong> published cities · <strong>{entities.length}</strong> linked records</>}
    />
  );
}
