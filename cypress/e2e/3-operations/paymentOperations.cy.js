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
    paymentOperations.transactionView
      .children()
      .eq(0)
      .should("have.text", "All0");
    paymentOperations.transactionView
      .children()
      .eq(1)
      .should("have.text", "Succeeded0");
    paymentOperations.transactionView
      .children()
      .eq(2)
      .should("have.text", "Failed0");
    paymentOperations.transactionView
      .children()
      .eq(3)
      .should("have.text", "Dropoffs0");
    paymentOperations.transactionView
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
          paymentOperations.transactionView
            .children()
            .eq(0)
            .should("have.text", "All1");
          paymentOperations.transactionView
            .children()
            .eq(1)
            .should("have.text", "Succeeded1");

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

  // Columns
  it("should display all default columns and allow selecting/deselecting columns", () => {
    const columns = {
      expected: [
        "Card Network",
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
        "Profile Id",
        "Amount",
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
        "Card Network",
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
        "Profile Id",
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

    paymentOperations.columnButton.click();

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

  it("should display matching columns when searching for valid column names", () => {
    let columns = [
      "Card Network",
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
      "Profile Id",
      "Amount",
      "AmountCapturable",
      "Authentication Type",
      "Capture Method",
      "Client Secret",
      "Currency",
      "Customer ID",
      "Merchant ID",
      "Setup Future Usage",
      "Attempt count",
    ];

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

    paymentOperations.columnButton.click();
    cy.get(".border > .rounded-md").should(
      "be.visible",
      "have.attr",
      "placeholder",
      `Search in ${columnSize} options`,
    );

    columns.forEach((searchTerm) => {
      cy.get(`input[placeholder="Search in ${columnSize} options"]`)
        .clear()
        .type(searchTerm);
      cy.contains(searchTerm).should("exist");
    });
  });

  it("should show 'No matching records found' when searching for invalid column names", () => {
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

    paymentOperations.columnButton.click();
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

  it("should display all selected columns in payments table", () => {
    const expectedColumns = [
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
      "AmountCapturable",
      "Authentication Type",
      "Capture Method",
      "Client Secret",
      "Currency",
      "Customer ID",
      "Merchant ID",
      "Setup Future Usage",
      "Attempt count",
    ];

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

    paymentOperations.columnButton.click();

    cy.get(
      '[data-component="modal:Table Columns"] [data-dropdown-numeric]',
    ).each(($el) => {
      cy.wrap($el).click();
    });

    cy.contains("button", `${columnSize} Columns Selected`).click();

    cy.get("table thead tr th").each(($el, index) => {
      cy.wrap($el).should("have.text", expectedColumns[index]);
    });
  });

  // Search bar
  it("should display correct payment when searched with payment ID", () => {
    let merchant_id;
    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
        cy.createPaymentAPI(merchant_id);
        cy.createPaymentAPI(merchant_id);
      });

    homePage.operations.click();
    homePage.paymentOperations.click();

    // Copy First Payment ID
    paymentOperations.paymentIdCopyButton
      .children()
      .eq(0)
      .click({ force: true });

    // Paste Payment ID and search
    cy.window()
      .its("navigator.clipboard")
      .then((clip) => clip.readText())
      .then((text) => {
        paymentOperations.searchBox.type(text + "{enter}");

        cy.get(
          '[class="flex text-blue-811 text-sm font-extrabold cursor-pointer"]',
        ).click();

        cy.get('[data-table-location="Orders_tr1_td2"]').should(
          "contain",
          text,
        );
      });

    paymentOperations.searchBox.clear();

    // Copy Second Payment ID
    paymentOperations.paymentIdCopyButton
      .children()
      .eq(1)
      .click({ force: true });

    // Paste Payment ID and search
    cy.window()
      .its("navigator.clipboard")
      .then((clip) => clip.readText())
      .then((text) => {
        paymentOperations.searchBox.type(text + "{enter}");

        cy.get(
          '[class="flex text-blue-811 text-sm font-extrabold cursor-pointer"]',
        ).click();

        cy.get('[data-table-location="Orders_tr1_td2"]').should(
          "contain",
          text,
        );
      });
  });

  it("should display a valid message and expand search timerange button when searched with invalid payment ID", () => {
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

    paymentOperations.searchBox.type("Some_ID{enter}");

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

  it("should extend the time range by 90 days", () => {
    homePage.operations.click();
    homePage.paymentOperations.click();

    // Get the current time range string
    paymentOperations.dateSelector
      .invoke("text")
      .should("not.contain", "Select Date")
      .then((initialRange) => {
        const startDateStr = initialRange.split("-")[0].trim();

        // Parse the date using JavaScript Date
        const parsedStartDate = new Date(startDateStr);
        const previousStartDate = new Date(parsedStartDate);
        previousStartDate.setDate(parsedStartDate.getDate() - 90);

        // Format the new expected range
        const formatDate = (date) => {
          return date.toLocaleDateString("en-US", {
            month: "short",
            day: "numeric",
            year: "numeric",
          });
        };

        const expectedStart = formatDate(previousStartDate);
        const expectedEnd = formatDate(parsedStartDate);

        const expectedRange = `${expectedStart} - ${expectedEnd}`;

        cy.get(
          '[data-button-for="expandTheSearchToThePrevious90Days"]',
        ).click();

        paymentOperations.dateSelector.should("contain", expectedRange);
      });
  });

  // search with invalid ID and expand search verify time range changed

  // Filters
  // Views
  // Date Selector
  // Payment details page
});
