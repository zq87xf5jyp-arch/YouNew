export type AnalyticsEvent =
  | { name: "page_view"; path: string }
  | {
      name: "search";
      searchId: string;
      searchIntent: string;
      resultCount: number;
      hasResults: boolean;
      queryTokenBucket: SearchQueryTokenBucket;
      typeFilter?: string;
      cityId?: string;
      provinceId?: string;
      categoryId?: string;
      profile?: string;
      locationScope: "national" | "province" | "municipality";
    }
  | { name: "search_result_opened"; searchId: string; contentId: string; resultRank: number }
  | { name: "official_source_click"; contentId: string }
  | { name: "partner_click"; contentId: string }
  | { name: "item_saved"; contentId: string }
  | { name: "app_cta_click"; location: string }
  | { name: "profile_selected" }
  | { name: "business_mailto_prepared"; organizationType: string }
  | { name: "analytics_consent_granted" };

export type SearchResultBucket = "0" | "1" | "2-5" | "6-10" | "11-20" | "21-50" | "51+";
export type SearchQueryTokenBucket = "1" | "2-3" | "4-7" | "8+";

export type AnalyticsProvider = {
  track(event: AnalyticsEvent): void;
  flush?(): Promise<void>;
  dispose?(): void;
};

declare global {
  interface Window {
    __YOUNEW_ANALYTICS__?: AnalyticsProvider;
  }
}

export function track(event: AnalyticsEvent) {
  if (typeof window === "undefined") return;
  window.__YOUNEW_ANALYTICS__?.track(event);
}

export type AnalyticsConfiguration = {
  endpoint: string;
  publishableKey: string;
  consentVersion: string;
  schemaVersion: number;
  appVersion: string;
};

export type AnalyticsEnvelope = {
  client_event_id: string;
  app_instance_id: string;
  session_id: string;
  event_name: AnalyticsEvent["name"];
  screen: string;
  platform: "Web";
  app_version: string;
  language: string;
  properties: Record<string, string | number | boolean>;
  occurred_at: string;
  consent_version: string;
  schema_version: number;
  environment: "production" | "staging";
};

type AnalyticsRuntime = {
  fetch: typeof fetch;
  now(): Date;
  randomUUID(): string;
  pathname(): string;
  language(): string;
  environment(): "production" | "staging";
  setTimeout(callback: () => void, milliseconds: number): unknown;
  clearTimeout(timer: unknown): void;
};

type ProviderOptions = {
  configuration: AnalyticsConfiguration;
  appInstanceId: string;
  sessionId: string;
  runtime?: AnalyticsRuntime;
};

const safeEndpointPath = "/functions/v1/analytics-ingest";
const maximumBatchSize = 20;
const flushDelayMilliseconds = 1_000;

export function analyticsEnvironment(hostname: string): "production" | "staging" {
  const normalized = hostname.trim().toLowerCase();
  return normalized === "localhost"
    || normalized === "127.0.0.1"
    || normalized === "::1"
    || normalized.endsWith(".localhost")
    ? "staging"
    : "production";
}

export function randomUUIDv4() {
  const source = globalThis.crypto;
  if (typeof source?.randomUUID === "function") return source.randomUUID();
  if (typeof source?.getRandomValues !== "function") {
    throw new Error("Secure random values are unavailable.");
  }

  const bytes = source.getRandomValues(new Uint8Array(16));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  const hexadecimal = Array.from(bytes, (byte) => byte.toString(16).padStart(2, "0"));
  return [
    hexadecimal.slice(0, 4).join(""),
    hexadecimal.slice(4, 6).join(""),
    hexadecimal.slice(6, 8).join(""),
    hexadecimal.slice(8, 10).join(""),
    hexadecimal.slice(10, 16).join("")
  ].join("-");
}

function defaultRuntime(): AnalyticsRuntime {
  return {
    fetch: window.fetch.bind(window),
    now: () => new Date(),
    randomUUID: randomUUIDv4,
    pathname: () => window.location.pathname,
    language: () => document.documentElement.lang || "en",
    environment: () => analyticsEnvironment(window.location.hostname),
    setTimeout: (callback, milliseconds) => window.setTimeout(callback, milliseconds),
    clearTimeout: (timer) => window.clearTimeout(timer as number)
  };
}

function isValidConfiguration(configuration: AnalyticsConfiguration) {
  try {
    const endpoint = new URL(configuration.endpoint);
    return endpoint.protocol === "https:"
      && endpoint.hostname.endsWith(".supabase.co")
      && endpoint.pathname === safeEndpointPath
      && configuration.publishableKey.startsWith("sb_publishable_")
      && configuration.consentVersion.length > 0
      && configuration.schemaVersion === 1;
  } catch {
    return false;
  }
}

function safeScreen(value: string) {
  const path = value.split(/[?#]/, 1)[0] || "/";
  const normalized = path.replace(/[^A-Za-z0-9_./:-]/g, "-");
  return normalized.slice(0, 160) || "/";
}

function safeProperty(value: string) {
  return value
    .replace(/[^A-Za-z0-9_./: -]/g, "-")
    .slice(0, 160);
}

function safeSlugProperty(value: string) {
  return value
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9-]/g, "-")
    .replace(/-+/g, "-")
    .replace(/^-|-$/g, "")
    .slice(0, 80);
}

export function searchResultBucket(resultCount: number): SearchResultBucket {
  const count = Math.max(0, Math.trunc(resultCount));
  if (count === 0) return "0";
  if (count === 1) return "1";
  if (count <= 5) return "2-5";
  if (count <= 10) return "6-10";
  if (count <= 20) return "11-20";
  if (count <= 50) return "21-50";
  return "51+";
}

export function searchQueryTokenBucket(query: string): SearchQueryTokenBucket {
  const count = query.trim().split(/\s+/u).filter(Boolean).length;
  if (count <= 1) return "1";
  if (count <= 3) return "2-3";
  if (count <= 7) return "4-7";
  return "8+";
}

function eventProperties(event: AnalyticsEvent): Record<string, string | number | boolean> {
  switch (event.name) {
    case "search":
      return {
        search_id: safeProperty(event.searchId),
        search_intent: safeSlugProperty(event.searchIntent) || "unclassified",
        result_count: Math.max(0, Math.trunc(event.resultCount)),
        result_bucket: searchResultBucket(event.resultCount),
        has_results: event.hasResults,
        query_token_bucket: event.queryTokenBucket,
        ...(event.typeFilter ? { type_filter: safeSlugProperty(event.typeFilter) } : {}),
        ...(event.cityId ? { city_id: safeSlugProperty(event.cityId) } : {}),
        ...(event.provinceId ? { province_id: safeSlugProperty(event.provinceId) } : {}),
        ...(event.categoryId ? { category_id: safeSlugProperty(event.categoryId) } : {}),
        ...(event.profile ? { profile: safeSlugProperty(event.profile) } : {}),
        location_scope: event.locationScope
      };
    case "search_result_opened":
      return {
        search_id: safeProperty(event.searchId),
        content_id: safeProperty(event.contentId),
        result_rank: Math.max(1, Math.min(200, Math.trunc(event.resultRank)))
      };
    case "official_source_click":
    case "partner_click":
    case "item_saved":
      return { content_id: safeProperty(event.contentId) };
    case "app_cta_click":
      return { location: safeProperty(event.location) };
    case "business_mailto_prepared":
      return { organization_type: safeProperty(event.organizationType) };
    case "page_view":
    case "profile_selected":
    case "analytics_consent_granted":
      return {};
  }
}

export function createAnalyticsEnvelope(
  event: AnalyticsEvent,
  options: Omit<ProviderOptions, "runtime">,
  runtime: Pick<AnalyticsRuntime, "now" | "randomUUID" | "pathname" | "language" | "environment">
): AnalyticsEnvelope {
  return {
    client_event_id: runtime.randomUUID(),
    app_instance_id: options.appInstanceId,
    session_id: options.sessionId,
    event_name: event.name,
    screen: safeScreen(event.name === "page_view" ? event.path : runtime.pathname()),
    platform: "Web",
    app_version: options.configuration.appVersion,
    language: runtime.language().slice(0, 12),
    properties: eventProperties(event),
    occurred_at: runtime.now().toISOString(),
    consent_version: options.configuration.consentVersion,
    schema_version: options.configuration.schemaVersion,
    environment: runtime.environment()
  };
}

export function createSupabaseAnalyticsProvider(options: ProviderOptions): AnalyticsProvider {
  const runtime = options.runtime ?? defaultRuntime();
  let queue: AnalyticsEnvelope[] = [];
  let flushTimer: unknown;
  let disposed = false;
  let inFlight: Promise<void> | undefined;

  if (!isValidConfiguration(options.configuration)) {
    return { track() {} };
  }

  const flush = async () => {
    if (disposed || queue.length === 0) return;
    if (inFlight) {
      await inFlight;
      if (queue.length > 0) await flush();
      return;
    }

    if (flushTimer !== undefined) {
      runtime.clearTimeout(flushTimer);
      flushTimer = undefined;
    }
    const events = queue.splice(0, maximumBatchSize);
    inFlight = runtime.fetch(options.configuration.endpoint, {
      method: "POST",
      headers: {
        Accept: "application/json",
        apikey: options.configuration.publishableKey,
        "Content-Type": "application/json"
      },
      body: JSON.stringify({ events }),
      credentials: "omit",
      keepalive: true,
      referrerPolicy: "no-referrer"
    }).then(() => undefined).catch(() => undefined).finally(() => {
      inFlight = undefined;
    });
    await inFlight;
  };

  return {
    track(event) {
      if (disposed) return;
      queue.push(createAnalyticsEnvelope(event, options, runtime));
      if (queue.length >= maximumBatchSize) {
        void flush();
      } else if (flushTimer === undefined) {
        flushTimer = runtime.setTimeout(() => {
          flushTimer = undefined;
          void flush();
        }, flushDelayMilliseconds);
      }
    },
    flush,
    dispose() {
      if (flushTimer !== undefined) runtime.clearTimeout(flushTimer);
      flushTimer = undefined;
      disposed = true;
      queue = [];
    }
  };
}
