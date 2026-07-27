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
  assertConnectorFieldLabels,
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
    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request, page);
  }
}

async function gotoPmAuth(page: Page): Promise<boolean> {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  await homePage.pmAuthConnectors.click();
  await page.waitForLoadState("networkidle");
  return true;
}

test.describe("PM Auth Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
    await gotoPmAuth(page);
  });

  test("should expose 'Request a Processor' CTA and typeable search", async ({
    page,
  }) => {
    const pmAuthProcessor = new PmAuthProcessor(page);
    await expect(page).toHaveURL(/.*dashboard\/pm-authentication-processor/);
    await expect(pmAuthProcessor.requestProcessorButton).toBeVisible({
      timeout: 10000,
    });
    const search = pmAuthProcessor.searchProcessorPlaceholder;
    await expect(search).toBeVisible({ timeout: 10000 });
    await search.fill("stripe");
    await expect(search).toHaveValue("stripe");
  });
});

test.describe("Live PM Auth Processors", () => {
  let email: string;

  const pmAuthProcessors = Object.entries(pmAuthProcessorConfig);
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
        page
      );
    }
  });

  for (const [key, connector] of pmAuthProcessors) {
    test(`should setup and verify ${key} PM auth processor`, async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const pmAuthProcessor = new PmAuthProcessor(page);

      await homePage.connectors.click();
      await homePage.pmAuthConnectors.click();

      await expect(page).toHaveURL(/.*dashboard\/pm-authentication-processor/);

      await pmAuthProcessor.connectButton.first().click();

      await assertConnectorFieldLabels(page, connector.fields.fieldLabels);
      await fillConnectorFields(page, connector.fields);

      await pmAuthProcessor.saveOrConnectOrProceedButton.click();
      await page.waitForLoadState("networkidle");

      // await expect(pmAuthProcessor.successToast).toBeVisible({
      //   timeout: 10000,
      // });
      await pmAuthProcessor.doneButton.click();

      const connectorLabel =
        connector.fields.overrides["Enter Connector label"] || connector.label;
      await expect(page.getByText(connectorLabel, { exact: true })).toBeVisible(
        { timeout: 10000 },
      );
    });
  }
});
