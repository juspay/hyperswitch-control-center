/**
 * Auto-generated Playwright test
 * Source: scenario: signin flow happy path
 * Generated: 2026-03-23
 */

import { test, expect } from "@playwright/test";
import { SignInPage } from "../support/pages/auth/SignInPage";
import { signupUser } from "../support/commands";
import { generateUniqueEmail } from "../support/helper";

test.describe("Sign In Flow - Happy Path", () => {
  let testEmail: string;
  const testPassword = process.env.TEST_PASSWORD || "Test@123";

  test.beforeEach(async ({ page }) => {
    testEmail = generateUniqueEmail();
    await signupUser(testEmail, testPassword);
  });

  test("Sign in with valid email and password redirects to dashboard", async ({
    page,
  }) => {
    const signInPage = new SignInPage(page);

    await page.goto("/dashboard/login");
    await expect(page).toHaveURL(/.*login/);

    await signInPage.emailInput.fill(testEmail);
    await signInPage.passwordInput.fill(testPassword);
    await signInPage.signinButton.click();

    await signInPage.skip2FAButton.waitFor({
      state: "visible",
      timeout: 10000,
    });
    await signInPage.skip2FAButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/, { timeout: 10000 });
  });

  test("Sign in page displays all required elements", async ({ page }) => {
    const signInPage = new SignInPage(page);

    await page.goto("/dashboard/login");

    await expect(signInPage.emailInput).toBeVisible();
    await expect(signInPage.passwordInput).toBeVisible();
    await expect(signInPage.signinButton).toBeVisible();
    await expect(signInPage.forgetPasswordLink).toBeVisible();
    await expect(signInPage.headerText).toBeVisible();
    await expect(signInPage.signUpLink).toBeVisible();
  });

  test("Sign in form accepts input correctly", async ({ page }) => {
    const signInPage = new SignInPage(page);

    await page.goto("/dashboard/login");

    await signInPage.emailInput.fill("valid@example.com");
    await expect(signInPage.emailInput).toHaveValue("valid@example.com");

    await signInPage.passwordInput.fill("TestPassword123!");
    await expect(signInPage.passwordInput).toHaveValue("TestPassword123!");
  });

  test("Sign in button is enabled with valid input", async ({ page }) => {
    const signInPage = new SignInPage(page);

    await page.goto("/dashboard/login");

    await signInPage.emailInput.fill("test@example.com");
    await signInPage.passwordInput.fill("Password123!");

    await expect(signInPage.signinButton).toBeVisible();
    await expect(signInPage.signinButton).toBeEnabled();
  });

  test("User can navigate from sign in to sign up page", async ({ page }) => {
    const signInPage = new SignInPage(page);

    await page.goto("/dashboard/login");
    await signInPage.signUpLink.click();

    await expect(page).toHaveURL(/.*register/);
  });

  test("User can navigate to forgot password page", async ({ page }) => {
    const signInPage = new SignInPage(page);

    await page.goto("/dashboard/login");
    await signInPage.forgetPasswordLink.click();

    await expect(page).toHaveURL(/.*forget-password/);
  });
});
