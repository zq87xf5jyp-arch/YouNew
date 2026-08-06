import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const [homepage, header, footer, analytics, staticShell] = await Promise.all([
  readFile(new URL("../src/app/page.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/components/site-header.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/components/site-footer.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/lib/analytics/client.ts", import.meta.url), "utf8"),
  readFile(new URL("../public/static-shell.js", import.meta.url), "utf8")
]);

test("homepage starts with one promise, one task search, and a narrowing journey", () => {
  assert.equal(homepage.match(/<h1\b/g)?.length, 1);
  assert.equal(homepage.match(/<section\b/g)?.length, 10);
  assert.match(homepage, /Your guide to life in the Netherlands\./);
  assert.match(homepage, /What do you need in the Netherlands\?/);
  assert.match(homepage, /name="q"/);
  assert.match(homepage, /What do you need\?/);
  assert.match(homepage, /Life in the Netherlands/);
  assert.match(homepage, /Popular tasks/);
  assert.match(homepage, /Make the route relevant to you/);
  assert.match(homepage, /keeps national guidance visible and adds local context/);
  assert.match(homepage, /getMunicipalities/);
  assert.match(homepage, /Useful services/);
  assert.match(homepage, /Trusted resources/);
  assert.match(homepage, /No live public campaigns/);
  assert.match(homepage, /never shown in emergency guidance/);
  assert.match(homepage, /never replace responsible official sources/);
  assert.match(homepage, /never change organic search ranking/);
  assert.doesNotMatch(homepage, /\d+ (?:pages|categories|guides)/i);
  assert.doesNotMatch(homepage, /Supabase|\bCI\b|test counts|release authority|SystemEvidence/i);
});

test("homepage exposes ten user needs and ten concrete popular tasks", () => {
  const destinationsSource = homepage.slice(homepage.indexOf("const taskDestinations"), homepage.indexOf("const lifeDirections"));
  for (const title of [
    "Find housing",
    "Find work",
    "Healthcare",
    "Documents",
    "Study",
    "Daily life",
    "Emergency",
    "LGBTQ+",
    "Pets",
    "Families"
  ]) {
    assert.match(destinationsSource, new RegExp(`title: "${title.replace("+", "\\+")}"`));
  }
  assert.equal(destinationsSource.match(/title:/g)?.length, 10);

  const popularSource = homepage.slice(homepage.indexOf("const popularTasks"), homepage.indexOf("const usefulServices"));
  assert.equal(popularSource.match(/title:/g)?.length, 10);
  assert.match(popularSource, /title: "Get a BSN"/);
  assert.match(popularSource, /title: "Register with a huisarts"/);
});

test("global navigation keeps the product vision to nine primary destinations", () => {
  assert.match(header, /\["Explore", "\/discover"\]/);
  assert.match(header, /\["Naruto", "\/naruto"\]/);
  assert.match(header, /\["Housing", "\/categories\/housing"\]/);
  assert.match(header, /\["Work", "\/search\/\?q=work"\]/);
  assert.match(header, /\["Healthcare", "\/categories\/healthcare"\]/);
  assert.match(header, /\["Services", "\/organizations"\]/);
  assert.match(header, /\["Cities", "\/cities"\]/);
  assert.match(header, /\["Guides", "\/guides"\]/);
  assert.match(header, /\["Business", "\/business"\]/);
  assert.equal(header.match(/^  \["/gm)?.length, 9);
  assert.doesNotMatch(header, /Journeys|Updates|Map|Provinces|App status|My YouNew/);
  assert.match(footer, /Website language:<\/strong> English/);
  assert.match(footer, /Helping newcomers build a confident life in the Netherlands\./);
  assert.match(homepage, /href="\/naruto\/"/);
  assert.match(homepage, /Ask Naruto/);
});

test("profile analytics records only the action and never the selected profile", () => {
  assert.match(analytics, /\{ name: "profile_selected" \}/);
  assert.doesNotMatch(analytics, /name: "profile_selected"; profile:/);
  assert.match(analytics, /case "profile_selected":\s*\n\s*case "analytics_consent_granted":\s*\n\s*return \{\};/);
});

test("exported homepage runtime preserves profile personalization without a focus trap", () => {
  assert.match(staticShell, /homeProfileStorageKey = "younew\.web\.profile\.v1"/);
  assert.match(staticShell, /analyticsProvider\?\.track\("profile_selected"\)/);
  assert.match(staticShell, /renderHomeProfile\(readHomeProfile\(\)\)/);
  assert.match(staticShell, /worker:\s*\{/);
  assert.match(staticShell, /resident:\s*\{/);
  assert.match(staticShell, /data-home-municipality/);
  assert.match(staticShell, /new URLSearchParams\(\{ task, profile: current\.plannerProfile, area \}\)/);
  assert.doesNotMatch(staticShell, /first-registration-in-amsterdam/);
  const menuHandler = staticShell.slice(staticShell.indexOf('menu.addEventListener("keydown"'), staticShell.indexOf('window.matchMedia("(min-width: 1281px)"'));
  assert.doesNotMatch(menuHandler, /event\.key !== "Tab"|focusable|const items/);
});
