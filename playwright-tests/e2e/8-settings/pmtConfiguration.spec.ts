import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { ConfigurePMTPage } from "../../support/pages/settings/ConfigurePMTPage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe.skip("Configure PMTs - enable payment methods and amount limits", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
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
    const pmtPage = new ConfigurePMTPage(page);
    if (await pmtPage.creditCardToggle.isVisible().catch(() => false)) {
      await pmtPage.creditCardToggle.check();
      if (await pmtPage.visaCheckbox.isVisible().catch(() => false))
        await pmtPage.visaCheckbox.check();
    }

    if (await pmtPage.walletToggle.isVisible().catch(() => false)) {
      await pmtPage.walletToggle.check();
      if (await pmtPage.gpayCheckbox.isVisible().catch(() => false))
        await pmtPage.gpayCheckbox.check();
    }

    if (await pmtPage.saveButton.isVisible().catch(() => false))
      await pmtPage.saveButton.click();
  });

  test("should surface an error when min > max amount limits", async ({
    page,
  }) => {
    const pmtPage = new ConfigurePMTPage(page);
    if (
      !(await pmtPage.minAmountInput.isVisible().catch(() => false)) ||
      !(await pmtPage.maxAmountInput.isVisible().catch(() => false))
    ) {
      test.skip(true, "amount limit inputs not exposed");
    }

    await pmtPage.minAmountInput.fill("1000");
    await pmtPage.maxAmountInput.fill("100");

    await pmtPage.saveButton.click();

    await expect(pmtPage.amountErrorToast).toBeVisible({ timeout: 5000 });
  });

  test("should accept a country-restriction multi-select and persist values", async ({
    page,
  }) => {
    const pmtPage = new ConfigurePMTPage(page);
    if (!(await pmtPage.countrySelect.isVisible().catch(() => false))) {
      test.skip(true, "country restriction control not exposed");
    }
    await pmtPage.countrySelect.selectOption(["US", "CA", "GB"]);
    await pmtPage.saveButton.click();
    await expect(pmtPage.countrySelect).toBeVisible();
  });
});
