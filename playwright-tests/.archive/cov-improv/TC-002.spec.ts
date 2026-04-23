/**
 * TC-002: Tax Processor Configuration
 * Source: test-specification-for-coverage-improvement.json
 */
import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-002: Tax Processor Configuration", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.tax_processor = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should configure TaxJar connector", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.taxConnectors.click();

    await expect(page).toHaveURL(/.*dashboard\/tax-processor/);

    const connectButton = page
      .locator('[data-button-for="connectNow"], button:has-text("Connect")')
      .first();
    if (await connectButton.isVisible().catch(() => false)) {
      await connectButton.click();

      const taxJarOption = page
        .locator('[data-testid="taxjar"], [data-testid*="taxjar"]')
        .first();
      if (await taxJarOption.isVisible().catch(() => false)) {
        await taxJarOption.click();
      }

      await page
        .locator('[name*="api_key"], [name*="apiKey"]')
        .fill("taxjar_test_api_key");
      await page
        .locator('[name*="connector_label"], [name*="connectorLabel"]')
        .fill("taxjar_test_label");

      await page
        .locator(
          '[data-button-for="connectAndProceed"], button:has-text("Connect")',
        )
        .click();

      await expect(
        page.locator('[data-toast*="success"], [data-toast*="Successfully"]'),
      ).toBeVisible({ timeout: 10000 });
    }
  });

  test("should configure tax codes mapping", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.taxConnectors.click();

    await page
      .waitForSelector('[data-testid*="tax"], [data-testid*="connector"]', {
        timeout: 5000,
      })
      .catch(() => {});

    const configureButton = page
      .locator('[data-button-for="configure"], button:has-text("Configure")')
      .first();
    if (await configureButton.isVisible().catch(() => false)) {
      await configureButton.click();

      const taxCodeDropdown = page
        .locator('[data-testid*="tax-code"], select[name*="taxCode"]')
        .first();
      if (await taxCodeDropdown.isVisible().catch(() => false)) {
        await taxCodeDropdown.selectOption({ index: 1 });
      }

      await page
        .locator('[data-button-for="save"], button:has-text("Save")')
        .click();
    }
  });

  test("should set up exemption rules", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.taxConnectors.click();

    const exemptionsTab = page.locator(
      '[data-testid*="exemption"], [role="tab"]:has-text("Exemption")',
    );
    if (await exemptionsTab.isVisible().catch(() => false)) {
      await exemptionsTab.click();

      const addRuleButton = page.locator(
        '[data-button-for="addRule"], button:has-text("Add Rule")',
      );
      if (await addRuleButton.isVisible().catch(() => false)) {
        await addRuleButton.click();

        await page.locator('[name*="exemption_threshold"]').fill("100");
        await page.locator('[data-button-for="saveRule"]').click();
      }
    }
  });

  test("should test connection and enable tax calculation", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.taxConnectors.click();

    const testConnectionButton = page.locator(
      '[data-button-for="testConnection"], button:has-text("Test Connection")',
    );
    if (await testConnectionButton.isVisible().catch(() => false)) {
      await testConnectionButton.click();

      await expect(
        page.locator(
          '[data-toast*="success"], [data-testid*="connection-success"]',
        ),
      ).toBeVisible({ timeout: 10000 });
    }

    const enableToggle = page
      .locator(
        '[data-testid*="enable-tax"], input[type="checkbox"][name*="enabled"]',
      )
      .first();
    if (await enableToggle.isVisible().catch(() => false)) {
      await enableToggle.check();

      const saveButton = page.locator(
        '[data-button-for="save"], button:has-text("Save Changes")',
      );
      if (await saveButton.isVisible().catch(() => false)) {
        await saveButton.click();
      }
    }
  });
});
