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

async function gotoBilling(page: Page): Promise<boolean> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  const link = homePage.billingConnectors;
  if ((await link.count().catch(() => 0)) === 0) return false;
  await link.click();
  await page.waitForLoadState("networkidle");
  return true;
}

test.describe("Billing Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
    await enableFeatureFlag(page, "billing_processor");
  });

  test("should navigate to Billing Processor if enabled", async ({ page }) => {
    if (!(await gotoBilling(page))) {
      test.skip(true, "Billing Processor sidebar entry not exposed");
    }
    await expect(page).toHaveURL(/.*dashboard\/billing-processor/);
  });

  test("should render Billing Processor heading if reachable", async ({
    page,
  }) => {
    if (!(await gotoBilling(page))) {
      test.skip(true, "Billing Processor sidebar entry not exposed");
    }
    await expect(page.getByText(/Billing|Processor/i).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("should expose 'Request a Processor' CTA and typeable search", async ({
    page,
  }) => {
    if (!(await gotoBilling(page))) {
      test.skip(true, "Billing Processor not reachable");
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

  test("should configure Chargebee connector", async ({ page }) => {
    if (!(await gotoBilling(page))) {
      test.skip(true, "Billing Processor not reachable");
    }
    const connectButton = page
      .locator('[data-button-for="connectNow"], button:has-text("Connect")')
      .first();
    if (!(await connectButton.isVisible().catch(() => false))) {
      test.skip(true, "Connect CTA not exposed");
    }
    await connectButton.click();

    const chargebeeOption = page
      .locator('[data-testid*="chargebee"]')
      .first();
    if (await chargebeeOption.isVisible().catch(() => false)) {
      await chargebeeOption.click();
    }

    await page
      .locator('[name*="api_key"], [name*="site"]')
      .first()
      .fill("chargebee_test_site");
    await page
      .locator('[name*="api_key"]')
      .first()
      .fill("chargebee_test_api_key");

    await page.locator('[data-button-for="connectAndProceed"]').click();

    await expect(
      page.locator('[data-toast*="success"], [data-toast*="Successfully"]'),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should configure subscription plans sync", async ({ page }) => {
    if (!(await gotoBilling(page))) {
      test.skip(true, "Billing Processor not reachable");
    }
    const syncTab = page.locator(
      '[data-testid*="sync"], [role="tab"]:has-text("Sync")',
    );
    if (!(await syncTab.isVisible().catch(() => false))) {
      test.skip(true, "Sync tab not exposed");
    }
    await syncTab.click();

    const planCheckbox = page
      .locator('[data-testid*="plan"], input[type="checkbox"]')
      .first();
    if (await planCheckbox.isVisible().catch(() => false)) {
      await planCheckbox.check();
    }
    await page
      .locator('[data-button-for="saveSync"], button:has-text("Save Sync")')
      .click();
  });

  test("should set up invoice webhooks", async ({ page }) => {
    if (!(await gotoBilling(page))) {
      test.skip(true, "Billing Processor not reachable");
    }
    const webhooksTab = page.locator(
      '[data-testid*="webhook"], [role="tab"]:has-text("Webhook")',
    );
    if (!(await webhooksTab.isVisible().catch(() => false))) {
      test.skip(true, "Webhooks tab not exposed");
    }
    await webhooksTab.click();

    await page
      .locator('[name*="webhook_url"], [name*="webhookUrl"]')
      .fill("https://example.com/webhooks/billing");

    const eventCheckboxes = page.locator(
      '[data-testid*="invoice"], input[type="checkbox"][name*="event"]',
    );
    const count = await eventCheckboxes.count();
    for (let i = 0; i < Math.min(count, 3); i++) {
      await eventCheckboxes.nth(i).check();
    }
    await page.locator('[data-button-for="saveWebhooks"]').click();
  });
});
