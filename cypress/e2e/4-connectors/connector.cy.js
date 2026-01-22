import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";
import PaymentConnector from "../../support/pages/connector/PaymentConnector";
import { connectorConfig } from "../../fixtures/connectorConfig";

const homePage = new HomePage();
const paymentConnector = new PaymentConnector();

describe("connector", () => {
  beforeEach(() => {
    const email = helper.generateUniqueEmail();
    cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));
    cy.login_UI(email, Cypress.env("CYPRESS_PASSWORD"));
  });

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
      timeout: 5000,
    }).click();
    paymentConnector.connectorSetupDone.click();
    cy.url().should("include", "/dashboard/connectors");
    cy.contains("stripe_test_default").should("be.visible");
  });

  //Setup connector, select payment methods, then assert details page (creds and selected methods) after creation
});

describe("Test live connectors", () => {
  let email;
  const password = Cypress.env("CYPRESS_PASSWORD");

  const createSession = () => {
    cy.visit("/");
    cy.signup_API(email, password);
    cy.login_UI(email, password);
  };

  before(() => {
    email = helper.generateUniqueEmail();
    cy.session(`logged-in-user-${email}`, createSession);
  });

  beforeEach(() => {
    cy.session(`logged-in-user-${email}`, createSession);
    cy.visit("/dashboard/connectors");
  });

  Object.values(connectorConfig).forEach((connector) => {
    it.only(`should setup and verify ${connector.label} connector`, () => {
      paymentConnector.connectorSearchInput.type(connector.label);
      paymentConnector.addConnectButton.click();

      cy.assertConnectorFieldLabels(connector.fields.fieldLabels);
      cy.fillConnectorFields(connector.fields);

      paymentConnector.connectAndProceedButton.click();

      cy.assertPaymentMethodTypes(connector.paymentSections);

      paymentConnector.PMTproceedButton.click();
      paymentConnector.connectorSetupDone.click();

      cy.url().should("include", "/dashboard/connectors");
      cy.contains(connector.label).should("be.visible").click();
    });
  });
});
