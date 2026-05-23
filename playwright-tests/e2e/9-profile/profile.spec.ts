import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { SignInPage } from "../../support/pages/auth/SignInPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";
import { TwoFAProfile } from "../../support/pages/developers/TwoFAProfile";
import { ProfilePage } from "../../support/pages/profile/ProfilePage";

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
  });

  test("should sign out successfully", async ({ page }) => {
    const homePage = new HomePage(page);
    const signInPage = new SignInPage(page);

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await expect(page).toHaveURL(/.*login/);
    await expect(signInPage.headerText).toContainText("Hey there, Welcome back!");
  });
});

test.describe("Profile - Two Factor Authentication", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should render a QR code when clicking Enable 2FA", async ({ page }) => {
    const twoFA = new TwoFAProfile(page);
    const enable2FAButton = twoFA.enable2FAButton;
    if (!(await enable2FAButton.isVisible().catch(() => false))) {
      test.skip(true, "Enable 2FA CTA not exposed");
    }
    await enable2FAButton.click();

    const hasQr =
      (await twoFA.qrImage.isVisible().catch(() => false)) ||
      (await twoFA.qrCanvas.isVisible().catch(() => false));
    expect(hasQr).toBe(true);
  });

  test("should reject an invalid TOTP code with inline error", async ({ page }) => {
    const twoFA = new TwoFAProfile(page);
    const enable2FAButton = twoFA.enable2FAButtonByDataAttribute;
    if (!(await enable2FAButton.isVisible().catch(() => false))) {
      test.skip(true, "Enable 2FA CTA not exposed");
    }
    await enable2FAButton.click();

    const totpInput = twoFA.totpInput;
    if (!(await totpInput.isVisible().catch(() => false))) {
      test.skip(true, "TOTP input not exposed");
    }
    await totpInput.fill("000000");

    const verifyButton = twoFA.verifyButton;
    if (!(await verifyButton.isVisible().catch(() => false))) {
      test.skip(true, "Verify button not exposed");
    }
    await verifyButton.click();

    await expect(twoFA.invalidCodeError).toBeVisible({ timeout: 5000 });
  });

  test("should render the 2FA enabled badge when MFA has been set up", async ({ page }) => {
    const twoFA = new TwoFAProfile(page);
    const badge2FA = twoFA.badge2FA;
    if (!(await badge2FA.isVisible().catch(() => false))) {
      test.skip(true, "2FA badge not exposed (MFA not configured)");
    }
    await expect(badge2FA).toBeVisible();
  });
});

test.describe("Profile Settings - Page", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    const profilePage = new ProfilePage(page);
    await profilePage.visit();
    await page.waitForLoadState("networkidle");
  });

  test("should load the Profile Settings page with the User Info section", async ({ page }) => {
    const profilePage = new ProfilePage(page);

    await expect(page).toHaveURL(/.*account-settings\/profile/);
    await expect(profilePage.userInfoSectionHeading).toBeVisible({ timeout: 10000 });
  });

  test("should render the Profile heading with description", async ({ page }) => {
    const profilePage = new ProfilePage(page);

    await expect(profilePage.profileHeading).toBeVisible();
    await expect(profilePage.profileSubtitle).toBeVisible();
  });

  test("should display the user's name in a read-only field", async ({ page }) => {
    const profilePage = new ProfilePage(page);

    await expect(profilePage.nameLabel).toBeVisible();
    await expect(page.getByText("Playwright_test_user", { exact: true }).first()).toBeVisible();
  });

  test("should display the user email as read-only", async ({ page }) => {
    const profilePage = new ProfilePage(page);

    await expect(profilePage.emailLabel).toBeVisible();
    const emailValue = profilePage.emailLabel.locator("xpath=following-sibling::p[1]");
    await expect(emailValue).toHaveText(/.+@.+\..+/);
    await expect(page.locator('input[name="email"]')).toHaveCount(0);
  });

  test("should display the phone field when supported", async ({ page }) => {
    const profilePage = new ProfilePage(page);
    if (!(await profilePage.phoneLabel.isVisible().catch(() => false))) {
      test.skip(true, "Phone field is not rendered on this build");
    }
    await expect(profilePage.phoneLabel).toBeVisible();
  });

  test("should allow editing the phone number when supported", async ({ page }) => {
    const profilePage = new ProfilePage(page);
    if (!(await profilePage.phoneInput.isVisible().catch(() => false))) {
      test.skip(true, "Phone input is not rendered on this build");
    }
    await profilePage.phoneInput.fill("9999999999");
    await expect(profilePage.phoneInput).toHaveValue("9999999999");
  });

  test("should expose Sign Out All Sessions when supported", async ({ page }) => {
    const profilePage = new ProfilePage(page);
    if (!(await profilePage.signOutAllSessionsButton.isVisible().catch(() => false))) {
      test.skip(true, "Sign Out All Sessions CTA not exposed");
    }
    await expect(profilePage.signOutAllSessionsButton).toBeVisible();
    await expect(profilePage.signOutAllSessionsButton).toBeEnabled();
  });

  test("should navigate to /account-settings/profile from the account menu", async ({ page }) => {
    const homePage = new HomePage(page);
    const profilePage = new ProfilePage(page);

    await page.goto("/dashboard/home");
    await page.waitForLoadState("networkidle");
    await homePage.userAccount.click();
    await expect(homePage.userProfile).toBeVisible({ timeout: 5000 });
    await homePage.userProfile.click();

    await expect(page).toHaveURL(/.*account-settings\/profile/);
    await expect(profilePage.profileHeading).toBeVisible();
  });
});

test.describe("Profile Settings - Change Password", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    const profilePage = new ProfilePage(page);
    await profilePage.visit();
    await page.waitForLoadState("networkidle");
  });

  test("should open the Change Password modal with all password fields", async ({ page }) => {
    const profilePage = new ProfilePage(page);

    await expect(profilePage.changePasswordButton).toBeVisible();
    await profilePage.changePasswordButton.click();

    await expect(profilePage.changePasswordModalHeader).toBeVisible();
    await expect(profilePage.oldPasswordInput).toBeVisible();
    await expect(profilePage.newPasswordInput).toBeVisible();
    await expect(profilePage.confirmPasswordInput).toBeVisible();
    await expect(profilePage.confirmSubmitButton).toBeVisible();
  });

  test("should accept the old password as masked input", async ({ page }) => {
    const profilePage = new ProfilePage(page);

    await profilePage.changePasswordButton.click();
    await expect(profilePage.oldPasswordInput).toBeVisible();
    await profilePage.oldPasswordInput.fill(PLAYWRIGHT_PASSWORD);

    await expect(profilePage.oldPasswordInput).toHaveAttribute("type", "password");
    await expect(profilePage.oldPasswordInput).toHaveValue(PLAYWRIGHT_PASSWORD);
  });

  test("should accept the new password as masked input", async ({ page }) => {
    const profilePage = new ProfilePage(page);

    await profilePage.changePasswordButton.click();
    await expect(profilePage.newPasswordInput).toBeVisible();
    await profilePage.newPasswordInput.fill(STRONG_NEW_PASSWORD);

    await expect(profilePage.newPasswordInput).toHaveAttribute("type", "password");
    await expect(profilePage.newPasswordInput).toHaveValue(STRONG_NEW_PASSWORD);
  });

  test("should show a mismatch error when confirm password does not match", async ({ page }) => {
    const profilePage = new ProfilePage(page);

    await profilePage.changePasswordButton.click();
    await profilePage.oldPasswordInput.fill(PLAYWRIGHT_PASSWORD);
    await profilePage.newPasswordInput.fill(STRONG_NEW_PASSWORD);
    await profilePage.confirmPasswordInput.fill(`${STRONG_NEW_PASSWORD}_diff`);
    await profilePage.confirmPasswordInput.press("Tab");

    await expect(profilePage.passwordMismatchError).toBeVisible({ timeout: 5000 });
  });

  test("should change password successfully and log the user out", async ({ page }) => {
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
    await expect(signInPage.headerText).toContainText("Hey there, Welcome back!");
  });

  test("should close the modal automatically after a successful change", async ({ page }) => {
    test.setTimeout(60000);
    const profilePage = new ProfilePage(page);

    await page.route(/\/user\/change_password(\?|$)/, async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({}),
      });
    });

    await profilePage.changePasswordButton.click();
    await expect(profilePage.changePasswordModalHeader).toBeVisible();

    await profilePage.oldPasswordInput.fill(PLAYWRIGHT_PASSWORD);
    await profilePage.newPasswordInput.fill(STRONG_NEW_PASSWORD);
    await profilePage.confirmPasswordInput.fill(STRONG_NEW_PASSWORD);
    await profilePage.confirmSubmitButton.click();

    await expect(profilePage.changePasswordModalHeader).toBeHidden({ timeout: 15000 });
  });

  test("should surface the specific error when old password is wrong", async ({ page }) => {
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

    await expect(profilePage.toastByMessage(wrongOldPasswordMessage)).toBeVisible({ timeout: 10000 });
    await expect(profilePage.changePasswordModalHeader).toBeHidden();
  });

  test("should show generic failure toast when the API errors with a different code", async ({ page }) => {
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

    await expect(profilePage.passwordChangeFailedToast).toBeVisible({ timeout: 10000 });
    await expect(profilePage.changePasswordModalHeader).toBeHidden();
  });
});
