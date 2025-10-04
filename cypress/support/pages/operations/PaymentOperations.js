class PaymentOperations {
  get transactionView() {
    return cy.get(
      `[class="grid lg:grid-cols-5 md:grid-cols-4 sm:grid-cols-3 grid-cols-2 gap-6 my-8"]`,
    );
  }

  get searchBox() {
    return cy.get(`[name="name"]`);
  }

  get dateSelector() {
    return cy.get(`[data-testid="date-range-selector"]`);
  }

  get viewDropdown() {
    return cy.get(`[class="flex h-fit rounded-lg hover:bg-opacity-80"]`);
  }

  get addFilters() {
    return cy.get(`[data-icon="plus"]`);
  }

  get generateReports() {
    return cy.get(`[data-button-for="generateReports"]`);
  }

  get columnButton() {
    return cy.get(`[data-button-for="CustomIcon"]`);
  }

  get paymentIdCopyButton() {
    return cy.get(`[class="fill-current cursor-pointer opacity-70 h-7 py-1"]`);
  }

  get paymentIdOpenNewTabButton() {
    return cy.get(`[data-icon="open-in-new-tab"]`);
  }

  get generateReportsTimeRangeDropdown() {
    return cy.get(`[data-testid="generate-reports-time-range"]`);
  }

  get generateReportsGenerateButton() {
    return cy.get(`[data-button-text="Generate"]`);
  }
}

export default PaymentOperations;
