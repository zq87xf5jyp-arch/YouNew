import type { Metadata } from "next";
import { getContentEntities, getContentEntityById, type ContentEntity, type ContentEntityType } from "@/lib/content";
import { curatedSummaryGuideFor } from "@/lib/content/curated-summary-guides";
import { publicWebSummary } from "@/lib/content/presentation";
import { metadataForPage } from "@/lib/seo/metadata";

export function metadataForEntity(entity: ContentEntity): Metadata {
  const curatedSummary = curatedSummaryGuideFor(entity.id);
  const title = entity.type === "city" ? `${entity.title} city guide` : entity.practicalGuide?.seo.title ?? curatedSummary?.title ?? entity.title;
  const description = entity.practicalGuide?.seo.description ?? curatedSummary?.answer ?? publicWebSummary(entity.seo.description);
  const metadata = metadataForPage(title, description, entity.route);
  return { ...metadata, openGraph: { ...metadata.openGraph, type: "article" } };
}

export function relatedForEntity(entity: ContentEntity, limit = 18): ContentEntity[] {
  const explicitIds = [...(entity.practicalGuide?.relatedGuideIds ?? []), ...entity.relatedEntityIds];
  const related: ContentEntity[] = [];
  const seen = new Set([entity.id]);
  for (const id of explicitIds) {
    const item = getContentEntityById(id);
    if (item && !seen.has(item.id)) { related.push(item); seen.add(item.id); }
    if (related.length >= limit) return related;
  }
  const cityPeers = getContentEntities().filter((item) => item.cityId && item.cityId === (entity.type === "city" ? entity.slug : entity.cityId));
  const categoryPeers = getContentEntities().filter((item) => item.categorySlugs.some((category) => entity.categorySlugs.includes(category)));
  const peers = [...cityPeers, ...categoryPeers];
  const categoryRepresentatives = [...new Set(peers.flatMap((item) => [...item.categorySlugs]))]
    .flatMap((category) => peers.find((item) => item.categorySlugs.includes(category)) ?? []);
  for (const item of [...categoryRepresentatives, ...peers]) {
    if (!seen.has(item.id)) { related.push(item); seen.add(item.id); }
    if (related.length >= limit) break;
  }
  return related.slice(0, limit);
}

export const listingCopy: Record<ContentEntityType, { title: string; description: string }> = {
  city: { title: "City guides for everyday life in the Netherlands.", description: "Reviewed local context, useful places and source-backed starting points for the five cities currently published by YouNew." },
  guide: { title: "Practical guides for life in the Netherlands.", description: "Source-backed starting points for registration, housing, municipal services and everyday life. Publication depth is always labelled clearly." },
  organization: { title: "Organizations that help you get things done.", description: "Healthcare, education and local-service organizations with visible responsible sources and current verification dates." },
  place: { title: "Places worth knowing across YouNew cities.", description: "Published stations, museums, parks, food, culture and useful destinations from the reviewed YouNew catalogue." }
};
