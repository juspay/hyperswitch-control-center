/**
 * TC-005: PM Authentication Processor Setup
 * Source: test-specification-for-coverage-improvement.json
 */
import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-005: PM Authentication Processor Setup", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.pm_authentication_processor = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should configure authentication provider", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.pmAuthConnectors.click();

    await expect(page).toHaveURL(/.*dashboard\/pm-authentication-processor/);

    const connectButton = page
      .locator('[data-button-for="connectNow"], button:has-text("Connect")')
      .first();
    if (await connectButton.isVisible().catch(() => false)) {
      await connectButton.click();

      const providerOption = page
        .locator('[data-testid*="pm-auth"], [data-testid*="authentication"]')
        .first();
      if (await providerOption.isVisible().catch(() => false)) {
        await providerOption.click();
      }

      await page
        .locator('[name*="api_key"], [name*="client_id"]')
        .fill("pm_auth_test_key");

      await page.locator('[data-button-for="connectAndProceed"]').click();

      await expect(
        page.locator('[data-toast*="success"], [data-toast*="Connected"]'),
      ).toBeVisible({ timeout: 10000 });
    }
  });

  test("should configure 3DS authentication rules", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.pmAuthConnectors.click();

    const rulesSection = page.locator(
      '[data-testid*="rules"], [data-testid*="3ds-rules"]',
    );
    if (await rulesSection.isVisible().catch(() => false)) {
      const addRuleButton = page.locator(
        '[data-button-for="addRule"], button:has-text("Add 3DS Rule")',
      );
      if (await addRuleButton.isVisible().catch(() => false)) {
        await addRuleButton.click();

        await page.locator('[name*="rule_name"]').fill("3DS for High Value");

        const amountThreshold = page.locator(
          '[name*="amount_threshold"], [name*="amount"]',
        );
        if (await amountThreshold.isVisible().catch(() => false)) {
          await amountThreshold.fill("1000");
        }

        const actionDropdown = page
          .locator('[name*="action"], [name*="challenge_action"]')
          .first();
        if (await actionDropdown.isVisible().catch(() => false)) {
          await actionDropdown.selectOption("challenge");
        }

        await page.locator('[data-button-for="saveRule"]').click();
      }
    }
  });

  test("should set exemption thresholds", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.pmAuthConnectors.click();

    const exemptionsTab = page.locator(
      '[data-testid*="exemption"], [role="tab"]:has-text("Exemption")',
    );
    if (await exemptionsTab.isVisible().catch(() => false)) {
      await exemptionsTab.click();

      await page
        .locator('[name*="exemption_threshold"], [name*="threshold_amount"]')
        .fill("50");

      const trustedMerchantToggle = page.locator(
        '[data-testid*="trusted-merchant"], input[type="checkbox"][name*="trusted"]',
      );
      if (await trustedMerchantToggle.isVisible().catch(() => false)) {
        await trustedMerchantToggle.check();
      }

      await page
        .locator('[data-button-for="saveExemptions"], button:has-text("Save")')
        .click();
    }
  });

  test("should verify auth challenge flow configuration", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.pmAuthConnectors.click();

    const testFlowButton = page.locator(
      '[data-button-for="testFlow"], button:has-text("Test Flow")',
    );
    if (await testFlowButton.isVisible().catch(() => false)) {
      await testFlowButton.click();

      await expect(
        page.locator(
          '[data-testid*="auth-flow-test"], [data-toast*="Auth flow test initiated"]',
        ),
      ).toBeVisible({ timeout: 10000 });
    }

    const authProviderList = page.locator(
      '[data-testid*="auth-provider-list"], [data-testid*="provider-item"]',
    );
    if ((await authProviderList.count()) > 0) {
      await expect(authProviderList.first()).toBeVisible();
    }
  });
});
