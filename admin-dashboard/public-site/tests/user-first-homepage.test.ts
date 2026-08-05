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

test("homepage keeps one promise, adds discovery and business, and exposes no operational evidence", () => {
  assert.equal(homepage.match(/<h1\b/g)?.length, 1);
  assert.equal(homepage.match(/<section\b/g)?.length, 11);
  assert.match(homepage, /Find your next step in the Netherlands\./);
  assert.match(homepage, /Discover the Netherlands/);
  assert.match(homepage, /Cities, provinces, places and organizations\./);
  assert.match(homepage, /City coverage for five Dutch cities\./);
  assert.match(homepage, /0[\s\S]*live public campaigns/);
  assert.match(homepage, /Sponsored placements are off\./);
  assert.match(homepage, /Never shown in emergency guidance/);
  assert.match(homepage, /Never replaces responsible official sources/);
  assert.match(homepage, /Never changes organic search ranking/);
  assert.doesNotMatch(homepage, /Detailed web guides for five Dutch cities\./);
  assert.doesNotMatch(homepage, /Supabase|\bCI\b|test counts|release authority|SystemEvidence/i);
});

test("homepage task titles expose Amsterdam scope before navigation", () => {
  const taskSource = homepage.slice(homepage.indexOf("const popularTasks"), homepage.indexOf("const cities"));
  for (const title of [
    "Register in Amsterdam and get a BSN",
    "Renting a home in Amsterdam",
    "Driving licence in Amsterdam",
    "Amsterdam municipal taxes",
    "Report a street problem in Amsterdam"
  ]) {
    assert.match(taskSource, new RegExp(`title: "${title}"`));
  }

  const emergencyTask = taskSource.match(/\{\s*title: "Get emergency help"[\s\S]*?\n\s*\}/)?.[0];
  assert.ok(emergencyTask, "The national emergency task must remain published");
  assert.doesNotMatch(emergencyTask, /Amsterdam/i);
});

test("global navigation restores discovery, journeys, updates and business", () => {
  assert.match(header, /\["Start", "\/start"\]/);
  assert.match(header, /\["Discover", "\/discover"\]/);
  assert.match(header, /\["Guides", "\/guides"\]/);
  assert.match(header, /\["Journeys", "\/journeys"\]/);
  assert.match(header, /\["Cities", "\/cities"\]/);
  assert.match(header, /\["Map", "\/map"\]/);
  assert.match(header, /\["Updates", "\/updates"\]/);
  assert.match(header, /\["Business", "\/business"\]/);
  assert.doesNotMatch(header, /Organizations|Provinces|App status|My YouNew/);
  assert.match(footer, /Website language:<\/strong> English/);
  assert.doesNotMatch(footer, /pending content review/i);
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
  const menuHandler = staticShell.slice(staticShell.indexOf('menu.addEventListener("keydown"'), staticShell.indexOf('window.matchMedia("(min-width: 1281px)"'));
  assert.doesNotMatch(menuHandler, /event\.key !== "Tab"|focusable|const items/);
});
