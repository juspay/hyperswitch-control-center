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

  it("check singup flow", () => {
    const password = "cypress98#";
    cy.visit("http://localhost:9000/");
    cy.get("#card-subtitle").click();
    cy.url().should("include", "/register");
    cy.get("[data-testid=email]").type(username);
    cy.get("[data-testid=password]").type(password);
    cy.get('button[type="submit"]').click({ force: true });
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
    cy.intercept("GET", "merchant-config?domain=default", {
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
          mixpanel_token: "",
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
      },
    }).as("getFeatureData");
    cy.visit("http://localhost:9000");
    cy.wait("@getFeatureData");
    cy.get("[data-testid=card-foot-text]").click();
    cy.url().should("include", "/login");
    cy.get("#card-header").should("contain", "Hey there, Welcome back!");
    cy.get("#card-subtitle").should("contain", "Sign up");
    cy.get("[data-testid=forgot-password]").click();
    cy.url().should("include", "/forget-password");
    cy.get("#card-header").should("contain", "Forgot Password?");
  });

  it("should successfully log in with valid credentials", () => {
    const password = "cypress98#";
    cy.visit("http://localhost:9000/dashboard/login");
    cy.get("[data-testid=email]").type(username);
    cy.get("[data-testid=password]").type(password);
    cy.get('button[type="submit"]').click({ force: true });
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
    const password = "cypress98#";
    cy.visit("http://localhost:9000/");
    cy.get("[data-testid=email]").type(`  ${username}  `);
    cy.get("[data-testid=password]").type(password);
    cy.get('button[type="submit"]').click({ force: true });
    cy.url().should("eq", "http://localhost:9000/dashboard/home");
  });
});
