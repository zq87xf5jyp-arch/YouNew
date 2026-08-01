import { defineConfig, devices } from "@playwright/test";

const mode = process.env.E2E_MUTATION_MODE ?? "isolated";
const isProductionSafe = mode === "production";
const isolatedProfile = process.env.E2E_ISOLATED_PROFILE ?? "demo";
const isClosedProfile = isolatedProfile === "closed";
const baseURL = isProductionSafe
  ? process.env.E2E_BASE_URL
  : "http://127.0.0.1:4173";

if (isProductionSafe && !baseURL) {
  throw new Error("E2E_BASE_URL is required for production-safe Admin E2E.");
}

export default defineConfig({
  testDir: "./e2e",
  testMatch: isProductionSafe ? /admin-production\.spec\.ts/ : /admin-isolated\.spec\.ts/,
  timeout: 120_000,
  outputDir: isProductionSafe ? "test-results/admin-production" : `test-results/admin-${isolatedProfile}`,
  fullyParallel: false,
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 1 : 0,
  workers: 1,
  reporter: [
    ["line"],
    ["json", { outputFile: process.env.E2E_REPORT_PATH ?? "test-results/admin-e2e.json" }]
  ],
  use: {
    baseURL,
    trace: "retain-on-failure",
    screenshot: "only-on-failure",
    video: "retain-on-failure"
  },
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] }
    }
  ],
  webServer: isProductionSafe
    ? undefined
    : {
        command: "pnpm dev --hostname 127.0.0.1 --port 4173",
        url: isClosedProfile ? "http://127.0.0.1:4173/login" : "http://127.0.0.1:4173/dashboard",
        reuseExistingServer: false,
        timeout: 120_000,
        env: {
          ...process.env,
          NEXT_PUBLIC_SUPABASE_URL: "",
          NEXT_PUBLIC_SUPABASE_ANON_KEY: "",
          YOUNEW_ADMIN_DEMO_MODE: isClosedProfile ? "false" : "true"
        }
      }
});
