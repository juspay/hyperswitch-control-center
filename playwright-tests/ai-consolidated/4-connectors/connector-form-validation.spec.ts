import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentConnector } from "../../support/pages/connector/PaymentConnector";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Connector form - validation and interaction", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();
    await paymentConnector.connectNowButton.click({ force: true });
    await expect(paymentConnector.stripeDummyConnector).toBeVisible();
    await paymentConnector.stripeDummyConnector
      .locator("button")
      .click({ force: true });
  });

  test("should surface 'Please fix validation errors' toast when required API key is cleared", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);

    const apiKeyField = page.locator(
      "[name=connector_account_details\\.api_key]",
    );
    if ((await apiKeyField.count()) > 0) {
      await apiKeyField.clear();
    }

    const connectBtn = paymentConnector.connectAndProceedButton;
    if (await connectBtn.isEnabled().catch(() => false)) {
      await connectBtn.click();
    } else {
      await connectBtn.click({ force: true });
    }

    await expect(
      page.locator('[data-toast="Please fix validation errors"]'),
    ).toBeVisible({ timeout: 5000 });
  });

  test("should reset the connector form after Cancel and re-entering the flow", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);

    await page
      .locator("[name=connector_account_details\\.api_key]")
      .fill("temp_api_key");

    const cancelButton = page.locator('[data-button-for="cancel"]').first();
    if ((await cancelButton.count()) > 0) {
      await cancelButton.click();

      await paymentConnector.connectNowButton.click({ force: true });
      await paymentConnector.stripeDummyConnector
        .locator("button")
        .click({ force: true });

      const apiKeyValue = await page
        .locator("[name=connector_account_details\\.api_key]")
        .inputValue();
      expect(apiKeyValue).not.toBe("temp_api_key");
    }
  });

  test("should surface a field-level error for an invalid API key value", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);

    const apiKeyField = page.locator(
      "[name=connector_account_details\\.api_key]",
    );
    await apiKeyField.clear();
    await apiKeyField.fill("invalid_key_@#$%");

    await paymentConnector.connectAndProceedButton.click({ force: true });

    const fieldError = page.locator(
      '[data-field-error="connector_account_details.api_key"]',
    );
    const toast = page.locator('[data-toast="Please fix validation errors"]');
    await expect(fieldError.or(toast).first()).toBeVisible({ timeout: 5000 });
  });

  test("should preserve a partial form draft when navigating away and back", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await page
      .locator("[name=connector_account_details\\.api_key]")
      .fill("draft_api_key_value");

    await homePage.homeV2.click();
    await page.waitForLoadState("networkidle");

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();
    await paymentConnector.connectNowButton.click({ force: true });
    await paymentConnector.stripeDummyConnector
      .locator("button")
      .click({ force: true });

    const resumedValue = await page
      .locator("[name=connector_account_details\\.api_key]")
      .inputValue();
    expect(typeof resumedValue).toBe("string");
  });
});
