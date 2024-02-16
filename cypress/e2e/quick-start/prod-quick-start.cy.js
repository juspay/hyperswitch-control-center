beforeEach(() => {
  cy.intercept("POST", "/config/merchant-access", {
    statusCode: 200,
    body: {
      test_live_toggle: false,
      is_live_mode: true,
      magic_link: false,
      production_access: false,
      quick_start: false,
      switch_merchant: true,
      audit_trail: false,
      system_metrics: false,
      sample_data: false,
      frm: false,
      payout: true,
      recon: false,
      test_processors: true,
      feedback: false,
      verify_connector: false,
      mixpanel: false,
      mixpanel_sdk: false,
      business_profile: false,
      generate_report: false,
      forgot_password: false,
      user_journey_analytics: false,
      surcharge: false,
      permission_based_module: false,
      dispute_evidence_upload: false,
      paypal_automatic_flow: false,
      invite_multiple: false,
      "accept-invite": false,
    },
  }).as("getData");
  cy.intercept("GET", "/agreement/tc-hyperswitch-aug-23.pdf", {
    statusCode: 200,
  }).as("getPDF");
  cy.visit("http://localhost:9000");
  cy.wait("@getData");

  cy.login_UI();
  cy.wait("@getPDF");
});
describe("Prod quick start", () => {
  it("shoud", () => {
    cy.contains("Hyperswitch Service Agreement").should("be.visible");
    cy.get(".show-scrollbar").scrollTo(0, 300);
    cy.get("[data-selected-checkbox=NotSelected]").click({ force: true });
    cy.get("[data-button-for='accept&Proceed']").click({ force: true });
    cy.get("[data-testid=adyen]").click();
    cy.get("[data-button-for='proceed']").click({ force: true });
    cy.get('input[name="connector_account_details.api_key"]').type(
      "adyen_test_cypress_api_key",
    );
    cy.get('input[name="connector_account_details.key1"]').type(
      "adyen_test_cypress_account_id",
    );
    cy.get('input[name="connector_webhook_details.merchant_secret"]').type(
      "adyen_test_cypress_source_verification",
    );
    cy.get("[data-selected-checkbox=NotSelected]").click({ force: true });
    // cy.get("[data-button-for=connectAndProceed]").click({ force: true });
  });
});
