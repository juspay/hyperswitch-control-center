import { test, expect } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Performance Monitor", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to analytics page", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.paymentsAnalytics.click();

    await expect(page).toHaveURL(/.*dashboard\/analytics-payments/);
    await expect(
      page.locator('[class="flex items-center gap-spacing-xl"]'),
    ).toContainText("Payments");
  });

  test("should navigate to refund analytics page", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.analytics.click();
    await homePage.refundAnalytics.click();

    await expect(page).toHaveURL(/.*dashboard\/analytics-refunds/);
    await expect(
      page.locator('[class="flex items-center gap-spacing-xl"]'),
    ).toContainText("Refunds");
  });
});
