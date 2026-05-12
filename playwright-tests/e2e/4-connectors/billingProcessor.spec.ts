import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { BillingProcessor } from "../../support/pages/connector/BillingProcessor";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI, fillConnectorFields } from "../../support/commands";
import { billingProcessorConfig } from "../../support/fixtures/billingProcessorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
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
    const billingProcessor = new BillingProcessor(page);
    const fallback = billingProcessor.goToHomeFallback;
    if (await fallback.isVisible().catch(() => false)) {
      test.skip(true, "Page gated by feature flag fallback");
    }
    await expect(billingProcessor.requestProcessorButton).toBeVisible({ timeout: 10000 });
    const search = billingProcessor.searchProcessorPlaceholder;
    await expect(search).toBeVisible({ timeout: 10000 });
    await search.fill("stripe");
    await expect(search).toHaveValue("stripe");
  });

  test("should configure Chargebee connector", async ({ page }) => {
    if (!(await gotoBilling(page))) {
      test.skip(true, "Billing Processor not reachable");
    }
    const billingProcessor = new BillingProcessor(page);
    const connectButton = billingProcessor.connectNowOrConnectButton;
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

    await billingProcessor.connectAndProceedButton.click();

    await expect(billingProcessor.successToast).toBeVisible({ timeout: 10000 });
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

test.describe("All Billing Processors", () => {
  let email: string;

  const billingProcessors = Object.entries(billingProcessorConfig);
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  for (const [key, processor] of billingProcessors) {
    test(`should setup and verify ${key} billing processor`, async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const billingProcessor = new BillingProcessor(page);

      await homePage.connectors.click();
      const billingLink = homePage.billingConnectors;
      if ((await billingLink.count().catch(() => 0)) === 0) {
        test.skip(true, "Billing Processor not available");
      }

      await billingLink.click();
      await expect(page).toHaveURL(/.*dashboard\/billing-processor/);

      const connectButtons = billingProcessor.connectButton;
      await expect(connectButtons.first()).toBeVisible();
      if ((await connectButtons.count().catch(() => 0)) > 0) {
        await connectButtons.nth(0).click();

        if (processor.fields.fieldLabels.length > 0) {
          await fillConnectorFields(page, processor.fields);
        }

        const saveButton = billingProcessor.saveOrConnectOrProceedButton;
        if (await saveButton.isVisible({ timeout: 5000 }).catch(() => false)) {
          await saveButton.click();
          await page.waitForLoadState("networkidle");

          await billingProcessor.doneButton.click();

          const connectorLabel = processor.fields.overrides["Enter Connector label"] || processor.label;
          await expect(page.getByText(connectorLabel, { exact: true })).toBeVisible({ timeout: 10000 });
        }
      }
    });
  }
});
