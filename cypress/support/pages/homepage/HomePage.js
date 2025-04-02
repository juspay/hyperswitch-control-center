class HomePage {
  // Onboarding
  get enterMerchantName() {
    return cy.get('[name="merchant_name"]');
  }

  get onboardingSubmitButton() {
    return cy.get('[data-button-for="startExploring"]');
  }

  get orgDropdown() {
    return cy.get();
  }

  get merchantDropdown() {
    return cy.get();
  }

  get profileDropdown() {
    return cy.get('[class="md:max-w-40 max-w-16"]');
  }

  get profileDropdownList() {
    return cy.get(
      '[class="max-h-72 overflow-scroll px-1 pt-1 sidebar-scrollbar"]',
    );
  }

  //Sidebar

  //Connectors
  get connectors() {
    return cy.get("[data-testid=connectors]");
  }

  get paymentProcessors() {
    return cy.get("[data-testid=paymentprocessors]");
  }

  //Workflow
  get workflow() {
    return cy.get('[data-testid="workflow"]');
  }

  get routing() {
    return cy.get('[data-testid="routing"]');
  }
}

export default HomePage;
