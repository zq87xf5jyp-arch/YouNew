export const CONTENT_IMAGES_BUCKET = "content-images";
export const CONTENT_IMAGE_MAX_BYTES = 8 * 1024 * 1024;
export const CONTENT_IMAGE_MAX_WIDTH = 1920;
export const CONTENT_IMAGE_MAX_HEIGHT = 1280;
export const CONTENT_IMAGE_QUALITY = 0.84;
export const CONTENT_IMAGE_LIMIT = 12;
export const CONTENT_IMAGE_CLEANUP_CANDIDATE_LIMIT = CONTENT_IMAGE_LIMIT * 2;

export type ManagedContentImage = {
  id: string;
  path: string;
  url: string;
  thumbnailUrl: string;
  alt: string;
  role: "cover" | "gallery";
  width: number;
  height: number;
  bytes: number;
  mimeType: "image/webp";
};

function isSupabaseImageUrl(value: unknown) {
  if (typeof value !== "string") return false;
  try {
    const url = new URL(value);
    return url.protocol === "https:" && /\/storage\/v1\/(?:object|render\/image)\/public\/content-images\//.test(url.pathname);
  } catch {
    return false;
  }
}

export function isManagedContentImagePath(value: unknown): value is string {
  return typeof value === "string" && /^articles\/[a-zA-Z0-9_-]{1,80}\/[a-zA-Z0-9][a-zA-Z0-9._-]{0,219}\.webp$/.test(value);
}

export function isManagedContentImage(value: unknown): value is ManagedContentImage {
  if (!value || typeof value !== "object") return false;
  const image = value as Partial<ManagedContentImage>;
  return Boolean(
    typeof image.id === "string" &&
    isManagedContentImagePath(image.path) &&
    isSupabaseImageUrl(image.url) &&
    isSupabaseImageUrl(image.thumbnailUrl) &&
    typeof image.alt === "string" &&
    (image.role === "cover" || image.role === "gallery") &&
    typeof image.width === "number" && image.width > 0 && image.width <= CONTENT_IMAGE_MAX_WIDTH &&
    typeof image.height === "number" && image.height > 0 && image.height <= CONTENT_IMAGE_MAX_HEIGHT &&
    typeof image.bytes === "number" && image.bytes > 0 && image.bytes <= CONTENT_IMAGE_MAX_BYTES &&
    image.mimeType === "image/webp"
  );
}

export function normalizeManagedContentImages(value: unknown): ManagedContentImage[] {
  if (!Array.isArray(value)) return [];
  return value.filter(isManagedContentImage).slice(0, CONTENT_IMAGE_LIMIT);
}
