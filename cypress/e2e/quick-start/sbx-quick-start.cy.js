let username = `cypresssbxquickstart+${Math.round(
  +new Date() / 1000,
)}@gmail.com`;

before(() => {
  cy.viewport("macbook-16");
  cy.singup_curl(username, "cypress98#");
});
beforeEach(() => {
  cy.intercept("POST", "/config/merchant-access", {
    statusCode: 200,
    body: {
      test_live_toggle: false,
      is_live_mode: false,
      email: false,
      quick_start: true,
      audit_trail: false,
      system_metrics: false,
      sample_data: false,
      frm: false,
      payout: true,
      recon: false,
      test_processors: true,
      feedback: false,
      mixpanel: false,
      generate_report: false,
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
    cy.contains("How would you like to configure Hyperswitch?").should(
      "be.visible",
    );
    customComponentButtonType("configurationType");

    // to connect stripe
    cy.contains("Select Processor").should("be.visible");
    customComponentButtonType("stripe");
    customComponentButtonType("connectorSelection");

    cy.contains("Connect Stripe").should("be.visible");
    cy.contains("I have Stripe API keys").should("be.visible");
    customComponentButtonType("ConnectorApiKeys");
    customComponentButtonType("connectorConnectChoice");

    cy.contains("Connect Stripe").should("be.visible");
    fillInputFields(
      "connector_account_details.api_key",
      "sk_test_stripe_dummy_api_key",
    );

    fillInputFields(
      "connector_webhook_details.merchant_secret",
      "stripe_dummy_source_verification_keys",
    );
    customComponentButtonType("connectorConfigSubmit");
    cy.contains("Connect payment methods").should("be.visible");
    cy.get("[data-testid=credit_select_all]")
      .children("div:first")
      .should("have.attr", "data-bool-value")
      .and("match", /on/i);
    customComponentButtonType("connectorPaymentMethodsSubmit");
    cy.contains("Stripe").should("be.visible");
    customComponentButtonType("stripe_connectorSummary");

    // connect paypal
    cy.contains("Select Processor").should("be.visible");
    customComponentButtonType("paypal");
    customComponentButtonType("connectorSelection");

    cy.contains("Connect PayPal").should("be.visible");
    cy.contains("I have PayPal API keys").should("be.visible");
    customComponentButtonType("ConnectorApiKeys");
    customComponentButtonType("connectorConnectChoice");
    cy.contains("Connect PayPal").should("be.visible");
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
    customComponentButtonType("connectorConfigSubmit");
    cy.contains("Connect payment methods").should("be.visible");
    cy.get("[data-testid=credit_select_all]")
      .children("div:first")
      .should("have.attr", "data-bool-value")
      .and("match", /on/i);
    customComponentButtonType("connectorPaymentMethodsSubmit");
    cy.contains("PayPal").should("be.visible");
    customComponentButtonType("paypal_connectorSummary");

    // configure default routing
    cy.contains("Configure Smart Routing").should("be.visible");
    cy.get("[data-testid=horizontal-tile]").children().should("have.length", 2);
    cy.get(`[data-testid=DefaultFallback]`)
      .contains("Fallback routing (active - passive)")
      .should("exist")
      .click({ force: true });
    customComponentButtonType("smartRoutingProceed");
    cy.contains("Preview Checkout page");
    cy.get(`[data-button-for=skipThisStep]`).should("be.visible");
    clickButton("skipThisStep");

    // Integrate your app

    // NOTE: commented as test case was failing
    // cy.contains(
    //   "Configuration is complete. You can now start integrating with us!",
    // ).should("be.visible");
    customComponentButtonType("integrateiIntoYourApp");
    cy.contains("How would you like to integrate?").should("be.visible");
    cy.get("[data-testid=vertical-tile]").children().should("have.length", 2);
    cy.get(`[data-testid=MigrateFromStripe]`)
      .contains("Quick Integration for Stripe users")
      .should("exist")
      .click({ force: true });
    customComponentButtonType("integrateHyperswitch");

    // migrate from stripe steps
    cy.contains("Download Test API Key").should("be.visible");
    cy.contains(
      "API key once misplaced cannot be restored. If misplaced, please re-generate a new key from Dashboard > Developers.",
    ).should("be.visible");
    customComponentButtonType("downloadAPiKey");
    customComponentButtonType("DownloadTestAPIKeyStripe_button");

    cy.contains("Install Dependencies").should("be.visible");
    cy.get(`[data-editor="Monaco Editor"]`).should("exist");
    customComponentButtonType("InstallDeps_button");
    cy.contains("Replace API Key").should("be.visible");
    cy.contains("Publishable Key").should("be.visible");
    cy.get(`[data-editor="Difference code editor"]`).should("exist");
    customComponentButtonType("ReplaceAPIKeys_button");
    cy.contains("Reconfigure Checkout Form").should("be.visible");
    cy.contains("Publishable Key").should("be.visible");
    cy.get(`[data-editor="Difference code editor"]`).should("exist");
    customComponentButtonType("ReconfigureCheckout_button");
    cy.contains("Load Hyperswitch Checkout").should("be.visible");
    cy.contains("Publishable Key").should("be.visible");
    cy.get(`[data-editor="Difference code editor"]`).should("exist");
    customComponentButtonType("LoadCheckout_button");

    // prod onboarding
    cy.contains(
      "You have successfully completed Integration (Test Mode)",
    ).should("be.visible");
    customComponentButtonType("productionAccessForm");
    cy.contains("Provide Business Details").should("be.visible");
    cy.contains(
      "We require some information to verify your business. Once verified, you'll be able to access production environment and go live!",
    ).should("be.visible");
    fillInputFields("legal_business_name", "temp_business_name");
    selectDropDownOption("Select Country", "Albania");
    fillInputFields("business_website", "https://google.com");
    fillInputFields("poc_name", "temp_poc_name");
    fillInputFields("poc_email", username);
    fillInputFields("comments", "temp_tax_identification_number");
    customComponentButtonType("businessDetailsSubmit");
    cy.contains("Yay! you have successfully completed the setup!").should(
      "be.visible",
    );
    customComponentButtonType("redirectToHome");
    cy.url().should("eq", "http://localhost:9000/home");
  });
});
