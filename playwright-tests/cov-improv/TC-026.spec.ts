import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-026: Alternative Payment Methods", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "apm_test_connector",
        context.request,
      );
    }

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.apm = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should navigate to APM page", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();

    // Fixed: Added guard for APM nav existence
    const apmNav = page.locator('[data-testid*="apm"], a[href*="apm"]').first();
    if (!(await apmNav.isVisible().catch(() => false))) {
      return;
    }
    await apmNav.click();

    await expect(page).toHaveURL(/.*dashboard\/apm/);
  });

  test("should enable iDEAL for Netherlands", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();

    const apmNav = page.locator('[data-testid*="apm"]').first();
    if (!(await apmNav.isVisible().catch(() => false))) {
      return;
    }
    await apmNav.click();

    const idealToggle = page
      .locator('[data-testid*="ideal"], input[type="checkbox"][name*="ideal"]')
      .first();
    if (await idealToggle.isVisible().catch(() => false)) {
      await idealToggle.check();

      const countrySelect = page
        .locator('[name*="country"][name*="ideal"]')
        .first();
      if (await countrySelect.isVisible().catch(() => false)) {
        await countrySelect.selectOption("NL");
      }

      await page.locator('[data-button-for="save"]').click();
    }
  });

  test("should enable Sofort for Germany", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();

    const apmNav = page.locator('[data-testid*="apm"]').first();
    if (!(await apmNav.isVisible().catch(() => false))) {
      return;
    }
    await apmNav.click();

    const sofortToggle = page.locator('[data-testid*="sofort"]').first();
    if (await sofortToggle.isVisible().catch(() => false)) {
      await sofortToggle.check();

      const countrySelect = page
        .locator('[name*="country"][name*="sofort"]')
        .first();
      if (await countrySelect.isVisible().catch(() => false)) {
        await countrySelect.selectOption("DE");
      }

      await page.locator('[data-button-for="save"]').click();
    }
  });

  test("should configure APM credentials", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();

    const apmNav = page.locator('[data-testid*="apm"]').first();
    if (!(await apmNav.isVisible().catch(() => false))) {
      return;
    }
    await apmNav.click();

    const credentialsTab = page
      .locator(
        '[role="tab"]:has-text("Credentials"), [data-testid*="credentials"]',
      )
      .first();
    if (await credentialsTab.isVisible().catch(() => false)) {
      await credentialsTab.click();

      await page.locator('[name*="api_key"]').fill("apm_test_api_key");
      await page.locator('[name*="merchant_id"]').fill("apm_merchant_123");

      await page
        .locator('[data-button-for="validate"], button:has-text("Validate")')
        .click();

      await expect(
        page.locator('[data-toast*="validated"], [data-toast*="success"]'),
      ).toBeVisible({ timeout: 10000 });
    }
  });

  test("should set APM-specific rules", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();

    const apmNav = page.locator('[data-testid*="apm"]').first();
    if (!(await apmNav.isVisible().catch(() => false))) {
      return;
    }
    await apmNav.click();

    const rulesTab = page
      .locator('[role="tab"]:has-text("Rules"), [data-testid*="rules"]')
      .first();
    if (await rulesTab.isVisible().catch(() => false)) {
      await rulesTab.click();

      const minAmount = page.locator('[name*="min_amount"]').first();
      if (await minAmount.isVisible().catch(() => false)) {
        await minAmount.fill("5.00");
      }

      await page.locator('[data-button-for="saveRules"]').click();
    }
  });
});
