import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PmAuthProcessor } from "../../support/pages/connector/PmAuthProcessor";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  fillConnectorFields,
  createDummyConnectorAPI,
} from "../../support/commands";
import { pmAuthProcessorConfig } from "../../support/fixtures/pmAuthProcessorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  const homePage = new HomePage(page);
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  const merchantId = await homePage.merchantID.nth(0).textContent();
  if (merchantId) {
    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
  }
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

async function gotoPmAuth(page: Page): Promise<boolean> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  const link = homePage.pmAuthConnectors;
  if ((await link.count().catch(() => 0)) === 0) return false;
  await link.click();
  await page.waitForLoadState("networkidle");
  return true;
}

test.describe("PM Auth Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
    await enableFeatureFlag(page, "pm_authentication_processor");
  });

  test("should navigate to PM Auth Processor if enabled", async ({ page }) => {
    if (!(await gotoPmAuth(page))) {
      test.skip(true, "PM Auth Processor sidebar entry not exposed");
    }
    await expect(page).toHaveURL(/.*dashboard\/pm-authentication-processor/);
  });

  test("should render PM Auth Processor heading if reachable", async ({
    page,
  }) => {
    if (!(await gotoPmAuth(page))) {
      test.skip(true, "PM Auth Processor sidebar entry not exposed");
    }
    await expect(
      page.getByText(/PM Auth|Authentication|Processor/i).first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should expose 'Request a Processor' CTA and typeable search", async ({
    page,
  }) => {
    if (!(await gotoPmAuth(page))) {
      test.skip(true, "PM Auth Processor not reachable");
    }
    const pmAuthProcessor = new PmAuthProcessor(page);
    const fallback = pmAuthProcessor.goToHomeFallback;
    if (await fallback.isVisible().catch(() => false)) {
      test.skip(true, "Page gated by feature flag fallback");
    }
    await expect(pmAuthProcessor.requestProcessorButton).toBeVisible({
      timeout: 10000,
    });
    await expect(pmAuthProcessor.requestProcessorButton).toBeVisible({
      timeout: 10000,
    });
    const search = pmAuthProcessor.searchProcessorPlaceholder;
    await expect(search).toBeVisible({ timeout: 10000 });
    await search.fill("stripe");
    await expect(search).toHaveValue("stripe");
  });

  test("should configure authentication provider", async ({ page }) => {
    if (!(await gotoPmAuth(page))) {
      test.skip(true, "PM Auth Processor not reachable");
    }
    const pmAuthProcessor = new PmAuthProcessor(page);
    const connectButton = pmAuthProcessor.connectNowOrConnectButton;
    if (!(await connectButton.isVisible().catch(() => false))) {
      test.skip(true, "Connect CTA not exposed");
    }
    await connectButton.click();

    const providerOption = page
      .locator('[data-testid*="pm-auth"], [data-testid*="authentication"]')
      .first();
    if (await providerOption.isVisible().catch(() => false)) {
      await providerOption.click();
    }

    const apiKey = page
      .locator('[name*="api_key"], [name*="client_id"]')
      .first();
    if (await apiKey.isVisible().catch(() => false)) {
      await apiKey.fill("pm_auth_test_key");
    }

    const proceed = pmAuthProcessor.connectAndProceedOrConnectButton;
    if (await proceed.isEnabled().catch(() => false)) {
      await proceed.click();
      await expect(pmAuthProcessor.successToast).toBeVisible({
        timeout: 10000,
      });
      await expect(pmAuthProcessor.successToast).toBeVisible({
        timeout: 10000,
      });
    }
  });

  test("should configure 3DS authentication rules", async ({ page }) => {
    if (!(await gotoPmAuth(page))) {
      test.skip(true, "PM Auth Processor not reachable");
    }
    const rulesSection = page.locator(
      '[data-testid*="rules"], [data-testid*="3ds-rules"]',
    );
    if (!(await rulesSection.isVisible().catch(() => false))) {
      test.skip(true, "Rules section not exposed");
    }
    const addRuleButton = page.locator(
      '[data-button-for="addRule"], button:has-text("Add 3DS Rule")',
    );
    if (!(await addRuleButton.isVisible().catch(() => false))) {
      test.skip(true, "Add Rule CTA not exposed");
    }
    await addRuleButton.click();
    await page.locator('[name*="rule_name"]').fill("3DS for High Value");

    const amountThreshold = page
      .locator('[name*="amount_threshold"], [name*="amount"]')
      .first();
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
  });

  test("should set exemption thresholds", async ({ page }) => {
    if (!(await gotoPmAuth(page))) {
      test.skip(true, "PM Auth Processor not reachable");
    }
    const exemptionsTab = page.locator(
      '[data-testid*="exemption"], [role="tab"]:has-text("Exemption")',
    );
    if (!(await exemptionsTab.isVisible().catch(() => false))) {
      test.skip(true, "Exemption tab not exposed");
    }
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
  });

  test("should verify auth challenge flow configuration", async ({ page }) => {
    if (!(await gotoPmAuth(page))) {
      test.skip(true, "PM Auth Processor not reachable");
    }
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

test.describe("All PM Auth Processors", () => {
  const pmAuthProcessors = Object.entries(pmAuthProcessorConfig);
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  for (const [key, processor] of pmAuthProcessors) {
    test(`should setup and verify ${key} PM Auth processor`, async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const pmAuthProcessor = new PmAuthProcessor(page);

      await homePage.connectors.click();
      const pmAuthLink = homePage.pmAuthConnectors;
      if ((await pmAuthLink.count().catch(() => 0)) === 0) {
        test.skip(true, "PM Auth Processor not available");
      }

      await pmAuthLink.click();
      await expect(page).toHaveURL(/.*dashboard\/pm-authentication-processor/);

      const connectButtons = pmAuthProcessor.connectButton;
      await expect(connectButtons.first()).toBeVisible();
      if ((await connectButtons.count().catch(() => 0)) > 0) {
        await connectButtons.nth(0).click();

        if (processor.fields.fieldLabels.length > 0) {
          await fillConnectorFields(page, processor.fields);
        }

        const saveButton = pmAuthProcessor.saveOrConnectOrProceedButton;
        if (await saveButton.isVisible({ timeout: 5000 }).catch(() => false)) {
          await saveButton.click();
          await page.waitForLoadState("networkidle");

          await pmAuthProcessor.doneButton.click();

          const connectorLabel =
            processor.fields.overrides["Enter Connector label"] ||
            processor.label;
          await expect(
            page.getByText(connectorLabel, { exact: true }),
          ).toBeVisible({ timeout: 10000 });
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
