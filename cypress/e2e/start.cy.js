describe("template spec", () => {
  it("passes", () => {
    cy.visit("/");
    cy.contains("Hey there,").should("be.visible");
  });
});
