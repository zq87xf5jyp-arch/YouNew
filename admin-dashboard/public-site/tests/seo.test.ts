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

test("JSON-LD keeps the canonical origin without a rewrite-sensitive hostname literal", () => {
  const value = {
    url: "https://younew.nl/discover/",
    email: "support@younew.nl"
  };
  const serialized = serializeJsonLd(value);

  assert.doesNotMatch(serialized, /younew\.nl/);
  assert.match(serialized, /younew\\u002enl/);
  assert.deepEqual(JSON.parse(serialized), value);
});

test("primary navigation and homepage search keep descriptive accessible names", async () => {
  const [header, homepage] = await Promise.all([
    readFile(new URL("../src/components/site-header.tsx", import.meta.url), "utf8"),
    readFile(new URL("../src/app/page.tsx", import.meta.url), "utf8")
  ]);

  assert.match(header, /\["Explore", "\/discover"\]/);
  assert.match(header, /\["Housing", "\/tasks\/housing"\]/);
  assert.match(header, /\["Healthcare", "\/tasks\/healthcare"\]/);
  assert.match(header, /\["Business", "\/business"\]/);
  assert.match(header, /\["Search", "\/search"\]/);
  assert.match(header, /\["About", "\/about"\]/);
  assert.doesNotMatch(header, /"App status"|"My YouNew"/);
  assert.match(homepage, /<label htmlFor="home-search">What do you need in the Netherlands\?<\/label>/);
  assert.match(homepage, /aria-label="Search YouNew"/);
  assert.match(homepage, /href="\/naruto\/"/);
});
