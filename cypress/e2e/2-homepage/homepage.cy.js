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
});
