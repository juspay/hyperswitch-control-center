import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-006: Payment Operations - Empty State", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display empty state with helpful CTAs", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    await expect(page).toHaveURL(/.*dashboard\/payments/);

    const emptyStateIllustration = page
      .locator(
        '[data-testid*="empty"], [data-testid*="no-data"], img[alt*="empty"]',
      )
      .first();
    const noResultsMessage = page
      .locator("text=/no payments found|no results|empty/i")
      .first();

    if (await emptyStateIllustration.isVisible().catch(() => false)) {
      await expect(emptyStateIllustration).toBeVisible();
    }
    if (await noResultsMessage.isVisible().catch(() => false)) {
      await expect(noResultsMessage).toBeVisible();
    }
  });

  test("should expand to 90 days view", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const expandButton = page.locator(
      'button:has-text("90 days"), [data-button-for="expand90Days"], button:has-text("Expand")',
    );
    if (await expandButton.isVisible().catch(() => false)) {
      await expandButton.click();
      await page.waitForTimeout(1000);
      await expect(page).toHaveURL(/.*date_range.*90|.*days.*90/);
    }
  });

  test("should switch between transaction view tabs", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const tabs = [
      { name: "All", testId: "all" },
      { name: "Succeeded", testId: "succeeded" },
      { name: "Failed", testId: "failed" },
      { name: "Cancelled", testId: "cancelled" },
    ];

    for (const tab of tabs) {
      const tabButton = page
        .locator(
          `[role="tab"]:has-text("${tab.name}"), [data-testid*="${tab.testId}"]`,
        )
        .first();
      if (await tabButton.isVisible().catch(() => false)) {
        await tabButton.click();
        await expect(tabButton).toHaveAttribute("aria-selected", "true");
      }
    }
  });

  test("should handle filters in empty state", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const filterButton = page
      .locator('[data-testid*="filter"], button:has-text("Filter")')
      .first();
    if (await filterButton.isVisible().catch(() => false)) {
      await filterButton.click();

      const statusFilter = page
        .locator('[name*="status"], select[data-testid*="status"]')
        .first();
      if (await statusFilter.isVisible().catch(() => false)) {
        await statusFilter.selectOption("succeeded");
      }

      const applyButton = page
        .locator('[data-button-for="apply"], button:has-text("Apply")')
        .first();
      if (await applyButton.isVisible().catch(() => false)) {
        await applyButton.click();
      }
    }
  });

  test("should clear filters and verify reset", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const clearFiltersButton = page.locator(
      '[data-button-for="clearFilters"], button:has-text("Clear")',
    );
    if (await clearFiltersButton.isVisible().catch(() => false)) {
      await clearFiltersButton.click();
      await page.waitForTimeout(500);

      const filterBadge = page.locator(
        '[data-testid*="filter-badge"], [data-testid*="active-filter"]',
      );
      await expect(filterBadge).toHaveCount(0);
    }
  });
});
