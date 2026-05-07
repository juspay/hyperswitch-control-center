import { test, expect } from "@playwright/test";
import { SignInPage } from "../support/pages/auth/SignInPage";
import { SignUpPage } from "../support/pages/auth/SignUpPage";
import { generateUniqueEmail } from "../support/helper";
import {
  getAuthIdByEmail,
  signupUser,
  createAuth,
  visitSignupPage,
  mockV2MerchantList,
} from "../support/commands";
import { authenticator } from "otplib";
import { HomePage } from "../support/pages/homepage/HomePage";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Visual Testing - Auth Pages", () => {
  test("signup page should match visual snapshot", async ({ page }) => {
    const signupPage = new SignUpPage(page);

    await visitSignupPage(page);
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(500);

    await expect(signupPage.headerText).toBeVisible();

    await expect(page).toHaveScreenshot("auth-signup-page.png", {
      fullPage: true,
      animations: "disabled",
    });
  });

  test("sign in page should match visual snapshot", async ({ page }) => {
    const signinPage = new SignInPage(page);

    await page.goto("/");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(500);

    await expect(signinPage.headerText).toBeVisible();

    await expect(page).toHaveScreenshot("auth-signin-page.png", {
      fullPage: true,
      animations: "disabled",
    });
  });

  test("sign in with email page should match visual snapshot", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.goto("/");

    await signinPage.emailSigninLink.click();
    await expect(signinPage.headerText).toBeVisible();

    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(500);

    await expect(page).toHaveScreenshot("auth-signin-with-email-page.png", {
      fullPage: true,
      animations: "disabled",
    });
  });

  test("sign in page with SSO should match visual snapshot", async ({
    page,
    request,
  }) => {
    const signinPage = new SignInPage(page);

    try {
      await createAuth(request, "visual_test", "visualtest.in");
    } catch (error) {
      const errorMsg = error instanceof Error ? error.message : String(error);
      // Ignore "auth method already exists" error on retries, rethrow all others
      if (!errorMsg.includes("already exists")) {
        throw error;
      }
    }
    const authId = await getAuthIdByEmail(request, "visualtest.in");

    await page.goto(`/?auth_id=${authId}`);
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(500);

    await expect(signinPage.continueWithOktaButton).toBeVisible();

    await expect(page).toHaveScreenshot("auth-signin-sso-page.png", {
      fullPage: true,
      animations: "disabled",
    });
  });

  test("forget password page should match visual snapshot", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.goto("/");
    await signinPage.forgetPasswordLink.click();
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(500);

    await expect(signinPage.forgetPasswordHeader).toBeVisible();

    await expect(page).toHaveScreenshot("auth-forget-password-page.png", {
      fullPage: true,
      animations: "disabled",
    });
  });

  test("mail sent page should match visual snapshot", async ({ page }) => {
    const signupPage = new SignUpPage(page);
    const email = "test@test.com";

    await visitSignupPage(page);
    await signupPage.emailInput.fill(email);
    await signupPage.signUpButton.click();

    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(500);

    await expect(signupPage.headerText).toContainText(
      "Please check your inbox",
    );

    await expect(page).toHaveScreenshot("auth-mail-sent-page.png", {
      fullPage: true,
      animations: "disabled",
    });
  });

  test("2FA setup page for new user should match visual snapshot", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    const signinPage = new SignInPage(page);

    await page.goto("/");
    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);
    await signinPage.signinButton.click();

    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(500);

    await expect(signinPage.headerText2FA).toContainText(
      "Enable Two Factor Authentication",
    );
    await expect(signinPage.skip2FAButton).toBeVisible();
    await expect(signinPage.enable2FA).toBeVisible();

    await expect(page).toHaveScreenshot("auth-2fa-setup-new-user-page.png", {
      fullPage: true,
      animations: "disabled",
    });
  });

  test("2FA verification and recovery code pages for returning user with 2FA enabled", async ({
    page,
    context,
  }) => {
    let totpSecret = "";
    await mockV2MerchantList(page);
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    const signinPage = new SignInPage(page);
    const homePage = new HomePage(page);

    await page.goto("/");
    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);

    await page.route("**/2fa/totp/begin", async (route) => {
      const response = await route.fetch();
      const body = await response.json();
      totpSecret = body.secret?.secret || "";
      await route.fulfill({ response });
    });

    const responsePromise = page.waitForResponse("**/2fa/totp/begin");
    await signinPage.signinButton.click();
    await responsePromise;

    await expect(page.locator('[viewBox="0 0 41 41"]')).toBeVisible();

    const token = authenticator.generate(totpSecret);

    const textboxes = page.getByRole("textbox");
    const count = await textboxes.count();
    for (let i = 0; i < token.length && i < count; i++) {
      await textboxes.nth(i).fill(token.charAt(i));
    }

    await signinPage.enable2FA.click();

    await expect(page.getByText("Two factor recovery codes")).toBeVisible();

    await expect(page).toHaveScreenshot(
      "auth-2fa-download-recovery-codes-page.png",
      {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      },
    );

    await page.locator('[data-button-for="download"]').click();

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);
    await signinPage.signinButton.click();

    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(500);

    // When user has 2FA already setup, they're shown verification page
    await expect(signinPage.otpBox2FA).toBeVisible();

    await expect(page).toHaveScreenshot("auth-2fa-verification-page.png", {
      fullPage: true,
      animations: "disabled",
    });

    await page.getByText("Use recovery code").click();
    await expect(page.getByText("Enter a 8-digit recovery code")).toBeVisible();

    await expect(page).toHaveScreenshot(
      "auth-2fa-recovery-code-input-page.png",
      {
        fullPage: true,
        animations: "disabled",
      },
    );
  });
});
