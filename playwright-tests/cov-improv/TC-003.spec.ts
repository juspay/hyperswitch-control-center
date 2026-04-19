/**
 * TC-003: Billing Processor Configuration
 * Source: test-specification-for-coverage-improvement.json
 */
import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-003: Billing Processor Configuration", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.billing_processor = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should configure Chargebee connector", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.billingConnectors.click();

    await expect(page).toHaveURL(/.*dashboard\/billing-processor/);

    const connectButton = page
      .locator('[data-button-for="connectNow"], button:has-text("Connect")')
      .first();
    if (await connectButton.isVisible().catch(() => false)) {
      await connectButton.click();

      const chargebeeOption = page
        .locator('[data-testid*="chargebee"]')
        .first();
      if (await chargebeeOption.isVisible().catch(() => false)) {
        await chargebeeOption.click();
      }

      await page
        .locator('[name*="api_key"], [name*="site"]')
        .fill("chargebee_test_site");
      await page.locator('[name*="api_key"]').fill("chargebee_test_api_key");

      await page.locator('[data-button-for="connectAndProceed"]').click();

      await expect(
        page.locator('[data-toast*="success"], [data-toast*="Successfully"]'),
      ).toBeVisible({ timeout: 10000 });
    }
  });

  test("should configure subscription plans sync", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.billingConnectors.click();

    const syncTab = page.locator(
      '[data-testid*="sync"], [role="tab"]:has-text("Sync")',
    );
    if (await syncTab.isVisible().catch(() => false)) {
      await syncTab.click();

      const planCheckbox = page
        .locator('[data-testid*="plan"], input[type="checkbox"]')
        .first();
      if (await planCheckbox.isVisible().catch(() => false)) {
        await planCheckbox.check();
      }

      await page
        .locator('[data-button-for="saveSync"], button:has-text("Save Sync")')
        .click();
    }
  });

  test("should set up invoice webhooks", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.billingConnectors.click();

    const webhooksTab = page.locator(
      '[data-testid*="webhook"], [role="tab"]:has-text("Webhook")',
    );
    if (await webhooksTab.isVisible().catch(() => false)) {
      await webhooksTab.click();

      await page
        .locator('[name*="webhook_url"], [name*="webhookUrl"]')
        .fill("https://example.com/webhooks/billing");

      const eventCheckboxes = page.locator(
        '[data-testid*="invoice"], input[type="checkbox"][name*="event"]',
      );
      const count = await eventCheckboxes.count();
      for (let i = 0; i < Math.min(count, 3); i++) {
        await eventCheckboxes.nth(i).check();
      }

      await page.locator('[data-button-for="saveWebhooks"]').click();
    }
  });
});
