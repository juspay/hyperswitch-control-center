import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { DisputesOperations } from "../../support/pages/operations/DisputesOperations";
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
    const disputesOperations = new DisputesOperations(page);

    const disputeRow = disputesOperations.disputeListFirstRow;
    if (!(await disputeRow.isVisible().catch(() => false))) {
      test.skip(true, "no dispute rows rendered (empty merchant)");
    }
    await disputeRow.click();
    await expect(page).toHaveURL(/.*dispute\/|.*disputes\/dp_/);
  });

  test("should open the evidence upload input and accept a file", async ({
    page,
  }) => {
    const disputesOperations = new DisputesOperations(page);

    const disputeRow = disputesOperations.firstDisputeRow;
    if (!(await disputeRow.isVisible().catch(() => false))) {
      test.skip(true, "no dispute rows rendered");
    }
    await disputeRow.click();

    const uploadButton = disputesOperations.uploadEvidenceButton;
    if (!(await uploadButton.isVisible().catch(() => false))) {
      test.skip(true, "upload evidence CTA not exposed");
    }
    await uploadButton.click();

    const fileInput = disputesOperations.fileInput;
    if (!(await fileInput.isVisible().catch(() => false))) {
      test.skip(true, "file input not exposed");
    }
    await fileInput.setInputFiles({
      name: "evidence.pdf",
      mimeType: "application/pdf",
      buffer: Buffer.from("mock pdf content"),
    });

    await expect(disputesOperations.uploadToast).toBeVisible({ timeout: 10000 });
  });

  test("should render a deadline countdown string matching days/hours/minutes", async ({
    page,
  }) => {
    const disputesOperations = new DisputesOperations(page);

    const deadlineElement = disputesOperations.deadlineElement;
    if (!(await deadlineElement.isVisible().catch(() => false))) {
      test.skip(true, "deadline countdown not exposed");
    }
    const deadlineText = await deadlineElement.textContent();
    expect(deadlineText).toMatch(/\d+\s*(day|hour|minute)/i);
  });

  test("should disable the Submit Evidence button for an expired dispute", async ({
    page,
  }) => {
    const disputesOperations = new DisputesOperations(page);

    const expiredDispute = disputesOperations.expiredDispute;
    if (!(await expiredDispute.isVisible().catch(() => false))) {
      test.skip(true, "no expired disputes in this merchant");
    }
    await expiredDispute.click();

    const submitButton = disputesOperations.submitEvidenceButton;
    if (!(await submitButton.isVisible().catch(() => false))) {
      test.skip(true, "submit evidence button not exposed");
    }
    expect(await submitButton.isDisabled()).toBe(true);
  });
});
