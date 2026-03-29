import { Page, Locator } from "@playwright/test";

export class SignInPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get emailInput(): Locator {
    return this.page.getByPlaceholder("Enter your Email");
  }

  get passwordInput(): Locator {
    return this.page.getByPlaceholder("Enter your Password");
  }

  get signinButton(): Locator {
    return this.page.locator('[data-button-for="continue"]');
  }

  get signUpLink(): Locator {
    return this.page.locator("#card-subtitle");
  }

  get headerText(): Locator {
    return this.page.locator("#card-header");
  }

  get tcText(): Locator {
    return this.page.locator("#tc-text");
  }

  get footerText(): Locator {
    return this.page.locator("#footer");
  }

  get forgetPasswordLink(): Locator {
    return this.page.locator('[data-testid="forgot-password"]');
  }

  get emailSigninLink(): Locator {
    return this.page.locator('[data-testid="card-foot-text"]');
  }

  get invalidCredsToast(): Locator {
    return this.page.locator('[data-toast="Incorrect email or password"]');
  }

  get continueWithOktaButton(): Locator {
    return this.page.locator('[data-button-for="continueWithOkta"]');
  }

  get headerText2FA(): Locator {
    return this.page.locator(
      '[class="text-fs-24 leading-32 font-semibold font-inter-style"]',
    );
  }

  get instructions2FA(): Locator {
    return this.page.locator('[class="flex flex-col gap-4"]');
  }

  get otpBoxHeader(): Locator {
    return this.page.locator('[class="flex items-center my-4"]');
  }

  get otpBox2FA(): Locator {
    return this.page.locator('[class="flex justify-center relative "]');
  }

  async fillOTP(otp: string): Promise<void> {
    const textboxes = this.page.getByRole("textbox");
    const count = await textboxes.count();
    for (let i = 0; i < otp.length && i < count; i++) {
      await textboxes.nth(i).fill(otp.charAt(i));
    }
  }

  get skip2FAButton(): Locator {
    return this.page.locator('[data-testid="skip-now"]');
  }

  get enable2FA(): Locator {
    return this.page.locator('[data-button-for="enterCode"]');
  }

  get footerText2FA(): Locator {
    return this.page.getByText("Log in with a different account?");
  }

  get logoutLink2FA(): Locator {
    return this.page.getByText("Click here to log out.");
  }

  get forgetPasswordHeader(): Locator {
    return this.page.locator('[data-testid="card-header"]');
  }

  get resetPasswordButton(): Locator {
    return this.page.locator('[data-button-for="resetPassword"]');
  }

  get cancelForgetPassword(): Locator {
    return this.page.locator('[data-testid="card-foot-text"]');
  }

  get oktaEmailInput(): Locator {
    return this.page.locator('[name="identifier"]');
  }

  get oktaNextButton(): Locator {
    return this.page.locator('[value="Next"]');
  }

  get oktaPasswordInput(): Locator {
    return this.page.locator('[type="password"]');
  }

  get oktaVerifyButton(): Locator {
    return this.page.locator('[value="Verify"]');
  }

  get oktaErrorMessage(): Locator {
    return this.page.locator('[role="alert"]');
  }

  async login(email: string, password: string): Promise<void> {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.signinButton.click();
  }

  async skip2FASetup(): Promise<void> {
    if (await this.skip2FAButton.isVisible().catch(() => false)) {
      await this.skip2FAButton.click();
    }
  }
}

export default SignInPage;
