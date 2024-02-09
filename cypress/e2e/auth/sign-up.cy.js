describe("singup Module", () => {
  beforeEach(() => {
    cy.visit("http://localhost:9000/register");
  });

  it("should successfully log in with valid credentials", () => {
    const username = "test@gmail.com";
    const password = "test";
    cy.get("[data-testid=email]").type(username);
    cy.get("[data-testid=password]").type(password);
    cy.get('button[type="submit"]').click({ force: true });
    cy.url().should("eq", "http://localhost:9000/home");
    cy.contains(
      "Welcome to the home of your Payments Control Centre. It aims at providing your team with a 360-degree view of payments.",
    ).should("be.visible");
  });
});
