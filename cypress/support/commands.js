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

Cypress.Commands.add("login_UI", (name = "", pass = "") => {
  cy.visit("http://localhost:9000");
  const username = name.length > 0 ? name : Cypress.env("CYPRESS_USERNAME");
  const password = pass.length > 0 ? pass : Cypress.env("CYPRESS_PASSWORD");
  cy.get("[data-testid=email]").type(username);
  cy.get("[data-testid=password]").type(password);
  cy.get('button[type="submit"]').click({ force: true });
  cy.get("[data-testid=skip-now]").click({ force: true });
  cy.get('[data-form-label="Business name"]').should("exist");
  cy.get("[data-testid=merchant_name]").type("test_business");
  cy.get("[data-button-for=startExploring]").click();
  cy.reload(true);
});

Cypress.Commands.add("signup_curl", (name = "", pass = "") => {
  // Retrieve the username and password, use environment variables if not provided
  const username = name.length > 0 ? name : Cypress.env("CYPRESS_USERNAME");
  const password = pass.length > 0 ? pass : Cypress.env("CYPRESS_PASSWORD");
  cy.log(`Base URL: ${Cypress.env("baseUrl")}`);
  // Make the signup request
  cy.request({
    method: "POST",
    url: `http://localhost:8080/user/signup`,
    headers: {
      "Content-Type": "application/json",
    },
    body: { email: username, password: password, country: "IN" },
    failOnStatusCode: false, // Allows handling failed requests
  }).then((response) => {
    // Handle different response scenarios
    if (response.status >= 200 && response.status < 300) {
      cy.log("Signup successful");
      expect(response.body).to.have.property("token"); // Expect token if successful
    } else {
      // Handle error response
      cy.log(`Signup failed with status: ${response.status}`);
      //  throw new Error(`Signup request failed with status: ${response.status} and message: ${response.body.message || "No message provided"}`);
    }
  });
});

Cypress.Commands.add("login_curl", (name = "", pass = "") => {
  const username = name.length > 0 ? name : Cypress.env("CYPRESS_USERNAME");
  const password = pass.length > 0 ? pass : Cypress.env("CYPRESS_PASSWORD");
  // /user/signin
  cy.request({
    method: "POST",
    url: `http://localhost:8080/user/signin`,
    headers: {
      "Content-Type": "application/json",
    },
    body: { email: username, password: password, country: "IN" },
  }).then((response) => {
    // Assuming the token is returned in the response body as "token"
    const token = response.body.token;

    // Save token in Cypress environment for future use
    Cypress.env("token", token);

    // Optionally, log the token (for debugging)
    cy.log("Token saved in Cypress.env: ", Cypress.env("token"));
  });
});

Cypress.Commands.add("deleteConnector", (mca_id) => {
  let token = window.localStorage.getItem("login");
  let { merchant_id = "" } = JSON.parse(
    window.localStorage.getItem("merchant"),
  );
  cy.request({
    method: "DELETE",
    url: `http://localhost:8080/account/${merchant_id}/connectors/${mca_id}`,
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
  });
});

// Utility to log request IDs for easier debugging
const logRequestId = (requestId) => {
  cy.log(`Request ID: ${requestId}`);
};

// Cypress command to log in the user and retrieve TOTP token
Cypress.Commands.add("userLogin", () => {
  const baseUrl = Cypress.env("baseUrl");
  const email = Cypress.env("email");
  const password = Cypress.env("password");
  const url = `${baseUrl}/user/v2/signin?token_only=true`;

  cy.request({
    method: "POST",
    url: url,
    headers: {
      "Content-Type": "application/json",
    },
    body: { email, password },
    failOnStatusCode: false,
  }).then((response) => {
    logRequestId(response.headers["x-request-id"]);

    if (response.status === 200 && response.body.token_type === "totp") {
      expect(response.body).to.have.property("token").and.to.not.be.empty;

      Cypress.env("totpToken", response.body.token);
    } else {
      throw new Error(
        `User login failed with status ${response.status}: ${response.body.message}`,
      );
    }
  });
});

// Cypress command to terminate 2FA and get user info token
Cypress.Commands.add("terminate2Fa", () => {
  const baseUrl = Cypress.env("baseUrl");
  const totpToken = Cypress.env("totpToken");
  const url = `${baseUrl}/user/2fa/terminate?skip_two_factor_auth=true`;

  cy.request({
    method: "GET",
    url: url,
    headers: {
      Authorization: `Bearer ${totpToken}`,
      "Content-Type": "application/json",
    },
    failOnStatusCode: false,
  }).then((response) => {
    logRequestId(response.headers["x-request-id"]);

    if (response.status === 200 && response.body.token_type === "user_info") {
      expect(response.body).to.have.property("token").and.to.not.be.empty;

      Cypress.env("userInfoToken", response.body.token);

      // Store the token in localStorage in the required format {"token": "<actual_token>"}
      cy.window().then((window) => {
        const tokenObject = {
          token: response.body.token,
        };
        window.localStorage.setItem("USER_INFO", JSON.stringify(tokenObject));
      });
    } else {
      throw new Error(
        `2FA termination failed with status ${response.status}: ${response.body.message}`,
      );
    }
  });
});

// Cypress command to fetch user info and store IDs
Cypress.Commands.add("userInfo", () => {
  const baseUrl = Cypress.env("baseUrl");
  const userInfoToken = Cypress.env("userInfoToken");
  const url = `${baseUrl}/user`;

  cy.request({
    method: "GET",
    url: url,
    headers: {
      Authorization: `Bearer ${userInfoToken}`,
      "Content-Type": "application/json",
    },
    failOnStatusCode: false,
  }).then((response) => {
    logRequestId(response.headers["x-request-id"]);

    // Check for successful response
    if (response.status === 200) {
      // Log the response body for debugging
      console.log("Response Body:", response.body);

      // Assert that the response contains the required keys
      expect(response.body).to.have.property("merchant_id");
      expect(response.body).to.have.property("org_id");
      expect(response.body).to.have.property("profile_id");

      // Set environment variables
      Cypress.env("merchantId", response.body.merchant_id);
      Cypress.env("organizationId", response.body.org_id);
      Cypress.env("profileId", response.body.profile_id);
    } else {
      throw new Error(
        `Failed to fetch user info with status ${response.status}: ${response.body.message || "No message available"}`,
      );
    }
  });
});
