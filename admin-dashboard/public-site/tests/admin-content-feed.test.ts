import assert from "node:assert/strict";
import test from "node:test";

import { parseAdminContentFeed } from "../src/lib/admin-content-feed.ts";

const record = {
  id: "article-a",
  kind: "article",
  title: "Registering in the Netherlands",
  slug: "registering-in-the-netherlands",
  summary: "A verified starting point.",
  content: "Use the official municipality procedure.",
  language: "en",
  categorySlug: "arrival",
  officialSourceUrl: "https://www.government.nl/topics/personal-data",
  verifiedDate: "2026-07-28",
  updatedAt: "2026-07-28T20:00:00.000Z",
  publishedAt: "2026-07-28T20:00:00.000Z"
};

const feed = {
  available: true,
  schemaVersion: 1,
  sourceVersion: "2026-07-28T20:00:00.000Z",
  fingerprint: "b".repeat(64),
  recordCount: 1,
  activatedAt: "2026-07-28T21:00:00.000Z",
  records: [record]
};

test("site parser accepts the versioned Admin feed", () => {
  const parsed = parseAdminContentFeed(feed);
  assert.equal(parsed?.available, true);
  assert.equal(parsed?.recordCount, 1);
});

test("site parser accepts only the exact empty-state contract", () => {
  assert.deepEqual(parseAdminContentFeed({
    available: false,
    schemaVersion: 1,
    recordCount: 0,
    records: []
  }), {
    available: false,
    schemaVersion: 1,
    recordCount: 0,
    records: []
  });
  assert.equal(parseAdminContentFeed({
    available: false,
    schemaVersion: 1,
    recordCount: 1,
    records: []
  }), null);
});

test("site parser rejects tampered, duplicate and unsafe content", () => {
  assert.equal(parseAdminContentFeed({ ...feed, fingerprint: "invalid" }), null);
  assert.equal(parseAdminContentFeed({ ...feed, recordCount: 2 }), null);
  assert.equal(parseAdminContentFeed({
    ...feed,
    records: [{ ...record, officialSourceUrl: "javascript:alert(1)" }]
  }), null);
  assert.equal(parseAdminContentFeed({
    ...feed,
    recordCount: 2,
    records: [record, record]
  }), null);
});
