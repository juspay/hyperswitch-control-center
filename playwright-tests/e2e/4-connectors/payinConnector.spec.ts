import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentConnector } from "../../support/pages/connector/PaymentConnector";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  assertConnectorFieldLabels,
  fillConnectorFields,
  assertPaymentMethodTypes,
} from "../../support/commands";
import { connectorConfig } from "../../support/fixtures/payinConnectorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Payin Connector", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should setup a dummy connector", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await expect(paymentConnector.pageHeading).toContainText(
      "Payment Processors",
    );
    await expect(paymentConnector.pageHeading).toBeVisible();
    await expect(paymentConnector.pageBanner).toContainText(
      "Connect a Dummy Processor",
    );

    await paymentConnector.connectNowButton.click({ force: true });

    await expect(paymentConnector.stripeDummyConnector).toBeVisible();
    await paymentConnector.stripeDummyConnector
      .locator("button")
      .click({ force: true });

    //await expect(page.getByText("Credentials")).toBeVisible();
    await expect(
      page.locator("[name=connector_account_details\\.api_key]"),
    ).toHaveValue("test_key");

    await paymentConnector.connectAndProceedButton.click();
    await paymentConnector.pmtProceedButton.click();

    await expect(
      page.locator('[data-toast="Connector Created Successfully!"]'),
    ).toBeVisible();

    await paymentConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/connectors/);
    await expect(page.getByText("stripe_test_default")).toBeVisible();
  });
});

test.describe("Test live connectors", () => {
  let email: string;

  test.beforeAll(() => {
    email = generateUniqueEmail();
  });

  test.beforeEach(async ({ page, context }) => {
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  const connectors = Object.entries(connectorConfig);
  for (const [key, connector] of connectors) {
    test(`should setup and verify ${key} connector`, async ({ page }) => {
      const paymentConnector = new PaymentConnector(page);
      const homePage = new HomePage(page);

      await homePage.connectors.click();
      await homePage.paymentProcessors.click();

      await paymentConnector.connectorSearchInput.fill(connector.label);
      await paymentConnector.addConnectButton.nth(0).click();

      await assertConnectorFieldLabels(page, connector.fields.fieldLabels);
      await fillConnectorFields(page, connector.fields);

      await paymentConnector.connectAndProceedButton.click();

      await assertPaymentMethodTypes(page, connector.paymentSections);

      await paymentConnector.pmtProceedButton.click();
      await paymentConnector.connectorSetupDone.click();

      await expect(page).toHaveURL(/.*dashboard\/connectors/);
      await expect(
        page.getByTestId(
          connector.fields.overrides["Enter Connector label"] ||
          connector.label,
        ),
      ).toBeVisible();
      await page
        .getByTestId(
          connector.fields.overrides["Enter Connector label"] ||
          connector.label,
        )
        .click();
    });
  }
});
