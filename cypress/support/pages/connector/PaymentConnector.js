class PaymentConnector {
  get pageHeading() {
    return cy.get('[class="text-fs-28 font-semibold leading-10 "]');
  }

  get pageBanner() {
    return cy.get('[class="flex flex-col gap-2.5"]');
  }

  get connectNowButton() {
    return cy.get('[data-button-for="connectNow"]');
  }

  get connectorSearchInput() {
    return cy.get('[data-testid="search-processor"]');
  }

  get stripeDummyConnector() {
    return cy.get('[data-testid="stripe_test"]');
  }

  get addConnectButton() {
    return cy.get('[data-button-text="Connect"]');
  }
  get connectAndProceedButton() {
    return cy.get("[data-button-for=connectAndProceed]");
  }

  get PMTproceedButton() {
    return cy.get("[data-button-for=proceed]");
  }

  get connectorSetupDone() {
    return cy.get("[data-button-for=done]");
  }
}

export default PaymentConnector;
