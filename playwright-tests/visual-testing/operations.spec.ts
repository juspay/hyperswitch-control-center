import { test, expect } from "../support/test";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  mockV2MerchantList,
  createDummyConnectorAPI,
  createPaymentAPI,
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
