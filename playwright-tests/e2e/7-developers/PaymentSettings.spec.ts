import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentSettings } from "../../support/pages/developers/PaymentSettings";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Payment Settings", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test.describe("Navigation and Header", () => {
    test("should navigate to payment settings page via sidebar", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(page).toHaveURL(/.*dashboard\/payment-settings/);
      await expect(paymentSettings.pageHeader).toBeVisible({ timeout: 10000 });
    });

    test("should display page header and information cards", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(paymentSettings.pageHeader).toBeVisible({ timeout: 10000 });
      await expect(paymentSettings.profileName).toBeVisible();
      await expect(paymentSettings.profileId).toBeVisible();
      await expect(paymentSettings.merchantId).toBeVisible();
      await expect(paymentSettings.paymentResponseHashKey).toBeVisible();
    });

    test("should display copy buttons for Profile ID and Hash Key", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(paymentSettings.profileId).toBeVisible();
      await expect(paymentSettings.paymentResponseHashKey).toBeVisible();
    });
  });

  test.describe("Tabs Navigation", () => {
    test("should display all available tabs", async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(paymentSettings.paymentBehaviourTab).toBeVisible();
      await expect(paymentSettings.threeDSTab).toBeVisible();
      await expect(paymentSettings.customHeadersTab).toBeVisible();
      await expect(paymentSettings.metadataHeadersTab).toBeVisible();
      await expect(paymentSettings.paymentLinkTab).toBeVisible();
    });

    test("should switch between tabs correctly", async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(paymentSettings.collectBillingDetailsToggle).toBeVisible();

      await paymentSettings.threeDSTab.click();
      await expect(paymentSettings.force3DSChallengeToggle).toBeVisible();

      await paymentSettings.customHeadersTab.click();
      await expect(paymentSettings.customHeadersKeyInput).toBeVisible();

      await paymentSettings.metadataHeadersTab.click();
      await expect(paymentSettings.customMetadataHeadersHeading).toBeVisible();

      await paymentSettings.paymentLinkTab.click();
      await expect(paymentSettings.paymentLinkDomainHeading).toBeVisible();
    });

    // TODO: Assert clicked tab is highlighted and content of previously active tab is hidden when switching tabs.
  });

  test.describe("Payment Behaviour Tab", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      await homePage.developer.click();
      await homePage.paymentSettings.click();
    });

    test("should display all toggle options", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.collectBillingDetailsToggle).toBeVisible();
      await expect(paymentSettings.collectShippingDetailsToggle).toBeVisible();
      await expect(paymentSettings.autoRetriesToggle).toBeVisible();
      await expect(paymentSettings.manualRetriesToggle).toBeVisible();
      await expect(paymentSettings.extendedAuthorizationToggle).toBeVisible();
      await expect(paymentSettings.alwaysEnableOvercaptureToggle).toBeVisible();
      await expect(paymentSettings.networkTokenizationToggle).toBeVisible();
      await expect(paymentSettings.clickToPayToggle).toBeVisible();
    });

    test("should display form fields with correct labels", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.returnUrlInput).toBeVisible();
      await expect(paymentSettings.webhookUrlInput).toBeVisible();
    });

    test("should display Merchant Category Code dropdown", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.merchantCategoryCodeDropdown).toBeVisible();
      // TODO: Assert dropdown options are displayed correctly when clicked and correct value is selected when an option is clicked.
    });

    test("should allow entering values in form fields", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.fillReturnUrl("https://example.com/return");
      await paymentSettings.fillWebhookUrl("https://example.com/webhook");

      await expect(paymentSettings.returnUrlInput).toHaveValue(
        "https://example.com/return",
      );
      await expect(paymentSettings.webhookUrlInput).toHaveValue(
        "https://example.com/webhook",
      );
    });

    test("should display Update button", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.updateButton).toBeVisible();
    });

    // TODO: Add test to toggle options, fill forms and select dropdown values to verify they are saved correctly when Update button is clicked.
  });

  test.describe("3DS Tab", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.threeDSTab.click();
    });

    test("should display Force 3DS Challenge toggle", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.force3DSChallengeToggle).toBeVisible();
    });

    test("should display Acquirer Config Settings section", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.acquirerConfigSettings).toBeVisible();
    });

    test("should display Update button", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.updateButton).toBeVisible();
    });

    // TODO: Assert fields for acquirer config settings are visible and can be interacted with.
    // TODO: Add test to toggle options, fill forms and select dropdown values to verify they are saved correctly when Update button is clicked.
  });

  test.describe("Custom Headers Tab", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.customHeadersTab.click();
    });

    test("should display key-value input pairs", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.customHeadersKeyInput).toBeVisible();
      await expect(paymentSettings.customHeadersValueInput).toBeVisible();
    });

    test("should allow entering custom header values", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.fillCustomHeader(
        "X-Custom-Header",
        "CustomValue123",
      );

      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        "X-Custom-Header",
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        "CustomValue123",
      );
    });

    test("should display Update button", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.updateButton).toBeVisible();
    });

    // TODO: Add test to verify that custom headers are saved correctly when Update button is clicked.
  });

  test.describe("Metadata Headers Tab", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.metadataHeadersTab.click();
    });

    test("should display Custom Metadata Headers heading", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.customMetadataHeadersHeading).toBeVisible();
    });

    test("should allow entering metadata header values", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.fillCustomHeader("metadata-key", "metadata-value");

      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        "metadata-key",
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        "metadata-value",
      );
    });

    test("should display Update button", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.updateButton).toBeVisible();
    });

    // TODO: Add test to verify that metadata headers are saved correctly when Update button is clicked.
  });

  test.describe("Payment Link Tab", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.paymentLinkTab.click();
    });

    test("should display Payment Link Domain heading", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.paymentLinkDomainHeading).toBeVisible();
    });

    test("should display Update and Cancel buttons", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.updateButton).toBeVisible();
      await expect(paymentSettings.cancelButton).toBeVisible();
    });

    test("should disable Update button when form is invalid", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.updateButton).toBeDisabled();
    });

    test("should allow entering domain values", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.fillPaymentLinkDomain(
        "https://example.com",
        "example.com",
      );

      await expect(paymentSettings.domainNameInput).toHaveValue(
        "https://example.com",
      );
      await expect(paymentSettings.allowedDomainInput).toHaveValue(
        "example.com",
      );
    });
  });

  test.describe("Form Validation and Interaction", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      await homePage.developer.click();
      await homePage.paymentSettings.click();
    });

    test("should validate URL format in Return URL field", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.fillReturnUrl("not-a-valid-url");
      await expect(paymentSettings.returnUrlInput).toHaveValue(
        "not-a-valid-url",
      );

      await paymentSettings.returnUrlInput.clear();
      await paymentSettings.fillReturnUrl("https://example.com/callback");
      await expect(paymentSettings.returnUrlInput).toHaveValue(
        "https://example.com/callback",
      );
    });

    test("should allow clicking Cancel button in Payment Link tab", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.paymentLinkTab.click();
      await paymentSettings.clickCancel();

      await expect(page).toHaveURL(/.*dashboard/);
    });
  });
});
