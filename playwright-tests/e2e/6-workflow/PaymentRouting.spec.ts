import { test, expect } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentRouting } from "../../support/pages/workflow/paymentRouting/PaymentRouting";
import { DefaultFallback } from "../../support/pages/workflow/paymentRouting/DefaultFallback";
import { VolumeBasedConfiguration } from "../../support/pages/workflow/paymentRouting/VolumeBasedConfiguration";
import {
  generateUniqueEmail,
  generateDateTimeString,
} from "../../support/helper";
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
      page.locator('[data-toast="Successfully created a new configuration!"]'),
    ).toContainText("Successfully created a new configuration!");

    await page.getByRole("tab", { name: "Manage rules" }).click();

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
      page.locator('[data-toast="Successfully created a new configuration!"]'),
    ).toContainText("Successfully created a new configuration!");

    await expect(
      page.locator('[data-toast="Successfully activated!"]'),
    ).toContainText("Successfully activated!");

    await expect(page.locator('[class="flex flex-col gap-3"]')).toContainText(
      "Test volume based config",
    );

    const activeIndicator = page.locator('[data-icon="check"]').first();
    await expect(activeIndicator).toBeVisible();
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
      "Please connect at least 1 connector",
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

  test.skip("should be able to change the order by dragging and updating", async ({
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
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_2",
        context.request,
      );
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_3",
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.defaultFallbackManageButton.click();

    const firstConnector = defaultFallback.defaultFallbackList
      .locator("> div")
      .nth(0);
    const secondConnector = defaultFallback.defaultFallbackList
      .locator("> div")
      .nth(1);

    await firstConnector.dragTo(secondConnector);

    await defaultFallback.saveChangesButton.click();

    await expect(
      page.locator('[data-toast="Routing configuration updated successfully"]'),
    ).toBeVisible();
  });
});
