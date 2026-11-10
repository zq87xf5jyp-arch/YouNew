import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const [homepage, header, footer, analytics, staticShell, homeForm] = await Promise.all([
  readFile(new URL("../src/components/discovery-home.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/components/site-header.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/components/site-footer.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/lib/analytics/client.ts", import.meta.url), "utf8"),
  readFile(new URL("../public/static-shell.js", import.meta.url), "utf8"),
  readFile(new URL("../src/components/home-search-form.tsx", import.meta.url), "utf8")
]);

test("bilingual discovery home keeps one promise, private search and honest paths", () => {
  assert.equal(homepage.match(/<h1\b/g)?.length, 1);
  assert.match(homepage, /What would you like/);
  assert.match(homepage, /Wat wil je doen/);
  assert.match(homepage, /<HomeSearchForm locale=\{locale\}/);
  assert.doesNotMatch(homeForm, /name="q"/);
  assert.match(homeForm, /handoffSearch/);
  assert.match(homepage, /No payment\. No automatic publication/);
  assert.match(homepage, /Unconfirmed profiles and publication candidates stay outside search results/);
  assert.doesNotMatch(homepage, /\d+ (?:pages|categories|guides)|Supabase|test counts|SystemEvidence/i);
});

test("discovery imagery remains local, eager only for the hero, and licensed", async () => {
  const media = JSON.parse(await readFile(new URL("../src/content/discovery-media.json", import.meta.url), "utf8"));
  assert.equal(Object.keys(media).length, 5);
  for (const [slug, asset] of Object.entries(media) as Array<[string, {url:string; attribution:string; license:string; sourcePageUrl:string; variants:Array<{url:string; bytes:number}>}]>) {
    assert.match(asset.url, new RegExp(`/images/cities/${slug}-1920\\.webp`));
    assert.ok(asset.attribution && asset.license);
    assert.match(asset.sourcePageUrl, /^https:\/\/commons\.wikimedia\.org\/wiki\/File:/);
    for (const variant of asset.variants) { const data = await readFile(new URL(`../public${variant.url}`, import.meta.url)); assert.equal(data.length, variant.bytes); }
  }
  assert.match(homepage, /variant="hero"[^>]*eager/);
  assert.match(homepage, /discoveryMedia\[guide\.slug\]/);
});

test("discovery home exposes five real cities, six useful topics and three practical starts", () => {
  for (const city of ["amsterdam", "rotterdam", "den-haag", "utrecht", "eindhoven"]) assert.ok(homepage.includes(city));
  for (const category of ["culture", "food-drink", "outdoors", "organizations", "government", "/start/"]) assert.ok(homepage.includes(category));
  for (const topic of ["BSN BRP", "GP health insurance", "housing renting"]) assert.ok(homepage.includes(topic));
  assert.match(homepage, /cityGuides\.map/);
  assert.match(homepage, /\/nl\/stadsgidsen\//);
  assert.match(homepage, /\/city-guides\//);
});

test("compact navigation preserves bilingual core routes and emergency access", () => {
  for (const route of ["/#live", "/#cities-title", "/for-business", "/emergency", "/nl/#live", "/nl/#cities-title", "/nl/voor-bedrijven"]) assert.ok(header.includes(route));
  assert.match(header, /aria-label=\{isDutch \? "Navigatiemenu" : "Navigation menu"/);
  for (const route of ["/privacy/", "/terms/", "/support/", "/status/", "/app/"]) assert.ok(footer.includes(route));
  assert.match(footer, /LanguageLink locale=\{locale\} expanded/);
  assert.match(homepage, /\/leiden\//);
  assert.match(homepage, /\/nl\/leiden\//);
  for (const path of ["I live here", "I want to explore", "I own a business"]) assert.ok(homepage.includes(path));
});

test("profile analytics records only the action and never the selected profile", () => {
  assert.match(analytics, /\{ name: "profile_selected" \}/);
  assert.doesNotMatch(analytics, /name: "profile_selected"; profile:/);
  assert.doesNotMatch(analytics, /profile: safeProperty|filter_profile:|normalized_query_safe:/);
});

test("exported homepage runtime preserves profile personalization without a focus trap", () => {
  assert.match(staticShell, /homeProfileStorageKey = "younew\.web\.profile\.v1"/);
  assert.match(staticShell, /analyticsProvider\?\.track\("profile_selected"\)/);
  assert.match(staticShell, /renderHomeProfile\(readHomeProfile\(\)\)/);
  const menuHandler = staticShell.slice(staticShell.indexOf('menu.addEventListener("keydown"'), staticShell.indexOf('window.matchMedia("(min-width: 1281px)"'));
  assert.doesNotMatch(menuHandler, /event\.key !== "Tab"|focusable|const items/);
});
