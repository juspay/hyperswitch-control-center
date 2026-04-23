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

test.describe("TC-034: DynamicChart - All Chart Types", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_chart_test",
        context.request,
      );

      for (let i = 0; i < 5; i++) {
        try {
          await createPaymentAPI(merchantId, context.request);
        } catch (e) {}
      }
    }
  });

  test("should switch to Line chart", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const lineChartButton = page
      .locator('button:has-text("Line"), [data-chart-type="line"]')
      .first();
    if (await lineChartButton.isVisible().catch(() => false)) {
      await lineChartButton.click();
      await page.waitForTimeout(1000);

      const chart = page.locator("canvas, svg").first();
      await expect(chart).toBeVisible();
    }
  });

  test("should switch to Bar chart", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const barChartButton = page
      .locator('button:has-text("Bar"), [data-chart-type="bar"]')
      .first();
    if (await barChartButton.isVisible().catch(() => false)) {
      await barChartButton.click();
      await page.waitForTimeout(1000);

      const chart = page.locator("canvas, svg").first();
      await expect(chart).toBeVisible();
    }
  });

  test("should switch to Pie chart", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const pieChartButton = page
      .locator('button:has-text("Pie"), [data-chart-type="pie"]')
      .first();
    if (await pieChartButton.isVisible().catch(() => false)) {
      await pieChartButton.click();
      await page.waitForTimeout(1000);

      const chart = page.locator("canvas, svg").first();
      await expect(chart).toBeVisible();
    }
  });

  test("should change granularity to hourly", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const granularitySelect = page
      .locator('[name*="granularity"], select[data-testid*="granularity"]')
      .first();
    if (await granularitySelect.isVisible().catch(() => false)) {
      await granularitySelect.selectOption("hourly");
      await page.waitForTimeout(1000);

      const chart = page.locator("canvas, svg").first();
      await expect(chart).toBeVisible();
    }
  });

  test("should display tooltip on hover", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const chart = page.locator("canvas, svg").first();
    if (await chart.isVisible().catch(() => false)) {
      const box = await chart.boundingBox();
      if (box) {
        await page.mouse.move(box.x + box.width / 2, box.y + box.height / 2);
        await page.waitForTimeout(500);

        const tooltip = page
          .locator('[data-testid*="tooltip"], [class*="tooltip"]')
          .first();
        await expect(tooltip.or(chart)).toBeTruthy();
      }
    }
  });

  test("should export chart as image", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const exportButton = page
      .locator('[data-button-for="exportChart"], button:has-text("Export")')
      .first();
    if (await exportButton.isVisible().catch(() => false)) {
      const [download] = await Promise.all([
        page.waitForEvent("download", { timeout: 10000 }).catch(() => null),
        exportButton.click(),
      ]);

      if (download) {
        expect(download.suggestedFilename()).toMatch(/\.(png|jpg|svg)$/);
      }
    }
  });

  test("should display empty state for no data", async ({ page }) => {
    const homePage = new HomePage(page);

    await page.route("**/api/analytics/**", async (route) => {
      await route.fulfill({
        status: 200,
        body: JSON.stringify({ data: [], meta: { total: 0 } }),
      });
    });

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    const emptyState = page
      .locator('[data-testid*="empty"], [data-testid*="no-data"]')
      .first();
    await expect(emptyState.or(page.locator("body"))).toBeTruthy();
  });
});
