/**
 * Auto-generated Cypress test
 * Source: PR #4355 - feat: Add Truelayer Connector in dashboard for Payments
 * Generated: 2026-03-17
 * This test was auto-generated and may need manual adjustments.
 */

import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";
import PaymentConnector from "../../support/pages/connector/PaymentConnector";

const homePage = new HomePage();
const paymentConnector = new PaymentConnector();

describe("Truelayer Connector - PR #4355", () => {
  beforeEach(function () {
    const email = helper.generateUniqueEmail();
    cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));
    cy.login_UI(email, Cypress.env("CYPRESS_PASSWORD"));
  });

  it("should verify Truelayer connector is available in payment processors list @connectors @org", () => {
    homePage.connectors.click();
    homePage.paymentProcessors.click();

    cy.contains("Payment Processors").should("be.visible");
    cy.contains("Connect a Dummy Processor").should("be.visible");

    paymentConnector.connectNowButton.click({ force: true });

    cy.get('[data-component="modal:Connect a Dummy Processor"]', {
      timeout: 10000,
    }).should("be.visible");

    // Verify Truelayer appears in the connector selection
    cy.get('[data-testid="truelayer"]').should("be.visible");
    cy.contains("Truelayer").should("be.visible");
  });

  it("should setup Truelayer connector with required credentials @connectors @org", () => {
    homePage.connectors.click();
    homePage.paymentProcessors.click();

    cy.contains("Payment Processors").should("be.visible");
    paymentConnector.connectNowButton.click({ force: true });

    cy.get('[data-component="modal:Connect a Dummy Processor"]', {
      timeout: 10000,
    }).should("be.visible");

    // Select Truelayer from the modal
    cy.get('[data-testid="truelayer"]', { timeout: 10000 })
      .should("be.visible")
      .find("button")
      .click({ force: true });

    // Verify navigation to connector setup page
    cy.url().should("include", "/dashboard/connectors");
    cy.contains("Credentials").should("be.visible");

    // Enter Truelayer credentials
    cy.get("[name=connector_account_details\\.api_key]")
      .should("be.visible")
      .clear()
      .type("truelayer_test_api_key");

    cy.get("[name=connector_label]")
      .should("be.visible")
      .clear()
      .type("truelayer_test_label");

    // Click connect and proceed
    paymentConnector.connectAndProceedButton.click();

    // Configure payment methods
    paymentConnector.PMTproceedButton.click();

    // Verify success toast
    cy.get('[data-toast="Connector Created Successfully!"]', {
      timeout: 10000,
    }).should("be.visible");

    // Click done button
    paymentConnector.connectorSetupDone.click();

    // Verify redirect back to connectors list
    cy.url().should("include", "/dashboard/connectors");

    // Verify the connector is listed
    cy.contains("truelayer_test_label").scrollIntoView().should("be.visible");
  });

  it("should verify Truelayer connector details after creation @connectors @org", () => {
    homePage.connectors.click();
    homePage.paymentProcessors.click();

    paymentConnector.connectNowButton.click({ force: true });

    cy.get('[data-testid="truelayer"]', { timeout: 10000 })
      .find("button")
      .click({ force: true });

    // Enter credentials and label
    cy.get("[name=connector_account_details\\.api_key]").type(
      "truelayer_api_key_test",
    );
    cy.get("[name=connector_label]").type("truelayer_details_test");

    // Proceed through setup
    paymentConnector.connectAndProceedButton.click();
    paymentConnector.PMTproceedButton.click();

    // Wait for success and complete
    cy.get('[data-toast="Connector Created Successfully!"]', {
      timeout: 10000,
    }).click();
    paymentConnector.connectorSetupDone.click();

    // Verify connector details are displayed
    cy.contains("truelayer_details_test").should("be.visible");

    // Click on connector to view details
    cy.contains("truelayer_details_test").click();

    // Verify connector name and type are displayed
    cy.contains("Truelayer").should("be.visible");
    cy.contains("Payment Processor").should("be.visible");
  });
});
