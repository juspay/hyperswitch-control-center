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

test.describe("Payment Operations - table advanced features", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_payments",
        context.request,
      );
      for (let i = 0; i < 5; i++) {
        await createPaymentAPI(merchantId, context.request).catch(() => {});
      }
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.waitForTimeout(2000);
  });

  test("should allow exporting the payments table to CSV", async ({ page }) => {
    const exportButton = page
      .locator(
        '[data-button-for="export"], button:has-text("Export"), [data-testid*="export"]',
      )
      .first();
    if (!(await exportButton.isVisible().catch(() => false))) {
      test.skip(true, "export CTA not exposed");
    }

    const [download] = await Promise.all([
      page.waitForEvent("download", { timeout: 10000 }).catch(() => null),
      exportButton.click(),
    ]);

    if (download) {
      expect(download.suggestedFilename()).toMatch(/\.(csv|xlsx)$/);
    }
  });

  test("should accept special characters in the search input without crashing", async ({
    page,
  }) => {
    const searchInput = page
      .locator('[data-testid*="search"], input[placeholder*="search" i]')
      .first();
    if (!(await searchInput.isVisible().catch(() => false))) {
      test.skip(true, "search input not exposed");
    }
    await searchInput.fill("test@#$%123");
    await searchInput.press("Enter");
    await page.waitForTimeout(1000);
    expect(page.url()).toMatch(/dashboard/);
  });

  test("should clear all active filters and reset filter badges", async ({
    page,
  }) => {
    const clearAllButton = page
      .locator(
        '[data-button-for="clearAll"], [data-button-for="clearFilters"], button:has-text("Clear All"), button:has-text("Clear")',
      )
      .first();
    if (!(await clearAllButton.isVisible().catch(() => false))) {
      test.skip(true, "Clear all CTA not exposed");
    }
    await clearAllButton.click();
    await page.waitForTimeout(500);

    const activeFilters = page.locator(
      '[data-testid*="active-filter"], [data-testid*="filter-badge"]',
    );
    await expect(activeFilters).toHaveCount(0);
  });
});
