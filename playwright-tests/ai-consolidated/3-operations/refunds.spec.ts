import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentOperations } from "../../support/pages/operations/PaymentOperations";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Refunds list page", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should verify empty-state components on refund list", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    await homePage.operations.click();
    await homePage.refundOperations.click();

    await expect(
      page.locator('[class="flex justify-between items-center"]'),
    ).toContainText("Refunds");

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

  test("should show refund-specific filters in Add Filter dropdown", async ({
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
    }

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

  test("should show non-existent refund ID search empty state", async ({
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

  test("should initiate refund from payment details and display it on refund list + details page", async ({
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
    await expect(
      page.locator('[data-table-location="Refunds_tr1_td1"]'),
    ).toContainText("1");

    await page.locator('[data-table-location="Refunds_tr1_td1"]').click();
    await expect(page).toHaveURL(/.*dashboard\/refunds\/ref_/);
    await expect(page.getByText("Summary").first()).toBeVisible();
  });

  test("should filter refund list by Succeeded and All tabs", async ({
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
});
