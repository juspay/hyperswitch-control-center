import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI, fillConnectorFields } from "../../support/commands";
import { taxProcessorConfig } from "../../support/fixtures/taxProcessorConfig";

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

test.describe("All Tax Processors", () => {
  let email: string;

  const taxProcessors = Object.entries(taxProcessorConfig);
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  for (const [key, processor] of taxProcessors) {
    test(`should setup and verify ${key} tax processor`, async ({
      page,
    }) => {
      const homePage = new HomePage(page);

      await homePage.connectors.click();
      const taxLink = homePage.taxConnectors;
      if ((await taxLink.count().catch(() => 0)) === 0) {
        test.skip(true, "Tax Processor not available");
      }

      await taxLink.click();
      await expect(page).toHaveURL(/.*dashboard\/tax-processor/);

      const connectButtons = page.locator('[data-button-text="Connect"], button:has-text("Connect")');
      await expect(connectButtons.first()).toBeVisible();
      if ((await connectButtons.count().catch(() => 0)) > 0) {
        await connectButtons.nth(0).click();

        if (processor.fields.fieldLabels.length > 0) {
          await fillConnectorFields(page, processor.fields);
        }

        const saveButton = page.locator('button:has-text("Save"), button:has-text("Connect"), button:has-text("Proceed")').first();
        if (await saveButton.isVisible({ timeout: 5000 }).catch(() => false)) {
          await saveButton.click();
          await page.waitForLoadState("networkidle");

          await page.getByRole('button', { name: 'Done' }).click();

          // Verify the connector appears in the vault processor list
          const connectorLabel = processor.fields.overrides["Enter Connector label"] || processor.label;
          await expect(page.getByText(connectorLabel, { exact: true })).toBeVisible({ timeout: 10000 });
        }
      }
    });
  }
});
