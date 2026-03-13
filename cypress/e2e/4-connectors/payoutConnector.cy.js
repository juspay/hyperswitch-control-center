import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";
import PayoutConnector from "../../support/pages/connector/PayoutConnector";
import { payoutConnectorConfig } from "../../fixtures/payoutConnectorConfig";

const homePage = new HomePage();
const payoutConnector = new PayoutConnector();

describe("Payout connector setup", () => {
  let email;
  const password = Cypress.env("CYPRESS_PASSWORD");

  const createSession = () => {
    cy.visit("/");
    cy.signup_API(email, password);
    cy.login_UI(email, password);
  };

  before(() => {
    email = helper.generateUniqueEmail();
  });

  beforeEach(() => {
    cy.session(`logged-in-user-${email}`, createSession);
    cy.visit("/dashboard/payoutconnectors");
  });

  Object.values(payoutConnectorConfig).forEach((connector) => {
    it(`should setup and verify ${connector.label} payout connector`, () => {
      payoutConnector.pageHeading
        .should("contain", "Payout Processors")
        .should("be.visible");

      payoutConnector.connectorSearchInput.type(connector.label);
      payoutConnector.addConnectButton.eq(0).click();

      cy.assertConnectorFieldLabels(connector.fields.fieldLabels);
      cy.fillConnectorFields(connector.fields);

      payoutConnector.connectAndProceedButton.click();

      cy.assertPaymentMethodTypes(connector.paymentSections);

      payoutConnector.PMTproceedButton.click();
      payoutConnector.connectorSetupDone.click();

      cy.url().should("include", "/dashboard/payoutconnectors");
      cy.contains(connector.label).should("be.visible").click();
    });
  });
});
