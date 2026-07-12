import { test, expect, type Page } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  mockV2MerchantList,
  createDummyConnectorAPI,
  createPayoutConnectorAPI,
  createAuthenticationConnectorAPI,
  assertConnectorFieldLabels,
  fillConnectorFields,
  assertPaymentMethodTypes,
} from "../support/commands";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentConnector } from "../support/pages/connector/PaymentConnector";
import { PayoutConnector } from "../support/pages/connector/PayoutConnector";
import { ThreeDSAuthenticator } from "../support/pages/connector/ThreeDSAuthenticator";
import { FrmConnector } from "../support/pages/connector/FrmConnector";
import { PmAuthProcessor } from "../support/pages/connector/PmAuthProcessor";
import { TaxProcessor } from "../support/pages/connector/TaxProcessor";
import { BillingProcessor } from "../support/pages/connector/BillingProcessor";
import { VaultProcessor } from "../support/pages/connector/VaultProcessor";
import { SurchargeProcessor } from "../support/pages/connector/SurchargeProcessor";
import { payoutConnectorConfig } from "../support/fixtures/payoutConnectorConfig";
import { frmConnectorConfig } from "../support/fixtures/frmConnectorConfig";
import { pmAuthProcessorConfig } from "../support/fixtures/pmAuthProcessorConfig";
import { taxProcessorConfig } from "../support/fixtures/taxProcessorConfig";
import { billingProcessorConfig } from "../support/fixtures/billingProcessorConfig";
import { vaultProcessorConfig } from "../support/fixtures/vaultProcessorConfig";
import { surchargeProcessorConfig } from "../support/fixtures/surchargeProcessorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// Tax / Billing / Vault / PM Auth sidebar entries are gated behind feature
// flags. Intercept the config fetch BEFORE loginUI's page.goto so the flags
// are on from app boot and the sidebar links + processor grids render.
async function enableFeatureFlags(page: Page, flags: string[]): Promise<void> {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    if (json.features) {
      for (const flag of flags) {
        json.features[flag] = true;
      }
    }
    await route.fulfill({ response, json });
  });
}

test.describe("Visual Testing - Connectors", () => {
  test.describe("Payment Processors", () => {
    test("payment processors landing when no connector configured should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const paymentConnector = new PaymentConnector(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.paymentProcessors.click();
      await page.waitForLoadState("networkidle");

      await expect(page.getByText("Payment Processors").first()).toBeVisible({
        timeout: 10000,
      });
      await expect(paymentConnector.pageBanner).toContainText(
        "Connect a Dummy Processor",
      );

      await expect(page).toHaveScreenshot(
        "connectors-payment-processors-empty.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("payment processor setup flow should match visual snapshot at each section", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const paymentConnector = new PaymentConnector(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.paymentProcessors.click();
      await page.waitForLoadState("networkidle");

      await expect(paymentConnector.pageBanner).toContainText(
        "Connect a Dummy Processor",
      );

      // Section 1 — processor selection grid (after Connect Now).
      await paymentConnector.connectNowButton.click({ force: true });
      await expect(paymentConnector.stripeDummyConnector).toBeVisible();
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-payment-processor-select.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      // Section 2 — credentials form (API key pre-filled for the dummy processor).
      await paymentConnector.stripeDummyConnector
        .locator("button")
        .click({ force: true });
      await expect(paymentConnector.apiKeyInput).toHaveValue("test_key");
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-payment-processor-credentials.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      // Section 3 — payment methods configuration (after Connect & Proceed).
      await paymentConnector.connectAndProceedButton.click();
      await expect(paymentConnector.pmtProceedButton).toBeVisible();
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-payment-processor-payment-methods.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      // Section 4 — connector created and listed.
      await paymentConnector.pmtProceedButton.click();
      await expect(paymentConnector.connectorCreatedToast).toBeVisible();
      await expect(page).toHaveScreenshot(
        "connectors-payment-processor-created-details.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      await paymentConnector.connectorSetupDone.click();

      await expect(page).toHaveURL(/.*dashboard\/connectors/);
      await expect(page.getByText("stripe_test_default")).toBeVisible();
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-payment-processor-created.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });
  });

  test.describe("Payout Processors", () => {
    test("payout processors landing when no connector configured should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const payoutConnector = new PayoutConnector(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.payoutConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(payoutConnector.pageHeading).toContainText(
        "Payout Processors",
      );

      await expect(page).toHaveScreenshot(
        "connectors-payout-processors-empty.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("payout processor setup flow should match visual snapshot at each section", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const payoutConnector = new PayoutConnector(page);
      const connector = payoutConnectorConfig.stripe;

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.payoutConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(payoutConnector.pageHeading).toContainText(
        "Payout Processors",
      );

      // Section 1 — credentials form for the selected processor.
      await payoutConnector.connectorSearchInput.fill(connector.label);
      await payoutConnector.addConnectButton.nth(0).click();
      await assertConnectorFieldLabels(page, connector.fields.fieldLabels);
      await fillConnectorFields(page, connector.fields);
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-payout-processor-credentials.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      // Section 2 — payment methods configuration.
      await payoutConnector.connectAndProceedButton.click();
      await assertPaymentMethodTypes(page, connector.paymentSections);
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-payout-processor-payment-methods.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      // Section 3 — connector created and listed.
      await payoutConnector.pmtProceedButton.click();
      await expect(page).toHaveScreenshot(
        "connectors-payout-processor-created-details.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.02,
        },
      );
      await payoutConnector.connectorSetupDone.click();

      await expect(page).toHaveURL(/.*dashboard\/payoutconnectors/);
      await expect(
        page
          .getByText(connector.fields.overrides["Enter Connector label"])
          .first(),
      ).toBeVisible({ timeout: 10000 });
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-payout-processor-created.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });
  });

  test.describe("3DS Authenticators", () => {
    test("3ds authenticators landing when no connector configured should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const threeDSAuthenticator = new ThreeDSAuthenticator(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.threeDSConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(page.getByText(/3DS Authenticator/i).first()).toBeVisible({
        timeout: 10000,
      });
      await expect(threeDSAuthenticator.authenticatorSearchInput).toBeVisible();

      await expect(page).toHaveScreenshot(
        "connectors-3ds-authenticators-empty.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("3ds authenticator setup flow should match visual snapshot at each section", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const threeDSAuthenticator = new ThreeDSAuthenticator(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.threeDSConnectors.click();
      await page.waitForLoadState("networkidle");

      // Section 1 — credentials form for the Juspay 3DS Server authenticator.
      await threeDSAuthenticator.authenticatorSearchInput.fill("juspay");
      await threeDSAuthenticator.connectButton.nth(0).click();

      await page
        .getByRole("textbox", { name: "Enter Merchant Country Code" })
        .fill("test_value");
      await page
        .getByRole("textbox", { name: "Enter Merchant Name" })
        .fill("test_value");
      await page
        .getByRole("textbox", { name: "Enter ThreeDS requestor name" })
        .fill("test_value");
      await page
        .getByRole("textbox", { name: "Enter ThreeDS request id" })
        .fill("test_value");
      await page
        .getByRole("textbox", { name: "Enter Merchant Category Code" })
        .fill("test_value");
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-3ds-authenticator-credentials.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      // Section 2 — connector created and listed.
      await threeDSAuthenticator.connectAndProceedButton.click();
      await expect(page).toHaveScreenshot(
        "connectors-3ds-authenticator-created-details.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
      await threeDSAuthenticator.setupDoneButton.click();

      await expect(
        page.getByText("juspaythreedsserver_default", { exact: true }),
      ).toBeVisible({ timeout: 10000 });
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-3ds-authenticator-created.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });
  });

  test.describe("Fraud & Risk", () => {
    test("fraud & risk landing when no connector configured should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.frmConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(
        page.getByText("Fraud & Risk Management").first(),
      ).toBeVisible({ timeout: 10000 });

      await expect(page).toHaveScreenshot("connectors-fraud-risk-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("fraud & risk setup flow should match visual snapshot at each section", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const frmConnector = new FrmConnector(page);
      const connector = frmConnectorConfig.signifyd;

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        // Use API helpers to set up connector and payment without UI login flow
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
      }

      await homePage.connectors.click();
      await homePage.frmConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveURL(/.*dashboard\/fraud-risk-management/);

      await expect(frmConnector.connectButton.nth(1)).toBeVisible();
      await expect(page).toHaveScreenshot("connectors-fraud-risk-list.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });

      // Section 1 — configuration form for the selected FRM connector.
      await frmConnector.connectButton.nth(1).click();
      if (connector.fields.fieldLabels.length > 0) {
        await assertConnectorFieldLabels(page, connector.fields.fieldLabels);
        await fillConnectorFields(page, connector.fields);
      }
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot("connectors-fraud-risk-config.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });

      // Section 2 — connector saved.
      await frmConnector.saveOrConnectOrProceedButton.click();
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-fraud-risk-config-2.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      await page
        .getByRole("textbox", { name: "Enter API Key" })
        .fill("test_key");
      await page.getByRole("button", { name: "Connect and Finish" }).click();
      await expect(page.getByText("Connector Created Successfully")).toBeVisible({
        timeout: 10000,
      });

      await expect(page).toHaveScreenshot("connectors-fraud-risk-created.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });
  });

  test.describe("PM Auth Processor", () => {
    test("pm auth processor landing should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      await enableFeatureFlags(page, ["pm_authentication_processor"]);

      const homePage = new HomePage(page);
      const pmAuthProcessor = new PmAuthProcessor(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.pmAuthConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(pmAuthProcessor.connectButton.first()).toBeVisible({
        timeout: 10000,
      });

      await expect(page).toHaveScreenshot("connectors-pm-auth-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("pm auth processor setup flow should match visual snapshot at each section", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      await enableFeatureFlags(page, ["pm_authentication_processor"]);

      const homePage = new HomePage(page);
      const pmAuthProcessor = new PmAuthProcessor(page);
      const processor = pmAuthProcessorConfig.plaid;

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.pmAuthConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveURL(/.*dashboard\/pm-authentication-processor/);

      // Section 1 — credentials form for the selected processor.
      await pmAuthProcessor.connectButton.first().click();
      await fillConnectorFields(page, processor.fields);
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-pm-auth-credentials.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      // Section 2 — connector created and listed.
      await pmAuthProcessor.saveOrConnectOrProceedButton.click();
      await page.waitForLoadState("networkidle");
      await expect(page).toHaveScreenshot(
        "connectors-pm-auth-created-details.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      await pmAuthProcessor.doneButton.click();

      await expect(
        page.getByText(processor.fields.overrides["Enter Connector label"], {
          exact: true,
        }),
      ).toBeVisible({ timeout: 10000 });
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot("connectors-pm-auth-created.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });
  });

  test.describe("Tax Processor", () => {
    test("tax processor landing should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      await enableFeatureFlags(page, ["tax_processor"]);

      const homePage = new HomePage(page);
      const taxProcessor = new TaxProcessor(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.taxConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(taxProcessor.connectButton.first()).toBeVisible({
        timeout: 10000,
      });

      await expect(page).toHaveScreenshot(
        "connectors-tax-processor-empty.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("tax processor setup flow should match visual snapshot at each section", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      await enableFeatureFlags(page, ["tax_processor"]);

      const homePage = new HomePage(page);
      const taxProcessor = new TaxProcessor(page);
      const processor = taxProcessorConfig.taxjar;

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.taxConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveURL(/.*dashboard\/tax-processor/);

      // Section 1 — credentials form for the selected processor.
      await taxProcessor.connectButton.first().click();
      await fillConnectorFields(page, processor.fields);
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-tax-processor-credentials.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      // Section 2 — connector created and listed.
      await taxProcessor.saveOrConnectOrProceedButton.click();
      await page.waitForLoadState("networkidle");
      await expect(page).toHaveScreenshot(
        "connectors-tax-processor-created-details.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      await taxProcessor.doneButton.click();

      await expect(
        page.getByText(processor.fields.overrides["Enter Connector label"], {
          exact: true,
        }),
      ).toBeVisible({ timeout: 10000 });
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-tax-processor-created.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });
  });

  test.describe("Billing Processor", () => {
    test("billing processor landing should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      await enableFeatureFlags(page, ["billing_processor"]);

      const homePage = new HomePage(page);
      const billingProcessor = new BillingProcessor(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.billingConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(billingProcessor.connectButton.first()).toBeVisible({
        timeout: 10000,
      });

      await expect(page).toHaveScreenshot(
        "connectors-billing-processor-empty.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("billing processor setup flow should match visual snapshot at each section", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      await enableFeatureFlags(page, ["billing_processor"]);

      const homePage = new HomePage(page);
      const billingProcessor = new BillingProcessor(page);
      const processor = billingProcessorConfig.chargebee;

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.billingConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveURL(/.*dashboard\/billing-processor/);

      // Section 1 — credentials form for the selected processor.
      await billingProcessor.connectButton.first().click();
      await fillConnectorFields(page, processor.fields);
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-billing-processor-credentials.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      // Section 2 — connector created and listed.
      await billingProcessor.saveOrConnectOrProceedButton.click();
      await page.waitForLoadState("networkidle");
      await expect(page).toHaveScreenshot(
        "connectors-billing-processor-created-details.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
      await billingProcessor.doneButton.click();

      await expect(
        page.getByText(processor.fields.overrides["Enter Connector label"], {
          exact: true,
        }),
      ).toBeVisible({ timeout: 10000 });
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-billing-processor-created.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });
  });

  test.describe("Vault Processor", () => {
    test("vault processor landing should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      await enableFeatureFlags(page, ["vault", "vault_processor"]);

      const homePage = new HomePage(page);
      const vaultProcessor = new VaultProcessor(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.vaultConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(vaultProcessor.connectButton.first()).toBeVisible({
        timeout: 10000,
      });

      await expect(page).toHaveScreenshot(
        "connectors-vault-processor-empty.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("vault processor setup flow should match visual snapshot at each section", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      await enableFeatureFlags(page, ["vault", "vault_processor"]);

      const homePage = new HomePage(page);
      const vaultProcessor = new VaultProcessor(page);
      const processor = vaultProcessorConfig.vgs;

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.vaultConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveURL(/.*dashboard\/vault-processor/);

      // Section 1 — credentials form for the selected processor.
      await vaultProcessor.connectButton.first().click();
      await fillConnectorFields(page, processor.fields);
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-vault-processor-credentials.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      // Section 2 — connector created and listed.
      await vaultProcessor.saveOrConnectOrProceedButton.click();
      await page.waitForLoadState("networkidle");
      await expect(page).toHaveScreenshot(
        "connectors-vault-processor-created-details.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
      await vaultProcessor.doneButton.click();

      await expect(
        page.getByText(processor.fields.overrides["Enter Connector label"], {
          exact: true,
        }),
      ).toBeVisible({ timeout: 10000 });
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-vault-processor-created.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });
  });

  test.describe("Surcharge Processor", () => {
    test("surcharge processor landing should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      await enableFeatureFlags(page, ["surcharge_processor"]);

      const homePage = new HomePage(page);
      const surchargeProcessor = new SurchargeProcessor(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.surchargeConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(surchargeProcessor.connectButton.first()).toBeVisible({
        timeout: 10000,
      });

      await expect(page).toHaveScreenshot(
        "connectors-surcharge-processor-empty.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("surcharge processor setup flow should match visual snapshot at each section", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      await enableFeatureFlags(page, ["surcharge_processor"]);

      const homePage = new HomePage(page);
      const surchargeProcessor = new SurchargeProcessor(page);
      const processor = surchargeProcessorConfig.interpayments;

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.connectors.click();
      await homePage.surchargeConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveURL(/.*dashboard\/surcharge-processor/);

      // Section 1 — credentials form for the selected processor.
      await surchargeProcessor.connectButton.first().click();
      await fillConnectorFields(page, processor.fields);
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-surcharge-processor-credentials.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      // Section 2 — connector created and listed.
      await surchargeProcessor.connectAndProceedButton.click();
      await page.waitForLoadState("networkidle");
      await expect(page).toHaveScreenshot(
        "connectors-surcharge-processor-created-details.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );

      await surchargeProcessor.doneButton.click();

      await expect(
        page.getByText(processor.fields.overrides["Enter Connector label"], {
          exact: true,
        }),
      ).toBeVisible({ timeout: 10000 });
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot(
        "connectors-surcharge-processor-created.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });
  });
});
