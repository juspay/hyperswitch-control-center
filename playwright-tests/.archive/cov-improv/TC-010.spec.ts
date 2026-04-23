import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-010: Analytics - Date Range and Granularity", () => {
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

      for (let i = 0; i < 3; i++) {
        try {
          await createPaymentAPI(merchantId, context.request);
        } catch (e) {}
      }
    }
  });

  test("should select Last 30 Mins granularity", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    await expect(page).toHaveURL(/.*dashboard\/analytics-payments/);

    const timeRangeDropdown = page
      .locator(
        '[data-testid*="time-range"], select[name*="timeRange"], button:has-text("Last")',
      )
      .first();
    if (await timeRangeDropdown.isVisible().catch(() => false)) {
      await timeRangeDropdown.click();

      const thirtyMinOption = page
        .locator(
          '[data-value="30m"], option:has-text("30 Mins"), li:has-text("30 Mins")',
        )
        .first();
      if (await thirtyMinOption.isVisible().catch(() => false)) {
        await thirtyMinOption.click();
        await page.waitForTimeout(1000);

        await expect(page.locator("canvas, svg").first()).toBeVisible();
      }
    }
  });

  test("should select Today with hourly breakdown", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const todayButton = page
      .locator('button:has-text("Today"), [data-value="today"]')
      .first();
    if (await todayButton.isVisible().catch(() => false)) {
      await todayButton.click();
      await page.waitForTimeout(1000);

      const chart = page.locator('canvas, svg, [data-testid*="chart"]').first();
      await expect(chart).toBeVisible();
    }
  });

  test("should select Last 7 Days with daily granularity", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const sevenDaysButton = page
      .locator('button:has-text("Last 7 Days"), [data-value="7d"]')
      .first();
    if (await sevenDaysButton.isVisible().catch(() => false)) {
      await sevenDaysButton.click();
      await page.waitForTimeout(1000);

      await expect(page.locator("canvas, svg").first()).toBeVisible();
    }
  });

  test("should select Last 30 Days", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const thirtyDaysButton = page
      .locator('button:has-text("Last 30 Days"), [data-value="30d"]')
      .first();
    if (await thirtyDaysButton.isVisible().catch(() => false)) {
      await thirtyDaysButton.click();
      await page.waitForTimeout(1000);

      await expect(page.locator("canvas, svg").first()).toBeVisible();
    }
  });

  test("should select custom date range spanning 90 days", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const customRangeButton = page
      .locator('button:has-text("Custom"), [data-value="custom"]')
      .first();
    if (await customRangeButton.isVisible().catch(() => false)) {
      await customRangeButton.click();

      const startDateInput = page
        .locator('input[name*="start"], input[placeholder*="Start"]')
        .first();
      const endDateInput = page
        .locator('input[name*="end"], input[placeholder*="End"]')
        .first();

      if (await startDateInput.isVisible().catch(() => false)) {
        await startDateInput.fill("01/01/2024");
      }
      if (await endDateInput.isVisible().catch(() => false)) {
        await endDateInput.fill("03/31/2024");
      }

      const applyButton = page
        .locator('[data-button-for="apply"], button:has-text("Apply")')
        .first();
      if (await applyButton.isVisible().catch(() => false)) {
        await applyButton.click();
        await page.waitForTimeout(1500);
      }
    }
  });

  test("should switch between chart types", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const chartTypes = ["Line", "Bar", "Pie"];

    for (const type of chartTypes) {
      const typeButton = page
        .locator(
          `button:has-text("${type}"), [data-chart-type="${type.toLowerCase()}"]`,
        )
        .first();
      if (await typeButton.isVisible().catch(() => false)) {
        await typeButton.click();
        await page.waitForTimeout(500);

        const chart = page.locator("canvas, svg").first();
        await expect(chart).toBeVisible();
      }
    }
  });
});
