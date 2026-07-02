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
    return this.page.locator('[data-element="right-slot"]');
  }

  get confirmButton(): Locator {
    return this.page.locator('[data-button-for="confirm"]');
  }

  get newPasswordField(): Locator {
    return this.page.getByRole('textbox', { name: 'Enter your Password', exact: true });
  }

  get confirmPasswordField(): Locator {
    return this.page.getByRole('textbox', { name: 'Re-enter your Password' });
  }

  get weakPasswordError(): Locator {
    return this.page.getByText("Your password is not strong");
  }
}

export default ResetPasswordPage;
