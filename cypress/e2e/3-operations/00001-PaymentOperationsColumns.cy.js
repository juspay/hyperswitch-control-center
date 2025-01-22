import { v4 as uuidv4 } from "uuid";

describe.skip("Payment Operations Page - Columns Customization and Functionalities", () => {
  const TEST_PASSWORD = "Cypress98#";
  const TEST_USERNAME = `cypress_${uuidv4().slice(0, 8)}@example.com`;
  const columnSize = 23;
  const requiredColumnsSize = 14;

  before(() => {
    cy.visit(`/dashboard/login`);
    cy.get("[data-testid=card-subtitle]").contains("Sign up").click();
    cy.url().should("include", "/register");
    cy.get("[data-testid=auth-submit-btn]").should("exist");
    cy.get("[data-testid=tc-text]").should("exist");
    cy.get("[data-testid=footer]").should("exist");
    cy.sign_up_with_email(TEST_USERNAME, TEST_PASSWORD);
    cy.get('[data-form-label="Business name"]').should("exist");
    cy.get("[data-testid=merchant_name]").type("test_business");
    cy.get("[data-button-for=startExploring]").click();
  });

  beforeEach(function () {
    cy.viewport(1280, 720);
    if (this.currentTest.title !== "should create a dummy connector") {
      cy.login_UI(TEST_USERNAME, TEST_PASSWORD);
    }
  });

  it("should create a dummy connector", () => {
    cy.create_connector_UI();
  });

  it("should process a payment using the SDK", () => {
    cy.process_payment_sdk_UI();
  });

  it("Should display all default columns and allow selecting/deselecting columns", () => {
    const columns = {
      expected: [
        "Merchant Order Reference Id",
        "Metadata",
        "Payment Status",
        "Payment Method Type",
        "Payment Method",
        "Payment ID",
        "Customer Email",
        "Description",
        "Created",
        "Connector Transaction ID",
        "Connector",
        "Amount",
        "AmountCapturable",
        "Authentication Type",
        "Profile Id",
        "Capture Method",
        "Client Secret",
        "Currency",
        "Customer ID",
        "Merchant ID",
        "Setup Future Usage",
        "Attempt count",
      ],
      optional: [
        "AmountCapturable",
        "Authentication Type",
        "Capture Method",
        "Client Secret",
        "Currency",
        "Customer ID",
        "Merchant ID",
        "Setup Future Usage",
        "Attempt count",
      ],
      mandatory: [
        "Merchant Order Reference Id",
        "Metadata",
        "Payment Status",
        "Payment Method Type",
        "Payment Method",
        "Payment ID",
        "Customer Email",
        "Description",
        "Created",
        "Connector Transaction ID",
        "Connector",
        "Amount",
      ],
    };

    cy.get('[data-testid="operations"]').click();
    cy.get('[data-testid="payments"]').click();
    cy.get('button[data-button-for="CustomIcon"]').click();

    columns.expected.forEach((column) => {
      cy.contains(column).should("exist");
    });

    cy.get(
      '[data-component="modal:Table Columns"] [data-dropdown-numeric]',
    ).each(($el) => {
      cy.wrap($el).click();
    });

    cy.contains("button", `${columnSize} Columns Selected`).should(
      "be.visible",
    );

    columns.optional.forEach((column) => {
      cy.get(`[data-dropdown-value="${column}"]`).click();
    });

    cy.contains("button", `${requiredColumnsSize} Columns Selected`).should(
      "be.visible",
    );

    cy.get(
      '[data-component="modal:Table Columns"] [data-icon="modal-close-icon"]',
    ).click();

    columns.mandatory.forEach((column) => {
      cy.get(`[data-table-heading="${column}"]`).should("exist");
    });

    columns.optional.forEach((column) => {
      cy.get(`[data-table-heading="${column}"]`).should("not.exist");
    });
  });

  it("Should display matching columns when searching for valid column names", () => {
    cy.get('[data-testid="operations"]').click();
    cy.get('[data-testid="payments"]').click();
    cy.get('button[data-button-for="CustomIcon"]').should("be.visible").click();
    cy.get(".border > .rounded-md").should(
      "be.visible",
      "have.attr",
      "placeholder",
      `Search in ${columnSize} options`,
    );

    ["Merchant", "Profile", "Payment"].forEach((searchTerm) => {
      cy.get(`input[placeholder="Search in ${columnSize} options"]`)
        .clear()
        .type(searchTerm);
      cy.contains(searchTerm).should("exist");
    });
  });

  it("Should show 'No matching records found' when searching for invalid column names", () => {
    cy.get('[data-testid="operations"]').click();
    cy.get('[data-testid="payments"]').click();

    cy.get('button[data-button-for="CustomIcon"]').click();
    cy.get(`input[placeholder="Search in ${columnSize} options"]`).should(
      "be.visible",
    );

    ["abacd", "something", "createdAt"].forEach((searchTerm) => {
      cy.get(`input[placeholder="Search in ${columnSize} options"]`)
        .clear()
        .type(searchTerm);
      cy.contains("No matching records found").should("be.visible");
    });
    cy.get('[data-icon="searchExit"]').click();
    cy.get(
      '[data-component="modal:Table Columns"] [data-dropdown-numeric]',
    ).should("have.length", columnSize);
  });
});
