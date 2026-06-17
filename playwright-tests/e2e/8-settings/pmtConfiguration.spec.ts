import { test, expect } from "../../support/test";
import type { Page, APIRequestContext } from "@playwright/test";
import { ConfigurePMTPage } from "../../support/pages/settings/ConfigurePMTPage";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createMerchantAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function loginAndVisit(
  page: Page,
  flagEnabled = true,
): Promise<ConfigurePMTPage> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

  const configurePMT = new ConfigurePMTPage(page);
  await configurePMT.visit();
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(1000);
  return configurePMT;
}

// Seeds a fresh org with a card/credit connector via the API so the page
// renders a populated payment-methods table, then opens Configure PMTs.
async function loginWithConnectorAndVisit(
  page: Page,
  apiContext: APIRequestContext,
): Promise<ConfigurePMTPage> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

  // The merchant ID is only known after login; wait for the sidebar element
  // to render before reading it, then seed the connector against it via the
  // API so the page renders a populated payment-methods table.
  const homePage = new HomePage(page);
  await homePage.merchantID
    .nth(0)
    .waitFor({ state: "visible", timeout: 20000 });
  const merchantId = (await homePage.merchantID.nth(0).textContent())?.trim();
  if (!merchantId) {
    throw new Error("Could not read merchant ID after login");
  }
  await createDummyConnectorAPI(merchantId, "stripe_test_pmt", apiContext);

  const configurePMTPage = new ConfigurePMTPage(page);
  await configurePMTPage.visit();
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(1000);
  await configurePMTPage.waitForConnectorRow("stripe_test");
  return configurePMTPage;
}


test.describe("Configure PMTs - Page & Layout", () => {
  let configurePMT: ConfigurePMTPage;

  test("should load the page with heading and subtitle", async ({ page }) => {
    configurePMT = await loginAndVisit(page);
    await expect(configurePMT.pageHeading).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.pageSubtitle).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.addFiltersButton).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.noDataMessage).toBeVisible({ timeout: 10000 });
  });

  test("should verify filter options", async ({ page, context }) => {
    configurePMT = await loginWithConnectorAndVisit(page, context.request);
    await expect(configurePMT.addFiltersButton).toBeVisible({ timeout: 10000 });
    await configurePMT.openFilters();
    await expect(page.locator('div').filter({ hasText: /^ProfileIdConnectorIdPaymentMethodPaymentMethodType$/ }).nth(1)).toBeVisible();
  });

  test("should verify profile filter", async ({ page, context }) => {
    configurePMT = await loginWithConnectorAndVisit(page, context.request);
    await expect(configurePMT.addFiltersButton).toBeVisible({ timeout: 10000 });
    await configurePMT.openFilters();
    await page.getByText('ProfileId').click();
    await page.locator('div').filter({ hasText: /^Select Profile$/ }).nth(3).click();
    await expect(page.getByRole('button', { name: "Apply" })).toBeDisabled();
    await page.locator('div').filter({ hasText: /^default/ }).nth(3).click();
    await page.getByRole('button', { name: "Apply" }).click();
    await expect(page.getByRole('button', { name: "Apply" })).not.toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^default \(/ }).nth(3)).toBeVisible();
    await expect(page.getByRole('button', { name: 'Clear All' })).toBeVisible();
  });

  test("should verify ConnectorId filter", async ({ page, context }) => {
    configurePMT = await loginWithConnectorAndVisit(page, context.request);
    await expect(configurePMT.addFiltersButton).toBeVisible({ timeout: 10000 });
    await configurePMT.openFilters();
    await page.getByText('ConnectorId').click();
    await page.locator('div').filter({ hasText: /^Select Connector$/ }).nth(3).click();
    await expect(page.getByRole('button', { name: "Apply" })).toBeDisabled();
    await page.locator('div').filter({ hasText: /^stripe_test$/ }).nth(3).click();
    await page.getByRole('button', { name: "Apply" }).click();
    await expect(page.getByRole('button', { name: "Apply" })).not.toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^stripe_test$/ }).nth(3)).toBeVisible();
    await expect(page.getByRole('button', { name: 'Clear All' })).toBeVisible();
  });

  test("should verify PaymentMethod filter", async ({ page, context }) => {
    configurePMT = await loginWithConnectorAndVisit(page, context.request);
    await expect(configurePMT.addFiltersButton).toBeVisible({ timeout: 10000 });
    await configurePMT.openFilters();
    await page.locator('div').filter({ hasText: /^PaymentMethod$/ }).first().click();
    await page.locator('div').filter({ hasText: /^Select Payment Method$/ }).nth(3).click();
    await expect(page.getByRole('button', { name: "Apply" })).toBeDisabled();
    await page.locator('div').filter({ hasText: /^card$/ }).nth(3).click();
    await page.getByRole('button', { name: "Apply" }).click();
    await expect(page.getByRole('button', { name: "Apply" })).not.toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^card$/ }).nth(3)).toBeVisible();
    await expect(page.getByRole('button', { name: 'Clear All' })).toBeVisible();
  });

  test("should verify PaymentMethodType filter", async ({ page, context }) => {
    configurePMT = await loginWithConnectorAndVisit(page, context.request);
    await expect(configurePMT.addFiltersButton).toBeVisible({ timeout: 10000 });
    await configurePMT.openFilters();
    await page.getByText('PaymentMethodType').click();
    await page.locator('div').filter({ hasText: /^Select Payment Method Type$/ }).nth(3).click();
    await expect(page.getByRole('button', { name: "Apply" })).toBeDisabled();
    await page.locator('div').filter({ hasText: /^debit$/ }).nth(1).click();
    await page.getByRole('button', { name: "Apply" }).click();
    await expect(page.getByRole('button', { name: "Apply" })).not.toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^debit$/ }).nth(3)).toBeVisible();
    await expect(page.getByRole('button', { name: 'Clear All' })).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^credit$/ }).nth(5)).not.toBeVisible();
  });

  test("should verify clear All button clears the filter", async ({ page, context }) => {
    configurePMT = await loginWithConnectorAndVisit(page, context.request);
    await expect(configurePMT.addFiltersButton).toBeVisible({ timeout: 10000 });
    await configurePMT.openFilters();
    await page.getByText('PaymentMethodType').click();
    await page.locator('div').filter({ hasText: /^Select Payment Method Type$/ }).nth(3).click();
    await expect(page.getByRole('button', { name: "Apply" })).toBeDisabled();
    await page.locator('div').filter({ hasText: /^debit$/ }).nth(1).click();
    await page.getByRole('button', { name: "Apply" }).click();
    await expect(page.getByRole('button', { name: "Apply" })).not.toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^debit$/ }).nth(3)).toBeVisible();
    await expect(page.getByRole('button', { name: 'Clear All' })).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^credit$/ }).nth(5)).not.toBeVisible();

    await page.getByRole('button', { name: 'Clear All' }).click();
    await expect(page.getByText('paymentMethodTypedebitClear')).not.toBeVisible();

  });

});

test.describe("Configure PMTs - Configured Connector", () => {
  let configurePMT: ConfigurePMTPage;

  test.beforeEach(async ({ page, context }) => {
    configurePMT = await loginWithConnectorAndVisit(page, context.request);
  });

  test("should render the payment methods table column headers", async () => {
    await expect(configurePMT.columnHeader("Processor")).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.columnHeader("Payment Method Type")).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.columnHeader("Payment Method")).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.columnHeader("Countries Allowed")).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.columnHeader("Currencies Allowed")).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.columnHeader("Card Network")).toBeVisible({ timeout: 10000 });
  });

  test("should list the seeded connector and its payment method type", async () => {
    await expect(configurePMT.cellByText("stripe_test")).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.cellByText("credit")).toBeVisible({ timeout: 10000 });
  });

  test("should open the Configure PMTs modal with country/currency and amount fields on row click", async () => {
    await configurePMT.cellByText("stripe_test").click();

    await expect(configurePMT.configureModalHeading).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.configureModalSubHeading).toBeVisible({ timeout: 10000 });

    await expect(configurePMT.countriesLabel).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.countriesDropdown).toBeVisible({ timeout: 10000 });

    await expect(configurePMT.currenciesLabel).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.currenciesDropdown).toBeVisible({ timeout: 10000 });

    await expect(configurePMT.minimumAmountInputHeading).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.minimumAmountInput).toBeVisible({ timeout: 10000 });

    await expect(configurePMT.maximumAmountInputHeading).toBeVisible({ timeout: 10000 });
    await expect(configurePMT.maximumAmountInput).toBeVisible({ timeout: 10000 });

    await expect(configurePMT.submitButton).toBeVisible({ timeout: 10000 });
  });

  test("should reject an empty amount on submit", async () => {
    await configurePMT.cellByText("stripe_test").click();
    await expect(configurePMT.minimumAmountInput).toBeVisible({ timeout: 10000 });

    await configurePMT.minimumAmountInput.fill("");
    await expect(configurePMT.submitButton).toBeDisabled();

    await configurePMT.minimumAmountInput.fill("50");
    await configurePMT.maximumAmountInput.fill("");
    await expect(configurePMT.submitButton).toBeDisabled();
  });

  test("should reject a maximum amount lower than the minimum amount", async () => {
    await configurePMT.cellByText("stripe_test").click();
    await expect(configurePMT.minimumAmountInput).toBeVisible({ timeout: 10000 });

    await configurePMT.minimumAmountInput.fill("500");
    await configurePMT.maximumAmountInput.fill("100");
    await expect(configurePMT.submitButton).toBeDisabled();
  });

  test("should reject a amount greater than maximum allowed value", async () => {
    await configurePMT.cellByText("stripe_test").click();
    await expect(configurePMT.minimumAmountInput).toBeVisible({ timeout: 10000 });

    await configurePMT.maximumAmountInput.fill("999999999999");
    await expect(configurePMT.submitButton).toBeDisabled();
  });

  test("should close the Configure PMTs modal on the close button", async () => {
    await configurePMT.cellByText("stripe_test").click();
    await expect(configurePMT.configureModalHeading).toBeVisible({ timeout: 10000 });

    await configurePMT.modalCloseButton.click();

    await expect(configurePMT.configureModalSubHeading).toBeHidden();
  });

  test("should close the modal and return to the list when the submit API fails", async ({ page }) => {
    await configurePMT.cellByText("stripe_test").click();
    await expect(configurePMT.configureModalHeading).toBeVisible({ timeout: 10000 });

    // Force the connector-update POST to fail so the onSubmit catch block runs.
    await page.route("**/account/*/connectors/*", async (route) => {
      if (route.request().method() === "POST") {
        await route.fulfill({
          status: 500,
          contentType: "application/json",
          body: JSON.stringify({ error: { message: "Internal Server Error" } }),
        });
        return;
      }
      await route.continue();
    });

    // Provide valid form data before submitting.
    await configurePMT.minimumAmountInput.fill("111");
    await configurePMT.maximumAmountInput.fill("9999");
    await expect(configurePMT.submitButton).toBeEnabled();

    await configurePMT.submitButton.click();

    // The catch block in onSubmit closes the modal on error, returning the
    // user to the payment-methods list.
    await expect(configurePMT.configureModalSubHeading).toBeHidden({ timeout: 10000 });
    await expect(configurePMT.cellByText("stripe_test")).toBeVisible({ timeout: 10000 });
  });

  test("should successfully update PMT configuration", async ({ page }) => {
    await configurePMT.cellByText("stripe_test").click();

    await configurePMT.countriesDropdown.click();
    await page.getByRole('textbox', { name: 'Search...' }).fill("UnitedStatesOfAmerica");
    await page.locator('[data-dropdown-value="UnitedStatesOfAmerica"]').click();
    await configurePMT.configureModalHeading.click();
    await expect(page.getByRole('textbox', { name: 'Search...' })).not.toBeVisible();

    await page.getByRole('button', { name: 'Select Value' }).click();
    await page.getByRole('textbox', { name: 'Search...' }).fill("USD");
    await page.locator('[data-dropdown-value="USD"]').click();
    await configurePMT.configureModalHeading.click();
    await expect(page.getByRole('textbox', { name: 'Search...' })).not.toBeVisible();

    await configurePMT.minimumAmountInput.fill("111");
    await configurePMT.maximumAmountInput.fill("9999");

    await configurePMT.submitButton.click();

    await configurePMT.cellByText("stripe_test").click();

    await expect(page.getByRole('button', { name: 'UnitedStatesOfAmerica' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'USD' })).toBeVisible();
    await expect(configurePMT.minimumAmountInput).toHaveValue("111");
    await expect(configurePMT.maximumAmountInput).toHaveValue("9999");
  });
});

test.describe("Configure PMTs - Feature Flag", () => {
  test("should fall back to the unauthorized view when configure_pmts is disabled", async ({
    page,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.configure_pmts = false;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

    const configurePMT = new ConfigurePMTPage(page);
    await configurePMT.visit();
    await page.waitForLoadState("networkidle");

    await expect(configurePMT.pageHeading).toBeHidden();
    await expect(configurePMT.goToHomeButton).toBeVisible({ timeout: 10000 });
  });
});
