import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { SurchargeProcessor } from "../../support/pages/connector/SurchargeProcessor";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, _context: BrowserContext) {
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

async function configureInterPayments(page: Page): Promise<void> {
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
    await configureInterPayments(page);
  });

  test("should disable and re-enable InterPayments surcharge processor", async ({
    page,
  }) => {
    const surchargeProcessor = new SurchargeProcessor(page);
    await configureInterPayments(page);

    await page.getByTestId("interpayments_default").click();
    await expect(
      surchargeProcessor.connectorEnableStatus("Enabled"),
    ).toBeVisible();

    await surchargeProcessor.connectorEnableToggle.click();
    await expect(
      surchargeProcessor.connectorEnableStatus("Disabled"),
    ).toBeVisible({ timeout: 10000 });

    await gotoSurcharge(page);
    await expect(page.getByText("DISABLED", { exact: true })).toBeVisible();

    await page.getByTestId("interpayments_default").click();
    await expect(
      surchargeProcessor.connectorEnableStatus("Disabled"),
    ).toBeVisible();
    await surchargeProcessor.connectorEnableToggle.click();
    await expect(
      surchargeProcessor.connectorEnableStatus("Enabled"),
    ).toBeVisible({ timeout: 10000 });

    await gotoSurcharge(page);
    await expect(page.getByText("ENABLED", { exact: true })).toBeVisible();
  });
});
