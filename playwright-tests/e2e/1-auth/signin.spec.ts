import { test, expect } from "@playwright/test";
import { SignInPage } from "../../support/pages/auth/SignInPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUser } from "../../support/commands";

test.describe("Sign In - Authentication Flow", () => {});

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Sign In - Happy Flow", () => {
  let email: string;

  test.beforeEach(async ({ context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  });

  test("should successfully login with valid credentials", async ({ page }) => {
    const signinPage = new SignInPage(page);

    await page.goto("/");
    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);
    await signinPage.signinButton.click();
    await signinPage.skip2FAButton.click();
    await expect(page).toHaveURL(/.*dashboard\/home/);
  });
});
