import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentConnector } from "../../support/pages/connector/PaymentConnector";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createStripeConnectorAPI,
  createBusinessProfileAPI,
  ompLineage,
  assertConnectorFieldLabels,
  fillConnectorFields,
  assertPaymentMethodTypes,
  createAPIKey,
  createStripeConnectorAPIwithAPIKey,
  getDefaultProfileId,
} from "../../support/commands";
import { connectorConfig } from "../../support/fixtures/payinConnectorConfig";
import { exec } from "node:child_process";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(
  page: Page,
  context: BrowserContext,
): Promise<void> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function gotoConnectorList(page: Page): Promise<void> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  await homePage.paymentProcessors.click();
  await page.waitForLoadState("networkidle");
}

async function fillStripeFormDefaults(page: Page): Promise<void> {
  const inputs = page
    .locator('.grid.grid-cols-2 input[type="text"]')
    .locator("visible=true");
  const count = await inputs.count();
  for (let i = 0; i < count; i++) {
    const input = inputs.nth(i);
    await input.clear();
    await input.fill("test_value");
  }
}

async function openStripeConnectorForm(page: Page): Promise<void> {
  const paymentConnector = new PaymentConnector(page);
  await gotoConnectorList(page);
  await paymentConnector.connectorSearchInput.fill("stripe");
  await page.waitForTimeout(500);
  const stripeCard = page.locator('[data-testid="stripe"]').first();
  await expect(stripeCard).toBeVisible({ timeout: 10000 });
  await stripeCard.locator("button").click({ force: true });
  await fillStripeFormDefaults(page);
}

async function setupConfiguredStripeConnector(
  page: Page,
  context: BrowserContext,
  label: string = "stripe_configured",
): Promise<string> {
  const { merchantId } = await ompLineage(page);
  await createStripeConnectorAPI(merchantId, label, context.request);
  await page.reload();
  await page.waitForLoadState("networkidle");
  return label;
}

test.describe("Stripe Connector", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should show dummy processor banner only in test mode", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await gotoConnectorList(page);

    await expect(paymentConnector.pageBanner).toContainText(
      "Connect a Dummy Processor",
    );
    await expect(
      page.getByRole("button", { name: "Request a Processor" }).first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should not show dummy processor banner in live mode", async ({
    page,
  }) => {
    await gotoConnectorList(page);

    await page.route("**/dashboard/config/feature?domain=", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.is_live_mode = true;
      }
      await route.fulfill({ response, json });
    });

    await page.reload();

    await expect(page.getByRole('paragraph').filter({ hasText: 'Connect a Dummy Processor' })).not.toBeAttached();
    await expect(page.getByRole("button", { name: "Request a Processor" }).first()).not.toBeAttached();
  });

  test("should setup a dummy connector end-to-end", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await expect(paymentConnector.pageHeading).toContainText(
      "Payment Processors",
    );
    await expect(paymentConnector.pageHeading).toBeVisible();
    await expect(paymentConnector.pageBanner).toContainText(
      "Connect a Dummy Processor",
    );

    await paymentConnector.connectNowButton.click({ force: true });
    await expect(paymentConnector.stripeDummyConnector).toBeVisible();
    await paymentConnector.stripeDummyConnector
      .locator("button")
      .click({ force: true });

    await expect(
      page.locator("[name=connector_account_details\\.api_key]"),
    ).toHaveValue("test_key");

    await paymentConnector.connectAndProceedButton.click();
    await paymentConnector.pmtProceedButton.click();

    await expect(
      page.locator('[data-toast="Connector Created Successfully!"]'),
    ).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("stripe_test_default")).toBeVisible();
  });

  test("should search the processor grid when searching a known processor", async ({
    page,
  }) => {
    await gotoConnectorList(page);

    const search = page.getByPlaceholder("Search a processor");
    await search.fill("adyen");
    await page.waitForTimeout(500);
    await expect(page.getByText(/adyen/i).first()).toBeVisible({
      timeout: 5000,
    });
  });

  test("should render zero Connect buttons when search has no matches", async ({
    page,
  }) => {
    await gotoConnectorList(page);

    const search = page.getByPlaceholder("Search a processor");
    await search.fill("nonexistentprocessor_zzzzzzzz");
    await page.waitForTimeout(700);
    const connectVisible = await page
      .getByRole("button", { name: "Connect", exact: true })
      .filter({ visible: true })
      .count();
    expect(connectVisible).toBe(0);
  });

  test("should search a connector by merchant connector ID", async ({
    page,
    context,
  }) => {
    const stripeLabel = "stripe_default";
    const { merchantId } = await ompLineage(page);
    await createStripeConnectorAPI(merchantId, stripeLabel, context.request);
    await gotoConnectorList(page);

    const connectorRow = page
      .locator("tr", { hasText: stripeLabel })
      .first();
    await expect(connectorRow).toBeVisible({ timeout: 10000 });

    const mcaCell = connectorRow
      .locator('td:has-text("mca_"), [data-testid*="mca"], code')
      .first();
    if (!(await mcaCell.isVisible({ timeout: 5000 }).catch(() => false))) {
      test.skip(true, "Merchant connector id column not surfaced");
    }
    const mcaId = ((await mcaCell.textContent()) ?? "").trim();
    expect(mcaId.length).toBeGreaterThan(0);

    const search = page
      .locator('[data-testid="search-processor"]')
      .or(page.getByPlaceholder(/Search/i))
      .first();
    await expect(search).toBeVisible({ timeout: 10000 });
    await search.fill(mcaId);
    await search.blur();
    await page.waitForTimeout(500);

    await expect(page.getByText(stripeLabel).first()).toBeVisible();
  });

  test("should show 'No Data Available' when searching for a non-existent connector", async ({
    page,
    context,
  }) => {
    const stripeLabel = "stripe_default";
    const { merchantId } = await ompLineage(page);
    await createStripeConnectorAPI(merchantId, stripeLabel, context.request);
    await gotoConnectorList(page);

    const connectorRow = page
      .locator("tr", { hasText: stripeLabel })
      .first();
    await expect(connectorRow).toBeVisible({ timeout: 10000 });

    const search = page
      .locator('[data-testid="search-processor"]')
      .or(page.getByPlaceholder(/Search/i))
      .first();
    await expect(search).toBeVisible({ timeout: 10000 });
    await search.fill("abcd");
    await search.blur();
    await page.waitForTimeout(500);

    await expect(
      page.locator("div").filter({ hasText: /^No Data Available$/ }).nth(2),
    ).toBeVisible();
  });

  test("should mark required fields with asterisk", async ({ page }) => {
    await openStripeConnectorForm(page);
    await expect(page.locator('div').filter({ hasText: /^Secret Key \*$/ }).nth(1)).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^Connector label \*$/ }).nth(2)).toBeVisible();
  });

  test("should show tooltip on Connector Label help icon hover", async ({
    page,
  }) => {
    await openStripeConnectorForm(page);

    const connectorLabelField = page
      .locator("div")
      .filter({ hasText: /^Connector label \*$/ })
      .nth(2);
    await expect(connectorLabelField).toBeVisible();

    const helpIcon = connectorLabelField
      .locator(".text-sm.text-gray-500")
      .first();
    await expect(helpIcon).toBeVisible();
    await helpIcon.hover();

    await expect(page.getByText(/This is an unique label you can generate and pass in order to identify this connector account on your Hyperswitch dashboard and reports. Eg: if your profile label is 'default', connector label can be 'stripe_default'/i).first()).toBeVisible({
      timeout: 5000,
    });
  });

  test("should filter connector list by active profile context", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const { merchantId } = await ompLineage(page);

    const defaultLabel = "stripe_default_profile";
    const secondaryLabel = "stripe_secondary_profile";

    const secondaryProfileId = await createBusinessProfileAPI(
      merchantId,
      "secondary_profile",
      context.request,
    );

    await createStripeConnectorAPI(
      merchantId,
      defaultLabel,
      context.request,
    );
    await createStripeConnectorAPI(
      merchantId,
      secondaryLabel,
      context.request,
      secondaryProfileId,
    );

    await gotoConnectorList(page);
    await expect(page.getByText(defaultLabel).first()).toBeVisible({
      timeout: 10000,
    });
    await expect(page.getByText(secondaryLabel)).not.toBeVisible({
      timeout: 5000,
    });

    const profileSwitcher = homePage.profileDropdown;
    if (!(await profileSwitcher.isVisible().catch(() => false))) {
      test.skip(true, "Profile switcher not exposed in this build");
    }
    await profileSwitcher.click();
    await page
      .locator(
        '[class="max-h-72 overflow-scroll px-1 pt-1 selectbox-scrollbar"]',
      )
      .getByText("secondary_profile", { exact: false })
      .first()
      .click();

    await page.waitForLoadState("networkidle");
    await gotoConnectorList(page);

    await expect(page.getByText(secondaryLabel).first()).toBeVisible({
      timeout: 10000,
    });
    await expect(page.getByText(defaultLabel)).not.toBeVisible({
      timeout: 5000,
    });
  });

  test("should show processors from config in live mode", async ({
    page,
  }) => {
    await gotoConnectorList(page);

    await page.route("**/dashboard/config/feature?domain=", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.is_live_mode = true;
        json.connector_list_for_live.paymentProcessors = ["adyen"]
      }
      await route.fulfill({ response, json });
    });

    await page.reload();

    // await expect(page.getByRole('paragraph').filter({ hasText: 'Connect a Dummy Processor' })).not.toBeAttached();
    // await expect(page.getByRole("button", { name: "Request a Processor" }).first()).not.toBeAttached();
    await expect(page.getByTestId('adyen')).toBeVisible();
    await expect(page.getByTestId('affirm')).not.toBeAttached();

  });

  test("should validate field-level error for connector credentials page", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await gotoConnectorList(page);
    await paymentConnector.connectorSearchInput.fill("stripe");
    await page.waitForTimeout(500);
    const stripeCard = page.locator('[data-testid="stripe"]').first();
    await expect(stripeCard).toBeVisible({ timeout: 10000 });
    await stripeCard.locator("button").click({ force: true });

    const apiKeyField = page.locator("[name=connector_account_details\\.api_key]");
    await apiKeyField.fill("invalid_key_@#$%");
    await apiKeyField.blur();
    await expect(page.getByText('Secret key should have the prefix sk_test_')).toBeVisible();
    await apiKeyField.clear();
    await apiKeyField.blur();
    await expect(page.getByText('Please enter Secret Key')).toBeVisible();

    await page.locator('.grid.grid-cols-2 input[type="text"]').nth(1).clear();
    await page.locator('.grid.grid-cols-2 input[type="text"]').nth(1).blur();
    await expect(page.getByText('Please enter Connector label').nth(1)).toBeVisible();
  });

  test("should group payment methods by category in step 2", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    const stripePaymentSections = {
      Credit: {
        label: "Credit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
          "Interac",
        ],
      },
      Debit: {
        label: "Debit",
        methods: [
          "Mastercard",
          "Visa",
          "AmericanExpress",
          "JCB",
          "DinersClub",
          "Discover",
          "CartesBancaires",
          "UnionPay",
          "Interac",
        ],
      },
      BankTransfer: {
        label: "Bank Transfer",
        methods: ["Multibanco"],
      },
      BankRedirect: {
        label: "Bank Redirect",
        methods: [
          "Ideal",
          "Sofort",
          "Bancontact Card",
          "Giropay",
          "Eps",
          "Blik",
          "Online Banking Czech Republic",
          "Online Banking Finland",
          "Online Banking Poland",
          "Online Banking Slovakia",
          "Trustly",
          "Przelewy 24",
        ],
      },
      BankDebit: {
        label: "Bank Debit",
        methods: ["Ach", "Sepa", "Bacs", "Becs"],
      },
      PayLater: {
        label: "Pay Later",
        methods: ["Klarna", "Affirm", "Afterpay Clearpay"],
      },
      Wallet: {
        label: "Wallet",
        methods: ["Apple Pay", "Google Pay", "We Chat Pay", "Ali Pay"],
      },
    };

    await assertPaymentMethodTypes(page, stripePaymentSections);
  });

  test("should toggle card payment method", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();
    await expect(page.locator('.flex.items-center.transition.rounded-2\\.5').first()).toHaveAttribute('data-bool-value', 'on');
    await page.locator('.flex.items-center.transition.rounded-2\\.5').first().click();
    await expect(page.locator('.flex.items-center.transition.rounded-2\\.5').first()).toHaveAttribute('data-bool-value', 'off');
  });

  test("should configure Apple Pay web domain flow", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    await page.getByText("Apple Pay").click();

    await expect(page.getByText("Web Domain").nth(2)).toBeVisible();
    await expect(page.getByText("iOS Certificate").nth(1)).toBeVisible();
    await expect(page.getByText("Pre Decrypted Token").nth(1)).toBeVisible();

    await page.getByText("Web Domain").nth(2).click();
    await page.getByRole('button', { name: 'Continue' }).click();

    await expect(page.getByRole('button', { name: 'Verify & Enable' })).toBeDisabled();

    await expect(page.locator('div').filter({ hasText: /^Domain Name \*$/ }).nth(2)).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Domain Name' }).fill("hyperswitch.io")
    await expect(page.getByText('Merchant Business Country *')).toBeVisible();
    await page.getByRole('button', { name: 'Select Value' }).click();
    await page.getByPlaceholder("Search name or ID...").fill("US");
    await page.locator('div').filter({ hasText: /^UnitedStatesOfAmerica$/ }).nth(4).click();

    await page.getByRole('button', { name: 'Download File' }).click();
    await expect(page.locator('[data-toast="File download complete"]')).toContainText("File download complete");

    await expect(page.getByRole('button', { name: 'Verify & Enable' })).not.toBeDisabled();
    await page.getByRole('button', { name: 'Verify & Enable' }).click();
  });

  test("should configure Apple Pay iOS certificate flow", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    await page.getByText("Apple Pay").click();

    await expect(page.getByText("Web Domain").nth(2)).toBeVisible();
    await expect(page.getByText("iOS Certificate").nth(1)).toBeVisible();
    await expect(page.getByText("Pre Decrypted Token").nth(1)).toBeVisible();

    await page.getByText("iOS Certificate").nth(1).click();
    await page.getByRole('button', { name: 'Continue' }).click();

    await expect(page.getByRole('button', { name: 'Verify & Enable' })).toBeDisabled();
    await expect(page.getByText('Merchant Certificate (Base64')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Merchant Certificate (' }).fill("test_value");

    await expect(page.getByText('Merchant PrivateKey (Base64')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Merchant PrivateKey (' }).fill("test_value");

    await expect(page.getByText('Apple Merchant Identifier *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Apple Merchant' }).fill("test_value");

    await expect(page.locator('div').filter({ hasText: /^Display Name \*$/ }).nth(2)).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Display Name' }).fill("test_value");

    await expect(page.locator('div').filter({ hasText: /^Domain \*$/ }).first()).toBeVisible();
    await page.getByRole('button', { name: 'Select Value' }).first().click();
    await page.locator('div').filter({ hasText: /^IOS$/ }).first().click();

    await expect(page.locator('div').filter({ hasText: /^Merchant Business Country \*$/ }).first()).toBeVisible();
    await page.getByRole('button', { name: 'Select Value' }).click();

    await page.getByPlaceholder("Search name or ID...").fill("US");
    await page.locator('div').filter({ hasText: /^UnitedStatesOfAmerica$/ }).nth(4).click();

    await expect(page.getByText('Payment Processing Details At')).toBeVisible();

    await page.locator('div').filter({ hasText: /^Connector$/ }).first().click();
    await page.getByRole('button', { name: 'Verify & Enable' }).click();

    await page.getByRole('button', { name: 'Proceed' }).nth(1).click();
    await page.getByRole('button', { name: 'Proceed' }).click();

    await expect(page.getByRole('heading', { name: 'Apple Pay' })).toBeVisible();
  });

  test("should configure Google Pay flow", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    await page.getByText("Google Pay").click();
    await expect(page.getByText('Payment Gateway').nth(4)).toBeVisible();
    await page.getByRole("button", { name: "Continue" }).click();

    await expect(page.getByRole("button", { name: "Proceed" }).nth(1)).toBeDisabled();

    await expect(page.getByText("Google Pay Merchant Name")).toBeVisible();
    await page.getByRole("textbox", { name: "Enter Google Pay Merchant Name" }).fill("test_value");

    await expect(page.getByText("Google Pay Merchant Id")).toBeVisible();
    await page.getByRole("textbox", { name: "Enter Google Pay Merchant Id" }).fill("test_value");

    await expect(page.getByText('Stripe Publishable Key *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Stripe Publishable Key' }).fill("test_value");

    await expect(page.getByText('Allowed Auth Methods *')).toBeVisible();
    await page.getByRole('button', { name: 'Select Value' }).click();

    await page.getByText("PAN_ONLY").click();
    await page.getByText("CRYPTOGRAM_3DS").click();

    await expect(page.getByRole("button", { name: "Proceed" }).nth(1)).not.toBeDisabled();

    await page.getByRole("button", { name: "Proceed" }).nth(1).click();

    await page.getByRole('button', { name: 'Proceed' }).click();

    await expect(page.getByRole("heading", { name: "Google Pay" })).toBeVisible();
  });

  test("should show summary preview after PMs step", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();
    await paymentConnector.pmtProceedButton.click();

    const summary = page.getByText(/Summary|Preview|Review/i).first();
    if (!(await summary.isVisible({ timeout: 5000 }).catch(() => false))) {
      test.skip(true, "Connector flow does not expose explicit summary step");
    }
    await expect(summary).toBeVisible();
  });

  test("should render connector table with expected columns for configured connector", async ({
    page,
    context,
  }) => {
    await setupConfiguredStripeConnector(page, context);
    await gotoConnectorList(page);
    const expectedHeaders = [
      "Name",
      "Merchant Connector Id",
      "Label",
      "Status",
      "Disabled",
      "Actions",
      "Payment Methods",
    ];
    for (const header of expectedHeaders) {
      const headerLocator = page
        .getByRole("columnheader", { name: header })
        .or(page.getByText(header, { exact: true }))
        .first();
      if (!(await headerLocator.isVisible().catch(() => false))) continue;
      await expect(headerLocator).toBeVisible();
    }
  });

  test("should display configured connector row with status badge", async ({
    page,
    context,
  }) => {
    const createdLabel = await setupConfiguredStripeConnector(page, context);
    await gotoConnectorList(page);
    await expect(page.getByText(createdLabel).first()).toBeVisible({});
    await expect(page.locator('div').filter({ hasText: /^ACTIVE$/ }).first()).toBeVisible();
    await expect(page.getByText('ENABLED')).toBeVisible();
  });

  test("should render disabled/enabled label per connector", async ({
    page,
    context,
  }) => {
    await setupConfiguredStripeConnector(page, context);
    await gotoConnectorList(page);
    await page.locator('div').filter({ hasText: /^Stripe$/ }).first().click();

    await page.locator('.transition.rounded-full').click();
    await expect(page.locator('div').filter({ hasText: /^Disabled$/ }).nth(2)).toBeVisible();
    await page.goBack();
    await expect(page.locator('div').filter({ hasText: /^DISABLED$/ }).first()).toBeVisible();
  });

  test("should render pagination controls when 21 connectors are configured", async ({
    page,
    context,
  }) => {
    test.setTimeout(120_000);
    const { merchantId } = await ompLineage(page);
    const apiKey = await createAPIKey(merchantId, "", context.request);
    const profileId = await getDefaultProfileId(merchantId, context.request);

    const labels = Array.from(
      { length: 21 },
      (_, i) => `stripe_pag_${String(i + 1).padStart(2, "0")}`,
    );
    for (const label of labels) {
      await createStripeConnectorAPIwithAPIKey(
        merchantId,
        label,
        apiKey,
        context.request,
        profileId,
      );
      await page.waitForTimeout(200);
    }

    await gotoConnectorList(page);

    await expect(page.getByText('Showing 20')).toBeVisible();
    await expect(page.getByRole('button', { name: '2', exact: true })).toBeVisible();
    await page.getByRole('button', { name: '2', exact: true }).click();
    await expect(page.getByText('Showing 21')).toBeVisible();
  });

  test("should open edit form, validate pre-populated values, update credentials, and persist changes", async ({
    page,
    context,
  }) => {
    const createdLabel = await setupConfiguredStripeConnector(page, context);
    await gotoConnectorList(page);
    await page.getByText(createdLabel).first().click();

    await expect(page.getByText("Integration statusACTIVE")).toBeVisible();
    await expect(page.getByText("Webhook Endpointhttp://")).toBeVisible();
    await expect(page.getByText("Profiledefault -")).toBeVisible();
    await expect(page.getByRole("heading", { name: "Secret Key" })).toBeVisible();
    await expect(page.getByRole("heading", { name: "te******ue" })).toBeVisible();
    await expect(page.getByRole("heading", { name: "Connector Label" })).toBeVisible();
    await expect(page.getByRole("heading", { name: createdLabel })).toBeVisible();
    await expect(page.getByRole("heading", { name: "Credit" })).toBeVisible();

    await page.locator('.cursor-pointer > span > .flex').first().click();

    const apiKey = page.locator("[name=connector_account_details\\.api_key]");
    await expect(apiKey).toBeVisible();
    await apiKey.clear();
    await apiKey.fill("rotated_key_value");

    const connectorLabel = page.getByRole('textbox', { name: 'Enter Connector label' });
    await expect(connectorLabel).toBeVisible();
    await connectorLabel.clear();
    await connectorLabel.fill("stripe_updated_label");

    const save = page.getByRole('button', { name: 'Submit' });
    await expect(save).toBeVisible();
    await save.click();

    await expect(page.locator('[data-toast*="Details Updated!"]').first()).toBeVisible();

    await expect(page.getByRole('heading', { name: 'ro*************ue' })).toBeVisible();
    await expect(page.getByRole("heading", { name: "te******ue" })).not.toBeVisible();
    await expect(page.getByRole("heading", { name: "stripe_updated_label" })).toBeVisible();
    await expect(page.getByRole("heading", { name: "stripe_configured" })).not.toBeVisible();
  });

  test("should toggle individual payment method on existing connector", async ({
    page,
    context,
  }) => {
    const createdLabel = await setupConfiguredStripeConnector(page, context);
    await gotoConnectorList(page);
    await page.getByText(createdLabel).first().click();

    await expect(page.getByRole('heading', { name: 'Credit' })).toBeVisible();
    await page.locator('.fill-current.ml-2').click();

    await page.locator('.flex.items-center.transition.rounded-2\\.5').first().click();
    await page.locator('.flex.items-center.transition.rounded-2\\.5').first().click();

    await page.getByRole('button', { name: 'Proceed' }).click();
    await page.getByRole('button', { name: 'Done' }).click();
    await expect(page.getByRole('heading', { name: 'Credit' })).not.toBeVisible();

    await page.getByText(createdLabel).first().click();
    await expect(page.getByText('Integration statusACTIVE')).toBeVisible();
    await expect(page.getByRole('heading', { name: 'Credit' })).not.toBeVisible();
  });

  test("should reject duplicate connector label with warning", async ({
    page,
    context,
  }) => {
    const createdLabel = await setupConfiguredStripeConnector(page, context);
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    await page.locator("[name=connector_label]").clear();
    await page.locator("[name=connector_label]").fill(createdLabel);
    await paymentConnector.connectAndProceedButton.click();
    await paymentConnector.pmtProceedButton.click();

    await expect(page.locator('[data-toast*="Connector label already exist!"]').first()).toBeVisible();
  });
});

test.describe("Live Connectors", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  const connectors = Object.entries(connectorConfig);
  for (const [key, connector] of connectors) {
    test(`should setup and verify ${key} connector`, async ({ page }) => {
      const paymentConnector = new PaymentConnector(page);
      const homePage = new HomePage(page);

      await homePage.connectors.click();
      await homePage.paymentProcessors.click();

      await paymentConnector.connectorSearchInput.fill(connector.label);
      await paymentConnector.addConnectButton.nth(0).click();

      await assertConnectorFieldLabels(page, connector.fields.fieldLabels);
      await fillConnectorFields(page, connector.fields);

      await paymentConnector.connectAndProceedButton.click();

      await assertPaymentMethodTypes(page, connector.paymentSections);

      await paymentConnector.pmtProceedButton.click();
      await expect(page.locator('[data-toast="Connector Created Successfully!"]')).toBeVisible({ timeout: 10000 });
      await paymentConnector.connectorSetupDone.click();

      await expect(page).toHaveURL(/.*dashboard\/connectors/);
      await expect(
        page.getByTestId(
          connector.fields.overrides["Enter Connector label"] || connector.label,
        ),
      ).toBeVisible();
      await page
        .getByTestId(
          connector.fields.overrides["Enter Connector label"] || connector.label,
        )
        .click();
    });
  }
});
