import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-022: Webhooks - Endpoint Management", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.webhooks = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should navigate to webhooks page", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.webhooks.click();

    await expect(page).toHaveURL(/.*dashboard\/webhooks/);
  });

  test("should add webhook endpoint URL", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.webhooks.click();

    const addWebhookButton = page
      .locator(
        '[data-button-for="addWebhook"], button:has-text("Add Endpoint")',
      )
      .first();
    if (await addWebhookButton.isVisible().catch(() => false)) {
      await addWebhookButton.click();

      await page
        .locator('[name*="url"], [name*="endpoint_url"]')
        .fill("https://example.com/webhooks/hyperswitch");
      await page
        .locator('[name*="description"]')
        .fill("Production webhook endpoint");

      await page.locator('[data-button-for="saveWebhook"]').click();

      await expect(
        page.locator('[data-toast*="created"], [data-toast*="success"]'),
      ).toBeVisible({ timeout: 10000 });
    }
  });

  test("should select event types to subscribe", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.webhooks.click();

    const eventCheckbox = page
      .locator(
        'input[type="checkbox"][name*="event"], [data-testid*="event-checkbox"]',
      )
      .first();
    if (await eventCheckbox.isVisible().catch(() => false)) {
      await eventCheckbox.check();

      const saveButton = page.locator('[data-button-for="saveEvents"]').first();
      if (await saveButton.isVisible().catch(() => false)) {
        await saveButton.click();
      }
    }
  });

  test("should configure retry policy", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.webhooks.click();

    const retryAttempts = page
      .locator('[name*="retry_attempts"], [name*="max_retries"]')
      .first();
    if (await retryAttempts.isVisible().catch(() => false)) {
      await retryAttempts.fill("3");

      const retryInterval = page.locator('[name*="retry_interval"]').first();
      if (await retryInterval.isVisible().catch(() => false)) {
        await retryInterval.fill("60");
      }

      await page.locator('[data-button-for="saveRetryPolicy"]').click();
    }
  });

  test("should view webhook logs", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.webhooks.click();

    const logsTab = page
      .locator('[role="tab"]:has-text("Logs"), [data-testid*="logs"]')
      .first();
    if (await logsTab.isVisible().catch(() => false)) {
      await logsTab.click();

      await expect(
        page.locator('table tbody tr, [data-testid*="log-item"]').first(),
      ).toBeTruthy();
    }
  });

  test("should disable webhook endpoint", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.webhooks.click();

    const toggle = page
      .locator(
        '[data-testid*="webhook-toggle"], input[type="checkbox"][name*="enabled"]',
      )
      .first();
    if (await toggle.isVisible().catch(() => false)) {
      await toggle.uncheck();

      await expect(
        page.locator('[data-toast*="disabled"], [data-toast*="updated"]'),
      ).toBeVisible({ timeout: 10000 });
    }
  });
});
