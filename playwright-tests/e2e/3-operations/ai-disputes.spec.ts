import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentOperations } from "../../support/pages/operations/PaymentOperations";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Disputes list page", () => {
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

  test("should display disputes heading, subtitle, search, and empty state", async ({
    page,
  }) => {
    await expect(page.getByText("Disputes").first()).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.getByText(/View and manage all disputes/i),
    ).toBeVisible({ timeout: 10000 });
    await expect(
      page.locator('input[placeholder="Search for dispute ID"]'),
    ).toBeVisible({ timeout: 10000 });
    await expect(page.getByText("No results found")).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.locator('[data-button-for="expandTheSearchToThePrevious90Days"]'),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should display date range selector, filter button, and 4-column transaction grid", async ({
    page,
  }) => {
    const paymentOperations = new PaymentOperations(page);

    await expect(
      page.locator('[data-testid="date-range-selector"]'),
    ).toBeVisible({ timeout: 10000 });
    await expect(paymentOperations.addFilters).toBeVisible({
      timeout: 10000,
    });

    const grid = page.locator('[class*="grid-cols-4"]').first();
    await expect(grid).toBeVisible({ timeout: 10000 });
  });

  test("should open filter dropdown and show filter options", async ({
    page,
  }) => {
    const paymentOperations = new PaymentOperations(page);

    await paymentOperations.addFilters.click();
    await expect(
      page.locator('div').filter({ hasText: /^ConnectorDispute StatusDispute Stage$/ }).nth(1),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should keep URL /dashboard/disputes after reload and search non-matching id", async ({
    page,
  }) => {
    await page.reload();
    await expect(page).toHaveURL(/.*dashboard\/disputes/);

    const search = page.locator('input[placeholder="Search for dispute ID"]');
    await search.fill("dp_nonexistent_zzz");
    await search.press("Enter");
    await expect(page.getByText("No results found")).toBeVisible({
      timeout: 10000,
    });
    await expect(page).toHaveURL(/.*dashboard\/disputes/);
  });
});
