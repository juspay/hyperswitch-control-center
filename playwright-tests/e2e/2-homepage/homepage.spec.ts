import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { ProductionAccessPage } from "../../support/pages/homepage/ProductionAccessPage";
import { OrganizationChartPage } from "../../support/pages/settings/OrganizationChartPage";
import { generateUniqueEmail, generateDateTimeString } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createBusinessProfileAPI,
  createMerchantAPI,
} from "../../support/commands";
import UsersPage from "../../support/pages/settings/UsersPage";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
let email = "";

test.describe("Homepage", () => {
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

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

    await expect(homePage.welcomeText).toBeVisible();

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
      "Integrate a ProcessorGet a head start by connecting with 20+ gateways, payment methods, and networks.Connect Processors",
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

    await homePage.connectProcessorsButton.click();
    await expect(page).toHaveURL(/.*connectors/);

    await homePage.overview.click();

    await homePage.goToApiKeysButton.click();
    await expect(page).toHaveURL(/.*developer-api-keys/);
  });

  test("should render a Visit button for developer resources that is enabled", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    const visit = homePage.visitButton.first();
    await expect(visit).toBeVisible();
    await expect(visit).toBeEnabled();
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

    await expect(homePage.myModulesHeader).toBeVisible();

    await homePage.overview.click();
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

    await expect(homePage.exploreComposableServicesText).toBeVisible();

    await expect(homePage.productCardName("Orchestrator")).toBeVisible();
    await expect(homePage.orchestratorDescription).toBeVisible();
    await expect(homePage.productCardName(/^Vault$/)).toBeVisible();
    await expect(homePage.vaultDescription).toBeVisible();
    await expect(homePage.productCardName(/^Recon$/)).toBeVisible();
    await expect(homePage.reconDescription).toBeVisible();
    await expect(homePage.productCardName("Revenue Recovery")).toBeVisible();
    await expect(homePage.revenueRecoveryDescription).toBeVisible();
    await expect(homePage.productCardName("Cost Observability")).toBeVisible();
    await expect(homePage.costObservabilityDescription).toBeVisible();

    await expect(homePage.learnMoreButtons).toHaveCount(5);
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

    await expect(homePage.exploreComposableServicesText).toBeVisible();

    await expect(homePage.productCardName("Orchestrator")).toBeVisible();
    await expect(homePage.orchestratorDescription).toBeVisible();

    await expect(homePage.productCardName(/^Vault$/)).not.toBeAttached();
    await expect(homePage.productCardName(/^Recon$/)).not.toBeAttached();
    await expect(
      homePage.productCardName("Revenue Recovery"),
    ).not.toBeAttached();
    await expect(
      homePage.productCardName("Cost Observability"),
    ).not.toBeAttached();

    await expect(homePage.learnMoreButtons).toHaveCount(1);
  });

  test.skip("should handle Learn More click on every product card when all product flags are ON", async ({
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

      await homePage
        .productCard(productName)
        .getByRole("button", { name: "Learn More" })
        .click();

      await expect(homePage.addNewMerchantHeader.nth(1)).toBeVisible();
      await expect(homePage.merchantNameInput).toBeVisible();
      await expect(homePage.merchantNameInput).toHaveValue(
        new RegExp(`^${prefix}`),
      );
      await expect(homePage.addMerchantButton).toBeVisible();
      await homePage.addMerchantButton.click();
    }

    // Active product (Orchestrator): Learn More navigates to /dashboard/home
    await homePage.homeV2.click();
    await expect(page).toHaveURL(/.*dashboard\/v2\/home/);

    await homePage
      .productCard("Orchestrator")
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

    const homePage = new HomePage(page);

    await expect(homePage.liveModeBadge).toBeVisible();

    await expect(homePage.testModeBannerText).not.toBeVisible();
    await expect(homePage.testModeBannerText).not.toBeAttached();

    await expect(homePage.navbarGetProductionAccess).not.toBeVisible();
    await expect(homePage.navbarGetProductionAccess).not.toBeAttached();
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

    const homePage = new HomePage(page);
    const productionAccessPage = new ProductionAccessPage(page);

    await expect(homePage.testModeBannerText).toBeVisible();

    await expect(homePage.navbarGetProductionAccess).toBeVisible();

    await homePage.navbarGetProductionAccess.click();
    await expect(productionAccessPage.submitButton).toBeVisible();
  });
});

test.describe("Production access form", () => {
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should fill and submit the production access form, then hide the Get Production Access link", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const productionAccessPage = new ProductionAccessPage(page);

    await page.goto("/dashboard/home");
    await expect(page).toHaveURL(/.*dashboard\/home/);

    await expect(homePage.navbarGetProductionAccess).toBeVisible();
    await homePage.navbarGetProductionAccess.click();

    await expect(productionAccessPage.header).toBeVisible();
    await expect(productionAccessPage.submitButton).toBeVisible();

    await productionAccessPage.legalBusinessNameInput.fill(
      "Hyperswitch Pvt Ltd",
    );
    await productionAccessPage.selectCountryButton.click();
    await productionAccessPage.countryOption(/^Aland Islands$/).click();
    await productionAccessPage.websiteInput.fill("https://hyperswitch.io");
    await productionAccessPage.contactNameInput.fill("Jack Ryan");
    await productionAccessPage.contactEmailInput.fill(
      "jackryan@hyperswitch.io",
    );

    await productionAccessPage.submitButton.click();

    await expect(productionAccessPage.successMessage).toBeVisible();

    await expect(homePage.navbarGetProductionAccess).not.toBeVisible();
    await expect(homePage.navbarTestMode).toBeVisible();
    await expect(homePage.navbarProductionAccessRequested).toBeVisible();
  });

  test("should display required-field and field-level validation errors on the production access form", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const productionAccessPage = new ProductionAccessPage(page);

    await page.goto("/dashboard/home");
    await expect(page).toHaveURL(/.*dashboard\/home/);

    await expect(homePage.navbarGetProductionAccess).toBeVisible();
    await homePage.navbarGetProductionAccess.click();

    await expect(productionAccessPage.header).toBeVisible();
    await expect(productionAccessPage.submitButton).toBeVisible();

    // All required field labels are present with the `*` indicator
    await expect(productionAccessPage.legalBusinessNameLabel).toBeVisible();
    await expect(productionAccessPage.businessCountryLabel).toBeVisible();
    await expect(productionAccessPage.businessWebsiteLabel).toBeVisible();
    await expect(productionAccessPage.contactNameLabel).toBeVisible();
    await expect(productionAccessPage.contactEmailLabel).toBeVisible();

    // Empty form -> submit button is disabled
    await expect(productionAccessPage.submitButton).toBeDisabled();

    // Field-level validation: malformed website + email
    await productionAccessPage.legalBusinessNameInput.fill(
      "Hyperswitch Pvt Ltd",
    );
    await productionAccessPage.selectCountryButton.click();
    await productionAccessPage.countryOption(/^Aland Islands$/).click();
    await productionAccessPage.websiteInput.fill("not a url");
    await productionAccessPage.contactEmailInput.fill("invalid-email");
    await productionAccessPage.contactNameInput.fill("Jack Ryan");

    await expect(productionAccessPage.invalidUrlError).toBeVisible();
    await expect(productionAccessPage.invalidEmailError).toBeVisible();

    // Fix website + email -> field-level errors clear
    await productionAccessPage.websiteInput.fill("https://hyperswitch.io");
    await productionAccessPage.contactEmailInput.fill(
      "jackryan@hyperswitch.io",
    );
    await expect(productionAccessPage.invalidUrlError).not.toBeVisible();
    await expect(productionAccessPage.invalidEmailError).not.toBeVisible();
  });
});

test.describe("SDK Payment", () => {
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(merchantId, "stripe_test_sdk", context.request);
    }

    await homePage.tryItOutButton.click();
  });

  test("should render the SDK hosted checkout preview section", async ({ page }) => {
    const homePage = new HomePage(page);

    await expect(homePage.setupCheckoutHeader).toContainText("Setup Checkout");
    await expect(page.getByRole('tab', { name: 'Checkout Details' })).toBeVisible();
    await expect(page.getByRole('tab', { name: 'Theme Customization' })).toBeVisible();
    await expect(page.getByText('Customer ID')).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^Guest Mode$/ })).toBeVisible();
    await expect(page.getByRole('textbox', { name: 'Enter Customer ID' })).toBeVisible();
    await expect(page.getByRole('textbox', { name: 'Enter Customer ID' })).toHaveValue("hyperswitch_sdk_demo_id");
    await expect(page.getByText('Show Saved Card')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Yes' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Yes' })).toHaveAttribute("data-value", "yes");
    await expect(page.locator('div').filter({ hasText: /^Currency$/ }).first()).toBeVisible();
    await expect(page.getByRole('button', { name: '🇺🇸 United States Of America' })).toBeVisible();
    await expect(page.getByText('Enter amount')).toBeVisible();
    await expect(page.getByRole('textbox', { name: 'Enter amount' })).toBeVisible();
    await expect(page.getByRole('textbox', { name: 'Enter amount' })).toHaveValue("100");
    await expect(page.getByText('Edit Checkout Details')).toBeVisible();
    await expect(homePage.showPreviewButton).toBeVisible();
    await expect(homePage.showPreviewButton).toBeEnabled();
    await expect(page.getByText('For Testing Stripe & Dummy')).toBeVisible();
    await expect(page.getByText('Card Number :4242 4242 4242 4242')).toBeVisible();
    await expect(page.getByText('Expiry:Any future date')).toBeVisible();
    await expect(page.getByText('CVC:Any 3 Digits')).toBeVisible();
    await expect(page.getByRole('link', { name: 'Test creds for other connectors here' })).toBeVisible();
    await expect(homePage.sdkPreviewHeading).toBeVisible();
    await expect(page.getByRole('img', { name: 'blurry-sdk' })).toBeVisible();
  });

  test("should render the SDK theme configuration form", async ({ page }) => {
    const homePage = new HomePage(page);

    await expect(homePage.sdkCheckoutDetailsTab).toBeVisible();
    await homePage.sdkThemeCustomizationTab.click();
    await expect(page.locator('div').filter({ hasText: /^Theme$/ }).first()).toBeVisible();
    await expect(page.getByRole('button', { name: 'Default' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Default' })).toHaveAttribute("data-value", "default");
    await expect(page.locator('div').filter({ hasText: /^Locale$/ }).first()).toBeVisible();
    await expect(page.getByRole('button', { name: 'English (Global)' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'English (Global)' })).toHaveAttribute("data-value", "english(Global)");
    await expect(page.getByText('Layout')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Tabs' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Tabs' })).toHaveAttribute("data-value", "tabs");
    await expect(page.locator('div').filter({ hasText: /^Labels$/ }).first()).toBeVisible();
    await expect(page.getByRole('button', { name: 'Above' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Above' })).toHaveAttribute("data-value", "above");
    await expect(page.locator('div').filter({ hasText: /^Color Picker Input$/ }).nth(1)).toBeVisible();
    await expect(page.getByRole('textbox', { name: '#FFFFFF' })).toBeVisible();
    await expect(page.getByRole('textbox', { name: '#FFFFFF' })).toHaveValue("#006DF9");
    await expect(page.getByRole('link', { name: 'Learn More About Customization' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Show preview' })).toBeVisible();
  });

  test("should bind SDK form inputs to user-typed values", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.sdkCustomerIdInput.fill("cust_playwright_001");
    await expect(homePage.sdkCustomerIdInput).toHaveValue("cust_playwright_001");

    await page.getByRole('button', { name: 'Yes' }).click();
    await page.locator('div').filter({ hasText: /^No$/ }).nth(1).click();
    await expect(page.getByRole('button', { name: 'No' })).toHaveAttribute("data-value", "no");

    await page.getByRole('button', { name: '🇺🇸 United States Of America' }).click();
    await page.getByRole('textbox', { name: 'Search name or ID...' }).type("India");
    await page.getByText('🇮🇳 India - (INR)').click();
    await expect(page.getByRole('button', { name: '🇮🇳 India - (INR)' })).toBeVisible();

    await homePage.sdkAmountInput.fill("250.50");
    await expect(homePage.sdkAmountInput).toHaveValue("250.50");
  });

  test.fixme("should make a successful payment using SDK", async ({ page, context }) => {
    const homePage = new HomePage(page);

    await page.getByRole('button', { name: '🇺🇸 United States Of America' }).click();
    await page.getByRole('textbox', { name: 'Search name or ID...' }).type("India");
    await page.getByText('🇮🇳 India - (INR)').click();

    await homePage.sdkAmountInput.fill("123.45");

    await homePage.showPreviewButton.click();
    await page.waitForLoadState("networkidle");
    await homePage.waitForSdkCardForm();

    await homePage.fillSdkTestCard();

    await expect(homePage.payButtonByCurrency("INR")).toContainText("Pay INR 123.45");
    await homePage.payButtonByCurrency("INR").click();
    await expect(homePage.paymentSuccessfulText).toBeAttached({ timeout: 10000 });

    await homePage.goToPaymentOperationsButton.click();
    expect(page.url()).toContain("/dashboard/payments/pay_");

  });

  test.fixme("should display failed payment status using SDK", async ({ page }) => {
    const homePage = new HomePage(page);

    await page.route("**/payments/*/confirm", async (route) => {
      if (route.request().method() === "POST") {
        const response = await route.fetch();
        const json = await response.json();
        json.status = "failed";
        json.error_code = "CE_01";
        json.error_message = "Payment declined by processor";
        await route.fulfill({ response, json });
      } else {
        await route.continue();
      }
    });

    await homePage.showPreviewButton.click();
    await page.waitForLoadState("networkidle");
    await homePage.waitForSdkCardForm();

    await homePage.fillSdkTestCard();

    await expect(homePage.payButtonByCurrency("USD")).toContainText("Pay USD 100");
    await homePage.payButtonByCurrency("USD").click();
    await expect(homePage.paymentFailedText).toBeVisible({ timeout: 10000 });
    await expect(homePage.goToPaymentOperationsButton).toBeVisible();
  });

  test.fixme("should display processing payment status using SDK", async ({ page }) => {
    const homePage = new HomePage(page);

    await page.route("**/payments/*/confirm", async (route) => {
      if (route.request().method() === "POST") {
        const response = await route.fetch();
        const json = await response.json();
        json.status = "processing";
        await route.fulfill({ response, json });
      } else {
        await route.continue();
      }
    });

    await homePage.showPreviewButton.click();
    await page.waitForLoadState("networkidle");
    await homePage.waitForSdkCardForm();

    await homePage.fillSdkTestCard();

    await expect(homePage.payButtonByCurrency("USD")).toContainText("Pay USD 100");
    await homePage.payButtonByCurrency("USD").click();
    await expect(homePage.paymentPendingText).toBeVisible({ timeout: 10000 });
    await expect(homePage.goToPaymentOperationsButton).toBeVisible();
  });

  test("should display error toast when SDK save (Show Preview) API fails", async ({ page }) => {
    await page.route("**/payments", async (route) => {
      if (route.request().method() === "POST") {
        await route.fulfill({
          status: 500,
          contentType: "application/json",
          body: JSON.stringify({ error: { message: "Internal Server Error" } }),
        });
      } else {
        await route.continue();
      }
    });

    const homePage = new HomePage(page);

    await page.goto("/dashboard/sdk");
    await expect(homePage.showPreviewButton).toBeEnabled();
    await homePage.showPreviewButton.click();

    await expect(homePage.sdkErrorToast).toBeVisible();
  });
});

test.describe("Organization Chart Tree", () => {
  let companyName = "";

  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    companyName = generateDateTimeString();
    await signupUser(email, PLAYWRIGHT_PASSWORD, undefined, companyName);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
  });

  test("should render organization chart tree with org, merchant and profile columns with correct colour", async ({
    page,
  }) => {
    const orgChart = new OrganizationChartPage(page);
    await orgChart.visit();

    await expect(orgChart.pageHeading).toBeVisible();
    await expect(orgChart.pageSubtitle).toBeVisible();

    await expect(orgChart.orgColumn).toBeVisible();
    await expect(orgChart.merchantColumn).toBeVisible();
    await expect(orgChart.profileColumn).toBeVisible();

    await expect(page.getByText("Organization" + companyName)).toBeVisible();
    await expect(page.getByText("Organization" + companyName).getByText(companyName)).toHaveClass(/border-blue-600/);
    await expect(page.getByText("Organization" + companyName).getByText(companyName)).toHaveClass(/text-blue-600/);

    await expect(page.getByText("Merchant" + companyName)).toBeVisible();
    await expect(page.getByText("Merchant" + companyName).getByText(companyName + "Orchestrator")).toHaveClass(/border-blue-600/);
    await expect(page.getByText("Merchant" + companyName).getByText(companyName + "Orchestrator")).toHaveClass(/text-blue-600/);

    await expect(page.getByRole('button', { name: 'default' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'default' })).toHaveClass(/border-blue-600/);
    await expect(page.getByRole('button', { name: 'default' })).toHaveClass(/text-blue-600/);
  });

  test("should render chart with newly created merchant and profile highlighting selected options", async ({
    page,
    context,
  }) => {
    const orgChart = new OrganizationChartPage(page);

    const rawUserInfo = await page.evaluate(() =>
      window.localStorage.getItem("USER_INFO"),
    );
    const userInfo = JSON.parse(rawUserInfo || "{}");
    const token: string = userInfo.token || "";

    const newMerchantName = generateDateTimeString();
    const newMerchant = await createMerchantAPI(
      token,
      newMerchantName,
      context.request,
    );
    const newMerchantId = newMerchant.merchant_id;

    await createBusinessProfileAPI(
      newMerchantId,
      "new-test-profile",
      context.request,
    );

    await orgChart.visit();

    const orgName = page.getByRole('button', { name: companyName, exact: true });
    const merchantOneName = page.getByText(companyName + "Orchestrator");
    const merchantTwoName = page.getByText(newMerchantName + "Orchestrator");
    const merchantOneProfileName = page.getByRole('button', { name: 'default' });
    const merchantTwoProfileTwoName = page.getByRole('button', { name: 'new-test-profile' });

    await expect(orgChart.pageHeading).toBeVisible();

    //Organization button
    await expect(orgName).toBeVisible();
    await expect(orgName).toHaveClass(/border-blue-600/);
    await expect(orgName).toHaveClass(/text-blue-600/);

    //1st Merchant button - selected
    await expect(merchantOneName).toBeVisible();
    await expect(merchantOneName).toHaveClass(/border-blue-600/);
    await expect(merchantOneName).toHaveClass(/text-blue-600/);

    //2nd Merchant button - unselected
    await expect(merchantTwoName).toBeVisible();
    await expect(merchantTwoName).toHaveClass(/border-gray-200/);
    await expect(merchantTwoName).toHaveClass(/border-gray-200/);

    // 1st Merchant - Profile
    await expect(merchantOneProfileName).toBeVisible();
    await expect(merchantOneProfileName).toHaveClass(/border-blue-600/);
    await expect(merchantOneProfileName).toHaveClass(/border-blue-600/);

    //Switch merchant
    await merchantTwoName.click();

    //Organization button
    await expect(orgName).toBeVisible();
    await expect(orgName).toHaveClass(/border-blue-600/);
    await expect(orgName).toHaveClass(/text-blue-600/);

    //1st Merchant button - unselected
    await expect(merchantOneName).toBeVisible();
    await expect(merchantOneName).toHaveClass(/border-gray-200/);
    await expect(merchantOneName).toHaveClass(/border-gray-200/);

    //2nd Merchant button - selected
    await expect(merchantTwoName).toBeVisible();
    await expect(merchantTwoName).toHaveClass(/border-blue-600/);
    await expect(merchantTwoName).toHaveClass(/text-blue-600/);

    //1st Profile button
    await expect(merchantOneProfileName).toBeVisible();
    await expect(merchantOneProfileName).toHaveClass(/border-gray-200/);
    await expect(merchantOneProfileName).toHaveClass(/border-gray-200/);

    //2nd Profile button
    await expect(merchantTwoProfileTwoName).toBeVisible();
    await expect(merchantTwoProfileTwoName).toHaveClass(/border-blue-600/);
    await expect(merchantTwoProfileTwoName).toHaveClass(/border-blue-600/);

    //Switch profile
    await merchantOneProfileName.click();

    //Organization button
    await expect(orgName).toBeVisible();
    await expect(orgName).toHaveClass(/border-blue-600/);
    await expect(orgName).toHaveClass(/text-blue-600/);

    //1st Merchant button - unselected
    await expect(merchantOneName).toBeVisible();
    await expect(merchantOneName).toHaveClass(/border-gray-200/);
    await expect(merchantOneName).toHaveClass(/border-gray-200/);

    //2nd Merchant button - selected
    await expect(merchantTwoName).toBeVisible();
    await expect(merchantTwoName).toHaveClass(/border-blue-600/);
    await expect(merchantTwoName).toHaveClass(/text-blue-600/);

    //1st Profile button
    await expect(merchantOneProfileName).toBeVisible();
    await expect(merchantOneProfileName).toHaveClass(/border-blue-600/);
    await expect(merchantOneProfileName).toHaveClass(/border-blue-600/);

    //2nd Profile button
    await expect(merchantTwoProfileTwoName).toBeVisible();
    await expect(merchantTwoProfileTwoName).toHaveClass(/border-gray-200/);
    await expect(merchantTwoProfileTwoName).toHaveClass(/border-gray-200/);
  });

  test("should display loading state while switching entities", async ({
    page,
    context,
  }) => {
    const orgChart = new OrganizationChartPage(page);
    const usersPage = new UsersPage(page);

    const rawUserInfo = await page.evaluate(() =>
      window.localStorage.getItem("USER_INFO"),
    );
    const userInfo = JSON.parse(rawUserInfo || "{}");
    const token: string = userInfo.token || "";

    const newMerchantName = generateDateTimeString();
    const newMerchant = await createMerchantAPI(
      token,
      newMerchantName,
      context.request,
    );
    const newMerchantId = newMerchant.merchant_id;

    await createBusinessProfileAPI(
      newMerchantId,
      "new-test-profile",
      context.request,
    );

    await orgChart.visit();

    const merchantTwoName = page.getByText(newMerchantName + "Orchestrator");
    const merchantOneProfileName = page.getByRole('button', { name: 'default' });
    const merchantTwoProfileTwoName = page.getByRole('button', { name: 'new-test-profile' });

    await merchantTwoName.click();
    await expect(orgChart.merchantSwitchingLoader).toBeVisible();
    await expect(usersPage.merchantSwitchedSuccessText).toBeVisible();

    await merchantTwoProfileTwoName.click();

    await merchantOneProfileName.click();
    await expect(orgChart.profileSwitchingLoader).toBeVisible();
    await expect(usersPage.profileSwitchedSuccessText).toBeVisible();
  });
});
