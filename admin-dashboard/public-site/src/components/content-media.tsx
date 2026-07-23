/* eslint-disable @next/next/no-img-element */
import type { PublicMediaAsset } from "@/lib/content";
import { responsivePublicImage } from "@/lib/media/image-url";

type ContentMediaProps = {
  asset: PublicMediaAsset;
  variant: "card" | "hero" | "gallery";
  eager?: boolean;
};

export function preferredMedia(assets: readonly PublicMediaAsset[], roles: readonly PublicMediaAsset["role"][]) {
  for (const role of roles) {
    const match = assets.find((asset) => asset.role === role);
    if (match) return match;
  }
  return assets[0] ?? null;
}

export function ContentMedia({ asset, variant, eager = false }: ContentMediaProps) {
  const widths = variant === "card" ? [360, 640, 900] : variant === "gallery" ? [480, 800, 1200] : [720, 1200, 1920];
  const responsive = responsivePublicImage(asset.url, widths);
  const sizes = variant === "card"
    ? "(max-width: 760px) 100vw, (max-width: 1000px) 50vw, 33vw"
    : variant === "gallery" ? "(max-width: 760px) 100vw, 50vw" : "(max-width: 1200px) 100vw, 1180px";

  if (variant === "card") {
    return (
      <img
        className="entity-card-image"
        src={responsive.src}
        srcSet={responsive.srcSet}
        sizes={sizes}
        alt={asset.alt}
        loading="lazy"
        decoding="async"
      />
    );
  }

  return (
    <figure className={`content-media content-media-${variant}`}>
      <img
        src={responsive.src}
        srcSet={responsive.srcSet}
        sizes={sizes}
        alt={asset.alt}
        loading={eager ? "eager" : "lazy"}
        fetchPriority={eager ? "high" : "auto"}
        decoding="async"
      />
      {asset.attribution || asset.license ? (
        <figcaption>
          {asset.attribution ? <span>{asset.attribution}</span> : null}
          {asset.licenseUrl && asset.license ? <a href={asset.licenseUrl} rel="noreferrer" target="_blank">{asset.license}</a> : asset.license ? <span>{asset.license}</span> : null}
          {asset.sourcePageUrl ? <a href={asset.sourcePageUrl} rel="noreferrer" target="_blank">Source</a> : null}
        </figcaption>
      ) : null}
    </figure>
  );
}
