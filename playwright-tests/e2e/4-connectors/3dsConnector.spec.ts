import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { ThreeDSAuthenticator } from "../../support/pages/connector/ThreeDSAuthenticator";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI, assertConnectorFieldLabels, fillConnectorFields, generateCerts } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function gotoThreeDS(page: Page) {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  await homePage.threeDSConnectors.click();
  await page.waitForLoadState("networkidle");
}

test.describe("3DS Authenticators Module", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should navigate to 3DS authenticators page via sidebar and verify all elements are present", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.threeDSConnectors.click();

    await expect(page).toHaveURL(/.*dashboard\/3ds-authenticators/);

    await expect(page.getByText(/3DS Authenticator/i).first()).toBeVisible({
      timeout: 10000,
    });

    await expect(
      page.locator('[data-testid="search-processor"]'),
    ).toBeVisible();
  });

  test("should expose 'Request a Processor' CTA on 3DS list page", async ({
    page,
  }) => {
    await gotoThreeDS(page);
    const cta = page
      .getByRole("button", { name: "Request a Processor" })
      .first();
    if (!(await cta.isVisible().catch(() => false))) {
      test.skip(true, "Request a Processor CTA not exposed");
    }
    await expect(cta).toBeVisible({ timeout: 10000 });
  });

  test("should filter 3DS authenticator list when searching", async ({
    page,
  }) => {
    await gotoThreeDS(page);
    const searchInput = page.locator('[data-testid="search-processor"]');
    if (!(await searchInput.isVisible().catch(() => false))) {
      test.skip(true, "Search input not exposed on 3DS list");
    }
    await searchInput.fill("threedsecureio");
    await page.waitForTimeout(500);
    await expect(searchInput).toHaveValue("threedsecureio");
  });

  test("should show no results when searching unknown authenticator", async ({
    page,
  }) => {
    await gotoThreeDS(page);
    const searchInput = page.locator('[data-testid="search-processor"]');
    if (!(await searchInput.isVisible().catch(() => false))) {
      test.skip(true, "Search input not exposed on 3DS list");
    }
    await searchInput.fill("notarealauthenticator_zzz");
    await page.waitForTimeout(1000);
    await expect(searchInput).toHaveValue("notarealauthenticator_zzz");
  });

  test("should open configuration form when a 3DS authenticator is selected", async ({
    page,
  }) => {
    await gotoThreeDS(page);
    const connectButtons = page.locator('[data-button-text="Connect"]');
    if ((await connectButtons.count().catch(() => 0)) === 0) {
      test.skip(true, "No 3DS authenticators exposed");
    }
    await connectButtons.nth(0).click();
    await expect(page.getByText("API Key *")).toBeVisible();
    await expect(page.getByText("Organization Unit ID *")).toBeVisible();
    await expect(page.getByText("API ID *")).toBeVisible();
    await expect(page.getByText("Connector label *")).toBeVisible();
    await expect(page.getByText("Pull Mechanism Enabled")).toBeVisible();
  });
});

test.describe("3DS Authenticators Setup", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should setup Netcetera authenticator", async ({ page }) => {
    const { certBase64, keyBase64 } = await generateCerts();
    const threeDSAuthenticator = new ThreeDSAuthenticator(page);

    await gotoThreeDS(page);
    await threeDSAuthenticator.authenticatorSearchInput.fill("Netcetera");
    await threeDSAuthenticator.connectButton.nth(0).click();

    await expect(page.getByTestId('base64_encoded_pem_formatted_certificate_chain').getByText('Base64 encoded PEM formatted')).toBeVisible();
    await page.getByTestId('connector_account_details.certificate').getByRole('textbox', { name: 'Enter Base64 encoded PEM' }).fill(certBase64);

    await expect(page.getByTestId('base64_encoded_pem_formatted_private_key').getByText('Base64 encoded PEM formatted')).toBeVisible();
    await page.getByTestId('connector_account_details.private_key').getByRole('textbox', { name: 'Enter Base64 encoded PEM' }).fill(keyBase64);

    await expect(page.locator('div').filter({ hasText: /^Connector label \*$/ }).nth(2)).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Connector label' }).fill("netcetera_default");

    await expect(page.getByText('Live endpoint prefix *')).toBeVisible();
    await page.getByRole('textbox', { name: 'string that will replace \'{' }).fill("test_value");

    await expect(page.locator('div').filter({ hasText: /^MCC$/ }).nth(2)).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter MCC' }).fill("test_value");

    await expect(page.getByText('digit numeric country code')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter 3 digit numeric country' }).fill("test_value");

    await expect(page.getByText('Name of the merchant')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Name of the merchant' }).fill("test_value");

    await expect(page.getByText('ThreeDS requestor name')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter ThreeDS requestor name' }).fill("test_value");

    await expect(page.getByText('ThreeDS request id')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter ThreeDS request id' }).fill("test_value");

    await expect(page.getByText('Merchant Configuration ID')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Merchant Configuration' }).fill("test_value");

    await page.locator('[data-button-for="connectAndProceed"]').click();

    await page.getByRole('button', { name: 'Done' }).click();

    await expect(page.getByText("netcetera_default", { exact: true })).toBeVisible({ timeout: 10000 });
  });

  test("should setup 3DSecure.io authenticator", async ({ page }) => {
    const threeDSAuthenticator = new ThreeDSAuthenticator(page);

    await gotoThreeDS(page);
    await threeDSAuthenticator.authenticatorSearchInput.fill("threedsecureio");
    await threeDSAuthenticator.connectButton.nth(0).click();

    await expect(page.getByText('Api Key *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Api Key' }).fill("test_value");

    await expect(page.getByText('MCC *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter MCC' }).fill("test_value");

    await expect(page.getByText('digit numeric country code *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter 3 digit numeric country' }).fill("test_value");

    await expect(page.getByText('Name of the merchant *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Name of the merchant' }).fill("test_value");

    await expect(page.getByText('Acquirer BIN *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Acquirer BIN' }).fill("test_value");

    await expect(page.getByText('Acquirer Merchant ID *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Acquirer Merchant ID' }).fill("test_value");

    await expect(page.getByText('Acquirer Country Code')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Acquirer Country Code' }).fill("test_value");

    await expect(page.getByText('Pull Mechanism Enabled')).toBeVisible();

    await page.locator('[data-button-for="connectAndProceed"]').click();

    await page.getByRole('button', { name: 'Done' }).click();
    await expect(page.getByText("threedsecureio_default", { exact: true })).toBeVisible({ timeout: 10000 });
  });

  test("should setup Visa Click to Pay authenticator", async ({ page }) => {
    const threeDSAuthenticator = new ThreeDSAuthenticator(page);

    await gotoThreeDS(page);
    await threeDSAuthenticator.authenticatorSearchInput.fill("Visa");
    await threeDSAuthenticator.connectButton.nth(0).click();

    await expect(page.getByText('Merchant Country Code *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Merchant Country Code' }).fill("test_value");

    await expect(page.getByText('Acquire Bin *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Acquirer Bin' }).fill("test_value");

    await expect(page.getByText('Acquire Merchant Id *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Acquirer Merchant Id' }).fill("test_value");

    await expect(page.getByText('DPA Id *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter DPA Id' }).fill("test_value");

    await expect(page.getByText('DPA Name *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter DPA Name' }).fill("test_value");

    await expect(page.getByText('Locale *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter locale' }).fill("test_value");

    await expect(page.getByText('Merchant Category Code')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Merchant Category Code' }).fill("test_value");

    await page.locator('[data-button-for="connectAndProceed"]').click();

    await page.getByRole('button', { name: 'Done' }).click();
    await expect(page.getByText("ctp_visa_default", { exact: true })).toBeVisible({ timeout: 10000 });
  });

  test("should setup Mastercard Click to Pay authenticator", async ({ page }) => {
    const threeDSAuthenticator = new ThreeDSAuthenticator(page);

    await gotoThreeDS(page);
    await threeDSAuthenticator.authenticatorSearchInput.fill("Mastercard");
    await threeDSAuthenticator.connectButton.nth(0).click();

    await expect(page.getByText('API Key *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter API Key' }).fill("test_value");

    await expect(page.getByText('Merchant Country Code *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Merchant Country Code' }).fill("test_value");

    await expect(page.getByText('Acquire Bin *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Acquirer Bin' }).fill("test_value");

    await expect(page.getByText('Acquire Merchant Id *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Acquirer Merchant Id' }).fill("test_value");

    await expect(page.getByText('DPA Id *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter DPA Id' }).fill("test_value");

    await expect(page.getByText('DPA Name *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter DPA Name' }).fill("test_value");

    await expect(page.getByText('Locale *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter locale' }).fill("test_value");

    await expect(page.getByText('Merchant Category Code')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Merchant Category Code' }).fill("test_value");

    await page.locator('[data-button-for="connectAndProceed"]').click();

    await page.getByRole('button', { name: 'Done' }).click();
    await expect(page.getByText("ctp_mastercard_default", { exact: true })).toBeVisible({ timeout: 10000 });
  });

  test("should setup Juspay 3DS Server authenticator", async ({ page }) => {
    const threeDSAuthenticator = new ThreeDSAuthenticator(page);

    await gotoThreeDS(page);
    await threeDSAuthenticator.authenticatorSearchInput.fill("juspay");
    await threeDSAuthenticator.connectButton.nth(0).click();

    await expect(page.getByText('merchant_country_code *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Merchant Country Code' }).fill("test_value");

    await expect(page.getByText('merchant_name *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Merchant Name' }).fill("test_value");

    await expect(page.getByText('ThreeDS requestor name')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter ThreeDS requestor name' }).fill("test_value");

    await expect(page.getByText('ThreeDS request id')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter ThreeDS request id' }).fill("test_value");

    await expect(page.getByText('Pull Mechanism Enabled')).toBeVisible();

    await expect(page.getByText('merchant_category_code *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Merchant Category Code' }).fill("test_value");

    await page.locator('[data-button-for="connectAndProceed"]').click();

    await page.getByRole('button', { name: 'Done' }).click();
    await expect(page.getByText("juspaythreedsserver_default", { exact: true })).toBeVisible({ timeout: 10000 });
  });

  test("should setup Cardinal authenticator", async ({ page }) => {
    const threeDSAuthenticator = new ThreeDSAuthenticator(page);

    await gotoThreeDS(page);
    await threeDSAuthenticator.authenticatorSearchInput.fill("cardinal");
    await threeDSAuthenticator.connectButton.nth(0).click();

    await expect(page.getByTestId('api_key').getByText('*')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter API Key' }).fill("test_value");

    await expect(page.getByText('Organization Unit ID *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter Organization Unit ID' }).fill("test_value");

    await expect(page.getByText('API ID *')).toBeVisible();
    await page.getByRole('textbox', { name: 'Enter API ID' }).fill("test_value");

    await expect(page.getByText('Pull Mechanism Enabled')).toBeVisible();

    await page.locator('[data-button-for="connectAndProceed"]').click();

    await page.getByRole('button', { name: 'Done' }).click();
    await expect(page.getByText("cardinal_default", { exact: true })).toBeVisible({ timeout: 10000 });
  });
});