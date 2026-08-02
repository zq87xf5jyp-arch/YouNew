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

test("homepage has one promise, eight user sections and no operational evidence", () => {
  assert.equal(homepage.match(/<h1\b/g)?.length, 1);
  assert.equal(homepage.match(/<section\b/g)?.length, 8);
  assert.match(homepage, /Find your next step in the Netherlands\./);
  assert.match(homepage, /Detailed web guides for five Dutch cities\./);
  assert.doesNotMatch(homepage, /Supabase|\bCI\b|test counts|release authority|SystemEvidence/i);
});

test("global navigation and footer expose the compact public information architecture", () => {
  assert.match(header, /\["Start", "\/start"\]/);
  assert.match(header, /\["Guides", "\/guides"\]/);
  assert.match(header, /\["Cities", "\/cities"\]/);
  assert.match(header, /\["Map", "\/map"\]/);
  assert.doesNotMatch(header, /Updates|Business|Organizations|Provinces|App status|My YouNew/);
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
  const menuHandler = staticShell.slice(staticShell.indexOf('menu.addEventListener("keydown"'), staticShell.indexOf('window.matchMedia("(min-width: 1001px)"'));
  assert.doesNotMatch(menuHandler, /event\.key !== "Tab"|focusable|const items/);
});
