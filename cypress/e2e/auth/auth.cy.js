describe("auth ui checks", () => {
  beforeEach(() => {
    cy.visit("http://localhost:9000/");
  });

  it("check the components in the login page", () => {
    cy.url().should("include", "/login");
    cy.get("#card-header").should("contain", "Hey there, Welcome back!");
    cy.get("#card-subtitle").should("contain", "Sign up");
    cy.get("#auth-submit-btn").should("exist");
    cy.get("#tc-text").should("exist");
    cy.get("#footer").should("exist");
  });

  it("check the components in the sign up page", () => {
    cy.get("#card-subtitle").click();
    cy.url().should("include", "/register");
    cy.get("#card-header").should("contain", "Welcome to Hyperswitch");
    cy.get("#card-subtitle").should("contain", "Sign in");
    cy.get("#auth-submit-btn").should("exist");
    cy.get("#tc-text").should("exist");
    cy.get("#footer").should("exist");
  });
});
