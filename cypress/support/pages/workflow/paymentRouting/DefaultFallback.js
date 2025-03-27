class DefaultFallback {
  get defaultFallbackList() {
    return cy.get('[class="flex flex-col  w-full"]');
  }

  get saveChangesButton() {
    return cy.get('data-button-for="saveChanges"');
  }
}

export default DefaultFallback;
