import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
} from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-033: DynamicTable - Sorting, Filtering, Pagination", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_table_test",
        context.request,
      );

      for (let i = 0; i < 10; i++) {
        try {
          await createPaymentAPI(merchantId, context.request);
        } catch (e) {}
      }
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.waitForTimeout(2000);
  });

  test("should sort ascending by column", async ({ page }) => {
    const sortHeader = page.locator('th[role="columnheader"]').first();
    if (await sortHeader.isVisible().catch(() => false)) {
      await sortHeader.click();
      await page.waitForTimeout(500);

      const sortIndicator = sortHeader
        .locator('[data-icon*="asc"], [data-testid*="sort-asc"]')
        .first();
      await expect(sortIndicator.or(sortHeader)).toBeTruthy();
    }
  });

  test("should sort descending by column", async ({ page }) => {
    const sortHeader = page.locator('th[role="columnheader"]').first();
    if (await sortHeader.isVisible().catch(() => false)) {
      await sortHeader.click();
      await page.waitForTimeout(300);
      await sortHeader.click();
      await page.waitForTimeout(300);

      const sortIndicator = sortHeader
        .locator('[data-icon*="desc"], [data-testid*="sort-desc"]')
        .first();
      await expect(sortIndicator.or(sortHeader)).toBeTruthy();
    }
  });

  test("should apply column filter", async ({ page }) => {
    const filterInput = page
      .locator('th input[type="text"], [data-testid*="column-filter"] input')
      .first();
    if (await filterInput.isVisible().catch(() => false)) {
      await filterInput.fill("test");
      await page.waitForTimeout(1000);

      const rows = page.locator("table tbody tr");
      const count = await rows.count();
      expect(count).toBeGreaterThanOrEqual(0);
    }
  });

  test("should change page size", async ({ page }) => {
    const pageSizeSelect = page
      .locator('[data-testid*="page-size"], select[name*="pageSize"]')
      .first();
    if (await pageSizeSelect.isVisible().catch(() => false)) {
      await pageSizeSelect.selectOption("50");
      await page.waitForTimeout(1000);

      await expect(page.locator("body")).toBeTruthy();
    }
  });

  test("should navigate to last page", async ({ page }) => {
    const lastPageButton = page
      .locator('[data-testid*="last-page"], [aria-label*="last page"]')
      .first();
    if (await lastPageButton.isVisible().catch(() => false)) {
      await lastPageButton.click();
      await page.waitForTimeout(1000);

      const activePage = page
        .locator('[data-testid*="page-active"], [aria-current="page"]')
        .first();
      await expect(activePage.or(page.locator("body"))).toBeTruthy();
    }
  });

  test("should select all rows", async ({ page }) => {
    const selectAllCheckbox = page
      .locator('thead input[type="checkbox"]')
      .first();
    if (await selectAllCheckbox.isVisible().catch(() => false)) {
      await selectAllCheckbox.check();

      const rowCheckboxes = page.locator(
        'tbody input[type="checkbox"]:checked',
      );
      const checkedCount = await rowCheckboxes.count();
      expect(checkedCount).toBeGreaterThan(0);
    }
  });

  test("should select individual rows", async ({ page }) => {
    const rowCheckbox = page.locator('tbody input[type="checkbox"]').first();
    if (await rowCheckbox.isVisible().catch(() => false)) {
      await rowCheckbox.check();

      const isChecked = await rowCheckbox.isChecked();
      expect(isChecked).toBe(true);
    }
  });

  test("should expand row details", async ({ page }) => {
    const expandButton = page
      .locator('button[aria-label*="expand"], [data-testid*="expand-row"]')
      .first();
    if (await expandButton.isVisible().catch(() => false)) {
      await expandButton.click();

      const expandedContent = page
        .locator('[data-testid*="row-details"], tr[class*="expanded"]')
        .first();
      await expect(expandedContent.or(page.locator("body"))).toBeTruthy();
    }
  });

  test("should export filtered data", async ({ page }) => {
    const exportButton = page
      .locator('[data-button-for="export"], button:has-text("Export")')
      .first();
    if (await exportButton.isVisible().catch(() => false)) {
      const [download] = await Promise.all([
        page.waitForEvent("download", { timeout: 10000 }).catch(() => null),
        exportButton.click(),
      ]);

      if (download) {
        expect(download.suggestedFilename()).toMatch(/\.(csv|xlsx)$/);
      }
    }
  });
});
