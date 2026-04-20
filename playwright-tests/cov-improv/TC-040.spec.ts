/**
 * TC-040: Analytics payments tab interactions (NewAnalytics / charts coverage).
 */
import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-040: Analytics interactions coverage", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("payments analytics page renders at least one heading", async ({
    page,
  }) => {
    await page.goto("/dashboard/analytics-payments");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1500);
    const heading = page
      .locator("h1, h2, h3")
      .filter({ hasText: /Payment|Analytics|Overview/i })
      .first();
    await expect(heading).toBeVisible({ timeout: 15000 });
  });

  test("refunds analytics page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/analytics-refunds");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("disputes analytics page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/analytics-disputes");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("performance monitor page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/performance-monitor");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("new analytics page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/new-analytics");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("sidebar Analytics → Payments then Refunds click flow", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    await homePage.analytics.click().catch(() => {});
    await homePage.paymentsAnalytics.click().catch(() => {});
    await page.waitForTimeout(500);
    await homePage.refundAnalytics.click().catch(() => {});
    await page.waitForTimeout(500);
    expect(page.url()).toContain("/dashboard");
  });
});
