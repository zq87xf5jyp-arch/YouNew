import { defineConfig, devices } from "@playwright/test";

const mode = process.env.E2E_MUTATION_MODE ?? "isolated";
const isProductionSafe = mode === "production";
const isolatedProfile = process.env.E2E_ISOLATED_PROFILE ?? "demo";
const isClosedProfile = isolatedProfile === "closed";
const isolatedRole = process.env.E2E_ISOLATED_ROLE ?? "owner";
const isolatedSupabaseURL = "http://127.0.0.1:54329";
const isolatedEnvironment = {
  ...process.env,
  APP_STORE_CONNECT_ISSUER_ID: "",
  APP_STORE_CONNECT_KEY_ID: "",
  APP_STORE_CONNECT_PRIVATE_KEY: "",
  INTERNAL_ANALYTICS_INGEST_TOKEN: "",
  SUPABASE_SERVICE_ROLE_KEY: "",
  SUPABASE_URL: ""
};
if (!["owner", "editor", "qa", "viewer"].includes(isolatedRole)) {
  throw new Error(`Unsupported E2E_ISOLATED_ROLE: ${isolatedRole}`);
}
const baseURL = isProductionSafe
  ? process.env.E2E_BASE_URL
  : "http://localhost:4173";

if (isProductionSafe && !baseURL) {
  throw new Error("E2E_BASE_URL is required for production-safe Admin E2E.");
}

export default defineConfig({
  testDir: "./e2e",
  testMatch: isProductionSafe ? /admin-production\.spec\.ts/ : /admin-isolated\.spec\.ts/,
  timeout: 120_000,
  outputDir: isProductionSafe ? "test-results/admin-production" : `test-results/admin-${isolatedProfile}-${isolatedRole}`,
  preserveOutput: "always",
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
      name: "desktop-1440x900",
      use: { ...devices["Desktop Chrome"], viewport: { width: 1440, height: 900 } }
    },
    {
      name: "mobile-390x844",
      use: { ...devices["Pixel 5"], viewport: { width: 390, height: 844 } }
    }
  ],
  webServer: isProductionSafe
    ? undefined
    : [
        ...(!isClosedProfile ? [{
          command: "node e2e/fake-supabase.mjs",
          url: `${isolatedSupabaseURL}/health`,
          reuseExistingServer: false,
          timeout: 30_000,
          env: {
            ...isolatedEnvironment,
            E2E_FAKE_SUPABASE_PORT: "54329",
            E2E_ISOLATED_ROLE: isolatedRole
          }
        }] : []),
        {
          command: "pnpm start --hostname 127.0.0.1 --port 4173",
          url: "http://127.0.0.1:4173/login",
          reuseExistingServer: false,
          timeout: 120_000,
          env: {
            ...isolatedEnvironment,
            NEXT_PUBLIC_SUPABASE_URL: isClosedProfile ? "" : isolatedSupabaseURL,
            NEXT_PUBLIC_SUPABASE_ANON_KEY: isClosedProfile ? "" : "isolated-e2e-anon-key",
            YOUNEW_ADMIN_DEMO_MODE: "false",
            YOUNEW_ADMIN_DEMO_ROLE: isolatedRole
          }
        }
      ]
});
