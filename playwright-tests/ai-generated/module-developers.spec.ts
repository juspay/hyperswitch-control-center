/**
 * Auto-generated Playwright test
 * Source: module:developers - API Keys, Webhooks, Payment Settings
 * Generated: 2026-04-17
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentSettings } from "../support/pages/developers/PaymentSettings";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Developers - API Keys", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to API Keys via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await expect(page).toHaveURL(/.*dashboard\/developer-api-keys/);
    await expect(
      page.getByRole("heading", { name: "API Keys", level: 2 }),
    ).toBeVisible();
  });

  test("should display Create New API Key button", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await expect(
      page.getByRole("button", { name: "Create New API Key" }),
    ).toBeVisible();
  });

  test("should open Create API Key modal and disable Create when name empty", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();
    await expect(page.getByText("Create API Key")).toBeVisible();

    await expect(
      page.getByRole("button", { name: "Create", exact: true }),
    ).toBeDisabled();
  });

  test("should create API Key with valid name and description", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const keyName = `AI key ${Date.now()}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();
    await expect(page.getByText("Create API Key")).toBeVisible();

    await page.locator('input[name="name"]').fill(keyName);
    await page
      .locator('input[name="description"]')
      .fill("AI generated key for coverage");

    await page.getByRole("button", { name: "Create", exact: true }).click();

    await expect(page.getByText(/Please note down the API key/i)).toBeVisible({
      timeout: 10000,
    });
    await expect(page.getByText(/snd_/i).first()).toBeVisible();

    await page.getByRole("button", { name: "Download the key" }).click();
    await page.keyboard.press("Escape");
    await expect(page.getByText(keyName)).toBeVisible({ timeout: 10000 });
  });

  test("should validate name too long and description too long", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const longName = "X".repeat(100);
    const longDesc = "Y".repeat(300);

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();
    await page.locator('input[name="name"]').fill(longName);
    await page.locator('input[name="description"]').fill("desc");

    await expect(
      page.getByText("Name can't be more than 64 characters", { exact: true }),
    ).toBeVisible();

    await page.locator('input[name="name"]').fill("Valid Name");
    await page.locator('input[name="description"]').fill(longDesc);
    await expect(
      page.getByText("Description can't be more than 256 characters", {
        exact: true,
      }),
    ).toBeVisible();
  });
});

test.describe("Developers - Webhooks", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to Webhooks via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.webhooks.click();

    await expect(page).toHaveURL(/.*dashboard\/webhooks/);
  });

  test("should display Webhooks page heading", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.webhooks.click();

    await expect(page.getByText(/Webhook/i).first()).toBeVisible({
      timeout: 10000,
    });
  });
});

test.describe("Developers - Payment Settings", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to Payment Settings via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentSettings = new PaymentSettings(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();

    await expect(page).toHaveURL(/.*dashboard\/payment-settings/);
    await expect(paymentSettings.pageHeader).toBeVisible({ timeout: 10000 });
  });

  test("should show info cards: profile, merchant, hash key", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentSettings = new PaymentSettings(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();

    await expect(paymentSettings.profileName).toBeVisible();
    await expect(paymentSettings.profileId).toBeVisible();
    await expect(paymentSettings.merchantId).toBeVisible();
    await expect(paymentSettings.paymentResponseHashKey).toBeVisible();
  });

  test("should display all Payment Settings tabs", async ({ page }) => {
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

  test("should switch across Payment Settings tabs", async ({ page }) => {
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

  test("should allow entering Return URL and Webhook URL", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentSettings = new PaymentSettings(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();

    await paymentSettings.fillReturnUrl("https://ai.example.com/return");
    await paymentSettings.fillWebhookUrl("https://ai.example.com/webhook");

    await expect(paymentSettings.returnUrlInput).toHaveValue(
      "https://ai.example.com/return",
    );
    await expect(paymentSettings.webhookUrlInput).toHaveValue(
      "https://ai.example.com/webhook",
    );
  });

  test("should disable Update on empty Payment Link form", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentSettings = new PaymentSettings(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();
    await paymentSettings.paymentLinkTab.click();

    await expect(paymentSettings.updateButton).toBeDisabled();
  });

  test("should accept domain values in Payment Link tab", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentSettings = new PaymentSettings(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();
    await paymentSettings.paymentLinkTab.click();

    await paymentSettings.fillPaymentLinkDomain(
      "https://ai.example.com",
      "ai.example.com",
    );

    await expect(paymentSettings.domainNameInput).toHaveValue(
      "https://ai.example.com",
    );
    await expect(paymentSettings.allowedDomainInput).toHaveValue(
      "ai.example.com",
    );
  });

  test("should enter custom header key/value in Custom Headers tab", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentSettings = new PaymentSettings(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();
    await paymentSettings.customHeadersTab.click();

    await paymentSettings.fillCustomHeader("X-AI-Header", "AIValue");

    await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
      "X-AI-Header",
    );
    await expect(paymentSettings.customHeadersValueInput).toHaveValue(
      "AIValue",
    );
  });

  test("should show Acquirer Config Settings on 3DS tab", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentSettings = new PaymentSettings(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();
    await paymentSettings.threeDSTab.click();

    await expect(paymentSettings.acquirerConfigSettings).toBeVisible();
  });
});
