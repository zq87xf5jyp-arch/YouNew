import { expect, test } from "@playwright/test";

test.describe("isolated owner surface", () => {
  test("owner can read the core Admin surfaces", async ({ page }) => {
    const routes = [
      ["/dashboard", "Панель управления"],
      ["/business-inquiries", "Бизнес-заявки"],
      ["/feedback", "Отзывы пользователей"],
      ["/sync", "Публикация и синхронизация"],
      ["/localization-review", "Localization Review"],
      ["/audit-log", "Журнал действий"]
    ] as const;

    for (const [route, heading] of routes) {
      const response = await page.goto(route);
      expect(response, `${route} should return a document response`).not.toBeNull();
      expect(response!.status(), `${route} should not return an error`).toBeLessThan(400);
      await expect(page.getByRole("heading", { name: heading, exact: true })).toBeVisible();
    }
  });

  test("sync candidate remains non-activating without a production connection", async ({ page }) => {
    await page.goto("/sync");
    await expect(page.getByRole("button", { name: "Подготовить candidate-артефакт" })).toBeDisabled();
    await expect(page.getByText("Она не активирует production-версию.")).toBeVisible();
  });
});

test("missing authentication configuration fails closed", async ({ page }) => {
  await page.goto("/dashboard");
  await expect(page).toHaveURL(/\/login\?error=configuration$/);
  await expect(page.getByText("Сервис входа не настроен.")).toBeVisible();
});
