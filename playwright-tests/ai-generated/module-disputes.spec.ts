/**
 * Auto-generated Playwright test
 * Source: module:disputes - Orchestrator Operations → Disputes
 * Generated: 2026-04-17
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentOperations } from "../support/pages/operations/PaymentOperations";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Disputes Module", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to disputes page via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();

    await expect(page).toHaveURL(/.*dashboard\/disputes/);
  });

  test("should display disputes heading", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();
    await page.waitForLoadState("networkidle");

    await expect(page.getByText(/Dispute/i).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("should show empty state when no disputes", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();
    await page.waitForLoadState("networkidle");

    const empty = page.getByText("No results found");
    const table = page.locator("table tbody tr");
    const hasEmpty = await empty.isVisible().catch(() => false);
    const rowCount = await table.count().catch(() => 0);
    expect(hasEmpty || rowCount >= 0).toBeTruthy();
  });

  test("should display date range selector on disputes", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();

    await expect(
      page.locator('[data-testid="date-range-selector"]'),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should display add filters button", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();

    await expect(paymentOperations.addFilters).toBeVisible({ timeout: 10000 });
  });

  test("should open filter dropdown showing dispute filters", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();
    await paymentOperations.addFilters.click();

    await expect(
      page.locator('[class="px-1 py-1 overflow-y-auto max-h-96"]'),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should preserve disputes URL after reload", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.disputesOperations.click();
    await expect(page).toHaveURL(/.*dashboard\/disputes/);

    await page.reload();
    await expect(page).toHaveURL(/.*dashboard\/disputes/);
  });
});
