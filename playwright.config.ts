import { defineConfig, devices } from "@playwright/test";
import type { ReporterDescription } from "@playwright/test";

function buildReporters(): ReporterDescription[] {
  const coverageReporter: ReporterDescription = [
    "monocart-reporter",
    {
      // Coverage only - disable monocart's test report (redundant with built-in HTML)
      outputFile: "",
      coverage: {
        entryFilter: (entry: { url?: string }): boolean => {
          const url = entry.url || "";
          if (!url) return false;
          if (url.includes("node_modules")) return false;
          if (url.includes("webpack-internal:")) return false;
          return true;
        },
        sourceFilter: (sourcePath: string): boolean =>
          sourcePath.includes("src/") && !sourcePath.includes("node_modules"),
        reports: [
          ["v8", { outputFile: "index.html" }],
          ["console-summary"],
          ["markdown-summary", { metrics: ["bytes", "lines", "branches", "functions"] }],
          ["json-summary", { outputFile: "coverage-summary.json" }],
        ],
        name: "Hyperswitch E2E Coverage",
        outputDir: "./coverage-report",
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
  testIgnore: ["*seed.spec.ts", "**/.archive/**"],
  fullyParallel: true, // Run tests in files in parallel
  forbidOnly: !!process.env.CI, // Fail the build on CI if you accidentally left test.only in the source code.
  retries: process.env.CI ? 2 : 0, // Retry on CI only
  workers: process.env.CI ? 4 : undefined, // Opt out of parallel tests on CI.
  // Shared settings for all the projects below. See https://playwright.dev/docs/api/class-testoptions.
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL || "http://localhost:9000", // Base URL to use in actions like `await page.goto('')`.
    screenshot: "only-on-failure", // Screenshot on failure for debugging
    video: "retain-on-failure",
    trace: "on-first-retry",
    actionTimeout: 30000, // Action timeout - aligned with Cypress
    navigationTimeout: 90000, // Navigation timeout - aligned with Cypress
    viewport: { width: 1440, height: 1005 }, // Viewport - aligned with Cypress
  },
  outputDir: "test-results/", // Output directory for test artifacts
  reporter: buildReporters(),

  // Configure projects for major browsers
  projects: [
    {
      name: "chromium",
      use: { ...devices["Desktop Chrome"] },
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
    command: "npm run test:start",
    url: "http://localhost:9000",
    reuseExistingServer: !process.env.CI,
    timeout: 60000,
  },
});
