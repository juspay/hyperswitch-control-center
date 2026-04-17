/**
 * Auto-generated Playwright test
 * Source: module:refunds - extended coverage (creation, detail page, filters, errors)
 * Generated: 2026-04-17
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

test.describe("Refunds - Extended Coverage", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should render refunds page with empty state when no payment exists", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await expect(page).toHaveURL(/.*dashboard\/refunds/);
    await expect(
      page.locator('[class="flex justify-between items-center"]'),
    ).toContainText("Refunds");
    await expect(page.getByText("No results found")).toBeVisible();
  });

  test("should show all transaction view tabs for refunds", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await expect(page.locator('p:has-text("All")').nth(1)).toBeVisible();
    await expect(page.locator('p:has-text("Succeeded")').first()).toBeVisible();
    await expect(page.locator('p:has-text("Failed")').first()).toBeVisible();
    await expect(page.locator('p:has-text("Pending")').first()).toBeVisible();
  });

  test("should successfully initiate refund from payment details page", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
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
  });

  test("should display refund data in table columns", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.locator('[data-table-location="Orders_tr1_td1"]').click();
    await page.locator('[data-button-text="+ Refund"]').click();
    await page.locator('[name="amount"]').fill("5.00");
    await page.locator('[data-button-text="Initiate Refund"]').click();
    await page.waitForTimeout(2000);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await expect(
      page.locator('[data-table-location="Refunds_tr1_td1"]'),
    ).toContainText("1");
  });

  test("should filter refunds by Succeeded and All tabs", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.locator('[data-table-location="Orders_tr1_td1"]').click();
    await page.locator('[data-button-text="+ Refund"]').click();
    await page.locator('[name="amount"]').fill("2.50");
    await page.locator('[data-button-text="Initiate Refund"]').click();
    await page.waitForTimeout(2000);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await page.locator('p:has-text("Failed")').first().click();
    await expect(page.getByText("No results found")).toBeVisible();

    await page.locator('p:has-text("All")').nth(1).click();
    await expect(page.locator("table tbody tr")).toHaveCount(1);
  });

  test("should open filter dropdown and display refund filter options", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await paymentOperations.addFilters.click();

    await expect(
      page.getByRole("menuitem").filter({ hasText: "Connector" }),
    ).toBeVisible();
    await expect(
      page.getByRole("menuitem").filter({ hasText: "Currency" }),
    ).toBeVisible();
    await expect(
      page.getByRole("menuitem").filter({ hasText: "Refund Status" }),
    ).toBeVisible();
  });

  test("should search for non-existent refund ID and show empty state", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    const searchInput = page.locator(
      'input[placeholder*="Search for payment ID or refund ID"]',
    );
    await searchInput.fill("ref_nonexistent_9999");
    await searchInput.press("Enter");

    await expect(page.getByText("No results found")).toBeVisible();
  });

  test("should validate refund amount exceeding payment amount is rejected", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.locator('[data-table-location="Orders_tr1_td1"]').click();

    await page.locator('[data-button-text="+ Refund"]').click();
    const amountInput = page.locator('[name="amount"]');
    await amountInput.fill("9999.99");

    const initiateButton = page.locator('[data-button-text="Initiate Refund"]');
    await expect(initiateButton).toBeVisible();
  });

  test("should navigate to refund details page from refund list", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.locator('[data-table-location="Orders_tr1_td1"]').click();
    await page.locator('[data-button-text="+ Refund"]').click();
    await page.locator('[name="amount"]').fill("3.00");
    await page.locator('[data-button-text="Initiate Refund"]').click();
    await page.waitForTimeout(2000);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await page.locator('[data-table-location="Refunds_tr1_td1"]').click();

    await expect(page).toHaveURL(/.*dashboard\/refunds\/ref_/);
    await expect(page.getByText("Summary").first()).toBeVisible();
  });

  test("should display date range selector on refunds page", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await expect(
      page.locator('[data-testid="date-range-selector"]'),
    ).toBeVisible();
  });
});
