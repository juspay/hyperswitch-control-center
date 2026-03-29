import { test, expect } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentConnector } from "../../support/pages/connector/PaymentConnector";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnector,
  assertConnectorFieldLabels,
  fillConnectorFields,
  assertPaymentMethodTypes,
} from "../../support/commands";
import { connectorConfig } from "../../support/fixtures/payinConnectorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

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

    await expect(page.getByText("Credentials")).toBeVisible();
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
    await page.goto("/dashboard/connectors");
  });

  for (const connector of Object.values(connectorConfig)) {
    test(`should setup and verify ${connector.label} connector`, async ({
      page,
    }) => {
      const paymentConnector = new PaymentConnector(page);

      await paymentConnector.connectorSearchInput.fill(connector.label);
      await paymentConnector.addConnectButton.nth(0).click();

      for (const fieldLabel of connector.fields.fieldLabels) {
        await expect(page.getByText(fieldLabel)).toBeVisible();
      }

      await page
        .locator("[name=connector_account_details\\.api_key]")
        .fill("test_key");

      const labelField = page.locator("[name=connector_label]");
      const existingValue = await labelField.inputValue();
      if (!existingValue) {
        await labelField.fill(connector.label + "_default");
      }

      await paymentConnector.connectAndProceedButton.click();

      for (const [sectionName, sectionData] of Object.entries(
        connector.paymentSections,
      )) {
        await expect(page.getByText(sectionName)).toBeVisible();
        for (const method of sectionData.methods.slice(0, 3)) {
          await expect(page.getByText(method)).toBeVisible();
        }
      }

      if (await page.locator("[data-testid=credit_select_all]").isVisible()) {
        await page.locator("[data-testid=credit_select_all]").click();
      }
      if (await page.locator("[data-testid=debit_select_all]").isVisible()) {
        await page.locator("[data-testid=debit_select_all]").click();
      }

      await paymentConnector.pmtProceedButton.click();
      await paymentConnector.connectorSetupDone.click();

      await expect(page).toHaveURL(/.*dashboard\/connectors/);
      await expect(page.getByText(connector.label + "_default")).toBeVisible();
    });
  }
});

test.describe("Test live connectors", () => {
  test.describe.configure({ mode: "serial" });

  let email: string;

  test.beforeAll(async () => {
    email = generateUniqueEmail();
  });

  test.beforeEach(async ({ page, context }) => {
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.goto("/dashboard/connectors");
  });

  for (const connector of Object.values(connectorConfig)) {
    test(`should setup and verify ${connector.label} connector`, async ({
      page,
    }) => {
      const paymentConnector = new PaymentConnector(page);

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
        page.getByText(connector.fields.overrides["Enter Connector label"]),
      ).toBeVisible();
    });
  }
});
