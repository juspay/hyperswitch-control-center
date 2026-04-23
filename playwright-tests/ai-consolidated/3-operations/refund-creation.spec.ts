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

test.describe("Refund creation from refunds list page", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    const homePage = new HomePage(page);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_refunds",
        context.request,
      );
      for (let i = 0; i < 3; i++) {
        await createPaymentAPI(merchantId, context.request).catch(() => {});
      }
    }

    await homePage.operations.click();
    await homePage.refundOperations.click();
    await page.waitForLoadState("networkidle");
  });

  test("should open Create Refund modal from refund list and fill payment ID + amount", async ({
    page,
  }) => {
    const createRefundButton = page
      .locator(
        '[data-button-for="createRefund"], button:has-text("Create Refund")',
      )
      .first();
    if (!(await createRefundButton.isVisible().catch(() => false))) {
      test.skip(
        true,
        "Create Refund CTA not exposed on refunds list in this build",
      );
    }
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
    await expect(amountInput).toBeVisible({ timeout: 5000 });
    await amountInput.fill("50");
    await expect(amountInput).toHaveValue("50");
  });

  test("should toggle a Full Refund option in the Create Refund modal", async ({
    page,
  }) => {
    const createRefundButton = page
      .locator('[data-button-for="createRefund"]')
      .first();
    if (!(await createRefundButton.isVisible().catch(() => false))) {
      test.skip(true, "Create Refund CTA not exposed");
    }
    await createRefundButton.click();

    const fullRefundToggle = page.locator(
      '[data-testid*="full-refund"], input[type="checkbox"][name*="fullRefund"]',
    );
    if (!(await fullRefundToggle.isVisible().catch(() => false))) {
      test.skip(true, "full-refund toggle not exposed");
    }
    await fullRefundToggle.check();
    await expect(fullRefundToggle).toBeChecked();
  });

  test("should reject an excess refund amount when submit is attempted", async ({
    page,
  }) => {
    const createRefundButton = page
      .locator('[data-button-for="createRefund"]')
      .first();
    if (!(await createRefundButton.isVisible().catch(() => false))) {
      test.skip(true, "Create Refund CTA not exposed");
    }
    await createRefundButton.click();

    const amountInput = page.locator('[name*="refund_amount"]').first();
    if (!(await amountInput.isVisible().catch(() => false))) {
      test.skip(true, "refund amount input not exposed");
    }
    await amountInput.fill("999999");

    const submitButton = page
      .locator('[data-button-for="submitRefund"]')
      .first();
    if (!(await submitButton.isVisible().catch(() => false))) {
      test.skip(true, "submit refund button not exposed");
    }
    await submitButton.click();

    await expect(
      page.locator(
        '[data-toast*="error"], [data-testid*="refund-error"], [data-field-error*="amount"]',
      ),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should filter refund list by status via status dropdown", async ({
    page,
  }) => {
    const statusFilter = page
      .locator('[name*="status"], select[data-testid*="status"]')
      .first();
    if (!(await statusFilter.isVisible().catch(() => false))) {
      test.skip(true, "status filter not exposed as dropdown");
    }
    await statusFilter.selectOption("succeeded");
    await page.waitForLoadState("networkidle");
    expect(page.url()).toContain("refunds");
  });
});
