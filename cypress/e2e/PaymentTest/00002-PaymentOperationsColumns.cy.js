import * as fixtures from "../../fixtures/imports";
describe("Payment Operations Page - Columns Customization and Functionalities", () => {
  const password = "Cypress8#";
  const username = `cypress@gmail.com`;
  // Test Case 1: Verify customization of columns in Payments table
  describe("Customize Columns in Payments Table", () => {
    before(() => {
      // Pre-requisite steps: Login and navigate to "Payment Operations"
      cy.signup_curl(username, password);
      cy.userLogin();
      cy.terminate2Fa();
      cy.userInfo();

      cy.createDummyConnector(
        "payment_processor",
        fixtures.createConnectorBody,
      );
      cy.visit("http://localhost:9000/dashboard");
      cy.get('[data-testid="operations"]').click();
      cy.get('[data-testid="payments"]').click();
      cy.get('[data-test="customize-columns-button"]').click(); // Click on the Customize Columns button
    });

    it("Should display all default columns and allow selecting/deselecting columns", () => {
      // Verify the presence of all column names
      const expectedColumns = [
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
      ];

      expectedColumns.forEach((column) => {
        cy.contains(column).should("exist");
      });

      // Select all columns
      cy.get('[data-test="select-all-columns"]').click(); // Replace with actual selector to select all
      cy.get('[data-test="columns-selected-count"]').should(
        "contain",
        "22 Columns selected",
      );

      // Deselect optional columns
      const optionalColumns = [
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
      ];

      optionalColumns.forEach((column) => {
        cy.get(`[data-test="deselect-column-${column}"]`).click(); // Assuming individual deselect action
      });

      cy.get('[data-test="columns-selected-count"]').should(
        "contain",
        "12 Columns selected",
      );

      // Validate that only selected columns are visible in the table
      const mandatoryColumns = [
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
      ];

      cy.get('[data-test="payment-table"]').within(() => {
        mandatoryColumns.forEach((column) => {
          cy.contains(column).should("be.visible");
        });

        optionalColumns.forEach((column) => {
          cy.contains(column).should("not.exist");
        });
      });
    });
  });

  // Test Case 2: Search within the Customize Columns list
  describe.skip("Search Columns in Customize Columns List", () => {
    beforeEach(() => {
      cy.login_curl(username, password);
      //  cy.navigateToPaymentOperations();
      //
      cy.get('[data-test="customize-columns-button"]').click();
    });

    it("Should display matching columns when searching for valid column names", () => {
      cy.get('[data-test="column-search-input"]').should(
        "have.attr",
        "placeholder",
        "Search in 22 options",
      );

      // Search for valid column names
      ["Merchant", "Profile", "Payments"].forEach((searchTerm) => {
        cy.get('[data-test="column-search-input"]').clear().type(searchTerm);
        cy.contains(searchTerm).should("exist"); // Ensure matching results appear
      });
    });
  });

  // Test Case 3: Search invalid columns in Customize Columns list
  describe.skip("Search Invalid Columns in Customize Columns List", () => {
    beforeEach(() => {
      cy.login_curl(username, password);
      // cy.navigateToPaymentOperations();
      cy.get('[data-test="customize-columns-button"]').click();
    });

    it('Should show "No matching records found" when searching for invalid column names', () => {
      cy.get('[data-test="column-search-input"]').clear().type("abacd");
      cy.contains("No matching records found").should("be.visible");

      cy.get('[data-test="column-search-input"]').clear().type("something");
      cy.contains("No matching records found").should("be.visible");

      cy.get('[data-test="column-search-input"]').clear().type("createdAt");
      cy.contains("No matching records found").should("be.visible");

      // Clear search input by clicking the "X" button
      cy.get('[data-test="clear-search-input"]').click();
      cy.get('[data-test="column-list"]').children().should("have.length", 22); // All columns should reappear
    });
  });
});
