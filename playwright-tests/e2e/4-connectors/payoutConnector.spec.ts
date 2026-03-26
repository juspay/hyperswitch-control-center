import { test, expect } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PayoutConnector } from "../../support/pages/connector/PayoutConnector";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Payout Connector", () => {
  let email: string;

  test.beforeAll(() => {
    email = generateUniqueEmail();
  });

  test.beforeEach(async ({ page, context }) => {
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.goto("/dashboard/payoutconnectors");
  });

  test("should setup and verify stripe_test payout connector", async ({
    page,
  }) => {
    const payoutConnector = new PayoutConnector(page);

    await expect(payoutConnector.pageHeading).toContainText(
      "Payout Processors",
    );
    await expect(payoutConnector.pageHeading).toBeVisible();

    await payoutConnector.connectorSearchInput.fill("stripe_test");
    await payoutConnector.addConnectButton.nth(0).click();

    await expect(
      page.locator("[name=connector_account_details\\.api_key]"),
    ).toBeVisible();
    await page
      .locator("[name=connector_account_details\\.api_key]")
      .fill("test_key");
    await page.locator("[name=connector_label]").fill("stripe_payout_test");

    await payoutConnector.connectAndProceedButton.click();

    await expect(page.getByText("Credit")).toBeVisible();
    await page.locator("[data-testid=credit_select_all]").click();

    await payoutConnector.pmtProceedButton.click();
    await payoutConnector.connectorSetupDone.click();

    await expect(page).toHaveURL(/.*dashboard\/payoutconnectors/);
    await expect(page.getByText("stripe_payout_test")).toBeVisible();
  });
});
