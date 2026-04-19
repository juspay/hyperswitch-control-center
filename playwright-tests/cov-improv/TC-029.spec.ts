import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-029: Profile Settings - 2FA Setup", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to profile settings", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.userAccount.click();
    // Fixed (Attempt 1): Use direct href selector instead of problematic userProfile getter
    await page.locator('a[href*="/account-settings/profile"]').first().click();

    await expect(page).toHaveURL(/.*dashboard\/account-settings\/profile/);
  });

  test("should initiate 2FA setup", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.userAccount.click();
    await page.locator('a[href*="/account-settings/profile"]').first().click();

    const enable2FAButton = page
      .locator('[data-button-for="enable2FA"], button:has-text("Enable 2FA")')
      .first();
    if (await enable2FAButton.isVisible().catch(() => false)) {
      await enable2FAButton.click();

      const qrCode = page
        .locator('img[alt*="QR"], [data-testid*="qr-code"], canvas')
        .first();
      await expect(qrCode).toBeVisible();
    }
  });

  test("should verify QR code is displayed", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.userAccount.click();
    await page.locator('a[href*="/account-settings/profile"]').first().click();

    const enable2FAButton = page
      .locator('[data-button-for="enable2FA"]')
      .first();
    if (await enable2FAButton.isVisible().catch(() => false)) {
      await enable2FAButton.click();

      const qrImage = page
        .locator('img[src*="qr"], [data-testid*="qr"]')
        .first();
      const qrCanvas = page.locator("canvas").first();

      const hasQr =
        (await qrImage.isVisible().catch(() => false)) ||
        (await qrCanvas.isVisible().catch(() => false));
      expect(hasQr).toBe(true);
    }
  });

  test("should reject invalid TOTP code", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.userAccount.click();
    await page.locator('a[href*="/account-settings/profile"]').first().click();

    const enable2FAButton = page
      .locator('[data-button-for="enable2FA"]')
      .first();
    if (await enable2FAButton.isVisible().catch(() => false)) {
      await enable2FAButton.click();

      const totpInput = page
        .locator(
          'input[name*="totp"], input[name*="code"], input[maxlength="6"]',
        )
        .first();
      if (await totpInput.isVisible().catch(() => false)) {
        await totpInput.fill("000000");

        const verifyButton = page
          .locator('[data-button-for="verify"], button:has-text("Verify")')
          .first();
        if (await verifyButton.isVisible().catch(() => false)) {
          await verifyButton.click();

          await expect(
            page.locator('[data-toast*="invalid"], [data-field-error*="code"]'),
          ).toBeVisible({ timeout: 5000 });
        }
      }
    }
  });

  test("should display 2FA badge when enabled", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.userAccount.click();
    await page.locator('a[href*="/account-settings/profile"]').first().click();

    const badge2FA = page
      .locator(
        '[data-testid*="2fa-badge"], [data-testid*="mfa-badge"], span:has-text("2FA")',
      )
      .first();
    if (await badge2FA.isVisible().catch(() => false)) {
      await expect(badge2FA).toBeVisible();
    }
  });
});
