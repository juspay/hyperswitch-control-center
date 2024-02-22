let username = `cypressprocessores+${Math.round(+new Date() / 1000)}@gmail.com`;
before(() => {
  cy.singup_curl(username, "cypress98#");
});
beforeEach(() => {
  cy.login_UI(username, "cypress98#");
});
describe("Processors Create Module", () => {
  it("should successfully create the paypal test processor", () => {
    cy.url().should("eq", "http://localhost:9000/home");
    cy.get("[data-testid=connectors]")
      .find(".justify-center")
      .click({ force: true });
    cy.get("[data-testid=paymentprocessors]").click({ force: true });

    cy.get("[data-testid=connect_a_test_processor]").contains(
      "Connect a test processor",
    );
    cy.get("[data-testid=paypal_test]").click({ force: true });
    cy.get('input[name="connector_account_details.api_key"]').clear();
    cy.get('input[name="connector_label"]').clear();

    cy.get('input[name="connector_account_details.api_key"]').type(
      "paypal_test_cypress_api_key",
    );
    cy.get('input[name="connector_label"]').type("paypal_test_cypress_label");
    cy.get("[data-button-for=connectAndProceed]").click({ force: true });
    cy.contains(
      "NOTE:Please verify if the payment methods are turned on at the processor end as well.",
    ).should("be.visible");
    cy.get("[data-testid=credit_mastercard]").click();
    cy.get("[data-testid=debit_select_all]")
      .children(".cursor-pointer")
      .click({ force: true });
    cy.get("[data-testid=wallet_paypal]").click();
    cy.get("[data-button-for=proceed]").click({ force: true });
    cy.get("[data-testid=connector_status]").should("contain", "ACTIVE");
    cy.get("[data-button-for=done]").click({ force: true });
    cy.get("[data-testid=table-search-filter]").type("VOLT");
    cy.get("[data-component=no-data-available]").should("exist");
    cy.get('input[name="search"]').clear();
    cy.get("[data-testid=table-search-filter]").type("paypal");
    cy.get("[data-table-heading=Processor]").should("exist");
  });

  it("should successfully delete the paypal test processor", () => {
    cy.intercept("/accounts/*").as("getAccount");
    cy.wait("@getAccount").then(() => {
      cy.get("[data-testid=connectors]")
        .find(".justify-center")
        .click({ force: true });
      cy.get("[data-testid=paymentprocessors]").click({ force: true });
      const targetValue = "PayPal Test";
      cy.get("table")
        .find("td")
        .each(($td) => {
          // Use .invoke('text') to get the text content of each td
          cy.wrap($td)
            .invoke("text")
            .then((text) => {
              // Check if the text content of the current td matches the target value
              if (text === targetValue) {
                // Perform actions/assertions on the found td
                cy.wrap($td)
                  .should("have.text", targetValue)
                  .click({ force: true });
              }
            });
        });

      cy.location("pathname").then((pathname) => {
        let mca_id = pathname.split("/")[2];
        cy.deleteConnector(mca_id);
        cy.visit("http://localhost:9000/connectors");
      });
    });
  });

  it("should successfully land in the process list page", () => {
    cy.get("[data-testid=connectors]")
      .find(".justify-center")
      .click({ force: true });
    cy.get("[data-testid=paymentprocessors]").click({ force: true });
    cy.url().should("eq", "http://localhost:9000/connectors");
    cy.contains("Processors").should("be.visible");
    cy.contains(
      "Connect and manage payment processors to enable payment acceptance",
    ).should("be.visible");
    cy.get("[data-testid=connect_a_new_processor]").contains(
      "Connect a new processor",
    );
    cy.get("[data-testid=search-processor]")
      .type("stripe", { force: true })
      .should("have.value", "stripe");
    cy.get("[data-testid=stripe]")
      .find("img")
      .should("have.attr", "src", "/Gateway/STRIPE.svg");
  });
});
