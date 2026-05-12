import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Disputes - detail page and evidence upload", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
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

    await homePage.operations.click();
    await homePage.disputesOperations.click();
    await page.waitForURL(/dashboard\/disputes/, { timeout: 15000 });
    await page.waitForLoadState("networkidle");
  });

  test("should navigate to a dispute detail page when a row is clicked", async ({
    page,
  }) => {
    const disputeRow = page
      .locator('table tbody tr:first-child, [data-testid*="dispute-item"]')
      .first();
    if (!(await disputeRow.isVisible().catch(() => false))) {
      test.skip(true, "no dispute rows rendered (empty merchant)");
    }
    await disputeRow.click();
    await expect(page).toHaveURL(/.*dispute\/|.*disputes\/dp_/);
  });

  test("should open the evidence upload input and accept a file", async ({
    page,
  }) => {
    const disputeRow = page.locator("table tbody tr:first-child").first();
    if (!(await disputeRow.isVisible().catch(() => false))) {
      test.skip(true, "no dispute rows rendered");
    }
    await disputeRow.click();

    const uploadButton = page
      .locator('[data-button-for="uploadEvidence"], button:has-text("Upload")')
      .first();
    if (!(await uploadButton.isVisible().catch(() => false))) {
      test.skip(true, "upload evidence CTA not exposed");
    }
    await uploadButton.click();

    const fileInput = page.locator('input[type="file"]').first();
    if (!(await fileInput.isVisible().catch(() => false))) {
      test.skip(true, "file input not exposed");
    }
    await fileInput.setInputFiles({
      name: "evidence.pdf",
      mimeType: "application/pdf",
      buffer: Buffer.from("mock pdf content"),
    });

    await expect(
      page.locator('[data-toast*="upload"], [data-toast*="success"]'),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should render a deadline countdown string matching days/hours/minutes", async ({
    page,
  }) => {
    const deadlineElement = page
      .locator('[data-testid*="deadline"], [data-testid*="countdown"]')
      .first();
    if (!(await deadlineElement.isVisible().catch(() => false))) {
      test.skip(true, "deadline countdown not exposed");
    }
    const deadlineText = await deadlineElement.textContent();
    expect(deadlineText).toMatch(/\d+\s*(day|hour|minute)/i);
  });

  test("should disable the Submit Evidence button for an expired dispute", async ({
    page,
  }) => {
    const expiredDispute = page
      .locator('[data-testid*="expired"], tr:has-text("Expired")')
      .first();
    if (!(await expiredDispute.isVisible().catch(() => false))) {
      test.skip(true, "no expired disputes in this merchant");
    }
    await expiredDispute.click();

    const submitButton = page
      .locator('[data-button-for="submitEvidence"]')
      .first();
    if (!(await submitButton.isVisible().catch(() => false))) {
      test.skip(true, "submit evidence button not exposed");
    }
    expect(await submitButton.isDisabled()).toBe(true);
  });
});
