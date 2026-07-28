import type { ContentEntity, PublicMediaAsset } from "./types";

export type CardMedia = Readonly<{
  src: string;
  alt: string;
  credit: string;
  sourceUrl: string;
  license: string;
  licenseUrl: string;
}>;

const supportedSource = /\.(?:avif|gif|jpe?g|png|webp)(?:[?#]|$)/i;
const rolePriority = { thumbnail: 0, hero: 1, gallery: 2, map_preview: 3 } as const;

export function preferredCardMediaAsset(images: readonly PublicMediaAsset[]): PublicMediaAsset | null {
  return [...images]
    .filter((asset) => supportedSource.test(asset.url))
    .sort((left, right) => rolePriority[left.role] - rolePriority[right.role])[0] ?? null;
}

function creditFromAttribution(attribution: string): string {
  const creator = attribution.match(/\sby\s(.+?)\sis\s(?:licensed|marked)\b/i)?.[1]?.trim();
  return creator || attribution.split(/[.;]/, 1)[0].replace(/^"|"$/g, "").trim();
}

export function cardMediaForEntity(
  entity: Pick<ContentEntity, "images" | "slug" | "type">
): CardMedia | null {
  const asset = preferredCardMediaAsset(entity.images);
  if (!asset?.licenseUrl) return null;

  return {
    src: `/images/entities/${entity.type}-${entity.slug}.webp`,
    alt: asset.alt,
    credit: creditFromAttribution(asset.attribution),
    sourceUrl: asset.sourcePageUrl ?? asset.url,
    license: asset.license,
    licenseUrl: asset.licenseUrl
  };
}
