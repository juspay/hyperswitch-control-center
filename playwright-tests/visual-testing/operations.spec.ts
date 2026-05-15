import { test, expect } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  mockV2MerchantList,
  createDummyConnectorAPI,
  createPaymentAPI,
  createPayoutConnectorAPI,
  createPayoutAPI,
} from "../support/commands";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentOperations } from "../support/pages/operations/PaymentOperations";
import { RefundOperations } from "../support/pages/operations/RefundOperations";
import { CustomerOperations } from "../support/pages/operations/CustomerOperations";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Visual Testing - Payment Operations", () => {
  test("payment operations when no payment exists should match visual snapshot", async ({ page, context }) => {
    await mockV2MerchantList(page);

    const homePage = new HomePage(page);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    await expect(page).toHaveScreenshot("payment-operations-no-payment.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });

  test("payment operations when payment exists should match visual snapshot", async ({ page, context }) => {
    await mockV2MerchantList(page);

    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
      const paymentData = await createPaymentAPI(merchantId, context.request);
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    await expect(page).toHaveScreenshot("payment-operations-with-payment.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.02,
    });

    await paymentOperations.orderCell(1, 1).click();
    await paymentOperations.addRefundButton.click();
    await paymentOperations.refundAmountInput.fill("12.34");
    await paymentOperations.initiateRefundButton.click();

    await paymentOperations.eventsAndLogsSection.click();
    await expect(page).toHaveScreenshot("payment-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await paymentOperations.firstAttemptRowExpander.click();
    await paymentOperations.connectorTransactionIdInTable.scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-attempt-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await expect(paymentOperations.refundsSectionBlock).toContainText("Refunds");
    await paymentOperations.refundCell(1, 1).click();
    await paymentOperations.refundReasonField.scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-refund-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await paymentOperations.customerDetailsSection.click();
    await paymentOperations.customerEmailTestId("abc@test.com").nth(3).scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-customer-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await paymentOperations.morePaymentDetailsSection.click();
    await paymentOperations.paymentMethodDetailsSection.scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-more-payment-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await paymentOperations.paymentMetadataSection.click();
    await paymentOperations.frmDetailsSection.scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-payment-metadata.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await paymentOperations.frmDetailsSection.click();
    await paymentOperations.merchantDecisionField.scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-frm-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

  });
});

test.describe("Visual Testing - Refund Operations", () => {
  test("refund operations when no refund exists should match visual snapshot", async ({ page, context }) => {
    await mockV2MerchantList(page);

    const homePage = new HomePage(page);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await expect(page).toHaveScreenshot("refund-operations-no-refund.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });

  test("refund operations when refund exists should match visual snapshot", async ({ page, context }) => {
    await mockV2MerchantList(page);

    const homePage = new HomePage(page);
    const refundOperations = new RefundOperations(page);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
      await createPaymentAPI(merchantId, context.request);
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await refundOperations.orderCell(1, 1).click();

    await refundOperations.addRefundButton.click();
    await refundOperations.refundAmountInput.fill("12.34");
    await refundOperations.initiateRefundButton.click();

    await homePage.refundOperations.click();

    await expect(page).toHaveScreenshot("refund-operations-with-refund.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await refundOperations.refundCell(1, 1).click();

    //await expect(page.locator('[class="font-bold text-fs-16 dark:text-white dark:text-opacity-75 mt-4 mb-4"]')).toBeVisible();

    await expect(page).toHaveScreenshot("refund-details-1.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await refundOperations.paymentSectionText.scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("refund-details-2.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });
});

test.describe("Visual Testing - Payout Operations", () => {
  test("payout operations when no payouts exists should match visual snapshot", async ({ page, context }) => {
    await mockV2MerchantList(page);

    const homePage = new HomePage(page);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await homePage.operations.click();
    await homePage.payoutsOperations.click();

    await expect(page).toHaveScreenshot("payout-operations-no-payouts.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });

  test("payout operations when payouts exist should match visual snapshot", async ({ page, context }) => {
    await mockV2MerchantList(page);

    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_test_1",
        context.request,
      );
      await createPayoutAPI(merchantId, context.request);
    }

    await homePage.operations.click();
    await homePage.payoutsOperations.click();

    await expect(page).toHaveScreenshot("payout-operations-with-payouts.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await paymentOperations.payoutCell(1, 1).click();
    await paymentOperations.eventsAndLogsText.click();

    await expect(page).toHaveScreenshot("payout-details-1.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await paymentOperations.customerDetailsSection.click();
    await paymentOperations.payoutMethodText.scrollIntoViewIfNeeded();

    await expect(page).toHaveScreenshot("payout-details-2.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await paymentOperations.morePayoutDetailsSection.click();
    await paymentOperations.payoutErrorCodeText.scrollIntoViewIfNeeded();

    await expect(page).toHaveScreenshot("payout-details-3.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await paymentOperations.payoutMethodDetailsSection.click();
    await paymentOperations.payoutMetadataSection.click();

    await paymentOperations.payoutMetadataJsonText.scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payout-details-4.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

  });
});

test.describe("Visual Testing - Dispute Operations", () => {
  test("dispute operations when no disputes exists should match visual snapshot", async ({ page, context }) => {
    await mockV2MerchantList(page);

    const homePage = new HomePage(page);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await homePage.operations.click();
    await homePage.disputesOperations.click();

    await expect(page).toHaveScreenshot("dispute-operations-no-disputes.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });
});

test.describe("Visual Testing - Customers", () => {
  test("customers page when no customers exist should match visual snapshot", async ({ page, context }) => {
    await mockV2MerchantList(page);

    const homePage = new HomePage(page);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(page).toHaveScreenshot("customers-page-no-customers.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });

  test("customers page when customers exist should match visual snapshot", async ({ page, context }) => {
    await mockV2MerchantList(page);

    const homePage = new HomePage(page);
    const customerOperations = new CustomerOperations(page);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
      await createPaymentAPI(merchantId, context.request);
    }

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(page).toHaveScreenshot("customers-page-with-customers.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await customerOperations.customerCell(1, 1).click();

    await expect(page).toHaveScreenshot("customer-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });
});