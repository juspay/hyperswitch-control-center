import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentOperations } from "../../support/pages/operations/PaymentOperations";
import { DisputesOperations } from "../../support/pages/operations/DisputesOperations";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI, createDummyConnectorAPI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Disputes list page", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    const homePage = new HomePage(page);
    await homePage.operations.click();
    await homePage.disputesOperations.click();
    await page.waitForURL(/dashboard\/disputes/, { timeout: 15000 });
    await page.waitForLoadState("networkidle");
  });

  test("should display disputes heading, subtitle, search, and empty state", async ({
    page,
  }) => {
    const disputesOperations = new DisputesOperations(page);
    const paymentOperations = new PaymentOperations(page);

    await expect(page.getByText("Disputes").first()).toBeVisible({ timeout: 10000 });
    await expect(page.getByText(/View and manage all disputes/i)).toBeVisible({ timeout: 10000 });
    await expect(disputesOperations.searchInput).toBeVisible({ timeout: 10000 });
    await expect(page.getByText("No results found")).toBeVisible({ timeout: 10000 });
    await expect(paymentOperations.expandSearch90Days).toBeVisible({ timeout: 10000 });
    await expect(paymentOperations.dateSelector).toBeVisible({ timeout: 10000 });
    await expect(paymentOperations.addFilters).toBeVisible({ timeout: 10000 });

    await expect(disputesOperations.fourColumnGrid).toBeVisible({ timeout: 10000 });
  });

  test("should open filter dropdown and show filter options", async ({
    page,
  }) => {
    const paymentOperations = new PaymentOperations(page);
    const disputesOperations = new DisputesOperations(page);

    await paymentOperations.addFilters.click();
    await expect(disputesOperations.filterDropdown).toBeVisible({
      timeout: 10000,
    });
    await expect(disputesOperations.filterDropdownOptions).toBeVisible({
      timeout: 10000,
    });
  });

  test("should display 'No results found' for non-matching search id", async ({
    page,
  }) => {
    const disputesOperations = new DisputesOperations(page);

    await page.reload();
    await expect(page).toHaveURL(/.*dashboard\/disputes/);

    await disputesOperations.searchInput.fill("dp_nonexistent_zzz");
    await disputesOperations.searchInput.press("Enter");
    await expect(page.getByText("No results found")).toBeVisible({ timeout: 10000 });
  });
});

test.describe.fixme("Disputes - detail page and evidence upload", () => {
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

    await disputeRow.click();
    await expect(page).toHaveURL(/.*dispute\/|.*disputes\/dp_/);
  });

  test("should open the evidence upload input and accept a file", async ({
    page,
  }) => {
    const disputesOperations = new DisputesOperations(page);

    const disputeRow = disputesOperations.firstDisputeRow;

    await disputeRow.click();

    const uploadButton = disputesOperations.uploadEvidenceButton;

    await uploadButton.click();

    const fileInput = disputesOperations.fileInput;

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

    const deadlineText = await deadlineElement.textContent();
    expect(deadlineText).toMatch(/\d+\s*(day|hour|minute)/i);
  });

  test("should disable the Submit Evidence button for an expired dispute", async ({
    page,
  }) => {
    const disputesOperations = new DisputesOperations(page);

    const expiredDispute = disputesOperations.expiredDispute;

    await expiredDispute.click();

    const submitButton = disputesOperations.submitEvidenceButton;

    expect(await submitButton.isDisabled()).toBe(true);
  });
});
