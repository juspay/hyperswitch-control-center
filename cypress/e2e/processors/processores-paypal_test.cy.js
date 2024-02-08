beforeEach(() => {
  cy.login_UI();
});
describe("Processors Create Module", () => {
  it("should successfully create the paypal test processor", () => {
    cy.get("[data-testid=processors]").click({ force: true });
    cy.url().should("eq", "http://localhost:9000/connectors");
    cy.get("[data-testid=connect_a_test_connector]").contains(
      "Connect a test connector",
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
  });

  it("should successfully delete the paypal test processor", () => {
    cy.intercept("/accounts/*").as("getAccount");
    cy.wait("@getAccount").then(() => {
      cy.get("[data-testid=processors]").click({ force: true });
      cy.url().should("eq", "http://localhost:9000/connectors");
      cy.get("table")
        .find("tr")
        .eq(1)
        .find("td")
        .eq(0)
        .contains("PayPal Test")
        .click({ force: true });

      cy.location("pathname").then((pathname) => {
        let mca_id = pathname.split("/")[2];
        cy.deleteConnector(mca_id);
        cy.visit("http://localhost:9000/connectors");
      });
    });
  });
});
