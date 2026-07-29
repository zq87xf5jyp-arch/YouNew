const supabaseObjectMarker = "/storage/v1/object/public/";
const supabaseRenderMarker = "/storage/v1/render/image/public/";

function positiveWidth(width: number) {
  return Math.max(64, Math.min(2560, Math.round(width)));
}

function supabaseRenderUrl(input: URL, width: number, quality: number) {
  if (input.pathname.includes(supabaseObjectMarker)) {
    input.pathname = input.pathname.replace(supabaseObjectMarker, supabaseRenderMarker);
  } else if (!input.pathname.includes(supabaseRenderMarker)) {
    return null;
  }
  input.searchParams.set("width", String(positiveWidth(width)));
  input.searchParams.set("quality", String(Math.max(20, Math.min(100, Math.round(quality)))));
  input.searchParams.set("resize", "contain");
  return input.toString();
}

function wikimediaThumbnailUrl(input: URL, width: number) {
  if (input.hostname !== "upload.wikimedia.org" || !input.pathname.includes("/wikipedia/commons/")) return null;
  const size = positiveWidth(width);
  const marker = "/wikipedia/commons/";
  const relative = input.pathname.slice(input.pathname.indexOf(marker) + marker.length);
  const parts = relative.split("/").filter(Boolean);
  let sourceParts = parts;

  if (parts[0] === "thumb" && parts.length >= 5) {
    sourceParts = parts.slice(1, -1);
  }
  if (sourceParts.length < 3) return null;

  const filename = sourceParts.at(-1) ?? "image.jpg";
  const redirect = new URL("https://commons.wikimedia.org/wiki/Special:Redirect/file/");
  redirect.pathname = `/wiki/Special:Redirect/file/${filename}`;
  redirect.searchParams.set("width", String(size));
  return redirect.toString();
}

export function optimizedPublicImageUrl(url: string, width: number, quality = 82) {
  try {
    const parsed = new URL(url);
    return supabaseRenderUrl(new URL(parsed), width, quality) ?? wikimediaThumbnailUrl(new URL(parsed), width) ?? url;
  } catch {
    return url;
  }
}

export function responsivePublicImage(url: string, widths: readonly number[], quality = 82) {
  const uniqueWidths = [...new Set(widths.map(positiveWidth))].sort((left, right) => left - right);
  const variants = uniqueWidths.map((width) => ({ width, url: optimizedPublicImageUrl(url, width, quality) }));
  const hasTransform = variants.some((variant) => variant.url !== url);
  return {
    src: variants.at(-1)?.url ?? url,
    srcSet: hasTransform ? variants.map((variant) => `${variant.url} ${variant.width}w`).join(", ") : undefined
  };
}
