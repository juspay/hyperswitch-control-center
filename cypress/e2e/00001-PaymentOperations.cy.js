const dateRangeOptions = [
  "Last 30 Mins",
  "Last 1 Hour",
  "Last 2 Hours",
  "Today",
  "Yesterday",
  "Last 2 Days",
  "Last 7 Days",
  "Last 30 Days",
  "This Month",
  "Last Month",
];

const filterOptions = [
  "Connector",
  "Currency",
  "Status",
  "Payment Method",
  "Authentication Type",
  "Payment Method Type",
];

const paymentOperationTableColumns = [
  "S.No",
  "Payment ID",
  "Connector",
  "Connector Transaction ID",
  "Amount",
  "Payment Status",
  "Payment Method",
  "Payment Method Type",
  "Card Network",
  "Customer Email",
  "Merchant Order Reference Id",
  "Description",
  "Metadata",
  "Created",
];

const dummyPaymentData = {
  dropdownOption: "Germany (EUR)",
  currency: "EUR",
  amount: "101",
  cardDetails: {
    cardNo: "4242424242424242",
    expiry: "0532",
    cvv: "567",
  },
};

let username = `cypress+${Math.round(+new Date() / 1000)}@gmail.com`;

describe("connector", () => {
  // Login before each testcase
  beforeEach(() => {
    cy.login_UI(username);
  });

  it("Verify Default Elements on Payment Operations Page", () => {
    // Navigate to the "Payment Operations" page using the side menu.
    cy.navigateFromSideMenu("Operations/Payments");
    // Verify the URL to ensure the redirection to the "Payment Operations" page.
    cy.url().should("include", `/dashboard/payments`);
    // Verify the search box is present with the placeholder "Search payment id."

    cy.get('[data-id="Search payment id"]')
      .should("be.visible")
      .find("input")
      .should("have.attr", "placeholder", "Search payment id");

    // Verify the dropdown to select the time range is present.
    cy.get("[data-component-field-wrapper=field-start_time-end_time]")
      .should("be.visible")
      .within(() => {
        cy.get("button").click({ force: true });
      });
    // Verify the predefined options are present in the dropdown.
    cy.get('[data-date-picker-predifined="predefined-options"]').within(() => {
      dateRangeOptions.forEach((option) =>
        cy
          .get(`[data-daterange-dropdown-value="${option}"]`)
          .should("have.text", option),
      );
    });

    // Verify the "Add Filters" button is present and visible.
    cy.clickOnElementWithText("button", "Add Filters");
    // Verify the filter options are present in the dropdown.
    cy.get('[role="menu"]').within(() => {
      filterOptions.forEach((option, index) =>
        cy.get("button").eq(index).should("have.text", option),
      );
    });
  });

  it("Verify Payments Displayed", () => {
    // Make  payment.
    cy.createDummyPayment(dummyPaymentData);
    // Navigate to the "Payment Operations" page using the side menu.
    cy.navigateFromSideMenu("Operations/Payments");
    // Verify the URL to ensure the redirection to the "Payment Operations" page.
    cy.url().should("include", `/dashboard/payments`);

    // These assertions will pass only if the payments are visible in the table.
    // Verify the table contains the following columns.
    cy.get("table").within(() => {
      paymentOperationTableColumns.forEach((column, index) =>
        cy.get("th").eq(index).should("have.text", column),
      );
    });

    // Verify the "Generate reports" button is present and visible.
    cy.get("[data-button-for=generateReports]").should("exist");
    // Verify the "Customize columns" button is present and visible.
    cy.get("[data-button-for=CustomIcon]").should("exist");
  });
});
