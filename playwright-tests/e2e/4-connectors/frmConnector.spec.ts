import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { FrmConnector } from "../../support/pages/connector/FrmConnector";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  assertConnectorFieldLabels,
  fillConnectorFields,
  createDummyConnectorAPI
} from "../../support/commands";
import { frmConnectorConfig } from "../../support/fixtures/frmConnectorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function gotoFrmList(page: Page) {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  await homePage.frmConnectors.click();
  await page.waitForLoadState("networkidle");
}

test.describe("FRM (Fraud & Risk) Connectors", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should navigate to FRM connectors page via sidebar", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    await homePage.connectors.click();
    await homePage.frmConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/fraud-risk-management/);
  });
});

test.describe("Live FRM Connectors", () => {
  let email: string;

  const frmConnectors = Object.entries(frmConnectorConfig);
  test.beforeEach(async ({ page, context }) => {
    const homePage = new HomePage(page);
    email = generateUniqueEmail();

    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
    }
  });

  for (const [key, connector] of frmConnectors) {
    test(`should setup and verify ${key} FRM connector`, async ({ page }) => {
      const homePage = new HomePage(page);
      const frmConnector = new FrmConnector(page);

      await homePage.connectors.click();
      await homePage.frmConnectors.click();

      await expect(page).toHaveURL(/.*dashboard\/fraud-risk-management/);

      await page.getByText(connector.card_locator).getByRole('button', { name: 'Connect' }).click();
      await expect(page.locator('div').filter({ hasText: /^ProceedStripe TestCardEnabled with Pre-Authorization$/ }).first()).toBeVisible();
      await frmConnector.saveOrConnectOrProceedButton.click();

      await assertConnectorFieldLabels(page, connector.fields.fieldLabels);
      await fillConnectorFields(page, connector.fields);

      await expect(page.getByText('BackConnect and Finish')).toBeVisible();
      await page.getByText('Connect and Finish').click();

      await expect(page.getByRole('status', { name: 'FRM Player Created' })).toBeVisible();
      await expect(page.getByText('Stripe TestCardFlow :Pre Auth')).toBeVisible();
      await page.getByRole('button', { name: 'Done' }).click();
      await expect(page.getByText(connector.label));
    });
  }
});
