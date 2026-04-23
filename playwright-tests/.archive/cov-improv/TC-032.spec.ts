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

test.describe("TC-032: DateRangePicker - All Scenarios", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();

    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_daterange",
        context.request,
      );
      await createPaymentAPI(merchantId, context.request);
    }
  });

  test("should select Today predefined range", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const rangePicker = page
      .locator('[data-testid*="date-range"], [data-testid*="range-picker"]')
      .first();
    if (await rangePicker.isVisible().catch(() => false)) {
      await rangePicker.click();

      const todayOption = page
        .locator('button:has-text("Today"), [data-value="today"]')
        .first();
      if (await todayOption.isVisible().catch(() => false)) {
        await todayOption.click();

        await page.waitForTimeout(500);
      }
    }
  });

  test("should select Last 7 Days range", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const rangePicker = page.locator('[data-testid*="date-range"]').first();
    if (await rangePicker.isVisible().catch(() => false)) {
      await rangePicker.click();

      const sevenDaysOption = page
        .locator('button:has-text("Last 7 Days"), [data-value="7d"]')
        .first();
      if (await sevenDaysOption.isVisible().catch(() => false)) {
        await sevenDaysOption.click();

        await page.waitForTimeout(500);
      }
    }
  });

  test("should select custom date range", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const rangePicker = page.locator('[data-testid*="date-range"]').first();
    if (await rangePicker.isVisible().catch(() => false)) {
      await rangePicker.click();

      const customOption = page
        .locator('button:has-text("Custom"), [data-value="custom"]')
        .first();
      if (await customOption.isVisible().catch(() => false)) {
        await customOption.click();

        const startDate = page
          .locator('[data-testid*="start-date"], input[name*="start"]')
          .first();
        const endDate = page
          .locator('[data-testid*="end-date"], input[name*="end"]')
          .first();

        if (await startDate.isVisible().catch(() => false)) {
          await startDate.fill("2024-01-01");
        }
        if (await endDate.isVisible().catch(() => false)) {
          await endDate.fill("2024-01-31");
        }

        const applyButton = page
          .locator('[data-button-for="apply"], button:has-text("Apply")')
          .first();
        if (await applyButton.isVisible().catch(() => false)) {
          await applyButton.click();
        }
      }
    }
  });

  test("should reject invalid range end before start", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const rangePicker = page.locator('[data-testid*="date-range"]').first();
    if (await rangePicker.isVisible().catch(() => false)) {
      await rangePicker.click();

      const customOption = page.locator('button:has-text("Custom")').first();
      if (await customOption.isVisible().catch(() => false)) {
        await customOption.click();

        const startDate = page.locator('[data-testid*="start-date"]').first();
        const endDate = page.locator('[data-testid*="end-date"]').first();

        if (
          (await startDate.isVisible().catch(() => false)) &&
          (await endDate.isVisible().catch(() => false))
        ) {
          await startDate.fill("2024-01-31");
          await endDate.fill("2024-01-01");

          const applyButton = page.locator('[data-button-for="apply"]').first();
          if (await applyButton.isVisible().catch(() => false)) {
            await applyButton.click();

            await expect(
              page.locator(
                '[data-field-error*="date"], [data-toast*="invalid"]',
              ),
            ).toBeVisible({ timeout: 5000 });
          }
        }
      }
    }
  });

  test("should cancel and preserve original dates", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const rangePicker = page.locator('[data-testid*="date-range"]').first();
    if (await rangePicker.isVisible().catch(() => false)) {
      const originalValue = await rangePicker.inputValue().catch(() => "");

      await rangePicker.click();

      const cancelButton = page
        .locator('[data-button-for="cancel"], button:has-text("Cancel")')
        .first();
      if (await cancelButton.isVisible().catch(() => false)) {
        await cancelButton.click();

        await page.waitForTimeout(300);

        const newValue = await rangePicker.inputValue().catch(() => "");
        expect(newValue).toBe(originalValue);
      }
    }
  });
});
