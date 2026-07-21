export const supportedLocales = ["en", "nl", "ru", "uk", "pl"] as const;
export type SupportedLocale = (typeof supportedLocales)[number];

export const defaultLocale: SupportedLocale = "en";

// Governed runtime content currently contains reviewed English copy only.
// Dutch, Russian, Ukrainian and Polish remain deliberately unpublished until their content export
// is reviewed, preventing mixed-language or unverified legal/official pages.
export const publishedWebLocales: SupportedLocale[] = ["en"];

export const localeLabels: Record<SupportedLocale, string> = {
  en: "English",
  nl: "Nederlands",
  ru: "Русский",
  uk: "Українська",
  pl: "Polski"
};
