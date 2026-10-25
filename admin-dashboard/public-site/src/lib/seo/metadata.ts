import type { Metadata } from "next";

const origin = "https://younew.nl";
const socialImage = `${origin}/images/og-younew.jpg`;

function localizedCounterpart(path: string): { en: string; nl: string } | null {
  const normalized = path === "/" ? "/" : `/${path.replace(/^\/+|\/+$/g, "")}`;
  const pairs: Array<[RegExp, (match: RegExpMatchArray) => string, (match: RegExpMatchArray) => string]> = [
    [/^\/$/, () => "/", () => "/nl"],
    [/^\/nl$/, () => "/", () => "/nl"],
    [/^\/categories(?:\/(.+))?$/, (match) => `/categories${match[1] ? `/${match[1]}` : ""}`, (match) => `/nl/categorieen${match[1] ? `/${match[1]}` : ""}`],
    [/^\/organizations(?:\/(.+))?$/, (match) => `/organizations${match[1] ? `/${match[1]}` : ""}`, (match) => `/nl/organisaties${match[1] ? `/${match[1]}` : ""}`],
    [/^\/search$/, () => "/search", () => "/nl/zoeken"],
    [/^\/for-business$/, () => "/for-business", () => "/nl/voor-bedrijven"],
    [/^\/for-business\/local$/, () => "/for-business/local", () => "/nl/voor-bedrijven/lokaal"],
    [/^\/for-business\/local\/apply$/, () => "/for-business/local/apply", () => "/nl/voor-bedrijven/aanmelden"],
    [/^\/city-guides\/(.+)$/, (match) => `/city-guides/${match[1]}`, (match) => `/nl/stadsgidsen/${match[1]}`],
    [/^\/nl\/categorieen(?:\/(.+))?$/, (match) => `/categories${match[1] ? `/${match[1]}` : ""}`, (match) => `/nl/categorieen${match[1] ? `/${match[1]}` : ""}`],
    [/^\/nl\/organisaties(?:\/(.+))?$/, (match) => `/organizations${match[1] ? `/${match[1]}` : ""}`, (match) => `/nl/organisaties${match[1] ? `/${match[1]}` : ""}`],
    [/^\/nl\/zoeken$/, () => "/search", () => "/nl/zoeken"],
    [/^\/nl\/voor-bedrijven$/, () => "/for-business", () => "/nl/voor-bedrijven"],
    [/^\/nl\/voor-bedrijven\/lokaal$/, () => "/for-business/local", () => "/nl/voor-bedrijven/lokaal"],
    [/^\/nl\/voor-bedrijven\/aanmelden$/, () => "/for-business/local/apply", () => "/nl/voor-bedrijven/aanmelden"],
    [/^\/nl\/stadsgidsen\/(.+)$/, (match) => `/city-guides/${match[1]}`, (match) => `/nl/stadsgidsen/${match[1]}`]
  ];
  for (const [pattern, english, dutch] of pairs) {
    const match = normalized.match(pattern);
    if (match) return { en: english(match), nl: dutch(match) };
  }
  return null;
}

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
