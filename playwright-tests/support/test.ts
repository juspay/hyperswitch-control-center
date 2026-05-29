/// <reference types="node" />
/**
 * Coverage-enabled Playwright test fixture.
 *
 * Starts V8/CDP JS coverage before each test and stops + forwards it to
 * monocart-reporter after each test. Every spec in this repo imports
 * `test` and `expect` from here so coverage is collected automatically
 * with zero per-spec wiring.
 *
 * Coverage is opt-in via the PW_COVERAGE=1 env var (set by the CI job
 * and by the local `pw:coverage` npm script). When unset the fixture is
 * a no-op so day-to-day `npx playwright test` runs stay fast.
 */

import { test as base, expect } from "@playwright/test";
import { addCoverageReport } from "monocart-reporter";

const COVERAGE_ENABLED = process.env.PW_COVERAGE === "1";

type AutoFixtures = {
  autoCoverage: void;
};

export const test = base.extend<AutoFixtures>({
  autoCoverage: [
    async ({ page }, use, testInfo) => {
      if (!COVERAGE_ENABLED) {
        await use();
        return;
      }
      await page.coverage.startJSCoverage({ resetOnNavigation: false });
      await use();
      const coverage = await page.coverage.stopJSCoverage().catch(() => []);
      if (coverage.length > 0) {
        // addCoverageReport adds to the global pool that monocart-reporter
        // aggregates in its onEnd hook; attachCoverageReport would only
        // generate per-test reports without merging.
        await addCoverageReport(coverage, testInfo);
      }
    },
    { auto: true },
  ],
});

export { expect };
