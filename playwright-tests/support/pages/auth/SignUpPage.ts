import { Page, Locator } from "@playwright/test";

export class SignUpPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get headerText(): Locator {
    return this.page.locator('[data-testid="card-header"]');
  }

  get signInLink(): Locator {
    return this.page.locator('[data-testid="card-subtitle"]');
  }

  get emailInput(): Locator {
    return this.page.locator('[data-testid="email"]').first();
  }

  get passwordInput(): Locator {
    return this.page.locator('[data-testid="password"]').nth(1);
  }

  get signUpButton(): Locator {
    return this.page.locator('[data-testid="auth-submit-btn"]').nth(1);
  }

  get invalidInputError(): Locator {
    return this.page.locator("[data-form-error]");
  }

  get footerText(): Locator {
    return this.page.locator('[data-testid="card-foot-text"]');
  }

  async signup(email: string, password: string): Promise<void> {
    await this.page.goto("/register");
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.signUpButton.click();
  }
}

export default SignUpPage;
