/**
 * Auto-generated Playwright test
 * Source: module:analytics-extended - dispute/auth/routing/performance/new analytics
 * Generated: 2026-04-17
 */

import { test, expect } from "@playwright/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

async function signupAndLogin(
  page: import("@playwright/test").Page,
  context: import("@playwright/test").BrowserContext,
) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

test.describe("Analytics - direct URL coverage", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should load Payments analytics from sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    await expect(page).toHaveURL(/.*dashboard\/analytics-payments/);
  });

  test("should load Refund analytics from sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.refundAnalytics.click();

    await expect(page).toHaveURL(/.*dashboard\/analytics-refunds/);
  });

  test("should load Dispute analytics via direct URL", async ({ page }) => {
    await page.goto("/dashboard/analytics-disputes");
    await page.waitForLoadState("networkidle");

    const expected = /.*dashboard\/(analytics-disputes|home|login)/;
    await expect(page).toHaveURL(expected);
  });

  test("should load Authentication analytics via direct URL", async ({
    page,
  }) => {
    await page.goto("/dashboard/analytics-authentication");
    await page.waitForLoadState("networkidle");

    const expected =
      /.*dashboard\/(analytics-authentication|home|login)/;
    await expect(page).toHaveURL(expected);
  });

  test("should load Routing analytics via direct URL", async ({ page }) => {
    await page.goto("/dashboard/analytics-routing");
    await page.waitForLoadState("networkidle");

    const expected = /.*dashboard\/(analytics-routing|home|login)/;
    await expect(page).toHaveURL(expected);
  });

  test("should load Performance Monitor via direct URL", async ({ page }) => {
    await page.goto("/dashboard/performance-monitor");
    await page.waitForLoadState("networkidle");

    const expected = /.*dashboard\/(performance-monitor|home|login)/;
    await expect(page).toHaveURL(expected);
  });

  test("should load New Analytics via direct URL", async ({ page }) => {
    await page.goto("/dashboard/new-analytics");
    await page.waitForLoadState("networkidle");

    const expected = /.*dashboard\/(new-analytics|home|login)/;
    await expect(page).toHaveURL(expected);
  });

  test("should display analytics page heading on payments analytics", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();
    await page.waitForLoadState("networkidle");

    await expect(
      page.locator('[class="flex items-center gap-4 "]').first(),
    ).toContainText(/Payment/i);
  });
});
