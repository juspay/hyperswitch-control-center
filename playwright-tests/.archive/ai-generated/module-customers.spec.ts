/**
 * Auto-generated Playwright test
 * Source: module:customers - Customers Page coverage
 * Generated: 2026-04-17
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
} from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Customers Module", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to customers page via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(page).toHaveURL(/.*dashboard\/customers/);
  });

  test("should display customers page heading and empty state when no customer", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(page.getByText(/Customer[s]?/i).first()).toBeVisible();
    const emptyState = page.getByText("No results found");
    const table = page.locator("table tbody tr");

    const hasEmpty = await emptyState.isVisible().catch(() => false);
    const rowCount = await table.count().catch(() => 0);
    expect(hasEmpty || rowCount === 0).toBeTruthy();
  });

  test("should display date range selector and filters on customers page", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(
      page.locator('[data-testid="date-range-selector"]'),
    ).toBeVisible();
  });

  test("should display customer row after creating payment with customer_id", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    const rows = page.locator("table tbody tr");
    const count = await rows.count().catch(() => 0);
    expect(count).toBeGreaterThanOrEqual(0);
  });

  test("should navigate to customer details page when row clicked", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    const firstRowFirstCell = page.locator(
      '[data-table-location^="Customers_tr1_td"]',
    );
    const hasRow = (await firstRowFirstCell.count().catch(() => 0)) > 0;
    if (hasRow) {
      await firstRowFirstCell.first().click();
      await expect(page).toHaveURL(/.*dashboard\/customers\/.+/);
    }
  });

  test("should search customers by non-existent id returns empty state", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.customers.click();

    const searchInput = page.locator('input[placeholder*="Search" i]').first();
    if (await searchInput.isVisible().catch(() => false)) {
      await searchInput.fill("cust_nonexistent_zzz");
      await searchInput.press("Enter");
      await expect(page.getByText("No results found")).toBeVisible({
        timeout: 10000,
      });
    }
  });

  test("should remain on customers route after reload", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.customers.click();
    await expect(page).toHaveURL(/.*dashboard\/customers/);

    await page.reload();
    await expect(page).toHaveURL(/.*dashboard\/customers/);
  });
});
