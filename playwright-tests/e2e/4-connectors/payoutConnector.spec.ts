import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PayoutConnector } from "../../support/pages/connector/PayoutConnector";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  assertConnectorFieldLabels,
  fillConnectorFields,
  assertPaymentMethodTypes,
} from "../../support/commands";
import { payoutConnectorConfig } from "../../support/fixtures/payoutConnectorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Payout Connector", () => {
  let email: string;

  const payoutConnectors = Object.entries(payoutConnectorConfig);
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  for (const [key, connector] of payoutConnectors) {
    test(`should setup and verify ${key} payout connector`, async ({
      page,
    }) => {
      const payoutConnector = new PayoutConnector(page);
      const homePage = new HomePage(page);

      await homePage.connectors.click();
      await homePage.payoutConnectors.click();

      await expect(payoutConnector.pageHeading).toContainText(
        "Payout Processors",
      );
      await expect(payoutConnector.pageHeading).toBeVisible();

      await payoutConnector.connectorSearchInput.fill(connector.label);
      await payoutConnector.addConnectButton.nth(0).click();

      await assertConnectorFieldLabels(page, connector.fields.fieldLabels);
      await fillConnectorFields(page, connector.fields);

      await payoutConnector.connectAndProceedButton.click();

      await assertPaymentMethodTypes(page, connector.paymentSections);

      await payoutConnector.pmtProceedButton.click();
      await payoutConnector.connectorSetupDone.click();

      await expect(page).toHaveURL(/.*dashboard\/payoutconnectors/);
      const connectorLabelOverride =
        connector.fields.overrides["Enter Connector label"];
      if (connectorLabelOverride) {
        await expect(page.getByText(connectorLabelOverride)).toBeVisible();
      }
    });
  }
});
