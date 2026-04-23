/**
 * Auto-generated Playwright test
 * Source: module:disputes-empty - detailed empty-state coverage
 * Generated: 2026-04-17
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentOperations } from "../support/pages/operations/PaymentOperations";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Disputes - Empty state coverage", () => {
  // Fixed (Attempt 1): switched from page.goto to sidebar nav — direct URL
  // right after loginUI races the post-signin flow and lands on a 2FA screen.
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    const homePage = new HomePage(page);
    await homePage.operations.click();
    await homePage.disputesOperations.click();
    await page.waitForURL(/dashboard\/disputes/, { timeout: 15000 });
    await page.waitForLoadState("networkidle");
  });

  test("shows Disputes heading and subtitle", async ({ page }) => {
    await expect(page.getByText("Disputes").first()).toBeVisible({
      timeout: 10000,
    });
    await expect(page.getByText(/View and manage all disputes/i)).toBeVisible({
      timeout: 10000,
    });
  });

  test("shows search with exact placeholder 'Search for dispute ID'", async ({
    page,
  }) => {
    const search = page.locator('input[placeholder="Search for dispute ID"]');
    await expect(search).toBeVisible({ timeout: 10000 });
  });

  test("shows 'No results found' when there are no disputes", async ({
    page,
  }) => {
    await expect(page.getByText("No results found")).toBeVisible({
      timeout: 10000,
    });
  });

  test("date-range selector is visible", async ({ page }) => {
    await expect(
      page.locator('[data-testid="date-range-selector"]'),
    ).toBeVisible({ timeout: 10000 });
  });

  test("add filters button is visible", async ({ page }) => {
    const paymentOperations = new PaymentOperations(page);
    await expect(paymentOperations.addFilters).toBeVisible({
      timeout: 10000,
    });
  });

  test("filter dropdown opens and shows options", async ({ page }) => {
    const paymentOperations = new PaymentOperations(page);
    await paymentOperations.addFilters.click();

    await expect(
      page.locator('[class="px-1 py-1 overflow-y-auto max-h-96"]'),
    ).toBeVisible({ timeout: 10000 });
  });

  test("transaction view grid renders tabs", async ({ page }) => {
    // Fixed (Attempt 1): disputes use a 4-col grid (not 5-col like payments);
    // assert via partial class match instead of full chain.
    const grid = page.locator('[class*="grid-cols-4"]').first();
    await expect(grid).toBeVisible({ timeout: 10000 });
  });

  test("expand-search-90-days CTA is present in empty state", async ({
    page,
  }) => {
    const cta = page.locator(
      '[data-button-for="expandTheSearchToThePrevious90Days"]',
    );
    await expect(cta).toBeVisible({ timeout: 10000 });
  });

  test("search with non-matching id yields No results", async ({ page }) => {
    const search = page.locator('input[placeholder="Search for dispute ID"]');
    await search.fill("dp_nonexistent_zzz");
    await search.press("Enter");
    await expect(page.getByText("No results found")).toBeVisible({
      timeout: 10000,
    });
  });

  test("URL remains /dashboard/disputes after interaction", async ({
    page,
  }) => {
    const paymentOperations = new PaymentOperations(page);
    await paymentOperations.addFilters.click();
    await page.keyboard.press("Escape");
    await expect(page).toHaveURL(/.*dashboard\/disputes/);
  });
});
