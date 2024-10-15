import * as fixtures from "../../fixtures/imports";

describe("Payment Operations Page - Columns Customization and Functionalities", () => {
  const username = `cypress@gmail.com`;
  const password = "Cypress8#";

  beforeEach(() => {
    cy.signup_curl(username, password);
    cy.userLogin();
    cy.terminate2Fa();
    cy.userInfo();
    cy.createDummyConnector("payment_processor", fixtures.createConnectorBody);
    cy.makePayment(fixtures.makePaymentBody);
    cy.visit("http://localhost:9000/dashboard");
    cy.get('[data-testid="operations"]').click();
    cy.get('[data-testid="payments"]').click();
  });

  it("Should display all default columns and allow selecting/deselecting columns", () => {
    const columns = {
      expected: [
        "Merchant Order Reference Id",
        "Metadata",
        "Payment Status",
        "Payment Method Type",
        "Payment Method",
        "Payment ID",
        "Customer Email",
        "Description",
        "Created",
        "Connector Transaction ID",
        "Connector",
        "Amount",
        "AmountCapturable",
        "Authentication Type",
        "Profile Id",
        "Capture Method",
        "Client Secret",
        "Currency",
        "Customer ID",
        "Merchant ID",
        "Setup Future Usage",
        "Attempt count",
      ],
      optional: [
        "AmountCapturable",
        "Authentication Type",
        "Profile Id",
        "Capture Method",
        "Client Secret",
        "Currency",
        "Customer ID",
        "Merchant ID",
        "Setup Future Usage",
        "Attempt count",
      ],
      mandatory: [
        "Merchant Order Reference Id",
        "Metadata",
        "Payment Status",
        "Payment Method Type",
        "Payment Method",
        "Payment ID",
        "Customer Email",
        "Description",
        "Created",
        "Connector Transaction ID",
        "Connector",
        "Amount",
      ],
    };

    cy.get('button[data-button-for="CustomIcon"]').click();

    columns.expected.forEach((column) => {
      cy.contains(column).should("exist");
    });

    cy.get(
      '[data-component="modal:Table Columns"] [data-dropdown-numeric]',
    ).each(($el) => {
      cy.wrap($el).click();
    });

    cy.contains("button", "23 Columns Selected").should("be.visible");

    columns.optional.forEach((column) => {
      cy.get(`[data-dropdown-value="${column}"]`).click();
    });

    cy.contains("button", "13 Columns Selected").should("be.visible");

    cy.get(
      '[data-component="modal:Table Columns"] [data-icon="modal-close-icon"]',
    ).click();

    columns.mandatory.forEach((column) => {
      cy.get(`[data-table-heading="${column}"]`).should("exist");
    });

    columns.optional.forEach((column) => {
      cy.get(`[data-table-heading="${column}"]`).should("not.exist");
    });
  });

  it("Should display matching columns when searching for valid column names", () => {
    cy.visit("http://localhost:9000/Dashboard/payments");
    cy.get('button[data-button-for="CustomIcon"]').click();
    cy.get(".border > .rounded-md").should(
      "be.visible",
      "have.attr",
      "placeholder",
      "Search in 23 options",
    );

    // Search for valid column names
    ["Merchant", "Profile", "Payment"].forEach((searchTerm) => {
      cy.get('input[placeholder="Search in 23 options"]')
        .clear()
        .type(searchTerm);
      cy.contains(searchTerm).should("exist"); // Ensure matching results appear
    });
  });
});
