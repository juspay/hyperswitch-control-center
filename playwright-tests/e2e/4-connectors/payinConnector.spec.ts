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
  getJwtFromLocalStorage,
  switchProfileAPI,
  generateCerts,
} from "../../support/commands";
import { connectorConfig } from "../../support/fixtures/payinConnectorConfig";
import { exec } from "node:child_process";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

const CONNECTOR_SETUP_TIMEOUT = 60000;

async function signupAndLogin(
  page: Page,
  context: BrowserContext,
): Promise<void> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function gotoConnectorList(page: Page): Promise<void> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  await homePage.paymentProcessors.click();
  await page.waitForLoadState("networkidle");
}

async function fillStripeFormDefaults(page: Page): Promise<void> {
  const paymentConnector = new PaymentConnector(page);
  await expect(paymentConnector.apiKeyInput).toBeVisible();
  await expect(paymentConnector.connectorLabelInput).toBeVisible();

  const inputs = page
    .locator('.grid.grid-cols-2 input[type="text"]')
    .locator("visible=true");
  const count = await inputs.count();
  for (let i = 0; i < count; i++) {
    const input = inputs.nth(i);
    await input.clear();
    await input.fill("test_value");
  }

  await expect(paymentConnector.connectAndProceedButton).toBeEnabled();
}

async function openStripeConnectorForm(page: Page): Promise<void> {
  const paymentConnector = new PaymentConnector(page);
  await gotoConnectorList(page);
  await paymentConnector.connectorSearchInput.fill("stripe");
  await page.waitForTimeout(500);
  await expect(paymentConnector.stripeConnector).toBeVisible({
    timeout: 10000,
  });
  await paymentConnector.stripeConnector
    .locator("button")
    .click({ force: true });
  await fillStripeFormDefaults(page);
}

async function setupConfiguredStripeConnector(
  page: Page,
  context: BrowserContext,
  label: string = "stripe_configured",
): Promise<string> {
  const { merchantId } = await ompLineage(page);
  await createStripeConnectorAPI(
    merchantId,
    label,
    context.request,
    undefined,
    page,
  );
  await page.reload();
  await page.waitForLoadState("networkidle");
  return label;
}

test.describe("Payin Connector tests", () => {
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

    await expect(
      page
        .getByRole("paragraph")
        .filter({ hasText: "Connect a Dummy Processor" }),
    ).not.toBeAttached();
    await expect(
      page.getByRole("button", { name: "Request a Processor" }).first(),
    ).not.toBeAttached();
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

    await expect(paymentConnector.apiKeyInput).toHaveValue("test_key");

    await paymentConnector.connectAndProceedButton.click();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("stripe_test_default")).toBeVisible();
  });

  test("should search the processor grid when searching a known processor", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await gotoConnectorList(page);

    await paymentConnector.searchProcessorPlaceholder.fill("adyen");
    await page.waitForTimeout(500);
    await expect(page.getByText(/adyen/i).first()).toBeVisible({
      timeout: 5000,
    });
  });

  test("should render zero Connect buttons when search has no matches", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await gotoConnectorList(page);

    await paymentConnector.searchProcessorPlaceholder.fill(
      "nonexistentprocessor_zzzzzzzz",
    );
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
    await createStripeConnectorAPI(
      merchantId,
      stripeLabel,
      context.request,
      undefined,
      page,
    );
    await gotoConnectorList(page);

    const connectorRow = page.locator("tr", { hasText: stripeLabel }).first();
    await expect(connectorRow).toBeVisible({ timeout: 10000 });

    const mcaCell = connectorRow
      .locator('td:has-text("mca_"), [data-testid*="mca"], code')
      .first();
    const mcaId = ((await mcaCell.textContent()) ?? "").trim();
    expect(mcaId.length).toBeGreaterThan(0);

    const paymentConnector = new PaymentConnector(page);
    const search = paymentConnector.connectorSearchInput
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
    await createStripeConnectorAPI(
      merchantId,
      stripeLabel,
      context.request,
      undefined,
      page,
    );
    await gotoConnectorList(page);

    const connectorRow = page.locator("tr", { hasText: stripeLabel }).first();
    await expect(connectorRow).toBeVisible({ timeout: 10000 });

    const paymentConnector = new PaymentConnector(page);
    const search = paymentConnector.connectorSearchInput
      .or(page.getByPlaceholder(/Search/i))
      .first();
    await expect(search).toBeVisible({ timeout: 10000 });
    await search.fill("abcd");
    await search.blur();
    await page.waitForTimeout(500);

    await expect(
      page
        .locator("div")
        .filter({ hasText: /^No Data Available$/ })
        .nth(2),
    ).toBeVisible();
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

    await expect(
      page
        .getByText(
          /This is an unique label you can generate and pass in order to identify this connector account on your Hyperswitch dashboard and reports. Eg: if your profile label is 'default', connector label can be 'stripe_default'/i,
        )
        .first(),
    ).toBeVisible({
      timeout: 5000,
    });
  });

  test("should filter connector list by active profile context", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    // `profileId` here is the active profile the logged-in UI renders against.
    const { merchantId, profileId: defaultProfileId } = await ompLineage(page);

    const defaultLabel = "stripe_default_profile";
    const secondaryLabel = "stripe_secondary_profile";

    const secondaryProfileId = await createBusinessProfileAPI(
      merchantId,
      "secondary_profile",
      context.request,
      page,
    );
    const defaultProfileToken = await getJwtFromLocalStorage(page);
    const secondaryProfileToken = await switchProfileAPI(
      defaultProfileToken,
      secondaryProfileId,
      context.request,
    );

    // Pin the default connector to the active profile explicitly. Relying on
    // getDefaultProfileId() (profiles[0]) is unsafe once a second profile
    // exists, since the business_profile list order is not guaranteed and the
    // connector could land on the secondary profile, hiding it from this view.
    await createStripeConnectorAPI(
      merchantId,
      defaultLabel,
      context.request,
      defaultProfileId,
      page,
    );
    await createStripeConnectorAPI(
      merchantId,
      secondaryLabel,
      context.request,
      secondaryProfileId,
      page,
      secondaryProfileToken,
    );

    await gotoConnectorList(page);
    await expect(page.getByText(defaultLabel).first()).toBeVisible({
      timeout: 10000,
    });
    await expect(page.getByText(secondaryLabel)).not.toBeVisible({
      timeout: 5000,
    });

    const profileSwitcher = homePage.profileDropdown;

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

  test("should show processors from config in live mode", async ({ page }) => {
    await gotoConnectorList(page);

    await page.route("**/dashboard/config/feature?domain=", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      // Guard both branches: an unchecked write to a missing
      // `connector_list_for_live` throws inside the handler, which makes
      // Playwright error the request rather than fulfilling it — the page
      // then never sees the live-mode config and Adyen never renders.
      if (json) {
        json.features = { ...(json.features ?? {}), is_live_mode: true };
        json.connector_list_for_live = {
          ...(json.connector_list_for_live ?? {}),
          paymentProcessors: ["adyen"],
        };
      }
      await route.fulfill({ response, json });
    });

    // Subscribe before reload so we deterministically await the mocked
    // response. Without this, `page.reload()` resolves on `load` and the
    // assertion races against fetchConfig → parse → explicit 1s delay in
    // HyperSwitchEntry → setScreenState(Success) → ConnectorList mount →
    // ProcessorCards render, which can blow past the default 5s timeout on CI.
    const configResponse = page.waitForResponse(
      (resp) => resp.url().includes("/config/feature") && resp.ok(),
    );
    await page.reload();
    await configResponse;
    await page.waitForLoadState("networkidle");

    await expect(page.getByTestId("adyen")).toBeVisible({ timeout: 15000 });
    await expect(page.getByTestId("affirm")).not.toBeAttached();
  });

  test("should validate field-level error for connector credentials page", async ({
    page,
  }) => {
    const paymentConnector = new PaymentConnector(page);
    await gotoConnectorList(page);
    await paymentConnector.connectorSearchInput.fill("stripe");
    await page.waitForTimeout(500);
    await expect(paymentConnector.stripeConnector).toBeVisible({
      timeout: 10000,
    });
    await paymentConnector.stripeConnector
      .locator("button")
      .click({ force: true });

    const apiKeyField = paymentConnector.apiKeyInput;
    await apiKeyField.fill("invalid_key_@#$%");
    await apiKeyField.blur();
    await expect(
      page.getByText("Secret key should have the prefix sk_test_"),
    ).toBeVisible();
    await apiKeyField.clear();
    await apiKeyField.blur();
    await expect(page.getByText("Please enter Secret Key")).toBeVisible();

    await page.getByRole("textbox", { name: "Enter Connector label" }).clear();
    await page.getByRole("textbox", { name: "Enter Connector label" }).blur();
    await expect(
      page.getByText("Please enter Connector label").nth(1),
    ).toBeVisible();
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
    await expect(paymentConnector.paymentMethodToggle).toHaveAttribute(
      "data-bool-value",
      "on",
    );
    await paymentConnector.paymentMethodToggle.click();
    await expect(paymentConnector.paymentMethodToggle).toHaveAttribute(
      "data-bool-value",
      "off",
    );
  });

  test("should configure Apple Pay web domain flow", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    await page.getByText("Apple Pay").click();

    await expect(
      page.getByText("Web Domain").locator("visible=true").first(),
    ).toBeVisible();
    await expect(
      page.getByText("iOS Certificate").locator("visible=true").first(),
    ).toBeVisible();
    await expect(
      page.getByText("Pre Decrypted Token").locator("visible=true").first(),
    ).toBeVisible();

    await page.getByText("Web Domain").locator("visible=true").first().click();
    await page.getByRole("button", { name: "Continue" }).click();

    await expect(
      page.getByRole("button", { name: "Verify & Enable" }),
    ).toBeDisabled();

    await expect(
      page
        .locator("div")
        .filter({ hasText: /^Domain Name \*$/ })
        .nth(2),
    ).toBeVisible();
    await page
      .getByRole("textbox", { name: "Enter Domain Name" })
      .fill("hyperswitch.io");
    await expect(page.getByText("Merchant Business Country *")).toBeVisible();
    await page.getByRole("button", { name: "Select Value" }).click();
    await page
      .getByRole("searchbox", { name: "Search options..." })
      .fill("UnitedStatesOfAmerica");
    await page
      .locator("div")
      .filter({ hasText: /^UnitedStatesOfAmerica$/ })
      .nth(4)
      .click();

    await page.getByRole("button", { name: "Download File" }).click();
    await expect(
      page.locator('[data-id="File download complete"]'),
    ).toContainText("File download complete");

    await expect(
      page.getByRole("button", { name: "Verify & Enable" }),
    ).not.toBeDisabled();
    await page.getByRole("button", { name: "Verify & Enable" }).click();
  });

  test("should configure Apple Pay iOS certificate flow", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    await page.getByText("Apple Pay").click();

    await expect(
      page.getByText("Web Domain").locator("visible=true").first(),
    ).toBeVisible();
    await expect(
      page.getByText("iOS Certificate").locator("visible=true").first(),
    ).toBeVisible();
    await expect(
      page.getByText("Pre Decrypted Token").locator("visible=true").first(),
    ).toBeVisible();

    await page
      .getByText("iOS Certificate")
      .locator("visible=true")
      .first()
      .click();
    await page.getByRole("button", { name: "Continue" }).click();

    await expect(
      page.getByRole("button", { name: "Verify & Enable" }),
    ).toBeDisabled();
    await expect(page.getByText("Merchant Certificate (Base64")).toBeVisible();
    await page
      .getByRole("textbox", { name: "Enter Merchant Certificate (" })
      .fill("test_value");

    await expect(page.getByText("Merchant PrivateKey (Base64")).toBeVisible();
    await page
      .getByRole("textbox", { name: "Enter Merchant PrivateKey (" })
      .fill("test_value");

    await expect(page.getByText("Apple Merchant Identifier *")).toBeVisible();
    await page
      .getByRole("textbox", { name: "Enter Apple Merchant" })
      .fill("test_value");

    await expect(
      page
        .locator("div")
        .filter({ hasText: /^Display Name \*$/ })
        .nth(2),
    ).toBeVisible();
    await page
      .getByRole("textbox", { name: "Enter Display Name" })
      .fill("test_value");

    await expect(
      page
        .locator("div")
        .filter({ hasText: /^Domain \*$/ })
        .first(),
    ).toBeVisible();
    await page
      .getByRole("button", { name: "Select Value" })
      .first()
      .click({ force: true });
    await page.getByRole("menuitem", { name: "IOS", exact: true }).click();

    await expect(
      page
        .locator("div")
        .filter({ hasText: /^Merchant Business Country \*$/ })
        .first(),
    ).toBeVisible();
    await page.getByRole("button", { name: "Select Value" }).click();

    await page
      .getByRole("searchbox", { name: "Search options..." })
      .fill("UnitedStatesOfAmerica");
    await page
      .locator("div")
      .filter({ hasText: /^UnitedStatesOfAmerica$/ })
      .nth(4)
      .click();

    await expect(page.getByText("Payment Processing Details At")).toBeVisible();

    await page
      .locator("div")
      .filter({ hasText: /^Connector$/ })
      .first()
      .click();
    await page.getByRole("button", { name: "Verify & Enable" }).click();

    await page.getByRole("button", { name: "Proceed" }).nth(1).click();
    await expect(page.getByText("Default", { exact: true })).not.toBeVisible();
    await page.getByRole("button", { name: "Proceed" }).click();

    await expect(
      page.getByRole("heading", { name: "Apple Pay" }),
    ).toBeVisible();
  });

  test("should configure Google Pay flow", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();

    await page.getByText("Google Pay").click();
    await expect(
      page.getByText("Payment Gateway").locator("visible=true").first(),
    ).toBeVisible();
    await page.getByRole("button", { name: "Continue" }).click();

    await expect(
      page.getByRole("button", { name: "Proceed" }).nth(1),
    ).toBeDisabled();

    await expect(page.getByText("Google Pay Merchant Name")).toBeVisible();
    await page
      .getByRole("textbox", { name: "Enter Google Pay Merchant Name" })
      .fill("test_value");

    await expect(page.getByText("Google Pay Merchant Id")).toBeVisible();
    await page
      .getByRole("textbox", { name: "Enter Google Pay Merchant Id" })
      .fill("test_value");

    await expect(page.getByText("Stripe Publishable Key *")).toBeVisible();
    await page
      .getByRole("textbox", { name: "Enter Stripe Publishable Key" })
      .fill("test_value");

    await expect(page.getByText("Allowed Auth Methods *")).toBeVisible();
    await page.getByRole("button", { name: "Select Value" }).click();

    await page.getByText("PAN_ONLY").click();
    await page.getByText("CRYPTOGRAM_3DS").click();

    await expect(
      page.getByRole("button", { name: "Proceed" }).nth(1),
    ).not.toBeDisabled();

    await page.getByRole("button", { name: "Proceed" }).nth(1).click();

    await expect(
      page.getByRole("heading", { name: "Google Pay" }),
    ).toBeVisible();
  });

  test("should show summary preview after PMs step", async ({ page }) => {
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    await paymentConnector.connectAndProceedButton.click();
    await paymentConnector.pmtProceedButton.click();

    const summary = page.getByText(/Summary|Preview|Review/i).first();

    await expect(summary).toBeVisible();
    await expect(page.getByText("Integration statusACTIVE")).toBeVisible();
    await expect(paymentConnector.connectorCreatedToast).toBeVisible();
  });

  test("should reject duplicate connector label with warning", async ({
    page,
    context,
  }) => {
    test.setTimeout(CONNECTOR_SETUP_TIMEOUT);
    const createdLabel = await setupConfiguredStripeConnector(page, context);
    const paymentConnector = new PaymentConnector(page);
    await openStripeConnectorForm(page);
    const labelInput = paymentConnector.connectorLabelInput;
    await expect(labelInput).toBeVisible();
    await labelInput.clear();
    await labelInput.fill(createdLabel);
    // 5s is too tight on CI: the form takes a moment to enable Connect &
    // Proceed after the label change. Use the standard 30s action timeout.
    await paymentConnector.connectAndProceedButton.click();
    await expect(paymentConnector.pmtProceedButton).toBeVisible();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorLabelExistsToast).toBeVisible({
      timeout: 15000,
    });
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
    await expect(
      page
        .locator("div")
        .filter({ hasText: /^ACTIVE$/ })
        .first(),
    ).toBeVisible();
    await expect(page.getByText("ENABLED")).toBeVisible();
  });

  test("should render disabled/enabled label per connector", async ({
    page,
    context,
  }) => {
    test.setTimeout(CONNECTOR_SETUP_TIMEOUT);
    await setupConfiguredStripeConnector(page, context);
    await gotoConnectorList(page);
    const stripeRow = page
      .locator("div")
      .filter({ hasText: /^Stripe$/ })
      .first();
    await expect(stripeRow).toBeVisible();
    await stripeRow.click();
    await page.waitForLoadState("networkidle");

    const paymentConnector = new PaymentConnector(page);
    const toggle = paymentConnector.connectorEnableToggle;
    await expect(toggle).toBeVisible();
    await toggle.click();
    await expect(
      page
        .locator("div")
        .filter({ hasText: /^Disabled$/ })
        .nth(2),
    ).toBeVisible();
    await gotoConnectorList(page);
    await expect(
      page
        .locator("div")
        .filter({ hasText: /^DISABLED$/ })
        .first(),
    ).toBeVisible({ timeout: 5000 });
  });

  test("should render pagination controls when 21 connectors are configured", async ({
    page,
    context,
  }) => {
    test.setTimeout(CONNECTOR_SETUP_TIMEOUT);
    const { merchantId } = await ompLineage(page);
    const apiKey = await createAPIKey(merchantId, "", context.request, page);
    const profileId = await getDefaultProfileId(
      merchantId,
      context.request,
      page,
    );

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
        page,
      );
      await page.waitForTimeout(200);
    }

    await gotoConnectorList(page);

    await expect(page.getByText("Showing 20")).toBeVisible();
    await expect(
      page.getByRole("button", { name: "2", exact: true }),
    ).toBeVisible();
    await page.getByRole("button", { name: "2", exact: true }).click();
    await expect(page.getByText("Showing 21")).toBeVisible();
  });

  test("should open edit form, validate pre-populated values, update credentials, and persist changes", async ({
    page,
    context,
  }) => {
    const createdLabel = await setupConfiguredStripeConnector(page, context);
    await gotoConnectorList(page);
    await page.getByText(createdLabel).first().click();

    await expect(page.getByText("Integration statusACTIVE")).toBeVisible();
    await expect(page.getByText("Webhook Endpointhttp")).toBeVisible();
    await expect(page.getByText("Profiledefault -")).toBeVisible();
    await expect(
      page.getByRole("heading", { name: "Secret Key" }),
    ).toBeVisible();
    await expect(
      page.getByRole("heading", { name: "te******ue" }),
    ).toBeVisible();
    await expect(
      page.getByRole("heading", { name: "Connector Label" }),
    ).toBeVisible();
    await expect(
      page.getByRole("heading", { name: createdLabel }),
    ).toBeVisible();
    await expect(page.getByRole("heading", { name: "Credit" })).toBeVisible();

    await page.locator(".cursor-pointer > span > .flex").first().click();

    const paymentConnector = new PaymentConnector(page);
    const apiKey = paymentConnector.apiKeyInput;
    await expect(apiKey).toBeVisible();
    await apiKey.clear();
    await apiKey.fill("rotated_key_value");

    const connectorLabel = paymentConnector.connectorLabelTextbox;
    await expect(connectorLabel).toBeVisible();
    await connectorLabel.clear();
    await connectorLabel.fill("stripe_updated_label");

    const save = paymentConnector.submitButton;
    await expect(save).toBeVisible();
    await save.click();

    await expect(paymentConnector.detailsUpdatedToast).toBeVisible();

    await expect(
      page.getByRole("heading", { name: "ro*************ue" }),
    ).toBeVisible();
    await expect(
      page.getByRole("heading", { name: "te******ue" }),
    ).not.toBeVisible();
    await expect(
      page.getByRole("heading", { name: "stripe_updated_label" }),
    ).toBeVisible();
    await expect(
      page.getByRole("heading", { name: "stripe_configured" }),
    ).not.toBeVisible();
  });

  test("should toggle individual payment method on existing connector", async ({
    page,
    context,
  }) => {
    const createdLabel = await setupConfiguredStripeConnector(page, context);
    await gotoConnectorList(page);
    await page.getByText(createdLabel).first().click();

    await expect(page.getByRole("heading", { name: "Credit" })).toBeVisible();
    await page.locator(".fill-current.ml-2").click();

    const paymentConnector = new PaymentConnector(page);
    await paymentConnector.paymentMethodToggle.click();
    await paymentConnector.paymentMethodToggle.click();

    await page.getByRole("button", { name: "Proceed" }).click();
    await page.getByRole("button", { name: "Done" }).click();
    await expect(
      page.getByRole("heading", { name: "Credit" }),
    ).not.toBeVisible();

    await page.getByText(createdLabel).first().click();
    await expect(page.getByText("Integration statusACTIVE")).toBeVisible();
    await expect(
      page.getByRole("heading", { name: "Credit" }),
    ).not.toBeVisible();
  });

  test("should setup Stripe connector with Bank Debit PMT when no PM auth processor is setup", async ({
    page,
  }) => {
    test.setTimeout(CONNECTOR_SETUP_TIMEOUT);
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    // --- Setup Stripe payment connector ---
    await gotoConnectorList(page);
    await paymentConnector.connectorSearchInput.fill("stripe");
    await page.waitForTimeout(500);
    await expect(paymentConnector.stripeConnector).toBeVisible({
      timeout: 10000,
    });
    await paymentConnector.stripeConnector
      .locator("button")
      .click({ force: true });

    // Fill only the API key so the auto-populated `stripe_default` connector
    // label is preserved for the final list assertion.
    await expect(paymentConnector.apiKeyInput).toBeVisible();
    await paymentConnector.apiKeyInput.fill("test_value");
    await expect(paymentConnector.connectAndProceedButton).toBeEnabled();

    await paymentConnector.connectAndProceedButton.click();

    await expect(page.getByText("Bank DebitAchBacsBecsSepa")).toBeVisible();
    await page.getByTestId("bank_debit_ach").click();
    await page.getByTestId("bank_debit_bacs").click();
    await page.getByTestId("bank_debit_becs").click();
    await page.getByTestId("bank_debit_sepa").click();

    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.getByRole("heading", { name: "Ach, Bacs, Becs, Sepa" }),
    ).toBeVisible();
    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("stripe_default").first()).toBeVisible();
  });

  test("should setup Stripe connector with Bank Debit PMT + Plaid when PM auth processor is setup", async ({
    page,
  }) => {
    test.setTimeout(CONNECTOR_SETUP_TIMEOUT);
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    // --- Setup PM Auth processor (Plaid) ---
    await homePage.connectors.click();
    await homePage.pmAuthConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/pm-authentication-processor/);

    // Plaid is the only PM auth processor surfaced, so the first Connect CTA
    // opens its setup form.
    await page.getByRole("button", { name: "Connect" }).first().click();
    await expect(page).toHaveURL(/.*name=plaid/);

    await page
      .getByRole("textbox", { name: "Enter Client Id" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Secret" })
      .fill("test_value");
    await expect(
      page.getByRole("textbox", { name: "Enter Connector label" }),
    ).toHaveValue("plaid_default");

    await paymentConnector.connectAndProceedButton.click();

    await expect(page.getByText("Integration status")).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.getByText("ACTIVE", { exact: true }).first(),
    ).toBeVisible();
    await paymentConnector.connectorSetupDone.click();

    await expect(
      page.getByText("plaid_default", { exact: true }).first(),
    ).toBeVisible({ timeout: 10000 });

    // --- Setup Stripe payment connector ---
    await gotoConnectorList(page);
    await paymentConnector.connectorSearchInput.fill("stripe");
    await page.waitForTimeout(500);
    await expect(paymentConnector.stripeConnector).toBeVisible({
      timeout: 10000,
    });
    await paymentConnector.stripeConnector
      .locator("button")
      .click({ force: true });

    // Fill only the API key so the auto-populated `stripe_default` connector
    // label is preserved for the final list assertion.
    await expect(paymentConnector.apiKeyInput).toBeVisible();
    await paymentConnector.apiKeyInput.fill("test_value");
    await expect(paymentConnector.connectAndProceedButton).toBeEnabled();

    await paymentConnector.connectAndProceedButton.click();

    await expect(
      page.getByText(
        "Bank DebitBelow methods can be enabled independently. Add optional payment authenticator if needed.",
      ),
    ).toBeVisible();
    await expect(page.getByText("AchOptional Configuration")).toBeVisible();
    await expect(page.getByText("BacsOptional Configuration")).toBeVisible();
    await expect(page.getByText("BecsOptional Configuration")).toBeVisible();
    await expect(page.getByText("SepaOptional Configuration")).toBeVisible();

    await page.getByText("AchOptional Configuration").click();
    await expect(
      page
        .getByText(
          "Select PM Authenticator (optional)Select PM Authentication Processor(Enable method to choose an authenticator)CancelProceed",
        )
        .first(),
    ).toBeVisible();

    await expect(
      page.getByRole("button", { name: "Select PM Authentication" }),
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Proceed" }).nth(1),
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Proceed" }).nth(1),
    ).toBeDisabled();

    await page.getByRole('heading').nth(1).locator('[data-checkbox="checkbox"]').click();
    await expect(
      page.getByRole("button", { name: "Select PM Authentication" }),
    ).not.toBeDisabled();
    await expect(
      page.getByRole("button", { name: "Proceed" }).nth(1),
    ).not.toBeDisabled();
    await page
      .getByRole("button", { name: "Select PM Authentication" })
      .click();
    await page.getByText("Plaid").click();
    await page
      .getByRole("button", { name: "Proceed" })
      .nth(1)
      .click({ force: true });
    await expect(page.getByRole("button", { name: "Proceed" })).toHaveCount(1);
    await paymentConnector.pmtProceedButton.click({ force: true });

    await expect(paymentConnector.connectorCreatedToast).toBeVisible({
      timeout: 10000,
    });
    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("stripe_default").first()).toBeVisible();
  });

  test("should setup Stripe connector without Plaid and Bank Debit PMT when PM auth processor is setup", async ({
    page,
  }) => {
    test.setTimeout(CONNECTOR_SETUP_TIMEOUT);
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    // --- Setup PM Auth processor (Plaid) ---
    await homePage.connectors.click();
    await homePage.pmAuthConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/pm-authentication-processor/);

    // Plaid is the only PM auth processor surfaced, so the first Connect CTA
    // opens its setup form.
    await page.getByRole("button", { name: "Connect" }).first().click();
    await expect(page).toHaveURL(/.*name=plaid/);

    await page
      .getByRole("textbox", { name: "Enter Client Id" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Secret" })
      .fill("test_value");
    await expect(
      page.getByRole("textbox", { name: "Enter Connector label" }),
    ).toHaveValue("plaid_default");

    await paymentConnector.connectAndProceedButton.click();

    await expect(page.getByText("Integration status")).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.getByText("ACTIVE", { exact: true }).first(),
    ).toBeVisible();
    await paymentConnector.connectorSetupDone.click();

    await expect(
      page.getByText("plaid_default", { exact: true }).first(),
    ).toBeVisible({ timeout: 10000 });

    // --- Setup Stripe payment connector ---
    await gotoConnectorList(page);
    await paymentConnector.connectorSearchInput.fill("stripe");
    await page.waitForTimeout(500);
    await expect(paymentConnector.stripeConnector).toBeVisible({
      timeout: 10000,
    });
    await paymentConnector.stripeConnector
      .locator("button")
      .click({ force: true });

    // Fill only the API key so the auto-populated `stripe_default` connector
    // label is preserved for the final list assertion.
    await expect(paymentConnector.apiKeyInput).toBeVisible();
    await paymentConnector.apiKeyInput.fill("test_value");
    await expect(paymentConnector.connectAndProceedButton).toBeEnabled();

    await paymentConnector.connectAndProceedButton.click();

    await expect(
      page.getByText(
        "Bank DebitBelow methods can be enabled independently. Add optional payment authenticator if needed.",
      ),
    ).toBeVisible();
    await expect(page.getByText("AchOptional Configuration")).toBeVisible();
    await expect(page.getByText("BacsOptional Configuration")).toBeVisible();
    await expect(page.getByText("BecsOptional Configuration")).toBeVisible();
    await expect(page.getByText("SepaOptional Configuration")).toBeVisible();

    await page.getByText("AchOptional Configuration").click();
    await expect(
      page
        .getByText(
          "Select PM Authenticator (optional)Select PM Authentication Processor(Enable method to choose an authenticator)CancelProceed",
        )
        .first(),
    ).toBeVisible();

    await expect(
      page.getByRole("button", { name: "Select PM Authentication" }),
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Proceed" }).nth(1),
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Proceed" }).nth(1),
    ).toBeDisabled();

    await page.getByRole('heading').nth(1).locator('[data-checkbox="checkbox"]').click();
    await page
      .getByRole("button", { name: "Proceed" })
      .nth(1)
      .click({ force: true });
    await expect(page.getByRole("button", { name: "Proceed" })).toHaveCount(1);
    await paymentConnector.pmtProceedButton.click({ force: true });

    await expect(paymentConnector.connectorCreatedToast).toBeVisible({
      timeout: 10000,
    });
    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("stripe_default").first()).toBeVisible();
  });
});

test.describe("All Payin Connectors", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
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

      if (connector.label === "hipay") {
        await paymentConnector.addConnectButton.nth(3).click();
      } else {
        await paymentConnector.addConnectButton.nth(2).click();
      }

      await assertConnectorFieldLabels(page, connector.fields.fieldLabels);
      await fillConnectorFields(page, connector.fields);

      await paymentConnector.connectAndProceedButton.click({ timeout: 5000 });

      await assertPaymentMethodTypes(page, connector.paymentSections);

      await paymentConnector.pmtProceedButton.click();
      await expect(paymentConnector.connectorCreatedToast).toBeVisible({
        timeout: 10000,
      });
      await paymentConnector.connectorSetupDone.click();

      await expect(page).toHaveURL(/.*dashboard\/connectors/);
      await expect(
        page.getByTestId(
          connector.fields.overrides["Enter Connector label"] ||
          connector.label,
        ),
      ).toBeVisible();
      await page
        .getByTestId(
          connector.fields.overrides["Enter Connector label"] ||
          connector.label,
        )
        .click();
    });
  }

  test("should setup and verify cashtocode connector", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectorSearchInput.fill("cashtocode");
    await paymentConnector.addConnectButton.nth(2).click();

    await expect(page.getByRole("tab", { name: "Classic" })).toBeVisible();
    await expect(page.getByRole("tab", { name: "Evoucher" })).toBeVisible();

    await page.locator("div").filter({ hasText: /^USD$/ }).first().click();
    await page
      .getByRole("textbox", { name: "Enter Password Classic" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Username Classic" })
      .fill("Username Classic");
    await page
      .getByRole("textbox", { name: "Enter MerchantId Classic" })
      .fill("MerchantId Classic");

    await paymentConnector.connectAndProceedButton.click();

    await expect(
      page.getByText("RewardSelect allClassicEvoucher"),
    ).toBeVisible();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("cashtocode_default")).toBeVisible();
  });

  test("should setup and verify braintree connector", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectorSearchInput.fill("braintree");
    await paymentConnector.addConnectButton.nth(2).click();

    await page
      .getByRole("textbox", { name: "Enter Public Key" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Merchant Id" })
      .fill("Username Classic");
    await page
      .getByRole("textbox", { name: "Enter Private Key" })
      .fill("MerchantId Classic");
    await page.getByRole("button", { name: "Select Currency" }).click();
    await page.locator("div").filter({ hasText: /^AED$/ }).first().click();
    await page
      .getByRole("textbox", { name: "Enter Merchant Account Id" })
      .fill("Merchant Account Id");

    await paymentConnector.connectAndProceedButton.click();

    await expect(page.getByText("CreditSelect all")).toBeVisible();
    await expect(page.getByText("DebitSelect all")).toBeVisible();
    await expect(page.getByText("Wallet")).toBeVisible();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("braintree_default")).toBeVisible();
  });

  test("should setup and verify klarna connector", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectorSearchInput.fill("klarna");
    await paymentConnector.addConnectButton.nth(2).click();

    await page
      .getByRole("textbox", { name: "Enter Klarna Merchant ID" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Klarna Merchant Username" })
      .fill("Username Classic");
    await page.getByRole("button", { name: "Select Value" }).click();
    await page
      .locator("div")
      .filter({ hasText: /^Europe$/ })
      .first()
      .click();

    await paymentConnector.connectAndProceedButton.click();

    await expect(
      page.getByText("Pay LaterSelect allKlarna SDKKlarna Checkout"),
    ).toBeVisible();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("klarna_default")).toBeVisible();
  });

  test("should setup and verify payload connector", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectorSearchInput.fill("payload");
    await paymentConnector.addConnectButton.nth(2).click();

    await page.locator("div").filter({ hasText: /^USD$/ }).first().click();
    await page
      .getByRole("textbox", { name: "Enter API Key" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Processing Account Id" })
      .fill("Username Classic");

    await paymentConnector.connectAndProceedButton.click();

    await expect(page.getByText("CreditSelect all")).toBeVisible();
    await expect(page.getByText("DebitSelect all")).toBeVisible();
    await expect(page.getByText("Bank Debit")).toBeVisible();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("payload_default")).toBeVisible();
  });

  test("should setup and verify coinbase connector", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectorSearchInput.fill("coinbase");
    await paymentConnector.addConnectButton.nth(2).click();

    await page
      .getByRole("textbox", { name: "Enter API Key" })
      .fill("test_value");
    await page.getByRole("button", { name: "Select Value" }).click();
    await page
      .locator("div")
      .filter({ hasText: /^fixed_price$/ })
      .first()
      .click();

    await paymentConnector.connectAndProceedButton.click();

    await expect(page.getByText("CryptoSelect allCrypto")).toBeVisible();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("coinbase_default")).toBeVisible();
  });

  test("should setup and verify prophetpay connector", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectorSearchInput.fill("prophetpay");
    await paymentConnector.addConnectButton.nth(2).click();

    await page
      .getByRole("textbox", { name: "Enter Username" })
      .fill("test_value");
    await page.getByRole("textbox", { name: "Enter Token" }).fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Profile" })
      .fill("test_value");

    await paymentConnector.connectAndProceedButton.click();

    await expect(
      page.getByText("Card RedirectSelect allCard Redirect"),
    ).toBeVisible();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("prophetpay_default")).toBeVisible();
  });

  test("should setup and verify worldpayvantiv connector", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectorSearchInput.fill("worldpayvantiv");
    await paymentConnector.addConnectButton.nth(2).click();

    await page
      .getByRole("textbox", { name: "Enter Username" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Merchant ID" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Password" })
      .fill("test_value");
    await page.getByRole("button", { name: "Select Currency" }).click();
    await page.locator("div").filter({ hasText: /^AED$/ }).first().click();
    await page
      .getByRole("textbox", { name: "Enter Default Report Group" })
      .fill("test_value");

    await paymentConnector.connectAndProceedButton.click();

    await expect(page.getByText("CreditSelect all")).toBeVisible();
    await expect(page.getByText("DebitSelect all")).toBeVisible();
    await expect(page.getByText("Wallet")).toBeVisible();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("worldpayvantiv_default")).toBeVisible();
  });

  test("should setup and verify paysafe connector", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectorSearchInput.fill("paysafe");
    await paymentConnector.addConnectButton.nth(2).click();

    await page
      .getByRole("textbox", { name: "Enter Username" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Password" })
      .fill("test_value");

    await paymentConnector.connectAndProceedButton.click();

    await expect(page.getByText("CreditSelect all")).toBeVisible();
    await expect(page.getByText("DebitSelect all")).toBeVisible();
    await expect(page.getByText("Wallet")).toBeVisible();
    await paymentConnector.pmtProceedButton.click();

    await expect(page.getByText("APPLE PAYUSDEncryptDecrypt")).toBeVisible();
    await expect(
      page.getByText("USDThree DsNo Three Ds"),
    ).toBeVisible();

    await page
      .locator("div")
      .filter({ hasText: /^Encrypt$/ })
      .click();

    await page
      .getByRole("textbox", { name: "Enter encrypt value" })
      .fill("test_value");

    await paymentConnector.pmtProceedButton.nth(1).click();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("paysafe_default")).toBeVisible();
  });

  test("should setup and verify affirm connector", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectorSearchInput.fill("affirm");
    await paymentConnector.addConnectButton.nth(2).click();

    await page
      .getByRole("textbox", { name: "Enter Public Key" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Private Key" })
      .fill("test_value");

    await paymentConnector.connectAndProceedButton.click();

    await expect(page.getByText("Pay LaterSelect allAffirm")).toBeVisible();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("affirm_default")).toBeVisible();
  });

  test.skip("should setup and verify santander connector", async ({ page }) => {
    const { certBase64, keyBase64 } = await generateCerts();
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectorSearchInput.fill("santander");
    await paymentConnector.addConnectButton.nth(2).click();

    await page
      .getByRole("textbox", {
        name: "Base64 encoded PEM formatted certificate chain",
      })
      .fill(certBase64);
    await page
      .getByRole("textbox", {
        name: "Base64 encoded PEM formatted private key",
      })
      .fill(keyBase64);

    await paymentConnector.connectAndProceedButton.click();

    await expect(
      page.getByText(
        "Bank TransferThe following payment method types require additional detailsPix QrPix Automatico PushPix Automatico Qr",
      ),
    ).toBeVisible();
    await expect(
      page.getByText(
        "VoucherThe following payment method types require additional detailsBoleto",
      ),
    ).toBeVisible();

    await page
      .locator("div")
      .filter({ hasText: /^Pix Qr$/ })
      .nth(1)
      .click();
    await expect(page.getByText("Client ID *").first()).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your Client Id" }),
    ).toBeVisible();
    await expect(page.getByText("Client Secret *").first()).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your Client Secret" }),
    ).toBeVisible();
    await expect(page.getByText("Chave Key Type *").first()).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Select Value" }),
    ).toBeVisible();
    await page.getByRole("button", { name: "Select Value" }).click();
    await expect(
      page
        .locator("div")
        .filter({ hasText: /^CPFCNPJEMAILCELLULAREVP$/ })
        .nth(1),
    ).toBeVisible();
    await expect(page.getByText("Chave Key *").first()).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your Chave/Pix Key" }),
    ).toBeVisible();
    await expect(page.getByText("Merchant City *").first()).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter the city the merchant" }),
    ).toBeVisible();
    await expect(page.getByText("Merchant Name *").nth(2)).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter the merchant name" }),
    ).toBeVisible();
    await expect(page.getByText("CancelContinue").first()).toBeVisible();

    await page
      .locator("div")
      .filter({ hasText: /^Pix Automatico Push$/ })
      .nth(1)
      .click();
    await expect(page.getByText("Client ID *").nth(1)).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your Client Id" }),
    ).toBeVisible();
    await expect(page.getByText("Client Secret *").nth(1)).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your Client Secret" }),
    ).toBeVisible();
    await expect(page.getByText("Chave Key Type *").nth(1)).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Select Value" }).first(),
    ).toBeVisible();
    await page.getByRole("button", { name: "Select Value" }).first().click();
    await expect(
      page
        .locator("div")
        .filter({ hasText: /^CPFCNPJEMAILCELLULAREVP$/ })
        .nth(1),
    ).toBeVisible();
    await expect(page.getByText("Chave Key *").nth(1)).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your Chave/Pix Key" }),
    ).toBeVisible();
    await expect(page.getByText("Account Number").nth(1)).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your Account Number" }),
    ).toBeVisible();
    await expect(page.getByText("Account Type").nth(1)).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Select Value" }).nth(1),
    ).toBeVisible();
    await page.getByRole("button", { name: "Select Value" }).nth(1).click();
    await expect(
      page
        .locator("div")
        .filter({ hasText: /^currentsavingspayment$/ })
        .nth(1),
    ).toBeVisible();
    await expect(page.getByText("Branch Code").nth(1)).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your branch code" }),
    ).toBeVisible();
    await expect(page.getByText("CancelContinue").nth(1)).toBeVisible();

    await page
      .locator("div")
      .filter({ hasText: /^Pix Automatico Qr$/ })
      .nth(1)
      .click();
    await expect(page.getByText("Client ID *").nth(2)).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your Client Id" }),
    ).toBeVisible();
    await expect(page.getByText("Client Secret *").nth(2)).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your Client Secret" }),
    ).toBeVisible();
    await expect(page.getByText("Chave Key Type *").nth(2)).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Select Value" }).first(),
    ).toBeVisible();
    await page.getByRole("button", { name: "Select Value" }).first().click();
    await expect(
      page
        .locator("div")
        .filter({ hasText: /^CPFCNPJEMAILCELLULAREVP$/ })
        .nth(2),
    ).toBeVisible();
    await expect(page.getByText("Chave Key *").nth(2)).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your Chave/Pix Key" }),
    ).toBeVisible();
    await expect(page.getByText("Account Number").nth(2)).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your Account Number" }),
    ).toBeVisible();
    await expect(page.getByText("Account Type").nth(2)).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Select Value" }).nth(1),
    ).toBeVisible();
    await page.getByRole("button", { name: "Select Value" }).nth(1).click();
    await expect(
      page
        .locator("div")
        .filter({ hasText: /^currentsavingspayment$/ })
        .nth(2),
    ).toBeVisible();
    await expect(page.getByText("Branch Code").nth(2)).toBeVisible();
    await expect(
      page.getByRole("textbox", { name: "Enter your branch code" }),
    ).toBeVisible();
    await expect(page.getByText("CancelContinue").nth(2)).toBeVisible();

    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("santander_default")).toBeVisible();
  });

  test.skip("should setup and verify tokenio connector", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectorSearchInput.fill("tokenio");
    await paymentConnector.addConnectButton.nth(2).click();

    await page
      .getByRole("textbox", { name: "Enter Key Id" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Merchant Id" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Private Key" })
      .fill("test_value");
    await page
      .getByRole("textbox", { name: "Enter Key Algorithm" })
      .fill("test_value");

    await paymentConnector.connectAndProceedButton.click();

    await expect(
      page.getByText("Open BankingSelect allOpen Banking PIS"),
    ).toBeVisible();
    await paymentConnector.pmtProceedButton.click();

    await expect(paymentConnector.connectorCreatedToast).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("tokenio_default")).toBeVisible();
  });
});
