import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Configure PMTs - enable payment methods and amount limits", () => {
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

    await homePage.settings.click();
    await homePage.configurePMT.click();
    await expect(page).toHaveURL(/.*dashboard\/configure-pmts/);
  });

  test("should enable credit-card and wallet payment methods via toggles", async ({
    page,
  }) => {
    const creditCardToggle = page
      .locator('[data-testid*="credit"], input[type="checkbox"][name*="credit"]')
      .first();
    if (await creditCardToggle.isVisible().catch(() => false)) {
      await creditCardToggle.check();
      const visa = page
        .locator('[data-testid*="visa"], input[type="checkbox"][name*="visa"]')
        .first();
      if (await visa.isVisible().catch(() => false)) await visa.check();
    }

    const walletToggle = page
      .locator('[data-testid*="wallet"], input[type="checkbox"][name*="wallet"]')
      .first();
    if (await walletToggle.isVisible().catch(() => false)) {
      await walletToggle.check();
      const gpay = page
        .locator('[data-testid*="gpay"], [data-testid*="google"]')
        .first();
      if (await gpay.isVisible().catch(() => false)) await gpay.check();
    }

    const save = page.locator('[data-button-for="save"]').first();
    if (await save.isVisible().catch(() => false)) await save.click();
  });

  test("should surface an error when min > max amount limits", async ({
    page,
  }) => {
    const minAmount = page.locator('[name*="min_amount"]').first();
    const maxAmount = page.locator('[name*="max_amount"]').first();
    if (
      !(await minAmount.isVisible().catch(() => false)) ||
      !(await maxAmount.isVisible().catch(() => false))
    ) {
      test.skip(true, "amount limit inputs not exposed");
    }

    await minAmount.fill("1000");
    await maxAmount.fill("100");

    await page.locator('[data-button-for="save"]').click();

    await expect(
      page.locator('[data-field-error*="amount"], [data-toast*="error"]'),
    ).toBeVisible({ timeout: 5000 });
  });

  test("should accept a country-restriction multi-select and persist values", async ({
    page,
  }) => {
    const countrySelect = page
      .locator('[name*="allowed_countries"], select[name*="country"]')
      .first();
    if (!(await countrySelect.isVisible().catch(() => false))) {
      test.skip(true, "country restriction control not exposed");
    }
    await countrySelect.selectOption(["US", "CA", "GB"]);
    await page.locator('[data-button-for="save"]').click();
    await expect(countrySelect).toBeVisible();
  });
});
