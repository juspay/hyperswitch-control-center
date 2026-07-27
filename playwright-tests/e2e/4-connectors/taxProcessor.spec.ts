import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { TaxProcessor } from "../../support/pages/connector/TaxProcessor";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  fillConnectorFields,
} from "../../support/commands";
import { taxProcessorConfig } from "../../support/fixtures/taxProcessorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function gotoTaxConnectorPage(page: Page): Promise<boolean> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  await homePage.taxConnectors.click();
  await page.waitForLoadState("networkidle");
  return true;
}

test.describe("Tax Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
    await gotoTaxConnectorPage(page);
  });

  test("should expose 'Request a Processor' CTA and typeable search", async ({
    page,
  }) => {
    const taxProcessor = new TaxProcessor(page);
    await expect(page.getByText(/Tax|Processor/i).first()).toBeVisible({
      timeout: 10000,
    });
    await expect(taxProcessor.requestProcessorButton).toBeVisible({
      timeout: 10000,
    });
    const search = taxProcessor.searchProcessorPlaceholder;
    await expect(search).toBeVisible({ timeout: 10000 });
    await search.fill("stripe");
    await expect(search).toHaveValue("stripe");
  });
});

test.describe("All Tax Processors", () => {
  let email: string;

  const taxProcessors = Object.entries(taxProcessorConfig);
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await gotoTaxConnectorPage(page);
  });

  for (const [key, processor] of taxProcessors) {
    test(`should setup and verify ${key} tax processor`, async ({ page }) => {
      const homePage = new HomePage(page);
      const taxProcessor = new TaxProcessor(page);

      await expect(page).toHaveURL(/.*dashboard\/tax-processor/);

      const connectButtons = taxProcessor.connectButton;
      await expect(connectButtons.first()).toBeVisible();
      await connectButtons.nth(0).click();
      await fillConnectorFields(page, processor.fields);
      const saveButton = taxProcessor.saveOrConnectOrProceedButton;
      await saveButton.click();
      await page.waitForLoadState("networkidle");
      await taxProcessor.doneButton.click();
      const connectorLabel =
        processor.fields.overrides["Enter Connector label"] || processor.label;
      await expect(page.getByText(connectorLabel, { exact: true })).toBeVisible(
        { timeout: 10000 },
      );
    });
  }
});
