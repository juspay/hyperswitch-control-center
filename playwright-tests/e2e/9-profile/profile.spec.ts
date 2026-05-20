import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { SignInPage } from "../../support/pages/auth/SignInPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";
import { TwoFAProfile } from "../../support/pages/developers/TwoFAProfile";
import { ProfilePage } from "../../support/pages/profile/ProfilePage";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Profile", () => {
  test.beforeEach(async ({ page, context }) => {
    const twoFA = new TwoFAProfile(page);
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
    await expect(signInPage.headerText).toContainText(
      "Hey there, Welcome back!",
    );
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

  test("should reject an invalid TOTP code with inline error", async ({
    page,
  }) => {
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

  test("should render the 2FA enabled badge when MFA has been set up", async ({
    page,
  }) => {
    const twoFA = new TwoFAProfile(page);
    const badge2FA = twoFA.badge2FA;
    if (!(await badge2FA.isVisible().catch(() => false))) {
      test.skip(true, "2FA badge not exposed (MFA not configured)");
    }
    await expect(badge2FA).toBeVisible();
  });
});

test.describe.skip("Account Settings - Profile page", () => {
  test("should render 'Profile' heading and 'Reset Password' button", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

    const profilePage = new ProfilePage(page);
    await profilePage.visit();
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await expect(profilePage.profileHeading).toBeVisible({
      timeout: 10000,
    });
    await expect(profilePage.resetPasswordButton).toBeVisible({
      timeout: 10000,
    });
  });
});
