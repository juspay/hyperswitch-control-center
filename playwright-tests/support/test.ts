/// <reference types="node" />
/**
 * Coverage-enabled Playwright test fixture.
 *
 * Reads the Istanbul coverage object (`window.__coverage__`) that the
 * instrumented test build (`npm run build:test`, CHECK_COVERAGE=true)
 * injects, and writes it per-test into `.nyc_output/` after each test.
 * Every spec in this repo imports `test` and `expect` from here so
 * coverage is collected automatically with zero per-spec wiring.
 *
 * The per-test files are plain Istanbul coverage maps (counters keyed by
 * file), so per-shard and overall reports are produced by `nyc` —
 * `nyc merge` is integer counter addition, so it is fast and cannot OOM
 * the way merging raw V8 data across shards did.
 *
 * Coverage is opt-in via the PW_COVERAGE=1 env var (set by the CI job
 * and by the local `pw:coverage` npm script). When unset the fixture is
 * a no-op so day-to-day `npx playwright test` runs stay fast.
 */

import { test as base, expect, chromium } from "@playwright/test";
import * as fs from "fs";
import * as path from "path";

const COVERAGE_ENABLED = process.env.PW_COVERAGE === "1";
const NYC_OUTPUT_DIR = path.resolve(process.cwd(), ".nyc_output");

type AutoFixtures = {
  autoCoverage: void;
};

export const test = base.extend<AutoFixtures>({
  // When CHROME_USER_DATA_DIR is set, launch OS Chrome with a persistent
  // context against the given (copied) profile directory. OS Chrome can
  // decrypt the profile's cookies via the macOS Keychain — Playwright's
  // bundled Chromium cannot, which is why we need channel: "chrome" and
  // must strip --password-store=basic / --use-mock-keychain from the
  // default args.
  //
  // Use a COPIED profile (npm run pw:gpay:copy-profile) to avoid locking
  // your daily Chrome. Requires --workers=1.
  context: [
    async ({ playwright, browserName }, use, testInfo) => {
      if (process.env.CHROME_USER_DATA_DIR && browserName === "chromium") {
        testInfo.setTimeout(120000);
        const projectUse = testInfo.project.use;
        const context = await chromium.launchPersistentContext(
          process.env.CHROME_USER_DATA_DIR,
          {
            channel: "chrome",
            headless: false,
            timeout: 120000,
            args: [
              "--profile-directory=Default",
              "--no-first-run",
              "--no-default-browser-check",
              "--disable-popup-blocking",
              "--restore-last-session=false",
              "--disable-blink-features=AutomationControlled",
            ],
            viewport: projectUse.viewport,
            baseURL: projectUse.baseURL,
            ignoreDefaultArgs: [
              "--enable-automation",
              "--password-store=basic",
              "--use-mock-keychain",
              "--disable-sync",
            ],
          },
        );
        await use(context);
        await context.close();
      } else {
        const browser = await playwright[browserName].launch(
          testInfo.project.use.launchOptions ?? {},
        );
        const context = await browser.newContext(testInfo.project.use);
        await use(context);
        await context.close();
        await browser.close();
      }
    },
    { scope: "test" },
  ],

  autoCoverage: [
    async ({ page }, use, testInfo) => {
      if (!COVERAGE_ENABLED) {
        await use();
        return;
      }
      await use();
      // The instrumented bundle exposes window.__coverage__ (Istanbul).
      // Read it at the end of the test; a fresh page per test means the
      // counters reflect just this test's execution.
      const coverage = await page
        .evaluate(
          () => (window as unknown as { __coverage__?: unknown }).__coverage__,
        )
        .catch(() => undefined);
      if (coverage && Object.keys(coverage).length > 0) {
        fs.mkdirSync(NYC_OUTPUT_DIR, { recursive: true });
        const file = path.join(
          NYC_OUTPUT_DIR,
          `${testInfo.testId}-${testInfo.retry}.json`,
        );
        fs.writeFileSync(file, JSON.stringify(coverage));
      }
    },
    { auto: true },
  ],
});

export { expect };
