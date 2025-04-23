class ResetPasswordPage {
  get createPassword() {
    return cy.get('[name="create_password"]');
  }

  get confirmPassword() {
    return cy.get('[data-testid="comfirm_password"]').children().eq(1);
  }

  get eyeIcon() {
    return cy.get('[data-icon="eye-slash"]');
  }

  get confirmButton() {
    return cy.get('[data-button-for="confirm"]');
  }

  get newPasswordField() {
    return cy.get(`[data-testid="create_password"]`);
  }

  get confirmPasswordField() {
    return cy.get(`[data-testid="comfirm_password"]`);
  }
}
export default ResetPasswordPage;
