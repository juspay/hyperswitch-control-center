import { test, expect } from "@playwright/test";
import { SignInPage } from "../../support/pages/auth/SignInPage";
import { SignUpPage } from "../../support/pages/auth/SignUpPage";
import { ResetPasswordPage } from "../../support/pages/auth/ResetPasswordPage";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
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

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

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

    const invalidEmails = [
      "@#$%",
      "plainaddress",
      "missing@domain",
      "user@.com",
      "user@domain..com",
      "user@domain,com",
      "user@domain.123",
      "user@domain.c",
      "user@domain.",
      "user@.com",
      "12345678",
      "abc@@xy.zi",
      "@com.in",
      "abc.in",
      "abc..xyz@abc.com",
    ];

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
      "Please check your inbox",
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
    await page.getByPlaceholder("Enter your Email").fill(email);
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

test.describe("Sign in", () => {
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
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await expect(page).toHaveURL(/.*dashboard\/home/);
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
    const email = generateUniqueEmail();
    const password = PLAYWRIGHT_PASSWORD;

    const signinPage = new SignInPage(page);
    const resetPasswordPage = new ResetPasswordPage(page);

    await visitSignupPage(page);
    await page.getByPlaceholder("Enter your Email").fill(email);
    await page.locator('[data-testid="auth-submit-btn"]').click();
    await expect(page.locator('[data-testid="card-header"]')).toContainText(
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

    await expect(page).toHaveURL(/.*dashboard\/home/);
  });

  test("should display only email field when 'sign in with an email' is clicked", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.goto("/");

    await expect(page.locator('[data-testid="password"]')).toBeAttached();
    await expect(
      page.locator('[data-testid="forgot-password"]'),
    ).toBeAttached();

    await signinPage.emailSigninLink.click();

    await expect(page.locator('[data-testid="password"]')).not.toBeAttached();
    await expect(
      page.locator('[data-testid="forgot-password"]'),
    ).not.toBeAttached();
  });

  test("should verify components displayed in 2FA setup page", async ({
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
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

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

    await expect(
      page.getByText("Incorrect code, please try again"),
    ).toBeVisible();
  });

  test("should navigate to homepage when 2FA is skipped", async ({
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
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

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

    await expect(
      page.locator('[data-toast="Forgot Password Failed, Try again"]'),
    ).toBeVisible();
    await expect(
      page.locator('[data-toast="Forgot Password Failed, Try again"]'),
    ).toContainText("Forgot Password Failed, Try again");
  });

  test("should display success message when registered email is used", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    const signinPage = new SignInPage(page);

    await page.goto("/");
    await signinPage.forgetPasswordLink.click();
    await signinPage.emailInput.fill(email);
    await signinPage.resetPasswordButton.click();

    await expect(
      page.locator('[data-toast="Please check your registered e-mail"]'),
    ).toBeVisible();
    await expect(
      page.locator('[data-toast="Please check your registered e-mail"]'),
    ).toContainText("Please check your registered e-mail");
    await expect(page.locator('[data-testid="card-header"]')).toContainText(
      "Please check your inbox",
    );
    await expect(
      page.locator('[class="flex-col items-center justify-center"]'),
    ).toContainText("A reset password link has been sent to");
    await expect(
      page.locator('[class="w-full flex justify-center"]'),
    ).toContainText("Cancel");
  });

  test("should reset password through mail and login successfully", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    const newPassword = "Test@123";

    const signinPage = new SignInPage(page);
    const resetPasswordPage = new ResetPasswordPage(page);

    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

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
    await expect(
      page.locator('[data-toast="Password Changed Successfully"]'),
    ).toContainText("Password Changed Successfully");

    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(newPassword);
    await signinPage.signinButton.click();
    await signinPage.skip2FAButton.click();
    await expect(page).toHaveURL(/.*dashboard\/home/);
  });
});

const ssoBaseUrl = process.env.PLAYWRIGHT_SSO_BASE_URL;
(ssoBaseUrl ? test.describe.serial : test.describe.skip)(
  "Okta SSO tests",
  () => {
    let authId = "";

    test.beforeAll(async ({ request }) => {
      await signupUser(
        process.env.PLAYWRIGHT_SSO_USERNAME!,
        process.env.PLAYWRIGHT_SSO_PASSWORD!,
        request,
      );
      await createAuth(request);
      authId = await getAuthIdByEmail(request);
    });

    test("should display 'Continue with Okta' button when login URL is accessed with valid okta enabled auth_id", async ({
      page,
    }) => {
      const signinPage = new SignInPage(page);

      await page.goto(`/?auth_id=${authId}`);

      await expect(signinPage.continueWithOktaButton).toBeVisible();
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

      await page.waitForURL(/.*okta\.com.*/, { timeout: 10000 });
    });

    test("should redirect to dashboard homepage after entering valid Okta credentials", async ({
      page,
    }) => {
      const signinPage = new SignInPage(page);
      const ssoUsername = process.env.PLAYWRIGHT_SSO_USERNAME || "";
      const ssoPassword = process.env.PLAYWRIGHT_SSO_PASSWORD || "";

      await page.goto(`/?auth_id=${authId}`);
      await signinPage.continueWithOktaButton.click();

      await page.waitForURL(/.*okta\.com.*/, { timeout: 10000 });

      await signinPage.oktaEmailInput.fill(ssoUsername);
      await signinPage.oktaNextButton.click();
      await signinPage.oktaPasswordInput.fill(ssoPassword);
      await signinPage.oktaVerifyButton.click();

      await page.waitForURL(/.*dashboard\/home/, { timeout: 10000 });
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

      await page.waitForURL(/.*dashboard\/home/, { timeout: 10000 });

      await homePage.userAccount.click();
      await homePage.signOut.click();

      await signinPage.continueWithOktaButton.click();

      await page.waitForURL(/.*dashboard\/home/, { timeout: 10000 });
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

      await page.waitForURL(/.*dashboard\/home/, { timeout: 10000 });

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

    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

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

    await expect(page.locator('[viewBox="0 0 41 41"]')).toBeVisible();

    const token = authenticator.generate(totpSecret);

    const textboxes = page.getByRole("textbox");
    const count = await textboxes.count();
    for (let i = 0; i < token.length && i < count; i++) {
      await textboxes.nth(i).fill(token.charAt(i));
    }

    await signinPage.enable2FA.click();

    await page.locator('[data-button-for="download"]').click();

    await expect(page).toHaveURL(/.*dashboard\/home/);
  });
});
