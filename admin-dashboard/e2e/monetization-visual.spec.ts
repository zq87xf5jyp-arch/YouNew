import { expect, test, type Page, type Route } from "@playwright/test";
import { mkdir } from "node:fs/promises";
import { join } from "node:path";

const screenshotRoot = join(process.cwd(), "visual-validation", "screenshots");
const businessEndpoint = "https://pgdzdxsiagfjioxwuqxf.supabase.co/functions/v1/submit-business-inquiry";
const syntheticLead = Object.freeze({
  companyName: "Synthetic Mobility Test BV",
  contactPerson: "Synthetic Reviewer",
  contactRole: "Global Mobility Lead",
  email: "visual-validation@example.test",
  website: "https://example.test",
  kvkNumber: "12345678",
  city: "Amsterdam",
  province: "Noord-Holland",
  campaignGoal: "Reduce repeated onboarding questions after arrival.",
  description: "Synthetic validation data only: employees need clearer registration and healthcare routes."
});

type ExternalRequest = { url: string; method: string; body: string };

const consoleErrorsByPage = new WeakMap<Page, string[]>();
const externalRequestsByPage = new WeakMap<Page, ExternalRequest[]>();

function luminance(red: number, green: number, blue: number): number {
  const channels = [red, green, blue].map((value) => {
    const normalized = value / 255;
    return normalized <= 0.04045 ? normalized / 12.92 : ((normalized + 0.055) / 1.055) ** 2.4;
  });
  return 0.2126 * channels[0] + 0.7152 * channels[1] + 0.0722 * channels[2];
}

function contrast(first: readonly number[], second: readonly number[]): number {
  const one = luminance(first[0], first[1], first[2]);
  const two = luminance(second[0], second[1], second[2]);
  return (Math.max(one, two) + 0.05) / (Math.min(one, two) + 0.05);
}

function rgbChannels(value: string): number[][] {
  return [...value.matchAll(/rgba?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)/g)]
    .map((match) => [Number(match[1]), Number(match[2]), Number(match[3])]);
}

function opaqueRgbChannels(value: string): number[][] {
  return [...value.matchAll(/rgba?\(\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)\s*,\s*(\d+(?:\.\d+)?)(?:\s*,\s*(\d*(?:\.\d+)?))?/g)]
    .filter((match) => match[4] === undefined || Number(match[4]) >= 0.75)
    .map((match) => [Number(match[1]), Number(match[2]), Number(match[3])]);
}

async function assertTextContrast(
  page: Page,
  textSelector: string,
  surfaceSelector: string,
  minimum: number
): Promise<void> {
  const styles = await page.evaluate(({ textSelector: text, surfaceSelector: surface }) => {
    const textElement = document.querySelector(text);
    const surfaceElement = document.querySelector(surface);
    if (!(textElement instanceof HTMLElement) || !(surfaceElement instanceof HTMLElement)) return null;
    const textStyle = getComputedStyle(textElement);
    const surfaceStyle = getComputedStyle(surfaceElement);
    const bodyStyle = getComputedStyle(document.body);
    return {
      foreground: textStyle.color,
      background: `${surfaceStyle.backgroundColor} ${surfaceStyle.backgroundImage}`,
      fallbackBackground: `${bodyStyle.backgroundColor} ${bodyStyle.backgroundImage}`
    };
  }, { textSelector, surfaceSelector });
  if (!styles) throw new Error(`Contrast elements are missing: ${textSelector} / ${surfaceSelector}`);
  const foreground = rgbChannels(styles.foreground)[0];
  const backgrounds = opaqueRgbChannels(styles.background);
  if (!backgrounds.length) backgrounds.push(...opaqueRgbChannels(styles.fallbackBackground));
  if (!foreground || !backgrounds.length) {
    throw new Error(`Contrast colours could not be computed: ${textSelector} / ${surfaceSelector}`);
  }
  for (const background of backgrounds) {
    expect(
      contrast(foreground, background),
      `${textSelector} contrast for ${styles.foreground} on ${background.join(",")}`
    ).toBeGreaterThanOrEqual(minimum);
  }
}

async function isolateExternalNetwork(page: Page): Promise<ExternalRequest[]> {
  const requests: ExternalRequest[] = [];
  externalRequestsByPage.set(page, requests);
  await page.route(/^https?:\/\//, async (route: Route) => {
    const request = route.request();
    const url = new URL(request.url());
    if (url.hostname === "127.0.0.1" || url.hostname === "localhost") {
      await route.continue();
      return;
    }

    requests.push({
      url: request.url(),
      method: request.method(),
      body: request.postData() ?? ""
    });

    if (request.url() === businessEndpoint) {
      if (request.method() === "OPTIONS") {
        await route.fulfill({
          status: 204,
          headers: {
            "Access-Control-Allow-Origin": "*",
            "Access-Control-Allow-Headers": "content-type",
            "Access-Control-Allow-Methods": "POST, OPTIONS"
          }
        });
        return;
      }
      await route.fulfill({
        status: 201,
        contentType: "application/json",
        headers: { "Access-Control-Allow-Origin": "*" },
        body: JSON.stringify({
          confirmationId: "YNI-A1B2C3D4E5F6",
          createdAt: "2026-08-18T12:00:00.000Z"
        })
      });
      return;
    }

    await route.fulfill({
      status: 204,
      headers: { "Access-Control-Allow-Origin": "*" }
    });
  });
  return requests;
}

async function dismissConsent(page: Page): Promise<void> {
  const decline = page.getByRole("button", { name: "Decline analytics" });
  if (await decline.isVisible().catch(() => false)) await decline.click();
}

async function assertPageHealth(page: Page): Promise<void> {
  await expect(page.locator("h1")).toHaveCount(1);
  await expect(page.locator("h1")).toBeVisible();
  await expect(page.locator(".site-header")).toBeVisible();
  await expect(page.locator("nextjs-portal")).toHaveCount(0);
  await expect.poll(() => page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth + 1)).toBe(true);
  await expect.poll(() => page.evaluate(() => {
    const header = document.querySelector(".site-header")?.getBoundingClientRect();
    const heading = document.querySelector("h1")?.getBoundingClientRect();
    return !header || !heading || heading.top >= header.bottom - 1;
  })).toBe(true);
  await expect.poll(() => page.evaluate(() => {
    const controls = [...document.querySelectorAll<HTMLElement>("a.button, button.button, button.button-primary")]
      .filter((element) => {
        const rect = element.getBoundingClientRect();
        const style = getComputedStyle(element);
        return rect.width > 0 && rect.height > 0 && style.visibility !== "hidden";
      });
    return controls.every((element) => {
      const rect = element.getBoundingClientRect();
      return rect.left >= -1 && rect.right <= document.documentElement.scrollWidth + 1 && rect.width >= 40 && rect.height >= 40;
    });
  })).toBe(true);
  await expect.poll(() => page.evaluate(() => getComputedStyle(document.documentElement).getPropertyValue("--orange").trim().length > 0)).toBe(true);
}

async function assertCriticalContrast(page: Page): Promise<void> {
  const values = await page.locator(".button-primary").first().evaluate((element) => {
    const style = getComputedStyle(element);
    return { color: style.color, background: style.backgroundColor, image: style.backgroundImage };
  });
  const foreground = rgbChannels(values.color)[0];
  const backgrounds = [...rgbChannels(values.image), ...rgbChannels(values.background)];
  if (!foreground) throw new Error("Primary CTA text colour could not be computed.");
  expect(backgrounds.length, "primary CTA background colour must be computable").toBeGreaterThan(0);
  for (const background of backgrounds) {
    expect(contrast(foreground, background), `primary CTA contrast for ${values.color} on ${background.join(",")}`).toBeGreaterThanOrEqual(3);
  }
}

async function assertKeyboardFocus(page: Page): Promise<void> {
  await page.locator("body").click({ position: { x: 2, y: 2 } });
  let focused = false;
  for (let index = 0; index < 20; index += 1) {
    await page.keyboard.press("Tab");
    focused = await page.evaluate(() => document.activeElement?.matches("a.button, button.button, button.button-primary") ?? false);
    if (focused) break;
  }
  expect(focused, "keyboard navigation must reach a CTA").toBe(true);
  const focusStyle = await page.evaluate(() => {
    const active = document.activeElement;
    if (!(active instanceof HTMLElement)) return null;
    const style = getComputedStyle(active);
    return { outline: style.outlineStyle, outlineWidth: style.outlineWidth, boxShadow: style.boxShadow };
  });
  expect(focusStyle).toBeTruthy();
  expect(
    (focusStyle?.outline !== "none" && focusStyle?.outlineWidth !== "0px") || focusStyle?.boxShadow !== "none",
    "focused CTA must expose a visible outline or focus ring"
  ).toBe(true);
}

async function screenshot(page: Page, projectName: string, name: string): Promise<void> {
  const directory = join(screenshotRoot, projectName);
  await mkdir(directory, { recursive: true });
  // Chromium can duplicate off-canvas fixed elements while stitching full-page
  // screenshots. The skip link remains covered by the keyboard-focus assertions;
  // hide only its non-focused state from captured review artifacts.
  await page.addStyleTag({ content: ".skip-link:not(:focus) { visibility: hidden !important; }" });
  await page.screenshot({ path: join(directory, `${name}.png`), fullPage: true, animations: "disabled" });
}

async function fillSyntheticLead(page: Page): Promise<void> {
  await page.getByLabel("Company or organization").fill(syntheticLead.companyName);
  await page.getByLabel("Organization type").selectOption("advertising-agency");
  await page.getByLabel("Contact person").fill(syntheticLead.contactPerson);
  await page.getByLabel("Role", { exact: true }).fill(syntheticLead.contactRole);
  await page.getByLabel("Work email").fill(syntheticLead.email);
  await page.getByLabel("Organization website").fill(syntheticLead.website);
  await page.getByLabel(/KvK number/).fill(syntheticLead.kvkNumber);
  await page.getByLabel("Selected Dutch city or region").fill(syntheticLead.city);
  await page.getByLabel("Province").selectOption({ label: syntheticLead.province });
  await page.getByLabel("What should the pilot help your team improve?").fill(syntheticLead.campaignGoal);
  await page.getByLabel("What do international employees ask today?").fill(syntheticLead.description);
  await page.getByRole("checkbox", { name: /I consent to the processing/ }).check();
  await page.getByRole("checkbox", { name: /I confirm that the information is accurate/ }).check();
}

test.beforeEach(async ({ page }) => {
  const consoleErrors: string[] = [];
  consoleErrorsByPage.set(page, consoleErrors);
  page.on("console", (message) => {
    if (message.type() === "error") consoleErrors.push(message.text());
  });
  page.on("pageerror", (error) => consoleErrors.push(error.message));
  await isolateExternalNetwork(page);
});

test.afterEach(async ({ page }) => {
  expect(consoleErrorsByPage.get(page) ?? [], "no page or console errors").toEqual([]);
});

test("six approved routes render with pricing, disclosure, consent and responsive safety", async ({ page }, testInfo) => {
  const routes = [
    ["for-business", "/for-business/", "Give international employees one clear place to start in the Netherlands."],
    ["pilot-price", "/for-business/pilot/", "A 90-day onboarding pilot built around real employee questions."],
    ["demo-report", "/for-business/demo-report/", "See the reporting structure before a pilot is scoped."],
    ["partners-disclosure", "/partners/", "Useful partners, clearly identified."],
    ["pilot-form-empty", "/partners/apply/", "Tell us what your team needs."],
    ["success-state", "/partners/apply/success/", "Request received."]
  ] as const;

  for (const [name, route, heading] of routes) {
    await page.goto(route, { waitUntil: "networkidle" });
    expect(new URL(page.url()).pathname).toBe(route);
    await expect(page.getByRole("heading", { level: 1, name: heading })).toBeVisible();
    await assertPageHealth(page);
    if (route === "/for-business/") {
      await expect(page.getByRole("heading", { name: "Help improve YouNew?" })).toBeVisible();
    }
    if (route === "/for-business/pilot/") {
      await expect(page.getByText("Founding pilot — €1,500 excl. VAT", { exact: true })).toBeVisible();
      await expect(page.getByRole("link", { name: /Request pilot/ }).first()).toBeVisible();
      await assertCriticalContrast(page);
      await assertTextContrast(page, ".pilot-price-line strong", "body", 3);
      await assertTextContrast(page, ".pilot-process-card li strong", ".pilot-process-card", 4.5);
      await assertTextContrast(page, ".pilot-process-card li p", ".pilot-process-card", 4.5);
      await assertTextContrast(page, ".pilot-scope-panel li", ".pilot-scope-panel", 4.5);
      await assertTextContrast(page, ".pilot-card-grid article p", ".pilot-card-grid article", 4.5);
    }
    if (route === "/partners/") {
      await expect(page.getByText(/Paid placement never changes YouNew’s factual guidance/)).toBeVisible();
      await assertTextContrast(page, ".business-hero h1", ".business-hero", 3);
      await assertTextContrast(page, ".business-hero>p", ".business-hero", 4.5);
      await assertTextContrast(page, ".pilot-card-grid article p", ".pilot-card-grid article", 4.5);
    }
    if (route === "/partners/apply/") {
      await assertTextContrast(page, ".pilot-request-form .form-field>label", ".pilot-request-form .form-section", 4.5);
      await assertTextContrast(page, ".pilot-request-form .form-field input", ".pilot-request-form .form-field input", 4.5);
    }
    await screenshot(page, testInfo.project.name, name);
    await dismissConsent(page);
  }

  await page.goto("/for-business/", { waitUntil: "networkidle" });
  await dismissConsent(page);
  await page.getByRole("link", { name: /Request a 90-day pilot/ }).first().click();
  await expect(page).toHaveURL(/\/for-business\/pilot\/$/);
  await assertKeyboardFocus(page);
  await screenshot(page, testInfo.project.name, "navigation-focus");
});

test("pilot form validates, uses only synthetic data and reaches stored-receipt success", async ({ page }, testInfo) => {
  const requests = externalRequestsByPage.get(page) ?? [];
  await page.goto("/partners/apply/", { waitUntil: "networkidle" });
  await dismissConsent(page);
  await screenshot(page, testInfo.project.name, "form-empty");

  await page.getByRole("button", { name: "Send pilot request" }).click();
  const summary = page.getByRole("alert").filter({ hasText: "Check the highlighted fields." });
  await expect(summary).toBeVisible();
  await expect(summary).toBeFocused();
  expect(await page.locator('[aria-invalid="true"]').count()).toBeGreaterThan(0);
  await assertTextContrast(page, ".pilot-request-form .form-field-error", ".pilot-request-form .form-section", 4.5);
  await assertTextContrast(page, ".pilot-request-form .form-error-summary p", "body", 4.5);
  await screenshot(page, testInfo.project.name, "form-validation-errors");

  await fillSyntheticLead(page);
  await expect(page.locator('[aria-invalid="true"]')).toHaveCount(0);
  await screenshot(page, testInfo.project.name, "form-synthetic-filled");
  await page.getByRole("button", { name: "Send pilot request" }).click();
  await expect(page).toHaveURL(/\/partners\/apply\/success\/$/);
  await expect(page.getByRole("heading", { level: 1, name: "Request received." })).toBeVisible();
  await screenshot(page, testInfo.project.name, "form-success");

  const submission = requests.find((request) => request.url === businessEndpoint && request.method === "POST");
  expect(submission, "one synthetic business request is intercepted inside Playwright").toBeTruthy();
  expect(submission?.body).toContain(syntheticLead.email);
  expect(submission?.body).not.toMatch(/ivan|chernikov|@younew\.nl/i);
  for (const request of requests.filter((candidate) => candidate.url !== businessEndpoint)) {
    expect(request.body).not.toContain(syntheticLead.email);
    expect(request.body).not.toContain(syntheticLead.contactPerson);
    expect(request.body).not.toContain(syntheticLead.companyName);
  }
});

test("legacy commercial route returns 308 and resolves to the canonical destination", async ({ page }, testInfo) => {
  const direct = await page.request.get("/business/pricing/?source=visual-ci", { maxRedirects: 0 });
  expect(direct.status()).toBe(308);
  expect(direct.headers().location).toBe("/for-business/pilot/?source=visual-ci");

  await page.goto("/business/pricing/?source=visual-ci", { waitUntil: "networkidle" });
  await expect(page).toHaveURL(/\/for-business\/pilot\/\?source=visual-ci$/);
  await expect(page.getByText("Founding pilot — €1,500 excl. VAT", { exact: true })).toBeVisible();
  await assertPageHealth(page);
  await screenshot(page, testInfo.project.name, "legacy-308-destination");
});
