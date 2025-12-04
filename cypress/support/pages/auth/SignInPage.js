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

  get continueWithOktaButton() {
    return cy.get('[data-button-for="continueWithOkta"]');
  }

  // 2FA setup
  get headerText2FA() {
    return cy.get(
      '[class="text-fs-24 leading-32 font-semibold font-inter-style"]',
    );
  }

  get instructions2FA() {
    return cy.get('[class="flex flex-col gap-4"]');
  }

  get otpBoxHeader() {
    return cy.get('[class="flex items-center my-4"]');
  }

  get otpBox2FA() {
    return cy.get('[class="flex justify-center relative "]');
  }

  get skip2FAButton() {
    return cy.get('[data-testid="skip-now"]');
  }

  get enable2FA() {
    return cy.get('[data-button-for="enterCode"]');
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

  //Okta SSO
  get oktaEmailInput() {
    return cy.get('[name="identifier"]');
  }

  get oktaNextButton() {
    return cy.get('[value="Next"]');
  }

  get oktaPasswordInput() {
    return cy.get('[type="password"]');
  }

  get oktaVerifynButton() {
    return cy.get('[value="Verify"]');
  }

  get oktaErrorMessage() {
    return cy.get('[role="alert"]');
  }
}

export default SignInPage;
