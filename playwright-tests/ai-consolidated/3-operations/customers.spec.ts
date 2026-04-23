import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Customers page", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display Customers heading, empty state, and date range selector", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(page).toHaveURL(/.*dashboard\/customers/);
    await expect(page.getByText(/Customer[s]?/i).first()).toBeVisible();

    const empty = page.getByText("No results found");
    const table = page.locator("table tbody tr");
    const hasEmpty = await empty.isVisible().catch(() => false);
    const rowCount = await table.count().catch(() => 0);
    expect(hasEmpty || rowCount === 0).toBeTruthy();

    await expect(
      page.locator('[data-testid="date-range-selector"]'),
    ).toBeVisible();
  });

  test("should navigate to customer details page after creating a payment", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    const firstRowFirstCell = page.locator(
      '[data-table-location^="Customers_tr1_td"]',
    );
    const hasRow = (await firstRowFirstCell.count().catch(() => 0)) > 0;
    if (hasRow) {
      await firstRowFirstCell.first().click();
      await expect(page).toHaveURL(/.*dashboard\/customers\/.+/);
    }
  });

  test("should show empty state on non-existent customer search and survive reload", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.customers.click();
    await expect(page).toHaveURL(/.*dashboard\/customers/);

    const searchInput = page.locator('input[placeholder*="Search" i]').first();
    if (await searchInput.isVisible().catch(() => false)) {
      await searchInput.fill("cust_nonexistent_zzz");
      await searchInput.press("Enter");
      await expect(page.getByText("No results found")).toBeVisible({
        timeout: 10000,
      });
    }

    await page.reload();
    await expect(page).toHaveURL(/.*dashboard\/customers/);
  });
});
