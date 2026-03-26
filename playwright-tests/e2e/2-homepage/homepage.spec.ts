import { test, expect } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUser,
  loginUI,
  createDummyConnector,
  createAPIKey,
  createPayment,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Homepage", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    await page.route("**/dashboard/config/feature?domain=", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.global_search = true;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should verify all components on homepage", async ({ page }) => {
    const homePage = new HomePage(page);

    await expect(
      page.getByText(
        "Welcome to the home of your Payments Control Centre. It aims at providing your team with a 360-degree view of payments.",
      ),
    ).toBeVisible();

    await expect(homePage.orgIcon).toBeVisible();
    await expect(homePage.merchantDropdown).toBeVisible();
    await expect(homePage.profileDropdown).toBeVisible();
    await expect(homePage.orgChartIcon).toBeVisible();
    await expect(homePage.globalSearchInput).toBeVisible();

    await expect(homePage.productionAccessBanner).toBeVisible();
    await expect(homePage.productionAccessBanner).toContainText(
      "You're in Test ModeGet Production Access",
    );

    await expect(homePage.integrateConnectorCard).toBeVisible();
    await expect(homePage.integrateConnectorCard).toContainText(
      "Integrate a ProcessorGive a headstart by connecting with more than 20+ gateways, payment methods, and networks.",
    );
    await expect(
      homePage.integrateConnectorCard.locator(
        '[data-button-for="connectProcessors"]',
      ),
    ).toBeVisible();

    await expect(homePage.demoCheckoutCard).toBeVisible();
    await expect(homePage.demoCheckoutCard).toContainText(
      "Demo our checkout experienceTest your payment connector by initiating a transaction and visualize the user checkout experience",
    );
    await expect(
      homePage.demoCheckoutCard.locator('[data-button-for="tryItOut"]'),
    ).toBeVisible();
  });

  test("should navigate to connector list and API keys page", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await page.locator('[data-button-for="connectProcessors"]').click();
    await expect(page).toHaveURL(/.*connectors/);

    await page.locator('[data-testid="overview"]').click();

    await page.locator('[data-button-text="Go to API keys"]').click();
    await expect(page).toHaveURL(/.*developer-api-keys/);
  });

  test("should make a payment using SDK", async ({ page, context }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      const { token } = await loginUser(
        await generateUniqueEmail(),
        PLAYWRIGHT_PASSWORD,
        context.request,
      );
      await createDummyConnector(merchantId, token, "stripe_test_1");
    }

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();
    await expect(page.getByText("Payment Processors")).toBeVisible();

    await page.locator('[data-testid="overview"]').first().click();
    await page.locator('[data-button-for="tryItOut"]').click();

    await expect(
      page.locator('[class="text-fs-28 font-semibold leading-10 "]'),
    ).toContainText("Setup Checkout");

    await page.locator('[data-button-for="showPreview"]').click();
    await page.waitForTimeout(2000);

    const iframe = page.frameLocator("iframe").first();
    await iframe
      .locator("[data-testid=cardNoInput]")
      .waitFor({ state: "visible", timeout: 20000 });
    await iframe.locator("[data-testid=cardNoInput]").fill("4242424242424242");
    await iframe.locator("[data-testid=expiryInput]").fill("0127");
    await iframe.locator("[data-testid=cvvInput]").fill("492");

    await page.locator('[data-button-for="payUSD100"]').click();
    await expect(page.getByText("Payment Successful")).toBeAttached();
  });

  test("should verify sidebar menu navigation for orchestrator", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await expect(homePage.homeV2).toBeVisible();
    await homePage.homeV2.click();
    await expect(page).toHaveURL(/.*dashboard\/v2\/home/);

    await expect(homePage.users).toBeVisible();
    await homePage.users.click();
    await expect(page).toHaveURL(/.*dashboard\/users/);

    await expect(page.getByText("MY MODULES")).toBeVisible();

    await page.locator('[data-testid="overview"]').click();
    await expect(page).toHaveURL(/.*dashboard\/home/);

    await expect(homePage.operations).toBeVisible();
    await homePage.operations.click();
    await expect(homePage.paymentOperations).toBeVisible();
    await homePage.paymentOperations.click();
    await expect(page).toHaveURL(/.*dashboard\/payments/);

    await expect(homePage.refundOperations).toBeVisible();
    await homePage.refundOperations.click();
    await expect(page).toHaveURL(/.*dashboard\/refunds/);

    await expect(homePage.disputesOperations).toBeVisible();
    await homePage.disputesOperations.click();
    await expect(page).toHaveURL(/.*dashboard\/disputes/);

    await expect(homePage.payoutsOperations).toBeVisible();
    await homePage.payoutsOperations.click();
    await expect(page).toHaveURL(/.*dashboard\/payouts/);

    await expect(homePage.customers).toBeVisible();
    await homePage.customers.click();
    await expect(page).toHaveURL(/.*dashboard\/customers/);

    await expect(homePage.connectors).toBeVisible();
    await homePage.connectors.click();
    await expect(homePage.paymentProcessors).toBeVisible();
    await homePage.paymentProcessors.click();
    await expect(page).toHaveURL(/.*dashboard\/connectors/);

    await expect(homePage.payoutConnectors).toBeVisible();
    await homePage.payoutConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/payoutconnectors/);

    await expect(homePage.threeDSConnectors).toBeVisible();
    await homePage.threeDSConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/3ds-authenticators/);

    await expect(homePage.frmConnectors).toBeVisible();
    await homePage.frmConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/fraud-risk-management/);

    await expect(homePage.pmAuthConnectors).toBeVisible();
    await homePage.pmAuthConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/pm-authentication-processor/);

    await expect(homePage.taxConnectors).toBeVisible();
    await homePage.taxConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/tax-processor/);

    await expect(homePage.billingConnectors).toBeVisible();
    await homePage.billingConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/billing-processor/);

    await expect(homePage.vaultConnectors).toBeVisible();
    await homePage.vaultConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/vault-processor/);

    await expect(homePage.analytics).toBeVisible();
    await homePage.analytics.click();
    await expect(homePage.paymentsAnalytics).toBeVisible();
    await homePage.paymentsAnalytics.click();
    await expect(page).toHaveURL(/.*dashboard\/analytics-payments/);

    await expect(homePage.refundAnalytics).toBeVisible();
    await homePage.refundAnalytics.click();
    await expect(page).toHaveURL(/.*dashboard\/analytics-refunds/);

    await expect(homePage.workflow).toBeVisible();
    await homePage.workflow.click();
    await expect(homePage.routing).toBeVisible();
    await homePage.routing.click();
    await expect(page).toHaveURL(/.*dashboard\/routing/);

    await expect(homePage.surchargeRouting).toBeVisible();
    await homePage.surchargeRouting.click();
    await expect(page).toHaveURL(/.*dashboard\/surcharge/);

    await expect(homePage.threeDSRouting).toBeVisible();
    await homePage.threeDSRouting.click();
    await expect(page).toHaveURL(/.*dashboard\/3ds/);

    await expect(homePage.payoutRouting).toBeVisible();
    await homePage.payoutRouting.click();
    await expect(page).toHaveURL(/.*dashboard\/payoutrouting/);

    await expect(homePage.threeDSExemptionManager).toBeVisible();
    await homePage.threeDSExemptionManager.click();
    await expect(page).toHaveURL(/.*dashboard\/3ds-exemption/);

    await expect(homePage.vault).toBeVisible();
    await homePage.vault.click();
    await expect(homePage.vaultConfiguration).toBeVisible();
    await homePage.vaultConfiguration.click();
    await expect(page).toHaveURL(/.*dashboard\/vault-onboarding/);

    await expect(homePage.vaultCustomersAndTokens).toBeVisible();
    await homePage.vaultCustomersAndTokens.click();
    await expect(page).toHaveURL(/.*dashboard\/vault-customers-tokens/);

    await expect(homePage.developer).toBeVisible();
    await homePage.developer.click();
    await expect(homePage.paymentSettings).toBeVisible();
    await homePage.paymentSettings.click();
    await expect(page).toHaveURL(/.*dashboard\/payment-settings/);

    await expect(homePage.apiKeys).toBeVisible();
    await homePage.apiKeys.click();
    await expect(page).toHaveURL(/.*dashboard\/developer-api-keys/);

    await expect(homePage.webhooks).toBeVisible();
    await homePage.webhooks.click();
    await expect(page).toHaveURL(/.*dashboard\/webhooks/);

    await expect(homePage.settings).toBeVisible();
    await homePage.settings.click();
    await expect(homePage.configurePMT).toBeVisible();
    await homePage.configurePMT.click();
    await expect(page).toHaveURL(/.*dashboard\/configure-pmts/);

    await expect(homePage.organizationSettings).toBeVisible();
    await homePage.organizationSettings.click();
    await expect(page).toHaveURL(/.*dashboard\/organization-settings/);
  });
});
