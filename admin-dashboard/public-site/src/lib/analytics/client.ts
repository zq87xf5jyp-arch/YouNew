export type AnalyticsEvent =
  | { name: "page_view"; path: string }
  | { name: "search"; resultCount: number; hasResults: boolean }
  | { name: "official_source_click"; contentId: string }
  | { name: "partner_click"; contentId: string }
  | { name: "app_cta_click"; location: string }
  | { name: "profile_selected"; profile: string }
  | { name: "business_mailto_prepared"; organizationType: string };

export type AnalyticsProvider = {
  track(event: AnalyticsEvent): void;
};

declare global {
  interface Window {
    __YOUNEW_ANALYTICS__?: AnalyticsProvider;
  }
}

/**
 * No provider is installed by default. This deliberately performs no network
 * request and sets no cookie. A future privacy-reviewed provider can be wired
 * at runtime without changing feature code.
 */
export function track(event: AnalyticsEvent) {
  if (typeof window === "undefined") return;
  window.__YOUNEW_ANALYTICS__?.track(event);
}

