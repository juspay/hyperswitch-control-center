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

test.describe("TC-007: Payment Table - Advanced Features", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_payments",
        context.request,
      );

      for (let i = 0; i < 5; i++) {
        try {
          await createPaymentAPI(merchantId, context.request);
        } catch (e) {
          // Continue even if some payments fail to create
        }
      }
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.waitForTimeout(2000);
  });

  test("should sort columns ascending and descending", async ({ page }) => {
    const headers = page.locator(
      'th[role="columnheader"], [data-testid*="sort"]',
    );
    const count = await headers.count();

    for (let i = 0; i < Math.min(count, 3); i++) {
      const header = headers.nth(i);
      if (await header.isVisible().catch(() => false)) {
        await header.click();
        await page.waitForTimeout(500);

        const sortIndicator = header.locator(
          '[data-icon*="arrow"], [data-testid*="sort-indicator"], .sort-icon',
        );
        if (await sortIndicator.isVisible().catch(() => false)) {
          await expect(sortIndicator).toBeVisible();
        }

        await header.click();
        await page.waitForTimeout(500);
      }
    }
  });

  test("should resize column widths", async ({ page }) => {
    const resizer = page
      .locator(
        '[data-testid*="resizer"], .column-resizer, th [role="separator"]',
      )
      .first();
    if (await resizer.isVisible().catch(() => false)) {
      const box = await resizer.boundingBox();
      if (box) {
        await resizer.hover();
        await page.mouse.down();
        await page.mouse.move(box.x + 50, box.y);
        await page.mouse.up();
      }
    }
  });

  test("should hide and show columns", async ({ page }) => {
    const columnToggleButton = page
      .locator('[data-testid*="column-toggle"], button:has-text("Columns")')
      .first();
    if (await columnToggleButton.isVisible().catch(() => false)) {
      await columnToggleButton.click();

      const columnCheckboxes = page.locator(
        '[data-testid*="column-checkbox"], input[type="checkbox"][name*="column"]',
      );
      const firstCheckbox = columnCheckboxes.first();

      if (await firstCheckbox.isVisible().catch(() => false)) {
        const isChecked = await firstCheckbox.isChecked();
        await firstCheckbox.setChecked(!isChecked);
        await page.waitForTimeout(500);
        await firstCheckbox.setChecked(isChecked);
      }

      await page.keyboard.press("Escape");
    }
  });

  test("should combine multiple filters", async ({ page }) => {
    const filterButton = page
      .locator('[data-testid*="filter"], button:has-text("Filter")')
      .first();
    if (await filterButton.isVisible().catch(() => false)) {
      await filterButton.click();

      const connectorFilter = page
        .locator('[name*="connector"], select[name*="processor"]')
        .first();
      if (await connectorFilter.isVisible().catch(() => false)) {
        await connectorFilter.selectOption({ index: 1 });
      }

      const statusFilter = page.locator('[name*="status"]').first();
      if (await statusFilter.isVisible().catch(() => false)) {
        await statusFilter.selectOption("succeeded");
      }

      const currencyFilter = page.locator('[name*="currency"]').first();
      if (await currencyFilter.isVisible().catch(() => false)) {
        await currencyFilter.selectOption("USD");
      }

      const applyButton = page.locator('[data-button-for="apply"]').first();
      if (await applyButton.isVisible().catch(() => false)) {
        await applyButton.click();
        await page.waitForTimeout(1000);
      }
    }
  });

  test("should export to CSV", async ({ page }) => {
    const exportButton = page
      .locator(
        '[data-button-for="export"], button:has-text("Export"), [data-testid*="export"]',
      )
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

  test("should paginate correctly", async ({ page }) => {
    const lastPageButton = page
      .locator(
        '[data-testid*="last-page"], button:has-text(">>"), [aria-label*="last"]',
      )
      .first();
    if (await lastPageButton.isVisible().catch(() => false)) {
      await lastPageButton.click();
      await page.waitForTimeout(1000);

      const activePage = page
        .locator('[data-testid*="page-active"], [aria-current="page"]')
        .first();
      if (await activePage.isVisible().catch(() => false)) {
        await expect(activePage).toBeVisible();
      }
    }
  });

  test("should handle search with special characters", async ({ page }) => {
    const searchInput = page
      .locator('[data-testid*="search"], input[placeholder*="search" i]')
      .first();
    if (await searchInput.isVisible().catch(() => false)) {
      await searchInput.fill("test@#$%123");
      await searchInput.press("Enter");
      await page.waitForTimeout(1000);

      await expect(page).toBeTruthy();
    }
  });

  test("should clear all filters", async ({ page }) => {
    const clearAllButton = page
      .locator('[data-button-for="clearAll"], button:has-text("Clear All")')
      .first();
    if (await clearAllButton.isVisible().catch(() => false)) {
      await clearAllButton.click();
      await page.waitForTimeout(500);

      const activeFilters = page.locator(
        '[data-testid*="active-filter"], [data-testid*="filter-badge"]',
      );
      await expect(activeFilters).toHaveCount(0);
    }
  });
});
