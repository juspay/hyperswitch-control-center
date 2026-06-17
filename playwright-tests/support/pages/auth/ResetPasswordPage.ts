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
    return this.page.locator('[placeholder="Re-enter your Password"]');
  }

  get eyeIcon(): Locator {
    return this.page.locator('[data-icon="eye"]');
  }

  get confirmButton(): Locator {
    return this.page.locator('[data-button-for="confirm"]');
  }

  get newPasswordField(): Locator {
    return this.page.locator('[data-testid="create_password"] input');
  }

  get confirmPasswordField(): Locator {
    return this.page.locator('[data-testid="confirm_password"] input');
  }

  get weakPasswordError(): Locator {
    return this.page.getByText("Your password is not strong");
  }
}

export default ResetPasswordPage;
