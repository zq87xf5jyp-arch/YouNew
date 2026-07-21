import type { Metadata } from "next";

const origin = "https://younew.nl";
const socialImage = `${origin}/images/og-younew.jpg`;

export function metadataForPage(
  title: string,
  description: string,
  path: string,
  options: { noIndex?: boolean; follow?: boolean; socialImage?: string } = {}
): Metadata {
  const canonicalPath = path === "/" ? "/" : `${path.replace(/\/$/, "")}/`;
  const url = `${origin}${canonicalPath}`;
  const image = options.socialImage ?? socialImage;
  return {
    title,
    description,
    alternates: {
      canonical: url,
      languages: { en: url, "x-default": url }
    },
    openGraph: {
      title,
      description,
      url,
      siteName: "YouNew",
      locale: "en_US",
      type: "website",
      images: [{ url: image, width: 1200, height: 630, alt: "YouNew guide to the Netherlands" }]
    },
    twitter: {
      card: "summary_large_image",
      title,
      description,
      images: [image]
    },
    robots: options.noIndex ? { index: false, follow: options.follow ?? false } : undefined
  };
}
