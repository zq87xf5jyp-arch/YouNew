import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: "./e2e",
  testMatch: /monetization-visual\.spec\.ts/,
  timeout: 120_000,
  expect: { timeout: 10_000 },
  outputDir: "visual-validation/test-results",
  fullyParallel: false,
  forbidOnly: Boolean(process.env.CI),
  retries: 0,
  workers: 1,
  reporter: [
    ["line"],
    ["json", { outputFile: "visual-validation/playwright-results.json" }]
  ],
  use: {
    baseURL: "http://127.0.0.1:4173",
    serviceWorkers: "block",
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
    video: "off"
  },
  projects: [
    {
      name: "desktop-1440x900",
      use: { browserName: "chromium", viewport: { width: 1440, height: 900 } }
    },
    {
      name: "mobile-390x844",
      use: { browserName: "chromium", viewport: { width: 390, height: 844 }, isMobile: true }
    }
  ],
  webServer: {
    command: "pnpm --dir public-site start",
    url: "http://127.0.0.1:4173/for-business/",
    reuseExistingServer: false,
    timeout: 120_000,
    env: {
      ...process.env,
      HOST: "127.0.0.1",
      PORT: "4173"
    }
  }
});
