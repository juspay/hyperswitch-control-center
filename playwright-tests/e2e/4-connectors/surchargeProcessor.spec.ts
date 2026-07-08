import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { SurchargeProcessor } from "../../support/pages/connector/SurchargeProcessor";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function gotoSurcharge(page: Page): Promise<boolean> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  const link = homePage.surchargeConnectors;
  if ((await link.count().catch(() => 0)) === 0) return false;
  await link.click();
  await page.waitForLoadState("networkidle");
  return true;
}

test.describe("Surcharge Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should navigate to Surcharge Processor if enabled", async ({
    page,
  }) => {
    await gotoSurcharge(page);
    await expect(page).toHaveURL(/.*dashboard\/surcharge-processor/);
  });

  test("should configure InterPayments surcharge processor", async ({
    page,
  }) => {
    await gotoSurcharge(page);
    const surchargeProcessor = new SurchargeProcessor(page);
    const connectButton = surchargeProcessor.connectNowOrConnectButton;

    await expect(connectButton).toBeVisible();
    await connectButton.click();

    const apiKeyInput = page.locator('[name*="api_key"]').first();
    await expect(apiKeyInput).toBeVisible();
    await apiKeyInput.fill("interpayments_test_api_key");

    await surchargeProcessor.connectAndProceedButton.click();
    await surchargeProcessor.doneButton.click();
    await expect(page.getByTestId("interpayments_default")).toBeVisible();
  });
});
