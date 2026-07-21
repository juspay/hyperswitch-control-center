import { defineConfig, devices } from "@playwright/test";
import type { ReporterDescription } from "@playwright/test";

// Coverage is collected via the Istanbul fixture in
// playwright-tests/support/test.ts (writes per-test data to .nyc_output/);
// it needs no Playwright reporter. nyc produces the per-shard and merged
// reports in CI. See .github/workflows/playwright-test.yml.
function buildReporters(): ReporterDescription[] {
  if (process.env.CI) {
    return [
      ["html", { open: "never", outputFolder: "playwright-report" }],
      ["line"],
      ["playwright-ctrf-json-reporter", { outputDir: "ctrf" }],
    ];
  }

  // Local: plain list output when collecting coverage (PW_COVERAGE=1),
  // otherwise the usual on-failure HTML report.
  return process.env.PW_COVERAGE === "1"
    ? [["list"]]
    : [["html", { open: "on-failure" }]];
}

const PLAYWRIGHT_USERNAME =
  process.env.PLAYWRIGHT_USERNAME || "playwright@test.com";
const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
const MAIL_URL = process.env.MAIL_URL || "http://localhost:8025";
const PLAYWRIGHT_SSO_BASE_URL = process.env.CYPRESS_SSO_BASE_URL;
const PLAYWRIGHT_SSO_CLIENT_ID = process.env.CYPRESS_SSO_CLIENT_ID;
const PLAYWRIGHT_SSO_CLIENT_SECRET = process.env.CYPRESS_SSO_CLIENT_SECRET;
const PLAYWRIGHT_SSO_USERNAME = process.env.CYPRESS_SSO_USERNAME;
const PLAYWRIGHT_SSO_PASSWORD = process.env.CYPRESS_SSO_PASSWORD;

// If PLAYWRIGHT_BASE_URL targets a remote env, skip the local dev server.
// Local/CI runs use localhost and start the webServer.
const BASE_URL = process.env.PLAYWRIGHT_BASE_URL || "http://localhost:9000";
const IS_LOCAL_TARGET =
  BASE_URL.includes("localhost") || BASE_URL.includes("127.0.0.1");

export default defineConfig({
  testDir: "./playwright-tests",
  // Ignore stub files
  testIgnore: ["*seed.spec.ts"],
  fullyParallel: true, // Run tests in files in parallel
  forbidOnly: !!process.env.CI, // Fail the build on CI if you accidentally left test.only in the source code.
  retries: process.env.CI ? 3 : 0, // Retry on CI only
  workers: process.env.CI ? 4 : undefined, // Opt out of parallel tests on CI.
  // CI runners are slower than local dev — extend the default 30s test budget
  // so multi-step flows (signup, connector setup, UI interactions) don't run
  // out of time before the assertions that verify them.
  timeout: process.env.CI ? 90000 : 30000,
  // Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions.
  use: {
    baseURL: BASE_URL,
    screenshot: "only-on-failure", // Screenshot on failure for debugging
    video: "retain-on-failure",
    trace: "on-first-retry",
    actionTimeout: 30000, // Action timeout
    navigationTimeout: 90000, // Navigation timeout
    viewport: { width: 1620, height: 1080 }, // Viewport
  },
  outputDir: "test-results/", // Output directory for test artifacts
  reporter: buildReporters(),

  // Configure projects for major browsers
  projects: [
    {
      name: "chromium",
      use: {
        ...devices["Desktop Chrome"],
        viewport: { width: 1620, height: 1080 },
      },
    },
    /* Test against different browsers.
    {
      name: 'Microsoft Edge',
      use: { ...devices['Desktop Edge'], channel: 'msedge' },
    },
    {
      name: 'firefox',
      use: { ...devices['Desktop Firefox'] },
    },

    {
      name: 'webkit',
      use: { ...devices['Desktop Safari'] },
    },

    Test against mobile viewports.
    {
      name: 'Mobile Chrome',
      use: { ...devices['Pixel 5'] },
    },
    {
      name: 'Mobile Safari',
      use: { ...devices['iPhone 12'] },
    }, */
  ],

  // Run your local dev server before starting the tests.
  // Skipped entirely when targeting a remote environment
  // (PLAYWRIGHT_BASE_URL is non-localhost).
  webServer: IS_LOCAL_TARGET
    ? {
      command: "npm run start:test",
      url: "http://localhost:9000",
      reuseExistingServer: !process.env.CI,
      timeout: 60000,
    }
    : undefined,
});
