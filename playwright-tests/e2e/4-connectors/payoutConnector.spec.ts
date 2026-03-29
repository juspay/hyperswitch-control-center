import { test, expect } from "@playwright/test";
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

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Payout Connector", () => {
  test.describe.configure({ mode: "serial" });

  let email: string;

  test.beforeAll(async () => {
    email = generateUniqueEmail();
  });

  test.beforeEach(async ({ page, context }) => {
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.goto("/dashboard/payoutconnectors");
  });

  for (const connector of Object.values(payoutConnectorConfig)) {
    test(`should setup and verify ${connector.label} payout connector`, async ({
      page,
    }) => {
      const payoutConnector = new PayoutConnector(page);

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
      await expect(
        page.getByText(connector.fields.overrides["Enter Connector label"]),
      ).toBeVisible();
    });
  }
});
