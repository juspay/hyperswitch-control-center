describe("connector", () => {
  const username = `cypress${Math.round(+new Date() / 1000)}@gmail.com`;
  const password = "Cypress98#";

  // Login before each testcase
  beforeEach(() => {
    cy.visit("http://localhost:9000/dashboard/login");
    cy.url().should("include", "/login");
    cy.get("[data-testid=card-header]").should(
      "contain",
      "Hey there, Welcome back!",
    );
    cy.get("[data-testid=card-subtitle]")
      .should("contain", "Sign up")
      .click({ force: true });
    cy.url().should("include", "/register");
    cy.get("[data-testid=auth-submit-btn]").should("exist");
    cy.get("[data-testid=tc-text]").should("exist");
    cy.get("[data-testid=footer]").should("exist");

    cy.get("[data-testid=email]").type(username);
    cy.get("[data-testid=password]").type(password);
    cy.get('button[type="submit"]').click({ force: true });
    cy.get("[data-testid=skip-now]").click({ force: true });

    cy.url().should("include", "/dashboard/home");
  });

  it("Create a dummy connector", () => {
    cy.url().should("include", "/dashboard/home");

    cy.get('[data-form-label="Business name"]').should("exist");
    cy.get("[data-testid=merchant_name]").type("test_business");
    cy.get("[data-button-for=startExploring]").click();
    cy.reload(true);
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
});
