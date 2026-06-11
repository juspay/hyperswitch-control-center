import { test, expect, type Page } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  mockV2MerchantList,
  createDummyConnectorAPI,
  createPayoutConnectorAPI,
  createAuthenticationConnectorAPI,
} from "../support/commands";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentConnector } from "../support/pages/connector/PaymentConnector";
import { PayoutConnector } from "../support/pages/connector/PayoutConnector";
import { ThreeDSAuthenticator } from "../support/pages/connector/ThreeDSAuthenticator";
import { PmAuthProcessor } from "../support/pages/connector/PmAuthProcessor";
import { TaxProcessor } from "../support/pages/connector/TaxProcessor";
import { BillingProcessor } from "../support/pages/connector/BillingProcessor";
import { VaultProcessor } from "../support/pages/connector/VaultProcessor";

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

    test("payment processors list when connector configured should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
      }

      await homePage.connectors.click();
      await homePage.paymentProcessors.click();
      await page.waitForLoadState("networkidle");

      await expect(page.getByText("stripe_test_1").first()).toBeVisible({
        timeout: 10000,
      });

      await expect(page).toHaveScreenshot(
        "connectors-payment-processors-with-connector.png",
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

    test("payout processors list when connector configured should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createPayoutConnectorAPI(
          merchantId,
          "adyen_test_1",
          context.request,
        );
      }

      await homePage.connectors.click();
      await homePage.payoutConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(page.getByText("adyen_test_1").first()).toBeVisible({
        timeout: 10000,
      });

      await expect(page).toHaveScreenshot(
        "connectors-payout-processors-with-connector.png",
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

    test("3ds authenticators list when connector configured should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createAuthenticationConnectorAPI(
          merchantId,
          "juspaythreedsserver_1",
          context.request,
        );
      }

      await homePage.connectors.click();
      await homePage.threeDSConnectors.click();
      await page.waitForLoadState("networkidle");

      await expect(
        page.getByText("juspaythreedsserver_1").first(),
      ).toBeVisible({ timeout: 10000 });

      await expect(page).toHaveScreenshot(
        "connectors-3ds-authenticators-with-connector.png",
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

      await expect(page).toHaveScreenshot("connectors-tax-processor-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
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
  });
});
