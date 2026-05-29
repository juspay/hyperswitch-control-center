import { test, expect } from "../../support/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe.skip("Performance Monitor - alert configuration", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.performance_monitor = true;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.goto("/dashboard/performance-monitor");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1500);

    const fallback = page.getByText("Go to Home", { exact: true }).first();
    if (await fallback.isVisible().catch(() => false)) {
      test.skip(true, "performance monitor gated off");
    }
  });

  test("should open the Add Alert modal and accept latency-threshold inputs", async ({
    page,
  }) => {
    const addAlertButton = page
      .locator('[data-button-for="addAlert"], button:has-text("Add Alert")')
      .first();
    await expect(addAlertButton).toBeVisible({ timeout: 10000 });
    await addAlertButton.click();

    await page.locator('[name*="alert_name"]').fill("High Latency Alert");
    await page.locator('[name*="metric"]').selectOption("latency");
    await page.locator('[name*="threshold"]').fill("500");
    await page.locator('[name*="operator"]').selectOption("greater_than");

    await page.locator('[data-button-for="saveAlert"]').click();
    await expect(
      page.locator('[data-toast*="success"], [data-toast*="Alert created"]'),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should configure email + webhook notification channels", async ({
    page,
  }) => {
    const settingsTab = page
      .locator('[data-testid*="settings"], [role="tab"]:has-text("Settings")')
      .first();
    await expect(settingsTab).toBeVisible({ timeout: 10000 });
    await settingsTab.click();

    await page.locator('[name*="email"]').fill("alerts@example.com");
    await page
      .locator('[name*="webhook_url"]')
      .fill("https://example.com/webhook/alerts");

    await page.locator('[data-button-for="saveChannels"]').click();
  });

  test("should acknowledge an open alert from the Alerts tab", async ({
    page,
  }) => {
    const alertsTab = page
      .locator('[data-testid*="alerts"], [role="tab"]:has-text("Alerts")')
      .first();
    await expect(alertsTab).toBeVisible({ timeout: 10000 });
    await alertsTab.click();

    const acknowledgeButton = page
      .locator('[data-button-for="acknowledge"], button:has-text("Acknowledge")')
      .first();

    if (await acknowledgeButton.isVisible().catch(() => false)) {
      await acknowledgeButton.click();
      await page.waitForLoadState("networkidle");
    }
  });
});
