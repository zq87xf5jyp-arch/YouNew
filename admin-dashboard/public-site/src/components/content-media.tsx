/* eslint-disable @next/next/no-img-element */
import type { PublicMediaAsset } from "@/lib/content";
import { responsivePublicImage } from "@/lib/media/image-url";
import { ViewportImage } from "@/components/viewport-image";

type ContentMediaProps = {
  asset: PublicMediaAsset;
  variant: "card" | "hero" | "gallery";
  eager?: boolean;
  eagerMedia?: string;
  deferUntilVisible?: boolean;
  sizes?: string;
};

export function preferredMedia(assets: readonly PublicMediaAsset[], roles: readonly PublicMediaAsset["role"][]) {
  for (const role of roles) {
    const match = assets.find((asset) => asset.role === role);
    if (match) return match;
  }
  return assets[0] ?? null;
}

export function ContentMedia({ asset, variant, eager = false, eagerMedia, deferUntilVisible = false, sizes: requestedSizes }: ContentMediaProps) {
  const widths = variant === "card" ? [360, 640, 900] : variant === "gallery" ? [480, 800, 1200] : [720, 1200, 1920];
  const localCityImage = /^\/images\/cities\/([a-z-]+)-1920\.webp$/.exec(asset.url);
  const responsive = localCityImage
    ? { src: asset.url, srcSet: [480, 800, 1200, 1920].map((width) => `/images/cities/${localCityImage[1]}-${width}.webp ${width}w`).join(", ") }
    : responsivePublicImage(asset.url, widths);
  const sizes = requestedSizes ?? (variant === "card"
    ? "(max-width: 760px) 100vw, (max-width: 1000px) 50vw, 33vw"
    : variant === "gallery" ? "(max-width: 760px) 100vw, 50vw" : "(max-width: 1200px) 100vw, 1180px");

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
      {eager && eagerMedia ? <link rel="preload" as="image" href={responsive.src} imageSrcSet={responsive.srcSet} imageSizes={sizes} media={eagerMedia} fetchPriority="high" /> : null}
      {deferUntilVisible ? <ViewportImage src={responsive.src} srcSet={responsive.srcSet} sizes={sizes} alt={asset.alt} /> : <img
        src={responsive.src}
        srcSet={responsive.srcSet}
        sizes={sizes}
        alt={asset.alt}
        loading={eager && !eagerMedia ? "eager" : "lazy"}
        fetchPriority={eager && !eagerMedia ? "high" : "auto"}
        decoding="async"
      />}
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
