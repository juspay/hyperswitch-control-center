import { test, expect } from "../../support/test";
import { SignInPage } from "../../support/pages/auth/SignInPage";
import { SignUpPage } from "../../support/pages/auth/SignUpPage";
import { ResetPasswordPage } from "../../support/pages/auth/ResetPasswordPage";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail, getInvalidEmails } from "../../support/helper";
import {
  signupUser,
  loginUI,
  visitSignupPage,
  redirectFromMailInbox,
  signinFromMailInbox,
  createAuth,
  getAuthIdByEmail,
} from "../../support/commands";
import { authenticator } from "otplib";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe.serial("Sign up", () => {
  test("should verify all components on the sign-up page", async ({ page }) => {
    const signupPage = new SignUpPage(page);
    const signinPage = new SignInPage(page);

    await visitSignupPage(page);

    await expect(signupPage.headerText).toContainText("Welcome to Hyperswitch");
    await expect(signupPage.signInLink).toContainText("Sign in");
    await expect(signupPage.emailInput).toHaveAttribute(
      "placeholder",
      "Enter your Email",
    );
    await expect(signupPage.signUpButton).toContainText(
      "Get started, for free!",
    );
    await expect(signupPage.signUpButton).toBeVisible();
    await expect(signupPage.footerText).toBeVisible();
    await expect(signinPage.tcText).toBeVisible();
  });

  test("should display an error message for an invalid email", async ({
    page,
  }) => {
    const signupPage = new SignUpPage(page);
    const signinPage = new SignInPage(page);

    const invalidEmails = getInvalidEmails();

    await visitSignupPage(page);

    for (const invalidEmail of invalidEmails) {
      await signupPage.emailInput.clear();
      await signupPage.emailInput.fill(invalidEmail);
      await signupPage.emailInput.blur();

      await expect(signupPage.invalidInputError).toBeVisible();
      await expect(signupPage.invalidInputError).toContainText(
        "Please enter valid Email ID",
      );
      await expect(signupPage.signUpButton).toBeVisible();

      await signupPage.emailInput.clear();
      await signupPage.emailInput.fill("test@example.com");
      await expect(signupPage.invalidInputError).not.toBeVisible();
    }
  });

  test("should show success message page after using magic link", async ({
    page,
  }) => {
    const signupPage = new SignUpPage(page);
    const signinPage = new SignInPage(page);
    const email = generateUniqueEmail();

    await visitSignupPage(page);
    await signupPage.emailInput.fill(email);
    await signupPage.signUpButton.click();

    await expect(signupPage.headerText).toContainText(
      "Please check your inbox", { timeout: 10000 }
    );
    await expect(signupPage.headerText.locator("+ div")).toContainText(
      "A magic link has been sent to",
    );
    await expect(signupPage.headerText.locator("+ div")).toContainText(email);
    await expect(signupPage.footerText).toBeVisible();
    await expect(signupPage.footerText).toContainText("Cancel");
  });

  test("should be able to sign up using magic link and verify password masking while signup", async ({
    page,
  }) => {
    const email = generateUniqueEmail();
    const password = PLAYWRIGHT_PASSWORD;

    const signinPage = new SignInPage(page);
    const signupPage = new SignUpPage(page);
    const resetPasswordPage = new ResetPasswordPage(page);

    await visitSignupPage(page);
    await signupPage.emailInput.fill(email);
    await signupPage.signUpButton.click();
    await page.waitForLoadState("networkidle");

    await redirectFromMailInbox(page, email);
    await signinPage.skip2FAButton.click();

    await expect(resetPasswordPage.createPassword).toHaveAttribute(
      "type",
      "password",
    );
    await resetPasswordPage.createPassword.fill(password);
    await expect(resetPasswordPage.confirmPassword).toHaveAttribute(
      "type",
      "password",
    );
    await resetPasswordPage.confirmPassword.fill(password);

    await resetPasswordPage.eyeIcon.nth(0).click();
    await expect(resetPasswordPage.createPassword).toHaveAttribute(
      "type",
      "text",
    );
    await expect(resetPasswordPage.createPassword).toHaveValue(password);

    await resetPasswordPage.eyeIcon.click();
    await expect(resetPasswordPage.confirmPassword).toHaveAttribute(
      "type",
      "text",
    );
    await expect(resetPasswordPage.confirmPassword).toHaveValue(password);

    await resetPasswordPage.confirmButton.click();

    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(password);
    await signinPage.signinButton.click();
    await expect(signinPage.headerText2FA).toContainText(
      "Enable Two Factor Authentication",
    );
    await signinPage.skip2FAButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/);
  });

  test("should navigate back to the login page when the `cancel` button in signup page is clicked", async ({
    page,
  }) => {
    const signupPage = new SignUpPage(page);
    const signinPage = new SignInPage(page);

    await visitSignupPage(page);
    await signinPage.signUpLink.click();
    await signupPage.emailInput.fill("test@example.com");
    await signupPage.signUpButton.click();

    await signupPage.footerText.click();
    await expect(page).toHaveURL(/.*login/);
  });
});

test.describe.serial("Sign in", () => {
  test("should verify all components on the signin page", async ({ page }) => {
    const signinPage = new SignInPage(page);
    const signupPage = new SignUpPage(page);

    await page.goto("/");

    await expect(signinPage.headerText).toContainText(
      "Hey there, Welcome back!",
    );
    await expect(signinPage.signUpLink).toContainText("Sign up");
    await expect(signinPage.emailInput).toBeVisible();
    await expect(signinPage.emailInput).toHaveAttribute(
      "placeholder",
      "Enter your Email",
    );
    await expect(signinPage.passwordInput).toBeVisible();
    await expect(signinPage.passwordInput).toHaveAttribute(
      "placeholder",
      "Enter your Password",
    );
    await expect(signinPage.forgetPasswordLink).toBeVisible();
    await expect(signinPage.forgetPasswordLink).toContainText(
      "Forgot Password?",
    );
    await expect(signinPage.signinButton).toBeVisible();
    await expect(signinPage.emailSigninLink).toBeVisible();
    await expect(signinPage.emailSigninLink).toContainText(
      "sign in with an email",
    );
    await expect(signinPage.tcText).toBeAttached();
    await expect(signinPage.footerText).toBeAttached();
  });

  test("should return to login page when clicked on 'Sign in'", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);
    const signupPage = new SignUpPage(page);

    await page.goto("/");
    await signinPage.signUpLink.click();
    await expect(page).toHaveURL(/.*register/);

    await expect(signupPage.headerText).toContainText("Welcome to Hyperswitch");
    await signupPage.signInLink.click();

    await expect(page).toHaveURL(/.*login/);
    await expect(signinPage.headerText).toContainText(
      "Hey there, Welcome back!",
    );
  });

  test("should successfully login in with valid credentials", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await expect(page).toHaveURL(/.*dashboard\/home/);
  });

  test("should persist session and remain logged in after page reload", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await expect(page).toHaveURL(/.*dashboard\/home/);

    await page.reload();
    await expect(page).toHaveURL(/.*dashboard\/home/);
    await expect(page.getByRole('button', { name: email })).toBeVisible();
  });

  test("should redirect to login when session is expired or cleared", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await expect(page).toHaveURL(/.*dashboard\/home/);

    await page.evaluate(() => {
      window.localStorage.removeItem("USER_INFO");
    });

    await page.reload();
    await page.goto("/dashboard/home");
    await expect(page).toHaveURL(/.*login/);
  });

  test("should display an error message with invalid credentials", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.goto("/");
    await signinPage.emailInput.fill("abc@gmail.com");
    await signinPage.passwordInput.fill("aAbcd?");
    await signinPage.signinButton.click();

    await expect(signinPage.invalidCredsToast).toBeVisible();
  });

  test("should successfully login using magic link for registered user", async ({
    page,
    context,
  }) => {
    // Magic-link flow chains signup, mail inbox redirect, password reset, then
    // a second mail inbox round-trip. Each hop is independently slow on CI.
    test.setTimeout(90000);
    const email = generateUniqueEmail();
    const password = PLAYWRIGHT_PASSWORD;

    const signinPage = new SignInPage(page);
    const signupPage = new SignUpPage(page);
    const resetPasswordPage = new ResetPasswordPage(page);

    await visitSignupPage(page);
    await signupPage.emailInput.fill(email);
    await signupPage.signUpButton.click();
    await expect(signupPage.headerText).toContainText(
      "Please check your inbox",
    );

    await redirectFromMailInbox(page, email);
    await signinPage.skip2FAButton.click();

    await resetPasswordPage.createPassword.fill(password);
    await resetPasswordPage.confirmPassword.fill(password);
    await resetPasswordPage.confirmButton.click();

    await signinPage.emailSigninLink.click();
    await signinPage.emailInput.fill(email);
    await signinPage.signinButton.click();

    await signinFromMailInbox(page);
    await signinPage.skip2FAButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/, { timeout: 30000 });
  });

  test("should display only email field when 'sign in with an email' is clicked", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.goto("/");

    await expect(signinPage.passwordField).toBeAttached();
    await expect(signinPage.forgetPasswordLink).toBeAttached();

    await signinPage.emailSigninLink.click();

    await expect(signinPage.passwordField).not.toBeAttached();
    await expect(signinPage.forgetPasswordLink).not.toBeAttached();
  });

  test("should verify components displayed in 2FA setup page", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    const signinPage = new SignInPage(page);

    await page.goto("/");
    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);
    await signinPage.signinButton.click();

    await expect(signinPage.headerText2FA).toContainText(
      "Enable Two Factor Authentication",
    );

    await expect(signinPage.instructions2FA).toContainText(
      "Follow these steps to configure 2FA:",
    );
    await expect(signinPage.instructions2FA).toContainText(
      "Scan the QR code with your authenticator app",
    );
    await expect(signinPage.instructions2FA).toContainText(
      "Enter the 6-digit code shown in your app below",
    );

    await expect(signinPage.otpBoxHeader).toContainText(
      "Then, Enter a 6-digit code generated by your authenticator.",
    );
    await expect(signinPage.otpBox2FA.locator("> div")).toHaveCount(6);

    await expect(signinPage.skip2FAButton).toBeVisible();
    await expect(signinPage.enable2FA).toBeVisible();
    await expect(signinPage.enable2FA).toBeDisabled();
    await expect(signinPage.enable2FA).toContainText("Enter Code");
    await expect(signinPage.footerText2FA).toBeVisible();
    await expect(signinPage.footerText2FA).toContainText(
      "Log in with a different account?",
    );
    await expect(signinPage.footerText2FA).toContainText(
      "Click here to log out.",
    );
  });

  test("should display error message with invalid TOTP in 2FA page", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    const signinPage = new SignInPage(page);
    const otp = "123456";

    await page.goto("/");
    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);
    await signinPage.signinButton.click();

    await expect(signinPage.headerText2FA).toContainText(
      "Enable Two Factor Authentication",
    );

    await signinPage.fillOTP(otp);
    await signinPage.enable2FA.click();

    await expect(signinPage.incorrectCodeError).toBeVisible();
  });

  test("should navigate to homepage when 2FA is skipped", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    const signinPage = new SignInPage(page);

    await page.goto("/");
    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);
    await signinPage.signinButton.click();

    await expect(signinPage.headerText2FA).toContainText(
      "Enable Two Factor Authentication",
    );

    await signinPage.skip2FAButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/);
  });

  test("should navigate to signin page when 'Click here to log out.' is clicked in 2FA page", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    const signinPage = new SignInPage(page);

    await page.goto("/");
    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);
    await signinPage.signinButton.click();

    await expect(signinPage.headerText2FA).toContainText(
      "Enable Two Factor Authentication",
    );

    await signinPage.logoutLink2FA.click();

    await expect(signinPage.headerText).toContainText(
      "Hey there, Welcome back!",
    );
  });
});

test.describe("Forgot password", () => {
  test("should verify all components in forgot password page", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.goto("/");
    await signinPage.forgetPasswordLink.click();
    await expect(page).toHaveURL(/.*dashboard\/forget-password/);
    await expect(signinPage.forgetPasswordHeader).toContainText(
      "Forgot Password?",
    );

    await expect(signinPage.emailInput).toBeVisible();
    await expect(signinPage.emailInput).toHaveAttribute(
      "placeholder",
      "Enter your Email",
    );

    await expect(signinPage.resetPasswordButton).toBeVisible();
    await expect(signinPage.resetPasswordButton).toBeDisabled();
    await expect(signinPage.cancelForgetPassword).toBeVisible();
    await expect(signinPage.cancelForgetPassword).toContainText("Cancel");
  });

  test("should display fail toast when unregistered email is used", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.goto("/");
    await signinPage.forgetPasswordLink.click();
    await signinPage.emailInput.fill("abcde@gmail.com");
    await signinPage.resetPasswordButton.click();

    await expect(signinPage.forgotPasswordFailedToast).toBeVisible();
    await expect(signinPage.forgotPasswordFailedToast).toContainText(
      "Forgot Password Failed, Try again",
    );
  });

  test("should display success message when registered email is used", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    const signinPage = new SignInPage(page);

    await page.goto("/");
    await signinPage.forgetPasswordLink.click();
    await signinPage.emailInput.fill(email);
    await signinPage.resetPasswordButton.click();

    await expect(signinPage.forgotPasswordSentToast).toBeVisible();
    await expect(signinPage.forgotPasswordSentToast).toContainText(
      "Please check your registered e-mail",
    );
    await expect(signinPage.forgetPasswordHeader).toContainText(
      "Please check your inbox",
    );
    await expect(signinPage.resetLinkSentContainer).toContainText(
      "A reset password link has been sent to",
    );
    await expect(signinPage.forgotPasswordCancelContainer).toContainText(
      "Cancel",
    );
  });

  test("should reset password through mail and login successfully", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    const newPassword = "Test@123";

    const signinPage = new SignInPage(page);
    const resetPasswordPage = new ResetPasswordPage(page);

    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.goto("/");
    await signinPage.forgetPasswordLink.click();
    await signinPage.emailInput.fill(email);
    await signinPage.resetPasswordButton.click();
    await redirectFromMailInbox(
      page,
      email,
      "Get back to Hyperswitch - Reset Your Password Now!",
    );

    await signinPage.skip2FAButton.click();
    await resetPasswordPage.newPasswordField.fill(newPassword);
    await resetPasswordPage.confirmPasswordField.fill(newPassword);
    await resetPasswordPage.confirmButton.click();
    await expect(page).toHaveURL(/.*login/);
    await expect(signinPage.passwordChangedToast).toContainText(
      "Password Changed Successfully",
    );

    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(newPassword);
    await signinPage.signinButton.click();
    await signinPage.skip2FAButton.click();
    await expect(page).toHaveURL(/.*dashboard\/home/);
  });

  test("should display validation error for weak password or mismatched confirmation on reset", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    const signinPage = new SignInPage(page);
    const resetPasswordPage = new ResetPasswordPage(page);

    const weakPasswords = [
      { password: "Weak1!", expectedError: "Password must be at least 8 characters long." },
      { password: "password123!", expectedError: /uppercase/ },
      { password: "PASSWORD123!", expectedError: /lowercase/ },
      { password: "Password!@#", expectedError: /numeric/ },
      { password: "Password123", expectedError: /special/ },
    ];

    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.goto("/");
    await signinPage.forgetPasswordLink.click();
    await signinPage.emailInput.fill(email);
    await signinPage.resetPasswordButton.click();
    await redirectFromMailInbox(
      page,
      email,
      "Get back to Hyperswitch - Reset Your Password Now!",
    );

    await signinPage.skip2FAButton.click();

    for (const { password, expectedError } of weakPasswords) {
      await resetPasswordPage.newPasswordField.fill(password);
      await resetPasswordPage.newPasswordField.blur();
      await resetPasswordPage.confirmPasswordField.fill(password);
      await resetPasswordPage.confirmPasswordField.blur();
      await expect(resetPasswordPage.weakPasswordError).toContainText(expectedError);
    }
  });
});

const ssoBaseUrl = process.env.PLAYWRIGHT_SSO_BASE_URL;
(ssoBaseUrl ? test.describe.serial : test.describe.skip)(
  "Okta SSO tests",
  () => {
    let authId = "";

    test.beforeAll(async ({ request }) => {
      try {
        await signupUser(
          process.env.PLAYWRIGHT_SSO_USERNAME!,
          process.env.PLAYWRIGHT_SSO_PASSWORD!,
          request,
        );
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        // Ignore "already exists" error on retries, rethrow all others
        if (!errorMsg.includes("already exists")) {
          throw error;
        }
      }
      try {
        await createAuth(request);
      } catch (error) {
        const errorMsg = error instanceof Error ? error.message : String(error);
        // Ignore "auth method already exists" error on retries, rethrow all others
        if (!errorMsg.includes("already exists")) {
          throw error;
        }
      }
      authId = await getAuthIdByEmail(request);
    });

    test("should display 'Continue with Okta' button when login URL is accessed with valid okta enabled auth_id", async ({
      page,
    }) => {
      const signinPage = new SignInPage(page);

      await page.goto(`/?auth_id=${authId}`);
      await page.waitForLoadState("networkidle");

      await expect(signinPage.continueWithOktaButton).toBeVisible({
        timeout: 30000,
      });
      await expect(signinPage.continueWithOktaButton).toContainText(
        "Continue with Okta",
      );
    });

    test("should not display the SSO button when login URL is accessed without, with empty, or with invalid auth_id parameter", async ({
      page,
    }) => {
      const signinPage = new SignInPage(page);

      await page.goto("/");
      await expect(signinPage.continueWithOktaButton).not.toBeAttached();

      await page.goto("/?auth_id=");
      await expect(signinPage.continueWithOktaButton).not.toBeAttached();

      await page.goto("/?auth_id=abcd");
      await expect(signinPage.continueWithOktaButton).not.toBeAttached();
    });

    test("should redirect to Okta login page when 'Continue with Okta' button is clicked", async ({
      page,
    }) => {
      const signinPage = new SignInPage(page);

      await page.goto(`/?auth_id=${authId}`);
      await signinPage.continueWithOktaButton.click();

      await page.waitForURL(/.*okta\.com.*/, { timeout: 30000 });
    });

    test("should redirect to dashboard homepage after entering valid Okta credentials", async ({
      page,
    }) => {
      // Cross-domain Okta round-trip + dashboard load is too slow for the
      // default 30s test budget on CI; bump it before chaining waits.
      test.setTimeout(90000);
      const signinPage = new SignInPage(page);
      const ssoUsername = process.env.PLAYWRIGHT_SSO_USERNAME || "";
      const ssoPassword = process.env.PLAYWRIGHT_SSO_PASSWORD || "";

      await page.goto(`/?auth_id=${authId}`);
      await signinPage.continueWithOktaButton.click();

      await page.waitForURL(/.*okta\.com.*/, { timeout: 30000 });

      await signinPage.oktaEmailInput.fill(ssoUsername);
      await signinPage.oktaNextButton.click();
      await signinPage.oktaPasswordInput.fill(ssoPassword);
      await signinPage.oktaVerifyButton.click();

      await page.waitForURL(/.*dashboard\/home/, { timeout: 30000 });
    });

    test("should show authentication error after entering invalid Okta credentials and stay on Okta login page", async ({
      page,
    }) => {
      const signinPage = new SignInPage(page);

      await page.goto(`/?auth_id=${authId}`);
      await signinPage.continueWithOktaButton.click();

      await signinPage.oktaEmailInput.fill("demo.user@test.com");
      await signinPage.oktaNextButton.click();
      await signinPage.oktaPasswordInput.fill("Test@1234");
      await signinPage.oktaVerifyButton.click();

      await expect(signinPage.oktaErrorMessage).toBeVisible();
      await expect(signinPage.oktaErrorMessage).toContainText(
        "Unable to sign in",
      );
      await expect(page).toHaveURL(/.*okta\.com.*/);
    });

    test("should automatically log in and redirect to the dashboard after logout once initial Okta login is successful", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const signinPage = new SignInPage(page);
      const ssoUsername = process.env.PLAYWRIGHT_SSO_USERNAME || "";
      const ssoPassword = process.env.PLAYWRIGHT_SSO_PASSWORD || "";

      await page.goto(`/?auth_id=${authId}`);
      await signinPage.continueWithOktaButton.click();

      await signinPage.oktaEmailInput.fill(ssoUsername);
      await signinPage.oktaNextButton.click();
      await signinPage.oktaPasswordInput.fill(ssoPassword);
      await signinPage.oktaVerifyButton.click();

      await page.waitForURL(/.*dashboard\/home/, { timeout: 30000 });

      await homePage.userAccount.click();
      await homePage.signOut.click();

      await signinPage.continueWithOktaButton.click();

      await page.waitForURL(/.*dashboard\/home/, { timeout: 30000 });
    });

    test("should require full Okta login after logged out from okta", async ({
      page,
      request,
    }) => {
      const homePage = new HomePage(page);
      const signinPage = new SignInPage(page);
      const ssoUsername = process.env.PLAYWRIGHT_SSO_USERNAME || "";
      const ssoPassword = process.env.PLAYWRIGHT_SSO_PASSWORD || "";
      const ssoBase = process.env.PLAYWRIGHT_SSO_BASE_URL || "";

      await page.goto(`/?auth_id=${authId}`);
      await signinPage.continueWithOktaButton.click();

      await signinPage.oktaEmailInput.fill(ssoUsername);
      await signinPage.oktaNextButton.click();
      await signinPage.oktaPasswordInput.fill(ssoPassword);
      await signinPage.oktaVerifyButton.click();

      await page.waitForURL(/.*dashboard\/home/, { timeout: 30000 });

      await homePage.userAccount.click();
      await homePage.signOut.click();

      await page.request.get(`${ssoBase}/login/signout`, { maxRedirects: 0 });

      await signinPage.continueWithOktaButton.click();

      await expect(page).toHaveURL(/.*okta\.com.*/);
    });
  },
);

test.describe("TOTP flows", () => {
  test("should successfully setup 2FA while signup", async ({
    page,
    context,
  }) => {
    let totpSecret = "";
    const email = generateUniqueEmail();

    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.goto("/");
    const signinPage = new SignInPage(page);

    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);

    await page.route("**/2fa/totp/begin", async (route) => {
      const response = await route.fetch();
      const body = await response.json();
      totpSecret = body.secret.secret;
      await route.fulfill({ response });
    });

    const responsePromise = page.waitForResponse("**/2fa/totp/begin");
    await signinPage.signinButton.click();
    await responsePromise;

    await expect(signinPage.qrCode2FA).toBeVisible();

    const token = authenticator.generate(totpSecret);

    await signinPage.fillOTP(token);

    await signinPage.enable2FA.click();

    await signinPage.downloadRecoveryCodes.click();

    await expect(page).toHaveURL(/.*dashboard\/home/);
  });

  test("should successfully signin using 2FA", async ({ page, context }) => {
    let totpSecret = "";
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

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

    await expect(signinPage.qrCode2FA).toBeVisible();

    const token = authenticator.generate(totpSecret);

    await signinPage.fillOTP(token);

    await signinPage.enable2FA.click();

    await expect(signinPage.recoveryCodesText).toBeVisible();

    await signinPage.downloadRecoveryCodes.click();

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);
    await signinPage.signinButton.click();

    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(500);

    // When user has 2FA already setup, they're shown verification page
    await expect(signinPage.otpBox2FA).toBeVisible();

    await signinPage.fillOTP(token);

    await signinPage.verifyOTPButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/);
  });
});

test.describe("Branding flag", () => {
  test("should show T&C and footer links on auth pages when branding flag is OFF", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.branding = false;
      }
      await route.fulfill({ response, json });
    });

    await page.goto("/login");

    await expect(signinPage.tcText).toBeVisible();
    await expect(signinPage.footerText).toBeVisible();
  });

  test("should hide T&C and footer links on auth pages when branding flag is ON", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.branding = true;
      }
      await route.fulfill({ response, json });
    });

    await page.goto("/login");

    await expect(signinPage.headerText).toContainText(
      "Hey there, Welcome back!",
    );
    await expect(signinPage.tcText).not.toBeAttached();
    await expect(signinPage.footerText).not.toBeAttached();
  });
});

test.describe("Email flag behavior", () => {
  test("should display Forgot Password link on login page when email flag is ON", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.email = true;
      }
      await route.fulfill({ response, json });
    });

    await page.goto("/login");

    await expect(signinPage.forgetPasswordLink).toBeVisible();
    await expect(signinPage.forgetPasswordLink).toContainText(
      "Forgot Password?",
    );
    await expect(signinPage.emailSigninLink).toBeVisible();
    await expect(signinPage.emailSigninLink).toContainText(
      "sign in with an email",
    );
  });

  test("should not display Forgot Password link on login page when email flag is OFF", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.email = false;
      }
      await route.fulfill({ response, json });
    });

    await page.goto("/login");

    await expect(signinPage.headerText).toContainText(
      "Hey there, Welcome back!",
    );
    await expect(signinPage.forgetPasswordLink).not.toBeVisible();
    await expect(signinPage.emailSigninLink).not.toBeVisible();
  });
});

test.describe("Maintenance mode and Down time", () => {
  test("should display maintenance page instead of auth flow when downTime flag is ON", async ({
    page,
  }) => {
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.down_time = true;
      }
      await route.fulfill({ response, json });
    });

    await page.goto("/");

    await expect(page.getByText('Hyperswitch Control Center is under maintenance', { exact: true })).toBeVisible();
    await expect(page.getByText('Hyperswitch Control Center is under maintenance will be back in an hour')).toBeVisible();
    await expect(page.getByText("Hey there, Welcome back!")).not.toBeVisible();
  });

  test("should display maintenance alert banner in homepage when maintenance_alert is set", async ({
    page, context
  }) => {
    const maintenanceAlert = "Scheduled maintenance window time from 01:30 AM to 06:00 AM IST on 21st Jun";

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.maintenance_alert = maintenanceAlert;
      }
      await route.fulfill({ response, json });
    });

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await expect(page.getByRole('alert')).toContainText(maintenanceAlert);
  });
});
