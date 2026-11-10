import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const { serializeJsonLd } = (await import(new URL("../src/lib/seo/json-ld.ts", import.meta.url).href)) as {
  serializeJsonLd: (value: unknown) => string;
};

test("JSON-LD serialization cannot terminate the script element", () => {
  const serialized = serializeJsonLd({ title: "</script><script>alert(1)</script>", note: "A & B" });
  assert.doesNotMatch(serialized, /<\/script/i);
  assert.doesNotMatch(serialized, /<script/i);
  assert.match(serialized, /\\u003c/);
  assert.match(serialized, /\\u0026/);
});

test("primary navigation and homepage search keep descriptive accessible names", async () => {
  const [header, homepage, homeSearchForm] = await Promise.all([
    readFile(new URL("../src/components/site-header.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/components/discovery-home.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/components/home-search-form.tsx", import.meta.url), "utf8")
  ]);

  assert.match(header, /\["Explore", "\/#cities-title"\]/);
  assert.match(header, /\["Live", "\/#live"\]/);
  assert.match(homepage, /\/guides\//);
  assert.match(header, /\["Business", "\/for-business"\]/);
  assert.doesNotMatch(header, /"App status"|"My YouNew"/);
  assert.match(homepage, /<HomeSearchForm locale=\{locale\}/);
  assert.match(homeSearchForm, /<label htmlFor="home-search">/);
  assert.match(homeSearchForm, /aria-label=\{nl \? "Zoeken op YouNew" : "Search YouNew"\}/);
});
