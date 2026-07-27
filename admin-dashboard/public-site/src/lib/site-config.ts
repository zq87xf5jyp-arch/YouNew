import rawSiteConfig from "@/config/site-config.json";

export type AppStoreConfig = {
  available: boolean;
  id: string;
  url: string;
  version: string;
  releasedAt: string;
  minimumOS: string;
  label: string;
};

export type StatusBannerConfig = {
  enabled: boolean;
  id: string;
  tone: "information" | "warning";
  message: string;
  action?: {
    label: string;
    href: string;
  };
};

export type SiteConfig = {
  schemaVersion: number;
  appStore: AppStoreConfig;
  statusBanner: StatusBannerConfig;
};

export const siteConfig = rawSiteConfig as SiteConfig;
export const appStore = siteConfig.appStore;
export const appleSmartAppBanner = `app-id=${appStore.id}`;
