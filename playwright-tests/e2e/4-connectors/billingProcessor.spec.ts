import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { BillingProcessor } from "../../support/pages/connector/BillingProcessor";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  fillConnectorFields,
} from "../../support/commands";
import { billingProcessorConfig } from "../../support/fixtures/billingProcessorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function gotoBilling(page: Page): Promise<boolean> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  await homePage.billingConnectors.click();
  await page.waitForLoadState("networkidle");
  return true;
}

test.describe("Billing Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
    await gotoBilling(page);
  });

  test("should expose 'Request a Processor' CTA and typeable search", async ({
    page,
  }) => {
    const billingProcessor = new BillingProcessor(page);
    const fallback = billingProcessor.goToHomeFallback;
    await expect(billingProcessor.requestProcessorButton).toBeVisible({
      timeout: 10000,
    });
    const search = billingProcessor.searchProcessorPlaceholder;
    await expect(search).toBeVisible({ timeout: 10000 });
    await search.fill("stripe");
    await expect(search).toHaveValue("stripe");
  });

  test("should configure Chargebee connector", async ({ page }) => {
    const billingProcessor = new BillingProcessor(page);
    const connectButton = billingProcessor.connectNowOrConnectButton;
    await connectButton.click();

    const chargebeeOption = page.locator('[data-testid*="chargebee"]').first();
    await chargebeeOption.click();

    await page.getByRole('textbox', { name: 'Enter Chargebee API Key' }).fill("test_key");
    await page.getByRole('textbox', { name: 'Enter chargebee site' }).fill("test_key");
    await page.getByRole('textbox', { name: 'Enter Webhook URL Username' }).fill("test_key");
    await page.getByRole('textbox', { name: 'Enter Webhook URL Password' }).fill("test_key");

    await billingProcessor.connectAndProceedButton.click();
    await page.getByRole('button', { name: 'Done' }).click();

    //await expect(billingProcessor.successToast).toBeVisible({ timeout: 10000 });

    await expect(page.locator('div').filter({ hasText: /^chargebee_default$/ }).first()).toBeVisible();
  });
});