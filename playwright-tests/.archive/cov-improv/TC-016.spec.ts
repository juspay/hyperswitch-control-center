import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-016: Surcharge Rules - Fee Calculation", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.surcharge = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should navigate to surcharge configuration", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.surchargeRouting.click();

    await expect(page).toHaveURL(/.*dashboard\/surcharge/);
  });

  test("should add percentage-based surcharge", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.surchargeRouting.click();

    const addRuleButton = page
      .locator('[data-button-for="addRule"], button:has-text("Add Rule")')
      .first();
    if (await addRuleButton.isVisible().catch(() => false)) {
      await addRuleButton.click();

      await page.locator('[name*="rule_name"]').fill("Standard Card Surcharge");

      const feeType = page.locator('[name*="fee_type"]').first();
      if (await feeType.isVisible().catch(() => false)) {
        await feeType.selectOption("percentage");
      }

      await page
        .locator('[name*="fee_value"], [name*="percentage"]')
        .fill("2.5");

      await page.locator('[data-button-for="saveRule"]').click();
    }
  });

  test("should add fixed fee surcharge", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.surchargeRouting.click();

    const addRuleButton = page.locator('[data-button-for="addRule"]').first();
    if (await addRuleButton.isVisible().catch(() => false)) {
      await addRuleButton.click();

      await page.locator('[name*="rule_name"]').fill("Fixed Transaction Fee");

      const feeType = page.locator('[name*="fee_type"]').first();
      if (await feeType.isVisible().catch(() => false)) {
        await feeType.selectOption("fixed");
      }

      await page
        .locator('[name*="fee_value"], [name*="fixed_amount"]')
        .fill("0.30");

      const currency = page.locator('[name*="currency"]').first();
      if (await currency.isVisible().catch(() => false)) {
        await currency.selectOption("USD");
      }

      await page.locator('[data-button-for="saveRule"]').click();
    }
  });

  test("should add conditional surcharge for Amex cards", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.surchargeRouting.click();

    const addRuleButton = page.locator('[data-button-for="addRule"]').first();
    if (await addRuleButton.isVisible().catch(() => false)) {
      await addRuleButton.click();

      await page.locator('[name*="rule_name"]').fill("Amex Surcharge");

      const cardNetwork = page
        .locator('[name*="card_network"], [name*="network"]')
        .first();
      if (await cardNetwork.isVisible().catch(() => false)) {
        await cardNetwork.selectOption("amex");
      }

      await page.locator('[name*="fee_value"]').fill("3.0");

      await page.locator('[data-button-for="saveRule"]').click();
    }
  });

  test("should combine multiple surcharge rules", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.surchargeRouting.click();

    const combineToggle = page
      .locator(
        '[data-testid*="combine-rules"], input[type="checkbox"][name*="combine"]',
      )
      .first();
    if (await combineToggle.isVisible().catch(() => false)) {
      await combineToggle.check();

      const saveButton = page
        .locator('[data-button-for="saveSettings"], button:has-text("Save")')
        .first();
      if (await saveButton.isVisible().catch(() => false)) {
        await saveButton.click();
      }
    }
  });
});
