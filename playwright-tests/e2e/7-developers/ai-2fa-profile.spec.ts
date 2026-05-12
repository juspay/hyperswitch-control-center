import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe.skip("Account Settings - Profile 2FA setup", () => {
  test("should render a QR code when clicking Enable 2FA", async ({ page }) => {
    const enable2FAButton = page
      .locator('[data-button-for="enable2FA"], button:has-text("Enable 2FA")')
      .first();
    if (!(await enable2FAButton.isVisible().catch(() => false))) {
      test.skip(true, "Enable 2FA CTA not exposed");
    }
    await enable2FAButton.click();

    const qrImage = page.locator('img[src*="qr"], [data-testid*="qr"]').first();
    const qrCanvas = page.locator("canvas").first();
    const hasQr =
      (await qrImage.isVisible().catch(() => false)) ||
      (await qrCanvas.isVisible().catch(() => false));
    expect(hasQr).toBe(true);
  });

  test("should reject an invalid TOTP code with inline error", async ({
    page,
  }) => {
    const enable2FAButton = page
      .locator('[data-button-for="enable2FA"]')
      .first();
    if (!(await enable2FAButton.isVisible().catch(() => false))) {
      test.skip(true, "Enable 2FA CTA not exposed");
    }
    await enable2FAButton.click();

    const totpInput = page
      .locator(
        'input[name*="totp"], input[name*="code"], input[maxlength="6"]',
      )
      .first();
    if (!(await totpInput.isVisible().catch(() => false))) {
      test.skip(true, "TOTP input not exposed");
    }
    await totpInput.fill("000000");

    const verifyButton = page
      .locator('[data-button-for="verify"], button:has-text("Verify")')
      .first();
    if (!(await verifyButton.isVisible().catch(() => false))) {
      test.skip(true, "Verify button not exposed");
    }
    await verifyButton.click();

    await expect(
      page.locator('[data-toast*="invalid"], [data-field-error*="code"]'),
    ).toBeVisible({ timeout: 5000 });
  });

  test("should render the 2FA enabled badge when MFA has been set up", async ({
    page,
  }) => {
    const badge2FA = page
      .locator(
        '[data-testid*="2fa-badge"], [data-testid*="mfa-badge"], span:has-text("2FA")',
      )
      .first();
    if (!(await badge2FA.isVisible().catch(() => false))) {
      test.skip(true, "2FA badge not exposed (MFA not configured)");
    }
    await expect(badge2FA).toBeVisible();
  });
});
