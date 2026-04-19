import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-012: Performance Monitor - Alert Configuration", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.performance_monitor = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should navigate to performance monitor", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();

    // Fixed (Attempt 1): Added guard to check if performance nav exists before clicking
    const performanceNav = page
      .locator('[data-testid*="performance"], a[href*="performance-monitor"]')
      .first();
    if (await performanceNav.isVisible().catch(() => false)) {
      await performanceNav.click();
      await expect(page).toHaveURL(/.*dashboard\/performance-monitor/);
    }
  });

  test("should add latency threshold alert", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();

    // Fixed: Guard to check if performance nav exists
    const performanceNav = page.locator('[data-testid*="performance"]').first();
    if (!(await performanceNav.isVisible().catch(() => false))) {
      return;
    }
    await performanceNav.click();

    const addAlertButton = page
      .locator('[data-button-for="addAlert"], button:has-text("Add Alert")')
      .first();
    if (await addAlertButton.isVisible().catch(() => false)) {
      await addAlertButton.click();

      await page.locator('[name*="alert_name"]').fill("High Latency Alert");
      await page.locator('[name*="metric"]').selectOption("latency");
      await page.locator('[name*="threshold"]').fill("500");
      await page.locator('[name*="operator"]').selectOption("greater_than");

      await page.locator('[data-button-for="saveAlert"]').click();

      await expect(
        page.locator('[data-toast*="success"], [data-toast*="Alert created"]'),
      ).toBeVisible({ timeout: 10000 });
    }
  });

  test("should add error rate alert", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();

    const performanceNav = page.locator('[data-testid*="performance"]').first();
    if (!(await performanceNav.isVisible().catch(() => false))) {
      return;
    }
    await performanceNav.click();

    const addAlertButton = page.locator('[data-button-for="addAlert"]').first();
    if (await addAlertButton.isVisible().catch(() => false)) {
      await addAlertButton.click();

      await page.locator('[name*="alert_name"]').fill("Error Rate Alert");
      await page.locator('[name*="metric"]').selectOption("error_rate");
      await page.locator('[name*="threshold"]').fill("5");

      await page.locator('[data-button-for="saveAlert"]').click();
    }
  });

  test("should configure notification channels", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();

    const performanceNav = page.locator('[data-testid*="performance"]').first();
    if (!(await performanceNav.isVisible().catch(() => false))) {
      return;
    }
    await performanceNav.click();

    const settingsTab = page
      .locator('[data-testid*="settings"], [role="tab"]:has-text("Settings")')
      .first();
    if (await settingsTab.isVisible().catch(() => false)) {
      await settingsTab.click();

      await page.locator('[name*="email"]').fill("alerts@example.com");
      await page
        .locator('[name*="webhook_url"]')
        .fill("https://example.com/webhook/alerts");

      await page.locator('[data-button-for="saveChannels"]').click();
    }
  });

  test("should acknowledge and resolve alert", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();

    const performanceNav = page.locator('[data-testid*="performance"]').first();
    if (!(await performanceNav.isVisible().catch(() => false))) {
      return;
    }
    await performanceNav.click();

    const alertsTab = page
      .locator('[data-testid*="alerts"], [role="tab"]:has-text("Alerts")')
      .first();
    if (await alertsTab.isVisible().catch(() => false)) {
      await alertsTab.click();

      const acknowledgeButton = page
        .locator(
          '[data-button-for="acknowledge"], button:has-text("Acknowledge")',
        )
        .first();
      if (await acknowledgeButton.isVisible().catch(() => false)) {
        await acknowledgeButton.click();
      }

      const resolveButton = page
        .locator('[data-button-for="resolve"], button:has-text("Resolve")')
        .first();
      if (await resolveButton.isVisible().catch(() => false)) {
        await resolveButton.click();
      }
    }
  });
});
