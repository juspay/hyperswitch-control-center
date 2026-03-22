import { Page, Locator } from "@playwright/test";

export class ResetPasswordPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get createPassword(): Locator {
    return this.page.locator('[name="create_password"]');
  }

  get confirmPassword(): Locator {
    return this.page.locator('[data-testid="comfirm_password"]').nth(1);
  }

  get eyeIcon(): Locator {
    return this.page.locator('[data-icon="eye-slash"]');
  }

  get confirmButton(): Locator {
    return this.page.locator('[data-button-for="confirm"]');
  }

  get newPasswordField(): Locator {
    return this.page.locator('[data-testid="create_password"]');
  }

  get confirmPasswordField(): Locator {
    return this.page.locator('[data-testid="comfirm_password"]');
  }
}

export default ResetPasswordPage;
