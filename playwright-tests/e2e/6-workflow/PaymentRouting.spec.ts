import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentRouting } from "../../support/pages/workflow/paymentRouting/PaymentRouting";
import { DefaultFallback } from "../../support/pages/workflow/paymentRouting/DefaultFallback";
import { VolumeBasedConfiguration } from "../../support/pages/workflow/paymentRouting/VolumeBasedConfiguration";
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
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
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

    await expect(page.locator('[class="px-3 text-fs-16"]')).toContainText(
      "Please configure at least 1 connector",
    );
  });

  test("should display all elements in volume based routing page", async ({
    page,
    context,
  }) => {
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
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);

    await expect(paymentRouting.volumeBasedRoutingHeader).toContainText(
      "Smart routing configuration",
    );

    const currentDate = new Date().toLocaleDateString("en-CA", {
      timeZone: "Asia/Kolkata"
    });
    await expect(
      page.locator('[placeholder="Enter Configuration Name"]'),
    ).toHaveValue("Volume Based Routing-" + currentDate);

    await expect(page.locator('[name="description"]')).toContainText(
      "This is a volume based routing created at",
    );

    await volumeBasedConfiguration.connectorDropdown.click();
    await expect(page.locator(`[value="${connectorLabel}"]`)).toContainText(
      connectorLabel,
    );
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
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);

    await page.locator('[placeholder="Enter Configuration Name"]').clear();
    await page
      .locator('[placeholder="Enter Configuration Name"]')
      .fill("Test volume based config");

    await volumeBasedConfiguration.connectorDropdown.click();
    await page.locator('[value="stripe_test_1"]').click();
    await page.locator('[data-button-for="configureRule"]').click();
    await page.locator('[data-button-for="saveRule"]').click();

    await expect(
      page.locator('[data-toast="Successfully Created a new Configuration !"]'),
    ).toContainText("Successfully Created a new Configuration !");

    await page
      .locator('[class="flex flex-col cursor-pointer w-max"]')
      .nth(1)
      .click();

    await expect(
      page.locator('[data-table-location="History_tr1_td2"]'),
    ).toContainText("Test volume based config");
    await expect(page.locator('[data-label="INACTIVE"]')).toContainText(
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
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);

    await page.locator('[placeholder="Enter Configuration Name"]').clear();
    await page
      .locator('[placeholder="Enter Configuration Name"]')
      .fill("Test volume based config");

    await volumeBasedConfiguration.connectorDropdown.click();
    await page.locator('[value="stripe_test_1"]').click();
    await page.locator('[data-button-for="configureRule"]').click();
    await page.locator('[data-button-for="saveAndActivateRule"]').click();

    await expect(
      page.locator('[data-toast="Successfully Created a new Configuration !"]'),
    ).toContainText("Successfully Created a new Configuration !");

    await expect(
      page.locator('[data-toast="Successfully Activated !"]'),
    ).toContainText("Successfully Activated !");

    await expect(page.locator('[class="flex flex-col gap-3"]')).toContainText(
      "Test volume based config",
    );

    const activeIndicator = page.locator('[data-icon="check"]').first();
    await expect(activeIndicator).toBeVisible();
  });

  test("should validate volume percentage split", async ({
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
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);

    await volumeBasedConfiguration.connectorDropdown.click();
    await page.locator('[value="stripe_test_1"]').click();
    await page.locator('input[name="1"]').clear();
    await page.locator('input[name="1"]').fill("50");
    await expect(page.locator('[data-button-for="configureRule"]')).toBeDisabled();
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
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);

    await page.getByRole('textbox', { name: 'Enter Configuration Name' }).clear();
    await page.getByRole('textbox', { name: 'Enter Configuration Name' }).blur();
    await expect(page.getByText('Please provide name field')).toBeVisible();

    await page.getByRole('textbox', { name: 'Add a description for your' }).clear();
    await page.getByRole('textbox', { name: 'Add a description for your' }).blur();
    await expect(page.getByText('Please provide description')).toBeVisible();
  });
});

test.describe("Rule based routing", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display valid message when no connectors are connected", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.ruleBasedRoutingSetupButton.click();

    await expect(page.locator('[class="px-3 text-fs-16"]')).toContainText(
      "Please configure at least 1 connector",
    );
  });
});

test.describe("Payment default fallback", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
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

    await expect(page.locator('[class="px-3 text-2xl mt-32 "]')).toContainText(
      "Please connect atleast 1 connector",
    );
  });

  test("should display connected connectors in the list", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const defaultFallback = new DefaultFallback(page);

    const merchantId = await page
      .locator('[style="overflow-wrap: anywhere;"]')
      .nth(0)
      .textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
    }

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.defaultFallbackManageButton.click();

    await expect(
      defaultFallback.defaultFallbackList.locator("> div").nth(0),
    ).toContainText("stripe_test_1");
  });

  test("should be able to change the order by dragging and updating", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const defaultFallback = new DefaultFallback(page);

    const merchantId = await page.locator('[style="overflow-wrap: anywhere;"]').nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
      await createDummyConnectorAPI(merchantId, "stripe_test_2", context.request);
      await createDummyConnectorAPI(merchantId, "stripe_test_3", context.request);
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.defaultFallbackManageButton.click();

    const firstConnector = defaultFallback.defaultFallbackList.locator("> div").nth(0);
    const secondConnector = defaultFallback.defaultFallbackList.locator("> div").nth(1);

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

    const yesButton = page.getByRole("button", { name: "Yes, save it" });
    await yesButton.waitFor({ state: "visible", timeout: 5000 });
    await yesButton.click();

    await expect(page.locator('[data-toast="Configuration saved successfully!"]')).toBeVisible();
  });
});

test.describe("Routing list - Manage rules", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
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

  async function createInactiveVolumeRule(page: Page, context: BrowserContext, configName: string, connectorLabel = "stripe_test_1") {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createDummyConnectorAPI(merchantId, connectorLabel, context.request);
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();
    await expect(page).toHaveURL(/.*routing\/volume/);

    await page.locator('[placeholder="Enter Configuration Name"]').clear();
    await page.locator('[placeholder="Enter Configuration Name"]').fill(configName);

    await volumeBasedConfiguration.connectorDropdown.click();
    await page.locator(`[value="${connectorLabel}"]`).click();
    await page.locator('[data-button-for="configureRule"]').click();
    await page.locator('[data-button-for="saveRule"]').click();

    await expect(page.locator('[data-toast="Successfully Created a new Configuration !"]')).toContainText("Successfully Created a new Configuration !");
  }

  async function createActiveVolumeRule(page: Page, context: BrowserContext, configName: string, connectorLabel = "stripe_test_1") {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createDummyConnectorAPI(merchantId, connectorLabel, context.request);
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();
    await expect(page).toHaveURL(/.*routing\/volume/);

    await page.locator('[placeholder="Enter Configuration Name"]').clear();
    await page.locator('[placeholder="Enter Configuration Name"]').fill(configName);

    await volumeBasedConfiguration.connectorDropdown.click();
    await page.locator(`[value="${connectorLabel}"]`).click();
    await page.locator('[data-button-for="configureRule"]').click();
    await page.locator('[data-button-for="saveAndActivateRule"]').click();

    await expect(page.locator('[data-toast="Successfully Activated !"]')).toContainText("Successfully Activated !");
  }

  async function openManageRulesTab(page: Page) {
    const homePage = new HomePage(page);
    await homePage.workflow.click();
    await homePage.routing.click();
    await page.locator('[class="flex flex-col cursor-pointer w-max"]').nth(1).click();
  }

  test("verify routing page when elements", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const defaultFallback = new DefaultFallback(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await homePage.workflow.click();
    await homePage.routing.click();

    await expect(page.locator('div').filter({ hasText: /^Active$/ })).toBeVisible();
    await expect(page.getByText('Default fallback').nth(1)).toBeVisible();
    await expect(page.getByRole('button', { name: 'View and Manage' })).toBeVisible();

    await expect(page.getByText("Volume Based Configuration", { exact: true })).toBeVisible();
    await expect(page.getByText("Route traffic across various processors by volume distribution", { exact: true })).toBeVisible();

    await expect(page.getByText("Rule Based Configuration", { exact: true })).toBeVisible();
    await expect(page.getByText("Route traffic across processors with advanced logic rules on the basis of various payment parameters", { exact: true })).toBeVisible();

    await expect(page.getByText("Auth Rate Based Routing", { exact: true })).toBeVisible();
    await expect(page.getByText("Dynamically route payments to maximise payment authorization rates", { exact: true })).toBeVisible();

    await expect(page.getByText("Fallback is the priority list of configured processors used for routing traffic alone or when other rules don’t apply. You can reorder it via drag and drop", { exact: true })).toBeVisible();

    await expect(page.getByText("Least Cost Routing Configuration", { exact: true })).toBeVisible();
    await expect(page.getByText("Optimize processing fees on debit payments by routing traffic to the cheapest network", { exact: true }).first()).toBeVisible();

    await expect(page.getByRole("button", { name: "Setup" })).toHaveCount(4);
    await expect(page.getByRole('button', { name: 'Manage', exact: true })).toBeVisible();
  });

  test("should display default fallback when no other routing is configured", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const defaultFallback = new DefaultFallback(page);

    const merchantId = await page
      .locator('[style="overflow-wrap: anywhere;"]')
      .nth(0)
      .textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
    }

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await homePage.workflow.click();
    await homePage.routing.click();
    await expect(page.locator('div').filter({ hasText: /^Active$/ })).toBeVisible();
    await expect(page.getByText('Default fallback').nth(1)).toBeVisible();
    await expect(page.getByRole('button', { name: 'View and Manage' })).toBeVisible();

  });

  test("should display active routing configurations on Active configuration tab", async ({ page, context }) => {
    await createActiveVolumeRule(page, context, "List active smoke config");

    await expect(page.locator('div').filter({ hasText: /^Active$/ })).toBeVisible();
    await expect(page.getByText('List active smoke config -')).toBeVisible();
    await expect(page.getByRole('button', { name: 'View and Manage' })).toBeVisible();
  });

  test("should display all existing routing configurations on Manage rules tab", async ({ page, context }) => {
    await createInactiveVolumeRule(page, context, "List inactive smoke config");
    await createActiveVolumeRule(page, context, "List active smoke config", "stripe_test_2");

    await expect(page.getByText('List active smoke config -')).toBeVisible();
    await expect(page.getByRole('button', { name: 'View and Manage' })).toBeVisible();
    await openManageRulesTab(page);

    await expect(page.locator('[data-table-location="History_tr1_td2"]')).toContainText("List active smoke config");
    await expect(page.locator('[data-table-location="History_tr1_td3"]')).toContainText("Volume Based");
    await expect(page.locator('[data-table-location="History_tr1_td5"]')).toContainText("ACTIVE");

    await expect(page.locator('[data-table-location="History_tr2_td2"]')).toContainText("List inactive smoke config");
    await expect(page.locator('[data-table-location="History_tr2_td3"]')).toContainText("Volume Based");
    await expect(page.locator('[data-table-location="History_tr2_td5"]')).toContainText("INACTIVE");
  });

  test("should expose Activate Configuration on inactive rule preview", async ({ page, context }) => {
    await createInactiveVolumeRule(page, context, "Activate via preview");

    await openManageRulesTab(page);
    await page.locator('[data-table-location="History_tr1_td2"]').click();
    await page.waitForLoadState("networkidle");

    await expect(page.getByText('Configuration NameActivate')).toBeVisible();
    await expect(page.getByText('DescriptionThis is a volume')).toBeVisible();
    await expect(page.getByText('Volume Based Configuration is helpful when you want a specific traffic distribution for each of the configured connectors. For eg: Stripe (70%), Adyen (20%), Checkout (10%).')).toBeVisible();
    await expect(page.getByText('stripe_test_1')).toBeVisible();

    const activateBtn = page.getByRole("button", { name: /Activate Configuration/i }).first();
    await expect(activateBtn).toBeVisible({ timeout: 10000 });
    await activateBtn.click();
    await expect(page.locator('[data-toast="Successfully Activated !"]')).toContainText("Successfully Activated !");
  });

  test("should expose Deactivate Configuration on active rule preview", async ({ page, context }) => {
    await createActiveVolumeRule(page, context, "Deactivate via preview");

    await openManageRulesTab(page);
    await page.locator('[data-table-location="History_tr1_td2"]').click();
    await page.waitForLoadState("networkidle");

    const deactivateBtn = page.getByRole("button", { name: /Deactivate Configuration/i }).first();
    await expect(deactivateBtn).toBeVisible();
    await deactivateBtn.click();
    await expect(page.locator('[data-toast="Successfully Deactivated !"]')).toContainText("Successfully Deactivated !");
  });

  test("should duplicate and edit volume routing - update name and add a different connector", async ({ page, context }) => {
    await createActiveVolumeRule(page, context, "Volume edit original", "stripe_test_volume_a");

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createDummyConnectorAPI(merchantId, "stripe_test_volume_b", context.request);
    }

    await openManageRulesTab(page);
    await page.locator('[data-table-location="History_tr1_td2"]').click();
    await page.waitForLoadState("networkidle");

    const duplicateBtn = page.getByRole('button', { name: 'Duplicate & Edit Configuration' });
    await expect(duplicateBtn).toBeVisible({ timeout: 10000 });
    await duplicateBtn.click();

    const nameInput = page.locator('[placeholder="Enter Configuration Name"]');
    await nameInput.clear();
    await nameInput.fill("Volume edit updated");

    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);
    await volumeBasedConfiguration.connectorDropdown.click();
    await page.locator('[value="stripe_test_volume_b"]').click();

    await page.locator('[data-button-for="configureRule"]').click();
    await page.getByRole('button', { name: 'Save and Activate Rule' }).click();

    await expect(page.locator('[data-toast="Successfully Created a new Configuration !"]')).toContainText("Successfully Created a new Configuration !");

    await openManageRulesTab(page);
    await expect(page.locator('[data-table-location="History_tr1_td2"]')).toContainText("Volume edit updated");
  });

  test("should duplicate and edit rule routing - update name and configure a different value for a route", async ({ page, context }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    const merchantId = await getMerchantId(page);
    if (merchantId) {
      await createDummyConnectorAPI(merchantId, "stripe_routing_edit", context.request);
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.ruleBasedRoutingSetupButton.click();
    await page.waitForLoadState("networkidle");

    await page.locator('[placeholder*="Configuration Name"]').clear();
    await page.locator('[placeholder*="Configuration Name"]').fill("Rule edit original");

    await page.getByRole('button', { name: 'Select Field' }).click();
    await page.locator('div').filter({ hasText: /^currency$/ }).nth(5).click();

    await page.getByRole('button', { name: 'Select Operator' }).click();
    await page.locator('div').filter({ hasText: /^IS$/ }).nth(5).click();

    await page.getByRole('button', { name: 'Select Value' }).click();
    await page.locator('div').filter({ hasText: /^USD$/ }).nth(4).click();

    await page.getByRole('button', { name: 'Add Processors' }).click();
    await page.locator('div').filter({ hasText: /^stripe_routing_edit$/ }).nth(5).click();

    await page.getByRole('button', { name: 'Configure Rule' }).click();

    await page.getByRole('button', { name: 'Save and Activate Rule' }).click();
    await page.waitForLoadState("networkidle");

    await openManageRulesTab(page);
    await page.locator('[data-table-location="History_tr1_td2"]').click();
    await page.waitForLoadState("networkidle");

    const duplicateBtn = page.getByRole('button', { name: 'Duplicate and Edit' });
    await expect(duplicateBtn).toBeVisible({ timeout: 10000 });
    await duplicateBtn.click();

    const nameInput = page.locator('[placeholder*="Configuration Name"]');
    await nameInput.clear();
    await nameInput.fill("Rule edit updated");

    await page.getByRole('button', { name: 'USD' }).click();
    await page.locator('div').filter({ hasText: /^EUR$/ }).nth(4).click();
    await page.getByRole('button', { name: 'Configure Rule' }).click();

    await page.getByRole('button', { name: 'Save and Activate Rule' }).click();
    await page.waitForLoadState("networkidle");

    await openManageRulesTab(page);
    await expect(page.locator('[data-table-location="History_tr1_td2"]')).toContainText("Rule edit updated");
  });
});

test.describe("Auth rate based routing", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
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

    await expect(page.locator('[class="px-3 text-fs-16"]')).toContainText(
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
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.authRateBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/auth-rate/);

    await expect(page.getByText("Intelligent Routing Configuration")).toBeVisible();
    await expect(page.getByText("Dynamically route payments to maximise payment authorization rates.")).toBeVisible();

    await expect(authRateBasedConfiguration.bucketSizeInput).toBeVisible();
    await expect(authRateBasedConfiguration.explorationPercentInput).toBeVisible();
    await expect(authRateBasedConfiguration.rolloutPercentInput).toBeVisible();
  });

  test("should validate required form fields", async ({
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

    await expect(page.locator('div').filter({ hasText: /^Active$/ })).toBeVisible();
    await expect(page.getByText("Success rate based dynamic routing algorithm - Auth Rate Based Routing")).toBeVisible();
  });
});
