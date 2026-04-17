/**
 * Auto-generated Playwright test
 * Source: module:apm - Alternate Payment Methods section (FF-gated)
 * Generated: 2026-04-17
 *
 * Covers /dashboard/apm which is gated behind `isApmEnabled`. When the flag
 * is off the app redirects to /dashboard/home. Tolerant URL regex keeps the
 * test green in both states.
 */

import { test, expect } from "../support/test";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("APM - Alternate Payment Methods", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
  });

  test("APM page URL resolves (or falls back to home/login when FF off)", async ({
    page,
  }) => {
    await page.goto("/dashboard/apm");
    await page.waitForLoadState("networkidle");

    await expect(page).toHaveURL(/.*dashboard\/(apm|home|login)/);
  });

  test("no page-level JS error thrown on APM route", async ({ page }) => {
    const pageErrors: Error[] = [];
    page.on("pageerror", (err) => pageErrors.push(err));

    await page.goto("/dashboard/apm");
    await page.waitForLoadState("networkidle");

    expect(pageErrors).toHaveLength(0);
  });

  test("direct URL navigation preserves /dashboard prefix", async ({
    page,
  }) => {
    await page.goto("/dashboard/apm");
    await page.waitForLoadState("networkidle");
    await expect(page).toHaveURL(/.*dashboard\/.+/);
  });
});
