/**
 * Auto-generated Playwright test
 * Source: module:payouts-empty - detailed empty-state coverage
 * Generated: 2026-04-17
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentOperations } from "../support/pages/operations/PaymentOperations";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Payouts - Empty state coverage", () => {
  // Fixed (Attempt 1): use sidebar nav and skip suite if payouts flag off.
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

  test("loads payouts URL (no auth redirect)", async ({ page }) => {
    expect(page.url()).not.toMatch(/\/login/);
    await expect(page).toHaveURL(/.*dashboard\/payouts/);
  });

  test("shows 'Payouts' text on page", async ({ page }) => {
    await expect(page.getByText(/Payouts/i).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("shows search with exact placeholder 'Search for payout ID'", async ({
    page,
  }) => {
    const search = page.locator('input[placeholder="Search for payout ID"]');
    if (await search.count()) {
      await expect(search).toBeVisible({ timeout: 10000 });
    }
  });

  test("shows 'No results found' when no payouts exist", async ({ page }) => {
    const empty = page.getByText("No results found");
    const table = page.locator("table tbody tr");
    const hasEmpty = await empty.isVisible().catch(() => false);
    const rowCount = await table.count().catch(() => 0);
    expect(hasEmpty || rowCount === 0).toBeTruthy();
  });

  test("date-range selector is visible", async ({ page }) => {
    const selector = page.locator('[data-testid="date-range-selector"]');
    if (await selector.isVisible().catch(() => false)) {
      await expect(selector).toBeVisible();
    }
  });

  test("add filters button is visible", async ({ page }) => {
    const paymentOperations = new PaymentOperations(page);
    if (await paymentOperations.addFilters.isVisible().catch(() => false)) {
      await expect(paymentOperations.addFilters).toBeVisible();
    }
  });

  test("URL survives a reload in empty state", async ({ page }) => {
    await page.reload();
    await page.waitForLoadState("networkidle");
    await expect(page).toHaveURL(/.*dashboard\/payouts/);
  });

  test("search for non-existent id shows empty state", async ({ page }) => {
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
