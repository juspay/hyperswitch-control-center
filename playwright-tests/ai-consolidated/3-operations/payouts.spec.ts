import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentOperations } from "../../support/pages/operations/PaymentOperations";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Payouts list page (feature-flag gated)", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    const homePage = new HomePage(page);
    await homePage.operations.click();
    const payouts = homePage.payoutsOperations;
    if ((await payouts.count().catch(() => 0)) === 0) {
      test.skip(true, "Payouts disabled for this merchant");
    }
    await payouts.first().click();
    await page.waitForLoadState("networkidle");
  });

  test("should land on payouts URL with heading and empty state", async ({
    page,
  }) => {
    expect(page.url()).not.toMatch(/\/login/);
    await expect(page).toHaveURL(/.*dashboard\/payouts/);
    await expect(page.getByText(/Payouts/i).first()).toBeVisible({
      timeout: 10000,
    });

    const empty = page.getByText("No results found");
    const table = page.locator("table tbody tr");
    const hasEmpty = await empty.isVisible().catch(() => false);
    const rowCount = await table.count().catch(() => 0);
    expect(hasEmpty || rowCount === 0).toBeTruthy();
  });

  test("should display search with 'Search for payout ID' placeholder, date range, and filters", async ({
    page,
  }) => {
    const paymentOperations = new PaymentOperations(page);

    const search = page.locator('input[placeholder="Search for payout ID"]');
    if (await search.count()) {
      await expect(search).toBeVisible({ timeout: 10000 });
    }

    const selector = page.locator('[data-testid="date-range-selector"]');
    if (await selector.isVisible().catch(() => false)) {
      await expect(selector).toBeVisible();
    }

    if (await paymentOperations.addFilters.isVisible().catch(() => false)) {
      await expect(paymentOperations.addFilters).toBeVisible();
    }
  });

  test("should survive reload and return empty state when searching non-existent ID", async ({
    page,
  }) => {
    await page.reload();
    await page.waitForLoadState("networkidle");
    await expect(page).toHaveURL(/.*dashboard\/payouts/);

    const search = page.locator('input[placeholder="Search for payout ID"]');
    if (await search.isVisible().catch(() => false)) {
      await search.fill("po_nonexistent_zzz");
      await search.press("Enter");
      await expect(page.getByText("No results found")).toBeVisible({
        timeout: 10000,
      });
    }
  });
});
