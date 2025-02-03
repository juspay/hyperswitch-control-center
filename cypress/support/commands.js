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

import {
  hasPermission,
  hasAccessLevelPermission,
} from "../support/permissions";

const signinPage = new SignInPage();

// Custom command to check permissions and decide whether to skip or run the test
Cypress.Commands.add("checkPermissionsFromTestName", (testName) => {
  const userRole = Cypress.env("role") || "admin"; // Role passed via environment (default 'admin')
  const userAccessLevel = Cypress.env("accessLevel") || "org"; // Access level passed via environment (default 'org')

  // Extract tags from the test name using a regex
  const regex = /@([a-zA-Z0-9_-]+)/g;
  const tags = [...testName.matchAll(regex)].map((match) => match[1]);

  // Parse the tags
  const sectionTag = tags.find((tag) =>
    ["analytics", "workflow", "operations"].includes(tag),
  ); // Assuming section names are one of these
  const accessLevelTag = tags.find((tag) =>
    ["org", "merchant", "profile"].includes(tag),
  );
  const permissionTag = tags.find((tag) => ["read", "write"].includes(tag));

  // Default values if no tags are found in the name
  const requiredSection = sectionTag || "analytics"; // Default to 'analytics'
  const requiredAccessLevel = accessLevelTag || "org"; // Default to 'org'
  const requiredPermission = permissionTag || "read"; // Default to 'read'

  // If the test case mentions 'profile', allow all access levels
  if (tags.includes("profile")) {
    Cypress.log({
      name: "Test Skipped",
      message: `Test has 'profile' tag, allowing all access levels for ${requiredSection}`,
    });
    // Allow any access level, but we still need to check permissions and roles
  } else if (userAccessLevel !== requiredAccessLevel) {
    // Skip the test if access level doesn't match
    Cypress.log({
      name: "Test Skipped",
      message: `Skipping ${requiredSection} test due to incorrect access level`,
    });
    Cypress._.skip(); // Skip the test
    return;
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
    Cypress._.skip(); // Skip the test
    return;
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
    Cypress._.skip(); // Skip the test
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

Cypress.Commands.add("singup_curl", (name = "", pass = "") => {
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

Cypress.Commands.add("login_curl", (name = "", pass = "") => {
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
  cy.get("[data-testid=email]").type(username);
  cy.get("[data-testid=password]").type(password);
  cy.get('button[type="submit"]').click({ force: true });
  cy.get("[data-testid=skip-now]").click({ force: true });
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

Cypress.Commands.add("process_payment_sdk_UI", () => {
  cy.clearCookies("login_token");
  cy.get("[data-testid=connectors]").click();
  cy.get("[data-testid=paymentprocessors]").click();
  cy.contains("Payment Processors").should("be.visible");
  cy.get("[data-testid=home]").eq(1).click();
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

const selectors = {
  email: "[data-testid=email]",
  password: "[data-testid=password]",
  createPassword: "[data-testid=create_password]",
  comfirmPassword: "[data-testid=comfirm_password]",
  submitButton: 'button[type="submit"]',
  authSubmitButton: '[data-testid="auth-submit-btn"]',
  skipNowButton: "[data-testid=skip-now]",
  cardHeader: "[data-testid=card-header]",
};

Cypress.Commands.add("sign_up_with_email", (username, password) => {
  const MAIL_URL = "http://localhost:8025";
  cy.url().should("include", "/register");
  cy.get(selectors.email).type(username);
  cy.get(selectors.authSubmitButton).click();
  cy.get("[data-testid=card-header]").should(
    "contain",
    "Please check your inbox",
  );
  cy.visit(`${MAIL_URL}`);
  cy.get("div.messages > div:nth-child(2)").click();
  cy.wait(1000);
  cy.get("iframe").then(($iframe) => {
    // Verify email
    const doc = $iframe.contents();
    const verifyEmail = doc.find("a").get(0);
    cy.visit(verifyEmail.href);
    cy.get(selectors.skipNowButton).click();
    // Set password
    cy.get(selectors.createPassword).type(password);
    cy.get(selectors.comfirmPassword).type(password);
    cy.get("#auth-submit-btn").click();
    // Login to dashboard
    cy.get(selectors.email).type(username);
    cy.get(selectors.password).type(password);
    cy.get(selectors.authSubmitButton).click();
    // Skip 2FA
    cy.get(selectors.skipNowButton).click();
  });
});

const getIframeBody = () => {
  return cy
    .get("iframe")
    .its("0.contentDocument.body")
    .should("not.be.empty")
    .then(cy.wrap);
};
