import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
let email = "";

test.describe("Homepage", () => {
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
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

  test("should render a Visit button for developer resources that is enabled", async ({
    page,
  }) => {
    const visit = page.getByRole("button", { name: "Visit" }).first();
    await expect(visit).toBeVisible();
    await expect(visit).toBeEnabled();
  });

  test("should make a payment using SDK", async ({ page, context }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );

      await homePage.connectors.click();
      await homePage.paymentProcessors.click();
      await expect(page.getByText("Payment Processors").nth(1)).toBeVisible();

      await page.locator('[data-testid="overview"]').first().click();
      await page.locator('[data-button-for="tryItOut"]').click();

      await expect(
        page.locator(
          '[class="text-fs-24 leading-32 font-semibold font-inter-style "]',
        ),
      ).toContainText("Setup Checkout");

      await page.locator('[data-button-for="showPreview"]').click();
      await page.waitForTimeout(2000);

      const iframe = page.frameLocator("iframe").first();
      await iframe
        .locator("[data-testid=cardNoInput]")
        .waitFor({ state: "visible", timeout: 20000 });
      await iframe
        .locator("[data-testid=cardNoInput]")
        .fill("4242424242424242");
      await iframe.locator("[data-testid=expiryInput]").fill("0127");
      await iframe.locator("[data-testid=cvvInput]").fill("492");

      await page.locator('[data-button-for="payUSD100"]').click();
      await expect(page.getByText("Payment Successful")).toBeAttached();
    }
  });

  test("should verify sidebar menu navigation - overview and operations", async ({
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
  });

  test("should verify sidebar menu navigation - connectors", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

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
  });

  test("should verify sidebar menu navigation - analytics and workflow", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

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
  });

  test("should verify sidebar menu navigation - vault, developer and settings", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await expect(homePage.vault).toBeVisible();
    await homePage.vault.click();
    await expect(homePage.vaultConfiguration).toBeVisible();
    await homePage.vaultConfiguration.click();
    await expect(page).toHaveURL(/.*dashboard\/vault-onboarding/);

    await expect(homePage.vaultCustomersAndTokens).toBeVisible();
    await homePage.vaultCustomersAndTokens.click();
    await expect(page).toHaveURL(/.*dashboard\/vault-customers-tokens/);
    await page.waitForLoadState("networkidle");

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
    await page.waitForLoadState("networkidle");
  });
});

test.describe("DefaultHome product cards", () => {
  const setProductFlags = async (
    page: import("@playwright/test").Page,
    flags: {
      dev_vault_v2_product: boolean;
      dev_recon_v2_product: boolean;
      dev_recovery_v2_product: boolean;
      dev_hypersense_v2_product: boolean;
    },
  ) => {
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        Object.assign(json.features, flags);
      }
      await route.fulfill({ response, json });
    });
  };

  test("should display Orchestrator and all gated product cards when product flags are ON", async ({
    page,
    context,
  }) => {
    const adminEmail = generateUniqueEmail();
    await signupUser(adminEmail, PLAYWRIGHT_PASSWORD, context.request);

    await setProductFlags(page, {
      dev_vault_v2_product: true,
      dev_recon_v2_product: true,
      dev_recovery_v2_product: true,
      dev_hypersense_v2_product: true,
    });

    await loginUI(page, adminEmail, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    await homePage.homeV2.click();
    await expect(page).toHaveURL(/.*dashboard\/v2\/home/);

    await expect(page.getByText("Explore composable services")).toBeVisible();

    await expect(page.locator('span').filter({ hasText: 'Orchestrator' })).toBeVisible();
    await expect(page.getByText('Unified the diverse abstractions to connect with payment processors, payout processors, fraud management solutions, tax automation solutions, identity solutions and reporting systems')).toBeVisible();
    await expect(page.locator('span').filter({ hasText: /^Vault$/ })).toBeVisible();
    await expect(page.getByText('A standalone, PCI-compliant vault that securely tokenizes and stores your customers’ card data—without requiring the use of our payment solutions. Supports card tokenization at PSPs and networks as well.')).toBeVisible();
    await expect(page.locator('span').filter({ hasText: /^Recon$/ })).toBeVisible();
    await expect(page.getByText('A robust tool for efficient reconciliation, providing real-time matching and error detection across transactions, ensuring data consistency and accuracy in financial operations.')).toBeVisible();
    await expect(page.locator('span').filter({ hasText: 'Revenue Recovery' })).toBeVisible();
    await expect(page.getByText('A resilient recovery system that ensures seamless restoration of critical data and transactions, safeguarding against unexpected disruptions and minimizing downtime.')).toBeVisible();
    await expect(page.locator('span').filter({ hasText: 'Cost Observability' })).toBeVisible();
    await expect(page.getByText('Unified view of payment processing costs across acquirers, payment methods, & regions. Track every cent, detect anomalies, audit against contracted rates, & forecast the impact of card network changes.')).toBeVisible();

    await expect(
      page.getByRole("button", { name: "Learn More" }),
    ).toHaveCount(5);
  });

  test("should hide gated product cards on default home when product flags are OFF", async ({
    page,
    context,
  }) => {
    const adminEmail = generateUniqueEmail();
    await signupUser(adminEmail, PLAYWRIGHT_PASSWORD, context.request);

    await setProductFlags(page, {
      dev_vault_v2_product: false,
      dev_recon_v2_product: false,
      dev_recovery_v2_product: false,
      dev_hypersense_v2_product: false,
    });

    await loginUI(page, adminEmail, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    await homePage.homeV2.click();
    await expect(page).toHaveURL(/.*dashboard\/v2\/home/);

    await expect(page.getByText("Explore composable services")).toBeVisible();

    await expect(
      page.locator('span').filter({ hasText: 'Orchestrator' }),
    ).toBeVisible();
    await expect(page.getByText('Unified the diverse abstractions to connect with payment processors, payout processors, fraud management solutions, tax automation solutions, identity solutions and reporting systems')).toBeVisible();

    await expect(
      page.locator('span').filter({ hasText: /^Vault$/ }),
    ).not.toBeAttached();
    await expect(
      page.locator('span').filter({ hasText: /^Recon$/ }),
    ).not.toBeAttached();
    await expect(
      page.locator('span').filter({ hasText: 'Revenue Recovery' }),
    ).not.toBeAttached();
    await expect(
      page.locator('span').filter({ hasText: 'Cost Observability' }),
    ).not.toBeAttached();

    await expect(
      page.getByRole("button", { name: "Learn More" }),
    ).toHaveCount(1);
  });

  test("should handle Learn More click on every product card when all product flags are ON", async ({
    page,
    context,
  }) => {
    const adminEmail = generateUniqueEmail();
    await signupUser(adminEmail, PLAYWRIGHT_PASSWORD, context.request);

    await setProductFlags(page, {
      dev_vault_v2_product: true,
      dev_recon_v2_product: true,
      dev_recovery_v2_product: true,
      dev_hypersense_v2_product: true,
    });

    await loginUI(page, adminEmail, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);

    // Non-active products: Learn More opens the "Add a new merchant" modal.
    // The merchant-name input is pre-filled with `${productPrefix}_${randomString}`.
    const gatedProducts: { name: string; prefix: string }[] = [
      { name: "Vault", prefix: "vault_" },
      { name: "Recon", prefix: "recon_" },
      { name: "Revenue Recovery", prefix: "revenue_recovery_" },
      { name: "Cost Observability", prefix: "cost_observability_" },
    ];
    for (const { name: productName, prefix } of gatedProducts) {
      await homePage.homeV2.click();
      await expect(page).toHaveURL(/.*dashboard\/v2\/home/);

      const card = page
        .locator("div")
        .filter({ has: page.getByText(productName, { exact: true }) })
        .filter({ has: page.getByRole("button", { name: "Learn More" }) })
        .last();
      await card.getByRole("button", { name: "Learn More" }).click();

      await expect(page.getByText('Add a new merchant').nth(1)).toBeVisible();
      const merchantNameInput = page.getByRole('textbox', { name: 'Eg: My New Merchant' });
      await expect(merchantNameInput).toBeVisible();
      await expect(merchantNameInput).toHaveValue(new RegExp(`^${prefix}`));
      await expect(page.getByRole('button', { name: 'Add Merchant' })).toBeVisible();
      await page.getByRole('button', { name: 'Add Merchant' }).click();
    }

    // Active product (Orchestrator): Learn More navigates to /dashboard/home
    await homePage.homeV2.click();
    await expect(page).toHaveURL(/.*dashboard\/v2\/home/);

    const orchestratorCard = page
      .locator("div")
      .filter({ has: page.getByText("Orchestrator", { exact: true }) })
      .filter({ has: page.getByRole("button", { name: "Learn More" }) })
      .last();
    await orchestratorCard
      .getByRole("button", { name: "Learn More" })
      .click();

    await expect(page).toHaveURL(/.*dashboard\/home/);
  });
});

test.describe("Live Mode and Test mode Behavior", () => {
  test("should hide Test Mode banner and Get Production Access on /dashboard/home when is_live_mode flag is ON", async ({
    page,
    context,
  }) => {
    const adminEmail = generateUniqueEmail();
    await signupUser(adminEmail, PLAYWRIGHT_PASSWORD, context.request);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.is_live_mode = true;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, adminEmail, PLAYWRIGHT_PASSWORD);

    await expect(page.locator('div').filter({ hasText: /^Live Mode$/ })).toBeVisible();

    const testModeBanner = page.getByText("You're in Test Mode");
    await expect(testModeBanner).not.toBeVisible();
    await expect(testModeBanner).not.toBeAttached();

    const getProductionAccess = page
      .locator("#navbar")
      .getByText("Get Production Access");
    await expect(getProductionAccess).not.toBeVisible();
    await expect(getProductionAccess).not.toBeAttached();
  });

  test("should display Test Mode banner and Get Production Access on /dashboard/home when is_live_mode flag is OFF", async ({
    page,
    context,
  }) => {
    const adminEmail = generateUniqueEmail();
    await signupUser(adminEmail, PLAYWRIGHT_PASSWORD, context.request);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.is_live_mode = false;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, adminEmail, PLAYWRIGHT_PASSWORD);

    const testModeBanner = page.getByText("You're in Test Mode");
    await expect(testModeBanner).toBeVisible();

    const getProductionAccess = page
      .locator("#navbar")
      .getByText("Get Production Access");
    await expect(getProductionAccess).toBeVisible();

    await getProductionAccess.click();
    await expect(
      page.getByRole("button", { name: "Get Production Access" }),
    ).toBeVisible();
  });
});

test.describe("Production access form", () => {
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should fill and submit the production access form, then hide the Get Production Access link", async ({
    page,
  }) => {
    await page.goto("/dashboard/home");
    await expect(page).toHaveURL(/.*dashboard\/home/);

    const getProductionAccess = page.locator("#navbar").getByText("Get Production Access");
    await expect(getProductionAccess).toBeVisible();
    await getProductionAccess.click();

    const submitButton = page.getByRole("button", { name: "Get Production Access" });
    await expect(page.getByText("Get access to Live environment")).toBeVisible();
    await expect(submitButton).toBeVisible();

    await page.getByRole("textbox", { name: "Eg: HyperSwitch Pvt Ltd" }).fill("Hyperswitch Pvt Ltd");
    await page.getByRole("button", { name: "Select Country" }).click();
    await page.locator('div').filter({ hasText: /^Aland Islands$/ }).nth(4).click();
    await page.getByRole("textbox", { name: "Enter a website" }).fill("https://hyperswitch.io");
    await page.getByRole("textbox", { name: "Eg: Jack Ryan" }).fill("Jack Ryan");
    await page.getByRole("textbox", { name: "Eg: jackryan@hyperswitch.io" }).fill("jackryan@hyperswitch.io");

    await submitButton.click();

    await expect(
      page.getByText("Successfully sent for verification!"),
    ).toBeVisible();

    await expect(page.locator("#navbar").getByText("Get Production Access")).not.toBeVisible();
    await expect(page.locator("#navbar").getByText("You're in Test Mode")).toBeVisible();
    await expect(page.locator("#navbar").getByText("Production Access Requested")).toBeVisible();
  });

  test("should display required-field and field-level validation errors on the production access form", async ({
    page,
  }) => {
    await page.goto("/dashboard/home");
    await expect(page).toHaveURL(/.*dashboard\/home/);

    const getProductionAccess = page.locator("#navbar").getByText("Get Production Access");
    await expect(getProductionAccess).toBeVisible();
    await getProductionAccess.click();

    const submitButton = page.getByRole("button", { name: "Get Production Access" });
    await expect(page.getByText("Get access to Live environment")).toBeVisible();
    await expect(submitButton).toBeVisible();

    // All required field labels are present with the `*` indicator
    await expect(page.getByText('Legal Business Name *')).toBeVisible();
    await expect(page.getByText('Business country *')).toBeVisible();
    await expect(page.getByText('Business Website *')).toBeVisible();
    await expect(page.getByText('Contact Name *')).toBeVisible();
    await expect(page.getByText('Contact Email *')).toBeVisible();

    // Empty form -> submit button is disabled
    await expect(submitButton).toBeDisabled();

    // Field-level validation: malformed website + email
    await page.getByRole("textbox", { name: "Eg: HyperSwitch Pvt Ltd" }).fill("Hyperswitch Pvt Ltd");
    await page.getByRole("button", { name: "Select Country" }).click();
    await page.locator('div').filter({ hasText: /^Aland Islands$/ }).nth(4).click();
    await page.getByRole("textbox", { name: "Enter a website" }).fill("not a url");
    await page.getByRole("textbox", { name: "Eg: jackryan@hyperswitch.io" }).fill("invalid-email");
    await page.getByRole("textbox", { name: "Eg: Jack Ryan" }).fill("Jack Ryan");

    await expect(page.getByText('Please Enter Valid URL')).toBeVisible();
    await expect(page.getByText("Please enter valid email id")).toBeVisible();

    // Fix website + email -> field-level errors clear
    await page.getByRole("textbox", { name: "Enter a website" }).fill("https://hyperswitch.io");
    await page.getByRole("textbox", { name: "Eg: jackryan@hyperswitch.io" }).fill("jackryan@hyperswitch.io");
    await expect(page.getByText("Please Enter Valid URL")).not.toBeVisible();
    await expect(page.getByText("Please enter valid email id")).not.toBeVisible();
  });
});
