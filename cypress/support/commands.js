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

Cypress.Commands.add("getByTestId", (testId) => {
  return cy.get(`[data-testid="${testId}"]`);
});

Cypress.Commands.add("clickOnElementWithText", (selector, text) => {
  cy.contains(selector, text).should("be.visible").click();
});

Cypress.Commands.add("navigateFromSideMenu", (menuItem) => {
  if (menuItem.includes("/")) {
    const [firstMenu, secondMenu] = menuItem
      .split("/")
      .map((item) => item.toLowerCase().replace(/\s/g, ""));

    cy.get(`[data-testid=${firstMenu}]`).click();
    cy.get(`[data-testid=${secondMenu}]`).click();
  } else {
    cy.get(`[data-testid=${menuItem.toLowerCase()}]`).click();
  }
});

Cypress.Commands.add("createDummyPayment", (data) => {
  cy.navigateFromSideMenu("Connectors/Payment Processors");
  cy.navigateFromSideMenu("Home");
  cy.get("[data-button-for=tryItOut]").click();

  cy.get('[data-value="unitedStates(USD)"]').click();
  cy.get(`[data-dropdown-value="${data?.dropdownOption}"]`).click();
  cy.get("[data-testid=amount]").find("input").clear().type(data?.amount);
  cy.get("[data-button-for=showPreview]").click();

  cy.get("iframe", {
    timeout: 25000,
  })
    .first()
    .then(($iframe) => {
      expect($iframe).to.exist;
      cy.wrap($iframe)
        .its("0.contentDocument.body")
        .should("not.be.empty")
        .then(cy.wrap)
        .find("[data-testid=cardNoInput]", { timeout: 25000 })
        .type(data?.cardDetails?.cardNo);

      cy.wrap($iframe)
        .its("0.contentDocument.body")
        .should("not.be.empty")
        .then(cy.wrap)
        .find("[data-testid=expiryInput]")
        .type(data?.cardDetails?.expiry);

      cy.wrap($iframe)
        .its("0.contentDocument.body")
        .should("not.be.empty")
        .then(cy.wrap)
        .find("[data-testid=cvvInput]")
        .type(data?.cardDetails?.cvv, {
          force: true,
        });
    });

  cy.clickOnElementWithText("button", `Pay ${data?.currency} ${data?.amount}`);
  cy.wait(400);
});

Cypress.Commands.add("login_UI", (name = "", pass = "") => {
  cy.visit("http://localhost:9000");
  const username = name.length > 0 ? name : Cypress.env("CYPRESS_USERNAME");
  const password = pass.length > 0 ? pass : Cypress.env("CYPRESS_PASSWORD");
  cy.get("[data-testid=email]").type(username);
  cy.get("[data-testid=password]").type(password);
  cy.get('button[type="submit"]').click({ force: true });
  cy.get("[data-testid=skip-now]").click({ force: true });
});

Cypress.Commands.add("register_UI", (name = "", pass = "") => {
  const username = name.length > 0 ? name : Cypress.env("CYPRESS_USERNAME");
  const password = pass.length > 0 ? pass : Cypress.env("CYPRESS_PASSWORD");
  cy.visit("http://localhost:9000");
  cy.get("#card-subtitle").click();
  cy.url().should("include", "/register");
  cy.get("[data-testid=email]").type(username);
  cy.get("[data-testid=password]").type(password);
  cy.get('button[type="submit"]').click({ force: true });
  cy.clickOnElementWithText("button", "Skip now");
  cy.url().should("eq", "http://localhost:9000/dashboard/home");
  cy.getByTestId("merchant_name").type("Hyperswitch_test");
  cy.get('[data-button-for="startExploring"]').click();
});

Cypress.Commands.add("singup_curl", (name = "", pass = "") => {
  const username = name.length > 0 ? name : Cypress.env("CYPRESS_USERNAME");
  const password = pass.length > 0 ? pass : Cypress.env("CYPRESS_PASSWORD");
  // /user/signin
  cy.request({
    method: "POST",
    url: `http://localhost:8080/user/signup`,
    headers: {
      "Content-Type": "application/json",
    },
    body: { email: username, password: password, country: "IN" },
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
    url: `http://localhost:8080/user/signin`,
    headers: {
      "Content-Type": "application/json",
    },
    body: { email: username, password: password, country: "IN" },
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
  cy.get("[data-testid=connectors]").click();
  cy.get("[data-testid=paymentprocessors]").click();
  cy.contains("Payment Processors").should("be.visible");
  cy.get('[data-testid="home"]').click();

  cy.get("[data-button-for=tryItOut]").scrollIntoView().click();
  cy.get('[data-breadcrumb="Explore Demo Checkout Experience"]').should(
    "exist",
  );
  cy.get("[data-testid=amount]").find("input").clear().type("77");
  cy.wait(2000);
  cy.get("[data-button-for=showPreview]").click();

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
  cy.contains("Payment Successful").should("be.visible");
  cy.get("[data-button-for=goToPayment]").click();
  cy.url().should("include", "dashboard/payments");
});

const getIframeBody = () => {
  return cy
    .get("iframe", { timeout: 15000 })
    .should("be.visible")
    .should("exist")
    .its("0.contentDocument.body")
    .should("not.be.empty")
    .then(cy.wrap);
};
