import * as helper from "../../support/helper";
import HomePage from "../../support/pages/homepage/HomePage";
import PaymentOperations from "../../support/pages/operations/PaymentOperations";

const homePage = new HomePage();
const paymentOperations = new PaymentOperations();

beforeEach(function () {
  const email = helper.generateUniqueEmail();
  cy.signup_API(email, Cypress.env("CYPRESS_PASSWORD"));
  cy.login_UI(email, Cypress.env("CYPRESS_PASSWORD"));
});

const columnSize = 23;
const requiredColumnsSize = 14;

describe("Payment Operations", () => {
  it("should verify all components in Payment Operations page", () => {
    homePage.operations.click();
    homePage.paymentOperations.click();

    //Header
    cy.get(`[class="text-fs-28 font-semibold leading-10 "]`).should(
      "contain",
      "Payment Operations",
    );

    // Transaction view
    cy.get(`[class="flex gap-6 justify-around"]`)
      .children()
      .eq(0)
      .should("have.text", "All0");
    cy.get(`[class="flex gap-6 justify-around"]`)
      .children()
      .eq(1)
      .should("have.text", "Succeeded0");
    cy.get(`[class="flex gap-6 justify-around"]`)
      .children()
      .eq(2)
      .should("have.text", "Failed0");
    cy.get(`[class="flex gap-6 justify-around"]`)
      .children()
      .eq(3)
      .should("have.text", "Dropoffs0");
    cy.get(`[class="flex gap-6 justify-around"]`)
      .children()
      .eq(4)
      .should("have.text", "Cancelled0");

    // Search box
    paymentOperations.searchBox.should(
      "have.attr",
      "placeholder",
      "Search for payment ID",
    );

    //Date selector, View dropdown, Add filters
    paymentOperations.dateSelector.should("be.visible");
    paymentOperations.viewDropdown.should("be.visible");
    paymentOperations.addFilters.should("be.visible");

    cy.get(`[class="items-center text-2xl text-black font-bold mb-4"]`).should(
      "have.text",
      "No results found",
    );
    cy.get(`[data-button-for="expandTheSearchToThePrevious90Days"]`).should(
      "have.text",
      "Expand the search to the previous 90 days",
    );
    cy.get(`[class="flex justify-center"]`).should(
      "have.text",
      "Or try the following:Try a different search parameterAdjust or remove filters and search once more",
    );
  });

  it("should verify all components in Payment Operations page when a payment exists", () => {
    let merchant_id;
    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
        cy.createPaymentAPI(merchant_id).then((response) => {
          homePage.operations.click();
          homePage.paymentOperations.click();

          //Header
          cy.get(`[class="text-fs-28 font-semibold leading-10 "]`).should(
            "contain",
            "Payment Operations",
          );

          // Transaction view
          cy.get(`[class="flex gap-6 justify-around"]`)
            .children()
            .eq(0)
            .should("have.text", "All1");
          cy.get(`[class="flex gap-6 justify-around"]`)
            .children()
            .eq(3)
            .should("have.text", "Dropoffs1");

          // Search box
          paymentOperations.searchBox.should(
            "have.attr",
            "placeholder",
            "Search for payment ID",
          );

          // Add filters, Date selector, View dropdown, Column button
          paymentOperations.addFilters.should("be.visible");
          paymentOperations.dateSelector.should("be.visible");
          paymentOperations.viewDropdown.should("be.visible");
          paymentOperations.columnButton.should("be.visible");

          // Table headers
          const expectedHeaders = [
            "S.No",
            "Payment ID",
            "Connector",
            "Profile Id",
            "Amount",
            "Payment Status",
            "Payment Method",
            "Payment Method Type",
            "Card Network",
            "Connector Transaction ID",
            "Customer Email",
            "Merchant Order Reference Id",
            "Description",
            "Metadata",
            "Created",
          ];
          cy.get("table thead tr th").each(($el, index) => {
            cy.wrap($el).should("have.text", expectedHeaders[index]);
          });

          // Payment details in table row
          cy.get(`[data-table-location="Orders_tr1_td1"]`).contains("1");
          cy.get(`[data-table-location="Orders_tr1_td2"]`)
            .contains("...")
            .click();
          cy.get(`[data-table-location="Orders_tr1_td2"]`).contains(
            response.body.payment_id,
          );
          cy.get(`[data-table-location="Orders_tr1_td3"]`).contains(
            "Stripe Dummy",
          );
          cy.get(`[data-table-location="Orders_tr1_td4"]`).contains(
            response.body.profile_id,
          );
          cy.get(`[data-table-location="Orders_tr1_td5"]`).contains(
            `${response.body.amount / 100}` + " " + `${response.body.currency}`,
          );
          cy.get(`[data-table-location="Orders_tr1_td6"]`).contains(
            response.body.status.toUpperCase(),
          );
          cy.get(`[data-table-location="Orders_tr1_td7"]`).contains(
            response.body.payment_method,
          );
          cy.get(`[data-table-location="Orders_tr1_td8"]`).contains(
            response.body.payment_method_type,
          );
          cy.get(`[data-table-location="Orders_tr1_td9"]`).contains("NA");
          cy.get(`[data-table-location="Orders_tr1_td10"]`).contains(
            response.body.connector_transaction_id,
          );
          cy.get(`[data-table-location="Orders_tr1_td11"]`).contains(
            response.body.email,
          );
          cy.get(`[data-table-location="Orders_tr1_td12"]`).contains(
            response.body.merchant_order_reference_id,
          );
          cy.get(`[class="text-sm font-extrabold cursor-pointer"]`).click();
          cy.get(`[data-table-location="Orders_tr1_td13"]`).contains(
            response.body.description,
          );
          cy.get(`[data-table-location="Orders_tr1_td14"]`).contains(
            JSON.stringify(response.body.metadata),
          );
        });
      });
  });

  //Columns
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

    let merchant_id;
    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
        cy.createPaymentAPI(merchant_id);
      });

    homePage.operations.click();
    homePage.paymentOperations.click();

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
    let merchant_id;
    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
        cy.createPaymentAPI(merchant_id);
      });

    homePage.operations.click();
    homePage.paymentOperations.click();

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
    let merchant_id;
    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
        cy.createPaymentAPI(merchant_id);
      });

    homePage.operations.click();
    homePage.paymentOperations.click();

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

  //Search bar
  // Filters
  // Views
  // Date Selector
  // Payment details page
});
