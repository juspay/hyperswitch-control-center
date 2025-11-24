import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";
import PaymentConnector from "../../support/pages/connector/PaymentConnector";

const homePage = new HomePage();
const paymentConnector = new PaymentConnector();

beforeEach(function () {
  const email = helper.generateUniqueEmail();
  cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));
  cy.login_UI(email, Cypress.env("CYPRESS_PASSWORD"));
});

describe("connector", () => {
  it("should setup a dummy connector", () => {
    homePage.connectors.click();
    homePage.paymentProcessors.click();
    paymentConnector.pageHeading
      .should("contain", "Payment Processors")
      .should("be.visible");
    paymentConnector.pageBanner.should("contain", "Connect a Dummy Processor");
    paymentConnector.connectNowButton.click({ force: true });
    paymentConnector.stripeDummyConnector
      .should("be.visible")
      .find("button")
      .click({ force: true });
    cy.contains("Credentials").should("be.visible");
    cy.get("[name=connector_account_details\\.api_key]").should(
      "have.value",
      "test_key",
    );
    paymentConnector.connectAndProceedButton.click();
    paymentConnector.PMTproceedButton.click();
    cy.get('[data-toast="Connector Created Successfully!"]', {
      timeout: 10000,
    }).click();
    paymentConnector.connectorSetupDone.click();
    cy.url().should("include", "/dashboard/connectors");
    cy.contains("stripe_test_default").should("be.visible");
  });
});
