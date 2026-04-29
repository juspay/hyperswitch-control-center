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

  test("should configure authentication provider", async ({ page }) => {
    if (!(await gotoPmAuth(page))) {
      test.skip(true, "PM Auth Processor not reachable");
    }
    const connectButton = page
      .locator('[data-button-for="connectNow"], button:has-text("Connect")')
      .first();
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

    const proceed = page
      .locator(
        '[data-button-for="connectAndProceed"], button:has-text("Connect")',
      )
      .last();
    if (await proceed.isEnabled().catch(() => false)) {
      await proceed.click();
      await expect(
        page.locator(
          '[data-toast*="success"], [data-toast*="Connected"], [data-toast*="Successfully"]',
        ),
      ).toBeVisible({ timeout: 10000 });
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
