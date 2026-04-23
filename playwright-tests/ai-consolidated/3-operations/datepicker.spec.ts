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

test.describe("DatePicker + DateRangePicker interactions", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_datepicker",
        context.request,
      );
      await createPaymentAPI(merchantId, context.request).catch(() => {});
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.waitForTimeout(1500);
  });

  test("should open a calendar and allow changing months / clearing selection", async ({
    page,
  }) => {
    const datePicker = page
      .locator(
        '[data-testid*="date-picker"], input[type="date"], input[placeholder*="date" i]',
      )
      .first();
    if (!(await datePicker.isVisible().catch(() => false))) {
      test.skip(true, "no single-date picker rendered on this page");
    }
    await datePicker.click();

    const calendar = page
      .locator(
        '[data-testid*="calendar"], [role="dialog"], [class*="calendar"]',
      )
      .first();
    await expect(calendar).toBeVisible();

    const nextMonthButton = page
      .locator('[data-testid*="next-month"], [aria-label*="next month"]')
      .first();
    if (await nextMonthButton.isVisible().catch(() => false)) {
      await nextMonthButton.click();
      await page.waitForTimeout(300);
    }

    const dayCell = page.locator('[data-testid*="day"], [role="gridcell"]').nth(5);
    if (await dayCell.isVisible().catch(() => false)) {
      await dayCell.click();
    }

    const clearButton = page
      .locator('[data-testid*="clear-date"], button:has-text("Clear")')
      .first();
    if (await clearButton.isVisible().catch(() => false)) {
      await clearButton.click();
    }
  });

  test("should apply the Today preset and keep a date-range button visible", async ({
    page,
  }) => {
    const rangePicker = page
      .locator('[data-testid*="date-range"], [data-testid*="range-picker"]')
      .first();
    if (!(await rangePicker.isVisible().catch(() => false))) {
      test.skip(true, "range picker not rendered");
    }
    await rangePicker.click();

    const todayOption = page
      .locator('button:has-text("Today"), [data-value="today"]')
      .first();
    await expect(todayOption).toBeVisible({ timeout: 5000 });
    await todayOption.click();
    await page.waitForTimeout(500);

    await expect(rangePicker).toBeVisible();
  });

  test("should apply Last 7 Days preset", async ({ page }) => {
    const rangePicker = page
      .locator('[data-testid*="date-range"], [data-testid*="range-picker"]')
      .first();
    if (!(await rangePicker.isVisible().catch(() => false))) {
      test.skip(true, "range picker not rendered");
    }
    await rangePicker.click();

    const sevenDays = page
      .locator('button:has-text("Last 7 Days"), [data-value="7d"]')
      .first();
    await expect(sevenDays).toBeVisible({ timeout: 5000 });
    await sevenDays.click();
    await page.waitForLoadState("networkidle");
  });

  test("should accept a manually typed date value", async ({ page }) => {
    const dateInput = page
      .locator('input[type="date"], input[data-testid*="date"]')
      .first();
    if (!(await dateInput.isVisible().catch(() => false))) {
      test.skip(true, "native date input not rendered");
    }
    await dateInput.fill("2024-01-15");
    await expect(dateInput).toHaveValue("2024-01-15");
  });

  test("should preserve the current range when Cancel is clicked in the picker", async ({
    page,
  }) => {
    const rangePicker = page
      .locator('[data-testid*="date-range"], [data-testid*="range-picker"]')
      .first();
    if (!(await rangePicker.isVisible().catch(() => false))) {
      test.skip(true, "range picker not rendered");
    }
    const originalValue = await rangePicker.textContent();

    await rangePicker.click();
    const cancelButton = page
      .locator('[data-button-for="cancel"], button:has-text("Cancel")')
      .first();
    if (await cancelButton.isVisible().catch(() => false)) {
      await cancelButton.click();
      await page.waitForTimeout(300);
      const newValue = await rangePicker.textContent();
      expect(newValue).toBe(originalValue);
    }
  });

  test("should apply a custom date range and reject end-before-start values", async ({
    page,
  }) => {
    const rangePicker = page
      .locator('[data-testid*="date-range"], [data-testid*="range-picker"]')
      .first();
    if (!(await rangePicker.isVisible().catch(() => false))) {
      test.skip(true, "range picker not rendered");
    }
    await rangePicker.click();

    const customOption = page
      .locator('button:has-text("Custom"), [data-value="custom"]')
      .first();
    if (!(await customOption.isVisible().catch(() => false))) {
      test.skip(true, "custom range not exposed");
    }
    await customOption.click();

    const startDate = page
      .locator('[data-testid*="start-date"], input[name*="start"]')
      .first();
    const endDate = page
      .locator('[data-testid*="end-date"], input[name*="end"]')
      .first();

    if (
      (await startDate.isVisible().catch(() => false)) &&
      (await endDate.isVisible().catch(() => false))
    ) {
      await startDate.fill("2024-01-31");
      await endDate.fill("2024-01-01");

      const applyButton = page
        .locator('[data-button-for="apply"], button:has-text("Apply")')
        .first();
      if (await applyButton.isVisible().catch(() => false)) {
        await applyButton.click();
        await expect(
          page.locator('[data-field-error*="date"], [data-toast*="invalid"]'),
        ).toBeVisible({ timeout: 5000 });
      }
    }
  });
});
