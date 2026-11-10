export const supportedLocales = ["en", "nl", "ru", "uk", "pl"] as const;
export type SupportedLocale = (typeof supportedLocales)[number];

export const defaultLocale: SupportedLocale = "en";

// English remains the governed source-content language. The reviewed Dutch web shell,
// category/search/business interfaces and city guides publish without inventing translations
// of unreviewed entity facts. Russian, Ukrainian and Polish remain unpublished.
export const publishedWebLocales: SupportedLocale[] = ["en", "nl"];

export const localeLabels: Record<SupportedLocale, string> = {
  en: "English",
  nl: "Nederlands",
  ru: "Русский",
  uk: "Українська",
  pl: "Polski"
};
