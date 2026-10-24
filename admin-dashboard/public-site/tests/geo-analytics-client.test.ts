import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import {
  createAnalyticsEnvelope,
  createSupabaseAnalyticsProvider,
  track,
  type AnalyticsConfiguration,
  type AnalyticsEvent,
  type AnalyticsProvider
} from "../src/lib/analytics/client.ts";
import { privacySafeSearchQuery } from "../src/lib/search/taxonomy.ts";

const configuration: AnalyticsConfiguration = {
  endpoint: "https://pgdzdxsiagfjioxwuqxf.supabase.co/functions/v1/analytics-ingest",
  publishableKey: "sb_publishable_test",
  consentVersion: "2026-07-28",
  schemaVersion: 1,
  appVersion: "web-ranking-test"
};

const identifiers = {
  configuration,
  appInstanceId: "11111111-1111-4111-8111-111111111111",
  sessionId: "22222222-2222-4222-8222-222222222222"
};

const envelopeRuntime = {
  now: () => new Date("2026-08-19T10:00:00.000Z"),
  randomUUID: () => "33333333-3333-4333-8333-333333333333",
  pathname: () => "/search/?q=private+medical+question&email=person@example.com",
  language: () => "en",
  environment: () => "staging" as const
};

type CapturedRequest = { input: RequestInfo | URL; init?: RequestInit };

function providerHarness(fetchImplementation?: typeof fetch) {
  const requests: CapturedRequest[] = [];
  let scheduled: (() => void) | undefined;
  let sequence = 0;
  const runtimeFetch = fetchImplementation ?? (async (input: RequestInfo | URL, init?: RequestInit) => {
    requests.push({ input, init });
    return new Response(JSON.stringify({ accepted: 1, stored: true }), { status: 202 });
  }) as typeof fetch;
  const provider = createSupabaseAnalyticsProvider({
    ...identifiers,
    runtime: {
      fetch: runtimeFetch,
      now: envelopeRuntime.now,
      randomUUID: () => {
        sequence += 1;
        return `00000000-0000-4000-8000-${String(sequence).padStart(12, "0")}`;
      },
      pathname: envelopeRuntime.pathname,
      language: envelopeRuntime.language,
      environment: envelopeRuntime.environment,
      setTimeout: (callback) => {
        scheduled = callback;
        return 1;
      },
      clearTimeout: () => {
        scheduled = undefined;
      }
    }
  });
  return { provider, requests, scheduled: () => scheduled };
}

function withWindow(value: { __YOUNEW_ANALYTICS__?: AnalyticsProvider }, callback: () => void | Promise<void>) {
  const descriptor = Object.getOwnPropertyDescriptor(globalThis, "window");
  Object.defineProperty(globalThis, "window", { configurable: true, value });
  return Promise.resolve(callback()).finally(() => {
    if (descriptor) Object.defineProperty(globalThis, "window", descriptor);
    else delete (globalThis as { window?: unknown }).window;
  });
}

test("no consent means the global track facade records no event", async () => {
  const { provider, requests } = providerHarness();
  await withWindow({}, async () => {
    track({ name: "explicit_city_detected", city: "leiden", intentId: "healthcare" });
    await provider.flush?.();
  });
  assert.equal(requests.length, 0);
});

test("consent grant enables permitted geo events in one batched request", async () => {
  const { provider, requests, scheduled } = providerHarness();
  await withWindow({ __YOUNEW_ANALYTICS__: provider }, async () => {
    track({ name: "analytics_consent_granted" });
    track({ name: "explicit_city_detected", city: "leiden", intentId: "healthcare" });
    track({ name: "city_filter_corrected", city: "leiden", source: "query" });
    track({ name: "national_fallback_shown", city: "leiden", intentId: "healthcare" });
    assert.ok(scheduled());
    assert.equal(requests.length, 0, "track must not synchronously perform network I/O");
    await provider.flush?.();
  });

  assert.equal(requests.length, 1, "a geo action sequence must be batched, not N+1 requests");
  const payload = JSON.parse(String(requests[0].init?.body)) as {
    events: Array<{ event_name: string; properties: Record<string, unknown> }>;
  };
  assert.deepEqual(payload.events.map((event) => event.event_name), [
    "analytics_consent_granted",
    "explicit_city_detected",
    "city_filter_corrected",
    "national_fallback_shown"
  ]);
  assert.deepEqual(payload.events[1].properties, { city: "leiden", intent_id: "healthcare" });
  assert.deepEqual(payload.events[2].properties, { city: "leiden", source: "query" });
  assert.deepEqual(payload.events[3].properties, { city: "leiden", intent_id: "healthcare" });
});

test("consent withdrawal removes the provider and prevents subsequent writes", async () => {
  const { provider, requests } = providerHarness();
  const browserWindow: { __YOUNEW_ANALYTICS__?: AnalyticsProvider } = {
    __YOUNEW_ANALYTICS__: provider
  };
  await withWindow(browserWindow, async () => {
    track({ name: "explicit_city_detected", city: "leiden", intentId: "healthcare" });
    delete browserWindow.__YOUNEW_ANALYTICS__;
    provider.dispose?.();
    track({ name: "national_fallback_shown", city: "leiden", intentId: "healthcare" });
    provider.track({ name: "official_source_click", contentId: "guide.healthcare" });
    await provider.flush?.();
  });
  assert.equal(requests.length, 0, "withdrawal must discard the queued event without a network request");
});

test("geo event envelopes discard injected raw-query and PII fields", () => {
  const maliciousExtras = {
    rawQuery: "My condition is private",
    email: "person@example.com",
    phone: "+31 6 12345678",
    ip: "203.0.113.4",
    coordinates: "52.16,4.49"
  };
  const events = [
    { name: "explicit_city_detected", city: "leiden", intentId: "healthcare", ...maliciousExtras },
    { name: "city_filter_corrected", city: "leiden", source: "query", ...maliciousExtras },
    { name: "national_fallback_shown", city: "leiden", intentId: "healthcare", ...maliciousExtras },
    { name: "action_panel_cta_clicked", city: "leiden", contentId: "guide.healthcare", ...maliciousExtras }
  ] as unknown as AnalyticsEvent[];

  const envelopes = events.map((event) => createAnalyticsEnvelope(event, identifiers, envelopeRuntime));
  assert.deepEqual(envelopes.map((envelope) => Object.keys(envelope.properties).sort()), [
    ["city", "intent_id"],
    ["city", "source"],
    ["city", "intent_id"],
    ["city", "content_id"]
  ]);
  const serialized = JSON.stringify(envelopes);
  assert.doesNotMatch(serialized, /condition|person@example|12345678|203\.0\.113|52\.16|rawQuery/i);
  assert.ok(envelopes.every((envelope) => envelope.screen === "/search/"));
  assert.ok(envelopes.every((envelope) => envelope.app_version === "web-ranking-test"));
});

test("search privacy normalization rejects raw identifiers and unknown free text", () => {
  assert.equal(privacySafeSearchQuery("person@example.com needs a huisarts"), "[redacted]");
  assert.equal(privacySafeSearchQuery("Call +31 6 12345678 about healthcare"), "[redacted]");
  assert.equal(privacySafeSearchQuery("My private medical situation in Leiden"), "[unmapped]");
  assert.equal(privacySafeSearchQuery("healthcare"), "healthcare");

  const envelope = createAnalyticsEnvelope(
    {
      name: "search_result_opened",
      contentId: "guide.healthcare",
      position: 1,
      normalizedQuery: privacySafeSearchQuery("person@example.com needs a huisarts")
    },
    identifiers,
    envelopeRuntime
  );
  assert.equal(envelope.properties.normalized_query_safe, "[redacted]");
  assert.doesNotMatch(JSON.stringify(envelope), /person@example|needs a huisarts/i);
});

test("first-result, official-source and Action Panel clicks use canonical aliases", async () => {
  const [searchSource, officialSource] = await Promise.all([
    readFile(new URL("../src/components/search-experience.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/components/tracked-official-source-link.tsx", import.meta.url), "utf8")
  ]);

  assert.match(searchSource, /name: "search_result_opened"[\s\S]{0,180}position: index \+ 1/);
  assert.match(searchSource, /name: "official_source_click", contentId: primaryNationalGuide\.id/);
  assert.match(officialSource, /track\(\{ name: "official_source_click", contentId \}\)/);
  assert.match(officialSource, /track\(\{ name: "action_panel_cta_clicked", contentId, city: actionPanelCity \}\)/);
  assert.doesNotMatch(searchSource + officialSource, /first_result_clicked|official_source_clicked/);
});

test("analytics failure is isolated and track remains fire-and-forget", async () => {
  let attempts = 0;
  const failingFetch = (async () => {
    attempts += 1;
    throw new Error("synthetic analytics outage");
  }) as typeof fetch;
  const { provider } = providerHarness(failingFetch);

  assert.equal(
    provider.track({ name: "action_panel_cta_clicked", contentId: "guide.healthcare", city: "leiden" }),
    undefined
  );
  const flush = provider.flush;
  assert.ok(flush);
  await assert.doesNotReject(flush());
  assert.equal(attempts, 1);
});

test("public analytics configuration exposes only a publishable key", async () => {
  const [configSource, clientSource, consentSource] = await Promise.all([
    readFile(new URL("../src/config/site-config.json", import.meta.url), "utf8"),
    readFile(new URL("../src/lib/analytics/client.ts", import.meta.url), "utf8"),
    readFile(new URL("../src/components/analytics-consent.tsx", import.meta.url), "utf8")
  ]);
  const config = JSON.parse(configSource) as { analytics: AnalyticsConfiguration & { enabled: boolean } };

  assert.match(config.analytics.publishableKey, /^sb_publishable_/);
  assert.doesNotMatch(configSource + clientSource + consentSource, /service[_ -]?role|SUPABASE_SERVICE_ROLE_KEY/i);
  assert.doesNotMatch(clientSource, /Authorization\s*:/i);
  assert.match(consentSource, /choice !== "accepted"/);
  assert.match(consentSource, /delete window\.__YOUNEW_ANALYTICS__/);
  assert.match(consentSource, /provider\.dispose\?\.\(\)/);
  const declineHandler = consentSource.slice(
    consentSource.indexOf("const decline = () =>"),
    consentSource.indexOf("return (", consentSource.indexOf("const decline = () =>"))
  );
  assert.match(declineHandler, /delete window\.__YOUNEW_ANALYTICS__/);
  assert.match(declineHandler, /provider\?\.dispose\?\.\(\)/);
  assert.doesNotMatch(declineHandler, /flush/);
});
