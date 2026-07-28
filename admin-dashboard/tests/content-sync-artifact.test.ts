import assert from "node:assert/strict";
import test from "node:test";

import {
  buildPublishedContentArtifact,
  fingerprintArtifact,
  type PublishedArticleRecord
} from "../supabase/functions/prepare-content-sync/artifact.ts";

const records: PublishedArticleRecord[] = [
  {
    id: "b",
    title: "Second",
    slug: "second",
    short_description: "Second summary",
    full_content: "Second content",
    language: "en",
    source_url: "https://government.nl/second",
    verified_date: "2026-07-28",
    updated_at: "2026-07-28T10:00:00.000Z",
    published_at: "2026-07-28T10:00:00.000Z",
    category_id: "category-b",
    categories: { slug: "work" }
  },
  {
    id: "a",
    title: "First",
    slug: "first",
    short_description: "First summary",
    full_content: "First content",
    language: "en",
    source_url: "https://government.nl/first",
    verified_date: "2026-07-27",
    updated_at: "2026-07-27T10:00:00.000Z",
    published_at: "2026-07-27T10:00:00.000Z",
    category_id: "category-a",
    categories: [{ slug: "arrival" }]
  }
];

test("content sync artifact is stable, sorted and retry-idempotent", async () => {
  const forward = buildPublishedContentArtifact(records);
  const reversed = buildPublishedContentArtifact([...records].reverse());
  assert.deepEqual(forward, reversed);
  assert.deepEqual(forward.records.map((record) => record.id), ["a", "b"]);
  assert.equal(forward.sourceVersion, "2026-07-28T10:00:00.000Z");
  assert.equal(await fingerprintArtifact(forward), await fingerprintArtifact(reversed));
});
