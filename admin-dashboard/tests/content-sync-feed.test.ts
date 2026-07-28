import assert from "node:assert/strict";
import test from "node:test";

import {
  buildPublicContentFeed,
  emptyPublicContentFeed
} from "../src/lib/content-sync-feed.ts";

const record = {
  id: "article-a",
  kind: "article",
  title: "Registering in the Netherlands",
  slug: "registering-in-the-netherlands",
  summary: "A verified starting point.",
  content: "Use the official municipality procedure.",
  language: "en",
  categorySlug: "arrival",
  officialSourceUrl: "https://www.government.nl/topics/personal-data/question-and-answer/when-should-i-register-with-the-personal-records-database",
  verifiedDate: "2026-07-28",
  updatedAt: "2026-07-28T20:00:00.000Z",
  publishedAt: "2026-07-28T20:00:00.000Z"
};

const row = {
  source_version: "2026-07-28T20:00:00.000Z",
  artifact_fingerprint: "a".repeat(64),
  record_count: 1,
  activated_at: "2026-07-28T21:00:00.000Z",
  artifact: {
    schemaVersion: 1,
    source: "supabase-operational",
    sourceVersion: "2026-07-28T20:00:00.000Z",
    recordCount: 1,
    records: [record]
  }
};

test("public content feed accepts one activated, source-backed article", () => {
  const feed = buildPublicContentFeed(row);
  assert.equal(feed.available, true);
  assert.equal(feed.recordCount, 1);
  if (!feed.available) return;
  assert.equal(feed.records[0]?.title, record.title);
  assert.equal(feed.fingerprint, "a".repeat(64));
});

test("public content feed exposes an explicit safe empty state", () => {
  assert.deepEqual(emptyPublicContentFeed(), {
    available: false,
    schemaVersion: 1,
    recordCount: 0,
    records: []
  });
});

test("public content feed fails closed on mismatches and unsafe records", () => {
  assert.throws(() => buildPublicContentFeed({ ...row, record_count: 2 }), /invalid_public_content_feed/);
  assert.throws(
    () => buildPublicContentFeed({
      ...row,
      artifact: { ...row.artifact, sourceVersion: "different" }
    }),
    /invalid_public_content_feed/
  );
  assert.throws(
    () => buildPublicContentFeed({
      ...row,
      artifact: {
        ...row.artifact,
        records: [{ ...record, officialSourceUrl: "http://example.com" }]
      }
    }),
    /invalid_public_content_record/
  );
  assert.throws(
    () => buildPublicContentFeed({
      ...row,
      record_count: 2,
      artifact: { ...row.artifact, recordCount: 2, records: [record, record] }
    }),
    /duplicate_public_content_record_id/
  );
});
