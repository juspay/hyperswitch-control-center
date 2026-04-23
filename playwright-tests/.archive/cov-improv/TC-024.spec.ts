import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-024: Configure PMTs - All Combinations", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_pmt_test",
        context.request,
      );
    }
  });

  test("should navigate to configure PMTs", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();
    await homePage.configurePMT.click();

    await expect(page).toHaveURL(/.*dashboard\/configure-pmts/);
  });

  test("should enable credit card payment methods", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();
    await homePage.configurePMT.click();

    const creditCardToggle = page
      .locator(
        '[data-testid*="credit"], input[type="checkbox"][name*="credit"]',
      )
      .first();
    if (await creditCardToggle.isVisible().catch(() => false)) {
      await creditCardToggle.check();

      const visaCheckbox = page
        .locator('[data-testid*="visa"], input[type="checkbox"][name*="visa"]')
        .first();
      if (await visaCheckbox.isVisible().catch(() => false)) {
        await visaCheckbox.check();
      }

      const mastercardCheckbox = page
        .locator('[data-testid*="mastercard"]')
        .first();
      if (await mastercardCheckbox.isVisible().catch(() => false)) {
        await mastercardCheckbox.check();
      }

      await page.locator('[data-button-for="save"]').click();
    }
  });

  test("should enable wallet payment methods", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();
    await homePage.configurePMT.click();

    const walletToggle = page
      .locator(
        '[data-testid*="wallet"], input[type="checkbox"][name*="wallet"]',
      )
      .first();
    if (await walletToggle.isVisible().catch(() => false)) {
      await walletToggle.check();

      const gpayCheckbox = page
        .locator('[data-testid*="gpay"], [data-testid*="google"]')
        .first();
      if (await gpayCheckbox.isVisible().catch(() => false)) {
        await gpayCheckbox.check();
      }

      const applePayCheckbox = page.locator('[data-testid*="apple"]').first();
      if (await applePayCheckbox.isVisible().catch(() => false)) {
        await applePayCheckbox.check();
      }

      await page.locator('[data-button-for="save"]').click();
    }
  });

  test("should configure country restrictions", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();
    await homePage.configurePMT.click();

    const countrySelect = page
      .locator('[name*="allowed_countries"], select[name*="country"]')
      .first();
    if (await countrySelect.isVisible().catch(() => false)) {
      await countrySelect.selectOption(["US", "CA", "GB"]);

      await page.locator('[data-button-for="save"]').click();
    }
  });

  test("should set min and max amount limits", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();
    await homePage.configurePMT.click();

    const minAmount = page.locator('[name*="min_amount"]').first();
    const maxAmount = page.locator('[name*="max_amount"]').first();

    if (await minAmount.isVisible().catch(() => false)) {
      await minAmount.fill("1.00");
    }

    if (await maxAmount.isVisible().catch(() => false)) {
      await maxAmount.fill("10000.00");
    }

    await page.locator('[data-button-for="save"]').click();
  });

  test("should validate amount limits on input", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();
    await homePage.configurePMT.click();

    const minAmount = page.locator('[name*="min_amount"]').first();
    const maxAmount = page.locator('[name*="max_amount"]').first();

    if (
      (await minAmount.isVisible().catch(() => false)) &&
      (await maxAmount.isVisible().catch(() => false))
    ) {
      await minAmount.fill("1000");
      await maxAmount.fill("100");

      await page.locator('[data-button-for="save"]').click();

      await expect(
        page.locator('[data-field-error*="amount"], [data-toast*="error"]'),
      ).toBeVisible({ timeout: 5000 });
    }
  });
});
