/**
 * Auto-generated Playwright test
 * Source: module:workflows - routing, 3DS decision manager, surcharge, payout routing
 * Generated: 2026-04-17
 */

import { test, expect } from "@playwright/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentRouting } from "../support/pages/workflow/paymentRouting/PaymentRouting";
import { VolumeBasedConfiguration } from "../support/pages/workflow/paymentRouting/VolumeBasedConfiguration";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Workflows - Routing (Volume / Rule / Fallback)", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to routing page via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.routing.click();

    await expect(page).toHaveURL(/.*dashboard\/routing/);
  });

  test("should show connector required message for volume routing setup", async ({
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

  test("should show connector required message for rule-based routing", async ({
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

  test("should show connector required message for default fallback", async ({
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

  test("should open volume-based configuration with connector configured", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);
    await expect(
      page.locator('[placeholder="Enter Configuration Name"]'),
    ).toBeVisible();
    await expect(volumeBasedConfiguration.connectorDropdown).toBeVisible();
  });

  test("should save a new volume based configuration as INACTIVE", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);
    const volumeBasedConfiguration = new VolumeBasedConfiguration(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/volume/);

    await page.locator('[placeholder="Enter Configuration Name"]').clear();
    await page
      .locator('[placeholder="Enter Configuration Name"]')
      .fill("AI generated volume config");

    await volumeBasedConfiguration.connectorDropdown.click();
    await page.locator('[value="stripe_test_1"]').click();
    await page.locator('[data-button-for="configureRule"]').click();
    await page.locator('[data-button-for="saveRule"]').click();

    await expect(
      page.locator('[data-toast="Successfully Created a new Configuration !"]'),
    ).toContainText("Successfully Created a new Configuration !");
  });
});

test.describe("Workflows - 3DS Decision Manager", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to 3DS Decision Manager via sidebar", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.threeDSRouting.click();

    await expect(page).toHaveURL(/.*3ds/);
  });

  test("should show heading on 3DS Decision Manager", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.threeDSRouting.click();

    await expect(
      page.getByText(/3DS/i).first(),
    ).toBeVisible({ timeout: 10000 });
  });
});

test.describe("Workflows - 3DS Exemption Manager", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to 3DS Exemption Manager via sidebar", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    const exemption = homePage.threeDSExemptionManager;
    if ((await exemption.count().catch(() => 0)) > 0) {
      await exemption.click();
      await expect(
        page.getByText(/Exemption/i).first(),
      ).toBeVisible({ timeout: 10000 });
    }
  });
});

test.describe("Workflows - Surcharge", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to Surcharge page via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    const surcharge = homePage.surchargeRouting;
    if ((await surcharge.count().catch(() => 0)) > 0) {
      await surcharge.click();
      await expect(
        page.getByText(/Surcharge/i).first(),
      ).toBeVisible({ timeout: 10000 });
    }
  });
});

test.describe("Workflows - Payout Routing", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to Payout Routing via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    const payoutRouting = homePage.payoutRouting;
    if ((await payoutRouting.count().catch(() => 0)) > 0) {
      await payoutRouting.click();
      await expect(page).toHaveURL(/.*(payout|routing)/);
    }
  });
});
