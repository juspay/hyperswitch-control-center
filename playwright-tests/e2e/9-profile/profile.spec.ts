import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { SignInPage } from "../../support/pages/auth/SignInPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";
import { ProfilePage } from "../../support/pages/profile/ProfilePage";
import { authenticator } from "otplib";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
const STRONG_NEW_PASSWORD = "PlaywrightNew00#";

test.describe("Profile - User Account Menu", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should open user account dropdown", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.userAccount.click();

    await expect(homePage.userProfile).toBeVisible({ timeout: 5000 });
    await expect(homePage.signOut).toBeVisible();

    await homePage.userProfile.click();

    await expect(page.getByText("ProfileManage your profile")).toBeVisible();
    await expect(
      page.locator("div").filter({ hasText: /^User Info$/ }),
    ).toBeVisible();
    await expect(page.getByText("Name:Playwright_test_user")).toBeVisible();
    await expect(page.getByText("Email:playwright-")).toBeVisible();
    // The password row shows masked value plus an action button that is either
    // "Change Password" or "Reset Password" depending on the `email` feature
    // flag, so assert the stable parts and match either action button.
    await expect(page.getByText("Password:", { exact: true })).toBeVisible();
    await expect(page.getByText("********")).toBeVisible();
    await expect(
      page.getByRole("button", { name: /Change Password|Reset Password/ }),
    ).toBeVisible();

    await expect(
      page.locator("div").filter({ hasText: /^Two factor authentication$/ }),
    ).not.toBeVisible();
    await expect(
      page.getByText(
        "Change app / deviceReset TOTP to regain access if you've changed or lost your device.",
      ),
    ).not.toBeVisible();
    await expect(
      page.getByRole("button", { name: "Edit" }).first(),
    ).not.toBeVisible();
    await expect(
      page.getByText(
        "Regenerate recovery codesRegenerate your access code to ensure continued access and security for your account.",
      ),
    ).not.toBeVisible();
    await expect(
      page.getByRole("button", { name: "Edit" }).nth(1),
    ).not.toBeVisible();
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

test.describe("Profile Settings - Change Password", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.email = false;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    const profilePage = new ProfilePage(page);
    await profilePage.visit();
    await page.waitForLoadState("networkidle");
  });

  test("should open the Change Password modal with all password fields", async ({
    page,
  }) => {
    const profilePage = new ProfilePage(page);

    await expect(profilePage.changePasswordButton).toBeVisible({
      timeout: 10000,
    });
    await profilePage.changePasswordButton.click();

    await expect(profilePage.changePasswordModalHeader).toBeVisible();

    await expect(page.getByText("Old Password")).toBeVisible();
    await expect(profilePage.oldPasswordInput).toBeVisible();
    await expect(profilePage.oldPasswordInput).toHaveAttribute(
      "type",
      "password",
    );

    await expect(page.getByText("New Password")).toBeVisible();
    await expect(profilePage.newPasswordInput).toBeVisible();
    await expect(profilePage.newPasswordInput).toHaveAttribute(
      "type",
      "password",
    );

    await expect(page.getByText("Confirm Password")).toBeVisible();
    await expect(profilePage.confirmPasswordInput).toBeVisible();
    await expect(profilePage.confirmPasswordInput).toHaveAttribute(
      "type",
      "password",
    );

    await expect(profilePage.confirmSubmitButton).toBeVisible();
    await expect(profilePage.confirmSubmitButton).toBeDisabled();
  });

  test("should show a mismatch error when confirm password does not match", async ({
    page,
  }) => {
    const profilePage = new ProfilePage(page);

    await profilePage.changePasswordButton.click();
    await profilePage.oldPasswordInput.fill(PLAYWRIGHT_PASSWORD);
    await profilePage.newPasswordInput.fill(STRONG_NEW_PASSWORD);
    await profilePage.confirmPasswordInput.fill(`${STRONG_NEW_PASSWORD}_diff`);
    await profilePage.confirmPasswordInput.press("Tab");

    await expect(profilePage.passwordMismatchError).toBeVisible({
      timeout: 5000,
    });
  });

  test("should change password successfully and log the user out", async ({
    page,
  }) => {
    test.setTimeout(60000);
    const profilePage = new ProfilePage(page);
    const signInPage = new SignInPage(page);

    await page.route(/\/user\/change_password(\?|$)/, async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({}),
      });
    });

    await profilePage.changePasswordButton.click();
    await profilePage.oldPasswordInput.fill(PLAYWRIGHT_PASSWORD);
    await profilePage.newPasswordInput.fill(STRONG_NEW_PASSWORD);
    await profilePage.confirmPasswordInput.fill(STRONG_NEW_PASSWORD);
    await profilePage.confirmSubmitButton.click();

    await expect(page).toHaveURL(/.*login/, { timeout: 15000 });
    await expect(signInPage.headerText).toContainText(
      "Hey there, Welcome back!",
    );
    await expect(
      page
        .locator("div")
        .filter({ hasText: /^Password Changed Successfully$/ })
        .nth(1),
    ).toBeVisible();
  });

  test("should surface the specific error when old password is wrong", async ({
    page,
  }) => {
    const profilePage = new ProfilePage(page);
    const wrongOldPasswordMessage = "Old password is incorrect";

    await page.route(/\/user\/change_password(\?|$)/, async (route) => {
      await route.fulfill({
        status: 400,
        contentType: "application/json",
        body: JSON.stringify({
          error: {
            code: "UR_06",
            message: wrongOldPasswordMessage,
            type: "invalid_request",
          },
        }),
      });
    });

    await profilePage.changePasswordButton.click();
    await profilePage.oldPasswordInput.fill("WrongOldPass00#");
    await profilePage.newPasswordInput.fill(STRONG_NEW_PASSWORD);
    await profilePage.confirmPasswordInput.fill(STRONG_NEW_PASSWORD);
    await profilePage.confirmSubmitButton.click();

    await expect(
      profilePage.toastByMessage(wrongOldPasswordMessage),
    ).toBeVisible({ timeout: 10000 });
    await expect(profilePage.changePasswordModalHeader).toBeHidden();
  });

  test("should show generic failure toast when the API errors with a different code", async ({
    page,
  }) => {
    const profilePage = new ProfilePage(page);

    await page.route(/\/user\/change_password(\?|$)/, async (route) => {
      await route.fulfill({
        status: 500,
        contentType: "application/json",
        body: JSON.stringify({
          error: {
            code: "IR_00",
            message: "Internal server error",
            type: "server_error",
          },
        }),
      });
    });

    await profilePage.changePasswordButton.click();
    await profilePage.oldPasswordInput.fill(PLAYWRIGHT_PASSWORD);
    await profilePage.newPasswordInput.fill(STRONG_NEW_PASSWORD);
    await profilePage.confirmPasswordInput.fill(STRONG_NEW_PASSWORD);
    await profilePage.confirmSubmitButton.click();

    await expect(profilePage.passwordChangeFailedToast).toBeVisible({
      timeout: 10000,
    });
    await expect(profilePage.changePasswordModalHeader).toBeHidden();
  });
});

test.describe("Profile Settings - Reset Password", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.email = true;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    const profilePage = new ProfilePage(page);
    await profilePage.visit();
    await page.waitForLoadState("networkidle");
  });

  test("should show the Reset Password button", async ({ page }) => {
    const profilePage = new ProfilePage(page);

    // The button is gated on the `email` feature flag, which propagates through
    // the Recoil atom after the config endpoint is (re)fetched; allow the same
    // 10s the rest of this suite uses for flag-dependent assertions.
    await expect(profilePage.resetPasswordButton).toBeVisible({
      timeout: 10000,
    });
  });

  test("should show a success toast when Reset Password is clicked", async ({
    page,
  }) => {
    const profilePage = new ProfilePage(page);

    await page.route(/\/user\/forgot_password(\?|$)/, async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({}),
      });
    });

    await profilePage.resetPasswordButton.click();

    await expect(
      profilePage.toastByMessage("Please check your registered e-mail"),
    ).toBeVisible({ timeout: 10000 });
  });
});

test.describe("Profile - Two Factor Authentication - TOTP", () => {
  let totpSecret = "";
  let currentEmail = "";
  let recoveryCodes: string[] = [];

  test.beforeEach(async ({ page }) => {
    totpSecret = "";
    recoveryCodes = [];
    currentEmail = generateUniqueEmail();
    const email = currentEmail;
    const signinPage = new SignInPage(page);

    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.goto("/");
    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);

    await page.route("**/2fa/totp/begin", async (route) => {
      const response = await route.fetch();
      // On the initial setup call body.secret holds the TOTP secret; on
      // subsequent calls (e.g. re-signin after 2FA is already enabled) the
      // backend returns { secret: null } — guard against that so the route
      // still fulfills and the page doesn't hang.
      const body = await response.json().catch(() => ({}));
      if (body?.secret?.secret) {
        totpSecret = body.secret.secret;
      }
      await route.fulfill({ response });
    });

    const responsePromise = page.waitForResponse("**/2fa/totp/begin");
    await signinPage.signinButton.click();
    await responsePromise;

    await expect(signinPage.qrCode2FA).toBeVisible();

    // TOTP codes are valid for a 30s window. If the current window is about
    // to close, fill + network latency can push the submit into the next
    // window and the server rejects the code. Wait for a fresh window when
    // we're near the boundary.
    if (authenticator.timeRemaining() < 5) {
      await page.waitForTimeout((authenticator.timeRemaining() + 1) * 1000);
    }
    const token = authenticator.generate(totpSecret);

    await signinPage.fillOTP(token);
    await signinPage.enable2FA.click();

    await expect(signinPage.downloadRecoveryCodes).toBeVisible({
      timeout: 10000,
    });
    // allInnerTexts() does not auto-wait, so the recovery-code <p> elements can
    // still be unpopulated the instant the download button becomes visible.
    // Poll until the codes are actually captured.
    await expect(async () => {
      recoveryCodes = (
        await signinPage.recoveryCodesMask.locator("p").allInnerTexts()
      )
        .map((c) => c.trim())
        .filter((c) => c.length > 0);
      expect(recoveryCodes.length).toBeGreaterThan(0);
    }).toPass({ timeout: 10000 });
    await signinPage.downloadRecoveryCodes.click();

    await expect(page).toHaveURL(/.*dashboard\/home/);
    const profilePage = new ProfilePage(page);
    await profilePage.visit();
    await page.waitForLoadState("networkidle");
  });

  test("should render a 2FA options when 2FA is enabled", async ({ page }) => {
    // The 2FA section is gated on `isTwoFactorAuthSetup` from the resolved
    // user-info context, which is refetched after navigating to the profile;
    // allow the same 10s the rest of this suite uses for async-gated renders.
    await expect(
      page.locator("div").filter({ hasText: /^Two factor authentication$/ }),
    ).toBeVisible({ timeout: 10000 });
    await expect(
      page.getByText(
        "Change app / deviceReset TOTP to regain access if you've changed or lost your device.",
      ),
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Edit" }).first(),
    ).toBeVisible();
    await expect(
      page.getByText(
        "Regenerate recovery codesRegenerate your access code to ensure continued access and security for your account.",
      ),
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Edit" }).nth(1),
    ).toBeVisible();
  });

  test("should not prompt for current TOTP when TOTP is filled during login", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.getByRole("button", { name: "Edit" }).first().click();

    await expect(page.getByText("Reset totp").first()).toBeVisible();
    await expect(page.getByText("Profile/Reset totp")).toBeVisible();
    await expect(page.getByText("Enable new 2FA")).toBeVisible();
    await expect(
      page.getByText(
        "Follow these steps to configure 2FA:1Scan the QR code with your authenticator",
      ),
    ).toBeVisible();
    await expect(
      page.getByText("2Enter the 6-digit code shown in your app below"),
    ).toBeVisible();
    await expect(signinPage.qrCode2FA).toBeVisible({ timeout: 10000 });
    await expect(page.getByText("Then, Enter a 6-digit code")).toBeVisible();
    await expect(
      page.locator(".flex.flex-col.justify-center.items-center.gap-4"),
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Verify new OTP" }),
    ).toBeVisible();
  });

  test("should prompt for TOTP when user skips 2FA during signin", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const signInPage = new SignInPage(page);

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await expect(page).toHaveURL(/.*login/);
    await expect(signInPage.headerText).toContainText(
      "Hey there, Welcome back!",
    );

    await signInPage.login(currentEmail, PLAYWRIGHT_PASSWORD);
    await page.waitForTimeout(3000);

    await signInPage.skip2FAButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/);

    const profilePage = new ProfilePage(page);
    await profilePage.visit();
    await page.waitForLoadState("networkidle");

    await page.getByRole("button", { name: "Edit" }).first().click();
    await expect(page.getByText("Verify OTP").first()).toBeVisible();
    await expect(page.getByText("Didn't get a code? Use")).toBeVisible();

    // Reset TOTP flow re-prompts for the current code. Reuse the secret
    // captured in beforeEach to mint a fresh token; guard against the 30s
    // window boundary the same way as setup.
    if (authenticator.timeRemaining() < 5) {
      await page.waitForTimeout((authenticator.timeRemaining() + 1) * 1000);
    }
    const token = authenticator.generate(totpSecret);
    await signInPage.fillOTP(token);
    await page.getByRole("button", { name: "Verify OTP" }).click();

    await expect(signInPage.qrCode2FA).toBeVisible({ timeout: 10000 });
  });

  test("should scan the QR code and enter new OTP to reset TOTP", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    let newSecret = "";
    await page.route("**/2fa/totp/reset", async (route) => {
      const response = await route.fetch();
      const body = await response
        .json()
        .catch(() => ({}) as { secret?: { totp_url?: string } });
      const totpUrl: string = body?.secret?.totp_url ?? "";
      const match = totpUrl.match(/[?&]secret=([^&]+)/);
      if (match) {
        newSecret = decodeURIComponent(match[1]);
      }
      await route.fulfill({ response });
    });

    await page.getByRole("button", { name: "Edit" }).first().click();

    await expect(signinPage.qrCode2FA).toBeVisible({ timeout: 10000 });
    await expect.poll(() => newSecret, { timeout: 10000 }).not.toBe("");

    if (authenticator.timeRemaining() < 5) {
      await page.waitForTimeout((authenticator.timeRemaining() + 1) * 1000);
    }
    const token = authenticator.generate(newSecret);
    await signinPage.fillOTP(token);

    await page.getByRole("button", { name: "Verify new OTP" }).click();

    await expect(page.getByText("Successfully reset TOTP!")).toBeVisible({
      timeout: 10000,
    });

    // Sign out, then sign back in using the new TOTP secret and verify we
    // land on the dashboard home.
    const homePage = new HomePage(page);
    await homePage.userAccount.click();
    await homePage.signOut.click();

    await expect(page).toHaveURL(/.*login/);

    await signinPage.login(currentEmail, PLAYWRIGHT_PASSWORD);

    await expect(signinPage.verifyOTPButton).toBeVisible({ timeout: 10000 });

    if (authenticator.timeRemaining() < 5) {
      await page.waitForTimeout((authenticator.timeRemaining() + 1) * 1000);
    }
    const loginToken = authenticator.generate(newSecret);
    await signinPage.fillOTP(loginToken);
    await signinPage.verifyOTPButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/, { timeout: 15000 });
  });

  test("should show error and allow retry when verifying a wrong OTP in Reset TOTP flow", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.getByRole("button", { name: "Edit" }).first().click();

    await expect(signinPage.qrCode2FA).toBeVisible({ timeout: 10000 });

    await signinPage.fillOTP("000000");
    await page.getByRole("button", { name: "Verify new OTP" }).click();
    await expect(
      page
        .locator("div")
        .filter({ hasText: /^Invalid TOTP$/ })
        .nth(1),
    ).toBeVisible({ timeout: 10000 });
    await expect(signinPage.qrCode2FA).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Verify new OTP" }),
    ).toBeVisible();
  });

  test("should reset TOTP using a stored recovery code after skipping 2FA at signin", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const signInPage = new SignInPage(page);

    expect(recoveryCodes.length).toBeGreaterThan(0);

    // Capture the new TOTP secret that /2fa/totp/reset returns when the user
    // clicks "Regenerate QR" later in the test — it carries an otpauth URL
    // at body.secret.totp_url; pull the `secret` query param out of it.
    let newSecret = "";
    await page.route("**/2fa/totp/reset", async (route) => {
      const response = await route.fetch();
      const body = await response
        .json()
        .catch(() => ({}) as { secret?: { totp_url?: string } });
      const totpUrl: string = body?.secret?.totp_url ?? "";
      const match = totpUrl.match(/[?&]secret=([^&]+)/);
      if (match) {
        newSecret = decodeURIComponent(match[1]);
      }
      await route.fulfill({ response });
    });

    await homePage.userAccount.click();
    await homePage.signOut.click();
    await expect(page).toHaveURL(/.*login/);

    await signInPage.login(currentEmail, PLAYWRIGHT_PASSWORD);
    await page.waitForTimeout(3000);
    await signInPage.skip2FAButton.click();
    await expect(page).toHaveURL(/.*dashboard\/home/);

    const profilePage = new ProfilePage(page);
    await profilePage.visit();
    await page.waitForLoadState("networkidle");

    await page.getByRole("button", { name: "Edit" }).first().click();
    await expect(page.getByText("Verify OTP").first()).toBeVisible();

    await page.getByText("Use recovery-code").click();
    await expect(
      page.locator('input[name="recovery_code_input"]'),
    ).toBeVisible();

    await page
      .locator('input[name="recovery_code_input"]')
      .fill(recoveryCodes[0]);
    await page.getByRole("button", { name: "Verify recovery code" }).click();

    await expect(
      page.getByText("Verify recovery code").first(),
    ).not.toBeVisible();
    await expect(page.locator("path").nth(1)).toBeVisible();

    await expect(
      page.locator(".flex.flex-col.justify-center.items-center.gap-4"),
    ).not.toBeVisible();
    await expect(
      page.getByRole("button", { name: "Regenerate QR" }),
    ).toBeVisible();

    await page.getByRole("button", { name: "Regenerate QR" }).click();

    await expect(signInPage.qrCode2FA).toBeVisible({ timeout: 15000 });
    await expect(
      page.locator(".flex.flex-col.justify-center.items-center.gap-4"),
    ).toBeVisible();

    // Scan the new QR — the /reset interceptor above has populated newSecret
    // from the response that drove this QR render. Mint a fresh token with
    // the 30s-window guard and submit "Verify new OTP".
    await expect.poll(() => newSecret, { timeout: 10000 }).not.toBe("");

    if (authenticator.timeRemaining() < 5) {
      await page.waitForTimeout((authenticator.timeRemaining() + 1) * 1000);
    }
    const verifyToken = authenticator.generate(newSecret);
    await signInPage.fillOTP(verifyToken);
    await page.getByRole("button", { name: "Verify new OTP" }).click();

    await expect(page.getByText("Successfully reset TOTP!")).toBeVisible({
      timeout: 10000,
    });

    // Logout and sign in again using the new TOTP secret to confirm the
    // server now authenticates against the freshly reset credential.
    await homePage.userAccount.click();
    await homePage.signOut.click();
    await expect(page).toHaveURL(/.*login/);

    await signInPage.login(currentEmail, PLAYWRIGHT_PASSWORD);

    await expect(signInPage.verifyOTPButton).toBeVisible({ timeout: 10000 });

    if (authenticator.timeRemaining() < 5) {
      await page.waitForTimeout((authenticator.timeRemaining() + 1) * 1000);
    }
    const loginToken = authenticator.generate(newSecret);
    await signInPage.fillOTP(loginToken);
    await signInPage.verifyOTPButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/, { timeout: 15000 });
  });

  test("should show error when entering a wrong recovery code after skipping 2FA at signin", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const signInPage = new SignInPage(page);

    await homePage.userAccount.click();
    await homePage.signOut.click();
    await expect(page).toHaveURL(/.*login/);

    await signInPage.login(currentEmail, PLAYWRIGHT_PASSWORD);
    await page.waitForTimeout(3000);
    await signInPage.skip2FAButton.click();
    await expect(page).toHaveURL(/.*dashboard\/home/);

    const profilePage = new ProfilePage(page);
    await profilePage.visit();
    await page.waitForLoadState("networkidle");

    await page.getByRole("button", { name: "Edit" }).first().click();
    await expect(page.getByText("Verify OTP").first()).toBeVisible();

    await page.getByText("Use recovery-code").click();
    await expect(
      page.locator('input[name="recovery_code_input"]'),
    ).toBeVisible();

    await page.locator('input[name="recovery_code_input"]').fill("ABCD-1234");
    await page.getByRole("button", { name: "Verify recovery code" }).click();

    // verifyRecoveryCode error path (ResetTotp.res:168-180) clears the input
    // and sets errorMessage, which TwoFaHelper renders as "Error: <message>"
    // inside the (still visible) verify modal. User can retry.
    await expect(page.getByText(/^Error: /).first()).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.locator('input[name="recovery_code_input"]'),
    ).toBeVisible();
    await expect(
      page.getByRole("button", { name: "Verify recovery code" }),
    ).toBeVisible();
  });
});

test.describe("Profile - Two Factor Authentication - Recovery codes", () => {
  let totpSecret = "";
  let currentEmail = "";

  test.beforeEach(async ({ page }) => {
    totpSecret = "";
    currentEmail = generateUniqueEmail();
    const email = currentEmail;
    const signinPage = new SignInPage(page);

    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.goto("/");
    await signinPage.emailInput.fill(email);
    await signinPage.passwordInput.fill(PLAYWRIGHT_PASSWORD);

    await page.route("**/2fa/totp/begin", async (route) => {
      const response = await route.fetch();
      const body = await response.json().catch(() => ({}));
      if (body?.secret?.secret) {
        totpSecret = body.secret.secret;
      }
      await route.fulfill({ response });
    });

    const responsePromise = page.waitForResponse("**/2fa/totp/begin");
    await signinPage.signinButton.click();
    await responsePromise;

    await expect(signinPage.qrCode2FA).toBeVisible();

    if (authenticator.timeRemaining() < 5) {
      await page.waitForTimeout((authenticator.timeRemaining() + 1) * 1000);
    }
    await signinPage.fillOTP(authenticator.generate(totpSecret));
    await signinPage.enable2FA.click();

    await expect(signinPage.downloadRecoveryCodes).toBeVisible({
      timeout: 10000,
    });
    await signinPage.downloadRecoveryCodes.click();

    await expect(page).toHaveURL(/.*dashboard\/home/);
    const profilePage = new ProfilePage(page);
    await profilePage.visit();
    await page.waitForLoadState("networkidle");
  });

  test("should display, regenerate, and download fresh recovery codes", async ({
    page,
  }) => {
    const signinPage = new SignInPage(page);

    await page.getByRole("button", { name: "Edit" }).nth(1).click();

    await expect(page).toHaveURL(
      /.*\/account-settings\/profile\/2fa\?type=regenerate_recovery_code/,
    );
    await expect(
      page.getByText("Two factor recovery codes", { exact: true }),
    ).toBeVisible({ timeout: 10000 });
    await expect(
      page.getByText(
        "Recovery codes provide a way to access your account if you lose your device and can't receive two-factor authentication codes.",
      ),
    ).toBeVisible();
    await expect(
      page.getByText(
        "These codes are the last resort for accessing your account in case you lose your password and second factors. If you cannot find these codes, you will lose access to your account.",
      ),
    ).toBeVisible();
    await expect(signinPage.recoveryCodesMask).toBeVisible();
    await expect(page.getByRole("button", { name: "Copy" })).toBeVisible();
    await expect(page.getByRole("button", { name: "Download" })).toBeVisible();

    const firstCodes = (await signinPage.recoveryCodesMask.innerText()).trim();

    await page.getByRole("button", { name: "Download" }).click();
    await expect(
      page
        .locator('[data-toast="Successfully regenerated new recovery codes!"]')
        .first(),
    ).toBeVisible({ timeout: 10000 });
    await expect(page).toHaveURL(/.*\/account-settings\/profile(\?.*)?$/);

    await page.getByRole("button", { name: "Edit" }).nth(1).click();
    await expect(signinPage.recoveryCodesMask).toBeVisible({ timeout: 10000 });
    await expect
      .poll(
        async () => (await signinPage.recoveryCodesMask.innerText()).trim(),
        { timeout: 10000 },
      )
      .not.toBe(firstCodes);
  });

  test("should prompt for TOTP when accessing recovery codes after skipping 2FA during signin", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const signinPage = new SignInPage(page);

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await expect(page).toHaveURL(/.*login/);
    await expect(signinPage.headerText).toContainText(
      "Hey there, Welcome back!",
    );

    await signinPage.login(currentEmail, PLAYWRIGHT_PASSWORD);
    await page.waitForTimeout(3000);

    await signinPage.skip2FAButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/);

    const profilePage = new ProfilePage(page);
    await profilePage.visit();
    await page.waitForLoadState("networkidle");

    // Regenerate Recovery Codes path: when totp.isCompleted is false (skipped
    // at login), RegenerateRC.res:126-128 shows the verify modal first
    // instead of auto-calling /generate_recovery_codes.
    await page.getByRole("button", { name: "Edit" }).nth(1).click();
    await expect(page.getByText("Verify OTP").first()).toBeVisible();

    if (authenticator.timeRemaining() < 5) {
      await page.waitForTimeout((authenticator.timeRemaining() + 1) * 1000);
    }
    const token = authenticator.generate(totpSecret);
    await signinPage.fillOTP(token);
    await page.getByRole("button", { name: "Verify OTP" }).click();

    await expect(page.getByText("Verify OTP")).not.toBeVisible();

    await expect(
      page.getByText("Two factor recovery codes", { exact: true }),
    ).toBeVisible({ timeout: 10000 });
    await expect(signinPage.recoveryCodesMask).toBeVisible();
  });
});
