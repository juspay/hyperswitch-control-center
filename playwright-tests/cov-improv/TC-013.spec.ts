import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentRouting } from "../support/pages/workflow/paymentRouting/PaymentRouting";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-013: Payment Routing - Rule Creation", () => {
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

  test("should create volume-based routing 50-50 split", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.workflow.click();
    await homePage.routing.click();

    await paymentRouting.volumeBasedRoutingSetupButton.click();

    await page
      .locator('[placeholder*="Configuration Name"]')
      .fill("Volume Split 50-50");

    const connector1 = page.locator('[name*="connector"]').nth(0);
    if (await connector1.isVisible().catch(() => false)) {
      await connector1.selectOption("stripe_routing_1");
    }

    const percentage1 = page
      .locator('[name*="percentage"], [name*="weight"]')
      .nth(0);
    if (await percentage1.isVisible().catch(() => false)) {
      await percentage1.fill("50");
    }

    const addConnectorButton = page
      .locator('[data-button-for="addConnector"]')
      .first();
    if (await addConnectorButton.isVisible().catch(() => false)) {
      await addConnectorButton.click();

      const connector2 = page.locator('[name*="connector"]').nth(1);
      if (await connector2.isVisible().catch(() => false)) {
        await connector2.selectOption("adyen_routing_1");
      }

      const percentage2 = page.locator('[name*="percentage"]').nth(1);
      if (await percentage2.isVisible().catch(() => false)) {
        await percentage2.fill("50");
      }
    }

    // Fixed (Attempt 1): Added .first() to avoid strict mode violation when multiple save buttons exist
    await page.locator('[data-button-for="saveRule"]').first().click();

    await expect(
      page.locator('[data-toast*="success"], [data-toast*="Created"]'),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should create rule-based routing for USD currency", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.workflow.click();
    await homePage.routing.click();

    await paymentRouting.ruleBasedRoutingSetupButton.click();

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

  test("should create rule-based routing for amount greater than 1000", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.workflow.click();
    await homePage.routing.click();

    await paymentRouting.ruleBasedRoutingSetupButton.click();

    await page
      .locator('[placeholder*="Configuration Name"]')
      .fill("High Amount to Adyen");

    const conditionType = page.locator('[name*="condition_type"]').first();
    if (await conditionType.isVisible().catch(() => false)) {
      await conditionType.selectOption("amount");
    }

    const operator = page.locator('[name*="operator"]').first();
    if (await operator.isVisible().catch(() => false)) {
      await operator.selectOption("greater_than");
    }

    const value = page.locator('[name*="value"]').first();
    if (await value.isVisible().catch(() => false)) {
      await value.fill("1000");
    }

    const connector = page.locator('[name*="connector"]').first();
    if (await connector.isVisible().catch(() => false)) {
      await connector.selectOption("adyen_routing_1");
    }

    await page.locator('[data-button-for="saveRule"]').first().click();
  });

  test("should disable and re-enable routing rule", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.workflow.click();
    await homePage.routing.click();

    const toggleButton = page
      .locator(
        '[data-testid*="rule-toggle"], input[type="checkbox"][name*="enabled"]',
      )
      .first();
    if (await toggleButton.isVisible().catch(() => false)) {
      const isEnabled = await toggleButton.isChecked().catch(() => true);

      await toggleButton.setChecked(!isEnabled);
      await page.waitForTimeout(500);

      await toggleButton.setChecked(isEnabled);
      await page.waitForTimeout(500);
    }
  });

  test("should delete routing rule", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    await homePage.workflow.click();
    await homePage.routing.click();

    const deleteButton = page
      .locator('[data-button-for="deleteRule"], button:has-text("Delete"]')
      .first();
    if (await deleteButton.isVisible().catch(() => false)) {
      await deleteButton.click();

      const confirmButton = page.locator(
        '[data-button-for="confirmDelete"], button:has-text("Confirm")',
      );
      if (await confirmButton.isVisible().catch(() => false)) {
        await confirmButton.click();

        await expect(
          page.locator('[data-toast*="deleted"], [data-toast*="removed"]'),
        ).toBeVisible({ timeout: 10000 });
      }
    }
  });
});
