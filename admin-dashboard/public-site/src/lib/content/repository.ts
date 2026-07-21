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
  return type ? dataset.entities.filter((entity) => entity.type === type) : dataset.entities;
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
  return dataset.entities.filter((entity) => entity.categorySlugs.includes(slug));
}

export function getEntitiesForProvince(slug: string): readonly ContentEntity[] {
  return dataset.entities.filter((entity) => entity.provinceId === slug);
}

export function getStaticEntityParams(type: ContentEntityType): Array<{ slug: string }> {
  return dataset.entities.filter((entity) => entity.type === type).map(({ slug }) => ({ slug }));
}
