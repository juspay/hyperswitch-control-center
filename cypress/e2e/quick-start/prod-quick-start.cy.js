let username = `cypressquickstart+${Math.round(+new Date() / 1000)}@gmail.com`;
before(() => {
  cy.singup_curl(username, "cypress98#");
});
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
  cy.login_UI(username, "cypress98#");
  cy.wait("@getPDF");
});
describe("Prod quick start", () => {
  it("should successfully accept the agreement", () => {
    cy.contains("Hyperswitch Service Agreement").should("be.visible");
    cy.get(".show-scrollbar").scrollTo(0, 300);
    cy.get("[data-selected-checkbox=NotSelected]").click({ force: true });
    cy.get("[data-button-for='accept&Proceed']").click({ force: true });
  });

  it("should successfully setup first processor", () => {
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
    cy.get("[data-button-for=back]").should("exist");
    cy.get("[data-button-for=connectAndProceed]").click({ force: true });

    cy.contains("Setup Webhooks on Adyen");
    cy.contains("Enable relevant webhooks on your Adyen account");
    cy.get("[data-icon=copy]").should("exist");
    cy.get("[data-icon=copy]").click({ force: true });
    cy.get("[data-button-for=connectAndProceed]").click({ force: true });
    cy.contains("Replace API keys & Live Endpoints");
  });

  it("should successfully configure live endpoints", () => {
    cy.get("[data-button-for='accept&Proceed']").click({ force: true });
    cy.contains("Replace API keys & Live Endpoints");
    cy.contains(
      "Point your application's client and server to our live environment",
    );
    cy.contains("Live Domain");
    cy.contains(
      "Configure this base url in your application for all server-server calls",
    );
    cy.contains("Publishable Key");
    cy.contains(
      "Use this key to authenticate all calls from your application's client to Hyperswitch SDK",
    );
    cy.contains("API Key");
    cy.contains(
      "Use this key to authenticate all API requests from your application's server to Hyperswitch server",
    );
    cy.get("[data-button-for=createAndDownloadAPIKey]").click({ force: true });
    cy.get("[data-button-for=connectAndProceed]").click({ force: true });
    cy.contains("Setup Webhooks On Your End");
    cy.contains(
      "Create webhook endpoints to allow us to receive and notify you of payment events",
    );
    cy.contains("Merchant Webhook Endpoint");
    cy.contains(
      "Provide the endpoint where you would want us to send live payment events",
    );
    cy.contains("Payment Response Hash Key");
    cy.contains(
      "Download the provided key to authenticate and verify live events sent by Hyperswitch. Learn more",
    );
    cy.get('input[name="webhookEndpoint"]').type("https://google.com");
    cy.get("[data-button-for=connectAndProceed]").click({ force: true });
    cy.contains("Basic Account Setup Successful");
    cy.get("[data-button-for=goToDashboard]").click({ force: true });
    cy.url().should("eq", "http://localhost:9000/home");
  });
});
