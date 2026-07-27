import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentSettings } from "../../support/pages/developers/PaymentSettings";
import { SurchargeProcessor } from "../../support/pages/connector/SurchargeProcessor";
import { VaultProcessor } from "../../support/pages/connector/VaultProcessor";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createAuthenticationConnectorAPI,
  fillConnectorFields,
} from "../../support/commands";
import { vaultProcessorConfig } from "../../support/fixtures/vaultProcessorConfig";

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

    test("should display Vault and Surcharge tabs when both connectors are configured", async ({
      page,
    }) => {
      test.slow();

      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);
      const vaultProcessor = new VaultProcessor(page);
      const surchargeProcessor = new SurchargeProcessor(page);

      await homePage.connectors.click();
      await homePage.vaultConnectors.click();
      await expect(page).toHaveURL(/.*dashboard\/vault-processor/);

      await expect(vaultProcessor.connectButton.first()).toBeVisible();
      await vaultProcessor.connectButton.first().click();
      await fillConnectorFields(page, vaultProcessorConfig.vgs.fields);
      await vaultProcessor.saveOrConnectOrProceedButton.click();
      await page.waitForLoadState("networkidle");
      await vaultProcessor.doneButton.click();

      await homePage.connectors.click();
      await homePage.surchargeConnectors.click();
      await expect(page).toHaveURL(/.*dashboard\/surcharge-processor/);

      await expect(
        surchargeProcessor.connectNowOrConnectButton,
      ).toBeVisible();
      await surchargeProcessor.connectNowOrConnectButton.click();
      await page.locator('[name*="api_key"]').first().fill("interpayments_test_api_key");
      await surchargeProcessor.connectAndProceedButton.click();
      await surchargeProcessor.doneButton.click();

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(paymentSettings.vaultTab).toBeVisible();
      await expect(paymentSettings.surchargeTab).toBeVisible();
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
          page,
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

      const initial = await clickToPayToggle.getAttribute("data-bool-value");
      if (initial !== "on") {
        await clickToPayToggle.click();
        await expect(clickToPayToggle).toHaveAttribute("data-bool-value", "on");
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

      const forceChallenge = paymentSettings.toggleSwitchByLabel(
        "Force 3DS Challenge",
      );
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
          page,
        );
      }
      await page.reload();
      await page.waitForLoadState("networkidle");

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.threeDSTab.click();

      const forceChallenge = paymentSettings.toggleSwitchByLabel(
        "Force 3DS Challenge",
      );
      await expect(forceChallenge).toBeVisible();
      const initial = await forceChallenge.getAttribute("data-bool-value");
      if (initial !== "on") {
        await forceChallenge.click();
        await expect(forceChallenge).toHaveAttribute("data-bool-value", "on");
      }

      const requestorUrl = "https://example.com/3ds-requestor";
      const requestorAppUrl = "https://example.com/3ds-requestor-app";

      await paymentSettings.selectFieldDropdown().click();
      await page.getByRole('option', { name: 'juspaythreedsserver' }).click();
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
      await page.getByRole('button', { name: 'Select Field1' }).click();
      await expect(
        page.getByRole('option', { name: 'juspaythreedsserver' }).getByRole('checkbox')
      ).toHaveAttribute("data-state", "checked");
    });
  });

  test.describe("Acquirer Config Settings", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.threeDSTab.click();
    });

    test("should show empty state with heading and Acquirer config group button", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.acquirerConfigSettingsHeading).toBeVisible();
      await expect(paymentSettings.noAcquirerConfigsText).toBeVisible();
      await expect(paymentSettings.acquirerConfigGroupButton).toBeVisible();
    });

    test("should keep Add Acquirer modal actions visible and fields scrollable on a short viewport", async ({
      page,
    }) => {
      await page.setViewportSize({ width: 1280, height: 750 });
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.acquirerConfigGroupButton.click();

      const modal = paymentSettings.addAcquirerModal;
      await expect(modal).toBeVisible();
      await expect(
        modal.getByText("Add Acquirer Configuration", { exact: true }),
      ).toBeVisible();

      // Field labels
      await expect(
        modal.getByText("Acquirer merchant name", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Acquirer Merchant ID", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Card Network", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Acquirer BIN", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Acquirer ICA (optional)", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Fraud Rate (%) (optional)", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Acquirer Country (optional)", { exact: false }),
      ).toBeVisible();

      // Inputs
      await expect(
        paymentSettings.acquirerMerchantNameInput(modal),
      ).toBeVisible();
      await expect(
        paymentSettings.acquirerMerchantIdInput(modal),
      ).toBeVisible();
      await expect(paymentSettings.acquirerBinInput(modal)).toBeVisible();
      await expect(paymentSettings.acquirerIcaInput(modal)).toBeVisible();
      await expect(paymentSettings.acquirerFraudRateInput(modal)).toBeVisible();

      // Dropdowns
      await expect(
        paymentSettings.acquirerNetworkDropdownInModal(modal),
      ).toBeVisible();
      await expect(
        paymentSettings.acquirerCountryDropdownInModal(modal),
      ).toBeVisible();

      // Buttons
      await expect(
        paymentSettings.acquirerModalSaveButton(modal),
      ).toBeVisible();
      await expect(
        paymentSettings.acquirerModalCancelButton(modal),
      ).toBeVisible();

      const scrollRegion = paymentSettings.acquirerModalScrollRegion(modal);
      const saveButton = paymentSettings.acquirerModalSaveButton(modal);
      const cancelButton = paymentSettings.acquirerModalCancelButton(modal);
      const countryDropdown =
        paymentSettings.acquirerCountryDropdownInModal(modal);

      await expect(saveButton).toBeInViewport({ ratio: 1 });
      await expect(cancelButton).toBeInViewport({ ratio: 1 });

      const scrollMetrics = await scrollRegion.evaluate((element) => ({
        clientHeight: element.clientHeight,
        scrollHeight: element.scrollHeight,
      }));
      expect(scrollMetrics.scrollHeight).toBeGreaterThan(
        scrollMetrics.clientHeight,
      );

      await scrollRegion.evaluate((element) => {
        element.scrollTop = element.scrollHeight;
      });
      await expect
        .poll(() => scrollRegion.evaluate((element) => element.scrollTop))
        .toBeGreaterThan(0);
      await expect(countryDropdown).toBeInViewport();
      await expect(saveButton).toBeInViewport({ ratio: 1 });
      await expect(cancelButton).toBeInViewport({ ratio: 1 });
    });

    test("should close modal when Cancel is clicked without saving", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.acquirerConfigGroupButton.click();
      const modal = paymentSettings.addAcquirerModal;
      await expect(modal).toBeVisible();

      await paymentSettings.acquirerModalCancelButton(modal).click();
      // Modal hides — empty state remains
      await expect(paymentSettings.noAcquirerConfigsText).toBeVisible();
    });

    test("should show validation errors for BIN and fraud rate in the modal", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.acquirerConfigGroupButton.click();
      const modal = paymentSettings.addAcquirerModal;
      await expect(modal).toBeVisible();

      // BIN too short (< 4 digits)
      await paymentSettings.acquirerBinInput(modal).fill("12");
      await paymentSettings.acquirerBinInput(modal).press("Enter");
      await expect(paymentSettings.acquirerBinError).toBeVisible();

      // BIN valid → error clears
      await paymentSettings.acquirerBinInput(modal).fill("56688");
      await paymentSettings.acquirerBinInput(modal).blur();
      await expect(paymentSettings.acquirerBinError).toHaveCount(0);

      // Fraud rate out of range (> 100)
      await paymentSettings.acquirerFraudRateInput(modal).fill("150");
      await paymentSettings.acquirerFraudRateInput(modal).blur();
      await expect(paymentSettings.fraudRateError).toBeVisible();

      // Fraud rate valid → error clears
      await paymentSettings.acquirerFraudRateInput(modal).fill("25");
      await paymentSettings.acquirerFraudRateInput(modal).blur();
      await expect(paymentSettings.fraudRateError).toHaveCount(0);
    });

    test("should create an acquirer config group and display it as default", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const merchantName = "Acme Test Merchant";
      const merchantId = "acmeMerchant001";
      const network = "Visa";
      const bin = "56688";
      const ica = "12345";
      const fraudRate = "5";

      await paymentSettings.acquirerConfigGroupButton.click();
      const modal = paymentSettings.addAcquirerModal;
      await expect(modal).toBeVisible();

      await paymentSettings.acquirerMerchantNameInput(modal).fill(merchantName);
      await paymentSettings.acquirerMerchantIdInput(modal).fill(merchantId);
      await paymentSettings.acquirerNetworkDropdownInModal(modal).click();
      await paymentSettings.dropdownValue(network).click();
      await paymentSettings.acquirerBinInput(modal).fill(bin);
      await paymentSettings.acquirerIcaInput(modal).fill(ica);
      await paymentSettings.acquirerFraudRateInput(modal).fill(fraudRate);

      await paymentSettings.acquirerModalSaveButton(modal).click();
      await expect(paymentSettings.acquirerCreatedToast).toBeVisible({
        timeout: 10000,
      });

      // Bucket renders with merchant name and a Default tag (only bucket)
      await expect(page.getByText(merchantName, { exact: true })).toBeVisible();
      await expect(paymentSettings.defaultTag().first()).toBeVisible();
    });

    test("should add a new network to an existing acquirer bucket", async ({
      page,
    }) => {
      test.setTimeout(60000);
      const paymentSettings = new PaymentSettings(page);

      // Seed: create initial bucket with Visa
      await paymentSettings.acquirerConfigGroupButton.click();
      const addModal = paymentSettings.addAcquirerModal;
      await paymentSettings
        .acquirerMerchantNameInput(addModal)
        .fill("Seed Merchant");
      await paymentSettings
        .acquirerMerchantIdInput(addModal)
        .fill("seedmerchant1");
      await paymentSettings.acquirerNetworkDropdownInModal(addModal).click();
      await paymentSettings.dropdownValue("Visa").click();
      await paymentSettings.acquirerBinInput(addModal).fill("56688");
      await paymentSettings.acquirerModalSaveButton(addModal).click();
      await expect(paymentSettings.acquirerCreatedToast).toBeVisible({
        timeout: 10000,
      });

      // Expand the accordion to reach the Add New Network button
      await page.getByText("Seed Merchant", { exact: true }).click();
      await expect(paymentSettings.addNewNetworkButton).toBeVisible();
      await paymentSettings.addNewNetworkButton.click();

      const netModal = paymentSettings.addNetworkModal;
      await expect(netModal).toBeVisible();
      await expect(
        netModal.getByText("Add Network Configuration", { exact: true }),
      ).toBeVisible();

      await paymentSettings.acquirerNetworkDropdownInModal(netModal).click();
      await paymentSettings.dropdownValue("Mastercard").click();
      await paymentSettings.acquirerBinInput(netModal).fill("99887");
      await paymentSettings.acquirerModalSaveButton(netModal).click();

      await expect(paymentSettings.networkAddedToast).toBeVisible({
        timeout: 10000,
      });
      await expect(page.getByText("Mastercard", { exact: true })).toBeVisible();
    });

    test("should edit an existing network entry with the network field locked", async ({
      page,
    }) => {
      test.setTimeout(60000);
      const paymentSettings = new PaymentSettings(page);

      // Seed: create initial bucket with Visa BIN 56688
      await paymentSettings.acquirerConfigGroupButton.click();
      const addModal = paymentSettings.addAcquirerModal;
      await paymentSettings
        .acquirerMerchantNameInput(addModal)
        .fill("Edit Merchant");
      await paymentSettings
        .acquirerMerchantIdInput(addModal)
        .fill("editmerchant1");
      await paymentSettings.acquirerNetworkDropdownInModal(addModal).click();
      await paymentSettings.dropdownValue("Visa").click();
      await paymentSettings.acquirerBinInput(addModal).fill("56688");
      await paymentSettings.acquirerModalSaveButton(addModal).click();
      await expect(paymentSettings.acquirerCreatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.getByText("Edit Merchant", { exact: true }).click();
      await paymentSettings.editIconForRow("Visa").click();

      const editModal = paymentSettings.editNetworkModal;
      await expect(editModal).toBeVisible();
      await expect(
        editModal.getByText("Edit Network Configuration", { exact: true }),
      ).toBeVisible();

      // The locked network field renders the current network as button text
      // (buttonText=n.network) — its mere presence proves the field is
      // pre-filled with the existing network. We don't open the dropdown
      // because Escape (the only way to close it without selecting) also
      // closes the surrounding modal in this codebase.
      await expect(
        editModal.getByRole("button", { name: "Visa" }),
      ).toBeVisible();

      // Change BIN and save
      await paymentSettings.acquirerBinInput(editModal).fill("77777");
      await paymentSettings.acquirerModalUpdateButton(editModal).click();

      await expect(paymentSettings.networkUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await expect(page.getByText("77777", { exact: true })).toBeVisible();
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
      await expect(paymentSettings.pageHeader).toBeVisible();
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
