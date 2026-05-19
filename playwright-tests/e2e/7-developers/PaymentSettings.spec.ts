import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentSettings } from "../../support/pages/developers/PaymentSettings";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createAuthenticationConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Payment Settings", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test.describe("Navigation, Header and fields", () => {
    test("should display page header and information cards", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(paymentSettings.pageHeader).toBeVisible({ timeout: 10000 });
      await expect(paymentSettings.profileName).toBeVisible();
      await expect(paymentSettings.profileId).toBeVisible();
      await expect(paymentSettings.merchantId).toBeVisible();
      await expect(paymentSettings.paymentResponseHashKey).toBeVisible();
    });
  });

  test.describe("Tabs Navigation", () => {
    test("should display all available tabs", async ({ page }) => {
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

    test("should switch between tabs correctly", async ({ page }) => {
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

    // TODO: Assert clicked tab is highlighted and content of previously active tab is hidden when switching tabs.
  });

  test.describe("Payment Behaviour Tab", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      await homePage.developer.click();
      await homePage.paymentSettings.click();
    });

    test("should display all toggle options", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.collectBillingDetailsToggle).toBeVisible();
      await expect(paymentSettings.collectShippingDetailsToggle).toBeVisible();
      await expect(paymentSettings.autoRetriesToggle).toBeVisible();
      await expect(paymentSettings.manualRetriesToggle).toBeVisible();
      await expect(paymentSettings.extendedAuthorizationToggle).toBeVisible();
      await expect(paymentSettings.alwaysEnableOvercaptureToggle).toBeVisible();
      await expect(paymentSettings.networkTokenizationToggle).toBeVisible();
      await expect(paymentSettings.merchantCategoryCodeDropdown).toBeVisible();
      await expect(paymentSettings.clickToPayToggle).toBeVisible();
      await expect(paymentSettings.paymentMethodBlocking).toBeVisible();
      await expect(paymentSettings.returnUrlInput).toBeVisible();
      await expect(paymentSettings.webhookUrlInput).toBeVisible();
      await expect(paymentSettings.updateButton).toBeVisible();
    });

    test("should allow entering values in form fields", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.fillReturnUrl("https://example.com/return");
      await paymentSettings.fillWebhookUrl("https://example.com/webhook");

      await expect(paymentSettings.returnUrlInput).toHaveValue(
        "https://example.com/return",
      );
      await expect(paymentSettings.webhookUrlInput).toHaveValue(
        "https://example.com/webhook",
      );
    });

    test("should save toggle, form, and dropdown values when Update is clicked", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const toggleLabels = [
        "Manual Retries",
        "Extended Authorization",
        "Always Enable Overcapture",
        "Connector Agnostic",
      ];

      const expectedToggleStates: Record<string, "on" | "off"> = {};
      for (const label of toggleLabels) {
        const toggle = paymentSettings.toggleSwitchByLabel(label);
        await expect(toggle).toBeVisible();
        const initial = await toggle.getAttribute("data-bool-value");
        const expected = initial === "on" ? "off" : "on";
        await toggle.click();
        await expect(toggle).toHaveAttribute("data-bool-value", expected);
        expectedToggleStates[label] = expected;
      }

      const returnUrl = "https://example.com/return";
      const webhookUrl = "https://example.com/webhook";
      const expectedCategory = "Wine producers";

      await paymentSettings.fillReturnUrl(returnUrl);
      await paymentSettings.fillWebhookUrl(webhookUrl);

      await paymentSettings.selectFirstMerchantCategoryCode();
      await expect(
        paymentSettings.buttonByName(expectedCategory),
      ).toBeVisible();

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      // Wait for the PUT /merchant_account response to settle before reload —
      // otherwise reload can race the persisted state and read stale toggles.
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");

      await expect(paymentSettings.returnUrlInput).toHaveValue(returnUrl, {
        timeout: 10000,
      });
      await expect(paymentSettings.webhookUrlInput).toHaveValue(webhookUrl);
      await expect(
        paymentSettings.buttonByName(expectedCategory),
      ).toBeVisible();

      for (const label of toggleLabels) {
        await expect(
          paymentSettings.toggleSwitchByLabel(label),
        ).toHaveAttribute("data-bool-value", expectedToggleStates[label], {
          timeout: 10000,
        });
      }
    });

    test("should save Auto Retries with Max Auto Retries value", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const autoRetriesToggle =
        paymentSettings.toggleSwitchByLabel("Auto Retries");
      const initial = await autoRetriesToggle.getAttribute("data-bool-value");
      if (initial !== "on") {
        await autoRetriesToggle.click();
        await expect(autoRetriesToggle).toHaveAttribute(
          "data-bool-value",
          "on",
        );
      }

      await expect(paymentSettings.maxAutoRetriesInput).toBeVisible();
      await paymentSettings.maxAutoRetriesInput.fill("4");
      await expect(paymentSettings.maxAutoRetriesInput).toHaveValue("4");

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();

      await expect(
        paymentSettings.toggleSwitchByLabel("Auto Retries"),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
      await expect(paymentSettings.maxAutoRetriesInput).toHaveValue("4");
    });

    test("should save Collect billing and shipping details with Always option", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const billingToggle = paymentSettings.toggleSwitchByLabel(
        "Collect billing details from wallets",
      );
      const shippingToggle = paymentSettings.toggleSwitchByLabel(
        "Collect shipping details from wallets",
      );

      const billingInitial =
        await billingToggle.getAttribute("data-bool-value");
      if (billingInitial !== "on") {
        await billingToggle.click();
        await expect(billingToggle).toHaveAttribute("data-bool-value", "on");
      }
      await paymentSettings.radioOption("Always").click();

      const shippingInitial =
        await shippingToggle.getAttribute("data-bool-value");
      if (shippingInitial !== "on") {
        await shippingToggle.click();
        await expect(shippingToggle).toHaveAttribute("data-bool-value", "on");
      }
      // The shipping section's "Always" is the second occurrence of that label
      await paymentSettings.alwaysOption("last").click();

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();

      await expect(
        paymentSettings.toggleSwitchByLabel(
          "Collect billing details from wallets",
        ),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
      await expect(
        paymentSettings.toggleSwitchByLabel(
          "Collect shipping details from wallets",
        ),
      ).toHaveAttribute("data-bool-value", "on");
      // Both "Always" options remain visible because their parent toggles are ON
      await expect(page.getByText("Always", { exact: true })).toHaveCount(2);
    });
  });

  test.describe("Payment Behaviour Tab — Network Tokenization", () => {
    test.beforeEach(async ({ page }) => {
      await page.route("**/dashboard/config/feature*", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        if (json.features) {
          json.features.network_tokenization = true;
        }
        await route.fulfill({ response, json });
      });
      await page.reload();

      const homePage = new HomePage(page);
      await homePage.developer.click();
      await homePage.paymentSettings.click();
    });

    test("should save Network Tokenization toggle when feature flag is enabled", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const ntToggle = paymentSettings.toggleSwitchByLabel(
        "Network Tokenization",
      );
      await expect(ntToggle).toBeVisible();

      const initial = await ntToggle.getAttribute("data-bool-value");
      if (initial !== "on") {
        await ntToggle.click();
        await expect(ntToggle).toHaveAttribute("data-bool-value", "on");
      }

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");

      await expect(
        paymentSettings.toggleSwitchByLabel("Network Tokenization"),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
    });
  });

  test.describe("Payment Behaviour Tab — Click to Pay", () => {
    const connectorLabel = "juspaythreedsserver_default";

    test.beforeEach(async ({ page, context }) => {
      await page.route("**/dashboard/config/feature*", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        if (json.features) {
          json.features.dev_click_to_pay = true;
        }
        await route.fulfill({ response, json });
      });

      const homePage = new HomePage(page);
      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createAuthenticationConnectorAPI(
          merchantId,
          connectorLabel,
          context.request,
        );
      }

      await page.reload();
      await homePage.developer.click();
      await homePage.paymentSettings.click();
    });

    test("should save Click to Pay toggle with selected connector", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const clickToPayToggle =
        paymentSettings.toggleSwitchByLabel("Click to Pay");
      await expect(clickToPayToggle).toBeVisible();

      const initial =
        await clickToPayToggle.getAttribute("data-bool-value");
      if (initial !== "on") {
        await clickToPayToggle.click();
        await expect(clickToPayToggle).toHaveAttribute(
          "data-bool-value",
          "on",
        );
      }

      await expect(paymentSettings.clickToPayConnectorDropdown).toBeVisible();
      await paymentSettings.clickToPayConnectorDropdown.click();
      await paymentSettings.dropdownValueByText(connectorLabel).click();

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");

      await expect(
        paymentSettings.toggleSwitchByLabel("Click to Pay"),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
      await expect(
        paymentSettings.buttonByName(new RegExp(connectorLabel)),
      ).toBeVisible();
    });
  });

  test.describe("3DS Tab", () => {
    test("should save Force 3DS Challenge toggle without a 3DS connector", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.threeDSTab.click();

      const forceChallenge =
        paymentSettings.toggleSwitchByLabel("Force 3DS Challenge");
      const initial = await forceChallenge.getAttribute("data-bool-value");
      if (initial !== "on") {
        await forceChallenge.click();
        await expect(forceChallenge).toHaveAttribute("data-bool-value", "on");
      }

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();
      await paymentSettings.threeDSTab.click();

      await expect(
        paymentSettings.toggleSwitchByLabel("Force 3DS Challenge"),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
    });

    test("should save all fields when a 3DS connector is created", async ({
      page,
      context,
    }) => {
      // This flow chains a connector setup, several toggle/dropdown
      // interactions, an update + reload, and then re-asserts persisted state.
      // On CI the default 30s budget is too tight; one of the retries was
      // killed mid-assertion ("browser has been closed") because the previous
      // attempt was still tearing down. Give the test enough headroom.
      test.setTimeout(120000);

      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      const connectorName = "juspaythreedsserver";
      if (merchantId) {
        await createAuthenticationConnectorAPI(
          merchantId,
          "threeds_tab_connector",
          context.request,
        );
      }
      await page.reload();
      await page.waitForLoadState("networkidle");

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.threeDSTab.click();

      const forceChallenge =
        paymentSettings.toggleSwitchByLabel("Force 3DS Challenge");
      await expect(forceChallenge).toBeVisible();
      const initial = await forceChallenge.getAttribute("data-bool-value");
      if (initial !== "on") {
        await forceChallenge.click();
        await expect(forceChallenge).toHaveAttribute("data-bool-value", "on");
      }

      const requestorUrl = "https://example.com/3ds-requestor";
      const requestorAppUrl = "https://example.com/3ds-requestor-app";

      await paymentSettings.selectFieldDropdown().click();
      await paymentSettings.dropdownValue(connectorName).click();
      await page.keyboard.press("Escape");

      await paymentSettings.threeDsRequestorUrlInput.fill(requestorUrl);
      await paymentSettings.threeDsRequestorAppUrlInput.fill(requestorAppUrl);

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");
      await paymentSettings.threeDSTab.click();

      await expect(
        paymentSettings.toggleSwitchByLabel("Force 3DS Challenge"),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
      await expect(paymentSettings.threeDsRequestorUrlInput).toHaveValue(
        requestorUrl,
      );
      await expect(paymentSettings.threeDsRequestorAppUrlInput).toHaveValue(
        requestorAppUrl,
      );

      // Verify the connector is the selected option in the multi-select
      await paymentSettings.buttonByName("juspaythreedsserver").first().click();
      await expect(paymentSettings.dropdownValue(connectorName)).toHaveAttribute(
        "data-dropdown-value-selected",
        "True",
      );
    });
  });

  test.describe("Acquirer Config Settings", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.threeDSTab.click();
      await paymentSettings.acquirerConfigSettings.click();
    });

    test("should fill all fields, save, and persist after reload", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const merchantName = "Acme Test Merchant";
      const acquirerBin = "123456";
      const acquirerAssignedMerchantId = "acmeMerchant001";
      const acquirerFraudRate = "5";
      const network = "Visa";

      await expect(paymentSettings.acquirerMerchantNameInput).toBeVisible();
      await expect(paymentSettings.acquirerBinInput).toBeVisible();
      await expect(
        paymentSettings.acquirerAssignedMerchantIdInput,
      ).toBeVisible();
      await expect(paymentSettings.acquirerFraudRateInput).toBeVisible();
      await expect(paymentSettings.acquirerNetworkDropdown).toBeVisible();
      await expect(paymentSettings.acquirerSaveButton).toBeVisible();

      await paymentSettings.acquirerMerchantNameInput.fill(merchantName);
      await paymentSettings.acquirerBinInput.fill(acquirerBin);
      await paymentSettings.acquirerAssignedMerchantIdInput.fill(
        acquirerAssignedMerchantId,
      );
      await paymentSettings.acquirerFraudRateInput.fill(acquirerFraudRate);

      await paymentSettings.acquirerNetworkDropdown.click();
      await paymentSettings.dropdownValue(network).click();

      await paymentSettings.acquirerSaveButton.click();
      await expect(paymentSettings.acquirerConfigCreatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();
      await paymentSettings.threeDSTab.click();
      await paymentSettings.acquirerConfigSettings.click();

      await expect(paymentSettings.acquirerResultByTestId("acmemerchant001")).toBeVisible();
      await expect(paymentSettings.acquirerResultByTestId("acmetestmerchant")).toBeVisible();
      await expect(paymentSettings.acquirerResultByTestId("visa")).toBeVisible();
      await expect(paymentSettings.acquirerResultByTestId("123456")).toBeVisible();
      await expect(page.getByText("5%")).toBeVisible();
    });

    test("should show validation errors for each field", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      // Acquirer BIN — too short (< 5 digits)
      await paymentSettings.acquirerBinInput.fill("1234");
      await paymentSettings.acquirerBinInput.blur();
      await expect(paymentSettings.acquirerBinError).toBeVisible();

      // Acquirer BIN — fix to a valid value, error clears
      await paymentSettings.acquirerBinInput.fill("123456");
      await paymentSettings.acquirerBinInput.blur();
      await expect(paymentSettings.acquirerBinError).toHaveCount(0);

      // Acquirer Fraud Rate — out of range (> 100)
      await paymentSettings.acquirerFraudRateInput.fill("150");
      await paymentSettings.acquirerFraudRateInput.blur();
      await expect(paymentSettings.fraudRateError).toBeVisible();

      // Acquirer Fraud Rate — fix to a valid value, error clears
      await paymentSettings.acquirerFraudRateInput.fill("5");
      await paymentSettings.acquirerFraudRateInput.blur();
      await expect(paymentSettings.fraudRateError).toHaveCount(0);

      // Required: Merchant Name — focus then blur empty
      await paymentSettings.acquirerMerchantNameInput.focus();
      await paymentSettings.acquirerMerchantNameInput.blur();
      await expect(paymentSettings.requiredFieldError(0)).toBeVisible();

      // Required: Acquirer Assigned Merchant Id — focus then blur empty
      await paymentSettings.acquirerAssignedMerchantIdInput.focus();
      await paymentSettings.acquirerAssignedMerchantIdInput.blur();
      await expect(paymentSettings.requiredFieldError(1)).toBeVisible();

      // With required fields still empty, Save should remain disabled
      await expect(paymentSettings.acquirerSaveButton).toBeDisabled();
    });
  });

  test.describe("Custom Headers Tab", () => {
    test("should validate fields, save, reload, update again, and persist", async ({
      page,
    }) => {
      test.setTimeout(90000);
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.customHeadersTab.click();

      await expect(paymentSettings.customHeadersKeyInput).toBeVisible();
      await expect(paymentSettings.customHeadersValueInput).toBeVisible();
      await expect(paymentSettings.updateButton).toBeVisible();

      const initialKey = "X-Custom-Header";
      const initialValue = "CustomValue123";

      await paymentSettings.fillCustomHeader(initialKey, initialValue);
      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        initialKey,
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        initialValue,
      );

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");
      await paymentSettings.customHeadersTab.click();

      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        initialKey,
        { timeout: 10000 },
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        "Cu**********23",
      );

      const updatedKey = "X-Updated-Header";
      const updatedValue = "UpdatedValue456";

      await expect(paymentSettings.editButton).toBeVisible();
      await paymentSettings.editButton.click();
      await expect(paymentSettings.proceedButton).toBeVisible();
      await paymentSettings.proceedButton.click();
      await paymentSettings.fillCustomHeader(updatedKey, updatedValue);
      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        updatedKey,
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        updatedValue,
      );

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");
      await paymentSettings.customHeadersTab.click();

      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        updatedKey,
        { timeout: 10000 },
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        "Up***********56",
      );
    });
  });

  test.describe("Metadata Headers Tab", () => {
    test("should validate fields, save, reload, update again, and persist", async ({
      page,
    }) => {
      test.setTimeout(90000);
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.metadataHeadersTab.click();

      await expect(paymentSettings.customMetadataHeadersHeading).toBeVisible();
      await expect(paymentSettings.customHeadersKeyInput).toBeVisible();
      await expect(paymentSettings.customHeadersValueInput).toBeVisible();
      await expect(paymentSettings.updateButton).toBeVisible();

      const initialKey = "metadata-key";
      const initialValue = "metadata-value";

      await paymentSettings.fillCustomHeader(initialKey, initialValue);
      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        initialKey,
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        initialValue,
      );

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");
      await paymentSettings.metadataHeadersTab.click();

      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        initialKey,
        { timeout: 10000 },
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        initialValue,
      );

      const updatedKey = "metadata-key-updated";
      const updatedValue = "metadata-value-updated";

      await expect(paymentSettings.editButton).toBeVisible();
      await paymentSettings.editButton.click();
      await expect(paymentSettings.proceedButton).toBeVisible();
      await paymentSettings.proceedButton.click();
      await paymentSettings.fillCustomHeader(updatedKey, updatedValue);
      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        updatedKey,
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        updatedValue,
      );

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");
      await paymentSettings.metadataHeadersTab.click();

      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        updatedKey,
        { timeout: 10000 },
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        updatedValue,
      );
    });
  });

  test.describe("Payment Link Tab", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.paymentLinkTab.click();
    });

    test("should fill all fields, save, reload, and persist", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.paymentLinkDomainHeading).toBeVisible();
      await expect(paymentSettings.domainNameInput).toBeVisible();
      await expect(paymentSettings.allowedDomainInput).toBeVisible();
      await expect(paymentSettings.updateButton).toBeVisible();
      await expect(paymentSettings.cancelButton).toBeVisible();
      await expect(paymentSettings.updateButton).toBeDisabled();

      const domainName = "example.com";
      const allowedDomain = "https://example.com";

      await paymentSettings.fillPaymentLinkDomain(domainName, allowedDomain);
      await expect(paymentSettings.domainNameInput).toHaveValue(domainName);
      await expect(paymentSettings.allowedDomainInput).toHaveValue(
        allowedDomain,
      );

      await expect(paymentSettings.updateButton).toBeEnabled();
      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();
      await paymentSettings.paymentLinkTab.click();

      await expect(paymentSettings.domainNameInput).toHaveValue(domainName, {
        timeout: 10000,
      });
      await expect(paymentSettings.allowedDomainInput).toHaveValue(
        allowedDomain,
      );
    });

    test("should show validation errors for each field", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.paymentLinkDomainHeading.click();
      // Domain Name — invalid → error appears
      await paymentSettings.domainNameInput.fill("not a valid url");
      await paymentSettings.domainNameInput.blur();
      await expect(paymentSettings.validUrlError).toBeVisible();

      // Domain Name — valid → error clears
      await paymentSettings.domainNameInput.fill("example.com");
      await paymentSettings.domainNameInput.blur();
      await expect(paymentSettings.validUrlError).toHaveCount(0);

      // Allowed Domains — invalid → error appears
      await paymentSettings.allowedDomainInput.fill("not a valid url");
      await paymentSettings.allowedDomainInput.blur();
      await expect(paymentSettings.allowedDomainsError).toBeVisible();

      // Allowed Domains — valid → error clears
      await paymentSettings.allowedDomainInput.fill("https://example.com");
      await paymentSettings.allowedDomainInput.blur();
      await expect(paymentSettings.allowedDomainsError).toHaveCount(0);

      // With both fields valid, Update should be enabled
      await expect(paymentSettings.updateButton).toBeEnabled();
    });
  });
});
