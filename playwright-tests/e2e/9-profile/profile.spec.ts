import { test, expect } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Profile", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should open user account dropdown", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.userAccount.click();

    await expect(homePage.signOut).toBeVisible();
  });

  test("should sign out successfully", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await expect(page).toHaveURL(/.*login/);
    await expect(page.locator('[data-testid="card-header"]')).toContainText(
      "Hey there, Welcome back!",
    );
  });
});
