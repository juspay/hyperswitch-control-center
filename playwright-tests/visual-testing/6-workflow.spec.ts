import { test, expect, type Page, type BrowserContext } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  mockV2MerchantList,
  createSurchargeAPI,
  createThreeDsExemptionAPI,
  createDummyConnectorAPI,
  createPayoutConnectorAPI,
} from "../support/commands";
import { HomePage } from "../support/pages/homepage/HomePage";
import { Surcharge } from "../support/pages/workflow/Surcharge";
import { ThreeDSExemptionManager } from "../support/pages/workflow/ThreeDSExemptionManager";
import { PaymentRouting } from "../support/pages/workflow/paymentRouting/PaymentRouting";
import { RuleBasedConfiguration } from "../support/pages/workflow/paymentRouting/RuleBasedConfiguration";
import { AuthRateBasedConfiguration } from "../support/pages/workflow/paymentRouting/AuthRateBasedConfiguration";
import { DefaultFallback } from "../support/pages/workflow/paymentRouting/DefaultFallback";
import { VolumeBasedConfiguration } from "../support/pages/workflow/paymentRouting/VolumeBasedConfiguration";
import { PayoutRouting } from "../support/pages/workflow/payoutRouting/PayoutRouting";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// FeatureFlagUtils.res reads `threeds_exemption` off the dashboard config.
// The 3DS Exemption menu is gated behind it, so the flag must be flipped ON
// BEFORE loginUI navigates (the initial `/dashboard/config/feature` fetch).
const enableThreeDsExemptionFlag = async (page: Page): Promise<void> => {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    json.features = { ...(json.features ?? {}), threeds_exemption: true };
    await route.fulfill({ response, json });
  });
};

// Reads the per-run merchant id from the sidebar (only known post-login) and
// seeds a dummy payment connector against it, so the routing setup flows land
// on the real configuration screen instead of the "configure a connector"
// guard.
const seedConnector = async (
  page: Page,
  context: BrowserContext,
  label: string,
): Promise<void> => {
  const homePage = new HomePage(page);
  await homePage.merchantID
    .nth(0)
    .waitFor({ state: "visible", timeout: 20000 });
  const merchantId = (await homePage.merchantID.nth(0).textContent())?.trim();
  if (!merchantId) {
    throw new Error("Routing visual test: could not read merchant id");
  }
  await createDummyConnectorAPI(merchantId, label, context.request, page);
};

// Drives the volume-based UI flow to create and activate one routing
// configuration, so the Configuration History tab has a row to render and
// open. Mirrors the e2e helper in PaymentRouting.spec.ts.
const createActiveVolumeConfig = async (
  page: Page,
  context: BrowserContext,
  configName: string,
): Promise<void> => {
  const homePage = new HomePage(page);
  const paymentRouting = new PaymentRouting(page);
  const volume = new VolumeBasedConfiguration(page);

  await seedConnector(page, context, "stripe_test_history");

  await homePage.workflow.click();
  await homePage.routing.click();
  await paymentRouting.volumeBasedRoutingSetupButton.click();
  await page.waitForURL(/.*routing\/volume/, { timeout: 15000 });

  await volume.configurationNameInput.clear();
  await volume.configurationNameInput.fill(configName);
  await volume.connectorDropdown.click();
  await volume.connectorOption("stripe_test_history").click();
  await volume.configureRuleButton.click();
  await volume.saveAndActivateRuleButton.click();

  await expect(paymentRouting.dataToast("Successfully activated!")).toBeVisible(
    {
      timeout: 15000,
    },
  );
};

// Payout equivalents of the helpers above. Payout routing seeds an Adyen
// payout connector (createPayoutConnectorAPI) and its volume setup lands on
// /payoutrouting/volume.
const seedPayoutConnector = async (
  page: Page,
  context: BrowserContext,
  label: string,
): Promise<void> => {
  const homePage = new HomePage(page);
  await homePage.merchantID
    .nth(0)
    .waitFor({ state: "visible", timeout: 20000 });
  const merchantId = (await homePage.merchantID.nth(0).textContent())?.trim();
  if (!merchantId) {
    throw new Error("Payout routing visual test: could not read merchant id");
  }
  await createPayoutConnectorAPI(merchantId, label, context.request, page);
};

const createActivePayoutVolumeConfig = async (
  page: Page,
  context: BrowserContext,
  configName: string,
): Promise<void> => {
  const homePage = new HomePage(page);
  const payoutRouting = new PayoutRouting(page);
  const volume = new VolumeBasedConfiguration(page);

  await seedPayoutConnector(page, context, "adyen_payout_history");

  await homePage.workflow.click();
  await homePage.payoutRouting.click();
  await payoutRouting.volumeBasedRoutingSetupButton.click();
  await page.waitForURL(/.*payoutrouting\/volume/, { timeout: 15000 });

  await volume.configurationNameInput.clear();
  await volume.configurationNameInput.fill(configName);
  await volume.connectorDropdown.click();
  await volume.connectorOption("adyen_payout_history").click();
  await volume.configureRuleButton.click();
  await volume.saveAndActivateRuleButton.click();

  await expect(payoutRouting.dataToast("Successfully activated!")).toBeVisible({
    timeout: 15000,
  });
};

test.describe("Visual Testing - Workflow", () => {
  test.describe("Routing", () => {
    test("routing landing with no configuration should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.routing.click();

      // Routing landing renders the configuration option cards regardless of
      // whether any connector or rule exists.
      await expect(
        page.getByText("Volume Based Configuration", { exact: true }),
      ).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-routing-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("routing volume setup with no connectors should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const paymentRouting = new PaymentRouting(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.routing.click();
      await paymentRouting.volumeBasedRoutingSetupButton.click();

      // Fresh signup → no connectors, so the setup CTA lands on the
      // "configure at least 1 connector" guard screen.
      await expect(paymentRouting.noConnectorsMessage).toContainText(
        "Please connect at least 1 processor in order to create a rule.",
      );

      await expect(page).toHaveScreenshot(
        "workflow-routing-setup-no-connectors.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("rule based routing configuration should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const paymentRouting = new PaymentRouting(page);
      const ruleBased = new RuleBasedConfiguration(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      // Seed a connector so the setup CTA opens the rule editor (not the guard).
      await seedConnector(page, context, "stripe_test_rule");

      await homePage.workflow.click();
      await homePage.routing.click();
      await paymentRouting.ruleBasedRoutingSetupButton.click();
      await page.waitForLoadState("networkidle");

      await expect(ruleBased.configurationNameInput).toBeVisible({
        timeout: 15000,
      });
      await expect(ruleBased.selectFieldButton).toBeVisible();
      await expect(ruleBased.addProcessorsButton).toBeVisible();
      await expect(ruleBased.configureRuleButton).toBeVisible();

      // The prefilled configuration name + description carry a per-run
      // date/timestamp, so mask them.
      await expect(page).toHaveScreenshot("workflow-routing-rule-based.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        mask: [
          ruleBased.configurationNameInput,
          page.locator('[name="description"]'),
        ],
      });
    });

    test("default fallback configuration should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const paymentRouting = new PaymentRouting(page);
      const defaultFallback = new DefaultFallback(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      // Seed a connector so the fallback priority list has an entry to render.
      await seedConnector(page, context, "stripe_test_fallback");

      await homePage.workflow.click();
      await homePage.routing.click();
      await paymentRouting.defaultFallbackManageButton.click();
      await page.waitForLoadState("networkidle");

      await expect(defaultFallback.connectorAt(0)).toContainText(
        "stripe_test_fallback",
        { timeout: 15000 },
      );

      await expect(page).toHaveScreenshot(
        "workflow-routing-default-fallback.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("auth based routing configuration should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const paymentRouting = new PaymentRouting(page);
      const authRateBased = new AuthRateBasedConfiguration(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await seedConnector(page, context, "stripe_test_auth");

      await homePage.workflow.click();
      await homePage.routing.click();
      await paymentRouting.authRateBasedRoutingSetupButton.click();
      await page.waitForURL(/.*routing\/auth-rate/, { timeout: 15000 });

      await expect(authRateBased.bucketSizeInput).toBeVisible({
        timeout: 15000,
      });
      await expect(authRateBased.explorationPercentInput).toBeVisible();
      await expect(authRateBased.rolloutPercentInput).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-routing-auth-based.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("least cost routing configuration modal should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.routing.click();

      // Least Cost Routing is the 4th configuration card; its Setup button opens
      // the "Enable Least Cost Routing Configuration" modal (no connector needed).
      await page.locator('[data-button-for="setup"]').nth(3).click();

      await expect(
        page.getByText("Enable Least Cost Routing Configuration", {
          exact: true,
        }),
      ).toBeVisible({ timeout: 15000 });
      await expect(page.getByRole("button", { name: "Enable" })).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-routing-least-cost.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("configuration history tab should match visual snapshot", async ({
      page,
      context,
    }) => {
      // Create-and-activate flow (UI) + API connector seeding chains past the
      // default 30s budget.
      test.setTimeout(120000);
      await mockV2MerchantList(page);

      const paymentRouting = new PaymentRouting(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await createActiveVolumeConfig(page, context, "PW Visual History Config");

      await paymentRouting.configurationHistoryTab.click();
      await page.waitForLoadState("networkidle");

      // Row 1: S.No(1), Name(2), Type(3), Description(4), Status(5).
      await expect(paymentRouting.historyCell(1, 2)).toContainText(
        "PW Visual History Config",
        { timeout: 15000 },
      );
      await expect(paymentRouting.historyCell(1, 3)).toContainText(
        "Volume Based",
      );
      await expect(paymentRouting.historyCell(1, 5)).toContainText("ACTIVE");

      // The Description cell carries "...created at <timestamp>" — mask it.
      await expect(page).toHaveScreenshot(
        "workflow-routing-configuration-history.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [paymentRouting.historyCell(1, 4)],
        },
      );
    });

    test("clicking a configuration in history opens its preview should match visual snapshot", async ({
      page,
      context,
    }) => {
      test.setTimeout(120000);
      await mockV2MerchantList(page);

      const paymentRouting = new PaymentRouting(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await createActiveVolumeConfig(page, context, "PW Visual Preview Config");

      await paymentRouting.configurationHistoryTab.click();
      await page.waitForLoadState("networkidle");

      // Open the configuration preview from the history row.
      await expect(paymentRouting.historyCell(1, 2)).toContainText(
        "PW Visual Preview Config",
        { timeout: 15000 },
      );
      await paymentRouting.historyCell(1, 2).click();
      await page.waitForLoadState("networkidle");

      await expect(
        page.getByText("PW Visual Preview Config").first(),
      ).toBeVisible({
        timeout: 15000,
      });
      await expect(page.getByText("stripe_test_history").first()).toBeVisible();

      // The description block renders "...created at <timestamp>" — mask it.
      await expect(page).toHaveScreenshot(
        "workflow-routing-configuration-preview.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [page.getByText(/created at/).first()],
        },
      );
    });
  });

  test.describe("Surcharge", () => {
    test("surcharge empty state should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const surcharge = new Surcharge(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.surchargeRouting.click();
      await page.waitForURL(/dashboard\/surcharge/, { timeout: 15000 });

      // Fresh signup → no active surcharge rule on this merchant.
      await expect(surcharge.pageHeading).toBeVisible();
      await expect(surcharge.emptyStateHeading).toBeVisible();
      await expect(surcharge.createNewButton).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-surcharge-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("surcharge with active rule should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const surcharge = new Surcharge(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      // Seed an active surcharge rule via the routing API (reads the JWT from
      // localStorage, so it must run after loginUI).
      await createSurchargeAPI(page, context.request, {
        name: "playwright_surcharge",
      });

      await homePage.workflow.click();
      await homePage.surchargeRouting.click();
      await page.waitForURL(/dashboard\/surcharge/, { timeout: 15000 });

      // ActiveRulePreview card with the seeded rule.
      await expect(surcharge.activeBadge).toBeVisible();
      await expect(surcharge.editIcon).toBeVisible();
      await expect(surcharge.deleteIcon).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-surcharge-with-rule.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("surcharge configuration form should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const surcharge = new Surcharge(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.surchargeRouting.click();
      await page.waitForURL(/dashboard\/surcharge/, { timeout: 15000 });

      // Fresh signup → no active rule, so Create New opens the rule-builder
      // form directly (no override-warning popup).
      await expect(surcharge.createNewButton).toBeVisible();
      await surcharge.createNewButton.click();

      // The rule-builder form: rule heading, the "For example:" hint that only
      // renders inside the form, the surcharge-type selector and Save.
      await expect(surcharge.ruleHeading).toBeVisible({ timeout: 10000 });
      await expect(surcharge.configureSurchargeBlock).toBeVisible();
      await expect(surcharge.selectSurchargeTypeButton).toBeVisible();
      await expect(surcharge.saveButton).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-surcharge-config.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });
  });

  test.describe("Payout Routing", () => {
    test("payout routing landing with no configuration should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.payoutRouting.click();

      await expect(
        page.getByText("Volume Based Configuration", { exact: true }),
      ).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-payout-routing-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("payout routing volume setup with no connectors should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const payoutRouting = new PayoutRouting(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.payoutRouting.click();
      await payoutRouting.volumeBasedRoutingSetupButton.click();

      await expect(payoutRouting.noConnectorsMessage).toContainText(
        "Please connect at least 1 processor in order to create a rule.",
      );

      await expect(page).toHaveScreenshot(
        "workflow-payout-routing-setup-no-connectors.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("payout rule based routing configuration should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const payoutRouting = new PayoutRouting(page);
      const ruleBased = new RuleBasedConfiguration(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      // Seed a payout connector so the setup CTA opens the rule editor.
      await seedPayoutConnector(page, context, "adyen_payout_rule");

      await homePage.workflow.click();
      await homePage.payoutRouting.click();
      await payoutRouting.ruleBasedRoutingSetupButton.click();
      await page.waitForLoadState("networkidle");

      await expect(ruleBased.configurationNameInput).toBeVisible({
        timeout: 15000,
      });
      await expect(ruleBased.selectFieldButton).toBeVisible();
      await expect(ruleBased.addProcessorsButton).toBeVisible();
      await expect(ruleBased.configureRuleButton).toBeVisible();

      // The prefilled configuration name + description carry a per-run
      // date/timestamp, so mask them.
      await expect(page).toHaveScreenshot(
        "workflow-payout-routing-rule-based.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [
            ruleBased.configurationNameInput,
            page.locator('[name="description"]'),
          ],
        },
      );
    });

    test("payout default fallback configuration should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const payoutRouting = new PayoutRouting(page);
      const defaultFallback = new DefaultFallback(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      // Seed a payout connector so the fallback priority list has an entry.
      await seedPayoutConnector(page, context, "adyen_payout_fallback");

      await homePage.workflow.click();
      await homePage.payoutRouting.click();
      await payoutRouting.defaultFallbackManageButton.click();
      await page.waitForLoadState("networkidle");

      await expect(defaultFallback.connectorAt(0)).toContainText(
        "adyen_payout_fallback",
        { timeout: 15000 },
      );

      await expect(page).toHaveScreenshot(
        "workflow-payout-routing-default-fallback.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("payout configuration history tab should match visual snapshot", async ({
      page,
      context,
    }) => {
      // Create-and-activate flow (UI) + API connector seeding chains past the
      // default 30s budget.
      test.setTimeout(120000);
      await mockV2MerchantList(page);

      const payoutRouting = new PayoutRouting(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await createActivePayoutVolumeConfig(
        page,
        context,
        "PW Visual Payout History Config",
      );

      await payoutRouting.configurationHistoryTab.click();
      await page.waitForLoadState("networkidle");

      // Row 1: S.No(1), Name(2), Type(3), Description(4), Status(5).
      await expect(payoutRouting.historyCell(1, 2)).toContainText(
        "PW Visual Payout History Config",
        { timeout: 15000 },
      );
      await expect(payoutRouting.historyCell(1, 3)).toContainText(
        "Volume Based",
      );
      await expect(payoutRouting.historyCell(1, 5)).toContainText("ACTIVE");

      // The Description cell carries "...created at <timestamp>" — mask it.
      await expect(page).toHaveScreenshot(
        "workflow-payout-routing-configuration-history.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [payoutRouting.historyCell(1, 4)],
        },
      );
    });

    test("clicking a payout configuration in history opens its preview should match visual snapshot", async ({
      page,
      context,
    }) => {
      test.setTimeout(120000);
      await mockV2MerchantList(page);

      const payoutRouting = new PayoutRouting(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await createActivePayoutVolumeConfig(
        page,
        context,
        "PW Visual Payout Preview Config",
      );

      await payoutRouting.configurationHistoryTab.click();
      await page.waitForLoadState("networkidle");

      await expect(payoutRouting.historyCell(1, 2)).toContainText(
        "PW Visual Payout Preview Config",
        { timeout: 15000 },
      );
      await payoutRouting.historyCell(1, 2).click();
      await page.waitForLoadState("networkidle");

      await expect(
        page.getByText("PW Visual Payout Preview Config").first(),
      ).toBeVisible({ timeout: 15000 });
      await expect(
        page.getByText("adyen_payout_history").first(),
      ).toBeVisible();

      // The description block renders "...created at <timestamp>" — mask it.
      await expect(page).toHaveScreenshot(
        "workflow-payout-routing-configuration-preview.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [page.getByText(/created at/).first()],
        },
      );
    });
  });

  test.describe("3DS Exemption Manager", () => {
    test("3ds exemption empty state should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      // Register the FF mock before loginUI navigates so the menu is exposed.
      await enableThreeDsExemptionFlag(page);

      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.threeDSExemptionManager.click();
      await page.waitForURL(/dashboard\/3ds-exemption/, { timeout: 15000 });

      // Fresh signup → no active 3DS exemption rule on this merchant.
      await expect(exemption.pageHeading).toBeVisible();
      await expect(exemption.configureSectionHeading).toBeVisible();
      await expect(exemption.createNewButton).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-3ds-exemption-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("3ds exemption with active rule should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);
      await enableThreeDsExemptionFlag(page);

      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      // Seed an active 3DS exemption rule via the routing API (reads the JWT
      // from localStorage, so it must run after loginUI).
      await createThreeDsExemptionAPI(page, context.request, {
        name: "playwright_3ds_exemption",
      });

      await homePage.workflow.click();
      await homePage.threeDSExemptionManager.click();
      await page.waitForURL(/dashboard\/3ds-exemption/, { timeout: 15000 });

      // ActiveRulePreview card with the seeded rule.
      await expect(exemption.activeBadge).toBeVisible();
      await expect(exemption.deleteIcon).toBeVisible();

      await expect(page).toHaveScreenshot(
        "workflow-3ds-exemption-with-rule.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });

    test("3ds exemption configuration form should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);
      await enableThreeDsExemptionFlag(page);

      const homePage = new HomePage(page);
      const exemption = new ThreeDSExemptionManager(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.workflow.click();
      await homePage.threeDSExemptionManager.click();
      await page.waitForURL(/dashboard\/3ds-exemption/, { timeout: 15000 });

      // Fresh signup → no active rule, so Create New opens the rule-builder
      // form directly (no override-warning popup).
      await expect(exemption.createNewButton).toBeVisible();
      await exemption.createNewButton.click();

      // The rule-builder form: rule heading, the pre-filled condition row's
      // auth-type field ("Select Field") and Save.
      await expect(exemption.ruleHeading).toBeVisible({ timeout: 10000 });
      await expect(exemption.authTypeDropdown).toBeVisible();
      await expect(exemption.saveButton).toBeVisible();

      await expect(page).toHaveScreenshot("workflow-3ds-exemption-config.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });
  });
});
