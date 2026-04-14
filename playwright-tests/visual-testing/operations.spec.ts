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

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Visual Testing - Payment Operations", () => {
  test("payment operations when no payment exists should match visual snapshot", async ({ page,context }) => {
    await mockV2MerchantList(page);
    
    const homePage = new HomePage(page);
    
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    await expect(page).toHaveScreenshot("payment-operations-no-payment.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });

  test("payment operations when payment exists should match visual snapshot", async ({ page,context }) => {
    await mockV2MerchantList(page);
    
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);
    
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

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
    maxDiffPixelRatio: 0.01,
    });

    await page.locator('[data-table-location="Orders_tr1_td1"]').click();
    await page.locator('[data-button-text="+ Refund"]').click();
    await page.locator('[name="amount"]').fill("12.34");
    await page.locator('[data-button-text="Initiate Refund"]').click();

    await page.locator('div').filter({ hasText: /^Events and logs$/ }).first().click();
    await expect(page).toHaveScreenshot("payment-details.png", {
    fullPage: true,
    animations: "disabled",
    maxDiffPixelRatio: 0.01,
    });

    await page.locator('div').filter({ hasText: /^1$/ }).nth(1).click();
    await page.getByRole('table').getByText('Connector Transaction ID').scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-attempt-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await expect(page.locator('[class="flex flex-col gap-4"]').nth(1)).toContainText("Refunds");
    await page.locator('[data-table-location="Refunds_tr1_td1"]').click();
    await page.getByText('Refund ReasonN/A').scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-refund-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await page.getByText('Customer Details').click();
    await page.getByTestId('abc@test.com').nth(3).scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-customer-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await page.getByText('More Payment Details').click();
    await page.locator('div').filter({ hasText: /^Payment Method Details$/ }).first().scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-more-payment-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await page.getByText('Payment Metadata').click();
    await page.getByText('FRM Details').scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-payment-metadata.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await page.getByText('FRM Details').click();
    await page.getByText('Merchant DecisionN/A').scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payment-frm-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

  });
});

test.describe("Visual Testing - Refund Operations", () => {
  test("refund operations when no refund exists should match visual snapshot", async ({ page,context }) => {
    await mockV2MerchantList(page);
    
    const homePage = new HomePage(page);
    
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await expect(page).toHaveScreenshot("refund-operations-no-refund.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });

  test("refund operations when refund exists should match visual snapshot", async ({ page,context }) => {
    await mockV2MerchantList(page);
    
    const homePage = new HomePage(page);
    
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
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
    await page.locator('[data-table-location="Orders_tr1_td1"]').click();

    await page.locator('[data-button-text="+ Refund"]').click();
    await page.locator('[name="amount"]').fill("12.34");
    await page.locator('[data-button-text="Initiate Refund"]').click();

    await homePage.refundOperations.click();

    await expect(page).toHaveScreenshot("refund-operations-with-refund.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await page.locator('[data-table-location="Refunds_tr1_td1"]').click();

    //await expect(page.locator('[class="font-bold text-fs-16 dark:text-white dark:text-opacity-75 mt-4 mb-4"]')).toBeVisible();

    await expect(page).toHaveScreenshot("refund-details-1.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await page.getByText('Payment', { exact: true }).scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("refund-details-2.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });
});

test.describe("Visual Testing - Payout Operations", () => {
  test("payout operations when no payouts exists should match visual snapshot", async ({ page,context }) => {
    await mockV2MerchantList(page);
    
    const homePage = new HomePage(page);
    
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await homePage.operations.click();
    await homePage.payoutsOperations.click();

    await expect(page).toHaveScreenshot("payout-operations-no-payouts.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });

  test("payout operations when payouts exist should match visual snapshot", async ({ page,context }) => {
    await mockV2MerchantList(page);
    
    const homePage = new HomePage(page);
    
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
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

    await page.locator('[data-table-location="Payouts_tr1_td1"]').click();
    await page.getByText('Events and logs').click();

    await expect(page).toHaveScreenshot("payout-details-1.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await page.getByText('Customer Details').click();
    await page.getByText('Payout Method', { exact: true }).scrollIntoViewIfNeeded();

    await expect(page).toHaveScreenshot("payout-details-2.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await page.getByText('More Payout Details').click();
    await page.getByText('Error Code', { exact: true }).scrollIntoViewIfNeeded();

    await expect(page).toHaveScreenshot("payout-details-3.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await page.getByText('Payout Method Details').click();
    await page.getByText('Payout Metadata').click();

    await page.getByText('{ 2 "key": "value" 3}').scrollIntoViewIfNeeded();
    await expect(page).toHaveScreenshot("payout-details-4.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
 
  });
});

test.describe("Visual Testing - Dispute Operations", () => {
  test("dispute operations when no disputes exists should match visual snapshot", async ({ page,context }) => {
    await mockV2MerchantList(page);
    
    const homePage = new HomePage(page);
    
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

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
  test("customers page when no customers exist should match visual snapshot", async ({ page,context }) => {
    await mockV2MerchantList(page);
    
    const homePage = new HomePage(page);
    
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(page).toHaveScreenshot("customers-page-no-customers.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });

  test("customers page when customers exist should match visual snapshot", async ({ page,context }) => {
    await mockV2MerchantList(page);
    
    const homePage = new HomePage(page);
    
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

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

    await page.locator('[data-table-location="Customers_tr1_td1"]').click();

    await expect(page).toHaveScreenshot("customer-details.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });
});