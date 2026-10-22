import { defineConfig } from "@playwright/test";

export default defineConfig({
  testDir: ".",
  testMatch: "accordion.spec.ts",
  workers: 1,
  timeout: 60000,
  reporter: "list",
  outputDir: "/tmp/accordion-playwright-results",
  use: {
    baseURL: process.env.PLAYWRIGHT_BASE_URL || "http://127.0.0.1:9100",
    storageState: process.env.PLAYWRIGHT_STORAGE_STATE,
    screenshot: "off",
    trace: "off",
    video: "off",
    launchOptions: {
      executablePath: process.env.PLAYWRIGHT_CHROMIUM_EXECUTABLE,
      args: ["--no-sandbox"],
    },
  },
});
