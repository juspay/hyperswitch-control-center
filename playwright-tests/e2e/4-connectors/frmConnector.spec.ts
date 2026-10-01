import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { FrmConnector } from "../../support/pages/connector/FrmConnector";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  assertConnectorFieldLabels,
  fillConnectorFields,
  createDummyConnectorAPI,
} from "../../support/commands";
import type { DummyPaymentMethod } from "../../support/commands";
import {
  frmConnectorConfig,
  type ConnectorConfig,
} from "../../support/fixtures/frmConnectorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

// A player is only offered the connectors exposing a payment method it can screen, so
// each group is set up with the dummy connector its players need.
const frmConnectorsByPaymentMethod = Object.entries(frmConnectorConfig).reduce(
  (grouped, entry) => {
    const paymentMethod = entry[1].screened_payment_method;
    grouped[paymentMethod] = [...(grouped[paymentMethod] ?? []), entry];
    return grouped;
  },
  {} as Record<DummyPaymentMethod, [string, ConnectorConfig][]>,
);

test.describe("FRM (Fraud & Risk) Connectors", () => {
  test.beforeEach(async ({ page }) => {
    await signupAndLogin(page);
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

for (const [paymentMethod, connectors] of Object.entries(
  frmConnectorsByPaymentMethod,
) as [DummyPaymentMethod, [string, ConnectorConfig][]][]) {
  test.describe(`Live FRM Connectors screening ${paymentMethod}`, () => {
    test.beforeEach(async ({ page, context }) => {
      const homePage = new HomePage(page);

      await signupAndLogin(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
          page,
          paymentMethod,
        );
      }

      await homePage.connectors.click();
      await homePage.frmConnectors.click();
      await expect(page).toHaveURL(/.*dashboard\/fraud-risk-management/);
    });

    for (const [key, connector] of connectors) {
      test(`should setup and verify ${key} FRM connector`, async ({ page }) => {
        const frmConnector = new FrmConnector(page);
        const screenedMethod = connector.screened_payment_method_label;

        await page
          .getByText(connector.card_locator)
          .getByRole("button", { name: "Connect" })
          .click();

        if (connector.compatibility_note) {
          await expect(
            page.getByText(connector.compatibility_note),
          ).toBeVisible();
        }

        // The configured connector's row on the payment methods step, toggled on by
        // default with the only method this player screens.
        await expect(
          page
            .locator("div")
            .filter({
              hasText: new RegExp(
                `^Stripe Test${screenedMethod}Enabled with Pre-Authorization$`,
              ),
            })
            .first(),
        ).toBeVisible();
        await frmConnector.saveOrConnectOrProceedButton.click();

        await assertConnectorFieldLabels(page, connector.fields.fieldLabels);
        await fillConnectorFields(page, connector.fields);

        await expect(page.getByText("BackConnect and Finish")).toBeVisible();
        await page.getByText("Connect and Finish").click();

        await expect(
          page.getByRole("status", { name: "Connector Created Successfully!" }),
        ).toBeVisible();
        await expect(
          page.getByText(`Stripe Test${screenedMethod}Flow :Pre Auth`),
        ).toBeVisible();
        await page.getByRole("button", { name: "Done" }).click();

        // Back on the list: the player now shows in Connected Processors. The
        // "connect a new player" cards are hidden once one is configured, so the
        // display name resolves to the table row.
        await expect(
          page.getByText(connector.display_name, { exact: true }),
        ).toBeVisible();
      });
    }
  });
}

// Sanlam Payshield declares bank debit for payments and bank transfer for payouts. The
// two must not cross over: a payment connector exposing bank transfer is a payouts-only
// method on a payments connector and cannot be screened.
test.describe("Sanlam Payshield connector compatibility", () => {
  const payshield = frmConnectorConfig.sanlam_payshield;

  test.beforeEach(async ({ page, context }) => {
    const homePage = new HomePage(page);

    await signupAndLogin(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      // Card keeps the Fraud & Risk page open (the other players screen card)...
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_card",
        context.request,
        page,
        "card",
      );
      // ...while this one offers only a method Payshield screens on payouts.
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_bank_transfer",
        context.request,
        page,
        "bank_transfer",
      );
    }

    await homePage.connectors.click();
    await homePage.frmConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/fraud-risk-management/);
  });

  test("should not offer bank transfer on a payment connector", async ({
    page,
  }) => {
    await page
      .getByText(payshield.card_locator)
      .getByRole("button", { name: "Connect" })
      .click();

    await expect(page.getByText(payshield.compatibility_note!)).toBeVisible();
    await expect(
      page.getByText("No compatible connector is configured yet."),
    ).toBeVisible();
    // exact, so the note's own prose ("...bank transfer payouts...") is not a match
    await expect(
      page.getByText("Bank Transfer", { exact: true }),
    ).not.toBeAttached();
    await expect(page.getByText("Card", { exact: true })).not.toBeAttached();
  });
});
