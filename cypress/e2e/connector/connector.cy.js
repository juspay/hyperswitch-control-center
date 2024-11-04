describe("connector", () => {
  const password = "Cypress98#";
  const username = `cypress${Math.round(+new Date() / 1000)}@gmail.com`;

  const getIframeBody = () => {
    return cy
      .get("iframe")
      .its("0.contentDocument.body")
      .should("not.be.empty")
      .then(cy.wrap);
  };

  const selectRange = (range, shouldPaymentExist) => {
    cy.get("[data-date-picker=dateRangePicker]").click();
    cy.get("[data-date-picker-predifined=predefined-options]").should(
      "be.visible",
    );
    cy.get(`[data-daterange-dropdown-value="${range}"]`)
      .should("be.visible")
      .click();
    if (shouldPaymentExist) {
      cy.get("[data-table-location=Orders_tr1_td1]").should("exist");
    } else {
      cy.get("[data-table-location=Orders_tr1_td1]").should("not.exist");
    }
  };

  before(() => {
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

    cy.get('[data-form-label="Business name"]').should("exist");
    cy.get("[data-testid=merchant_name]").type("test_business");
    cy.get("[data-button-for=startExploring]").click();
  });

  beforeEach(function () {
    if (this.currentTest.title !== "Create a dummy connector") {
      cy.visit("http://localhost:9000/dashboard/login");
      cy.url().should("include", "/login");
      cy.get("[data-testid=card-header]").should(
        "contain",
        "Hey there, Welcome back!",
      );
      cy.get("[data-testid=email]").type(username);
      cy.get("[data-testid=password]").type(password);
      cy.get('button[type="submit"]').click({ force: true });
      cy.get("[data-testid=skip-now]").click({ force: true });
    }
  });

  it("Create a dummy connector", () => {
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
  it("Use the SDK to process a payment", () => {
    cy.get("[data-testid=connectors]").click();
    cy.get("[data-testid=paymentprocessors]").click();
    cy.contains("Payment Processors").should("be.visible");
    cy.get("[data-testid=home]").click();
    cy.get("[data-button-for=tryItOut]").click();
    cy.get('[data-breadcrumb="Explore Demo Checkout Experience"]').should(
      "exist",
    );
    cy.get('[data-value="unitedStates(USD)"]').click();
    cy.get('[data-dropdown-value="Germany (EUR)"]').click();
    cy.get("[data-testid=amount]").find("input").clear().type("77");
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
      .type("492", { force: true });
    cy.get("[data-button-for=payEUR77]").should("exist").click();
    cy.contains("Payment Successful").should("be.visible");
    cy.get("[data-button-for=goToPayment]").should("exist").click();
    cy.url().should("include", "dashboard/payments");
  });
  it("Verify Time Range Filters after Payment in Payment Operations Page", () => {
    cy.get("[data-testid=operations]").click();
    cy.get("[data-testid=payments]").click();
    cy.contains("Payment Operations").should("be.visible");
    const today = new Date();
    const date30DaysAgo = new Date(today);
    date30DaysAgo.setDate(today.getDate() - 30);
    const formattedDate30DaysAgo =
      date30DaysAgo.toLocaleDateString("en-US", {
        year: "numeric",
        month: "short",
        day: "2-digit",
      }) + " - Now";
    cy.get(`[data-button-text='${formattedDate30DaysAgo}']`).should("exist");
    cy.get("[data-table-location=Orders_tr1_td1]").should("exist");
    cy.get("[data-icon=customise-columns]").should("exist");

    const timeRanges = [
      { range: "Last 30 Mins", shouldPaymentExist: true },
      { range: "Last 1 Hour", shouldPaymentExist: true },
      { range: "Last 2 Hours", shouldPaymentExist: true },
      { range: "Today", shouldPaymentExist: true },
      { range: "Yesterday", shouldPaymentExist: false },
      { range: "Last 2 Days", shouldPaymentExist: true },
      { range: "Last 7 Days", shouldPaymentExist: true },
      { range: "Last 30 Days", shouldPaymentExist: true },
      { range: "This Month", shouldPaymentExist: true },
      { range: "Last Month", shouldPaymentExist: false },
    ];

    timeRanges.forEach(({ range, shouldPaymentExist }) => {
      selectRange(range, shouldPaymentExist);
    });
  });
  it("Verify Custom Range in Time Range Filters after Payment in Payment Operations Page", () => {
    cy.get("[data-testid=operations]").click();
    cy.get("[data-testid=payments]").click();
    cy.contains("Payment Operations").should("be.visible");
    const today = new Date();
    const date30DaysAgo = new Date(today);
    date30DaysAgo.setDate(today.getDate() - 30);
    const formattedDate30DaysAgo = date30DaysAgo.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "2-digit",
    });
    cy.get(`[data-button-text='${formattedDate30DaysAgo} - Now']`).should(
      "exist",
    );
    cy.get(`[data-button-text='${formattedDate30DaysAgo} - Now']`).click();
    cy.get("[data-date-picker-predifined=predefined-options]").should(
      "be.visible",
    );
    cy.get('[data-daterange-dropdown-value="Custom Range"]')
      .should("be.visible")
      .click();
    cy.get("[data-date-picker-section=date-picker-calendar]").should(
      "be.visible",
    );
    const formattedDate = today.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "2-digit",
    });
    const selectDate = today.toLocaleDateString("en-US", {
      year: "numeric",
      month: "short",
      day: "numeric",
    });

    cy.get(`[data-testid="${selectDate}"]`).click();
    cy.get("[data-button-for=apply]").click();
    cy.get(
      `[data-button-text='${formattedDate30DaysAgo} - ${formattedDate}']`,
    ).should("exist");
    cy.get("[data-table-location=Orders_tr1_td1]").should("exist");
  });
});
