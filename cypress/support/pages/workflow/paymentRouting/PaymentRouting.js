class PaymentRouting {
  //
  get volumeBasedRoutingSetupButton() {
    return cy.get('[data-button-for="setup"]').eq(0);
  }

  get volumeBasedRoutingHeader() {
    return cy.get('[class="flex items-center gap-4 "]');
  }

  get ruleBasedRoutingSetupButton() {
    return cy.get('[data-button-for="setup"]').eq(1);
  }

  get defaultFallbackManageButton() {
    return cy.get('[data-button-for="manage"]').children().eq(0);
  }
}

export default PaymentRouting;
