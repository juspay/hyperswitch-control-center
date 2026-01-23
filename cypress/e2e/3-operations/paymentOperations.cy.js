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

const columnSize = 24;
const requiredColumnsSize = 14;

describe("Payment Operations", () => {
  it("should verify all components in Payment Operations page when no payment exists", () => {
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
          cy.get(`[data-table-location="Orders_tr1_td9"]`).contains("N/A");
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
      cy.get(
        `[class="overflow-hidden p-6 pb-12 border-b border-solid  border-slate-300 dark:border-slate-500"]`,
      )
        .contains(column)
        .should("exist");
    });

    cy.get(
      '[data-component="modal:Table Columns"] [data-dropdown-numeric]',
    ).each(($el) => {
      cy.wrap($el).click();
    });

    cy.get('[data-button-text="Save"]').contains("Save").should("be.visible");

    columns.optional.forEach((column) => {
      cy.get(`[data-dropdown-value="${column}"]`).click();
    });

    cy.get('[data-button-text="Save"]').contains("Save").should("be.visible");

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
      "Error Message",
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

    cy.get('[data-button-text="Save"]').contains("Save").should("be.visible");

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

  it.skip("should display a valid message and expand search timerange when searched with invalid payment ID", () => {
    let merchant_id;
    let invalid_paymentID = "invalidID";

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

    paymentOperations.searchBox.should("be.visible");
    paymentOperations.searchBox.type(invalid_paymentID); //failed because it targeted a disabled element.
    paymentOperations.searchBox.type("{enter}");

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

  // Filters
  it("should verify filter dropdown contains all filters", () => {
    const allFilters = [
      "Connector",
      "Currency",
      "Status",
      "Payment Method",
      "Authentication Type",
      "Card Network",
      "Card Discovery",
      "Payment Method Type",
      "Customer Id",
      "Amount",
      "Merchant Order Reference Id",
    ];

    homePage.operations.click();
    homePage.paymentOperations.click();

    paymentOperations.addFilters.click();

    allFilters.forEach((filter) => {
      cy.get('[class="px-1 py-1 overflow-y-auto max-h-96"]')
        .contains(filter)
        .should("exist");
    });
  });

  it("should verify all filters can be selected from 'Add filter' dropdown", () => {
    let merchant_id = "";

    const filterKeys = [
      "Connector",
      "Currency",
      "Status",
      "Payment Method",
      "Authentication Type",
      "Card Network",
      "Card Discovery",
      "Payment Method Type",
      //"Customer Id",
      "Amount",
      //"Merchant Order Reference Id"
    ];

    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
        cy.createPaymentAPI(merchant_id).then((response) => {
          homePage.operations.click();
          homePage.paymentOperations.click();

          filterKeys.forEach((filter) => {
            paymentOperations.addFilters.click();
            cy.get(".mr-5.text-left").contains(filter).click();
            cy.get('[class="flex relative  flex-row  flex-wrap"]').should(
              "contain",
              `Select ${filter}`,
            );
            cy.get('[data-icon="cross-outline"]').click();
          });

          //"Customer Id"
          paymentOperations.addFilters.click();
          cy.get(".mr-5.text-left").contains("Customer Id").click();
          cy.get('[name="customer_id"]')
            .should("be.visible")
            .should("have.attr", "placeholder", "Enter Customer Id...");
          cy.get('[data-icon="cross-outline"]').click();

          //"Merchant Order Reference Id"
          paymentOperations.addFilters.click();
          cy.get(".mr-5.text-left")
            .contains("Merchant Order Reference Id")
            .click();
          cy.get('[name="merchant_order_reference_id"]')
            .should("be.visible")
            .should(
              "have.attr",
              "placeholder",
              "Enter Merchant Order Reference Id...",
            );
        });
      });
  });

  it("should verify applying 'Connector', 'Currency' and 'Status' filters", () => {
    let merchant_id = "";

    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
        cy.createPaymentAPI(merchant_id).then((response) => {
          homePage.operations.click();
          homePage.paymentOperations.click();

          paymentOperations.addFilters.click();
          cy.get(".mr-5.text-left").contains("Connector").click();
          cy.get('[class="flex relative  flex-row  flex-wrap"]').click();
          cy.get('[value="Stripe Test"]').click();
          cy.get('[data-button-text="Apply"]').click();
          cy.get('[class="flex relative  flex-row  flex-wrap"]').should(
            "contain",
            `Stripe Test`,
          );

          paymentOperations.addFilters.click();
          cy.get(".mr-5.text-left").contains("Status").click();
          cy.get('[data-component-field-wrapper="field-status"]').click();
          cy.get('[value="Succeeded"]').click();
          cy.get('[data-button-text="Apply"]').click();
          cy.get('[class="flex relative  flex-row  flex-wrap"]').should(
            "contain",
            `Succeeded`,
          );

          paymentOperations.addFilters.click();
          cy.get(".mr-5.text-left").contains("Currency").click();
          cy.contains("div", "Select Currency").click();
          cy.get('[placeholder="Search..."]').type("USD");
          cy.get('[data-searched-text="USD"]').click();
          cy.get('[data-button-text="Apply"]').click();
          cy.get('[class="flex relative  flex-row  flex-wrap"]').should(
            "contain",
            `USD`,
          );

          cy.get('[data-table-location="Orders_tr1_td3"').should(
            "contain",
            "Stripe",
          );
          cy.get('[data-table-location="Orders_tr1_td6"]').should(
            "contain",
            "SUCCEEDED",
          );
          cy.get('[data-table-location="Orders_tr1_td5"]').should(
            "contain",
            "USD",
          );
        });
      });
  });

  // Date Selector
  it("should extend the time range by 90 days when no payments are listed", () => {
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
            day: "2-digit",
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

  it.skip("should verify all time range filters are displayed in date selector dropdown", () => {
    const timeRangeFilters = [
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
      "Custom Range",
    ];

    homePage.operations.click();
    homePage.paymentOperations.click();

    paymentOperations.dateSelector.should("be.visible").click();
    cy.get('[data-date-picker-predifined="predefined-options"]').should(
      "be.visible",
    );
    cy.get('[data-date-picker-predifined="predefined-options"]')
      .should("exist")
      .should("be.visible")
      .within(() => {
        timeRangeFilters.forEach((option) => {
          cy.contains(option).should("exist");
        });
      });
  });

  it.skip("should verify seletced timerange when predefined timerange is applied from dropdown", () => {
    const predefinedTimeRange = [
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

    homePage.operations.click();
    homePage.paymentOperations.click();

    for (const timeRange of predefinedTimeRange) {
      paymentOperations.dateSelector.click();
      cy.get('[data-date-picker-predifined="predefined-options"]').should(
        "be.visible",
      );
      cy.get('[data-date-picker-predifined="predefined-options"]').within(
        () => {
          cy.contains(timeRange).click();
        },
      );
      cy.get(`[data-testid="date-range-selector"]`).should(
        "contain",
        timeRange,
      );
    }
  });

  it.skip("should verify applied custom timerange is displayed correctly", () => {
    const now = new Date();
    const today = now.getDate();
    const previousMonth = new Date(
      now.setMonth(now.getMonth() - 1),
    ).toLocaleString("default", { month: "short" });
    const currentYear = now.getFullYear();

    const startDate = today === 2 ? 1 : 2;
    const endDate = today === 28 ? 29 : 28;

    const formatDate = (day) => {
      const paddedDay = String(day).padStart(2, "0");
      return `${previousMonth} ${paddedDay}, ${currentYear}`;
    };

    const expectedRange = `${formatDate(startDate)} - ${formatDate(endDate)}`;

    homePage.operations.click();
    homePage.paymentOperations.click();

    paymentOperations.dateSelector.should("be.visible").click();
    cy.get('[data-date-picker-predifined="predefined-options"]').should(
      "be.visible",
    );
    cy.get('[data-daterange-dropdown-value="Custom Range"]')
      .should("exist")
      .should("be.visible")
      .click({ force: true });

    cy.get("[data-testid]")
      .filter(`[data-testid*=" ${startDate},"]`)
      .first()
      .click();
    cy.get("[data-testid]")
      .filter(`[data-testid*=" ${endDate},"]`)
      .first()
      .click();
    cy.get('[data-button-text="Apply"]').click();

    cy.get(`[data-button-text="${expectedRange}"]`).should(
      "contain",
      expectedRange,
    );
  });

  // Views
  it("should verify all transaction filter views are displayed", () => {
    const transactionViews = [
      "All",
      "Succeeded",
      "Failed",
      "Dropoffs",
      "Cancelled",
    ];

    homePage.operations.click();
    homePage.paymentOperations.click();

    paymentOperations.transactionView.should("be.visible").within(() => {
      transactionViews.forEach((view) => {
        cy.contains(view).should("exist");
      });
    });
  });

  it("should switch between different transaction views and verify applied filters", () => {
    const viewFilters = {
      Succeeded: "Succeeded",
      Failed: "Failed",
      Dropoffs: "Requires Payment Method",
      Cancelled: "Cancelled",
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

    for (const [view, filter] of Object.entries(viewFilters)) {
      paymentOperations.transactionView.contains(view).click();

      cy.get('[class="flex relative  flex-row  flex-wrap"]').should(
        "contain",
        filter,
      );
    }
  });

  // Verify "Open in new tab" button for payment ID
  it("should verify open in new tab for a payment", () => {
    let merchant_id = "";

    homePage.merchantID
      .eq(0)
      .invoke("text")
      .then((text) => {
        merchant_id = text;
        cy.createDummyConnectorAPI(merchant_id, "stripe_test_1");
        cy.createPaymentAPI(merchant_id).then((response) => {
          homePage.operations.click();
          homePage.paymentOperations.click();

          cy.get(
            '[class="flex text-blue-811 text-sm font-extrabold cursor-pointer"]',
          ).click();

          cy.get('[class="opacity-70 py-1"]')
            .should("have.attr", "href")
            .then((href) => {
              cy.get('[data-table-location="Orders_tr1_td2"]')
                .invoke("text")
                .then((orderValue) => {
                  cy.ompLineage().then((lineage) => {
                    const expectedUrlPart = `/dashboard/payments/${orderValue}/${lineage.profile_id}/${lineage.merchant_id}/${lineage.org_id}`;
                    expect(href).to.include(expectedUrlPart);
                  });
                });
            });

          cy.get('[class="opacity-70 py-1"]').should(
            "have.attr",
            "target",
            "_blank",
          );
        });
      });
  });

  // Payment details page
  it("should verify all components in Payment Details page - 1", () => {
    cy.ompLineage().then((lineage) => {
      cy.createDummyConnectorAPI(lineage.merchant_id, "stripe_test_1");
      cy.createPaymentAPI(lineage.merchant_id);
    });

    homePage.operations.click();
    homePage.paymentOperations.click();
    cy.get('[data-table-location="Orders_tr1_td1"]').click();

    cy.get('[data-button-text="+ Refund"]').should("be.visible").click();
    cy.get('[data-input-name="amount"]').type("12.34");
    cy.get('[data-button-text="Initiate Refund"]').click();

    //Summary section
    cy.get('[class="font-bold text-lg mb-5"]')
      .eq(0)
      .should("contain", "Summary");
    cy.get('[class="md:text-5xl font-bold"]').should("contain", "123.45 USD");
    cy.get(
      '[class="text-sm text-white font-bold px-3 py-2 rounded-md bg-hyperswitch_green dark:bg-opacity-50"]',
    ).should("contain", "SUCCEEDED");
    cy.get('[data-button-text="+ Refund"]')
      .should("be.visible")
      .should("contain", "+ Refund");
    cy.get('[data-label="Created"]').should("contain", "Created");
    cy.get('[data-label="Last Updated"]').should("contain", "Last Updated");
    cy.get('[data-label="Amount Received"]')
      .should("contain", "Amount Received")
      .should("contain", "123.45 USD");
    cy.get('[data-label="Payment ID"]').should("contain", "Payment ID");
    cy.get('[data-label="Connector Transaction ID"]').should(
      "contain",
      "Connector Transaction ID",
    );
    cy.get('[data-label="Error Message"]').should("contain", "Error Message");

    //About Payment section
    cy.get('[class="font-bold text-lg mb-5"]')
      .eq(1)
      .should("contain", "About Payment");
    cy.get('[data-label="Profile Id"]').should("contain", "Profile Id");
    cy.get('[data-label="Profile Name"]').should("contain", "Profile Name");
    cy.get('[data-label="Payment connector"]').should(
      "contain",
      "Payment connector",
    );
    cy.get('[data-label="Connector Label"]').should(
      "contain",
      "Connector Label",
    );
    cy.get('[data-label="Payment Method"]').should("contain", "Payment Method");
    cy.get('[data-label="Payment Method Type"]').should(
      "contain",
      "Payment Method Type",
    );
    cy.get('[data-label="Auth Type"]').should("contain", "Auth Type");
    cy.get('[data-label="Card Network"]').should("contain", "Card Network");

    cy.get(
      '[class="overflow-hidden border bg-white  border-jp-gray-500 dark:border-jp-gray-960 dark:bg-jp-gray-950 border  "]',
    )
      .eq(0)
      .should("contain", "Events and logs");

    //Payment attempts
    cy.get('[class="flex flex-col gap-4"]')
      .eq(0)
      .should("contain", "Payment Attempts");

    const expectedAttemptColumns = [
      "S.No",
      "Status",
      "Amount",
      "Currency",
      "Connector",
      "Payment Method",
      "Payment Method Type",
    ];

    cy.get("table thead tr th").each(($el, index) => {
      cy.wrap($el).should("have.text", expectedAttemptColumns[index]);
    });

    const expectedAttemptValues = [
      "1",
      "CHARGED",
      "123.45 USD",
      "USD",
      "Stripe Dummy",
      "card",
      "credit",
    ];

    cy.get("table tbody tr td").each(($el, index) => {
      cy.wrap($el).should("have.text", expectedAttemptValues[index]);
    });

    cy.get('[data-table-location="Attempts_tr1_td1"]').click();

    const expectedValues = {
      "Attempt ID": "",
      Status: "CHARGED",
      Amount: "123.45 USD",
      Currency: "USD",
      Connector: "Stripe Dummy",
      "Payment Method": "card",
      "Payment Method Type": "credit",
      "Error Message": "N/A",
      "Connector Transaction ID": "",
      "Capture Method": "automatic",
      "Authentication Type": "three_ds",
      "Cancellation Reason": "N/A",
      "Mandate ID": "N/A",
      "Error Code": "N/A",
      "Payment Token": "N/A",
      "Connector Metadata": "N/A",
      "Payment Experience": "N/A",
      "Reference ID": "N/A",
      "Client Source": "N/A",
      "Client Version": "N/A",
    };
    cy.get('[data-expandable-table="Attempts"]').within(() => {
      Object.entries(expectedValues).forEach(([label, value]) => {
        cy.get(`[data-label="${label}"]`)
          .scrollIntoView()
          .should("be.visible")
          .should("contain", value);
      });
    });

    //Refund attempts
    cy.get('[class="flex flex-col gap-4"]').eq(1).should("contain", "Refunds");

    const expectedRefundAttemptColumns = [
      "S.No",
      "Refund ID",
      "Payment Id",
      "Amount",
      "Refund Status",
      "Created",
      "Last Updated",
    ];

    cy.get('table[data-expandable-table="Refunds"]').within(() => {
      cy.get("thead tr th").each(($el, index) => {
        cy.wrap($el).should("have.text", expectedRefundAttemptColumns[index]);
      });
    });

    cy.get('[data-table-location="Refunds_tr1_td1"]').click();

    const expectedRefundValues = {
      "Refund ID": "",
      "Payment Id": "",
      "Refund Status": "SUCCEEDED",
      Amount: "12.34 USD",
      Currency: "USD",
      "Refund Reason": "N/A",
      "Error Message": "N/A",
    };
    cy.get('[data-expandable-table="Refunds"]').within(() => {
      Object.entries(expectedRefundValues).forEach(([label, value]) => {
        cy.get(`[data-label="${label}"]`)
          .scrollIntoView()
          .should("be.visible")
          .should("contain", value);
      });
    });
  });

  // In progress
  it.skip("should verify all components in Payment Details page - 2", () => {
    cy.ompLineage().then((lineage) => {
      cy.createDummyConnectorAPI(lineage.merchant_id, "stripe_test_1");
      cy.createPaymentAPI(lineage.merchant_id);
    });

    homePage.operations.click();
    homePage.paymentOperations.click();
    cy.get('[data-table-location="Orders_tr1_td1"]').click();

    cy.get('[data-button-text="+ Refund"]').should("be.visible").click();
    cy.get('[data-input-name="amount"]').type("12.34");
    cy.get('[data-button-text="Initiate Refund"]').click();
  });

  // Refund cases amount less , more and equal to payment amount

  // generate reports
});
