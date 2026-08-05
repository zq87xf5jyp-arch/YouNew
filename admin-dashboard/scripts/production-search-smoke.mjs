import assert from "node:assert/strict";
import { mkdir, writeFile } from "node:fs/promises";
import { dirname, resolve } from "node:path";
import { chromium, devices, webkit } from "playwright";

const baseUrl = process.env.PUBLIC_SEARCH_BASE_URL;
if (!baseUrl || !/^https?:\/\//u.test(baseUrl)) {
  throw new Error("Set PUBLIC_SEARCH_BASE_URL to the exact deployment origin to test.");
}

const reportPath = resolve(process.env.PUBLIC_SEARCH_REPORT_PATH ?? "e2e-reports/public-search-production.json");
const requestedBrowsers = new Set(
  (process.env.PUBLIC_SEARCH_BROWSERS ?? "chromium,webkit").split(",").map((value) => value.trim()).filter(Boolean)
);
const criticalCases = [
  { query: "rent", city: "den-haag", profile: "worker", expected: /Housing/i },
  { query: "housing rent", city: "den-haag", profile: "worker", expected: /Housing/i },
  { query: "work", city: "leiden", expected: /Work/i },
  { query: "huisarts", city: "rotterdam", expected: /Healthcare/i },
  { query: "Dutch school", city: "groningen", expected: /Education/i },
  { query: "BSN", city: "eindhoven", expected: /Documents/i },
  { query: "SIM card", city: "maastricht", expected: /SIM.*telecom/i },
  { query: "parking fine", city: "utrecht", expected: /Fines/i }
];

function searchUrl({ query, city, profile }) {
  const url = new URL("/search/", baseUrl);
  url.searchParams.set("q", query);
  if (city) url.searchParams.set("city", city);
  if (profile) url.searchParams.set("profile", profile);
  return url.toString();
}

async function resultEvidence(page, scenario, environment) {
  await page.goto(searchUrl(scenario), { waitUntil: "domcontentloaded" });
  const heading = page.locator("#results-title");
  await heading.waitFor({ state: "visible" });
  const headingText = (await heading.textContent()) ?? "";
  const count = Number.parseInt(headingText, 10);
  assert.ok(Number.isFinite(count) && count > 0, `${environment}: ${scenario.query} returned ${headingText}`);
  const firstTitle = (await page.locator(".search-result-list article h3").first().textContent()) ?? "";
  assert.match(firstTitle, scenario.expected, `${environment}: ${scenario.query} first result was ${firstTitle}`);
  assert.equal(new URL(page.url()).searchParams.get("q"), scenario.query, `${environment}: query URL state`);
  assert.equal(new URL(page.url()).searchParams.get("city"), scenario.city, `${environment}: city URL state`);
  if (scenario.profile) {
    assert.equal(new URL(page.url()).searchParams.get("profile"), scenario.profile, `${environment}: profile URL state`);
    await page.getByText(/profile boosts relevant results/i).waitFor({ state: "visible" });
  }
  return { query: scenario.query, city: scenario.city, profile: scenario.profile ?? null, count, firstTitle };
}

async function runBrowser(name, browserType, contextOptions, launchOptions = {}) {
  const browser = await browserType.launch({ headless: true, ...launchOptions });
  const context = await browser.newContext(contextOptions);
  if (name === "desktop-chromium") {
    await context.grantPermissions(["clipboard-read", "clipboard-write"], { origin: new URL(baseUrl).origin });
  }
  const page = await context.newPage();
  if (name === "desktop-chromium") {
    await page.addInitScript(() => {
      Object.defineProperty(navigator, "share", { configurable: true, value: undefined });
    });
  }
  const runtimeErrors = [];
  page.on("pageerror", (error) => runtimeErrors.push(`pageerror: ${error.message}`));
  page.on("console", (message) => { if (message.type() === "error") runtimeErrors.push(`console: ${message.text()}`); });

  try {
    const cases = [];
    for (const scenario of criticalCases) cases.push(await resultEvidence(page, scenario, name));

    if (name === "mobile-webkit") {
      assert.equal(await page.locator("#search-filter-panel").isHidden(), true, "mobile filters must start collapsed");
      await page.locator(".search-result-list article").first().waitFor({ state: "visible" });
      const filterToggle = await page.locator(".search-filter-toggle").boundingBox();
      assert.ok(filterToggle && filterToggle.height >= 44, "mobile filter touch target must be at least 44px high");
      assert.equal(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth), true, "mobile page must not overflow horizontally");
    }

    await page.goto(searchUrl({ query: "DenHaag" }), { waitUntil: "domcontentloaded" });
    await page.locator("#results-title").waitFor({ state: "visible" });
    assert.match((await page.locator(".search-result-list article h3").first().textContent()) ?? "", /'s-Gravenhage/i);
    await page.goto(searchUrl({ query: "DenBosch" }), { waitUntil: "domcontentloaded" });
    await page.locator("#results-title").waitFor({ state: "visible" });
    assert.match((await page.locator(".search-result-list article h3").first().textContent()) ?? "", /'s-Hertogenbosch/i);

    if (name === "desktop-chromium") {
      await page.goto(searchUrl({ query: "rent", city: "den-haag" }), { waitUntil: "domcontentloaded" });
      await page.getByLabel("Profile boost").selectOption("worker");
      await page.goto(searchUrl({ query: "rent", city: "den-haag" }), { waitUntil: "domcontentloaded" });
      await page.getByText(/Worker profile boosts relevant results/i).waitFor({ state: "visible" });

      await page.getByRole("button", { name: "Share results" }).click();
      await page.getByRole("button", { name: "Link copied" }).waitFor({ state: "visible" });

      const resultLink = page.locator(".search-result-list article a").first();
      await resultLink.click();
      assert.doesNotMatch(new URL(page.url()).pathname, /^\/search\/?$/u);
      await page.goBack({ waitUntil: "domcontentloaded" });
      await page.locator("#results-title").waitFor({ state: "visible" });

      await page.getByRole("button", { name: "Clear all" }).click();
      const clearedUrl = new URL(page.url());
      assert.equal(clearedUrl.searchParams.get("q"), "rent", "clear all must preserve the query");
      assert.equal(clearedUrl.searchParams.has("city"), false, "clear all must remove the city filter");
      assert.equal(clearedUrl.searchParams.has("profile"), false, "clear all must remove the profile boost");
    }

    await page.goto(searchUrl({ query: "zzzxxyy", city: "den-haag", profile: "worker" }), { waitUntil: "domcontentloaded" });
    await page.getByRole("heading", { name: "No useful published result matched" }).waitFor({ state: "visible" });
    await page.getByRole("button", { name: "Search all Netherlands" }).waitFor({ state: "visible" });
    await page.getByRole("button", { name: "Remove profile boost" }).waitFor({ state: "visible" });
    await page.getByRole("link", { name: "Browse life domains" }).waitFor({ state: "visible" });

    assert.deepEqual(runtimeErrors, [], `${name} runtime errors`);
    return { name, cases, runtimeErrors };
  } finally {
    await browser.close();
  }
}

const startedAt = new Date().toISOString();
const results = [];
for (const environment of [
  {
    id: "chromium",
    name: "desktop-chromium",
    browserType: chromium,
    contextOptions: { viewport: { width: 1440, height: 900 } },
    launchOptions: process.env.PUBLIC_SEARCH_CHROMIUM_CHANNEL ? { channel: process.env.PUBLIC_SEARCH_CHROMIUM_CHANNEL } : {}
  },
  { id: "webkit", name: "mobile-webkit", browserType: webkit, contextOptions: { ...devices["iPhone 13"] }, launchOptions: {} }
].filter((environment) => requestedBrowsers.has(environment.id))) {
  results.push(await runBrowser(environment.name, environment.browserType, environment.contextOptions, environment.launchOptions));
}

assert.ok(results.length > 0, "PUBLIC_SEARCH_BROWSERS did not select a supported browser");

const report = {
  schemaVersion: 1,
  baseUrl,
  startedAt,
  completedAt: new Date().toISOString(),
  verdict: "GO",
  environments: results
};
await mkdir(dirname(reportPath), { recursive: true });
await writeFile(reportPath, `${JSON.stringify(report, null, 2)}\n`, "utf8");
console.log(`Production search smoke passed: ${criticalCases.length} cases × ${results.length} browsers. Report: ${reportPath}`);
