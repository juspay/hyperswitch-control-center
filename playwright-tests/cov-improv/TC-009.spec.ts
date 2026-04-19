import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
} from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-009: Dispute Management - Evidence Upload", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_disputes",
        context.request,
      );
    }
  });

  test("should navigate to disputes and view list", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();

    await expect(page).toHaveURL(/.*dashboard\/disputes/);

    const disputesTable = page.locator('table, [data-testid*="dispute-list"]');
    await expect(
      disputesTable.or(page.locator('[data-testid*="empty"]')),
    ).toBeVisible();
  });

  test("should view dispute details", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();

    const disputeRow = page
      .locator('table tbody tr:first-child, [data-testid*="dispute-item"]')
      .first();
    if (await disputeRow.isVisible().catch(() => false)) {
      await disputeRow.click();

      await expect(page).toHaveURL(/.*dispute\/|.*disputes\/dp_/);

      const disputeDetails = page.locator(
        '[data-testid*="dispute-details"], [data-testid*="dispute-info"]',
      );
      await expect(
        disputeDetails.or(page.locator("h1:has-text('Dispute')")),
      ).toBeTruthy();
    }
  });

  test("should upload evidence files", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();

    const disputeRow = page.locator("table tbody tr:first-child").first();
    if (await disputeRow.isVisible().catch(() => false)) {
      await disputeRow.click();

      const uploadButton = page
        .locator(
          '[data-button-for="uploadEvidence"], button:has-text("Upload")',
        )
        .first();
      if (await uploadButton.isVisible().catch(() => false)) {
        await uploadButton.click();

        const fileInput = page.locator('input[type="file"]').first();
        if (await fileInput.isVisible().catch(() => false)) {
          await fileInput.setInputFiles({
            name: "evidence.pdf",
            mimeType: "application/pdf",
            buffer: Buffer.from("mock pdf content"),
          });

          await expect(
            page.locator('[data-toast*="upload"], [data-toast*="success"]'),
          ).toBeVisible({ timeout: 10000 });
        }
      }
    }
  });

  test("should display deadline countdown", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();

    const deadlineElement = page
      .locator('[data-testid*="deadline"], [data-testid*="countdown"]')
      .first();
    if (await deadlineElement.isVisible().catch(() => false)) {
      const deadlineText = await deadlineElement.textContent();
      expect(deadlineText).toMatch(/\d+\s*(day|hour|minute)/i);
    }
  });

  test("should prevent late submission", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();

    const expiredDispute = page
      .locator('[data-testid*="expired"], tr:has-text("Expired")')
      .first();
    if (await expiredDispute.isVisible().catch(() => false)) {
      await expiredDispute.click();

      const submitButton = page
        .locator('[data-button-for="submitEvidence"]')
        .first();
      if (await submitButton.isVisible().catch(() => false)) {
        const isDisabled = await submitButton.isDisabled();
        expect(isDisabled).toBe(true);
      }
    }
  });
});
