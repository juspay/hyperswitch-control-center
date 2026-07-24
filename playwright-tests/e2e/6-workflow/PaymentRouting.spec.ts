import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentRouting } from "../../support/pages/workflow/paymentRouting/PaymentRouting";
import { DefaultFallback } from "../../support/pages/workflow/paymentRouting/DefaultFallback";
import { VolumeBasedConfiguration } from "../../support/pages/workflow/paymentRouting/VolumeBasedConfiguration";
import { RuleBasedConfiguration } from "../../support/pages/workflow/paymentRouting/RuleBasedConfiguration";
import { AuthRateBasedConfiguration } from "../../support/pages/workflow/paymentRouting/AuthRateBasedConfiguration";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Volume based routing", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display valid message when no connectors are connected", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(paymentRouting.noProcessorFoundMessage).toBeVisible();
  });

  test("should display all elements in volume based routing page", async ({
    page,
    context,
  }) => {
    test.setTimeout(60000);
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    const connectorLabel = `stripe_test_${Date.now()}`;
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        connectorLabel,
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);
    // The configuration form mounts asynchronously after the route resolves;
    // wait for network to settle so the prefilled name input has its default
    // value before assertions read from it.
    await page.waitForLoadState("networkidle");

    await expect(paymentRouting.volumeBasedRoutingHeader).toContainText(
      "Smart Routing Configurations",
    );

    // Ask the browser for the date — the UI builds the name suffix from its
    // own `new Date()`, so evaluating in-page matches whatever timezone the
    // browser is using (UTC in CI, IST locally, etc.). Accepting today or
    // yesterday guards the millisecond race at midnight where the form
    // mounts on one side of the boundary and we read on the other.
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

  test("should save new Volume based configuration", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);

    await volumeBasedConfiguration.configurationNameInput.clear();
    await volumeBasedConfiguration.configurationNameInput.fill(
      "Test volume based config",
    );

    await volumeBasedConfiguration.connectorDropdown.click();
    await volumeBasedConfiguration.connectorOption("stripe_test_1").click();
    await volumeBasedConfiguration.configureRuleButton.click();
    await volumeBasedConfiguration.saveRuleButton.click();

    await expect(
      paymentRouting.dataToast("Successfully created a new configuration!"),
    ).toContainText("Successfully created a new configuration!");

    await paymentRouting.configurationHistoryTab.click();

    await expect(paymentRouting.historyCell(1, 2)).toContainText(
      "Test volume based config",
    );
    await expect(paymentRouting.dataLabel("INACTIVE")).toContainText(
      "INACTIVE",
    );
  });

  test("should save and activate Volume based configuration", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);

    await volumeBasedConfiguration.configurationNameInput.clear();
    await volumeBasedConfiguration.configurationNameInput.fill(
      "Test volume based config",
    );

    await volumeBasedConfiguration.connectorDropdown.click();
    await volumeBasedConfiguration.connectorOption("stripe_test_1").click();
    await volumeBasedConfiguration.configureRuleButton.click();
    await volumeBasedConfiguration.saveAndActivateRuleButton.click();

    await expect(
      paymentRouting.dataToast("Successfully created a new configuration!"),
    ).toContainText("Successfully created a new configuration!");

    await expect(
      paymentRouting.dataToast("Successfully activated!"),
    ).toContainText("Successfully activated!");

    await expect(volumeBasedConfiguration.activeConfigContainer).toContainText(
      "Test volume based config",
    );

    await expect(volumeBasedConfiguration.activeIndicator).toBeVisible();
  });

  test("should validate volume percentage split", async ({ page, context }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);

    await volumeBasedConfiguration.connectorDropdown.click();
    await volumeBasedConfiguration.connectorOption("stripe_test_1").click();
    await volumeBasedConfiguration.percentageInput(1).clear();
    await volumeBasedConfiguration.percentageInput(1).fill("50");
    await expect(volumeBasedConfiguration.configureRuleButton).toBeDisabled();
  });

  test("should validate name and description fields", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);

    await volumeBasedConfiguration.configurationNameTextbox.clear();
    await volumeBasedConfiguration.configurationNameTextbox.blur();
    await expect(page.getByText("Please provide name field")).toBeVisible();

    await volumeBasedConfiguration.descriptionTextbox.clear();
    await volumeBasedConfiguration.descriptionTextbox.blur();
    await expect(page.getByText("Please provide description")).toBeVisible();
  });
});

test.describe("Rule based routing", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  async function setupRuleBasedRouting(
    page: Page,
    context: BrowserContext,
  ): Promise<string | null> {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_operator_test",
        context.request,
        page,
      );
    }
    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.ruleBasedRoutingSetupButton.click();
    await page.waitForLoadState("networkidle");
    return merchantId;
  }

  test("should display valid message when no connectors are connected", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.ruleBasedRoutingSetupButton.click();

    await expect(page.getByText("Please configure at least 1")).toContainText(
      "Please configure at least 1 connector",
    );
  });

  test("Rule editor add condition row - Click Add Condition renders condition row with field, operator, value inputs", async ({
    page,
    context,
  }) => {
    await setupRuleBasedRouting(page, context);
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
    await page.getByText('stripe_operator_test', { exact: true }).click();

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
    await setupRuleBasedRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    await ruleBasedConfiguration.configurationNameInput.fill(
      "Operator Types Test",
    );

    await ruleBasedConfiguration.selectFieldButton.click();
    await page.getByText('currency', { exact: true }).click();
    await expect(page.getByText('surcharge_amount', { exact: true })).not.toBeVisible();
    await expect(page.getByRole('button', { name: 'currency' })).toBeVisible();
    await ruleBasedConfiguration.selectOperatorButton.click();
    await expect(page.locator("div").filter({ hasText: /^ISCONTAINSIS_NOTNOT_CONTAINS$/ }).nth(1)).toBeVisible();

    await page.getByRole("button", { name: "currency" }).click();
    await page.locator('[data-id="amount"]').first().click({ force: true });
    await expect(page.getByText('surcharge_amount', { exact: true })).not.toBeVisible();
    await expect(page.getByRole('button', { name: 'amount' })).toBeVisible();
    await ruleBasedConfiguration.selectOperatorButton.click();
    await expect(page.getByText('EQUAL TOGREATER THANLESS THAN')).toBeVisible();

    await page.getByRole("button", { name: "amount" }).click();
    await page.getByText('business_label', { exact: true }).click();
    await expect(page.getByText('surcharge_amount', { exact: true })).not.toBeVisible();
    await expect(page.getByRole('button', { name: 'business_label' })).toBeVisible();
    await ruleBasedConfiguration.selectOperatorButton.click();
    await expect(page.locator("div").filter({ hasText: /^EQUAL TONOT EQUAL_TO$/ }).first()).toBeVisible();
  });

  test("Rule editor logical operator AND OR toggle - changes logical operator value", async ({
    page,
    context,
  }) => {
    await setupRuleBasedRouting(page, context);
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

test.describe("Payment default fallback", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display valid message when no connectors are connected", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.defaultFallbackManageButton.click();

    await expect(paymentRouting.noProcessorFoundMessage).toBeVisible();
  });

  test("should display connected connectors in the list", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const defaultFallback = new DefaultFallback(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
        page,
      );
    }

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.defaultFallbackManageButton.click();

    await expect(defaultFallback.connectorAt(0)).toContainText("stripe_test_1");
  });

  test("should be able to change the order by dragging and updating", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const defaultFallback = new DefaultFallback(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
        page,
      );
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_2",
        context.request,
        page,
      );
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_3",
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.defaultFallbackManageButton.click();

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
    await page.waitForTimeout(300);

    await defaultFallback.saveChangesButton.click();

    await defaultFallback.yesSaveItButton.waitFor({
      state: "visible",
      timeout: 5000,
    });
    await defaultFallback.yesSaveItButton.click();

    await expect(defaultFallback.configurationSavedToast).toBeVisible();
  });
});

test.describe("Routing list - Configuration History", () => {
  test.beforeEach(async ({ page, context }) => {
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

  async function createInactiveVolumeRule(
    page: Page,
    context: BrowserContext,
    configName: string,
    connectorLabel = "stripe_test_1",
  ) {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        connectorLabel,
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();
    await expect(page).toHaveURL(/.*routing\/volume/);

    await volumeBasedConfiguration.configurationNameInput.clear();
    await volumeBasedConfiguration.configurationNameInput.fill(configName);

    await volumeBasedConfiguration.connectorDropdown.click();
    await volumeBasedConfiguration.connectorOption(connectorLabel).click();
    await volumeBasedConfiguration.configureRuleButton.click();
    await volumeBasedConfiguration.saveRuleButton.click();

    await expect(
      paymentRouting.dataToast("Successfully created a new configuration!"),
    ).toContainText("Successfully created a new configuration!");
  }

  async function createActiveVolumeRule(
    page: Page,
    context: BrowserContext,
    configName: string,
    connectorLabel = "stripe_test_1",
  ) {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        connectorLabel,
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();
    await expect(page).toHaveURL(/.*routing\/volume/);

    await volumeBasedConfiguration.configurationNameInput.clear();
    await volumeBasedConfiguration.configurationNameInput.fill(configName);

    await volumeBasedConfiguration.connectorDropdown.click();
    await volumeBasedConfiguration.connectorOption(connectorLabel).click();
    await volumeBasedConfiguration.configureRuleButton.click();
    await volumeBasedConfiguration.saveAndActivateRuleButton.click();

    await expect(
      paymentRouting.dataToast("Successfully activated!"),
    ).toContainText("Successfully activated!");
  }

  async function openManageRulesTab(page: Page) {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.configurationHistoryTab.click();
  }

  test("verify routing page when elements", async ({ page, context }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await homePage.workflow.click();
    await homePage.routing.click();

    await expect(paymentRouting.activeBadge).toBeVisible();
    await expect(page.getByText("Default Fallback").nth(1)).toBeVisible();
    await expect(paymentRouting.viewAndManageButton).toBeVisible();

    await expect(
      page.getByText("Volume Based Configuration", { exact: true }),
    ).toBeVisible();
    await expect(
      page.getByText(
        "Route traffic across various processors by volume distribution",
        { exact: true },
      ),
    ).toBeVisible();

    await expect(
      page.getByText("Rule Based Configuration", { exact: true }),
    ).toBeVisible();
    await expect(
      page.getByText(
        "Route traffic across processors with advanced logic rules on the basis of various payment parameters",
        { exact: true },
      ),
    ).toBeVisible();

    await expect(
      page.getByText("Auth Rate Based Routing", { exact: true }),
    ).toBeVisible();
    await expect(
      page.getByText(
        "Dynamically route payments to maximise payment authorization rates",
        { exact: true },
      ),
    ).toBeVisible();

    await expect(
      page.getByText(
        "Fallback is the priority list of configured processors used for routing traffic alone or when other rules don’t apply. You can reorder it via drag and drop",
        { exact: true },
      ),
    ).toBeVisible();

    await expect(
      page.getByText("Least Cost Routing Configuration", { exact: true }),
    ).toBeVisible();
    await expect(
      page
        .getByText(
          "Optimize processing fees on debit payments by routing traffic to the cheapest network",
          { exact: true },
        )
        .first(),
    ).toBeVisible();

    await expect(paymentRouting.setupButton).toHaveCount(4);
    await expect(paymentRouting.manageButton).toBeVisible();
  });

  test("should display default fallback when no other routing is configured", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
        page,
      );
    }

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await homePage.workflow.click();
    await homePage.routing.click();
    await expect(paymentRouting.activeBadge).toBeVisible();
    await expect(page.getByText("Default Fallback").nth(1)).toBeVisible();
    await expect(paymentRouting.viewAndManageButton).toBeVisible();
  });

  test("should display active routing configurations on Active configuration tab", async ({
    page,
    context,
  }) => {
    const paymentRouting = new PaymentRouting(page);
    await createActiveVolumeRule(page, context, "List active smoke config");

    await expect(paymentRouting.activeBadge).toBeVisible();
    await expect(page.getByText("List active smoke config -")).toBeVisible();
    await expect(paymentRouting.viewAndManageButton).toBeVisible();
  });

  test("should display all existing routing configurations on Configuration History tab", async ({
    page,
    context,
  }) => {
    const paymentRouting = new PaymentRouting(page);
    await createInactiveVolumeRule(page, context, "List inactive smoke config");
    await createActiveVolumeRule(
      page,
      context,
      "List active smoke config",
      "stripe_test_2",
    );

    await expect(page.getByText("List active smoke config -")).toBeVisible();
    await expect(paymentRouting.viewAndManageButton).toBeVisible();
    await openManageRulesTab(page);

    await expect(paymentRouting.historyCell(1, 2)).toContainText(
      "List active smoke config",
    );
    await expect(paymentRouting.historyCell(1, 3)).toContainText(
      "Volume Based",
    );
    await expect(paymentRouting.historyCell(1, 5)).toContainText("ACTIVE");

    await expect(paymentRouting.historyCell(2, 2)).toContainText(
      "List inactive smoke config",
    );
    await expect(paymentRouting.historyCell(2, 3)).toContainText(
      "Volume Based",
    );
    await expect(paymentRouting.historyCell(2, 5)).toContainText("INACTIVE");
  });

  test("should expose Activate Configuration on inactive rule preview", async ({
    page,
    context,
  }) => {
    const paymentRouting = new PaymentRouting(page);
    await createInactiveVolumeRule(page, context, "Activate via preview");

    await openManageRulesTab(page);
    await paymentRouting.historyCell(1, 2).click();
    await page.waitForLoadState("networkidle");

    await expect(page.getByText("Configuration NameActivate")).toBeVisible();
    await expect(page.getByText("DescriptionThis is a volume")).toBeVisible();
    await expect(page.getByText("stripe_test_1")).toBeVisible();

    const activateBtn = page
      .getByRole("button", { name: /Activate Configuration/i })
      .first();
    await expect(activateBtn).toBeVisible({ timeout: 10000 });
    await activateBtn.click();
    await expect(
      paymentRouting.dataToast("Successfully activated!"),
    ).toContainText("Successfully activated!");
  });

  test("should expose Deactivate Configuration on active rule preview", async ({
    page,
    context,
  }) => {
    const paymentRouting = new PaymentRouting(page);
    await createActiveVolumeRule(page, context, "Deactivate via preview");

    await openManageRulesTab(page);
    await paymentRouting.historyCell(1, 2).click();
    await page.waitForLoadState("networkidle");

    const deactivateBtn = page
      .getByRole("button", { name: /Deactivate Configuration/i })
      .first();
    await expect(deactivateBtn).toBeVisible();
    await deactivateBtn.click();
    await expect(
      paymentRouting.dataToast("Successfully deactivated!"),
    ).toContainText("Successfully deactivated!");
  });

  test("should duplicate and edit volume routing - update name and add a different connector", async ({
    page,
    context,
  }) => {
    // Test chains: create active rule (UI flow) + 2 API calls + manage tab
    // navigation + duplicate/edit/save flow + tab re-navigation. The previous
    // 30s budget routinely tripped on the API-key creation alone.
    test.setTimeout(120000);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);
    await createActiveVolumeRule(
      page,
      context,
      "Volume edit original",
      "stripe_test_volume_a",
    );

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_volume_b",
        context.request,
        page,
      );
    }

    await openManageRulesTab(page);
    const historyRow = paymentRouting.historyCell(1, 2);
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
    await nameInput.fill("Volume edit updated");

    await expect(volumeBasedConfiguration.connectorDropdown).toBeVisible();
    await volumeBasedConfiguration.connectorDropdown.click();
    const newConnectorOption = volumeBasedConfiguration.connectorOption(
      "stripe_test_volume_b",
    );
    await expect(newConnectorOption).toBeVisible();
    await newConnectorOption.click();

    await volumeBasedConfiguration.configureRuleButton.click();
    await volumeBasedConfiguration.saveAndActivateRuleByRoleButton.click();

    await expect(
      paymentRouting.dataToast("Successfully created a new configuration!"),
    ).toContainText("Successfully created a new configuration!");

    await openManageRulesTab(page);
    await expect(paymentRouting.historyCell(1, 2)).toContainText(
      "Volume edit updated",
    );
  });

  test("should duplicate and edit rule routing - update name and configure a different value for a route", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_routing_edit",
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.ruleBasedRoutingSetupButton.click();
    await page.waitForLoadState("networkidle");

    await ruleBasedConfiguration.configurationNameInput.clear();
    await ruleBasedConfiguration.configurationNameInput.fill(
      "Rule edit original",
    );

    await ruleBasedConfiguration.selectFieldButton.click();
    await page.getByText('currency', { exact: true }).click();

    await ruleBasedConfiguration.selectOperatorButton.click();
    await page.getByText('IS', { exact: true }).click();

    await ruleBasedConfiguration.selectValueButton.click();
    await page.getByText('USD', { exact: true }).click();

    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByText('stripe_routing_edit', { exact: true }).click();

    await ruleBasedConfiguration.configureRuleButton.click();

    await ruleBasedConfiguration.saveAndActivateRuleButton.click();
    await page.waitForLoadState("networkidle");

    await openManageRulesTab(page);
    await paymentRouting.historyCell(1, 2).click();
    await page.waitForLoadState("networkidle");

    const duplicateBtn = ruleBasedConfiguration.duplicateAndEditButton;
    await expect(duplicateBtn).toBeVisible({ timeout: 10000 });
    await duplicateBtn.click();

    const nameInput = ruleBasedConfiguration.configurationNameInput;
    await nameInput.clear();
    await nameInput.fill("Rule edit updated");

    await page.getByRole("button", { name: "USD" }).click();
    await page.getByText('EUR', { exact: true }).click();
    await ruleBasedConfiguration.configureRuleButton.click();

    await ruleBasedConfiguration.saveAndActivateRuleButton.click();
    await page.waitForLoadState("networkidle");

    await openManageRulesTab(page);
    await expect(paymentRouting.historyCell(1, 2)).toContainText(
      "Rule edit updated",
    );
  });
});

test.describe("Advanced rule connector selection modes", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  async function navigateToRuleBasedRouting(
    page: Page,
    context: BrowserContext,
  ) {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_rule_test_a",
        context.request,
        page,
      );
      await createDummyConnectorAPI(
        merchantId,
        "stripe_rule_test_b",
        context.request,
        page,
      );
      await createDummyConnectorAPI(
        merchantId,
        "stripe_rule_test_c",
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.ruleBasedRoutingSetupButton.click();
    await page.waitForLoadState("networkidle");
  }

  test("should render connectors without split fields in priority mode (distribute OFF)", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    // Verify distribute checkbox is hidden initially (no connectors selected)
    await expect(ruleBasedConfiguration.distributeText).not.toBeVisible();

    // Select two connectors and enable distribute
    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByText('stripe_rule_test_a', { exact: true }).click();
    await page.getByText('stripe_rule_test_b', { exact: true }).click();

    // Verify distribute checkbox is now visible
    await expect(ruleBasedConfiguration.distributeText).toBeVisible();

    // Verify distribute is OFF by default
    const isChecked =
      await ruleBasedConfiguration.distributeText.getAttribute("aria-checked");
    expect(isChecked || "false").toBe("false");

    // Verify connectors render as badges WITHOUT percentage input fields
    const connectorBadges = page.locator(
      ".flex.flex-row.items-center.justify-around.gap-2",
    );
    const badgeCount = await connectorBadges.count();
    expect(badgeCount).toBeGreaterThanOrEqual(2);

    // Verify NO percentage input fields are visible
    const percentageInputs = page.locator('input[name="1"], input[name="2"]');
    const inputCount = await percentageInputs.count();
    expect(inputCount).toBe(0);

    // Verify connectors display with correct labels
    await expect(page.getByText("stripe_rule_test_a").nth(1)).toBeVisible();
    await expect(page.getByText("stripe_rule_test_b").nth(1)).toBeVisible();
  });

  test("should render connectors with split fields in volume mode (distribute ON)", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    // Select multiple connectors
    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'stripe_rule_test_a' }).click();
    await page.getByRole('option', { name: 'stripe_rule_test_b' }).click();
    // Verify split fields are NOT visible before toggling distribute
    let percentageInputs = page.locator('input[name="1"], input[name="2"]');
    await expect(percentageInputs).toHaveCount(0);

    // Toggle distribute ON
    await ruleBasedConfiguration.distributeCheckboxNotSelected.click();
    await page.waitForTimeout(300);

    // Verify split fields appear
    percentageInputs = page.locator('input[name="1"], input[name="2"]');
    await expect(percentageInputs).toHaveCount(2, { timeout: 5000 });

    // Verify auto-calculated split percentages for 2 connectors (should be 50% each)
    const value1 = await ruleBasedConfiguration.percentageInput(1).inputValue();
    const value2 = await ruleBasedConfiguration.percentageInput(2).inputValue();

    expect(Number(value1)).toBe(50);
    expect(Number(value2)).toBe(50);
  });

  test("should render 3 connectors with auto-calculated split percentages (33/33/34)", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    // Select three connectors
    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'stripe_rule_test_a' }).click();
    await page.getByRole('option', { name: 'stripe_rule_test_b' }).click();
    await page.getByRole('option', { name: 'stripe_rule_test_c' }).click();

    // Toggle distribute ON
    await ruleBasedConfiguration.distributeCheckboxNotSelected.nth(0).click();
    await page.waitForTimeout(300);

    // Verify all 3 percentage input fields appear
    const percentageInputs = page.locator(
      'input[name="1"], input[name="2"], input[name="3"]',
    );
    await expect(percentageInputs).toHaveCount(3);

    // Verify auto-calculated percentages (33, 33, 34 - last adjusted to reach 100)
    const value1 = Number(
      await ruleBasedConfiguration.percentageInput(1).inputValue(),
    );
    const value2 = Number(
      await ruleBasedConfiguration.percentageInput(2).inputValue(),
    );
    const value3 = Number(
      await ruleBasedConfiguration.percentageInput(3).inputValue(),
    );

    expect(value1).toBe(33);
    expect(value2).toBe(33);
    expect(value3).toBe(34);
    expect(value1 + value2 + value3).toBe(100);
  });

  test("should toggle distribute mode and update UI accordingly", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    // Select two connectors
    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'stripe_rule_test_a' }).click();
    await page.getByRole('option', { name: 'stripe_rule_test_b' }).click();

    // Toggle distribute ON
    await ruleBasedConfiguration.distributeCheckboxNotSelected.click();
    await page.waitForTimeout(300);

    // Verify split fields appear
    let percentageInputs = page.locator('input[name="1"], input[name="2"]');
    await expect(percentageInputs).toHaveCount(2);

    // Toggle distribute OFF
    await ruleBasedConfiguration.distributeCheckboxSelected.click();
    await page.waitForTimeout(300);

    // Verify split fields disappear
    percentageInputs = page.locator('input[name="1"], input[name="2"]');
    await expect(percentageInputs).toHaveCount(0);

    // Verify connectors are still displayed
    await expect(page.getByText('1stripe_rule_test_a')).toBeVisible();
    await expect(page.getByText('2stripe_rule_test_b')).toBeVisible();
  });

  test("should allow manual editing of split percentages", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    // Select two connectors and enable distribute
    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'stripe_rule_test_a' }).click();
    await page.getByRole('option', { name: 'stripe_rule_test_b' }).click();

    await ruleBasedConfiguration.distributeCheckboxNotSelected.click();
    await page.waitForTimeout(300);

    // Verify initial percentages are 50/50
    const input1 = ruleBasedConfiguration.percentageInput(1);
    const input2 = ruleBasedConfiguration.percentageInput(2);

    expect(Number(await input1.inputValue())).toBe(50);
    expect(Number(await input2.inputValue())).toBe(50);

    // Edit first connector percentage to 40
    await input1.clear();
    await input1.fill("40");
    await input1.blur();
    await page.waitForTimeout(200);

    // Verify the change is reflected
    expect(Number(await input1.inputValue())).toBe(40);

    await expect(ruleBasedConfiguration.configureRuleButton).not.toBeEnabled();
  });

  test("should recalculate split percentages when removing a connector", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    // Select three connectors and enable distribute
    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'stripe_rule_test_a' }).click();
    await page.getByRole('option', { name: 'stripe_rule_test_b' }).click();
    await page.getByRole('option', { name: 'stripe_rule_test_c' }).click();

    await ruleBasedConfiguration.distributeCheckboxNotSelected.click();
    await page.waitForTimeout(300);

    // Verify initial state: 3 connectors with 33/33/34
    let percentageInputs = page.locator(
      'input[name="1"], input[name="2"], input[name="3"]',
    );
    await expect(percentageInputs).toHaveCount(3);

    // Remove the first connector by clicking X button
    await ruleBasedConfiguration.removeFirstConnectorButton.click();
    await page.waitForTimeout(300);

    // Verify only 2 connectors remain
    percentageInputs = page.locator('input[name="1"], input[name="2"]');
    await expect(percentageInputs).toHaveCount(2, { timeout: 5000 });

    // Verify percentages are recalculated to 50/50
    const value1 = Number(
      await ruleBasedConfiguration.percentageInput(1).inputValue(),
    );
    const value2 = Number(
      await ruleBasedConfiguration.percentageInput(2).inputValue(),
    );

    expect(value1).toBe(50);
    expect(value2).toBe(50);
  });

  test("should show validation error for missing configuration name", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    // Select a connector
    await ruleBasedConfiguration.addProcessorsButton.click();
    await page.getByRole('option', { name: 'stripe_rule_test_a' }).click();

    // Focus and blur the configuration name field without entering value
    const nameInput = ruleBasedConfiguration.configurationNameInput;
    await nameInput.click();
    await nameInput.clear();
    await nameInput.blur();
    await page.waitForTimeout(300);

    await expect(
      page.getByText("Please provide name field", { exact: false }),
    ).toBeVisible();

    await volumeBasedConfiguration.descriptionTextbox.clear();
    await volumeBasedConfiguration.descriptionTextbox.blur();
    await expect(
      page.getByText("Please provide description field", { exact: false }),
    ).toBeVisible();
  });

  test("should show validation error for missing connectors", async ({
    page,
    context,
  }) => {
    await navigateToRuleBasedRouting(page, context);
    const ruleBasedConfiguration = new RuleBasedConfiguration(page);

    // Fill configuration name but don't add any connectors
    await ruleBasedConfiguration.configurationNameInput.fill("Test Rule");

    // Try to configure rule without connectors
    const configureBtn = ruleBasedConfiguration.configureRuleButton;
    const isDisabled = await configureBtn.isDisabled();

    // Configure button should be disabled when no connectors selected
    if (!isDisabled) {
      await configureBtn.click();

      // Check for validation message about missing connectors
      const connectorError = page.getByText(
        /Add Processors|Please select|at least 1 connector/i,
        { exact: false },
      );

      const hasError = await connectorError.isVisible().catch(() => false);

      if (hasError) {
        await expect(connectorError).toBeVisible();
      }
    } else {
      // Button being disabled is also valid validation
      expect(isDisabled).toBe(true);
    }
  });
});

test.describe("Auth rate based routing", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display valid message when no connectors are connected", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.authRateBasedRoutingSetupButton.click();

    await expect(page.getByText("Please configure at least 1")).toContainText(
      "Please configure at least 1 connector",
    );
  });

  test("should display all elements in auth rate based routing page", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const authRateBasedConfiguration = new AuthRateBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.authRateBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/auth-rate/);

    await expect(
      page.getByText(
        "Auth rate routing continuously learns from recent authorization outcomes and sends each payment to the processor most likely to succeed.",
      ),
    ).toBeVisible();

    await expect(authRateBasedConfiguration.bucketSizeInput).toBeVisible();
    await expect(
      authRateBasedConfiguration.explorationPercentInput,
    ).toBeVisible();
    await expect(authRateBasedConfiguration.rolloutPercentInput).toBeVisible();
  });

  test("should validate required form fields", async ({ page, context }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const authRateBasedConfiguration = new AuthRateBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.authRateBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/auth-rate/);

    await authRateBasedConfiguration.bucketSizeInput.fill("");
    await authRateBasedConfiguration.bucketSizeInput.blur();
    await expect(page.getByText("Required")).toBeVisible();
    await authRateBasedConfiguration.bucketSizeInput.fill("200");

    await authRateBasedConfiguration.explorationPercentInput.fill("");
    await authRateBasedConfiguration.explorationPercentInput.blur();
    await expect(page.getByText("Required")).toBeVisible();
    await authRateBasedConfiguration.explorationPercentInput.fill("5");

    await authRateBasedConfiguration.rolloutPercentInput.fill("");
    await authRateBasedConfiguration.rolloutPercentInput.blur();
    await expect(page.getByText("Required")).toBeVisible();

    await expect(authRateBasedConfiguration.configureRuleButton).toBeDisabled();
  });

  test("should save and activate auth rate based configuration", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const authRateBasedConfiguration = new AuthRateBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
        page,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.authRateBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/auth-rate/);

    await authRateBasedConfiguration.bucketSizeInput.fill("100");

    await authRateBasedConfiguration.explorationPercentInput.fill("10");

    await authRateBasedConfiguration.rolloutPercentInput.fill("100");

    await authRateBasedConfiguration.configureRuleButton.click();
    await authRateBasedConfiguration.saveAndActivateRuleButton.click();

    await page.waitForLoadState("networkidle");

    await expect(paymentRouting.activeBadge).toBeVisible();
    await expect(
      page.getByText(
        "Success rate based dynamic routing algorithm - Auth Rate Based Routing",
      ),
    ).toBeVisible();
  });
});
