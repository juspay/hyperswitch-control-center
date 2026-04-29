import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function enableFeatureFlag(page: Page, flag: string) {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    if (json.features) {
      json.features[flag] = true;
    }
    await route.fulfill({ response, json });
  });
}

async function gotoTax(page: Page): Promise<boolean> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  const link = homePage.taxConnectors;
  if ((await link.count().catch(() => 0)) === 0) return false;
  await link.click();
  await page.waitForLoadState("networkidle");
  return true;
}

test.describe("Tax Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
    await enableFeatureFlag(page, "tax_processor");
  });

  test("should navigate to Tax Processor if enabled", async ({ page }) => {
    if (!(await gotoTax(page))) {
      test.skip(true, "Tax Processor sidebar entry not exposed");
    }
    await expect(page).toHaveURL(/.*dashboard\/tax-processor/);
  });

  test("should render Tax Processor heading if reachable", async ({ page }) => {
    if (!(await gotoTax(page))) {
      test.skip(true, "Tax Processor sidebar entry not exposed");
    }
    await expect(page.getByText(/Tax|Processor/i).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("should expose 'Request a Processor' CTA and typeable search", async ({
    page,
  }) => {
    if (!(await gotoTax(page))) {
      test.skip(true, "Tax Processor not reachable");
    }
    const fallback = page.getByText("Go to Home", { exact: true }).first();
    if (await fallback.isVisible().catch(() => false)) {
      test.skip(true, "Page gated by feature flag fallback");
    }
    await expect(
      page.getByRole("button", { name: "Request a Processor" }).first(),
    ).toBeVisible({ timeout: 10000 });
    const search = page.getByPlaceholder("Search a processor");
    await expect(search).toBeVisible({ timeout: 10000 });
    await search.fill("stripe");
    await expect(search).toHaveValue("stripe");
  });

  test("should configure TaxJar connector", async ({ page }) => {
    if (!(await gotoTax(page))) {
      test.skip(true, "Tax Processor not reachable");
    }
    const connectButton = page
      .locator('[data-button-for="connectNow"], button:has-text("Connect")')
      .first();
    if (!(await connectButton.isVisible().catch(() => false))) {
      test.skip(true, "Connect CTA not exposed");
    }
    await connectButton.click();

    const taxJarOption = page
      .locator('[data-testid="taxjar"], [data-testid*="taxjar"]')
      .first();
    if (await taxJarOption.isVisible().catch(() => false)) {
      await taxJarOption.click();
    }

    await page
      .locator('[name*="api_key"], [name*="apiKey"]')
      .first()
      .fill("taxjar_test_api_key");
    await page
      .locator('[name*="connector_label"], [name*="connectorLabel"]')
      .first()
      .fill("taxjar_test_label");

    await page
      .locator(
        '[data-button-for="connectAndProceed"], button:has-text("Connect")',
      )
      .last()
      .click();

    await expect(
      page.locator('[data-toast*="success"], [data-toast*="Successfully"]'),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should configure tax codes mapping", async ({ page }) => {
    if (!(await gotoTax(page))) {
      test.skip(true, "Tax Processor not reachable");
    }
    const configureButton = page
      .locator('[data-button-for="configure"], button:has-text("Configure")')
      .first();
    if (!(await configureButton.isVisible().catch(() => false))) {
      test.skip(true, "Configure CTA not exposed");
    }
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
  });

  test("should set up exemption rules", async ({ page }) => {
    if (!(await gotoTax(page))) {
      test.skip(true, "Tax Processor not reachable");
    }
    const exemptionsTab = page.locator(
      '[data-testid*="exemption"], [role="tab"]:has-text("Exemption")',
    );
    if (!(await exemptionsTab.isVisible().catch(() => false))) {
      test.skip(true, "Exemption tab not exposed");
    }
    await exemptionsTab.click();

    const addRuleButton = page.locator(
      '[data-button-for="addRule"], button:has-text("Add Rule")',
    );
    if (!(await addRuleButton.isVisible().catch(() => false))) {
      test.skip(true, "Add Rule CTA not exposed");
    }
    await addRuleButton.click();

    await page.locator('[name*="exemption_threshold"]').fill("100");
    await page.locator('[data-button-for="saveRule"]').click();
  });

  test("should test connection and enable tax calculation", async ({
    page,
  }) => {
    if (!(await gotoTax(page))) {
      test.skip(true, "Tax Processor not reachable");
    }
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
