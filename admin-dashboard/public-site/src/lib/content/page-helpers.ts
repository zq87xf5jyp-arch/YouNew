import type { Metadata } from "next";
import { getContentEntities, getContentEntityById, type ContentEntity, type ContentEntityType } from "@/lib/content";
import { metadataForPage } from "@/lib/seo/metadata";

export function metadataForEntity(entity: ContentEntity): Metadata {
  const title = entity.type === "city" ? `${entity.title} city guide` : entity.practicalGuide?.seo.title ?? entity.title;
  const description = entity.practicalGuide?.seo.description ?? entity.seo.description;
  const metadata = metadataForPage(title, description, entity.route);
  return { ...metadata, openGraph: { ...metadata.openGraph, type: "article" } };
}

export function relatedForEntity(entity: ContentEntity, limit = 6): ContentEntity[] {
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
  for (const item of [...cityPeers, ...categoryPeers]) {
    if (!seen.has(item.id)) { related.push(item); seen.add(item.id); }
    if (related.length >= limit) break;
  }
  return related.slice(0, limit);
}

export const listingCopy: Record<ContentEntityType, { title: string; description: string }> = {
  city: { title: "Published cities", description: "Governed city records released through the same production content artifact used by the iOS app." },
  guide: { title: "Source-backed guides", description: "Published municipal and housing starting points with a clear source trail and next-step context." },
  organization: { title: "Organizations", description: "Healthcare, education and local service organizations from the published source-checked dataset." },
  place: { title: "Places", description: "Published places, stations, museums, parks, restaurants and events currently concentrated in Amsterdam." }
};
