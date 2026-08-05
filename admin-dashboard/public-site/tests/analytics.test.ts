import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";
import {
  analyticsEnvironment,
  createAnalyticsEnvelope,
  createSupabaseAnalyticsProvider,
  randomUUIDv4,
  searchQueryTokenBucket,
  searchResultBucket,
  type AnalyticsConfiguration
} from "../src/lib/analytics/client.ts";

const configuration: AnalyticsConfiguration = {
  endpoint: "https://pgdzdxsiagfjioxwuqxf.supabase.co/functions/v1/analytics-ingest",
  publishableKey: "sb_publishable_test",
  consentVersion: "2026-07-28",
  schemaVersion: 1,
  appVersion: "web-test"
};

const identifiers = {
  configuration,
  appInstanceId: "11111111-1111-4111-8111-111111111111",
  sessionId: "22222222-2222-4222-8222-222222222222"
};

test("analytics environment treats only local development hosts as staging", () => {
  assert.equal(analyticsEnvironment("localhost"), "staging");
  assert.equal(analyticsEnvironment("127.0.0.1"), "staging");
  assert.equal(analyticsEnvironment("preview.localhost"), "staging");
  assert.equal(analyticsEnvironment("younew.nl"), "production");
  assert.equal(
    analyticsEnvironment("younew-netherlands-guide.tasty-finch-0991.chatgpt.site"),
    "production"
  );
});

test("analytics envelopes contain only bounded allowlisted values", () => {
  const envelope = createAnalyticsEnvelope(
    {
      name: "search",
      searchId: "77777777-7777-4777-8777-777777777777",
      searchIntent: "documents",
      resultCount: 7.8,
      hasResults: true,
      queryTokenBucket: "2-3",
      cityId: "s-gravenhage",
      profile: "worker",
      locationScope: "municipality"
    },
    identifiers,
    {
      now: () => new Date("2026-07-28T20:00:00.000Z"),
      randomUUID: () => "33333333-3333-4333-8333-333333333333",
      pathname: () => "/discover/?q=BSN-sensitive-text",
      language: () => "en",
      environment: () => "production"
    }
  );

  assert.equal(envelope.event_name, "search");
  assert.equal(envelope.screen, "/discover/");
  assert.deepEqual(envelope.properties, {
    search_id: "77777777-7777-4777-8777-777777777777",
    search_intent: "documents",
    result_count: 7,
    result_bucket: "6-10",
    has_results: true,
    query_token_bucket: "2-3",
    city_id: "s-gravenhage",
    profile: "worker",
    location_scope: "municipality"
  });
  assert.equal(JSON.stringify(envelope).includes("BSN-sensitive-text"), false);
  assert.equal(envelope.environment, "production");
  assert.equal(envelope.consent_version, "2026-07-28");
});

test("search analytics uses bounded buckets and never includes free text", () => {
  assert.equal(searchResultBucket(0), "0");
  assert.equal(searchResultBucket(1), "1");
  assert.equal(searchResultBucket(5), "2-5");
  assert.equal(searchResultBucket(51), "51+");
  assert.equal(searchQueryTokenBucket("rent"), "1");
  assert.equal(searchQueryTokenBucket("housing rent worker"), "2-3");
  assert.equal(searchQueryTokenBucket("one two three four five six seven eight"), "8+");

  const envelope = createAnalyticsEnvelope(
    {
      name: "search",
      searchId: "88888888-8888-4888-8888-888888888888",
      searchIntent: "unclassified",
      resultCount: 0,
      hasResults: false,
      queryTokenBucket: "4-7",
      categoryId: "housing",
      locationScope: "national"
    },
    identifiers,
    {
      now: () => new Date("2026-08-05T12:00:00.000Z"),
      randomUUID: () => "99999999-9999-4999-8999-999999999999",
      pathname: () => "/search/?q=private+free+text",
      language: () => "nl",
      environment: () => "production"
    }
  );

  const serialized = JSON.stringify(envelope);
  assert.equal(serialized.includes("private"), false);
  assert.equal(serialized.includes("free"), false);
  assert.deepEqual(envelope.properties, {
    search_id: "88888888-8888-4888-8888-888888888888",
    search_intent: "unclassified",
    result_count: 0,
    result_bucket: "0",
    has_results: false,
    query_token_bucket: "4-7",
    category_id: "housing",
    location_scope: "national"
  });
});

test("result-open analytics links by random search id without query text", () => {
  const envelope = createAnalyticsEnvelope(
    {
      name: "search_result_opened",
      searchId: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
      contentId: "national.housing<script>",
      resultRank: 500
    },
    identifiers,
    {
      now: () => new Date("2026-08-05T12:00:00.000Z"),
      randomUUID: () => "bbbbbbbb-bbbb-4bbb-8bbb-bbbbbbbbbbbb",
      pathname: () => "/search/",
      language: () => "en",
      environment: () => "production"
    }
  );

  assert.deepEqual(envelope.properties, {
    search_id: "aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa",
    content_id: "national.housing-script-",
    result_rank: 200
  });
});

test("planner save analytics uses the production allowlisted event and no free text", () => {
  const envelope = createAnalyticsEnvelope(
    {
      name: "item_saved",
      contentId: "planner route<script>?private=value"
    },
    identifiers,
    {
      now: () => new Date("2026-07-29T12:00:00.000Z"),
      randomUUID: () => "55555555-5555-4555-8555-555555555555",
      pathname: () => "/start/",
      language: () => "en",
      environment: () => "production"
    }
  );

  assert.equal(envelope.event_name, "item_saved");
  assert.deepEqual(envelope.properties, {
    content_id: "planner route-script--private-value"
  });
});

test("official source analytics keeps only a bounded content identifier", () => {
  const envelope = createAnalyticsEnvelope(
    {
      name: "official_source_click",
      contentId: "guide.brp<script>?private=value"
    },
    identifiers,
    {
      now: () => new Date("2026-07-29T12:00:00.000Z"),
      randomUUID: () => "66666666-6666-4666-8666-666666666666",
      pathname: () => "/guides/brp/",
      language: () => "en",
      environment: () => "production"
    }
  );

  assert.deepEqual(envelope.properties, {
    content_id: "guide.brp-script--private-value"
  });
});

test("UUID fallback creates a valid version 4 identifier", () => {
  const descriptor = Object.getOwnPropertyDescriptor(globalThis, "crypto");
  Object.defineProperty(globalThis, "crypto", {
    configurable: true,
    value: {
      getRandomValues<T extends ArrayBufferView>(array: T) {
        new Uint8Array(array.buffer, array.byteOffset, array.byteLength).fill(0xab);
        return array;
      }
    }
  });

  try {
    assert.match(
      randomUUIDv4(),
      /^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/
    );
  } finally {
    if (descriptor) Object.defineProperty(globalThis, "crypto", descriptor);
    else delete (globalThis as { crypto?: Crypto }).crypto;
  }
});

test("analytics provider batches events and sends no credentials or referrer", async () => {
  const requests: Array<{ input: RequestInfo | URL; init?: RequestInit }> = [];
  let scheduled: (() => void) | undefined;
  let sequence = 0;
  const provider = createSupabaseAnalyticsProvider({
    ...identifiers,
    runtime: {
      fetch: (async (input: RequestInfo | URL, init?: RequestInit) => {
        requests.push({ input, init });
        return new Response(JSON.stringify({ accepted: 2, stored: true }), { status: 202 });
      }) as typeof fetch,
      now: () => new Date("2026-07-28T20:00:00.000Z"),
      randomUUID: () => {
        sequence += 1;
        return sequence === 1
          ? "33333333-3333-4333-8333-333333333333"
          : "44444444-4444-4444-8444-444444444444";
      },
      pathname: () => "/discover/",
      language: () => "en",
      environment: () => "production",
      setTimeout: (callback) => {
        scheduled = callback;
        return 1;
      },
      clearTimeout: () => {
        scheduled = undefined;
      }
    }
  });

  provider.track({ name: "page_view", path: "/discover/?private=value" });
  provider.track({ name: "profile_selected" });
  assert.equal(requests.length, 0);
  assert.ok(scheduled);

  await provider.flush?.();

  assert.equal(requests.length, 1);
  assert.equal(requests[0].input, configuration.endpoint);
  assert.equal(requests[0].init?.credentials, "omit");
  assert.equal(requests[0].init?.referrerPolicy, "no-referrer");
  assert.equal((requests[0].init?.headers as Record<string, string>).apikey, configuration.publishableKey);
  const payload = JSON.parse(String(requests[0].init?.body)) as { events: Array<Record<string, unknown>> };
  assert.equal(payload.events.length, 2);
  assert.equal(payload.events[0].screen, "/discover/");
  assert.deepEqual(payload.events[1].properties, {});
});

test("invalid analytics configuration fails closed without a request", async () => {
  let requestCount = 0;
  const provider = createSupabaseAnalyticsProvider({
    ...identifiers,
    configuration: { ...configuration, endpoint: "https://example.com/collect" },
    runtime: {
      fetch: (async () => {
        requestCount += 1;
        return new Response(null, { status: 202 });
      }) as typeof fetch,
      now: () => new Date(),
      randomUUID: () => crypto.randomUUID(),
      pathname: () => "/",
      language: () => "en",
      environment: () => "staging",
      setTimeout: (callback, milliseconds) => setTimeout(callback, milliseconds),
      clearTimeout: (timer) => clearTimeout(timer as ReturnType<typeof setTimeout>)
    }
  });

  provider.track({ name: "page_view", path: "/" });
  await provider.flush?.();
  assert.equal(requestCount, 0);
});

test("the lightweight homepage shell preserves the full analytics consent flow", async () => {
  const shell = await readFile(new URL("../public/static-shell.js", import.meta.url), "utf8");

  assert.match(shell, /Help improve YouNew\?/);
  assert.match(shell, /Decline analytics/);
  assert.match(shell, /Allow anonymous analytics/);
  assert.match(shell, /globalPrivacyControl/);
  assert.match(shell, /getRandomValues/);
  assert.match(shell, /credentials: "omit"/);
  assert.match(shell, /referrerPolicy: "no-referrer"/);
  assert.match(shell, /analyticsEnvironment\(location\.hostname\)/);
  assert.match(shell, /delete window\.__YOUNEW_ANALYTICS__/);
  assert.match(shell, /data-analytics-official-source-id/);
  assert.match(shell, /official_source_click/);
  assert.doesNotMatch(shell, /analytics_consent_revoked/);
});
