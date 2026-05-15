import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { SignInPage } from "../../support/pages/auth/SignInPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Profile", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should open user account dropdown", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.userAccount.click();

    await expect(homePage.signOut).toBeVisible();
  });

  test("should sign out successfully", async ({ page }) => {
    const homePage = new HomePage(page);
    const signInPage = new SignInPage(page);

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await expect(page).toHaveURL(/.*login/);
    await expect(signInPage.headerText).toContainText(
      "Hey there, Welcome back!",
    );
  });
});
