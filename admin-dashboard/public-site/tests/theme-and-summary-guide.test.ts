import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const root = new URL("../", import.meta.url);
const themeToggle = await readFile(new URL("src/components/theme-toggle.tsx", root), "utf8");
const themeCss = await readFile(new URL("src/app/theme.css", root), "utf8");
const themeInit = await readFile(new URL("public/theme-init.js", root), "utf8");
const staticShell = await readFile(new URL("public/static-shell.js", root), "utf8");
const staticStripper = await readFile(new URL("scripts/strip-static-client.mjs", root), "utf8");
const summaryData = await readFile(new URL("src/lib/content/curated-summary-guides.ts", root), "utf8");
const summaryComponent = await readFile(new URL("src/components/useful-summary-guide.tsx", root), "utf8");
const guideDetail = await readFile(new URL("src/components/guide-detail.tsx", root), "utf8");
const pageHelpers = await readFile(new URL("src/lib/content/page-helpers.ts", root), "utf8");
const shareButton = await readFile(new URL("src/components/share-button.tsx", root), "utf8");
const systemEvidence = await readFile(new URL("src/config/system-evidence.ts", root), "utf8");
const homepage = await readFile(new URL("src/app/page.tsx", root), "utf8");

test("theme control supports persistent light and dark modes", () => {
  assert.match(themeInit, /younew\.theme\.v1/);
  assert.match(themeInit, /prefers-color-scheme: light/);
  assert.match(themeToggle, /aria-label=\{theme \? `Switch to \$\{nextTheme\} mode`/);
  assert.match(themeToggle, /localStorage\.setItem\(STORAGE_KEY, nextTheme\)/);
  assert.match(themeCss, /html\[data-theme="light"\]/);
  assert.match(themeCss, /color-scheme:light/);
  assert.match(staticStripper, /<script src="\/theme-init\.js"><\/script><\/head>/);
  assert.match(staticShell, /themeButton\?\.addEventListener\("click"/);
  assert.match(staticShell, /localStorage\.setItem\(themeStorageKey, nextTheme\)/);
});

test("Amsterdam driving licence summary uses the current official source and actionable facts", () => {
  assert.match(summaryData, /https:\/\/www\.amsterdam\.nl\/en\/civil-affairs\/applying-dutch-driving-licence\//);
  assert.match(summaryData, /Driving licence in Amsterdam/);
  assert.match(summaryData, /Amsterdam residents/);
  assert.match(summaryData, /Collect after 1 week/);
  assert.match(summaryData, /€53\.65/);
  assert.doesNotMatch(summaryData, /civil-affairs\/driving-licence\//);
});

test("useful summary exposes a working source action, saved state, share action and expandable details", () => {
  assert.match(summaryComponent, /<SaveButton/);
  assert.match(summaryComponent, /<ShareButton/);
  assert.match(summaryComponent, /target="_blank"/);
  assert.match(summaryComponent, /<details className=\{styles\.fact\}/);
  assert.match(summaryComponent, /aria-label="Key application facts"/);
  assert.match(shareButton, /aria-label=\{`Share \$\{title\}`\}/);
});

test("curated source truth also drives metadata and Article JSON-LD", () => {
  assert.match(pageHelpers, /curatedSummary\?\.title/);
  assert.match(pageHelpers, /curatedSummary\?\.answer/);
  assert.match(guideDetail, /headline: curatedSummary\?\.title/);
  assert.match(guideDetail, /isBasedOn: curatedSummary\?\.sourceUrl/);
  assert.match(guideDetail, /dateModified: curatedSummary\?\.checkedAt/);
});

test("homepage evidence stays aligned with the current generated release", () => {
  assert.match(systemEvidence, /publishedRecords:\s*183/);
  assert.match(systemEvidence, /staticRoutes:\s*582/);
  assert.match(systemEvidence, /indexableUrls:\s*572/);
  assert.match(systemEvidence, /passingWebAdminAiTests:\s*129/);
  assert.match(homepage, /releaseId\.startsWith\("amsterdam-"\)/);
  assert.doesNotMatch(homepage, /releaseId === "amsterdam-v0\.1\.4"/);
});
