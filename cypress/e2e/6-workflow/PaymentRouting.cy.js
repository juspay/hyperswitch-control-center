import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";
import PaymentRouting from "../../support/pages/workflow/paymentRouting/PaymentRouting";
import DefaultFallback from "../../support/pages/workflow/paymentRouting/DefaultFallback";

const homePage = new HomePage();
const paymentRouting = new PaymentRouting();
const defaultFallback = new DefaultFallback();

beforeEach(function () {
  const email = helper.generateUniqueEmail();
  cy.visit_signupPage();
  cy.sign_up_with_email(email, Cypress.env("CYPRESS_PASSWORD"));
  cy.url().should("include", "/dashboard/home");
  homePage.enterMerchantName.type("Test_merchant");
  homePage.onboardingSubmitButton.click();
});

describe("Volume based routing", () => {
  it("should display valid message when no connectors are connected", () => {
    homePage.workflow.click();
    homePage.routing.click();
    paymentRouting.volumeBasedRoutingSetupButton.click();
    cy.get('[class="px-3 text-fs-16"]').should(
      "contains.text",
      "Please configure atleast 1 connector",
    );
  });

  it("should display all elements in volume based routing page", () => {
    homePage.workflow.click();
    homePage.routing.click();
    paymentRouting.volumeBasedRoutingSetupButton.click();

    cy.url().should("include", "/routing/volume");

    paymentRouting.volumeBasedRoutingHeader.should(
      "contain",
      "Smart routing configuration",
    );

    homePage.profileDropdown.click();
    let profileID;
    homePage.profileDropdownList
      .children()
      .eq(1)
      .invoke("text")
      .then((text) => {
        profileID = text;
        let convertedStr = profileID.replace(" ", " (") + ")";
        cy.get(`[data-button-text="${convertedStr}"]`).should(
          "contain",
          convertedStr,
        );
      });

    //
  });
});

describe("Rule based routing", () => {
  it("should display valid message when no connectors are connected", () => {
    homePage.workflow.click();
    homePage.routing.click();
    paymentRouting.ruleBasedRoutingSetupButton.click();
    cy.get('[class="px-3 text-fs-16"]').should(
      "contains.text",
      "Please configure atleast 1 connector",
    );
  });
});

describe("Payment default fallback", () => {
  it("should display valid message when no connectors are connected", () => {
    homePage.workflow.click();
    homePage.routing.click();
    paymentRouting.defaultFallbackManageButton.click();
    cy.get('[class="px-3 text-2xl mt-32 "]').should(
      "contains.text",
      "Please connect atleast 1 connector",
    );
  });

  it("should display connected connectors in the list", () => {
    let merchant_id;
    cy.get('[style="overflow-wrap: anywhere;"]')
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
      });

    homePage.connectors.click();
    homePage.paymentProcessors.click();

    homePage.workflow.click();
    homePage.routing.click();
    paymentRouting.defaultFallbackManageButton.click();

    defaultFallback.defaultFallbackList
      .children()
      .eq(0)
      .should("contains.text", "stripe_test_1");
  });

  it.skip("should be able to change the order by dragging and updating", () => {
    let merchant_id;
    cy.get('[style="overflow-wrap: anywhere;"]')
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_2");
      });

    homePage.workflow.click();
    homePage.routing.click();
    paymentRouting.defaultFallbackManageButton.click();

    defaultFallback.defaultFallbackList
      .children()
      .eq(0)
      .should("contains.text", "stripe_test_1");

    defaultFallback.defaultFallbackList
      .children()
      .eq(1)
      .should("contains.text", "stripe_test_2");

    ///TODO: Add drag and drop functionality

    defaultFallback.defaultFallbackList
      .children()
      .eq(0)
      .should("contains.text", "stripe_test_2");

    defaultFallback.defaultFallbackList
      .children()
      .eq(1)
      .should("contains.text", "stripe_test_1");
  });
});
