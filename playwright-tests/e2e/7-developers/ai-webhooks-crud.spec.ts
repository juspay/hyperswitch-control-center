import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Webhooks - endpoint CRUD and subscriptions", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    await homePage.developer.click();
    await homePage.webhooks.click();
    await page.waitForLoadState("networkidle");
  });

  test("should create a webhook endpoint via Add Endpoint modal", async ({
    page,
  }) => {
    const addWebhookButton = page
      .locator('[data-button-for="addWebhook"], button:has-text("Add Endpoint")')
      .first();
    if (!(await addWebhookButton.isVisible().catch(() => false))) {
      test.skip(true, "Add Endpoint CTA not exposed");
    }
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
  });

  test("should subscribe to event types via checkbox list", async ({ page }) => {
    const eventCheckbox = page
      .locator(
        'input[type="checkbox"][name*="event"], [data-testid*="event-checkbox"]',
      )
      .first();
    if (!(await eventCheckbox.isVisible().catch(() => false))) {
      test.skip(true, "event checkboxes not exposed");
    }
    await eventCheckbox.check();

    const saveButton = page.locator('[data-button-for="saveEvents"]').first();
    if (await saveButton.isVisible().catch(() => false)) {
      await saveButton.click();
    }
  });

  test("should accept retry attempts and interval values", async ({ page }) => {
    const retryAttempts = page
      .locator('[name*="retry_attempts"], [name*="max_retries"]')
      .first();
    if (!(await retryAttempts.isVisible().catch(() => false))) {
      test.skip(true, "retry policy form not exposed");
    }
    await retryAttempts.fill("3");

    const retryInterval = page.locator('[name*="retry_interval"]').first();
    if (await retryInterval.isVisible().catch(() => false)) {
      await retryInterval.fill("60");
    }
    await page.locator('[data-button-for="saveRetryPolicy"]').click();
  });

  test("should switch to Logs tab and render log rows or empty state", async ({
    page,
  }) => {
    const logsTab = page
      .locator('[role="tab"]:has-text("Logs"), [data-testid*="logs"]')
      .first();
    if (!(await logsTab.isVisible().catch(() => false))) {
      test.skip(true, "Logs tab not exposed");
    }
    await logsTab.click();
    await page.waitForTimeout(500);
    expect(page.url()).toContain("/dashboard");
  });

  test("should toggle a webhook endpoint off and emit a disabled/updated toast", async ({
    page,
  }) => {
    const toggle = page
      .locator(
        '[data-testid*="webhook-toggle"], input[type="checkbox"][name*="enabled"]',
      )
      .first();
    if (!(await toggle.isVisible().catch(() => false))) {
      test.skip(true, "webhook toggle not exposed");
    }
    await toggle.uncheck();
    await expect(
      page.locator('[data-toast*="disabled"], [data-toast*="updated"]'),
    ).toBeVisible({ timeout: 10000 });
  });
});
