import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const root = new URL("../", import.meta.url);
const themeToggle = await readFile(new URL("src/components/theme-toggle.tsx", root), "utf8");
const themeCss = await readFile(new URL("src/app/theme.css", root), "utf8");
const globalCss = await readFile(new URL("src/app/globals.css", root), "utf8");
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
  assert.match(staticStripper, /readFile\(join\(outputRoot, "theme-init\.js"\)/);
  assert.match(staticStripper, /<script>\$\{themeInit\}<\/script><\/head>/);
  assert.match(staticShell, /themeButton\?\.addEventListener\("click"/);
  assert.match(staticShell, /localStorage\.setItem\(themeStorageKey, nextTheme\)/);
  assert.match(themeCss, /--cyan:#006d96/);
  assert.match(themeCss, /--orange-2:#9f3d00/);
  assert.match(globalCss, /\.coverage-map-results li strong \{ color:var\(--text\)/);
  assert.match(globalCss, /\.hero-kicker[^}]*color:var\(--cyan\)!important/);
  assert.match(globalCss, /\.button-outline[^}]*color:var\(--cyan\)/);
  assert.match(globalCss, /\.product-vision-home \.theme-toggle \{ display:grid; \}/);
  assert.match(globalCss, /html\[data-theme="dark"\] \.product-vision-home/);
  assert.doesNotMatch(globalCss, /\.product-vision-home \.theme-toggle \{ display:none; \}/);
  assert.match(globalCss, /@media \(min-width:380px\) and \(max-width:760px\)[\s\S]*?\.header-emergency \{ width:auto; padding:0 10px; \}/);
  assert.match(globalCss, /\.theme-toggle,\.mobile-menu summary \{ width:44px; height:44px; \}/);
});

test("homepage keeps the branded hero in every responsive theme state", () => {
  assert.match(globalCss, /younew-brand-hero-desktop-v1\.jpg/);
  assert.match(globalCss, /younew-brand-hero-tablet-portrait-v1\.jpg/);
  assert.match(globalCss, /younew-brand-hero-mobile-v1\.jpg/);
  assert.match(globalCss, /html\[data-theme="light"\] \.product-vision-home \.site-header/);
  assert.match(globalCss, /html\[data-theme="dark"\] \.product-vision-home \.vision-hero \{ background-color:#02091a; \}/);
  assert.doesNotMatch(homepage, /vision-hero-media/);
  assert.match(homepage, /placeholder="For example: I need housing in Leiden"/);
});

test("homepage continues the branded visual system below the hero", () => {
  assert.match(homepage, /className="vision-section vision-popular section-shell"/);
  assert.match(homepage, /className="vision-section vision-why section-shell"/);
  assert.match(globalCss, /Phase 4: continue the branded Netherlands system through the complete home journey/);
  assert.match(globalCss, /\.product-vision-home \{[\s\S]*?--vision-ink:#f7fbff/);
  assert.match(globalCss, /\.vision-needs \{[\s\S]*?radial-gradient/);
  assert.match(globalCss, /\.vision-city-rail article \{[\s\S]*?scroll-snap-align:start/);
  assert.match(globalCss, /\.vision-naruto-tip \{[\s\S]*?border:1px solid rgba\(102,205,221/);
  assert.match(globalCss, /html\[data-theme="light"\] \.product-vision-home \.vision-needs/);
  assert.match(globalCss, /html\[data-theme="dark"\] \.product-vision-home \.vision-needs/);
  assert.match(globalCss, /@media \(max-width:760px\)[\s\S]*?\.vision-task-grid \{ grid-template-columns:1fr; \}/);
});

test("light mode restores semantic light surfaces across every public template", () => {
  assert.match(themeCss, /Site-wide light-theme contract/);
  assert.match(themeCss, /html\[data-theme="light"\] \.page-shell-main \{[\s\S]*?background:transparent/);
  assert.match(themeCss, /html\[data-theme="light"\] \.product-vision-home \{[\s\S]*?--vision-ink:#082463[\s\S]*?background:#eef3f8/);
  assert.match(themeCss, /html\[data-theme="light"\] \.product-vision-home main \{[\s\S]*?linear-gradient\(180deg,#fff,#f7f9fc 46%,#eef3f8\)/);
  assert.match(themeCss, /html\[data-theme="light"\] :is\(\.task-hub-page,\.about-younew-page\) \.page-shell-main/);
  assert.match(themeCss, /html\[data-theme="light"\] \.task-choice \{[\s\S]*?background:linear-gradient\(145deg,#fff,var\(--panel\)\)/);
  assert.match(themeCss, /html\[data-theme="light"\] :is\(\.guide-feedback-loop,[\s\S]*?\.journey-card,[\s\S]*?\.search-input-wrap/);
  assert.match(themeCss, /html\[data-theme="light"\] :is\(\.business-subnav,\.knowledge-trust-summary/);
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

test("operational evidence stays off the user-first homepage", () => {
  assert.match(systemEvidence, /publishedRecords:\s*204/);
  assert.match(systemEvidence, /staticRoutes:\s*626/);
  assert.match(systemEvidence, /indexableUrls:\s*616/);
  assert.match(systemEvidence, /passingWebAdminAiTests:\s*148/);
  assert.match(homepage, /<time dateTime=\{nationalVerifiedAt\}>/);
  assert.match(homepage, /Three recently checked national additions\./);
  assert.doesNotMatch(homepage, /SystemEvidence|staticRoutes|passingWebAdminAiTests|Supabase|controlled release candidate/i);
});
