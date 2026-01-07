import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";

const homePage = new HomePage();

beforeEach(function () {
  const email = helper.generateUniqueEmail();
  cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));
  cy.login_UI(email, Cypress.env("CYPRESS_PASSWORD"));
});

describe("Homepage", () => {
  const getIframeBody = () => {
    return cy
      .get("iframe")
      .its("0.contentDocument.body")
      .should("not.be.empty")
      .then(cy.wrap);
  };

  it("should verify all components on homepage", () => {
    homePage.subHeaderText
      .should("be.visible")
      .and(
        "have.text",
        "Welcome to the home of your Payments Control Centre. It aims at providing your team with a 360-degree view of payments.",
      );

    homePage.orgIcon.should("be.visible");
    homePage.merchantDropdown.should("be.visible");
    homePage.profileDropdown.should("be.visible");

    homePage.orgChartIcon.should("be.visible");

    homePage.globalSearchInput.should("be.visible");

    homePage.productionAccessBanner
      .should("be.visible")
      .and("contain.text", "You're in Test ModeGet Production Access");

    // Assert integrate connector card
    homePage.integrateConnectorCard
      .should("be.visible")
      .and(
        "contain.text",
        "Integrate a ProcessorGive a headstart by connecting with more than 20+ gateways, payment methods, and networks.",
      );
    homePage.integrateConnectorCard
      .find('button[data-button-for="connectProcessors"]')
      .should("be.visible");

    // Assert Demo checkout card
    homePage.demoCheckoutCard
      .should("be.visible")
      .and(
        "contain.text",
        "Demo our checkout experienceTest your payment connector by initiating a transaction and visualize the user checkout experience",
      );
    homePage.demoCheckoutCard
      .find('button[data-button-for="tryItOut"]')
      .should("be.visible");
  });

  it("should navigate to connector list and API keys page.", () => {
    cy.get('[data-button-for="connectProcessors"]').click();
    cy.url().should("include", "/connectors");

    cy.get('[data-testid="overview"]').click();

    cy.get('[data-button-text="Go to API keys"]').click();
    cy.url().should("include", "/developer-api-keys");
  });

  it("should make a payment using SDK", () => {
    let merchant_id;
    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
        cy.get("[data-testid=connectors]").click();
        cy.get("[data-testid=paymentprocessors]").click();
        cy.contains("Payment Processors").should("be.visible");
        cy.get("[data-testid=overview]").first().click();
        cy.get("[data-button-for=tryItOut]").click();
        cy.get('[class="text-fs-28 font-semibold leading-10 "]').should(
          "contain",
          "Setup Checkout",
        );
        cy.get("[data-button-for=showPreview]").click();
        cy.wait(2000);
        getIframeBody()
          .find("[data-testid=cardNoInput]", { timeout: 20000 })
          .should("exist")
          .type("4242424242424242");
        getIframeBody()
          .find("[data-testid=expiryInput]")
          .should("exist")
          .type("0127");
        getIframeBody()
          .find("[data-testid=cvvInput]")
          .should("exist")
          .type("492");
        cy.get("[data-button-for=payUSD100]").should("exist").click();
        cy.contains("Payment Successful").should("exist");
      });
  });

  it("should verify sidebar menu navigation for orchestrator", () => {
    homePage.homeV2.should("be.visible").click();
    cy.url().should("include", "/dashboard/v2/home");

    cy.contains("MY MODULES").should("be.visible");

    cy.get('[data-testid="overview"]').should("be.visible").click();
    cy.url().should("include", "/dashboard/home");

    homePage.operations.should("be.visible").click();
    homePage.paymentOperations.should("be.visible").click();
    cy.url().should("include", "/dashboard/payments");
    homePage.refundOperations.should("be.visible").click();
    cy.url().should("include", "/dashboard/refunds");
    homePage.disputesOperations.should("be.visible").click();
    cy.url().should("include", "/dashboard/disputes");
    homePage.payoutsOperations.should("be.visible").click();
    cy.url().should("include", "/dashboard/payouts");
    homePage.customers.should("be.visible").click();
    cy.url().should("include", "/dashboard/customers");

    homePage.connectors.should("be.visible").click();
    homePage.paymentProcessors.should("be.visible").click();
    cy.url().should("include", "/dashboard/connectors");
    homePage.payoutConnectors.should("be.visible").click();
    cy.url().should("include", "/dashboard/payoutconnectors");
    homePage.threeDSConnectors.should("be.visible").click();
    cy.url().should("include", "/dashboard/3ds-authenticators");
    homePage.frmConnectors.should("be.visible").click();
    cy.url().should("include", "/dashboard/fraud-risk-management");
    homePage.pmAuthConnectors.should("be.visible").click();
    cy.url().should("include", "/dashboard/pm-authentication-processor");
    homePage.taxConnectors.should("be.visible").click();
    cy.url().should("include", "/dashboard/tax-processor");
    homePage.vaultConnectors.should("be.visible").click();
    cy.url().should("include", "/dashboard/vault-processor");

    homePage.analytics.should("be.visible").click();
    homePage.paymentsAnalytics.should("be.visible").click();
    cy.url().should("include", "/dashboard/analytics-payments");
    homePage.refundAnalytics.should("be.visible").click();
    cy.url().should("include", "/dashboard/analytics-refunds");

    homePage.workflow.should("be.visible").click();
    homePage.routing.should("be.visible").click();
    cy.url().should("include", "/dashboard/routing");
    homePage.surchargeRouting.should("be.visible").click();
    cy.url().should("include", "/dashboard/surcharge");
    homePage.threeDSRouting.should("be.visible").click();
    cy.url().should("include", "/dashboard/3ds");
    homePage.payoutRouting.should("be.visible").click();
    cy.url().should("include", "/dashboard/payoutrouting");

    homePage.developer.should("be.visible").click();
    homePage.paymentSettings.should("be.visible").click();
    cy.url().should("include", "/dashboard/payment-settings");
    homePage.apiKeys.should("be.visible").click();
    cy.url().should("include", "/dashboard/developer-api-keys");
    homePage.webhooks.should("be.visible").click();
    cy.url().should("include", "/dashboard/webhooks");

    homePage.settings.should("be.visible").click();
    homePage.configurePMT.should("be.visible").click();
    cy.url().should("include", "/dashboard/configure-pmts");
    homePage.users.should("be.visible").click();
    cy.url().should("include", "/dashboard/users");
  });
});
