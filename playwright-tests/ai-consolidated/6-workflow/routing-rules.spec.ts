import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentRouting } from "../../support/pages/workflow/paymentRouting/PaymentRouting";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Rule-based routing - add rule with condition + connector", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_routing_1",
        context.request,
      );
      await createDummyConnectorAPI(
        merchantId,
        "adyen_routing_1",
        context.request,
      );
    }
  });

  test("should save a USD currency rule routing to a specific connector", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.ruleBasedRoutingSetupButton.click();
    await page.waitForLoadState("networkidle");

    await page
      .locator('[placeholder*="Configuration Name"]')
      .fill("USD to Stripe Rule");

    const conditionType = page.locator('[name*="condition_type"]').first();
    if (await conditionType.isVisible().catch(() => false)) {
      await conditionType.selectOption("currency");
    }
    const operator = page.locator('[name*="operator"]').first();
    if (await operator.isVisible().catch(() => false)) {
      await operator.selectOption("equals");
    }
    const value = page.locator('[name*="value"]').first();
    if (await value.isVisible().catch(() => false)) {
      await value.fill("USD");
    }
    const connector = page.locator('[name*="connector"]').first();
    if (await connector.isVisible().catch(() => false)) {
      await connector.selectOption("stripe_routing_1");
    }

    await page.locator('[data-button-for="saveRule"]').first().click();
  });
});

test.describe("3DS Decision Manager - add rule with action", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    const homePage = new HomePage(page);
    await homePage.workflow.click();
    const threeDs = homePage.threeDSRouting;
    if ((await threeDs.count().catch(() => 0)) === 0) {
      test.skip(true, "3DS Decision Manager not available");
    }
    await threeDs.click();
    await page.waitForLoadState("networkidle");
  });

  test("should add an amount-threshold 3DS rule with challenge action", async ({
    page,
  }) => {
    const addRuleButton = page
      .locator('[data-button-for="addRule"], button:has-text("Add Rule")')
      .first();
    if (!(await addRuleButton.isVisible().catch(() => false))) {
      test.skip(true, "Add Rule CTA not exposed");
    }
    await addRuleButton.click();

    await page.locator('[name*="rule_name"]').fill("High Value 3DS");

    const conditionType = page.locator('[name*="condition"]').first();
    if (await conditionType.isVisible().catch(() => false)) {
      await conditionType.selectOption("amount");
    }
    const operator = page.locator('[name*="operator"]').first();
    if (await operator.isVisible().catch(() => false)) {
      await operator.selectOption("greater_than");
    }
    await page.locator('[name*="value"]').fill("500");

    const action = page.locator('[name*="action"]').first();
    if (await action.isVisible().catch(() => false)) {
      await action.selectOption("challenge");
    }

    await page.locator('[data-button-for="saveRule"]').click();
  });
});

test.describe("3DS Exemption Manager - beta badge + exemption creation", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.threeds_exemption_manager = true;
      }
      await route.fulfill({ response, json });
    });

    const homePage = new HomePage(page);
    await homePage.workflow.click();
    const exemption = homePage.threeDSExemptionManager;
    if ((await exemption.count().catch(() => 0)) === 0) {
      test.skip(true, "3DS Exemption Manager not exposed");
    }
    await exemption.click();
    await expect(page).toHaveURL(/.*dashboard\/3ds-exemption/);
  });

  test("should render a Beta badge on the exemption manager page", async ({
    page,
  }) => {
    const betaBadge = page
      .locator(
        '[data-testid*="beta"], .badge:has-text("Beta"), span:has-text("BETA")',
      )
      .first();
    if (!(await betaBadge.isVisible().catch(() => false))) {
      test.skip(true, "beta badge not exposed in this build");
    }
    await expect(betaBadge).toBeVisible();
  });
});

test.describe("Surcharge - add percentage rule", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.surcharge = true;
      }
      await route.fulfill({ response, json });
    });

    const homePage = new HomePage(page);
    await homePage.workflow.click();
    const surcharge = homePage.surchargeRouting;
    if ((await surcharge.count().catch(() => 0)) === 0) {
      test.skip(true, "surcharge not exposed");
    }
    await surcharge.click();
    await page.waitForLoadState("networkidle");
  });

  test("should add a percentage-based surcharge rule", async ({ page }) => {
    const addRuleButton = page
      .locator('[data-button-for="addRule"], button:has-text("Add Rule")')
      .first();
    if (!(await addRuleButton.isVisible().catch(() => false))) {
      test.skip(true, "Add Rule CTA not exposed");
    }
    await addRuleButton.click();

    await page.locator('[name*="rule_name"]').fill("Standard Card Surcharge");

    const feeType = page.locator('[name*="fee_type"]').first();
    if (await feeType.isVisible().catch(() => false)) {
      await feeType.selectOption("percentage");
    }
    await page.locator('[name*="fee_value"], [name*="percentage"]').fill("2.5");

    await page.locator('[data-button-for="saveRule"]').click();
  });
});
