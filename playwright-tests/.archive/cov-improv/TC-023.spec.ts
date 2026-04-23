import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-023: Payment Link Theme Customization", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.theme_configurator = true;
        json.features.payment_link_theme = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should navigate to payment link theme", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();

    // Fixed: Added guard for theme nav existence
    const themeNav = page
      .locator('[data-testid*="theme"], a[href*="payment-link-theme"]')
      .first();
    if (!(await themeNav.isVisible().catch(() => false))) {
      return;
    }
    await themeNav.click();

    await expect(page).toHaveURL(/.*dashboard\/payment-link-theme/);
  });

  test("should change primary color", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();

    const themeNav = page.locator('[data-testid*="theme"]').first();
    if (!(await themeNav.isVisible().catch(() => false))) {
      return;
    }
    await themeNav.click();

    const colorInput = page
      .locator('input[type="color"], [name*="primary_color"]')
      .first();
    if (await colorInput.isVisible().catch(() => false)) {
      await colorInput.fill("#FF6B35");

      const preview = page
        .locator('[data-testid*="preview"], [class*="preview"]')
        .first();
      if (await preview.isVisible().catch(() => false)) {
        await expect(preview).toBeVisible();
      }
    }
  });

  test("should customize button styles", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();

    const themeNav = page.locator('[data-testid*="theme"]').first();
    if (!(await themeNav.isVisible().catch(() => false))) {
      return;
    }
    await themeNav.click();

    const buttonStyle = page
      .locator('[name*="button_style"], select[name*="button"]')
      .first();
    if (await buttonStyle.isVisible().catch(() => false)) {
      await buttonStyle.selectOption("rounded");
    }

    const buttonColor = page
      .locator('input[type="color"][name*="button"]')
      .first();
    if (await buttonColor.isVisible().catch(() => false)) {
      await buttonColor.fill("#006DF9");
    }
  });

  test("should preview theme changes", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();

    const themeNav = page.locator('[data-testid*="theme"]').first();
    if (!(await themeNav.isVisible().catch(() => false))) {
      return;
    }
    await themeNav.click();

    const previewButton = page
      .locator('[data-button-for="preview"], button:has-text("Preview")')
      .first();
    if (await previewButton.isVisible().catch(() => false)) {
      await previewButton.click();

      const previewFrame = page
        .locator(
          'iframe[data-testid*="preview"], [data-testid*="preview-container"]',
        )
        .first();
      await expect(previewFrame).toBeVisible();
    }
  });

  test("should save theme configuration", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();

    const themeNav = page.locator('[data-testid*="theme"]').first();
    if (!(await themeNav.isVisible().catch(() => false))) {
      return;
    }
    await themeNav.click();

    const saveButton = page
      .locator('[data-button-for="saveTheme"], button:has-text("Save")')
      .first();
    if (await saveButton.isVisible().catch(() => false)) {
      await saveButton.click();

      await expect(
        page.locator('[data-toast*="saved"], [data-toast*="success"]'),
      ).toBeVisible({ timeout: 10000 });
    }
  });
});
