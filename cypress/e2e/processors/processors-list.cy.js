describe("Processors Landing Module", () => {
  beforeEach(() => {
    cy.visit("http://localhost:9000/");
  });
  it("should successfully land in the process list page", () => {
    const username = Cypress.env("CYPRESS_USERNAME");
    const password = Cypress.env("CYPRESS_PASSWORD");
    cy.get("[data-testid=email]").type(username);
    cy.get("[data-testid=password]").type(password);
    cy.get('button[type="submit"]').click({ force: true });
    cy.get("[data-testid=processors]").click({ force: true });
    cy.url().should("eq", "http://localhost:9000/connectors");
    cy.contains("Processors").should("be.visible");
    cy.contains(
      "Connect and manage payment processors to enable payment acceptance",
    ).should("be.visible");
    cy.get("[data-testid=connect_a_new_connector]").contains(
      "Connect a new connector",
    );
    cy.get("[data-testid=search-processor]")
      .type("stripe", { force: true })
      .should("have.value", "stripe");
    cy.get("[data-testid=stripe]")
      .find("img")
      .should("have.attr", "src", "/Gateway/STRIPE.svg");
  });
});
