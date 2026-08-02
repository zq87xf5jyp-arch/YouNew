import { expect, test } from "@playwright/test";

const ownerEmail = process.env.E2E_OWNER_EMAIL;
const ownerPassword = process.env.E2E_OWNER_PASSWORD;
const deniedEmail = process.env.E2E_DENIED_EMAIL;
const deniedPassword = process.env.E2E_DENIED_PASSWORD;

test.describe("production-safe smoke", () => {
  test("approved owner can read protected surfaces without mutation", async ({ page }) => {
    test.skip(!ownerEmail || !ownerPassword, "E2E owner credentials are required.");

    await page.goto("/login");
    await page.getByLabel("Email").fill(ownerEmail!);
    await page.getByLabel("Пароль").fill(ownerPassword!);
    await page.getByRole("button", { name: "Войти" }).click();
    await expect(page).toHaveURL(/\/dashboard(?:\?.*)?$/);

    for (const route of ["/business-inquiries", "/feedback", "/sync", "/audit-log"]) {
      const response = await page.goto(route);
      expect(response, `${route} should return a document response`).not.toBeNull();
      expect(response!.status(), `${route} should not return an error`).toBeLessThan(400);
      await expect(page.locator("main")).toBeVisible();
    }
  });

  test("unapproved account is denied", async ({ page }) => {
    test.skip(!deniedEmail || !deniedPassword, "E2E denied-user credentials are required.");

    await page.goto("/login");
    await page.getByLabel("Email").fill(deniedEmail!);
    await page.getByLabel("Пароль").fill(deniedPassword!);
    await page.getByRole("button", { name: "Войти" }).click();
    await expect(page).toHaveURL(/\/login\?error=not-approved$/);
    await expect(page.getByText("Аккаунт существует, но пока не одобрен")).toBeVisible();
  });
});
