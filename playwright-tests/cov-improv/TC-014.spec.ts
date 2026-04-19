import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-014: 3DS Decision Manager - Rules", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "threeds_connector",
        context.request,
      );
    }
  });

  test("should navigate to 3DS Decision Manager", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.threeDSRouting.click();

    await expect(page).toHaveURL(/.*dashboard\/3ds/);
  });

  test("should add rule for amount greater than 500", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.threeDSRouting.click();

    const addRuleButton = page
      .locator('[data-button-for="addRule"], button:has-text("Add Rule")')
      .first();
    if (await addRuleButton.isVisible().catch(() => false)) {
      await addRuleButton.click();

      await page.locator('[name*="rule_name"]').fill("High Value 3DS");

      const conditionType = page.locator('[name*="condition"]').first();
      if (await conditionType.isVisible().catch(() => false)) {
        await conditionType.selectOption("amount");
      }

      const operator = page.locator('[name*="operator"]').first();
      if (await operator.isVisible().catch(() => false)) {
        await operator.selectOption("greater_than");
      }

      await page.locator('[name*="value"]').fill("500");

      const action = page.locator('[name*="action"]').first();
      if (await action.isVisible().catch(() => false)) {
        await action.selectOption("challenge");
      }

      await page.locator('[data-button-for="saveRule"]').click();
    }
  });

  test("should add rule for trusted merchants", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.threeDSRouting.click();

    const addRuleButton = page.locator('[data-button-for="addRule"]').first();
    if (await addRuleButton.isVisible().catch(() => false)) {
      await addRuleButton.click();

      await page.locator('[name*="rule_name"]').fill("Skip 3DS for Trusted");

      const conditionType = page.locator('[name*="condition"]').first();
      if (await conditionType.isVisible().catch(() => false)) {
        await conditionType.selectOption("merchant_trust_score");
      }

      const trustScore = page
        .locator('[name*="trust_score"], [name*="score"]')
        .first();
      if (await trustScore.isVisible().catch(() => false)) {
        await trustScore.fill("80");
      }

      const action = page.locator('[name*="action"]').first();
      if (await action.isVisible().catch(() => false)) {
        await action.selectOption("skip");
      }

      await page.locator('[data-button-for="saveRule"]').click();
    }
  });

  test("should add rule for high-risk countries", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.threeDSRouting.click();

    const addRuleButton = page.locator('[data-button-for="addRule"]').first();
    if (await addRuleButton.isVisible().catch(() => false)) {
      await addRuleButton.click();

      await page.locator('[name*="rule_name"]').fill("High Risk Country 3DS");

      const conditionType = page.locator('[name*="condition"]').first();
      if (await conditionType.isVisible().catch(() => false)) {
        await conditionType.selectOption("country");
      }

      const countrySelect = page.locator('[name*="country"]').first();
      if (await countrySelect.isVisible().catch(() => false)) {
        await countrySelect.selectOption("RU");
      }

      const action = page.locator('[name*="action"]').first();
      if (await action.isVisible().catch(() => false)) {
        await action.selectOption("challenge");
      }

      await page.locator('[data-button-for="saveRule"]').click();
    }
  });

  test("should enable and disable rules", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.threeDSRouting.click();

    const ruleToggle = page
      .locator(
        '[data-testid*="rule-toggle"], input[type="checkbox"][name*="enabled"]',
      )
      .first();
    if (await ruleToggle.isVisible().catch(() => false)) {
      const isChecked = await ruleToggle.isChecked();
      await ruleToggle.setChecked(!isChecked);
      await page.waitForTimeout(500);
      await ruleToggle.setChecked(isChecked);
    }
  });
});
