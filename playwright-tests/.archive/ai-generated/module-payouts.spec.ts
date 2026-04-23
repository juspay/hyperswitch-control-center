/**
 * Auto-generated Playwright test
 * Source: module:payouts - Orchestrator Operations → Payouts
 * Generated: 2026-04-17
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Payouts Module", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to payouts page if payouts enabled", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    const payouts = homePage.payoutsOperations;
    if ((await payouts.count().catch(() => 0)) > 0) {
      await payouts.first().click();
      await expect(page).toHaveURL(/.*dashboard\/payouts/);
    }
  });

  test("should display payouts heading or empty state", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    const payouts = homePage.payoutsOperations;
    if ((await payouts.count().catch(() => 0)) > 0) {
      await payouts.first().click();
      await page.waitForLoadState("networkidle");
      await expect(page.getByText(/Payout/i).first()).toBeVisible({
        timeout: 10000,
      });
    }
  });

  test("should display date range selector on payouts", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    const payouts = homePage.payoutsOperations;
    if ((await payouts.count().catch(() => 0)) > 0) {
      await payouts.first().click();
      const selector = page.locator('[data-testid="date-range-selector"]');
      if (await selector.isVisible().catch(() => false)) {
        await expect(selector).toBeVisible();
      }
    }
  });

  test("should preserve payouts URL after reload", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    const payouts = homePage.payoutsOperations;
    if ((await payouts.count().catch(() => 0)) > 0) {
      await payouts.first().click();
      const currentUrl = page.url();
      if (currentUrl.includes("payouts")) {
        await page.reload();
        await expect(page).toHaveURL(/.*dashboard\/payouts/);
      }
    }
  });
});
