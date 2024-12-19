let username = `cypress+${Math.round(+new Date() / 1000)}@gmail.com`;
describe("Auth Module", () => {
  it("check the components in the sign up page", () => {
    cy.visit("http://localhost:9000/");
    cy.get("#card-subtitle").click();
    cy.url().should("include", "/register");
    cy.get("#card-header").should("contain", "Welcome to Hyperswitch");
    cy.get("#card-subtitle").should("contain", "Sign in");
    cy.get("#auth-submit-btn").should("exist");
    cy.get("#tc-text").should("exist");
    cy.get("#footer").should("exist");
  });

  it("check signup flow", () => {
    const password = "Cypress98#";
    cy.visit("http://localhost:9000/");
    cy.get("#card-subtitle").click();
    cy.url().should("include", "/register");
    cy.sign_up_with_email(username, password);
    cy.url().should("eq", "http://localhost:9000/dashboard/home");
  });

  it("check the components in the login page", () => {
    cy.visit("http://localhost:9000/dashboard/login");
    cy.url().should("include", "/login");
    cy.get("#card-header").should("contain", "Hey there, Welcome back!");
    cy.get("#card-subtitle").should("contain", "Sign up");
    cy.get("#auth-submit-btn").should("exist");
    cy.get("#tc-text").should("exist");
    cy.get("#footer").should("exist");
  });

  it("check auth page back button functioning", () => {
    cy.visit("http://localhost:9000/");
    cy.get("#card-subtitle").click();
    cy.url().should("include", "/register");
    cy.get("#card-header").should("contain", "Welcome to Hyperswitch");
    cy.get("#card-subtitle").should("contain", "Sign in");
    cy.get("#card-subtitle").click();
    cy.url().should("include", "/login");
    cy.get("#card-header").should("contain", "Hey there, Welcome back!");
  });

  it("sets true the feature flag for magic link and forgot password,then checks auth page back button functioning", () => {
    cy.intercept("GET", "/dashboard/config/feature?domain=default", {
      statusCode: 200,
      body: {
        theme: {
          primary_color: "#006DF9",
          primary_hover_color: "#005ED6",
          sidebar_color: "#242F48",
        },
        endpoints: {
          api_url: "http://localhost:8080",
          sdk_url: "",
          logo_url: "",
          favicon_url: "",
          agreement_url: "",
          agreement_version: "",
          apple_pay_certificate_url: "",
          mixpanel_token: "",
          recon_iframe_url: "",
          dss_certificate_url: "",
        },
        features: {
          test_live_toggle: false,
          is_live_mode: false,
          email: true,
          quick_start: false,
          audit_trail: false,
          system_metrics: false,
          sample_data: false,
          frm: false,
          payout: true,
          recon: false,
          test_processors: true,
          dev_click_to_pay: false,
          feedback: false,
          mixpanel: false,
          generate_report: false,
          user_journey_analytics: false,
          authentication_analytics: false,
          surcharge: false,
          dispute_evidence_upload: false,
          paypal_automatic_flow: false,
          threeds_authenticator: false,
          global_search: false,
          dispute_analytics: false,
          configure_pmts: false,
          branding: false,
          live_users_counter: false,
          granularity: false,
          compliance_certificate: false,
          user_management_revamp: false,
          pm_authentication_processor: true,
          performance_monitor: false,
          new_analytics: false,
          down_time: false,
          tax_processor: true,
        },
      },
    }).as("getFeatureData");
    cy.visit("http://localhost:9000");
    cy.wait("@getFeatureData");
    cy.get("[data-testid=card-foot-text]").click();
    cy.url().should("include", "/login");
    cy.get("#card-header").should("contain", "Hey there, Welcome back!");
    cy.get("#card-subtitle").should("contain", "Sign up");
    cy.get("[data-testid=card-foot-text]")
      .should("contain", "sign in using password")
      .click();

    cy.get("[data-testid=forgot-password]").click();
    cy.url().should("include", "/forget-password");
    cy.get("#card-header").should("contain", "Forgot Password?");
  });

  it("should successfully log in with valid credentials", () => {
    const password = "Cypress98#";
    cy.visit("http://localhost:9000/dashboard/login");
    cy.get("[data-testid=email]").type(username);
    cy.get("[data-testid=password]").type(password);
    cy.get('button[type="submit"]').click({ force: true });
    cy.get("[data-testid=skip-now]").click({ force: true });
    cy.url().should("eq", "http://localhost:9000/dashboard/home");
  });

  it("should display an error message with invalid credentials", () => {
    cy.visit("http://localhost:9000/");
    cy.get("[data-testid=email]").type("xxx@gmail.com");
    cy.get("[data-testid=password]").type("xxxx");
    cy.get('button[type="submit"]').click({ force: true });
    cy.contains("Incorrect email or password").should("be.visible");
  });

  it("should login successfully with email containing spaces", () => {
    const password = "Cypress98#";
    cy.visit("http://localhost:9000/");
    cy.get("[data-testid=email]").type(`  ${username}  `);
    cy.get("[data-testid=password]").type(password);
    cy.get('button[type="submit"]').click({ force: true });
    cy.get("[data-testid=skip-now]").click({ force: true });
    cy.url().should("eq", "http://localhost:9000/dashboard/home");
  });
});
