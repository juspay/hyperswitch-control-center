import { test, expect } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentOperations } from "../../support/pages/operations/PaymentOperations";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUser,
  loginUI,
  createDummyConnector,
  createAPIKey,
  createPayment,
  ompLineage,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";
const columnSize = 24;
const requiredColumnsSize = 14;

test.describe("Payment Operations", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should verify all components in Payment Operations page when no payment exists", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    await expect(
      page.locator('[class="text-fs-28 font-semibold leading-10 "]'),
    ).toContainText("Payment Operations");

    await expect(
      paymentOperations.transactionView.locator("> div").nth(0),
    ).toHaveText("All0");
    await expect(
      paymentOperations.transactionView.locator("> div").nth(1),
    ).toHaveText("Succeeded0");
    await expect(
      paymentOperations.transactionView.locator("> div").nth(2),
    ).toHaveText("Failed0");
    await expect(
      paymentOperations.transactionView.locator("> div").nth(3),
    ).toHaveText("Dropoffs0");
    await expect(
      paymentOperations.transactionView.locator("> div").nth(4),
    ).toHaveText("Cancelled0");

    await expect(paymentOperations.searchBox).toHaveAttribute(
      "placeholder",
      "Search for payment ID",
    );

    await expect(paymentOperations.dateSelector).toBeVisible();
    await expect(paymentOperations.viewDropdown).toBeVisible();
    await expect(paymentOperations.addFilters).toBeVisible();

    await expect(
      page.locator('[class="items-center text-2xl text-black font-bold mb-4"]'),
    ).toHaveText("No results found");
    await expect(
      page.locator('[data-button-for="expandTheSearchToThePrevious90Days"]'),
    ).toHaveText("Expand the search to the previous 90 days");
    await expect(page.locator('[class="flex justify-center"]')).toContainText(
      "Or try the following:Try a different search parameterAdjust or remove filters and search once more",
    );
  });

  test("should verify all components in Payment Operations page when a payment exists", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    let paymentResponse: {
      payment_id?: string;
      profile_id?: string;
      amount?: number;
      currency?: string;
      status?: string;
      payment_method?: string;
      payment_method_type?: string;
      connector_transaction_id?: string;
      merchant_order_reference_id?: string;
      description?: string;
      metadata?: Record<string, string>;
    } = {};

    if (merchantId) {
      const { token } = await loginUser(
        generateUniqueEmail(),
        PLAYWRIGHT_PASSWORD,
        context.request,
      );
      const apiKey = await createAPIKey(merchantId, token, context.request);
      await createDummyConnector(
        merchantId,
        token,
        "stripe_test_1",
        context.request,
      );
      const response = await context.request.post(
        `${process.env.HYPERSWITCH_API_URL || "http://localhost:8080"}/payments`,
        {
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
            "api-key": apiKey,
          },
          data: {
            amount: 10000,
            currency: "USD",
            confirm: true,
            capture_method: "automatic",
            customer_id: "test_customer",
            authentication_type: "no_three_ds",
            return_url: "https://google.com",
            email: "abc@test.com",
            name: "Joseph Doe",
            phone: "999999999",
            phone_country_code: "+65",
            merchant_order_reference_id: "abcd",
            description: "Its my first payment",
            statement_descriptor_name: "Juspay",
            statement_descriptor_suffix: "Router",
            payment_method: "card",
            payment_method_type: "credit",
            payment_method_data: {
              card: {
                card_number: "4242424242424242",
                card_exp_month: "01",
                card_exp_year: "2027",
                card_holder_name: "joseph Doe",
                card_cvc: "100",
                nick_name: "hehe",
              },
            },
          },
        },
      );
      paymentResponse = await response.json();

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      await expect(
        page.locator('[class="text-fs-28 font-semibold leading-10 "]'),
      ).toContainText("Payment Operations");

      await expect(
        paymentOperations.transactionView.locator("> div").nth(0),
      ).toHaveText("All1");
      await expect(
        paymentOperations.transactionView.locator("> div").nth(1),
      ).toHaveText("Succeeded1");

      await expect(paymentOperations.searchBox).toHaveAttribute(
        "placeholder",
        "Search for payment ID",
      );

      await expect(paymentOperations.addFilters).toBeVisible();
      await expect(paymentOperations.dateSelector).toBeVisible();
      await expect(paymentOperations.viewDropdown).toBeVisible();
      await expect(paymentOperations.columnButton).toBeVisible();

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
        "Merchant Order Reference Id",
        "Description",
        "Metadata",
        "Created",
        "Modified",
      ];

      for (let i = 0; i < expectedHeaders.length; i++) {
        await expect(page.locator("table thead tr th").nth(i)).toHaveText(
          expectedHeaders[i],
        );
      }

      await expect(
        page.locator('[data-table-location="Orders_tr1_td1"]'),
      ).toContainText("1");
      await expect(
        page.locator('[data-table-location="Orders_tr1_td2"]'),
      ).toContainText(paymentResponse.payment_id || "");
      await expect(
        page.locator('[data-table-location="Orders_tr1_td3"]'),
      ).toContainText("Stripe Dummy");
      await expect(
        page.locator('[data-table-location="Orders_tr1_td4"]'),
      ).toContainText(paymentResponse.profile_id || "");
      await expect(
        page.locator('[data-table-location="Orders_tr1_td5"]'),
      ).toContainText(
        `${(paymentResponse.amount || 0) / 100} ${paymentResponse.currency}`,
      );
      await expect(
        page.locator('[data-table-location="Orders_tr1_td6"]'),
      ).toContainText((paymentResponse.status || "").toUpperCase());
      await expect(
        page.locator('[data-table-location="Orders_tr1_td7"]'),
      ).toContainText(paymentResponse.payment_method || "");
      await expect(
        page.locator('[data-table-location="Orders_tr1_td8"]'),
      ).toContainText(paymentResponse.payment_method_type || "");
      await expect(
        page.locator('[data-table-location="Orders_tr1_td9"]'),
      ).toContainText("N/A");
      await expect(
        page.locator('[data-table-location="Orders_tr1_td10"]'),
      ).toContainText(paymentResponse.connector_transaction_id || "");
      await expect(
        page.locator('[data-table-location="Orders_tr1_td11"]'),
      ).toContainText(paymentResponse.merchant_order_reference_id || "");
    }
  });

  test("should display all default columns and allow selecting/deselecting columns", async ({
    page,
    context,
  }) => {
    const columns = {
      expected: [
        "Card Network",
        "Merchant Order Reference Id",
        "Metadata",
        "Payment Status",
        "Payment Method Type",
        "Payment Method",
        "Payment ID",
        "Description",
        "Created",
        "Modified",
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
        "Error Message",
      ],
      mandatory: [
        "Card Network",
        "Merchant Order Reference Id",
        "Metadata",
        "Payment Status",
        "Payment Method Type",
        "Payment Method",
        "Payment ID",
        "Description",
        "Created",
        "Modified",
        "Connector Transaction ID",
        "Connector",
        "Profile Id",
        "Amount",
      ],
    };

    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      const { token } = await loginUser(
        generateUniqueEmail(),
        PLAYWRIGHT_PASSWORD,
        context.request,
      );
      await createDummyConnector(
        merchantId,
        token,
        "stripe_test_1",
        context.request,
      );
      const apiKey = await createAPIKey(merchantId, token, context.request);
      await createPayment(merchantId, apiKey, context.request);
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    await paymentOperations.columnButton.click();

    for (const column of columns.expected) {
      await expect(
        page.locator(
          '[class="overflow-hidden p-6 pb-12 border-b border-solid  border-slate-300 dark:border-slate-500"]',
        ),
      ).toContainText(column);
    }

    const dropdownItems = page.locator(
      '[data-component="modal:Table Columns"] [data-dropdown-numeric]',
    );
    const count = await dropdownItems.count();
    for (let i = 0; i < count; i++) {
      await dropdownItems.nth(i).click();
    }

    await expect(page.locator('[data-button-text="Save"]')).toContainText(
      "Save",
    );

    for (const column of columns.optional) {
      await page.locator(`[data-dropdown-value="${column}"]`).click();
    }

    await expect(page.locator('[data-button-text="Save"]')).toContainText(
      "Save",
    );

    await page
      .locator(
        '[data-component="modal:Table Columns"] [data-icon="modal-close-icon"]',
      )
      .click();

    for (const column of columns.mandatory) {
      await expect(
        page.locator(`[data-table-heading="${column}"]`),
      ).toBeAttached();
    }

    for (const column of columns.optional) {
      await expect(
        page.locator(`[data-table-heading="${column}"]`),
      ).not.toBeAttached();
    }
  });

  test("should verify filter dropdown contains all filters", async ({
    page,
  }) => {
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

    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    await paymentOperations.addFilters.click();

    for (const filter of allFilters) {
      await expect(
        page.locator('[class="px-1 py-1 overflow-y-auto max-h-96"]'),
      ).toContainText(filter);
    }
  });

  test("should verify all transaction filter views are displayed", async ({
    page,
  }) => {
    const transactionViews = [
      "All",
      "Succeeded",
      "Failed",
      "Dropoffs",
      "Cancelled",
    ];

    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    for (const view of transactionViews) {
      await expect(paymentOperations.transactionView).toContainText(view);
    }
  });

  test("should display matching columns when searching for valid column names", async ({
    page,
    context,
  }) => {
    const columns = [
      "Card Network",
      "Merchant Order Reference Id",
      "Metadata",
      "Payment Status",
      "Payment Method Type",
      "Payment Method",
      "Payment ID",
      "Description",
      "Created",
      "Modified",
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

    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      const { token } = await loginUser(
        generateUniqueEmail(),
        PLAYWRIGHT_PASSWORD,
        context.request,
      );
      await createDummyConnector(
        merchantId,
        token,
        "stripe_test_1",
        context.request,
      );
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    await paymentOperations.columnButton.click();

    for (const searchTerm of columns) {
      await page
        .locator(`input[placeholder="Search in ${columnSize} options"]`)
        .clear();
      await page
        .locator(`input[placeholder="Search in ${columnSize} options"]`)
        .fill(searchTerm);
      await expect(page.locator("text=Save").first()).toBeVisible();
    }
  });

  test("should show 'No matching records found' when searching for invalid column names", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      const { token } = await loginUser(
        generateUniqueEmail(),
        PLAYWRIGHT_PASSWORD,
        context.request,
      );
      await createDummyConnector(
        merchantId,
        token,
        "stripe_test_1",
        context.request,
      );
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    await paymentOperations.columnButton.click();

    for (const searchTerm of ["abacd", "something", "createdAt"]) {
      await page
        .locator(`input[placeholder="Search in ${columnSize} options"]`)
        .clear();
      await page
        .locator(`input[placeholder="Search in ${columnSize} options"]`)
        .fill(searchTerm);
      await expect(page.getByText("No matching records found")).toBeVisible();
    }

    await page.locator('[data-icon="searchExit"]').click();
    await expect(
      page.locator(
        '[data-component="modal:Table Columns"] [data-dropdown-numeric]',
      ),
    ).toHaveCount(columnSize);
  });

  test("should display all selected columns in payments table", async ({
    page,
    context,
  }) => {
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
      "Merchant Order Reference Id",
      "Description",
      "Metadata",
      "Created",
      "Modified",
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

    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      const { token } = await loginUser(
        generateUniqueEmail(),
        PLAYWRIGHT_PASSWORD,
        context.request,
      );
      await createDummyConnector(
        merchantId,
        token,
        "stripe_test_1",
        context.request,
      );
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    await paymentOperations.columnButton.click();

    const dropdownItems = page.locator(
      '[data-component="modal:Table Columns"] [data-dropdown-numeric]',
    );
    const count = await dropdownItems.count();
    for (let i = 0; i < count; i++) {
      await dropdownItems.nth(i).click();
    }

    await expect(page.locator('[data-button-text="Save"]')).toContainText(
      "Save",
    );

    for (let i = 0; i < expectedColumns.length; i++) {
      await expect(page.locator("table thead tr th").nth(i)).toHaveText(
        expectedColumns[i],
      );
    }
  });

  test("should verify all filters can be selected from 'Add filter' dropdown", async ({
    page,
    context,
  }) => {
    const filterKeys = [
      "Connector",
      "Currency",
      "Status",
      "Payment Method",
      "Authentication Type",
      "Card Network",
      "Card Discovery",
      "Payment Method Type",
      "Amount",
    ];

    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      const { token } = await loginUser(
        generateUniqueEmail(),
        PLAYWRIGHT_PASSWORD,
        context.request,
      );
      await createDummyConnector(
        merchantId,
        token,
        "stripe_test_1",
        context.request,
      );
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    for (const filter of filterKeys) {
      await paymentOperations.addFilters.click();
      await page.locator(".mr-5.text-left").getByText(filter).click();
      await expect(
        page.locator('[class="flex relative  flex-row  flex-wrap"]'),
      ).toContainText(`Select ${filter}`);
      await page.locator('[data-icon="cross-outline"]').click();
    }

    await paymentOperations.addFilters.click();
    await page.locator(".mr-5.text-left").getByText("Customer Id").click();
    await expect(page.locator('[name="customer_id"]')).toHaveAttribute(
      "placeholder",
      "Enter Customer Id...",
    );
    await page.locator('[data-icon="cross-outline"]').click();

    await paymentOperations.addFilters.click();
    await page
      .locator(".mr-5.text-left")
      .getByText("Merchant Order Reference Id")
      .click();
    await expect(
      page.locator('[name="merchant_order_reference_id"]'),
    ).toHaveAttribute("placeholder", "Enter Merchant Order Reference Id...");
  });

  test("should verify applying 'Connector', 'Currency' and 'Status' filters", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      const { token } = await loginUser(
        generateUniqueEmail(),
        PLAYWRIGHT_PASSWORD,
        context.request,
      );
      await createDummyConnector(
        merchantId,
        token,
        "stripe_test_1",
        context.request,
      );
      const apiKey = await createAPIKey(merchantId, token, context.request);
      await context.request.post(
        `${process.env.HYPERSWITCH_API_URL || "http://localhost:8080"}/payments`,
        {
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
            "api-key": apiKey,
          },
          data: {
            amount: 10000,
            currency: "USD",
            confirm: true,
            capture_method: "automatic",
            customer_id: "test_customer",
            authentication_type: "no_three_ds",
            return_url: "https://google.com",
            email: "abc@test.com",
            name: "Joseph Doe",
            phone: "999999999",
            phone_country_code: "+65",
            merchant_order_reference_id: "abcd",
            description: "Its my first payment",
            payment_method: "card",
            payment_method_type: "credit",
            payment_method_data: {
              card: {
                card_number: "4242424242424242",
                card_exp_month: "01",
                card_exp_year: "2027",
                card_holder_name: "joseph Doe",
                card_cvc: "100",
              },
            },
          },
        },
      );
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    await paymentOperations.addFilters.click();
    await page.locator(".mr-5.text-left").getByText("Connector").click();
    await page.locator('[class="flex relative  flex-row  flex-wrap"]').click();
    await page.locator('[value="Stripe Test"]').click();
    await page.locator('[data-button-text="Apply"]').click();
    await expect(
      page.locator('[class="flex relative  flex-row  flex-wrap"]'),
    ).toContainText("Stripe Test");

    await paymentOperations.addFilters.click();
    await page.locator(".mr-5.text-left").getByText("Status").click();
    await page.locator('[data-component-field-wrapper="field-status"]').click();
    await page.locator('[value="Succeeded"]').click();
    await page.locator('[data-button-text="Apply"]').click();
    await expect(
      page.locator('[class="flex relative  flex-row  flex-wrap"]'),
    ).toContainText("Succeeded");

    await paymentOperations.addFilters.click();
    await page.locator(".mr-5.text-left").getByText("Currency").click();
    await page.getByText("Select Currency").click();
    await page.locator('[placeholder="Search..."]').fill("USD");
    await page.locator('[data-searched-text="USD"]').click();
    await page.locator('[data-button-text="Apply"]').click();
    await expect(
      page.locator('[class="flex relative  flex-row  flex-wrap"]'),
    ).toContainText("USD");

    await expect(
      page.locator('[data-table-location="Orders_tr1_td3"]'),
    ).toContainText("Stripe");
    await expect(
      page.locator('[data-table-location="Orders_tr1_td6"]'),
    ).toContainText("SUCCEEDED");
    await expect(
      page.locator('[data-table-location="Orders_tr1_td5"]'),
    ).toContainText("USD");
  });

  test("should extend the time range by 90 days when no payments are listed", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const initialRange = await paymentOperations.dateSelector.textContent();
    expect(initialRange).not.toContain("Select Date");

    if (initialRange) {
      const startDateStr = initialRange.split("-")[0].trim();
      const parsedStartDate = new Date(startDateStr);
      const previousStartDate = new Date(parsedStartDate);
      previousStartDate.setDate(parsedStartDate.getDate() - 90);

      const formatDate = (date: Date) => {
        return date.toLocaleDateString("en-US", {
          month: "short",
          day: "2-digit",
          year: "numeric",
        });
      };

      const expectedStart = formatDate(previousStartDate);
      const expectedEnd = formatDate(parsedStartDate);
      const expectedRange = `${expectedStart} - ${expectedEnd}`;

      await page
        .locator('[data-button-for="expandTheSearchToThePrevious90Days"]')
        .click();

      await expect(paymentOperations.dateSelector).toContainText(expectedStart);
    }
  });

  test("should switch between different transaction views and verify applied filters", async ({
    page,
    context,
  }) => {
    const viewFilters: Record<string, string> = {
      Succeeded: "Succeeded",
      Failed: "Failed",
      Dropoffs: "Requires Payment Method",
      Cancelled: "Cancelled",
    };

    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      const { token } = await loginUser(
        generateUniqueEmail(),
        PLAYWRIGHT_PASSWORD,
        context.request,
      );
      await createDummyConnector(
        merchantId,
        token,
        "stripe_test_1",
        context.request,
      );
      const apiKey = await createAPIKey(merchantId, token, context.request);
      await context.request.post(
        `${process.env.HYPERSWITCH_API_URL || "http://localhost:8080"}/payments`,
        {
          headers: {
            "Content-Type": "application/json",
            Accept: "application/json",
            "api-key": apiKey,
          },
          data: {
            amount: 10000,
            currency: "USD",
            confirm: true,
            capture_method: "automatic",
            customer_id: "test_customer",
            authentication_type: "no_three_ds",
            return_url: "https://google.com",
            payment_method: "card",
            payment_method_type: "credit",
            payment_method_data: {
              card: {
                card_number: "4242424242424242",
                card_exp_month: "01",
                card_exp_year: "2027",
                card_holder_name: "joseph Doe",
                card_cvc: "100",
              },
            },
          },
        },
      );
    }

    await homePage.operations.click();
    await homePage.paymentOperations.click();

    for (const [view, filter] of Object.entries(viewFilters)) {
      await paymentOperations.transactionView.getByText(view).click();
      await expect(
        page.locator('[class="flex relative  flex-row  flex-wrap"]'),
      ).toContainText(filter);
    }
  });

  test("should verify all components in Payment Details page - 1", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    const lineage = await ompLineage(page);

    const { token } = await loginUser(
      generateUniqueEmail(),
      PLAYWRIGHT_PASSWORD,
      context.request,
    );
    await createDummyConnector(
      lineage.merchantId,
      token,
      "stripe_test_1",
      context.request,
    );
    const apiKey = await createAPIKey(
      lineage.merchantId,
      token,
      context.request,
    );
    await context.request.post(
      `${process.env.HYPERSWITCH_API_URL || "http://localhost:8080"}/payments`,
      {
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "api-key": apiKey,
        },
        data: {
          amount: 12345,
          currency: "USD",
          confirm: true,
          capture_method: "automatic",
          customer_id: "test_customer",
          authentication_type: "three_ds",
          return_url: "https://google.com",
          email: "abc@test.com",
          name: "Joseph Doe",
          phone: "999999999",
          phone_country_code: "+65",
          merchant_order_reference_id: "abcd",
          description: "Its my first payment",
          payment_method: "card",
          payment_method_type: "credit",
          payment_method_data: {
            card: {
              card_number: "4242424242424242",
              card_exp_month: "01",
              card_exp_year: "2027",
              card_holder_name: "joseph Doe",
              card_cvc: "100",
            },
          },
        },
      },
    );

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.locator('[data-table-location="Orders_tr1_td1"]').click();

    await page.locator('[data-button-text="+ Refund"]').click();
    await page.locator('[data-input-name="amount"]').fill("12.34");
    await page.locator('[data-button-text="Initiate Refund"]').click();

    await expect(
      page.locator('[class="font-bold text-lg mb-5"]').nth(0),
    ).toContainText("Summary");
    await expect(page.locator('[class="md:text-5xl font-bold"]')).toContainText(
      "123.45 USD",
    );
    await expect(
      page.locator(
        '[class="text-sm text-white font-bold px-3 py-2 rounded-md bg-hyperswitch_green dark:bg-opacity-50"]',
      ),
    ).toContainText("SUCCEEDED");

    await expect(page.locator('[data-label="Created"]')).toContainText(
      "Created",
    );
    await expect(page.locator('[data-label="Last Updated"]')).toContainText(
      "Last Updated",
    );
    await expect(page.locator('[data-label="Amount Received"]')).toContainText(
      "Amount Received",
    );
    await expect(page.locator('[data-label="Payment ID"]')).toContainText(
      "Payment ID",
    );
    await expect(
      page.locator('[data-label="Connector Transaction ID"]'),
    ).toContainText("Connector Transaction ID");
    await expect(page.locator('[data-label="Error Message"]')).toContainText(
      "Error Message",
    );

    await expect(
      page.locator('[class="font-bold text-lg mb-5"]').nth(1),
    ).toContainText("About Payment");
    await expect(page.locator('[data-label="Profile Id"]')).toContainText(
      "Profile Id",
    );
    await expect(page.locator('[data-label="Profile Name"]')).toContainText(
      "Profile Name",
    );
    await expect(
      page.locator('[data-label="Payment connector"]'),
    ).toContainText("Payment connector");
    await expect(page.locator('[data-label="Connector Label"]')).toContainText(
      "Connector Label",
    );
    await expect(page.locator('[data-label="Payment Method"]')).toContainText(
      "Payment Method",
    );
    await expect(
      page.locator('[data-label="Payment Method Type"]'),
    ).toContainText("Payment Method Type");
    await expect(page.locator('[data-label="Auth Type"]')).toContainText(
      "Auth Type",
    );
    await expect(page.locator('[data-label="Card Network"]')).toContainText(
      "Card Network",
    );

    await expect(page.getByText("Events and logs")).toBeVisible();

    await expect(
      page.locator('[class="flex flex-col gap-4"]').nth(0),
    ).toContainText("Payment Attempts");

    const expectedAttemptColumns = [
      "S.No",
      "Status",
      "Amount",
      "Currency",
      "Connector",
      "Payment Method",
      "Payment Method Type",
    ];

    for (let i = 0; i < expectedAttemptColumns.length; i++) {
      await expect(page.locator("table thead tr th").nth(i)).toHaveText(
        expectedAttemptColumns[i],
      );
    }

    await page.locator('[data-table-location="Attempts_tr1_td1"]').click();
    await expect(
      page.locator('[data-heading="Attempt Details"]'),
    ).toBeVisible();

    const expectedValues: Record<string, string> = {
      "Attempt ID": "Attempt ID",
      Status: "CHARGED",
      Amount: "123.45 USD",
      Currency: "USD",
      Connector: "Stripe Dummy",
      "Payment Method": "card",
      "Payment Method Type": "credit",
      "Error Message": "N/A",
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

    for (const [label, value] of Object.entries(expectedValues)) {
      await expect(page.locator(`[data-label="${label}"]`)).toContainText(
        value,
      );
    }

    await expect(
      page.locator('[class="flex flex-col gap-4"]').nth(1),
    ).toContainText("Refunds");

    const expectedRefundAttemptColumns = [
      "S.No",
      "Refund ID",
      "Payment Id",
      "Amount",
      "Refund Status",
      "Created",
      "Last Updated",
    ];

    const refundsTable = page.locator('table[data-expandable-table="Refunds"]');
    for (let i = 0; i < expectedRefundAttemptColumns.length; i++) {
      await expect(refundsTable.locator("thead tr th").nth(i)).toHaveText(
        expectedRefundAttemptColumns[i],
      );
    }

    await page.locator('[data-table-location="Refunds_tr1_td1"]').click();

    const expectedRefundValues: Record<string, string> = {
      "Refund Status": "SUCCEEDED",
      Amount: "12.34 USD",
      Currency: "USD",
      "Refund Reason": "N/A",
      "Error Message": "N/A",
    };

    for (const [label, value] of Object.entries(expectedRefundValues)) {
      await expect(page.locator(`[data-label="${label}"]`)).toContainText(
        value,
      );
    }
  });

  test("should verify all components in Payment Details page - 2", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const lineage = await ompLineage(page);

    const { token } = await loginUser(
      generateUniqueEmail(),
      PLAYWRIGHT_PASSWORD,
      context.request,
    );
    await createDummyConnector(
      lineage.merchantId,
      token,
      "stripe_test_1",
      context.request,
    );
    const apiKey = await createAPIKey(
      lineage.merchantId,
      token,
      context.request,
    );
    await context.request.post(
      `${process.env.HYPERSWITCH_API_URL || "http://localhost:8080"}/payments`,
      {
        headers: {
          "Content-Type": "application/json",
          Accept: "application/json",
          "api-key": apiKey,
        },
        data: {
          amount: 12345,
          currency: "USD",
          confirm: true,
          capture_method: "automatic",
          customer_id: "test_customer",
          authentication_type: "three_ds",
          return_url: "https://google.com",
          email: "abc@test.com",
          name: "Joseph Doe",
          phone: "999999999",
          phone_country_code: "+65",
          merchant_order_reference_id: "abcd",
          description: "Its my first payment",
          payment_method: "card",
          payment_method_type: "credit",
          payment_method_data: {
            card: {
              card_number: "4242424242424242",
              card_exp_month: "01",
              card_exp_year: "2027",
              card_holder_name: "joseph Doe",
              card_cvc: "100",
            },
          },
        },
      },
    );

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.locator('[data-table-location="Orders_tr1_td1"]').click();

    await page.getByText("Customer Details").click();

    const assertSectionFields = async (
      sectionName: string,
      fields: Record<string, string>,
    ) => {
      const section = page
        .locator("div", { hasText: new RegExp(`^${sectionName}$`) })
        .first();
      for (const [label, value] of Object.entries(fields)) {
        await expect(section.locator(`[data-label="${label}"]`)).toContainText(
          value,
        );
      }
    };

    await assertSectionFields("Customer", {
      "First Name": "Joseph",
      "Last Name": "Doe",
      "Customer Phone": "+65 999999999",
      "Customer Email": "abc@test.com",
      "Customer ID": "test_customer",
      Description: "Its my first payment",
    });

    await assertSectionFields("Billing", {
      Email: "abc@test.com",
      Phone: "+91 8056594427",
      Address:
        "1562, HarrisonStreet, HarrisonStreet, Toronto, ON, CA, M3C 0C1.",
    });

    await assertSectionFields("Shipping", {
      Email: "abc@test.com",
      Phone: "+91 8056594427",
      Address:
        "1562, HarrisonStreet, HarrisonStreet, Toronto, ON, CA, M3C 0C1.",
    });

    await assertSectionFields("Tag", {
      Tag: "N/A",
      "Transaction Flow": "N/A",
      Message: "N/A",
    });
  });
});
