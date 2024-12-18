class SignUpPage {
  get headerText() {
    return cy.get('[data-testid="card-header"]');
  }

  get signInLink() {
    return cy.get('[data-testid="card-subtitle"]');
  }

  get emailInput() {
    return cy.get('[data-testid="email"]').children().first();
  }

  get passwordInput() {
    return cy.get('[data-testid="password"]').children().eq(1);
  }

  get signUpButton() {
    return cy.get('[data-testid="auth-submit-btn"]').children().eq(1);
  }

  get invalidInputError() {
    return cy.get("[data-form-error]");
  }

  get footerText() {
    return cy.get('[data-testid="card-foot-text"]');
  }

  signup(email, password) {
    cy.visit("/register");
    this.emailInput.type(email);
    this.passwordInput.type(password);
    this.signUpButton.click();
  }
}

export default SignUpPage;
