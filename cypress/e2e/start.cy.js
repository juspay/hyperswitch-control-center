describe("template spec", () => {
  it("passes", () => {
    cy.visit("http://localhost:9000/");
    cy.contains("Hey there,").should("be.visible");
  });
});
