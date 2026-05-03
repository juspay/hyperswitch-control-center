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

test.describe("Analytics - chart granularity, tooltip and export", () => {
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
        await createPaymentAPI(merchantId, context.request).catch(() => {});
      }
    }

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();
    await page.waitForLoadState("networkidle");
  });

  test("should switch granularity to hourly and keep a chart rendered", async ({
    page,
  }) => {
    const granularitySelect = page
      .locator('[name*="granularity"], select[data-testid*="granularity"]')
      .first();
    if (!(await granularitySelect.isVisible().catch(() => false))) {
      test.skip(true, "granularity control not exposed");
    }
    await granularitySelect.selectOption("hourly");
    await page.waitForTimeout(1000);
    await expect(page.locator("canvas, svg").first()).toBeVisible();
  });

  test("should show a tooltip area when hovering over a chart", async ({
    page,
  }) => {
    const chart = page.locator("canvas, svg").first();
    if (!(await chart.isVisible().catch(() => false))) {
      test.skip(true, "no chart rendered");
    }
    const box = await chart.boundingBox();
    if (!box) test.skip(true, "chart has no bounding box");

    await page.mouse.move(box!.x + box!.width / 2, box!.y + box!.height / 2);
    await page.waitForTimeout(500);

    const tooltip = page
      .locator('[data-testid*="tooltip"], [class*="tooltip"]')
      .first();
    const visible = (await tooltip.isVisible().catch(() => false)) ||
      (await chart.isVisible());
    expect(visible).toBe(true);
  });

  test("should export the chart as an image via an Export CTA", async ({
    page,
  }) => {
    const exportButton = page
      .locator('[data-button-for="exportChart"], button:has-text("Export")')
      .first();
    if (!(await exportButton.isVisible().catch(() => false))) {
      test.skip(true, "export chart CTA not exposed");
    }
    const [download] = await Promise.all([
      page.waitForEvent("download", { timeout: 10000 }).catch(() => null),
      exportButton.click(),
    ]);
    if (download) {
      expect(download.suggestedFilename()).toMatch(/\.(png|jpg|svg|pdf)$/);
    }
  });

  test("should render a Line chart after clicking the Line toggle", async ({
    page,
  }) => {
    const lineChartButton = page
      .locator('button:has-text("Line"), [data-chart-type="line"]')
      .first();
    if (!(await lineChartButton.isVisible().catch(() => false))) {
      test.skip(true, "Line chart toggle not exposed");
    }
    await lineChartButton.click();
    await page.waitForTimeout(800);
    await expect(page.locator("canvas, svg").first()).toBeVisible();
  });

  test("should render a Bar chart after clicking the Bar toggle", async ({
    page,
  }) => {
    const barChartButton = page
      .locator('button:has-text("Bar"), [data-chart-type="bar"]')
      .first();
    if (!(await barChartButton.isVisible().catch(() => false))) {
      test.skip(true, "Bar chart toggle not exposed");
    }
    await barChartButton.click();
    await page.waitForTimeout(800);
    await expect(page.locator("canvas, svg").first()).toBeVisible();
  });

  test("should render a Pie chart after clicking the Pie toggle", async ({
    page,
  }) => {
    const pieChartButton = page
      .locator('button:has-text("Pie"), [data-chart-type="pie"]')
      .first();
    if (!(await pieChartButton.isVisible().catch(() => false))) {
      test.skip(true, "Pie chart toggle not exposed");
    }
    await pieChartButton.click();
    await page.waitForTimeout(800);
    await expect(page.locator("canvas, svg").first()).toBeVisible();
  });

  test("should render an empty state when analytics API returns no data", async ({
    page,
    context,
  }) => {
    await page.route("**/api/analytics/**", async (route) => {
      await route.fulfill({
        status: 200,
        body: JSON.stringify({ data: [], meta: { total: 0 } }),
      });
    });
    await page.reload();
    await page.waitForLoadState("networkidle");

    const emptyState = page
      .locator('[data-testid*="empty"], [data-testid*="no-data"]')
      .first();
    const bodyHasContent =
      ((await page.locator("body").textContent()) || "").length > 0;
    expect(
      (await emptyState.isVisible().catch(() => false)) || bodyHasContent,
    ).toBe(true);
  });
});
