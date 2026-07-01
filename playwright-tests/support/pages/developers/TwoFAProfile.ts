import { Page, Locator } from "@playwright/test";

export class TwoFAProfile {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get enable2FAButton(): Locator {
    return this.page
      .locator('[data-button-for="enable2FA"], button:has-text("Enable 2FA")')
      .first();
  }

  get enable2FAButtonByDataAttribute(): Locator {
    return this.page.locator('[data-button-for="enable2FA"]').first();
  }

  get qrImage(): Locator {
    return this.page.locator('img[src*="qr"], [data-testid*="qr"]').first();
  }

  get qrCanvas(): Locator {
    return this.page.locator("canvas").first();
  }

  get totpInput(): Locator {
    return this.page
      .locator('input[name*="totp"], input[name*="code"], input[maxlength="6"]')
      .first();
  }

  get verifyButton(): Locator {
    return this.page
      .locator('[data-button-for="verify"], button:has-text("Verify")')
      .first();
  }

  get invalidCodeError(): Locator {
    return this.page.locator(
      '[data-toast*="invalid"], [data-field-error*="code"]',
    );
  }

  get badge2FA(): Locator {
    return this.page
      .locator(
        '[data-testid*="2fa-badge"], [data-testid*="mfa-badge"], span:has-text("2FA")',
      )
      .first();
  }
}

export default TwoFAProfile;
