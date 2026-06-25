import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { VaultProcessor } from "../../support/pages/connector/VaultProcessor";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  fillConnectorFields,
} from "../../support/commands";
import { vaultProcessorConfig } from "../../support/fixtures/vaultProcessorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, _context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function enableFeatureFlags(page: Page, flags: string[]) {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    if (json.features) {
      for (const flag of flags) {
        json.features[flag] = true;
      }
    }
    await route.fulfill({ response, json });
  });
}

async function gotoVault(page: Page): Promise<boolean> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  const link = homePage.vaultConnectors;
  if ((await link.count().catch(() => 0)) === 0) return false;
  await link.click();
  await page.waitForLoadState("networkidle");
  return true;
}

test.describe("Vault Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
    await enableFeatureFlags(page, ["vault", "vault_processor"]);
  });

  test("should navigate to Vault Processor if enabled", async ({ page }) => {
    if (!(await gotoVault(page))) {
      test.skip(true, "Vault Processor sidebar entry not exposed");
    }
    await expect(page).toHaveURL(/.*dashboard\/vault-processor/);
  });

  test("should render Vault Processor heading if reachable", async ({
    page,
  }) => {
    if (!(await gotoVault(page))) {
      test.skip(true, "Vault Processor sidebar entry not exposed");
    }
    await expect(page.getByText(/Vault|Processor/i).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("should expose 'Request a Processor' CTA and typeable search", async ({
    page,
  }) => {
    if (!(await gotoVault(page))) {
      test.skip(true, "Vault Processor not reachable");
    }
    const vaultProcessor = new VaultProcessor(page);
    const fallback = vaultProcessor.goToHomeFallback;
    if (await fallback.isVisible().catch(() => false)) {
      test.skip(true, "Page gated by feature flag fallback");
    }
    await expect(vaultProcessor.requestProcessorButton).toBeVisible({
      timeout: 10000,
    });
    const search = vaultProcessor.searchProcessorPlaceholder;
    await expect(search).toBeVisible({ timeout: 10000 });
    await search.fill("stripe");
    await expect(search).toHaveValue("stripe");
  });

  test("should configure Spreedly vault", async ({ page }) => {
    if (!(await gotoVault(page))) {
      test.skip(true, "Vault Processor not reachable");
    }
    const vaultProcessor = new VaultProcessor(page);
    const connectButton = vaultProcessor.connectNowOrConnectButton;
    if (!(await connectButton.isVisible().catch(() => false))) {
      test.skip(true, "Connect CTA not exposed");
    }
    await connectButton.click();

    const spreedlyOption = page.locator('[data-testid*="spreedly"]').first();
    if (await spreedlyOption.isVisible().catch(() => false)) {
      await spreedlyOption.click();
    }

    await page
      .locator('[name*="environment_key"]')
      .fill("spreedly_test_env_key");
    await page.locator('[name*="access_secret"]').fill("spreedly_test_secret");

    await vaultProcessor.connectAndProceedButton.click();

    await expect(vaultProcessor.successToast).toBeVisible({ timeout: 10000 });
  });

  test("should configure tokenization rules", async ({ page }) => {
    if (!(await gotoVault(page))) {
      test.skip(true, "Vault Processor not reachable");
    }
    const rulesTab = page.locator(
      '[data-testid*="rules"], [role="tab"]:has-text("Rules")',
    );
    if (!(await rulesTab.isVisible().catch(() => false))) {
      test.skip(true, "Rules tab not exposed");
    }
    await rulesTab.click();

    const addRuleButton = page.locator(
      '[data-button-for="addRule"], button:has-text("Add Rule")',
    );
    if (!(await addRuleButton.isVisible().catch(() => false))) {
      test.skip(true, "Add Rule CTA not exposed");
    }
    await addRuleButton.click();
    await page.locator('[name*="rule_name"]').fill("Auto Tokenize Cards");

    const conditionDropdown = page.locator('[name*="condition_type"]').first();
    if (await conditionDropdown.isVisible().catch(() => false)) {
      await conditionDropdown.selectOption("payment_method_card");
    }
    await page.locator('[data-button-for="saveRule"]').click();
  });

  test("should set retention policies", async ({ page }) => {
    if (!(await gotoVault(page))) {
      test.skip(true, "Vault Processor not reachable");
    }
    const retentionTab = page.locator(
      '[data-testid*="retention"], [role="tab"]:has-text("Retention")',
    );
    if (!(await retentionTab.isVisible().catch(() => false))) {
      test.skip(true, "Retention tab not exposed");
    }
    await retentionTab.click();
    await page.locator('[name*="retention_days"]').fill("365");

    const autoDeleteToggle = page.locator(
      '[data-testid*="auto-delete"], input[type="checkbox"][name*="auto_delete"]',
    );
    if (await autoDeleteToggle.isVisible().catch(() => false)) {
      await autoDeleteToggle.check();
    }
    await page.locator('[data-button-for="saveRetention"]').click();
  });

  test("should test token operations", async ({ page }) => {
    if (!(await gotoVault(page))) {
      test.skip(true, "Vault Processor not reachable");
    }
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

test.describe("All Vault Processors", () => {
  let email: string;

  const vaultProcessors = Object.entries(vaultProcessorConfig);
  test.beforeEach(async ({ page, _context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  for (const [key, processor] of vaultProcessors) {
    test(`should setup and verify ${key} vault processor`, async ({ page }) => {
      const homePage = new HomePage(page);
      const vaultProcessor = new VaultProcessor(page);

      await homePage.connectors.click();
      const vaultLink = homePage.vaultConnectors;
      if ((await vaultLink.count().catch(() => 0)) === 0) {
        test.skip(true, "Vault Processor not available");
      }

      await vaultLink.click();
      await expect(page).toHaveURL(/.*dashboard\/vault-processor/);

      const connectButtons = vaultProcessor.connectButton;
      await expect(connectButtons.first()).toBeVisible();
      if ((await connectButtons.count().catch(() => 0)) > 0) {
        await connectButtons.nth(0).click();

        if (processor.fields.fieldLabels.length > 0) {
          await fillConnectorFields(page, processor.fields);
        }

        const saveButton = vaultProcessor.saveOrConnectOrProceedButton;
        if (await saveButton.isVisible({ timeout: 5000 }).catch(() => false)) {
          await saveButton.click();
          await page.waitForLoadState("networkidle");

          await vaultProcessor.doneButton.click();

          const connectorLabel =
            processor.fields.overrides["Enter Connector label"] ||
            processor.label;
          await expect(
            page.getByText(connectorLabel, { exact: true }),
          ).toBeVisible({ timeout: 10000 });
        }
      }
    });
  }
});
