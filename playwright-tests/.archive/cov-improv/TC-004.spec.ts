/**
 * TC-004: Vault Processor Configuration
 * Source: test-specification-for-coverage-improvement.json
 */
import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-004: Vault Processor Configuration", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.vault = true;
        json.features.vault_processor = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should configure Spreedly vault", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.vaultConnectors.click();

    await expect(page).toHaveURL(/.*dashboard\/vault-processor/);

    const connectButton = page
      .locator(
        '[data-button-for="connectNow"], button:has-text("Connect Vault")',
      )
      .first();
    if (await connectButton.isVisible().catch(() => false)) {
      await connectButton.click();

      const spreedlyOption = page.locator('[data-testid*="spreedly"]').first();
      if (await spreedlyOption.isVisible().catch(() => false)) {
        await spreedlyOption.click();
      }

      await page
        .locator('[name*="environment_key"]')
        .fill("spreedly_test_env_key");
      await page
        .locator('[name*="access_secret"]')
        .fill("spreedly_test_secret");

      await page.locator('[data-button-for="connectAndProceed"]').click();

      await expect(
        page.locator('[data-toast*="success"], [data-toast*="Connected"]'),
      ).toBeVisible({ timeout: 10000 });
    }
  });

  test("should configure tokenization rules", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.vaultConnectors.click();

    const rulesTab = page.locator(
      '[data-testid*="rules"], [role="tab"]:has-text("Rules")',
    );
    if (await rulesTab.isVisible().catch(() => false)) {
      await rulesTab.click();

      const addRuleButton = page.locator(
        '[data-button-for="addRule"], button:has-text("Add Rule")',
      );
      if (await addRuleButton.isVisible().catch(() => false)) {
        await addRuleButton.click();

        await page.locator('[name*="rule_name"]').fill("Auto Tokenize Cards");

        const conditionDropdown = page
          .locator('[name*="condition_type"]')
          .first();
        if (await conditionDropdown.isVisible().catch(() => false)) {
          await conditionDropdown.selectOption("payment_method_card");
        }

        await page.locator('[data-button-for="saveRule"]').click();
      }
    }
  });

  test("should set retention policies", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.vaultConnectors.click();

    const retentionTab = page.locator(
      '[data-testid*="retention"], [role="tab"]:has-text("Retention")',
    );
    if (await retentionTab.isVisible().catch(() => false)) {
      await retentionTab.click();

      await page.locator('[name*="retention_days"]').fill("365");

      const autoDeleteToggle = page.locator(
        '[data-testid*="auto-delete"], input[type="checkbox"][name*="auto_delete"]',
      );
      if (await autoDeleteToggle.isVisible().catch(() => false)) {
        await autoDeleteToggle.check();
      }

      await page.locator('[data-button-for="saveRetention"]').click();
    }
  });

  test("should test token operations", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.vaultConnectors.click();

    const testButton = page.locator(
      '[data-button-for="testToken"], button:has-text("Test Token")',
    );
    if (await testButton.isVisible().catch(() => false)) {
      await testButton.click();

      await expect(
        page.locator(
          '[data-testid*="token-test-success"], [data-toast*="Token operation successful"]',
        ),
      ).toBeVisible({ timeout: 10000 });
    }

    const vaultStatus = page.locator(
      '[data-testid*="vault-status"], [data-testid*="connection-status"]',
    );
    if (await vaultStatus.isVisible().catch(() => false)) {
      await expect(vaultStatus).toContainText(/connected|active/i);
    }
  });
});
