describe("auth ui checks", () => {
  beforeEach(() => {
    cy.visit("http://localhost:9000/");
  });

  it("check the components in the login page", () => {
    cy.url().should("include", "/login");
  });
});
