class ResetPasswordPage {
  get createPassword() {
    return cy.get('[name="create_password"]');
  }

  get confirmPassword() {
    return cy.get('[data-testid="comfirm_password"]');
  }

  get eyeIcon() {
    return cy.get('[data-icon="eye-slash"]');
  }

  get confirmButton() {
    return cy.get('[data-button-for="confirm"]');
  }
}
export default ResetPasswordPage;
