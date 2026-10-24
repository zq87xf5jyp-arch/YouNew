import generatedContent from "@/generated/public-content.json";

import type {
  ContentCategory,
  ContentEntity,
  ContentEntityType,
  ContentProvince,
  PublicContentDataset
} from "./types";

const dataset = generatedContent as unknown as PublicContentDataset;

export function getPublicContent(): PublicContentDataset {
  return dataset;
}

export function getContentEntities(type?: ContentEntityType): readonly ContentEntity[] {
  const indexable = dataset.entities.filter((entity) => entity.indexable);
  return type ? indexable.filter((entity) => entity.type === type) : indexable;
}

export function getContentEntity(type: ContentEntityType, slug: string): ContentEntity | undefined {
  return dataset.entities.find((entity) => entity.type === type && entity.slug === slug);
}

export function getContentEntityById(id: string): ContentEntity | undefined {
  return dataset.entities.find((entity) => entity.id === id);
}

export function getCategory(slug: string): ContentCategory | undefined {
  return dataset.categories.find((category) => category.slug === slug);
}

export function getProvince(slug: string): ContentProvince | undefined {
  return dataset.provinces.find((province) => province.slug === slug);
}

export function getEntitiesForCategory(slug: string): readonly ContentEntity[] {
  return dataset.entities.filter((entity) => entity.indexable && entity.categorySlugs.includes(slug));
}

export function getEntitiesForProvince(slug: string): readonly ContentEntity[] {
  return dataset.entities.filter((entity) => entity.indexable && entity.provinceId === slug);
}

export function getStaticEntityParams(type: ContentEntityType): Array<{ slug: string }> {
  return dataset.entities.filter((entity) => entity.type === type).map(({ slug }) => ({ slug }));
}
