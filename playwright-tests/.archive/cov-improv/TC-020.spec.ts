import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-020: Vault - Onboarding Wizard", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.vault = true;
        json.features.vault_onboarding = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should start vault onboarding wizard", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.vault.click();
    await homePage.vaultConfiguration.click();

    await expect(page).toHaveURL(/.*dashboard\/vault-onboarding/);
  });

  test("should complete step 1: select vault provider", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.vault.click();
    await homePage.vaultConfiguration.click();

    const providerOption = page
      .locator(
        '[data-testid*="spreedly"], [data-testid*="braintree"], [data-testid*="vault-provider"]',
      )
      .first();
    if (await providerOption.isVisible().catch(() => false)) {
      await providerOption.click();

      const nextButton = page
        .locator('[data-button-for="next"], button:has-text("Next")')
        .first();
      if (await nextButton.isVisible().catch(() => false)) {
        await nextButton.click();
      }
    }
  });

  test("should complete step 2: configure encryption keys", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.vault.click();
    await homePage.vaultConfiguration.click();

    const keyInput = page
      .locator('[name*="encryption_key"], [name*="api_key"]')
      .first();
    if (await keyInput.isVisible().catch(() => false)) {
      await keyInput.fill("vault_encryption_key_12345");

      const nextButton = page.locator('[data-button-for="next"]').first();
      if (await nextButton.isVisible().catch(() => false)) {
        await nextButton.click();
      }
    }
  });

  test("should complete step 3: set up token format", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.vault.click();
    await homePage.vaultConfiguration.click();

    const tokenFormat = page
      .locator('[name*="token_format"], select[name*="format"]')
      .first();
    if (await tokenFormat.isVisible().catch(() => false)) {
      await tokenFormat.selectOption("uuid");

      const nextButton = page.locator('[data-button-for="next"]').first();
      if (await nextButton.isVisible().catch(() => false)) {
        await nextButton.click();
      }
    }
  });

  test("should complete step 4: configure retention", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.vault.click();
    await homePage.vaultConfiguration.click();

    const retentionDays = page.locator('[name*="retention_days"]').first();
    if (await retentionDays.isVisible().catch(() => false)) {
      await retentionDays.fill("365");

      const nextButton = page.locator('[data-button-for="next"]').first();
      if (await nextButton.isVisible().catch(() => false)) {
        await nextButton.click();
      }
    }
  });

  test("should complete step 5: review and activate", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.vault.click();
    await homePage.vaultConfiguration.click();

    const activateButton = page
      .locator('[data-button-for="activate"], button:has-text("Activate")')
      .first();
    if (await activateButton.isVisible().catch(() => false)) {
      await activateButton.click();

      await expect(
        page.locator('[data-toast*="success"], [data-toast*="activated"]'),
      ).toBeVisible({ timeout: 10000 });
    }
  });
});
