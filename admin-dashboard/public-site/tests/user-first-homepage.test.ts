import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const [homepage, header, footer, analytics, staticShell, taskTaxonomy] = await Promise.all([
  readFile(new URL("../src/app/page.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/components/site-header.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/components/site-footer.tsx", import.meta.url), "utf8"),
  readFile(new URL("../src/lib/analytics/client.ts", import.meta.url), "utf8"),
  readFile(new URL("../public/static-shell.js", import.meta.url), "utf8"),
  readFile(new URL("../src/lib/product/task-taxonomy.ts", import.meta.url), "utf8")
]);

test("homepage starts with one promise, one task search, and a narrowing journey", () => {
  assert.equal(homepage.match(/<h1\b/g)?.length, 1);
  assert.equal(homepage.match(/<section\b/g)?.length, 8);
  assert.match(homepage, /Your new life in the Netherlands/);
  assert.match(homepage, /What do you need in the Netherlands\?/);
  assert.match(homepage, /name="q"/);
  assert.match(homepage, /What do you need\?/);
  assert.match(homepage, /Life in the Netherlands/);
  assert.match(homepage, /Popular tasks/);
  assert.match(homepage, /Trusted services and sources/);
  assert.match(homepage, /Naruto clarifies your situation first/);
  assert.doesNotMatch(homepage, /Make the route relevant to you|getMunicipalities|HomepageProfileSelector/);
  assert.doesNotMatch(homepage, /No live public campaigns|vision-business/);
  assert.doesNotMatch(homepage, /\d+ (?:pages|categories|guides)/i);
  assert.doesNotMatch(homepage, /Supabase|\bCI\b|test counts|release authority|SystemEvidence/i);
});

test("homepage exposes exactly ten practical needs and six direct popular tasks", () => {
  for (const label of [
    "Housing",
    "Work",
    "Healthcare",
    "Documents",
    "Study",
    "Daily life",
    "Emergency",
    "LGBTIQ+",
    "Pets",
    "Family"
  ]) {
    assert.match(taskTaxonomy, new RegExp(`label: "${label.replace("+", "\\+")}"`));
  }
  assert.equal(taskTaxonomy.match(/^    id: "/gm)?.length, 10);
  assert.match(homepage, /youNewTasks\.map/);

  const popularSource = homepage.slice(homepage.indexOf("const popularTasks"), homepage.indexOf("const usefulServices"));
  assert.equal(popularSource.match(/title:/g)?.length, 6);
  assert.match(popularSource, /title: "Get a BSN"/);
  assert.match(popularSource, /title: "Register with a huisarts"/);
  assert.match(popularSource, /title: "Open a bank account"/);
  assert.match(popularSource, /title: "Learn Dutch"/);
});

test("global navigation keeps the approved ten primary destinations", () => {
  assert.match(header, /\["Explore", "\/discover"\]/);
  assert.match(header, /\["Housing", "\/tasks\/housing"\]/);
  assert.match(header, /\["Work", "\/tasks\/work"\]/);
  assert.match(header, /\["Healthcare", "\/tasks\/healthcare"\]/);
  assert.match(header, /\["Services", "\/organizations"\]/);
  assert.match(header, /\["Cities", "\/cities"\]/);
  assert.match(header, /\["Guides", "\/guides"\]/);
  assert.match(header, /\["Business", "\/business"\]/);
  assert.match(header, /\["Search", "\/search"\]/);
  assert.match(header, /\["About", "\/about"\]/);
  assert.equal(header.match(/^  \["/gm)?.length, 10);
  assert.doesNotMatch(header, /\["Naruto"|Journeys|Updates|Map|Provinces|App status|My YouNew/);
  assert.match(footer, /English interface/);
  assert.match(footer, /Practical routes for building a confident life in the Netherlands\./);
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
