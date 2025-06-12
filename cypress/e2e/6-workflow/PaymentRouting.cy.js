import * as helper from "../../support/helper";
import SignInPage from "../../support/pages/auth/SignInPage";
import HomePage from "../../support/pages/homepage/HomePage";
import PaymentRouting from "../../support/pages/workflow/paymentRouting/PaymentRouting";
import DefaultFallback from "../../support/pages/workflow/paymentRouting/DefaultFallback";
import VolumeBasedConfiguration from "../../support/pages/workflow/paymentRouting/VolumeBasedConfiguration";

const signinPage = new SignInPage();
const homePage = new HomePage();
const paymentRouting = new PaymentRouting();
const defaultFallback = new DefaultFallback();
const volumeBasedConfiguration = new VolumeBasedConfiguration();

beforeEach(function () {
  const email = helper.generateUniqueEmail();
  cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));
  cy.login_UI(email, Cypress.env("CYPRESS_PASSWORD"));
});

describe("Volume based routing", () => {
  it("should display valid message when no connectors are connected", () => {
    homePage.workflow.click();
    homePage.routing.click();
    paymentRouting.volumeBasedRoutingSetupButton.click();
    cy.get('[class="px-3 text-fs-16"]').should(
      "contains.text",
      "Please configure at least 1 connector",
    );
  });

  it("should display all elements in volume based routing page", () => {
    let merchant_id;
    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
      });

    homePage.workflow.click();
    homePage.routing.click();
    paymentRouting.volumeBasedRoutingSetupButton.click();

    cy.url().should("include", "/routing/volume");

    //verify page header
    paymentRouting.volumeBasedRoutingHeader.should(
      "contain",
      "Smart routing configuration",
    );

    //verify selected profile
    homePage.profileDropdown.click();
    let profileID;
    homePage.profileDropdownList
      .children()
      .eq(1)
      .invoke("text")
      .then((text) => {
        profileID = text;
        let convertedStr = profileID.replace("pro", " (pro") + ")";
        cy.get(`[data-button-text="${convertedStr}"]`).should(
          "contain",
          convertedStr,
        );
      });

    // verify Configuration Name placeholder
    const currentDate = new Date();
    let formattedDate = currentDate.toISOString().split("T")[0];
    cy.get(`[placeholder="Enter Configuration Name"]`).should(
      "have.value",
      "Volume Based Routing-" + formattedDate,
    );

    // verify Description placeholder
    cy.get(`[name="description"]`).should(
      "contain",
      "This is a volume based routing created at",
    );

    // verify added connector in dropdown
    volumeBasedConfiguration.connectorDropdown.click();
    cy.get(`[value="stripe_test_1"]`).should("contain", "stripe_test_1");
  });

  it("should save new Volume based configuration", () => {
    let merchant_id;
    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
      });

    homePage.workflow.click();
    homePage.routing.click();
    paymentRouting.volumeBasedRoutingSetupButton.click();

    cy.url().should("include", "/routing/volume");

    cy.get(`[placeholder="Enter Configuration Name"]`)
      .clear()
      .type("Test volume based config");

    volumeBasedConfiguration.connectorDropdown.click();
    cy.get(`[value="stripe_test_1"]`).click();
    cy.get(`[data-button-for="configureRule"]`).click();
    cy.get(`[data-button-for="saveRule"]`).click();

    cy.get(`[data-toast="Successfully Created a new Configuration !"]`).should(
      "contain",
      "Successfully Created a new Configuration !",
    );

    cy.get(`[class="flex flex-col cursor-pointer w-max"]`).eq(1).click();

    cy.get(`[data-table-location="History_tr1_td2"]`).should(
      "contain",
      "Test volume based config",
    );
    cy.get(`[data-label="INACTIVE"]`).should("contain", "INACTIVE");
  });

  it("should save and activate Volume based configuration", () => {
    let merchant_id;
    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
      });

    homePage.workflow.click();
    homePage.routing.click();
    paymentRouting.volumeBasedRoutingSetupButton.click();

    cy.url().should("include", "/routing/volume");

    cy.get(`[placeholder="Enter Configuration Name"]`)
      .clear()
      .type("Test volume based config");

    volumeBasedConfiguration.connectorDropdown.click();
    cy.get(`[value="stripe_test_1"]`).click();
    cy.get(`[data-button-for="configureRule"]`).click();
    cy.get(`[data-button-for="saveAndActivateRule"]`).click();

    cy.get(`[data-toast="Successfully Created a new Configuration !"]`).should(
      "contain",
      "Successfully Created a new Configuration !",
    );

    cy.get(`[data-toast="Successfully Activated !"]`).should(
      "contain",
      "Successfully Activated !",
    );

    cy.get(`[class="flex flex-col gap-3"]`).should(
      "contain",
      "Test volume based config",
    );

    cy.get('[data-icon="check"]')
      .closest("div")
      .siblings("span")
      .should("have.text", "Active");
  });
});

describe("Rule based routing", () => {
  it("should display valid message when no connectors are connected", () => {
    homePage.workflow.click();
    homePage.routing.click();
    paymentRouting.ruleBasedRoutingSetupButton.click();
    cy.get('[class="px-3 text-fs-16"]').should(
      "contains.text",
      "Please configure at least 1 connector",
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
