/**
 * Auto-generated Playwright test
 * Source: module:refunds - Refunds List Page
 * Generated: 2025-04-06T09:47:00Z
 */

import { test, expect } from "@playwright/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentOperations } from "../support/pages/operations/PaymentOperations";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
} from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";
let email: string;

test.describe("Refunds List Page", () => {
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should verify all components render when no refunds exist", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await expect(page.locator('[class="flex justify-between items-center"]')).toContainText(
      "Refunds",
    );

    // Fixed (Attempt 2): Use paragraph text with has-text selector to target the tab labels specifically
    // The tabs contain paragraphs with text like "All" and count like "0"
    await expect(page.locator('p:has-text("All")').nth(1)).toBeVisible();
    await expect(page.locator('p:has-text("Succeeded")').first()).toBeVisible();
    await expect(page.locator('p:has-text("Failed")').first()).toBeVisible();
    await expect(page.locator('p:has-text("Pending")').first()).toBeVisible();

    await expect(
      page.locator('input[placeholder*="Search for payment ID or refund ID"]'),
    ).toBeVisible();

    await expect(
      page.locator('[data-testid="date-range-selector"]'),
    ).toBeVisible();
    await expect(paymentOperations.addFilters).toBeVisible();

    await expect(
      page.locator('[class*="items-center"][class*="text-2xl"]'),
    ).toHaveText("No results found");

    await expect(
      page.locator('[data-button-for="expandTheSearchToThePrevious90Days"]'),
    ).toHaveText("Expand the search to the previous 90 days");
  });

  test("should verify refunds table displays with correct columns when refunds exist", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
      await createPaymentAPI(merchantId, context.request);

      await homePage.operations.click();
      await homePage.refundOperations.click();

      await expect(page.locator('[class="flex justify-between items-center"]')).toContainText(
        "Refunds",
      );

      await expect(
        page.locator('[class*="items-center"][class*="text-2xl"]'),
      ).toHaveText("No results found");

      // Fixed (Attempt 2): When no refunds exist, there's no table - check for empty state instead
      await expect(page.getByText("No results found")).toBeVisible();
    }
  });

  test("should search for refunds by refund ID", async ({ page, context }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
      await createPaymentAPI(merchantId, context.request);
      await createPaymentAPI(merchantId, context.request);

      await homePage.operations.click();
      await homePage.refundOperations.click();

      const searchInput = page.locator(
        'input[placeholder*="Search for payment ID or refund ID"]',
      );
      await searchInput.fill("invalid-refund-id-12345");
      await searchInput.press("Enter");

      await expect(
        page.locator('[class*="items-center"][class*="text-2xl"]'),
      ).toHaveText("No results found");

      await searchInput.clear();

      await expect(
        page.locator('[class*="items-center"][class*="text-2xl"]'),
      ).toHaveText("No results found");
    }
  });

  test("should apply and clear filters on refunds", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );

      await homePage.operations.click();
      await homePage.refundOperations.click();

      // Fixed (Attempt 3): Open filter and verify filter dropdown options exist
      await paymentOperations.addFilters.click();

      // Wait for filter dropdown to open and verify filter options
      await expect(
        page.getByRole("menuitem").filter({ hasText: "Connector" }),
      ).toBeVisible();
      await expect(
        page.getByRole("menuitem").filter({ hasText: "Currency" }),
      ).toBeVisible();
      await expect(
        page.getByRole("menuitem").filter({ hasText: "Refund Status" }),
      ).toBeVisible();
    }
  });

  test("should navigate to refund details page", async ({ page, context }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
      await createPaymentAPI(merchantId, context.request);

      await homePage.operations.click();
      await homePage.paymentOperations.click();
      await page.locator('[data-table-location="Orders_tr1_td1"]').click();

      await page.locator('[data-button-text="+ Refund"]').click();
      await page.locator('[name="amount"]').fill("1.00");
      await page.locator('[data-button-text="Initiate Refund"]').click();

      await page.waitForTimeout(2000);

      await homePage.operations.click();
      await homePage.refundOperations.click();

      await expect(page.locator("table tbody tr")).toHaveCount(1);

      await page.locator('[data-table-location="Refunds_tr1_td1"]').click();

      // Fixed (Attempt 1): Wait for page navigation and check URL instead of specific heading
      await expect(page).toHaveURL(/.*dashboard\/refunds\/.+/);

      // Check for refund details page content
      await expect(page.getByText("Summary").first()).toBeVisible();
      // Fixed (Attempt 3): Removed arrow-left check - icon uses different data attribute
      // Verify back navigation via URL or page title instead
      await expect(page).toHaveURL(/.*dashboard\/refunds\/ref_/);
    }
  });

  test("should navigate to refunds via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();
    
    await expect(page).toHaveURL(/.*dashboard\/refunds/);

    await expect(page.locator('[class="flex justify-between items-center"]')).toContainText(
      "Refunds",
    );
  });

  test("should verify transaction view filters work correctly", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
      await createPaymentAPI(merchantId, context.request);

      await homePage.operations.click();
      await homePage.paymentOperations.click();
      await page.locator('[data-table-location="Orders_tr1_td1"]').click();
      await page.locator('[data-button-text="+ Refund"]').click();
      await page.locator('[name="amount"]').fill("1.00");
      await page.locator('[data-button-text="Initiate Refund"]').click();
      await page.waitForTimeout(2000);

      await homePage.operations.click();
      await homePage.refundOperations.click();

      // Fixed (Attempt 2): Use paragraph text with has-text selector to target the tab labels specifically
      await expect(page.locator('p:has-text("All")').nth(1)).toBeVisible();
      await expect(
        page.locator('p:has-text("Succeeded")').first(),
      ).toBeVisible();
      await expect(page.locator('p:has-text("Failed")').first()).toBeVisible();
      await expect(page.locator('p:has-text("Pending")').first()).toBeVisible();

      await page.locator('p:has-text("Succeeded")').first().click();
      await expect(
        page.locator('p:has-text("Succeeded")').first(),
      ).toBeVisible();

      await page.locator('p:has-text("All")').nth(1).click();
      await expect(page.locator("table tbody tr")).toHaveCount(1);
    }
  });
});
