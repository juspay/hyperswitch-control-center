let username = `cypresssbxquickstart+${Math.round(+new Date() / 1000)}@gmail.com`;
before(() => {
  cy.singup_curl(username, "cypress98#");
});
beforeEach(() => {
  cy.intercept("POST", "/config/merchant-access", {
    statusCode: 200,
    body: {
      test_live_toggle: false,
      is_live_mode: false,
      magic_link: false,
      production_access: false,
      quick_start: true,
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
  cy.visit("http://localhost:9000");
  cy.wait("@getData");
  cy.login_UI(username, "cypress98#");
});

describe("Sandbox quick start", () => {
  function clickButton(buttonName) {
    cy.get(`[data-button-for=${buttonName}]`).click({ force: true });
  }

  function fillInputFields(inputFieldName, textToFill) {
    cy.get(`input[name="${inputFieldName}"]`).type(textToFill);
  }

  function customComponentButtonType(componentTestingId) {
    cy.get(`[data-testid=${componentTestingId}]`).click({ force: true });
  }

  function selectDropDownOption(dropdownId, dropdownValue) {
    cy.get(`[data-dropdown-for="${dropdownId}"]`).click();
    cy.get(`[data-dropdown-value="${dropdownValue}"]`).click();
  }

  it("should successfully setup quickstart flow", () => {
    cy.url().should("eq", "http://localhost:9000/home");
    fillInputFields("merchant_name", "quick_start_flow_test");
    cy.contains("Quick Start");
    cy.contains(
      "Configure and start using Hyperswitch to get an overview of our offerings and how hyperswitch can help you control your payments",
    );
    clickButton("startExploring");
    clickButton("getStartedNow");
    cy.contains("How would you like to configure Hyperswitch?");
    customComponentButtonType("MultipleProcessorWithSmartRouting");
    clickButton("proceed");

    // to connect stripe
    customComponentButtonType("stripe");
    clickButton("proceed");
    customComponentButtonType("ConnectorApiKeys");
    clickButton("proceed");
    fillInputFields(
      "connector_account_details.api_key",
      "sk_test_stripe_dummy_api_key",
    );
    fillInputFields(
      "connector_webhook_details.merchant_secret",
      "stripe_dummy_source_verification_keys",
    );
    clickButton("proceed");
    clickButton("proceed");
    clickButton("proceed");
    clickButton("proceed");

    // to connect paypal
    customComponentButtonType("paypal");
    clickButton("proceed");
    customComponentButtonType("ConnectorApiKeys");
    clickButton("proceed");
    fillInputFields(
      "connector_account_details.api_key",
      "sk_test_paypal_dummy_api_key",
    );
    fillInputFields(
      "connector_account_details.key1",
      "sk_test_paypal_dummy_client_id",
    );
    fillInputFields(
      "connector_webhook_details.merchant_secret",
      "paypal_dummy_source_verification_keys",
    );
    clickButton("proceed");
    clickButton("proceed");
    clickButton("proceed");
    clickButton("proceed");

    // configure default routing
    customComponentButtonType("DefaultFallback");
    clickButton("proceed");
    cy.contains("Preview Checkout page");
    cy.get(`[data-button-for=skipThisStep]`).should("be.visible");
    clickButton("skipThisStep");
    cy.contains(
      "Configuration is complete. You can now start integrating with us!",
    );
    clickButton("iWantToIntegrateHyperswitchIntoMyApp");
    // integrate to my app flow
    customComponentButtonType("MigrateFromStripe");
    clickButton("proceed");
    clickButton("downloadAPIKey");
    clickButton("proceed");
    clickButton("proceed");
    clickButton("proceed");
    clickButton("proceed");
    clickButton("complete");

    // prod intent form
    clickButton("getProductionAccess");
    fillInputFields("legal_business_name", "temp_business_name");
    selectDropDownOption("Select Country", "Albania");
    fillInputFields("business_website", "https://google.com");
    fillInputFields("poc_name", "temp_poc_name");
    fillInputFields(
      "poc_email",
      `cypressquickstart+${Math.round(+new Date() / 1000)}@gmail.com`,
    );
    fillInputFields("comments", "temp_tax_identification_number");
    clickButton("submit");
    clickButton("goToHome");
    cy.url().should("eq", "http://localhost:9000/home");
  });
});
