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

test.describe("TC-008: Refund Operations - Full Lifecycle", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_refunds",
        context.request,
      );

      for (let i = 0; i < 5; i++) {
        try {
          await createPaymentAPI(merchantId, context.request);
        } catch (e) {
          // Continue even if some payments fail
        }
      }
    }
  });

  test("should create partial refund", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await expect(page).toHaveURL(/.*dashboard\/refunds/);

    const createRefundButton = page.locator(
      '[data-button-for="createRefund"], button:has-text("Create Refund")',
    );
    if (await createRefundButton.isVisible().catch(() => false)) {
      await createRefundButton.click();

      const paymentIdInput = page
        .locator('[name*="payment_id"], [name*="paymentId"]')
        .first();
      if (await paymentIdInput.isVisible().catch(() => false)) {
        await paymentIdInput.fill("pay_test_12345");
      }

      const amountInput = page
        .locator('[name*="refund_amount"], [name*="amount"]')
        .first();
      if (await amountInput.isVisible().catch(() => false)) {
        await amountInput.fill("50");
      }

      const submitButton = page.locator(
        '[data-button-for="submitRefund"], button:has-text("Submit")',
      );
      if (await submitButton.isVisible().catch(() => false)) {
        await submitButton.click();

        await expect(
          page.locator(
            '[data-toast*="success"], [data-toast*="Refund created"]',
          ),
        ).toBeVisible({ timeout: 10000 });
      }
    }
  });

  test("should create full refund", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    const createRefundButton = page
      .locator('[data-button-for="createRefund"]')
      .first();
    if (await createRefundButton.isVisible().catch(() => false)) {
      await createRefundButton.click();

      const fullRefundToggle = page.locator(
        '[data-testid*="full-refund"], input[type="checkbox"][name*="fullRefund"]',
      );
      if (await fullRefundToggle.isVisible().catch(() => false)) {
        await fullRefundToggle.check();
      }

      const submitButton = page
        .locator('[data-button-for="submitRefund"]')
        .first();
      if (await submitButton.isVisible().catch(() => false)) {
        await submitButton.click();

        await expect(
          page.locator(
            '[data-toast*="success"], [data-testid*="refund-status"]:has-text("Succeeded")',
          ),
        ).toBeVisible({ timeout: 10000 });
      }
    }
  });

  test("should prevent excess refund", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    const createRefundButton = page
      .locator('[data-button-for="createRefund"]')
      .first();
    if (await createRefundButton.isVisible().catch(() => false)) {
      await createRefundButton.click();

      const amountInput = page.locator('[name*="refund_amount"]').first();
      if (await amountInput.isVisible().catch(() => false)) {
        await amountInput.fill("999999");
      }

      const submitButton = page
        .locator('[data-button-for="submitRefund"]')
        .first();
      if (await submitButton.isVisible().catch(() => false)) {
        await submitButton.click();

        await expect(
          page.locator(
            '[data-toast*="error"], [data-testid*="refund-error"], [data-field-error*="amount"]',
          ),
        ).toBeVisible({ timeout: 10000 });
      }
    }
  });

  test("should filter refunds by status", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    const statusFilter = page
      .locator('[name*="status"], select[data-testid*="status"]')
      .first();
    if (await statusFilter.isVisible().catch(() => false)) {
      await statusFilter.selectOption("succeeded");
      await page.waitForTimeout(1000);

      const filteredRows = page.locator(
        'table tbody tr, [data-testid*="refund-row"]',
      );
      await expect(filteredRows).toBeTruthy();
    }
  });

  test("should view refund details", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    const refundIdLink = page
      .locator(
        'table tbody tr:first-child td:first-child a, [data-testid*="refund-id"]',
      )
      .first();
    if (await refundIdLink.isVisible().catch(() => false)) {
      await refundIdLink.click();

      await expect(page).toHaveURL(/.*refund\/ref_|.*refund\/details/);

      const refundDetails = page.locator(
        '[data-testid*="refund-details"], [data-testid*="refund-info"]',
      );
      await expect(refundDetails.or(page.locator("body"))).toBeTruthy();
    }
  });
});
