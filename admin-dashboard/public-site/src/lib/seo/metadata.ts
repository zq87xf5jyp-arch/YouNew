import { localizedCounterpart } from "../i18n/routes";
import type { Metadata } from "next";

const origin = "https://younew.nl";
const socialImage = `${origin}/images/og-younew.jpg`;


function absolute(path: string) {
  const normalized = path === "/" ? "/" : `${path.replace(/\/$/, "")}/`;
  return `${origin}${normalized}`;
}

export function metadataForPage(
  title: string,
  description: string,
  path: string,
  options: { noIndex?: boolean; follow?: boolean; socialImage?: string; locale?: "en" | "nl" } = {}
): Metadata {
  const canonicalPath = path === "/" ? "/" : `${path.replace(/\/$/, "")}/`;
  const url = `${origin}${canonicalPath}`;
  const image = options.socialImage ?? socialImage;
  const localized = localizedCounterpart(path);
  return {
    title,
    description,
    alternates: {
      canonical: url,
      languages: localized
        ? { en: absolute(localized.en), nl: absolute(localized.nl), "x-default": absolute(localized.en) }
        : { en: url, "x-default": url }
    },
    openGraph: {
      title,
      description,
      url,
      siteName: "YouNew",
      locale: options.locale === "nl" ? "nl_NL" : "en_US",
      alternateLocale: localized ? [options.locale === "nl" ? "en_US" : "nl_NL"] : undefined,
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
