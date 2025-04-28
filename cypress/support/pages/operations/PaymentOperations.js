class PaymentOperations {
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

  get metricCards() {
    return cy.get(`[data-testid="metric-cards"]`);
  }
}

export default PaymentOperations;
