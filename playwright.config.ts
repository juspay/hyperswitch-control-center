import { defineConfig, devices } from "@playwright/test";
import type { ReporterDescription } from "@playwright/test";
// eslint-disable-next-line @typescript-eslint/no-require-imports
const mcrConfig = require("./mcr.config.js");

function buildReporters(): ReporterDescription[] {
  const coverageReporter: ReporterDescription = [
    "monocart-reporter",
    {
      // Coverage only - disable monocart's test report (redundant with built-in HTML)
      outputFile: "",
      coverage: {
        ...mcrConfig,
        // Preserve raw V8 data per shard so the merge-coverage CI job can
        // re-aggregate across shards into one unified report.
        // NOTE: monocart resolves this `outputDir` against the parent
        // coverage outputDir (see node_modules/monocart-coverage-reports/
        // lib/reports/raw.js:84 -> path.resolve(parent, this)). Pass a
        // bare segment ("raw"), not a "./coverage-report/raw" prefix, or
        // it nests as coverage-report/coverage-report/raw.
        reports: [
          ...mcrConfig.reports,
          ["raw", { outputDir: "raw" }],
        ],
      },
    },
  ];

  if (process.env.CI) {
    const base: ReporterDescription[] = [
      ["html", { open: "never", outputFolder: "playwright-report" }],
      ["line"],
      ["playwright-ctrf-json-reporter", { outputDir: "ctrf" }],
    ];
    return process.env.PW_COVERAGE === "1"
      ? [...base, coverageReporter]
      : base;
  }

  // Local: attach coverage reporter on demand via PW_COVERAGE=1.
  return process.env.PW_COVERAGE === "1"
    ? [["list"], coverageReporter]
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
    baseURL: process.env.PLAYWRIGHT_BASE_URL || "http://localhost:9000", // Base URL to use in actions like `await page.goto('')`.
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

  // Run your local dev server before starting the tests
  webServer: {
    command: "npm run start:test",
    url: "http://localhost:9000",
    reuseExistingServer: !process.env.CI,
    timeout: 60000,
  },
});
