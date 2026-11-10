import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import vm from "node:vm";
import test from "node:test";
import { sortSearchResults } from "../src/lib/search/sort.ts";
import type { RankedSearchResult, SearchDocument } from "../src/lib/search/rank";
import { localizedCounterpart } from "../src/lib/i18n/routes.ts";

test("language switching and hreflang share reciprocal routes including city and form context", () => {
  for (const [en,nl] of [
    ["/","/nl"], ["/city-guides/utrecht","/nl/stadsgidsen/utrecht"],
    ["/for-business/local/apply","/nl/voor-bedrijven/aanmelden"],
    ["/organizations/example","/nl/organisaties/example"],
    ["/categories/healthcare","/nl/categorieen/healthcare"], ["/search","/nl/zoeken"]
  ]) {
    assert.deepEqual(localizedCounterpart(en),{en,nl});
    assert.deepEqual(localizedCounterpart(`${nl}/`),{en,nl});
  }
  assert.equal(localizedCounterpart("/acquisition/"),null);
});

const themeScript = await readFile(new URL("../public/theme-init.js", import.meta.url), "utf8");
test("light is the default even on a dark OS; explicit saved preference and denied storage are respected", () => {
  for (const stored of [null, "invalid", "light", "dark", "throws"]) {
    const root = { dataset: {} as { theme?: string }, style: {} as { colorScheme?: string } };
    vm.runInNewContext(themeScript, { document: { documentElement: root }, window: { localStorage: { getItem() { if (stored === "throws") throw new Error("blocked"); return stored; } }, matchMedia: () => ({ matches:false }) } });
    assert.equal(root.dataset.theme, stored === "dark" ? "dark" : "light");
    assert.equal(root.style.colorScheme, root.dataset.theme);
  }
});

test("sorting preserves only governed result membership and never mutates relevance order", () => {
  const document = (id: string, title: string, verifiedAt: string | null): SearchDocument => ({
    id, title, verifiedAt, type: "guide", sourceKind: "test", slug: id, route: `/guides/${id}/`,
    summary: "Synthetic sorting fixture", keywords: [], city: null, cityId: null,
    province: null, provinceId: null, categories: [], narrowCategory: null,
    organization: null, audienceProfiles: []
  });
  const results = [
    { document: document("a", "Zorg", "2026-10-23"), score:5, matchedTerms:[] },
    { document: document("b", "Amsterdam", null), score:4, matchedTerms:[] },
    { document: document("c", "Rotterdam", "2026-10-25"), score:3, matchedTerms:[] },
    { document: document("d", "Utrecht", "invalid"), score:2, matchedTerms:[] }
  ] satisfies RankedSearchResult[];
  assert.deepEqual(sortSearchResults(results,"relevance"),results);
  assert.deepEqual(sortSearchResults(results,"title","nl").map(r=>r.document.id),["b","c","d","a"]);
  assert.deepEqual(sortSearchResults(results,"reviewed").map(r=>r.document.id),["c","a","b","d"]);
  assert.deepEqual(results.map(r=>r.document.id),["a","b","c","d"]);
});

test("NL search uses private handoff, removes query URLs and keeps accessible keyboard suggestions", async () => {
  const form = await readFile(new URL("../src/components/home-search-form.tsx",import.meta.url),"utf8");
  const search = await readFile(new URL("../src/components/nl-search-experience.tsx",import.meta.url),"utf8");
  assert.doesNotMatch(form,/name="q"/);
  assert.match(search,/takeSearchHandoff/);
  assert.doesNotMatch(search,/params\.set\("q"/);
  assert.match(search,/replaceState\(null, "", "\/nl\/zoeken\/"\)/);
  for(const control of ['role="combobox"','aria-activedescendant','role="listbox"','ArrowDown','ArrowUp','Escape','Enter']) assert.ok(search.includes(control));
});
