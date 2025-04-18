class SignInPage {
  get emailInput() {
    return cy.get('[data-testid="email"]');
  }

  get passwordInput() {
    return cy.get('[data-testid="password"]');
  }

  get signinButton() {
    return cy.get('[data-button-for="continue"]');
  }

  get signUpLink() {
    return cy.get("#card-subtitle");
  }

  get headerText() {
    return cy.get("#card-header");
  }

  get tcText() {
    return cy.get("#tc-text");
  }

  get footerText() {
    return cy.get("#footer");
  }

  get forgetPasswordLink() {
    return cy.get('[data-testid="forgot-password"]');
  }

  get emailSigninLink() {
    return cy.get('[data-testid="card-foot-text"]');
  }

  get invalidCredsToast() {
    return cy.get('[data-toast="Incorrect email or password"]');
  }

  // 2FA setup
  get headerText2FA() {
    return cy.get('[class="text-2xl font-semibold leading-8 text-grey-900"]');
  }

  get instructions2FA() {
    return cy.get('[class="flex flex-col gap-10 col-span-3"]');
  }

  get otpBox2FA() {
    return cy.get('[class="flex flex-col gap-4 items-center"]');
  }

  get skip2FAButton() {
    return cy.get('[data-testid="skip-now"]');
  }

  get enable2FA() {
    return cy.get('[data-button-for="enable2FA"]');
  }

  get footerText2FA() {
    return cy.get('[class="text-grey-200 flex gap-2"]');
  }

  //Forget password
  get forgetPasswordHeader() {
    return cy.get('[data-testid="card-header"]');
  }

  get resetPasswordButton() {
    return cy.get('[data-testid="auth-submit-btn"]').children().eq(1);
  }

  get cancelForgetPassword() {
    return cy.get('[data-testid="card-foot-text"]');
  }
}

export default SignInPage;
