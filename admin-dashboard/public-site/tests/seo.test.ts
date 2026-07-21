import assert from "node:assert/strict";
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
