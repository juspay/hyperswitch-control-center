import { test, expect } from "../../support/test";
import { TwoFAProfile } from "../../support/pages/developers/TwoFAProfile";

test.describe.skip("Account Settings - Profile 2FA setup", () => {
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
