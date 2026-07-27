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

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function gotoVault(page: Page): Promise<boolean> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  await homePage.vaultConnectors.click();
  await page.waitForLoadState("networkidle");
  return true;
}

test.describe("Vault Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
    await gotoVault(page);
  });

  test("should expose 'Request a Processor' CTA and typeable search", async ({
    page,
  }) => {
    const vaultProcessor = new VaultProcessor(page);
    await expect(page).toHaveURL(/.*dashboard\/vault-processor/);
    await expect(vaultProcessor.requestProcessorButton).toBeVisible({
      timeout: 10000,
    });
    const search = vaultProcessor.searchProcessorPlaceholder;
    await expect(search).toBeVisible({ timeout: 10000 });
    await search.fill("stripe");
    await expect(search).toHaveValue("stripe");
  });
});

test.describe("All Vault Processors", () => {
  let email: string;

  const vaultProcessors = Object.entries(vaultProcessorConfig);
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  for (const [key, processor] of vaultProcessors) {
    test(`should setup and verify ${key} vault processor`, async ({ page }) => {
      const homePage = new HomePage(page);
      const vaultProcessor = new VaultProcessor(page);

      await homePage.connectors.click();
      await gotoVault(page);
      await expect(page).toHaveURL(/.*dashboard\/vault-processor/);

      const connectButtons = vaultProcessor.connectButton;
      await expect(connectButtons.first()).toBeVisible();
      await connectButtons.nth(0).click();

      await fillConnectorFields(page, processor.fields);

      const saveButton = vaultProcessor.saveOrConnectOrProceedButton;
      await saveButton.click();
      await page.waitForLoadState("networkidle");
      await vaultProcessor.doneButton.click();
      const connectorLabel =
        processor.fields.overrides["Enter Connector label"] || processor.label;
      await expect(page.getByText(connectorLabel, { exact: true })).toBeVisible(
        { timeout: 10000 },
      );
    });
  }
});
