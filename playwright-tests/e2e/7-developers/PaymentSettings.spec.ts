import { test, expect } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Payment Settings", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to payment settings page", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();

    await expect(page).toHaveURL(/.*dashboard\/payment-settings/);
    await expect(
      page.locator('[class="text-fs-28 font-semibold leading-10 "]'),
    ).toContainText("Payment Settings");
  });

  test("should verify payment settings page components", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();

    await expect(page.locator('[data-testid="settings-form"]')).toBeVisible();
  });
});
