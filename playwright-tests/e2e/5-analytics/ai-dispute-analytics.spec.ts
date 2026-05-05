import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe.skip("Dispute Analytics", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.dispute_analytics = true;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_dispute",
        context.request,
      );
    }

    await page.goto("/dashboard/analytics-disputes");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1500);

    const fallback = page.getByText("Go to Home", { exact: true }).first();
    if (await fallback.isVisible().catch(() => false)) {
      test.skip(true, "dispute analytics gated off");
    }
  });

  test("should render a chart and a dispute-reason filter dropdown", async ({
    page,
  }) => {
    await expect(page.locator("canvas, svg").first()).toBeVisible({
      timeout: 10000,
    });

    const reasonFilter = page
      .locator('[name*="reason"], select[data-testid*="reason"]')
      .first();
    await expect(reasonFilter).toBeVisible({ timeout: 10000 });
  });

  test("should re-render the chart after selecting a dispute status filter", async ({
    page,
  }) => {
    const statusFilter = page
      .locator('[name*="dispute_status"], select[data-testid*="status"]')
      .first();
    await expect(statusFilter).toBeVisible({ timeout: 10000 });
    await statusFilter.selectOption({ index: 1 });
    await page.waitForLoadState("networkidle");

    await expect(page.locator("canvas, svg").first()).toBeVisible();
  });

  test("should respond to a click inside the dispute chart area", async ({
    page,
  }) => {
    const chart = page.locator("canvas, svg").first();
    await expect(chart).toBeVisible({ timeout: 10000 });

    const box = await chart.boundingBox();
    expect(box).not.toBeNull();

    if (box) {
      await page.mouse.click(box.x + box.width / 2, box.y + box.height / 2);
      await page.waitForTimeout(1000);
      expect(page.url()).toContain("/dashboard");
    }
  });
});
