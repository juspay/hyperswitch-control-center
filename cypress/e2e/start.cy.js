describe("template spec", () => {
  it("passes", () => {
    cy.visit("https://app.hyperswitch.io");
    cy.contains("Hey there,").should("be.visible");
  });
});
