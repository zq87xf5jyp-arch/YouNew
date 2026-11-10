import { expect, test, type Page } from "@playwright/test";
import { canAccessPath, type AdminRole } from "../src/lib/authorization";

const role = (process.env.E2E_ISOLATED_ROLE ?? "owner") as AdminRole;
const isolatedProfile = process.env.E2E_ISOLATED_PROFILE ?? "demo";
const routes = [
  ["/dashboard", "Панель управления", "Панель"],
  ["/analytics", "Аналитика", "Аналитика"],
  ["/finance", "Финансы YouNew", "Финансы"],
  ["/sync", "Публикация и синхронизация", "Синхронизация"],
  ["/trust", "Trust Dashboard & Human Review Queue", "Trust & Review"],
  ["/content", "Управление контентом", "Контент"],
  ["/business-inquiries", "Бизнес-заявки", "Бизнес-заявки"],
  ["/categories", "Категории", "Категории"],
  ["/cities", "Города", "Города"],
  ["/map", "Канонические точки карты", "Карта"],
  ["/visual-qa", "Проверка интерфейса", "Проверка UI"],
  ["/bugs", "Трекер ошибок", "Ошибки"],
  ["/releases", "Release Control", "Релизы"],
  ["/links", "Канонический реестр официальных ссылок", "Ссылки"],
  ["/ai-knowledge", "Знания для AI", "Знания AI"],
  ["/feedback", "Отзывы пользователей", "Отзывы"],
  ["/settings", "Настройки", "Настройки"],
  ["/audit-log", "Журнал действий", "Журнал"]
] as const;

const sourceExpectations = [
  ["/content", "Supabase articles", "data"],
  ["/categories", "packaged public content", "data"],
  ["/cities", "Городские страницы текущего пакета — только просмотр", "data"],
  ["/map", "packaged governed content + official municipality registry", "data"],
  ["/visual-qa", "isolated Playwright artifacts", "unknown"],
  ["/bugs", "Supabase unavailable", "unavailable"],
  ["/links", "deterministic canonical official-link registry", "data"],
  ["/links", "Supabase official_link_operational_latest", "unknown"],
  ["/ai-knowledge", "Supabase ai_knowledge_items", "empty (measured)"],
  ["/feedback", "Supabase feedback", "empty (measured)"],
  ["/audit-log", "Supabase audit_logs", "empty (measured)"]
] as const;

const readOnlyRoutes = [
  "/releases", "/links", "/ai-knowledge", "/feedback", "/audit-log"
] as const;

const mutationButtonPattern = /^(?:Создать|Сохранить|Удалить|Опубликовать|Активировать|Закрыть|Изменить|Редактировать)(?:\s|$)/i;

async function authenticateSyntheticAdmin(page: Page) {
  await page.goto("/login");
  await page.getByLabel("Email").fill(`e2e-${role}@example.invalid`);
  await page.getByLabel("Пароль").fill("isolated-e2e-password");
  await page.getByRole("button", { name: "Войти" }).click();
  await expect(page).toHaveURL(/\/dashboard$/);
  const response = await page.goto("/dashboard");
  expect(response?.status(), "authenticated dashboard document should load").toBeLessThan(400);
  await expect(page.getByRole("heading", { level: 1, name: "Панель управления" })).toBeVisible();
}

async function expectSourceState(page: Page, label: string, state: string) {
  const labelNode = page.getByText(`Источник: ${label}`, { exact: true });
  await expect(labelNode).toBeVisible();
  await expect(labelNode.locator("xpath=../..").getByText(state, { exact: true })).toBeVisible();
}

test.describe(`isolated ${role} surface`, () => {
  test.skip(isolatedProfile !== "demo", "Role matrix uses the localhost synthetic Supabase profile.");

  test.beforeEach(async ({ page }) => {
    await authenticateSyntheticAdmin(page);
  });

  test("every authorized route has exact identity, active navigation and no rendering regression", async ({ page }, testInfo) => {
    test.slow();
    const runtimeErrors: string[] = [];
    let activeRoute = "/login";
    page.on("pageerror", (error) => runtimeErrors.push(`${activeRoute} pageerror: ${error.message}`));
    page.on("console", (message) => {
      if (message.type() === "error") runtimeErrors.push(`${activeRoute} console: ${message.text()}`);
    });

    for (const [route, heading, navLabel] of routes.filter(([path]) => canAccessPath(role, path))) {
      activeRoute = route;
      const response = await page.goto(route);
      expect(response, `${route} should return a document response`).not.toBeNull();
      expect(response!.status(), `${route} should not return an error`).toBeLessThan(400);
      await expect(page).toHaveTitle("Админка YouNew.nl");
      await expect(page.locator("main")).toBeVisible();
      await expect(page.getByRole("heading", { level: 1, name: heading, exact: true })).toBeVisible();
      await expect(page.locator("nextjs-portal")).toHaveCount(0);
      const visibleActiveLabels = await page.locator(`a[aria-current="page"][href="${route}"]`).evaluateAll((links) =>
        links.filter((link) => link.getClientRects().length > 0).map((link) => link.textContent?.trim())
      );
      expect(visibleActiveLabels).toEqual([navLabel]);
      const overflow = await page.evaluate(() => document.documentElement.scrollWidth - document.documentElement.clientWidth);
      expect(overflow, `${route} must not overflow horizontally`).toBeLessThanOrEqual(1);
      if (role === "owner") {
        await testInfo.attach(`${testInfo.project.name}-${route.slice(1) || "root"}`, {
          body: await page.screenshot(),
          contentType: "image/png"
        });
      }
    }
    expect(runtimeErrors, "authorized routes must not emit browser runtime errors").toEqual([]);
  });

  test("route registry denies direct and launcher access outside the current role", async ({ page }) => {
    const deniedRoutes = routes.filter(([path]) => !canAccessPath(role, path));
    test.skip(deniedRoutes.length === 0, "Owner can access every registered Admin route.");
    for (const [route] of deniedRoutes) {
      await page.goto(route);
      await expect(page, `${role} must be denied ${route}`).toHaveURL(/\/dashboard\?error=forbidden$/);
    }
    const [deniedRoute, , deniedLabel] = deniedRoutes[0];
    await page.goto("/dashboard");
    const launcher = page.getByRole("combobox", { name: "Открыть раздел админки" });
    await launcher.fill(deniedLabel);
    await launcher.press("Enter");
    await expect(page, `launcher must not expose ${deniedRoute} to ${role}`).toHaveURL(/\/dashboard\??$/);
  });

  test("source-state cards distinguish measured, synthetic and unknown evidence", async ({ page }) => {
    for (const [route, label, state] of sourceExpectations.filter(([path]) => canAccessPath(role, path))) {
      await page.goto(route);
      await expectSourceState(page, label, state);
    }
    await page.goto("/dashboard");
    await expect(page.getByText("production не разрешён", { exact: true })).toBeVisible();
    await expect(page.getByText("FULL PRODUCT LIVE", { exact: true })).toHaveCount(0);
  });

  test("read-only pages expose no page-local mutation controls", async ({ page }) => {
    for (const route of readOnlyRoutes.filter((path) => canAccessPath(role, path))) {
      await page.goto(route);
      await expect(
        page.locator("main").getByRole("button", { name: mutationButtonPattern }),
        `${route} must not expose a data mutation control`
      ).toHaveCount(0);
    }
  });

  test("content controls produce bounded outcomes and respect published-state policy", async ({ page }) => {
    await page.goto("/content");
    const publishedTitle = "Регистрация в муниципалитете";
    const reviewTitle = "OVpay и общественный транспорт";
    const canEditDrafts = role === "owner" || role === "editor";
    const canManagePublished = role === "owner";

    const contentSearch = page.getByPlaceholder("Поиск по названию, категории или статусу");
    await contentSearch.fill("OVpay");
    await expect(page.getByText(reviewTitle, { exact: true })).toBeVisible();
    await expect(page.getByText(publishedTitle, { exact: true })).toHaveCount(0);
    await contentSearch.clear();

    const downloadPromise = page.waitForEvent("download");
    await page.getByRole("button", { name: "Экспорт JSON" }).click();
    const download = await downloadPromise;
    expect(download.suggestedFilename()).toMatch(/^younew-content-\d{4}-\d{2}-\d{2}\.json$/);

    if (canEditDrafts) {
      await expect(page.getByRole("button", { name: "Новый материал" })).toBeVisible();
      const title = page.getByLabel("Название", { exact: true });
      await title.fill("Transient synthetic title");
      await page.getByRole("button", { name: "Новый материал" }).click();
      await expect(title).toHaveValue("");
      await title.fill("Synthetic created material");
      await page.getByRole("button", { name: "Создать материал" }).click();
      await expect(page.getByRole("status").filter({ hasText: "Материал создан в Supabase." })).toHaveText("Материал создан в Supabase.");
      await expect(page.getByText("Synthetic created material", { exact: true })).toBeVisible();

      page.once("dialog", async (dialog) => {
        expect(dialog.message()).toBe("Удалить «Synthetic created material»?");
        await dialog.dismiss();
      });
      await page.getByRole("button", { name: "Удалить Synthetic created material" }).click();
      await expect(page.getByText("Synthetic created material", { exact: true })).toBeVisible();

      page.once("dialog", async (dialog) => {
        expect(dialog.message()).toBe("Удалить «Synthetic created material»?");
        await dialog.accept();
      });
      await page.getByRole("button", { name: "Удалить Synthetic created material" }).click();
      await expect(page.getByRole("status").filter({ hasText: "Материал и его изображения удалены из Supabase." })).toHaveText("Материал и его изображения удалены из Supabase.");
      await expect(page.getByText("Synthetic created material", { exact: true })).toHaveCount(0);
    } else {
      await expect(page.getByRole("button", { name: "Новый материал" })).toHaveCount(0);
      await expect(page.getByRole("heading", { name: "Создать материал" })).toHaveCount(0);
    }

    if (canManagePublished) {
      await expect(page.getByRole("button", { name: `Редактировать ${publishedTitle}` })).toBeVisible();
      await expect(page.getByRole("button", { name: `Удалить ${publishedTitle}` })).toBeVisible();
      await page.getByRole("button", { name: `Редактировать ${publishedTitle}` }).click();
      await expect(page.getByText("Опубликованный материал открыт в статусе review. Сохранение снимет его с публикации и потребует новой Human Review Queue проверки.")).toBeVisible();
      await page.getByRole("button", { name: "Отменить редактирование" }).click();
      await expect(page.getByRole("heading", { name: "Создать материал" })).toBeVisible();

      await page.getByRole("button", { name: `Редактировать ${publishedTitle}` }).click();
      await page.getByLabel("Название", { exact: true }).fill(`${publishedTitle} — review`);
      await page.getByRole("button", { name: "Сохранить изменения" }).click();
      await expect(page.getByRole("status").filter({ hasText: "Материал обновлён в Supabase." })).toHaveText("Материал обновлён в Supabase.");
      await expect(page.getByText(`${publishedTitle} — review`, { exact: true })).toBeVisible();
    } else {
      await expect(page.getByRole("button", { name: `Редактировать ${publishedTitle}` })).toHaveCount(0);
      await expect(page.getByRole("button", { name: `Удалить ${publishedTitle}` })).toHaveCount(0);
    }

    if (role === "editor") {
      await page.getByRole("button", { name: `Редактировать ${reviewTitle}` }).click();
      await expect(page.getByRole("heading", { name: "Редактировать материал" })).toBeVisible();
      await expect(page.getByRole("button", { name: "Отменить редактирование" })).toBeVisible();
      await page.getByRole("button", { name: "Отменить редактирование" }).click();
      await expect(page.getByRole("heading", { name: "Создать материал" })).toBeVisible();

      await page.getByRole("button", { name: `Редактировать ${reviewTitle}` }).click();
      await page.getByLabel("Название", { exact: true }).fill(`${reviewTitle} — editor update`);
      await page.getByRole("button", { name: "Сохранить изменения" }).click();
      await expect(page.getByRole("status").filter({ hasText: "Материал обновлён в Supabase." })).toHaveText("Материал обновлён в Supabase.");
      await expect(page.getByText(`${reviewTitle} — editor update`, { exact: true })).toBeVisible();
    }
  });

  test("global launcher and focus state have observable outcomes", async ({ page }) => {
    await page.goto("/dashboard");
    const launcher = page.getByRole("combobox", { name: "Открыть раздел админки" });
    await launcher.focus();
    await expect(launcher).toBeFocused();
    const focusIndicator = await launcher.evaluate((element) => {
      const style = getComputedStyle(element);
      return style.outlineStyle !== "none" || style.boxShadow !== "none";
    });
    expect(focusIndicator, "keyboard focus must be visible").toBe(true);
    await launcher.fill("Карта");
    await launcher.press("Enter");
    await expect(page).toHaveURL(/\/map$/);
    await expect(page.getByRole("heading", { level: 1, name: "Канонические точки карты" })).toBeVisible();
    await expect(launcher).toHaveValue("");
  });

  test("owner notification control opens the bounded internal inbox", async ({ page }) => {
    test.skip(role !== "owner", "Only Owner/Admin receives business notifications.");
    await page.goto("/dashboard");
    const notificationLink = page.getByRole("link", { name: /уведомлен/i });
    await expect(notificationLink).toBeVisible();
    const unavailableCount = page.getByTitle("Счётчик уведомлений недоступен");
    await expect(unavailableCount).toHaveAttribute("role", "status");
    await expect(unavailableCount).toHaveText("!");
    await notificationLink.click();
    await expect(page).toHaveURL(/\/business-inquiries#notifications$/);
    await expect(page.locator("#notifications").getByText("Внутренние уведомления", { exact: true })).toBeVisible();
    await expect(page.getByText("Новых внутренних уведомлений нет.", { exact: true })).toBeVisible();
  });

  test("owner business export is a bounded header-only synthetic CSV", async ({ page }) => {
    test.skip(role !== "owner", "Only Owner/Admin can export business inquiries.");
    await page.goto("/business-inquiries");
    const downloadPromise = page.waitForEvent("download");
    await page.getByRole("link", { name: "Экспорт без сообщения и внутренних заметок" }).click();
    const download = await downloadPromise;
    expect(download.suggestedFilename()).toMatch(/^younew-business-inquiries-\d{4}-\d{2}-\d{2}\.csv$/);
    const stream = await download.createReadStream();
    const chunks: Buffer[] = [];
    for await (const chunk of stream) chunks.push(Buffer.from(chunk));
    const csv = Buffer.concat(chunks).toString("utf8");
    expect(csv).toBe("reference_code,company_name,contact_person,email,inquiry_type,status,source_page,created_at");
    expect(csv).not.toMatch(/message|internal_notes|ip_address/i);
  });

  test("analytics filter links preserve the URL contract", async ({ page }) => {
    test.skip(!canAccessPath(role, "/analytics"), `${role} cannot access Analytics.`);
    await page.goto("/analytics");
    await page.getByRole("navigation", { name: "Период аналитики" }).getByRole("link", { name: "90 дней" }).click();
    await expect(page).toHaveURL(/\/analytics\?days=90&platform=web$/);
    await expect(page.getByRole("link", { name: "90 дней" })).toHaveAttribute("aria-current", "page");
    await page.getByRole("navigation", { name: "Платформа аналитики" }).getByRole("link", { name: "iOS", exact: true }).click();
    await expect(page).toHaveURL(/\/analytics\?days=90&platform=ios$/);
    await expect(page.getByRole("link", { name: "iOS", exact: true })).toHaveAttribute("aria-current", "page");
    await expect(page.getByText("iOS ingest отключён до отдельной privacy/security-проверки. Это no-data, а не сбой приложения.")).toBeVisible();
    await page.getByRole("button", { name: "Обновить" }).click();
    await expect(page).toHaveURL(/\/analytics\?days=90&platform=ios$/);
    await expect(page.getByText(/^(?:Автообновление через (?:59|60) с|Обновление…)$/)).toBeVisible();
  });

  test("unavailable sync and settings controls remain non-activating", async ({ page }) => {
    if (canAccessPath(role, "/sync")) {
      await page.goto("/sync");
      await expect(page.getByText("NOT VERIFIED", { exact: true })).toBeVisible();
      await expect(page.getByRole("button", { name: "Подготовить candidate-артефакт" })).toBeDisabled();
      await expect(page.getByText("Она не активирует сайт или iOS", { exact: false })).toBeVisible();
    }
    if (canAccessPath(role, "/settings")) {
      await page.goto("/settings");
      await expect(page.locator("main").getByRole("alert")).toContainText("Сохранение заблокировано");
      await expect(page.getByRole("button", { name: "Сохранить настройки" })).toHaveCount(0);
    }
  });

  test("logout control clears the isolated session", async ({ page }) => {
    await page.goto("/dashboard");
    await page.getByRole("button", { name: "Выйти" }).click();
    await expect(page).toHaveURL(/\/login$/);
    await expect(page.getByRole("heading", { name: "Вход в админку" })).toBeVisible();
  });
});

test("missing authentication configuration fails closed", async ({ page }) => {
  test.skip(isolatedProfile !== "closed", "Closed profile is run separately from the role matrix.");
  await page.goto("/dashboard");
  await expect(page).toHaveURL(/\/login\?error=configuration$/);
  await expect(page.getByText("Сервис входа не настроен.")).toBeVisible();
  await expect(page.getByText("Локальный демо-режим активен", { exact: false })).toHaveCount(0);
});
