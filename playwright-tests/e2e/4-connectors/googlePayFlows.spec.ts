import { test, expect } from "../../support/test";
import type { Locator, Page } from "@playwright/test";
import {
  signupUser,
  loginUI,
  fillConnectorFields,
} from "../../support/commands";
import { generateUniqueEmail } from "../../support/helper";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentConnector } from "../../support/pages/connector/PaymentConnector";
import { GooglePayFlow } from "../../support/pages/connector/GooglePayFlow";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

let googlePay: GooglePayFlow;

/**
 * The wallet form sits far down a long connector page, so targets are scrolled
 * into view before being clicked.
 */
async function clickInView(locator: Locator): Promise<void> {
  await locator.scrollIntoViewIfNeeded();
  await locator.click();
}

/**
 * The payment-methods step footer's Proceed button. The Google Pay accordion
 * renders its own Proceed, so the connector-level one must be addressed
 * explicitly rather than through the shared page object.
 */
function stepProceedButton(page: Page): Locator {
  return page.getByRole("button", { name: /Proceed/i }).first();
}

async function selectAllowedAuthMethods(page: Page): Promise<void> {
  // Centre the trigger before opening it: the menu is floating, so scrolling
  // once it is open makes it reposition and never settle for a click.
  await googlePay.allowedAuthMethodsDropdown.evaluate((el: HTMLElement) =>
    el.scrollIntoView({ block: "center" }),
  );
  await page.waitForTimeout(300);
  await googlePay.allowedAuthMethodsDropdown.click();

  await expect(googlePay.authMethodOption("PAN_ONLY")).toBeVisible();
  await googlePay.authMethodOption("PAN_ONLY").click();
  await googlePay.authMethodOption("CRYPTOGRAM_3DS").click();
  await page.keyboard.press("Escape");
}

/**
 * Walks a processor's credentials step and stops on the Google Pay landing
 * screen, where every test in this file begins.
 */
async function openGooglePayLanding(
  page: Page,
  connectorId: string,
): Promise<void> {
  const homePage = new HomePage(page);
  const paymentConnector = new PaymentConnector(page);
  googlePay = new GooglePayFlow(page);

  await homePage.connectors.click();
  await homePage.paymentProcessors.click();
  await page.waitForLoadState("networkidle");

  await paymentConnector.connectorSearchInput.fill(connectorId);
  const connectorCard = page.getByTestId(connectorId);
  await expect(connectorCard).toBeVisible({ timeout: 10000 });
  await connectorCard.locator("button").first().click({ force: true });

  // Wait for the credentials form to render before filling: counting the
  // inputs too early leaves required fields blank and keeps Proceed disabled.
  await expect(
    page.locator('.grid.grid-cols-2 input[type="text"]').first(),
  ).toBeVisible({ timeout: 15000 });
  await fillConnectorFields(page, { default: "test_value" });

  await expect(paymentConnector.connectAndProceedButton).toBeEnabled();
  await paymentConnector.connectAndProceedButton.click();

  await googlePay.googlePayPaymentMethod.click();
  await expect(googlePay.chooseConfigurationMethodHeading).toBeVisible();
}

/** Advances from the landing screen to the Direct / internal gateway step. */
async function openDirectFlowStep(): Promise<void> {
  await clickInView(googlePay.directCard);
  await clickInView(googlePay.continueButton);
  await expect(googlePay.decryptionKeyQuestion).toBeVisible();
}

test.describe("Google Pay configuration flows", () => {
  // Each test walks a full connector setup (signup, credentials, wallet
  // configuration), which does not fit the default per-test budget.
  test.describe.configure({ timeout: 120000 });

  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test.describe("Landing step", () => {
    test("should offer Payment Gateway, Direct and Pre Decrypted Token for Stripe", async ({
      page,
    }) => {
      await openGooglePayLanding(page, "stripe");

      await expect(googlePay.paymentGatewayCard).toBeVisible();
      await expect(googlePay.directCard).toBeVisible();
      await expect(googlePay.preDecryptedTokenCard).toBeVisible();

      await expect(googlePay.paymentGatewayCardDescription).toBeVisible();
      await expect(googlePay.directCardDescription).toBeVisible();
      await expect(googlePay.preDecryptedCardDescription).toBeVisible();
    });

    test("should offer the direct flow for Checkout", async ({ page }) => {
      await openGooglePayLanding(page, "checkout");

      await expect(googlePay.paymentGatewayCard).toBeVisible();
      await expect(googlePay.directCard).toBeVisible();
      await expect(googlePay.directCardDescription).toBeVisible();
    });
  });

  test.describe("Direct flow", () => {
    test.beforeEach(async ({ page }) => {
      await openGooglePayLanding(page, "stripe");
      await openDirectFlowStep();
    });

    // ---------------- Positive cases ----------------

    test("should configure the direct flow with merchant supplied certificates", async ({
      page,
    }) => {
      await expect(googlePay.customCertificatesRadio).toBeVisible();
      await expect(googlePay.managedCertificatesRadio).toBeVisible();
      await expect(googlePay.fieldLabel("Google Pay Public Key")).toBeVisible();
      await expect(
        googlePay.fieldLabel("Google Pay Private Key"),
      ).toBeVisible();
      await expect(googlePay.fieldLabel("Recipient Id")).toBeVisible();

      await googlePay.merchantNameInput.fill("playwright_merchant");
      await googlePay.publicKeyInput.fill("test_public_key");
      await googlePay.privateKeyInput.fill("test_private_key");
      await googlePay.recipientIdInput.fill("test_recipient_id");
      await selectAllowedAuthMethods(page);

      await expect(googlePay.proceedButton).toBeEnabled();
      await clickInView(googlePay.proceedButton);

      await expect(googlePay.googlePayHeading).toBeVisible();
    });

    test("should configure the internal gateway flow with Hyperswitch managed certificates", async ({
      page,
    }) => {
      await clickInView(googlePay.managedCertificatesRadio);

      // Hyperswitch holds the keys, so only the merchant identity is required.
      await expect(googlePay.fieldLabel("Google Pay Public Key")).toBeHidden();
      await expect(googlePay.fieldLabel("Google Pay Private Key")).toBeHidden();
      await expect(googlePay.fieldLabel("Recipient Id")).toBeHidden();
      await expect(googlePay.merchantIdLabel).toBeVisible();
      await expect(googlePay.merchantIdSubText).toBeVisible();

      await googlePay.merchantNameInput.fill("playwright_merchant");
      await selectAllowedAuthMethods(page);

      await expect(googlePay.proceedButton).toBeEnabled();
      await clickInView(googlePay.proceedButton);

      await expect(googlePay.googlePayHeading).toBeVisible();
    });

    test("should persist the internal gateway selection on the created connector", async ({
      page,
    }) => {
      await clickInView(googlePay.managedCertificatesRadio);
      await googlePay.merchantNameInput.fill("playwright_merchant");
      await googlePay.merchantIdInput.fill("playwright_gpay_merchant_id");
      await selectAllowedAuthMethods(page);
      await clickInView(googlePay.proceedButton);
      await expect(googlePay.googlePayHeading).toBeVisible();

      const connectorRequestPromise = page.waitForRequest(
        (request) =>
          request.method() === "POST" && request.url().includes("/connectors"),
      );
      await clickInView(stepProceedButton(page));

      const payload = (await connectorRequestPromise).postDataJSON();
      const merchantInfo =
        payload.connector_wallets_details.google_pay.provider_details
          .merchant_info;

      expect(merchantInfo.tokenization_specification.type).toBe(
        "INTERNAL_GATEWAY",
      );
      expect(merchantInfo.merchant_name).toBe("playwright_merchant");
      expect(merchantInfo.merchant_id).toBe("playwright_gpay_merchant_id");
      // Managed certificates means no key material is sent to the backend.
      expect(
        merchantInfo.tokenization_specification.parameters.public_key,
      ).toBeUndefined();
      expect(
        merchantInfo.tokenization_specification.parameters.private_key,
      ).toBeUndefined();
      expect(
        merchantInfo.tokenization_specification.parameters.recipient_id,
      ).toBeUndefined();
    });

    // ---------------- Negative cases ----------------

    test("should keep Proceed disabled until every direct flow credential is filled", async ({
      page,
    }) => {
      await expect(googlePay.proceedButton).toBeDisabled();

      await googlePay.merchantNameInput.fill("playwright_merchant");
      await googlePay.publicKeyInput.fill("test_public_key");
      await googlePay.privateKeyInput.fill("test_private_key");
      await selectAllowedAuthMethods(page);

      // Recipient Id is still missing.
      await expect(googlePay.proceedButton).toBeDisabled();

      await googlePay.recipientIdInput.fill("test_recipient_id");
      await expect(googlePay.proceedButton).toBeEnabled();
    });

    test("should reject whitespace-only values in the direct flow", async ({
      page,
    }) => {
      await googlePay.merchantNameInput.fill("   ");
      await googlePay.publicKeyInput.fill("   ");
      await googlePay.privateKeyInput.fill("   ");
      await googlePay.recipientIdInput.fill("   ");
      await selectAllowedAuthMethods(page);

      await expect(googlePay.proceedButton).toBeDisabled();
    });

    test("should keep Proceed disabled in the internal gateway flow without auth methods", async ({
      page,
    }) => {
      await clickInView(googlePay.managedCertificatesRadio);
      await googlePay.merchantNameInput.fill("playwright_merchant");

      // Merchant name alone is not enough; auth methods are mandatory.
      await expect(googlePay.proceedButton).toBeDisabled();

      await selectAllowedAuthMethods(page);
      await expect(googlePay.proceedButton).toBeEnabled();
    });

    // ---------------- Edge cases ----------------

    test("should swap the required fields when toggling between key handling modes", async () => {
      await expect(googlePay.publicKeyInput).toBeVisible();
      await expect(googlePay.merchantIdLabel).toBeHidden();

      await clickInView(googlePay.managedCertificatesRadio);
      await expect(googlePay.publicKeyInput).toBeHidden();
      await expect(googlePay.merchantIdLabel).toBeVisible();

      // Switching back must restore the certificate fields.
      await clickInView(googlePay.customCertificatesRadio);
      await expect(googlePay.publicKeyInput).toBeVisible();
      await expect(googlePay.privateKeyInput).toBeVisible();
      await expect(googlePay.recipientIdInput).toBeVisible();
      await expect(googlePay.merchantIdLabel).toBeHidden();
    });

    test("should treat the Google Pay Merchant ID as optional in the internal gateway flow", async ({
      page,
    }) => {
      await clickInView(googlePay.managedCertificatesRadio);

      // The label carries no asterisk and the sub text explains the fallback.
      await expect(googlePay.merchantIdSubText).toBeVisible();

      await googlePay.merchantNameInput.fill("playwright_merchant");
      await selectAllowedAuthMethods(page);

      await expect(googlePay.proceedButton).toBeEnabled();
      await clickInView(googlePay.proceedButton);

      const connectorRequestPromise = page.waitForRequest(
        (request) =>
          request.method() === "POST" && request.url().includes("/connectors"),
      );
      await clickInView(stepProceedButton(page));

      const payload = (await connectorRequestPromise).postDataJSON();
      const merchantInfo =
        payload.connector_wallets_details.google_pay.provider_details
          .merchant_info;

      expect(merchantInfo.tokenization_specification.type).toBe(
        "INTERNAL_GATEWAY",
      );
      expect(merchantInfo.merchant_id ?? "").toBe("");
    });

    test("should discard the Google Pay configuration when Cancel is clicked", async () => {
      await googlePay.merchantNameInput.fill("playwright_merchant");
      await clickInView(googlePay.cancelButton);

      // The wallet section collapses back without applying the configuration.
      await expect(googlePay.decryptionKeyQuestion).toBeHidden();
    });
  });
});
