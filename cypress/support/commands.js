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
