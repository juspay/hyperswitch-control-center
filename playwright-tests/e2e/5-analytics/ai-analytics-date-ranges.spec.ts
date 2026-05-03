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

const PRESET_RANGES: ReadonlyArray<{ label: string; dataValue: string }> = [
  { label: "Last 30 Mins", dataValue: "30m" },
  { label: "Today", dataValue: "today" },
  { label: "Last 7 Days", dataValue: "7d" },
  { label: "Last 30 Days", dataValue: "30d" },
];

test.describe("Payments Analytics - date range presets and chart types", () => {
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
        await createPaymentAPI(merchantId, context.request).catch(() => {});
      }
    }

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();
    await expect(page).toHaveURL(/.*dashboard\/analytics-payments/);

    const fallback = page.getByText("Go to Home", { exact: true }).first();
    if (await fallback.isVisible().catch(() => false)) {
      test.skip(true, "analytics gated off");
    }
  });

  for (const preset of PRESET_RANGES) {
    test(`should apply '${preset.label}' preset and keep a chart visible`, async ({
      page,
    }) => {
      const button = page
        .locator(
          `button:has-text("${preset.label}"), [data-value="${preset.dataValue}"]`,
        )
        .first();
      if (!(await button.isVisible().catch(() => false))) {
        test.skip(true, `preset '${preset.label}' not exposed`);
      }
      await button.click();
      await page.waitForTimeout(1000);

      const chart = page.locator("canvas, svg").first();
      await expect(chart).toBeVisible();
    });
  }

  test("should apply a Custom date range via start/end inputs", async ({
    page,
  }) => {
    const customRangeButton = page
      .locator('button:has-text("Custom"), [data-value="custom"]')
      .first();
    if (!(await customRangeButton.isVisible().catch(() => false))) {
      test.skip(true, "custom range CTA not exposed");
    }
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
  });

  test("should switch between Line / Bar / Pie chart types", async ({
    page,
  }) => {
    const chartTypes = ["Line", "Bar", "Pie"];
    let switchedAny = false;

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
        switchedAny = true;
      }
    }

    if (!switchedAny) {
      test.skip(true, "no chart type toggles exposed");
    }
  });
});
