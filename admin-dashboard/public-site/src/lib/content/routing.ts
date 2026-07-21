import type { ContentEntity, ContentEntityType } from "./types";

const routePrefix: Readonly<Record<ContentEntityType, string>> = {
  city: "/cities",
  guide: "/guides",
  organization: "/organizations",
  place: "/places"
};

export function isSafeContentSlug(slug: string): boolean {
  return /^[a-z0-9]+(?:-[a-z0-9]+)*$/.test(slug);
}

export function contentEntityRoute(type: ContentEntityType, slug: string): string {
  if (!isSafeContentSlug(slug)) throw new Error(`Unsafe public content slug: ${slug}`);
  return `${routePrefix[type]}/${slug}`;
}

export function routeForEntity(entity: Pick<ContentEntity, "type" | "slug">): string {
  return contentEntityRoute(entity.type, entity.slug);
}

export function categoryRoute(slug: string): string {
  if (!isSafeContentSlug(slug)) throw new Error(`Unsafe public category slug: ${slug}`);
  return `/categories/${slug}`;
}

export function provinceRoute(slug: string): string {
  if (!isSafeContentSlug(slug)) throw new Error(`Unsafe public province slug: ${slug}`);
  return `/provinces/${slug}`;
}
