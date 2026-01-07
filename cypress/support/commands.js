// ***********************************************
// This example commands.js shows you how to
// create various custom commands and overwrite
// existing commands.
//
// For more comprehensive examples of custom
// commands please read more here:
// https://on.cypress.io/custom-commands
// ***********************************************
//
//
// -- This is a parent command --
// Cypress.Commands.add('login', (email, password) => { ... })
//
//
// -- This is a child command --
// Cypress.Commands.add('drag', { prevSubject: 'element'}, (subject, options) => { ... })
//
//
// -- This is a dual command --
// Cypress.Commands.add('dismiss', { prevSubject: 'optional'}, (subject, options) => { ... })
//
//
// -- This will overwrite an existing command --
// Cypress.Commands.overwrite('visit', (originalFn, url, options) => { ... })

import { v4 as uuidv4 } from "uuid";
import * as helper from "../support/helper";
import SignInPage from "../support/pages/auth/SignInPage";
import SignUpPage from "../support/pages/auth/SignUpPage";
import ResetPasswordPage from "../support/pages/auth/ResetPasswordPage";

import {
  rolePermissions,
  hasPermission,
  hasAccessLevelPermission,
} from "../support/permissions";

const signinPage = new SignInPage();
const signupPage = new SignUpPage();
const resetPasswordPage = new ResetPasswordPage();

// Custom command to check permissions and decide whether to skip or run the test
Cypress.Commands.add("checkPermissionsFromTestName", (testName) => {
  const rbac = Cypress.env("RBAC").split(",");
  const userAccessLevel = rbac[0]; // "Access Level"
  const userRole = rbac[1]; // "Role"

  // Extract tags from the test name using a regex
  const regex = /@([a-zA-Z0-9_-]+)/g;
  const tags = [...testName.matchAll(regex)].map((match) => match[1]);

  // Parse the tags from test case name and get "section" and "accessLevel"
  const sectionTag = tags.find((tag) =>
    [
      "operations",
      "connectors",
      "analytics",
      "workflows",
      "reconOps",
      "reconReports",
      "users",
      "account",
    ].includes(tag),
  );
  const accessLevelTag = tags.find((tag) =>
    ["org", "merchant", "profile"].includes(tag),
  );
  const permissionTag =
    rolePermissions[userRole] && rolePermissions[userRole][sectionTag];

  // Default values if no tags are found in the name
  const requiredSection = sectionTag || "users"; // Default to 'analytics'
  const requiredAccessLevel = accessLevelTag || "org"; // Default to 'org'
  const requiredPermission = permissionTag || "write"; // Default to 'write'

  // Check access level and run the test based on the user’s access level
  if (userAccessLevel === "profile") {
    // If the user is at 'profile' access level, run tests with the 'profile' tag only
    if (!tags.includes("profile")) {
      Cypress.log({
        name: "Test skipped",
        message: `Skipping test for "${requiredSection}" section: User access level from env is 'profile' and this test is not tagged with 'profile'`,
      });
      return true;
    }
  } else if (userAccessLevel === "merchant") {
    // If the user is at 'merchant' access level, run tests with 'merchant' or 'profile' tag
    if (!tags.includes("merchant") && !tags.includes("profile")) {
      Cypress.log({
        name: "Test skipped",
        message: `Skipping test for "${requiredSection}" section: User access level from env is 'merchant' and this test is not tagged with 'merchant' or 'profile'`,
      });
      return true; // Skip the test
    }
  } else if (userAccessLevel === "org") {
    // If the user is at 'org' access level, run tests with 'org', 'merchant', or 'profile' tag
    if (
      !tags.includes("org") &&
      !tags.includes("merchant") &&
      !tags.includes("profile")
    ) {
      Cypress.log({
        name: "Test skipped",
        message: `Skipping test for "${requiredSection}" section: User access level from env is 'org' and this test is not tagged with 'org', 'merchant', or 'profile'`,
      });
      return true; // Skip the test
    }
  }

  // Validate if user has access level permission to the section
  const canAccess = hasAccessLevelPermission(
    userAccessLevel,
    userRole,
    requiredSection,
  );
  if (!canAccess) {
    Cypress.log({
      name: "Test Skipped",
      message: `Skipping ${requiredSection} test due to insufficient access level`,
    });
    return true; // Skip the test
  }

  // Validate if user has the correct permission (read/write)
  const hasCorrectPermission = hasPermission(
    userRole,
    requiredSection,
    requiredPermission,
  );
  if (!hasCorrectPermission) {
    Cypress.log({
      name: "Test Skipped",
      message: `Skipping ${requiredSection} test due to insufficient permissions (${requiredPermission})`,
    });
    return true; // Skip the test
  }
});

Cypress.Commands.add("visit_signupPage", () => {
  cy.visit("/");
  signinPage.signUpLink.click();
  cy.url().should("include", "/register");
});

Cypress.Commands.add("enable_email_feature_flag", () => {
  cy.intercept("GET", "/dashboard/config/feature?domain=", {
    statusCode: 200,
    body: {
      theme: {
        primary_color: "#006DF9",
        primary_hover_color: "#005ED6",
        sidebar_color: "#242F48",
      },
      endpoints: {
        api_url: "http://localhost:9000/api",
      },
      features: {
        email: true,
      },
    },
  }).as("getFeatureData");
  cy.visit("/");
  cy.wait("@getFeatureData");
});

Cypress.Commands.add("mock_magic_link_signin_success", (user_email = "") => {
  const email =
    user_email.length > 0 ? user_email : Cypress.env("CYPRESS_USERNAME");

  cy.intercept("POST", "/api/user/connect_account?auth_id=&domain=", {
    statusCode: 200,
    body: {
      is_email_sent: true,
    },
  }).as("getMagicLinkSuccess");
});

Cypress.Commands.add("signup_API", (name = "", pass = "") => {
  const username = name.length > 0 ? name : Cypress.env("CYPRESS_USERNAME");
  const password = pass.length > 0 ? pass : Cypress.env("CYPRESS_PASSWORD");

  cy.request({
    method: "POST",
    url: `http://localhost:8080/user/signup_with_merchant_id`,
    headers: {
      "Content-Type": "application/json",
      "api-key": "test_admin",
    },
    body: {
      email: username,
      password: password,
      company_name: helper.generateDateTimeString(),
      name: "Cypress_test_user",
    },
  })
    .then((response) => {
      expect(response.status).to.be.within(200, 299);
    })
    .should((response) => {
      // Check if there was an error in the response
      if (response.status >= 400) {
        throw new Error(`Request failed with status: ${response.status}`);
      }
    });
});

Cypress.Commands.add("login_API", (name = "", pass = "") => {
  const username = name.length > 0 ? name : Cypress.env("CYPRESS_USERNAME");
  const password = pass.length > 0 ? pass : Cypress.env("CYPRESS_PASSWORD");
  // /user/signin
  cy.request({
    method: "POST",
    url: `http://localhost:9000/api/user/signin`,
    headers: {
      "Content-Type": "application/json",
    },
    body: { email: username, password: password, country: "IN" },
  });
});

Cypress.Commands.add("login_UI", (name = "", pass = "") => {
  cy.visit("/");
  const username = name.length > 0 ? name : Cypress.env("CYPRESS_USERNAME");
  const password = pass.length > 0 ? pass : Cypress.env("CYPRESS_PASSWORD");
  signinPage.emailInput.type(username);
  signinPage.passwordInput.type(password);
  signinPage.signinButton.click();
  signinPage.skip2FAButton.click();
});

Cypress.Commands.add("createAPIKey", (merchant_id) => {
  return cy
    .request({
      method: "POST",
      url: `http://localhost:8080/api_keys/${merchant_id}`,
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "api-key": "test_admin",
      },
      body: {
        name: "API Key 1",
        description: null,
        expiration: "2060-09-23T01:02:03.000Z",
      },
    })
    .then((response) => {
      const apiKey = response.body.api_key;
      return apiKey;
    });
});

Cypress.Commands.add(
  "createDummyConnectorAPI",
  (merchant_id, connector_label) => {
    cy.createAPIKey(merchant_id).then((apiKey) => {
      cy.request({
        method: "POST",
        url: `http://localhost:8080/account/${merchant_id}/connectors`,
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "api-key": apiKey, // Pass the apiKey here
        },
        body: {
          connector_type: "payment_processor",
          connector_name: "stripe_test",
          connector_label: `${connector_label}`,
          connector_account_details: {
            api_key: "test_key",
            auth_type: "HeaderKey",
          },
          status: "active",
          test_mode: true,
          payment_methods_enabled: [
            {
              payment_method: "card",
              payment_method_types: [
                {
                  payment_method_type: "debit",
                  card_networks: ["Mastercard"],
                  minimum_amount: 0,
                  maximum_amount: 68607706,
                  recurring_enabled: true,
                  installment_payment_enabled: false,
                },
                {
                  payment_method_type: "debit",
                  card_networks: ["Visa"],
                  minimum_amount: 0,
                  maximum_amount: 68607706,
                  recurring_enabled: true,
                  installment_payment_enabled: false,
                },
              ],
            },
            {
              payment_method: "card",
              payment_method_types: [
                {
                  payment_method_type: "credit",
                  card_networks: ["Mastercard"],
                  minimum_amount: 0,
                  maximum_amount: 68607706,
                  recurring_enabled: true,
                  installment_payment_enabled: false,
                },
                {
                  payment_method_type: "credit",
                  card_networks: ["Visa"],
                  minimum_amount: 0,
                  maximum_amount: 68607706,
                  recurring_enabled: true,
                  installment_payment_enabled: false,
                },
              ],
            },
          ],
        },
      });
    });
  },
);

Cypress.Commands.add("create_connector_UI", () => {
  cy.get("[data-testid=connectors]").click();
  cy.get("[data-testid=paymentprocessors]").click();
  cy.contains("Payment Processors").should("be.visible");
  cy.contains("Connect a Dummy Processor").should("be.visible");
  cy.get("[data-button-for=connectNow]").click({
    force: true,
  });
  cy.get('[data-component="modal:Connect a Dummy Processor"]', {
    timeout: 10000,
  })
    .find("button")
    .should("have.length", 4);
  cy.contains("Stripe Dummy").should("be.visible");
  cy.get('[data-testid="stripe_test"]').find("button").click({ force: true });
  cy.url().should("include", "/dashboard/connectors");
  cy.contains("Credentials").should("be.visible");
  cy.get("[name=connector_account_details\\.api_key]")
    .clear()
    .type("dummy_api_key");
  cy.get("[name=connector_label]").clear().type("stripe_test_default_label");
  cy.get("[data-button-for=connectAndProceed]").click();
  cy.get("[data-testid=credit_select_all]").click();
  cy.get("[data-testid=credit_mastercard]").click();
  cy.get("[data-testid=debit_cartesbancaires]").click();
  cy.get("[data-testid=pay_later_klarna]").click();
  cy.get("[data-testid=wallet_we_chat_pay]").click();
  cy.get("[data-button-for=proceed]").click();
  cy.get('[data-toast="Connector Created Successfully!"]', {
    timeout: 10000,
  }).click();
  cy.get("[data-button-for=done]").click();
  cy.url().should("include", "/dashboard/connectors");
  cy.contains("stripe_test_default_label")
    .scrollIntoView()
    .should("be.visible");
});

Cypress.Commands.add("deleteConnector", (mca_id) => {
  let token = window.localStorage.getItem("login");
  let { merchant_id = "" } = JSON.parse(
    window.localStorage.getItem("merchant"),
  );
  cy.request({
    method: "DELETE",
    url: `http://localhost:9000/api/account/${merchant_id}/connectors/${mca_id}`,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  });
});

Cypress.Commands.add("createPaymentAPI", (merchant_id) => {
  cy.createAPIKey(merchant_id).then((apiKey) => {
    cy.request({
      method: "POST",
      url: `http://localhost:8080/payments`,
      headers: {
        "Content-Type": "application/json",
        Accept: "application/json",
        "api-key": apiKey, // Pass the apiKey here
      },
      body: {
        amount: 12345,
        currency: "USD",
        confirm: true,
        capture_method: "automatic",
        customer_id: "test_customer",
        authentication_type: "no_three_ds",
        return_url: "https://google.com",
        email: "abc@test.com",
        name: "Joseph Doe",
        phone: "999999999",
        phone_country_code: "+65",
        merchant_order_reference_id: "abcd",
        description: "Its my first payment",
        statement_descriptor_name: "Juspay",
        statement_descriptor_suffix: "Router",
        payment_method: "card",
        payment_method_type: "credit",
        payment_method_data: {
          card: {
            card_number: "4242424242424242",
            card_exp_month: "01",
            card_exp_year: "2027",
            card_holder_name: "joseph Doe",
            card_cvc: "100",
            nick_name: "hehe",
          },
        },
        billing: {
          address: {
            city: "Toronto",
            country: "CA",
            line1: "1562",
            line2: "HarrisonStreet",
            line3: "HarrisonStreet",
            zip: "M3C 0C1",
            state: "ON",
            first_name: "Joseph",
            last_name: "Doe",
          },
          phone: {
            number: "8056594427",
            country_code: "+91",
          },
          email: "abc@test.com",
        },
        shipping: {
          address: {
            city: "Toronto",
            country: "CA",
            line1: "1562",
            line2: "HarrisonStreet",
            line3: "HarrisonStreet",
            zip: "M3C 0C1",
            state: "ON",
            first_name: "Joseph",
            last_name: "Doe",
          },
          phone: {
            number: "8056594427",
            country_code: "+91",
          },
          email: "abc@test.com",
        },
        metadata: {
          key: "value",
        },
      },
    });
  });
});

Cypress.Commands.add("process_payment_sdk_UI", () => {
  cy.clearCookies("login_token");
  cy.get("[data-testid=connectors]").click();
  cy.get("[data-testid=paymentprocessors]").click();
  cy.contains("Payment Processors").should("be.visible");
  cy.get("[data-testid=home]").first().click();
  cy.get("[data-button-for=tryItOut]").click();
  cy.get('[data-breadcrumb="Explore Demo Checkout Experience"]').should(
    "exist",
  );
  cy.get("[data-testid=amount]").find("input").clear().type("77");
  cy.get("[data-button-for=showPreview]").click();
  cy.wait(2000);
  getIframeBody()
    .find("[data-testid=cardNoInput]", { timeout: 20000 })
    .should("exist")
    .type("4242424242424242");
  getIframeBody()
    .find("[data-testid=expiryInput]")
    .should("exist")
    .type("0127");
  getIframeBody()
    .find("[data-testid=cvvInput]")
    .should("exist")
    .scrollIntoView()
    .type("492");

  cy.get("[data-button-for=payUSD77]").click();
  cy.contains("Payment Successful").should("exist");
  // cy.get("[data-button-for=goToPayment]").click();
  // cy.url().should("include", "dashboard/payments");
});

Cypress.Commands.add("sign_up_with_email", (username, password) => {
  cy.url().should("include", "/register");
  signupPage.emailInput.type(username);
  signupPage.signUpButton.click();
  cy.get("[data-testid=card-header]").should(
    "contain",
    "Please check your inbox",
  );
  cy.visit(Cypress.env("MAIL_URL"));
  cy.get("div.messages > div:nth-child(2)").click();
  cy.wait(1000);
  cy.get("iframe").then(($iframe) => {
    // Verify email
    const doc = $iframe.contents();
    const verifyEmail = doc.find("a").get(0);
    cy.visit(verifyEmail.href);
    signinPage.skip2FAButton.click();
    // Set password
    resetPasswordPage.createPassword.type(password);
    resetPasswordPage.confirmPassword.type(password);
    resetPasswordPage.confirmButton.click();
    // Login to dashboard
    signinPage.emailInput.type(username);
    signinPage.passwordInput.type(password);
    signinPage.signinButton.click();
    // Skip 2FA
    signinPage.skip2FAButton.click();
  });
});

Cypress.Commands.add("redirect_from_mail_inbox", () => {
  cy.visit(Cypress.env("MAIL_URL"));
  cy.get("div.messages > div:nth-child(2)").click();
  cy.wait(1000);
  cy.get("iframe").then(($iframe) => {
    // Verify email
    const doc = $iframe.contents();
    const verifyEmail = doc.find("a").get(0);
    cy.visit(verifyEmail.href);
  });
});

Cypress.Commands.add("signin_from_mail_inbox", () => {
  cy.visit(Cypress.env("MAIL_URL"));
  cy.get("div.messages > div")
    .contains("Unlock Hyperswitch: Use Your Magic Link to Sign In")
    .click();
  cy.wait(1000);
  cy.get("iframe").then(($iframe) => {
    // Verify email
    const doc = $iframe.contents();
    const verifyEmail = doc.find("a").get(0);
    cy.visit(verifyEmail.href);
  });
});

const getIframeBody = () => {
  return cy
    .get("iframe")
    .its("0.contentDocument.body")
    .should("not.be.empty")
    .then(cy.wrap);
};

Cypress.Commands.add("create_auth", () => {
  cy.request({
    method: "POST",
    url: `http://localhost:8080/user/auth`,
    headers: {
      "Content-Type": "application/json",
      "api-key": "test_admin",
    },
    body: {
      owner_id: "okta_test",
      owner_type: "organization",
      auth_method: {
        auth_type: "open_id_connect",
        private_config: {
          base_url: Cypress.env("CYPRESS_SSO_BASE_URL"),
          client_id: Cypress.env("CYPRESS_SSO_CLIENT_ID"),
          client_secret: Cypress.env("CYPRESS_SSO_CLIENT_SECRET"),
        },
        public_config: {
          name: "okta",
        },
      },
      allow_signup: false,
      email_domain: "cypresstest.in",
    },
  });
});

Cypress.Commands.add("get_authID_by_email", () => {
  return cy
    .request({
      method: "GET",
      url: `http://localhost:8080/user/auth/list?email_domain=cypresstest.in`,
    })
    .then((response) => {
      return response.body[0].auth_id;
    });
});

Cypress.Commands.add("ompLineage", () => {
  return cy.window().then((win) => {
    const token = JSON.parse(win.localStorage.getItem("USER_INFO")).token;

    return cy
      .request({
        method: "GET",
        url: "http://localhost:8080/user",
        headers: {
          Authorization: `Bearer ${token}`,
        },
      })
      .then((response) => {
        const { merchant_id, org_id, profile_id } = response.body;

        return {
          org_id,
          merchant_id,
          profile_id,
        };
      });
  });
});
