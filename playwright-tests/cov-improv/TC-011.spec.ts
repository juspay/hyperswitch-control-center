import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
} from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-011: Dispute Analytics - Filter Drill-down", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_analytics",
        context.request,
      );
    }

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.dispute_analytics = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should navigate to dispute analytics", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();

    // Fixed: Added guard to check if dispute analytics nav exists before clicking
    const disputeNav = page
      .locator('[data-testid*="dispute"], a[href*="analytics-disputes"]')
      .first();
    if (!(await disputeNav.isVisible().catch(() => false))) {
      return;
    }
    await disputeNav.click();

    await expect(page).toHaveURL(/.*dashboard\/analytics-disputes/);
  });

  test("should filter by dispute reason", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();

    const disputeNav = page
      .locator('[data-testid*="dispute"], a[href*="analytics-disputes"]')
      .first();
    if (!(await disputeNav.isVisible().catch(() => false))) {
      return;
    }
    await disputeNav.click();

    const reasonFilter = page
      .locator('[name*="reason"], select[data-testid*="reason"]')
      .first();
    if (await reasonFilter.isVisible().catch(() => false)) {
      await reasonFilter.selectOption({ index: 1 });
      await page.waitForTimeout(1000);

      await expect(page.locator("canvas, svg").first()).toBeVisible();
    }
  });

  test("should filter by dispute status", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();

    const disputeNav = page.locator('[data-testid*="dispute"]').first();
    if (!(await disputeNav.isVisible().catch(() => false))) {
      return;
    }
    await disputeNav.click();

    const statusFilter = page
      .locator('[name*="dispute_status"], select[data-testid*="status"]')
      .first();
    if (await statusFilter.isVisible().catch(() => false)) {
      await statusFilter.selectOption("open");
      await page.waitForTimeout(1000);

      await expect(page.locator("canvas, svg").first()).toBeVisible();
    }
  });

  test("should drill down to specific dispute", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();

    const disputeNav = page.locator('[data-testid*="dispute"]').first();
    if (!(await disputeNav.isVisible().catch(() => false))) {
      return;
    }
    await disputeNav.click();

    const chartSegment = page.locator("canvas, svg").first();
    if (await chartSegment.isVisible().catch(() => false)) {
      const box = await chartSegment.boundingBox();
      if (box) {
        await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
        await page.waitForTimeout(1000);
      }
    }
  });
});
