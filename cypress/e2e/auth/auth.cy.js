describe("Auth Module", () => {
  it("check the components in the sign up page", () => {
    cy.visit("http://localhost:9000/");
    cy.get("#card-subtitle").click();
    cy.url().should("include", "/register");
    cy.get("#card-header").should("contain", "Welcome to Hyperswitch");
    cy.get("#card-subtitle").should("contain", "Sign in");
    cy.get("#auth-submit-btn").should("exist");
    cy.get("#tc-text").should("exist");
    cy.get("#footer").should("exist");
  });

  it("check singup flow", () => {
    const username = Cypress.env("CYPRESS_USERNAME");
    const password = Cypress.env("CYPRESS_PASSWORD");
    cy.visit("http://localhost:9000/");
    cy.get("#card-subtitle").click();
    cy.url().should("include", "/register");
    cy.get("[data-testid=email]").type(username);
    cy.get("[data-testid=password]").type(password);
    cy.get('button[type="submit"]').click({ force: true });
    cy.url().should("eq", "http://localhost:9000/home");
    cy.contains(
      "Welcome to the home of your Payments Control Centre. It aims at providing your team with a 360-degree view of payments.",
    ).should("be.visible");
  });

  it("check the components in the login page", () => {
    cy.visit("http://localhost:9000/login");
    cy.url().should("include", "/login");
    cy.get("#card-header").should("contain", "Hey there, Welcome back!");
    cy.get("#card-subtitle").should("contain", "Sign up");
    cy.get("#auth-submit-btn").should("exist");
    cy.get("#tc-text").should("exist");
    cy.get("#footer").should("exist");
  });

  it("should successfully log in with valid credentials", () => {
    const username = Cypress.env("CYPRESS_USERNAME");
    const password = Cypress.env("CYPRESS_PASSWORD");
    cy.visit("http://localhost:9000/login");
    cy.get("[data-testid=email]").type(username);
    cy.get("[data-testid=password]").type(password);
    cy.get('button[type="submit"]').click({ force: true });
    cy.url().should("eq", "http://localhost:9000/home");
    cy.contains(
      "Welcome to the home of your Payments Control Centre. It aims at providing your team with a 360-degree view of payments.",
    ).should("be.visible");
  });

  it("should display an error message with invalid credentials", () => {
    cy.visit("http://localhost:9000/");
    cy.get("[data-testid=email]").type("xxx@gmail.com");
    cy.get("[data-testid=password]").type("xxxx");
    cy.get('button[type="submit"]').click({ force: true });
    cy.contains("Incorrect email or password").should("be.visible");
  });
});
