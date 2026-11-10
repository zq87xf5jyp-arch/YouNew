import type { Metadata } from "next";
import { notFound } from "next/navigation";
import { CityGuidePage } from "@/components/city-guide-page";
import { cityGuideSlugs, getCityGuide } from "@/content/city-guides";
import { metadataForPage } from "@/lib/seo/metadata";

export const dynamicParams = false;
export function generateStaticParams() { return cityGuideSlugs.map((slug) => ({ slug })); }
export async function generateMetadata({ params }: { params: Promise<{ slug: string }> }): Promise<Metadata> { const guide = getCityGuide((await params).slug); return guide ? metadataForPage(guide.title.en, guide.description.en, `/city-guides/${guide.slug}`) : {}; }
export default async function Page({ params }: { params: Promise<{ slug: string }> }) { const guide = getCityGuide((await params).slug); if (!guide) notFound(); return <CityGuidePage guide={guide} locale="en" />; }
