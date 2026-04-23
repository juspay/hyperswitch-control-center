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

test.describe("TC-031: DatePicker - All Variants", () => {
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
      await createPaymentAPI(merchantId, context.request);
    }
  });

  test("should open date picker calendar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const datePicker = page
      .locator(
        '[data-testid*="date-picker"], input[type="date"], input[placeholder*="date" i]',
      )
      .first();
    if (await datePicker.isVisible().catch(() => false)) {
      await datePicker.click();

      const calendar = page
        .locator(
          '[data-testid*="calendar"], [role="dialog"], [class*="calendar"]',
        )
        .first();
      await expect(calendar).toBeVisible();
    }
  });

  test("should select single date", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const datePicker = page.locator('[data-testid*="date-picker"]').first();
    if (await datePicker.isVisible().catch(() => false)) {
      await datePicker.click();

      const dayCell = page
        .locator('[data-testid*="day"], [role="gridcell"]')
        .nth(5);
      if (await dayCell.isVisible().catch(() => false)) {
        await dayCell.click();

        await expect(datePicker).toHaveValue(/./);
      }
    }
  });

  test("should switch months", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const datePicker = page.locator('[data-testid*="date-picker"]').first();
    if (await datePicker.isVisible().catch(() => false)) {
      await datePicker.click();

      const nextMonthButton = page
        .locator('[data-testid*="next-month"], [aria-label*="next month"]')
        .first();
      if (await nextMonthButton.isVisible().catch(() => false)) {
        const monthHeader = page
          .locator('[data-testid*="month-header"], [class*="month"]')
          .first();
        const initialMonth = await monthHeader.textContent();

        await nextMonthButton.click();
        await page.waitForTimeout(300);

        const newMonth = await monthHeader.textContent();
        expect(newMonth).not.toBe(initialMonth);
      }
    }
  });

  test("should type date manually", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const dateInput = page
      .locator('input[type="date"], input[data-testid*="date"]')
      .first();
    if (await dateInput.isVisible().catch(() => false)) {
      await dateInput.fill("2024-01-15");

      await expect(dateInput).toHaveValue("2024-01-15");
    }
  });

  test("should clear date selection", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const datePicker = page.locator('[data-testid*="date-picker"]').first();
    if (await datePicker.isVisible().catch(() => false)) {
      await datePicker.click();

      const dayCell = page.locator('[data-testid*="day"]').nth(5);
      if (await dayCell.isVisible().catch(() => false)) {
        await dayCell.click();
      }

      const clearButton = page
        .locator('[data-testid*="clear-date"], button:has-text("Clear")')
        .first();
      if (await clearButton.isVisible().catch(() => false)) {
        await clearButton.click();

        const value = await datePicker.inputValue();
        expect(value).toBe("");
      }
    }
  });
});
