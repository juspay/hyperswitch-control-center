import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PayoutRouting } from "../../support/pages/workflow/payoutRouting/PayoutRouting";
import { DefaultFallback } from "../../support/pages/workflow/paymentRouting/DefaultFallback";
import { VolumeBasedConfiguration } from "../../support/pages/workflow/paymentRouting/VolumeBasedConfiguration";
import { RuleBasedConfiguration } from "../../support/pages/workflow/paymentRouting/RuleBasedConfiguration";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createPayoutConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

const setPayoutFeatureFlag = async (page: Page, payout: boolean) => {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    json.features = { ...json.features, payout };
    await route.fulfill({ response, json });
  });
};

test.describe("Volume based payout routing", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display valid message when no connectors are connected", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.volumeBasedRoutingSetupButton.click();

    await expect(payoutRouting.noProcessorFoundMessage).toBeVisible();
  });

  test("should display all elements in volume based payout routing page", async ({
    page,
    context,
  }) => {
    test.setTimeout(60000);
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    const connectorLabel = `adyen_payout_${Date.now()}`;
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        connectorLabel,
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*payoutrouting\/volume/);
    await page.waitForLoadState("networkidle");

    await expect(payoutRouting.volumeBasedRoutingHeader).toContainText(
      "Payout Routing Configurations",
    );

    const [today, yesterday] = await page.evaluate(() => {
      const fmt = (d: Date) => d.toLocaleDateString("en-CA");
      const t = new Date();
      const y = new Date(t);
      y.setDate(y.getDate() - 1);
      return [fmt(t), fmt(y)];
    });
    await expect(volumeBasedConfiguration.configurationNameInput).toHaveValue(
      new RegExp(`^Volume Based Routing-(${today}|${yesterday})$`),
      { timeout: 15000 },
    );

    await expect(volumeBasedConfiguration.descriptionInput).toContainText(
      "This is a volume based routing created at",
    );

    await volumeBasedConfiguration.connectorDropdown.click();
    await expect(
      volumeBasedConfiguration.connectorOption(connectorLabel),
    ).toContainText(connectorLabel);
  });

  test("should save new Volume based payout configuration", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_1",
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*payoutrouting\/volume/);

    await volumeBasedConfiguration.configurationNameInput.clear();
    await volumeBasedConfiguration.configurationNameInput.fill(
      "Test volume based payout config",
    );

    await volumeBasedConfiguration.connectorDropdown.click();
    await volumeBasedConfiguration.connectorOption("adyen_payout_1").click();
    await volumeBasedConfiguration.configureRuleButton.click();
    await volumeBasedConfiguration.saveRuleButton.click();

    await expect(
      payoutRouting.dataToast("Successfully created a new configuration!"),
    ).toContainText("Successfully created a new configuration!");

    await payoutRouting.configurationHistoryTab.click();
    await expect(payoutRouting.historyCell(1, 2)).toContainText(
      "Test volume based payout config",
    );
    await expect(payoutRouting.dataLabel("INACTIVE")).toContainText("INACTIVE");
  });

  test("should save and activate Volume based payout configuration", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_1",
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*payoutrouting\/volume/);

    await volumeBasedConfiguration.configurationNameInput.clear();
    await volumeBasedConfiguration.configurationNameInput.fill(
      "Test volume based payout config",
    );

    await volumeBasedConfiguration.connectorDropdown.click();
    await volumeBasedConfiguration.connectorOption("adyen_payout_1").click();
    await volumeBasedConfiguration.configureRuleButton.click();
    await volumeBasedConfiguration.saveAndActivateRuleButton.click();

    await expect(
      payoutRouting.dataToast("Successfully created a new configuration!"),
    ).toContainText("Successfully created a new configuration!");

    await expect(
      payoutRouting.dataToast("Successfully activated!"),
    ).toContainText("Successfully activated!");

    await expect(volumeBasedConfiguration.activeConfigContainer).toContainText(
      "Test volume based payout config",
    );

    await expect(volumeBasedConfiguration.activeIndicator).toBeVisible();
  });

  test("should validate volume percentage split", async ({ page, context }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_1",
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*payoutrouting\/volume/);

    await volumeBasedConfiguration.connectorDropdown.click();
    await volumeBasedConfiguration.connectorOption("adyen_payout_1").click();
    await volumeBasedConfiguration.percentageInput(1).clear();
    await volumeBasedConfiguration.percentageInput(1).fill("50");
    await expect(volumeBasedConfiguration.configureRuleButton).toBeDisabled();
  });

  test("should validate name and description fields", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_1",
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*payoutrouting\/volume/);

    await volumeBasedConfiguration.configurationNameTextbox.clear();
    await volumeBasedConfiguration.configurationNameTextbox.blur();
    await expect(page.getByText("Please provide name field")).toBeVisible();

    await volumeBasedConfiguration.descriptionTextbox.clear();
    await volumeBasedConfiguration.descriptionTextbox.blur();
    await expect(page.getByText("Please provide description")).toBeVisible();
  });
});

test.describe("Rule based payout routing", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  async function setupRuleBasedPayoutRouting(
    page: Page,
    context: BrowserContext,
  ): Promise<string | null> {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_operator_test",
        context.request,
      );
    }
    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.ruleBasedRoutingSetupButton.click();
    await page.waitForLoadState("networkidle");
    return merchantId;
  }

  test("should display valid message when no connectors are connected", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.ruleBasedRoutingSetupButton.click();

    await expect(page.getByText("Please configure at least 1")).toContainText(
      "Please configure at least 1 connector",
    );
  });

  test("Rule editor add condition row - Click Add Condition renders condition row with field, operator, value inputs", async ({
    page,
    context,
  }) => {
    await setupRuleBasedPayoutRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    await ruleBasedConfiguration.configurationNameInput.fill(
      "Add Condition Row Test",
    );

    await ruleBasedConfiguration.selectFieldButton.click();
    await page.getByRole('searchbox', { name: 'Search options...' }).fill("currency");
    await page.getByText('currency', { exact: true }).click();

    await ruleBasedConfiguration.selectOperatorButton.click();
    await page.getByText('IS', { exact: true }).click();

    await ruleBasedConfiguration.selectValueButton.click();
    await page.getByText('USD', { exact: true }).click();

    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByText('adyen_payout_operator_test', { exact: true }).click();

    await expect(
      ruleBasedConfiguration.firstAddConditionRowButton,
    ).toBeVisible();
    await ruleBasedConfiguration.firstAddConditionRowButton.click();

    await expect(ruleBasedConfiguration.rule2Button).toBeVisible();
  });

  test("Rule editor operators - enum, numeric, and text input types render correctly", async ({
    page,
    context,
  }) => {
    await setupRuleBasedPayoutRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    await ruleBasedConfiguration.configurationNameInput.fill(
      "Operator Types Test",
    );

    await ruleBasedConfiguration.selectFieldButton.click();
    await page.getByText('currency', { exact: true }).click();
    await expect(page.getByText('payment_method', { exact: true })).not.toBeVisible();
    await ruleBasedConfiguration.selectOperatorButton.click();
    await expect(page.locator("div").filter({ hasText: /^ISCONTAINSIS_NOTNOT_CONTAINS$/ }).nth(1)).toBeVisible();

    await page.getByRole("button", { name: "currency" }).click();
    await page.locator('[data-id="amount"]').first().click({ force: true });
    await expect(page.getByText('payment_method', { exact: true })).not.toBeVisible();
    await ruleBasedConfiguration.selectOperatorButton.click();
    await expect(page.locator("div").filter({ hasText: /^EQUAL TOGREATER THANLESS THAN$/ }).nth(1)).toBeVisible();

    await page.getByRole("button", { name: "amount" }).click();
    await page.locator('[data-id="business_label"]').first().click({ force: true });
    await expect(page.getByText('payment_method', { exact: true })).not.toBeVisible();
    await ruleBasedConfiguration.selectOperatorButton.click();
    await expect(page.locator("div").filter({ hasText: /^EQUAL TONOT EQUAL_TO$/ }).first()).toBeVisible();
  });

  test("Rule editor logical operator AND OR toggle - changes logical operator value", async ({
    page,
    context,
  }) => {
    await setupRuleBasedPayoutRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    await expect(ruleBasedConfiguration.addConditionButton).toBeVisible();
    await ruleBasedConfiguration.addConditionButton.click();
    await expect(
      ruleBasedConfiguration.logicalOperatorToggle.first(),
    ).toBeVisible();

    await ruleBasedConfiguration.logicalOperatorSwitch.click();
    await expect(
      ruleBasedConfiguration.logicalOperatorToggle.first(),
    ).not.toBeVisible();
  });
});

test.describe("Payout default fallback", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display valid message when no connectors are connected", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.defaultFallbackManageButton.click();

    await expect(payoutRouting.noProcessorFoundMessage).toBeVisible();
  });

  test("should display connected payout connectors in the list", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    const defaultFallback = new DefaultFallback(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_1",
        context.request,
      );
    }

    await homePage.connectors.click();
    await homePage.payoutConnectors.click();

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.defaultFallbackManageButton.click();

    await expect(defaultFallback.connectorAt(0)).toContainText(
      "adyen_payout_1",
    );
  });

  test("should be able to change the order by dragging and updating", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    const defaultFallback = new DefaultFallback(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_1",
        context.request,
      );
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_2",
        context.request,
      );
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_3",
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.defaultFallbackManageButton.click();

    const firstConnector = defaultFallback.connectorAt(0);
    const secondConnector = defaultFallback.connectorAt(1);

    await firstConnector.scrollIntoViewIfNeeded();
    const sourceBox = await firstConnector.boundingBox();
    const targetBox = await secondConnector.boundingBox();
    if (!sourceBox || !targetBox) {
      throw new Error("Bounding box missing for drag elements");
    }

    const startX = sourceBox.x + sourceBox.width / 2;
    const startY = sourceBox.y + sourceBox.height / 2;
    const endX = targetBox.x + targetBox.width / 2;
    const endY = targetBox.y + targetBox.height / 2;

    await page.mouse.move(startX, startY);
    await page.mouse.down();
    await page.mouse.move(startX, startY + 8, { steps: 5 });
    await page.mouse.move(endX, endY, { steps: 15 });
    await page.mouse.move(endX, endY + 2, { steps: 3 });
    await page.mouse.up();

    await defaultFallback.saveChangesButton.click();

    await defaultFallback.yesSaveItButton.waitFor({
      state: "visible",
      timeout: 5000,
    });
    await defaultFallback.yesSaveItButton.click();

    await expect(defaultFallback.configurationSavedToast).toBeVisible();
  });
});

test.describe("Payout Routing list - Configuration History", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  async function getMerchantId(page: Page): Promise<string | null> {
    const homePage = new HomePage(page);
    const merchantLocator = homePage.merchantID.nth(0);
    if (!(await merchantLocator.isVisible().catch(() => false))) {
      await page.goto("/dashboard/home");
      await page.waitForLoadState("networkidle");
    }
    return await merchantLocator.textContent();
  }

  async function createInactiveVolumePayoutRule(
    page: Page,
    context: BrowserContext,
    configName: string,
    connectorLabel = "adyen_payout_1",
  ) {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        connectorLabel,
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.volumeBasedRoutingSetupButton.click();
    await expect(page).toHaveURL(/.*payoutrouting\/volume/);

    await volumeBasedConfiguration.configurationNameInput.clear();
    await volumeBasedConfiguration.configurationNameInput.fill(configName);

    await volumeBasedConfiguration.connectorDropdown.click();
    await volumeBasedConfiguration.connectorOption(connectorLabel).click();
    await volumeBasedConfiguration.configureRuleButton.click();
    await volumeBasedConfiguration.saveRuleButton.click();

    await expect(
      payoutRouting.dataToast("Successfully created a new configuration!"),
    ).toContainText("Successfully created a new configuration!");
  }

  async function createActiveVolumePayoutRule(
    page: Page,
    context: BrowserContext,
    configName: string,
    connectorLabel = "adyen_payout_1",
  ) {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        connectorLabel,
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.volumeBasedRoutingSetupButton.click();
    await expect(page).toHaveURL(/.*payoutrouting\/volume/);

    await volumeBasedConfiguration.configurationNameInput.clear();
    await volumeBasedConfiguration.configurationNameInput.fill(configName);

    await volumeBasedConfiguration.connectorDropdown.click();
    await volumeBasedConfiguration.connectorOption(connectorLabel).click();
    await volumeBasedConfiguration.configureRuleButton.click();
    await volumeBasedConfiguration.saveAndActivateRuleButton.click();

    await expect(
      payoutRouting.dataToast("Successfully activated!"),
    ).toContainText("Successfully activated!");
  }

  async function openManageRulesTab(page: Page) {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.configurationHistoryTab.click();
  }

  test("verify payout routing page elements", async ({ page }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);

    await homePage.connectors.click();
    await homePage.payoutConnectors.click();

    await homePage.workflow.click();
    await homePage.payoutRouting.click();

    await expect(payoutRouting.activeBadge).toBeVisible();
    await expect(page.getByText("Default fallback").nth(1)).toBeVisible();
    await expect(payoutRouting.viewAndManageButton).toBeVisible();

    await expect(
      page.getByText("Volume Based Configuration", { exact: true }),
    ).toBeVisible();
    await expect(
      page.getByText("Rule Based Configuration", { exact: true }),
    ).toBeVisible();

    await expect(
      page.getByText(
        "Fallback is the priority list of configured processors used for routing traffic alone or when other rules don’t apply. You can reorder it via drag and drop",
        { exact: true },
      ),
    ).toBeVisible();

    await expect(payoutRouting.setupButton).toHaveCount(2);
    await expect(payoutRouting.manageButton).toBeVisible();
  });

  test("should display default fallback when no other payout routing is configured", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_1",
        context.request,
      );
    }

    await homePage.connectors.click();
    await homePage.payoutConnectors.click();

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await expect(payoutRouting.activeBadge).toBeVisible();
    await expect(page.getByText("Default fallback").nth(1)).toBeVisible();
    await expect(payoutRouting.viewAndManageButton).toBeVisible();
  });

  test("should display active payout routing configurations on Active configuration tab", async ({
    page,
    context,
  }) => {
    const payoutRouting = new PayoutRouting(page);
    await createActiveVolumePayoutRule(
      page,
      context,
      "List active payout smoke config",
    );

    await expect(payoutRouting.activeBadge).toBeVisible();
    await expect(
      page.getByText("List active payout smoke config -"),
    ).toBeVisible();
    await expect(payoutRouting.viewAndManageButton).toBeVisible();
  });

  test("should display all existing payout routing configurations on Configuration History tab", async ({
    page,
    context,
  }) => {
    const payoutRouting = new PayoutRouting(page);
    await createInactiveVolumePayoutRule(
      page,
      context,
      "List inactive payout smoke config",
    );
    await createActiveVolumePayoutRule(
      page,
      context,
      "List active payout smoke config",
      "adyen_payout_2",
    );

    await expect(
      page.getByText("List active payout smoke config -"),
    ).toBeVisible();
    await expect(payoutRouting.viewAndManageButton).toBeVisible();
    await openManageRulesTab(page);

    await expect(payoutRouting.historyCell(1, 2)).toContainText(
      "List active payout smoke config",
    );
    await expect(payoutRouting.historyCell(1, 3)).toContainText("Volume Based");
    await expect(payoutRouting.historyCell(1, 5)).toContainText("ACTIVE");

    await expect(payoutRouting.historyCell(2, 2)).toContainText(
      "List inactive payout smoke config",
    );
    await expect(payoutRouting.historyCell(2, 3)).toContainText("Volume Based");
    await expect(payoutRouting.historyCell(2, 5)).toContainText("INACTIVE");
  });

  test("should expose Activate Configuration on inactive payout rule preview", async ({
    page,
    context,
  }) => {
    const payoutRouting = new PayoutRouting(page);
    await createInactiveVolumePayoutRule(
      page,
      context,
      "Activate payout via preview",
    );

    await openManageRulesTab(page);
    await payoutRouting.historyCell(1, 2).click();
    await page.waitForLoadState("networkidle");

    await expect(page.getByText("Configuration NameActivate")).toBeVisible();
    await expect(page.getByText("DescriptionThis is a volume")).toBeVisible();
    await expect(page.getByText("adyen_payout_1")).toBeVisible();

    const activateBtn = page
      .getByRole("button", { name: /Activate Configuration/i })
      .first();
    await expect(activateBtn).toBeVisible({ timeout: 10000 });
    await activateBtn.click();
    await expect(
      payoutRouting.dataToast("Successfully activated!"),
    ).toContainText("Successfully activated!");
  });

  test("should expose Deactivate Configuration on active payout rule preview", async ({
    page,
    context,
  }) => {
    const payoutRouting = new PayoutRouting(page);
    await createActiveVolumePayoutRule(
      page,
      context,
      "Deactivate payout via preview",
    );

    await openManageRulesTab(page);
    await payoutRouting.historyCell(1, 2).click();
    await page.waitForLoadState("networkidle");

    const deactivateBtn = page
      .getByRole("button", { name: /Deactivate Configuration/i })
      .first();
    await expect(deactivateBtn).toBeVisible();
    await deactivateBtn.click();
    await expect(
      payoutRouting.dataToast("Successfully deactivated!"),
    ).toContainText("Successfully deactivated!");
  });

  test("should duplicate and edit volume payout routing - update name and add a different connector", async ({
    page,
    context,
  }) => {
    test.setTimeout(120000);
    const payoutRouting = new PayoutRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);
    await createActiveVolumePayoutRule(
      page,
      context,
      "Volume payout edit original",
      "adyen_payout_volume_a",
    );

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_volume_b",
        context.request,
      );
    }

    await openManageRulesTab(page);
    const historyRow = payoutRouting.historyCell(1, 2);
    await expect(historyRow).toBeVisible();
    await historyRow.click();
    await page.waitForLoadState("networkidle");

    const duplicateBtn =
      volumeBasedConfiguration.duplicateAndEditConfigurationButton;
    await expect(duplicateBtn).toBeVisible({ timeout: 15000 });
    await duplicateBtn.click();
    await page.waitForLoadState("networkidle");

    const nameInput = volumeBasedConfiguration.configurationNameInput;
    await expect(nameInput).toBeVisible();
    await nameInput.clear();
    await nameInput.fill("Volume payout edit updated");

    await expect(volumeBasedConfiguration.connectorDropdown).toBeVisible();
    await volumeBasedConfiguration.connectorDropdown.click();
    const newConnectorOption = volumeBasedConfiguration.connectorOption(
      "adyen_payout_volume_b",
    );
    await expect(newConnectorOption).toBeVisible();
    await newConnectorOption.click();

    await volumeBasedConfiguration.configureRuleButton.click();
    await volumeBasedConfiguration.saveAndActivateRuleByRoleButton.click();

    await expect(
      payoutRouting.dataToast("Successfully created a new configuration!"),
    ).toContainText("Successfully created a new configuration!");

    await openManageRulesTab(page);
    await expect(payoutRouting.historyCell(1, 2)).toContainText(
      "Volume payout edit updated",
    );
  });

  test("should duplicate and edit rule payout routing - update name and configure a different value for a route", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_routing_edit",
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.ruleBasedRoutingSetupButton.click();
    await page.waitForLoadState("networkidle");

    await ruleBasedConfiguration.configurationNameInput.clear();
    await ruleBasedConfiguration.configurationNameInput.fill(
      "Rule payout edit original",
    );

    await ruleBasedConfiguration.selectFieldButton.click();
    await page.getByText('currency', { exact: true }).click();

    await ruleBasedConfiguration.selectOperatorButton.click();
    await page.getByText('IS', { exact: true }).click();

    await ruleBasedConfiguration.selectValueButton.click();
    await page.getByText('USD', { exact: true }).click();

    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByText('adyen_payout_routing_edit', { exact: true }).click();

    await ruleBasedConfiguration.configureRuleButton.click();

    await ruleBasedConfiguration.saveAndActivateRuleButton.click();
    await page.waitForLoadState("networkidle");

    await openManageRulesTab(page);
    await payoutRouting.historyCell(1, 2).click();
    await page.waitForLoadState("networkidle");

    const duplicateBtn = ruleBasedConfiguration.duplicateAndEditButton;
    await expect(duplicateBtn).toBeVisible({ timeout: 10000 });
    await duplicateBtn.click();

    const nameInput = ruleBasedConfiguration.configurationNameInput;
    await nameInput.clear();
    await nameInput.fill("Rule payout edit updated");

    await page.getByRole("button", { name: "USD" }).click();
    await page.getByText('EUR', { exact: true }).click();
    await ruleBasedConfiguration.configureRuleButton.click();

    await ruleBasedConfiguration.saveAndActivateRuleButton.click();
    await page.waitForLoadState("networkidle");

    await openManageRulesTab(page);
    await expect(payoutRouting.historyCell(1, 2)).toContainText(
      "Rule payout edit updated",
    );
  });
});

test.describe("Advanced payout rule connector selection modes", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  async function navigateToRuleBasedPayoutRouting(
    page: Page,
    context: BrowserContext,
  ) {
    const homePage = new HomePage(page);
    const payoutRouting = new PayoutRouting(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_rule_a",
        context.request,
      );
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_rule_b",
        context.request,
      );
      await createPayoutConnectorAPI(
        merchantId,
        "adyen_payout_rule_c",
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.payoutRouting.click();
    await payoutRouting.ruleBasedRoutingSetupButton.click();
    await page.waitForLoadState("networkidle");
  }

  test("should render connectors without split fields in priority mode (distribute OFF)", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedPayoutRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    await expect(ruleBasedConfiguration.distributeText).not.toBeVisible();

    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'adyen_payout_rule_a' }).click();
    await page.getByRole('option', { name: 'adyen_payout_rule_b' }).click();

    await expect(ruleBasedConfiguration.distributeText).toBeVisible();

    const isChecked =
      await ruleBasedConfiguration.distributeText.getAttribute("aria-checked");
    expect(isChecked || "false").toBe("false");

    expect(page.getByText("1adyen_payout_rule_a")).toBeVisible();
    expect(page.getByText("2adyen_payout_rule_b")).toBeVisible();
    const percentageInputs = page.locator('input[name="1"], input[name="2"]');
    const inputCount = await percentageInputs.count();
    expect(inputCount).toBe(0);

    await expect(page.getByText("adyen_payout_rule_a").nth(1)).toBeVisible();
    await expect(page.getByText("adyen_payout_rule_b").nth(1)).toBeVisible();
  });

  test("should render connectors with split fields in volume mode (distribute ON)", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedPayoutRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'adyen_payout_rule_a' }).click();
    await page.getByRole('option', { name: 'adyen_payout_rule_b' }).click();

    let percentageInputs = page.locator('input[name="1"], input[name="2"]');
    await expect(percentageInputs).toHaveCount(0);

    await ruleBasedConfiguration.distributeCheckboxNotSelected.click();

    percentageInputs = page.locator('input[name="1"], input[name="2"]');
    await expect(percentageInputs).toHaveCount(2, { timeout: 5000 });

    await expect(ruleBasedConfiguration.percentageInput(1)).toHaveValue("50");
    await expect(ruleBasedConfiguration.percentageInput(2)).toHaveValue("50");
  });

  test("should render 3 connectors with auto-calculated split percentages (33/33/34)", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedPayoutRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'adyen_payout_rule_a' }).click();
    await page.getByRole('option', { name: 'adyen_payout_rule_b' }).click();
    await page.getByRole('option', { name: 'adyen_payout_rule_c' }).click();

    await ruleBasedConfiguration.distributeCheckboxNotSelected.nth(0).click();
    await page.waitForTimeout(300);

    const percentageInputs = page.locator(
      'input[name="1"], input[name="2"], input[name="3"]',
    );
    await expect(percentageInputs).toHaveCount(3);

    await expect(ruleBasedConfiguration.percentageInput(1)).toHaveValue("33");
    await expect(ruleBasedConfiguration.percentageInput(2)).toHaveValue("33");
    await expect(ruleBasedConfiguration.percentageInput(3)).toHaveValue("34");
  });

  test("should toggle distribute mode and update UI accordingly", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedPayoutRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'adyen_payout_rule_a' }).click();
    await page.getByRole('option', { name: 'adyen_payout_rule_b' }).click();

    await ruleBasedConfiguration.distributeCheckboxNotSelected.click();
    await expect(page.getByRole('option', { name: 'adyen_payout_rule_a' })).not.toBeVisible();

    let percentageInputs = page.locator('input[name="1"], input[name="2"]');
    await expect(percentageInputs).toHaveCount(2);

    await ruleBasedConfiguration.distributeCheckboxSelected.click();

    percentageInputs = page.locator('input[name="1"], input[name="2"]');
    await expect(percentageInputs).toHaveCount(0);

    await expect(page.getByText("adyen_payout_rule_a")).toBeVisible();
    await expect(page.getByText("adyen_payout_rule_b")).toBeVisible();
  });

  test("should allow manual editing of split percentages", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedPayoutRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'adyen_payout_rule_a' }).click();
    await page.getByRole('option', { name: 'adyen_payout_rule_b' }).click();

    await ruleBasedConfiguration.distributeCheckboxNotSelected.click();
    await page.waitForTimeout(300);

    const input1 = ruleBasedConfiguration.percentageInput(1);
    const input2 = ruleBasedConfiguration.percentageInput(2);

    await expect(input1).toHaveValue("50");
    await expect(input2).toHaveValue("50");

    await input1.clear();
    await input1.fill("40");
    await input1.blur();
    await page.waitForTimeout(200);

    await expect(input1).toHaveValue("40");

    await expect(ruleBasedConfiguration.configureRuleButton).not.toBeEnabled();
  });

  test("should recalculate split percentages when removing a connector", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedPayoutRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'adyen_payout_rule_a' }).click();
    await page.getByRole('option', { name: 'adyen_payout_rule_b' }).click();
    await page.getByRole('option', { name: 'adyen_payout_rule_c' }).click();


    await ruleBasedConfiguration.distributeCheckboxNotSelected.click();

    let percentageInputs = page.locator(
      'input[name="1"], input[name="2"], input[name="3"]',
    );
    await expect(percentageInputs).toHaveCount(3);

    await ruleBasedConfiguration.removeFirstConnectorButton.click();

    percentageInputs = page.locator('input[name="1"], input[name="2"]');
    await expect(percentageInputs).toHaveCount(2, { timeout: 5000 });

    await expect(ruleBasedConfiguration.percentageInput(1)).toHaveValue("50");
    await expect(ruleBasedConfiguration.percentageInput(2)).toHaveValue("50");
  });

  test("should show validation error for missing configuration name", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedPayoutRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'adyen_payout_rule_a' }).click();

    const nameInput = ruleBasedConfiguration.configurationNameInput;
    await nameInput.click();
    await nameInput.clear();
    await nameInput.blur();

    await expect(
      page.getByText("Please provide name field", { exact: false }),
    ).toBeVisible();

    await volumeBasedConfiguration.descriptionTextbox.clear();
    await volumeBasedConfiguration.descriptionTextbox.blur();
    await expect(
      page.getByText("Please provide description field", { exact: false }),
    ).toBeVisible();
  });
});

test.describe("Payout Routing feature flag", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
  });

  test("should expose the Payout Routing menu under Workflows when payout flag is ON", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    await setPayoutFeatureFlag(page, true);
    await page.reload();

    await homePage.workflow.click();
    await expect(homePage.payoutRouting).toBeVisible();
  });

  test("should hide the Payout Routing menu when payout flag is OFF", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    await setPayoutFeatureFlag(page, false);
    await page.reload();

    await homePage.workflow.click();
    await expect(homePage.payoutRouting).toHaveCount(0);
  });
});
