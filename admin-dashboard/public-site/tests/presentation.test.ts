import assert from "node:assert/strict";
import test from "node:test";

import { contentKindLabel, publicWebSummary } from "../src/lib/content/presentation.ts";

const generator = (await import(new URL("../scripts/generate-public-content.mjs", import.meta.url).href)) as {
  publicWebSummary: (summary: string) => string;
};

test("web summaries remove internal governance copy without changing canonical facts", () => {
  const canonical = "!WOON is a confirmed Amsterdam housing resource. The cited source specifically covers independent housing information and tenant support in Amsterdam. This governed entry stores a verified city location and direct web route without copying mutable prices, ratings, reviews or opening hours.";
  const expected = "!WOON is a confirmed Amsterdam housing resource. The source covers independent housing information and tenant support in Amsterdam.";
  assert.equal(publicWebSummary(canonical), expected);
  assert.equal(generator.publicWebSummary(canonical), expected);
  assert.equal(publicWebSummary("A concise source-backed summary."), "A concise source-backed summary.");
});

test("guide labels expose publication depth", () => {
  assert.equal(contentKindLabel("guide", "practical"), "Step-by-step guide");
  assert.equal(contentKindLabel("guide", "summary"), "Verified summary");
  assert.equal(contentKindLabel("organization", "summary"), "Organization");
  assert.equal(contentKindLabel("page"), "Useful page");
});
