import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentOperations } from "../../support/pages/operations/PaymentOperations";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
  ompLineage,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
const columnSize = 24;
const requiredColumnsSize = 14;
let email: string;

test.describe("Payment Operations", () => {
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test.describe("Verify Components of Payment Operations", () => {
    test("should verify all components in Payment Operations page when no payment exists", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      await expect(
        page.locator('[class="flex justify-between items-center"]'),
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
        page.locator(
          '[class="items-center text-2xl text-black font-bold mb-4"]',
        ),
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

      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        const paymentData = await createPaymentAPI(merchantId, context.request);

        await homePage.operations.click();
        await homePage.paymentOperations.click();

        await expect(
          page.locator('[class="flex justify-between items-center"]'),
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
          "Profile ID",
          "Amount",
          "Payment Status",
          "Payment Method",
          "Payment Method Type",
          "Card Network",
          "Connector Transaction ID",
          "Merchant Order Reference ID",
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
        ).toContainText(paymentData.payment_id);
        await expect(
          page.locator('[data-table-location="Orders_tr1_td3"]'),
        ).toContainText("Stripe Dummy");
        await expect(
          page.locator('[data-table-location="Orders_tr1_td4"]'),
        ).toContainText(paymentData.profile_id);
        await expect(
          page.locator('[data-table-location="Orders_tr1_td5"]'),
        ).toContainText(`${paymentData.amount / 100} ${paymentData.currency}`);
        await expect(
          page.locator('[data-table-location="Orders_tr1_td6"]'),
        ).toContainText(paymentData.status.toUpperCase());
        await expect(
          page.locator('[data-table-location="Orders_tr1_td7"]'),
        ).toContainText(paymentData.payment_method);
        await expect(
          page.locator('[data-table-location="Orders_tr1_td8"]'),
        ).toContainText(paymentData.payment_method_type);
        await expect(
          page.locator('[data-table-location="Orders_tr1_td9"]'),
        ).toContainText("N/A");
        await expect(
          page.locator('[data-table-location="Orders_tr1_td10"]'),
        ).toContainText(paymentData.connector_transaction_id);
        await expect(
          page.locator('[data-table-location="Orders_tr1_td11"]'),
        ).toContainText(paymentData.merchant_order_reference_id);
      }
    });
  });

  // Columns
  test.describe("Columns", () => {
    test("should display all default columns and allow selecting/deselecting columns", async ({
      page,
      context,
    }) => {
      const columns = {
        expected: [
          "Card Network",
          "Merchant Order Reference ID",
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
          "Profile ID",
          "Amount",
          "Amount Capturable",
          "Authentication Type",
          "Capture Method",
          "Client Secret",
          "Currency",
          "Customer ID",
          "Merchant ID",
          "Setup Future Usage",
          "Attempt Count",
          "Error Message",
        ],
        optional: [
          "Amount Capturable",
          "Authentication Type",
          "Capture Method",
          "Client Secret",
          "Currency",
          "Customer ID",
          "Merchant ID",
          "Setup Future Usage",
          "Attempt Count",
          "Error Message",
        ],
        mandatory: [
          "Card Network",
          "Merchant Order Reference ID",
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
          "Profile ID",
          "Amount",
        ],
      };

      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        // Use API helpers to set up connector and payment without UI login flow
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
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

    test("should display matching columns when searching for valid column names", async ({
      page,
      context,
    }) => {
      const columns = [
        "Card Network",
        "Merchant Order Reference ID",
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
        "Profile ID",
        "Amount",
        "Amount Capturable",
        "Authentication Type",
        "Capture Method",
        "Client Secret",
        "Currency",
        "Customer ID",
        "Merchant ID",
        "Setup Future Usage",
        "Attempt Count",
        "Error Message",
      ];

      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        // Use API helpers to set up connector and payment without UI login flow
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
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
        // Use API helpers to set up connector and payment without UI login flow
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
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
        "Profile ID",
        "Amount",
        "Payment Status",
        "Payment Method",
        "Payment Method Type",
        "Card Network",
        "Connector Transaction ID",
        "Merchant Order Reference ID",
        "Description",
        "Metadata",
        "Created",
        "Modified",
        "Amount Capturable",
        "Authentication Type",
        "Capture Method",
        "Client Secret",
        "Currency",
        "Customer ID",
        "Merchant ID",
        "Setup Future Usage",
        "Attempt Count",
        "Error Message",
      ];

      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        // Use API helpers to set up connector and payment without UI login flow
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
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

      await page.locator('[data-button-text="Save"]').click();

      for (let i = 0; i < expectedColumns.length; i++) {
        await expect(page.locator("table thead tr th").nth(i)).toHaveText(
          expectedColumns[i],
        );
      }
    });
  });

  // Sort
  test.describe("Sort", () => {
    test("should sort column ascending then descending on header click", async ({
      page,
      context,
    }) => {
      // 3 sequential payment creates + 6 sort + assert cycles per column.
      test.setTimeout(120000);
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      const payments: { payment_id: string; amount: number }[] = [];
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        const amounts = [10000, 20000, 30000];
        for (const amount of amounts) {
          const payment = await createPaymentAPI(
            merchantId,
            context.request,
            amount,
          );
          payments.push({ payment_id: payment.payment_id, amount });
          await page.waitForTimeout(1000);
        }
      }

      await page.route(/\/config\/feature/, async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        json.features = { ...json.features, dev_sort_enabled: true };
        await route.fulfill({ response, json });
      });
      await page.reload();
      await page.waitForLoadState("networkidle");

      await homePage.operations.click();
      await homePage.paymentOperations.click();
      await page.waitForLoadState("networkidle");

      const sortableColumns = ["Amount", "Created", "Modified"];

      for (const column of sortableColumns) {
        const heading = page.locator(`[data-table-heading="${column}"]`);
        const sortUp = heading.locator('[data-icon="caret-up"]');
        const sortDown = heading.locator('[data-icon="caret-down"]');

        // First click toggles NONE -> DEC (descending). The caret icon is
        // re-rendered after every sort, so wait for it to be stable rather
        // than relying on the action timeout to retry through the rerender.
        await expect(sortUp).toBeVisible();
        await sortUp.click();
        await page.waitForLoadState("networkidle");
        await expect(page.locator('[data-table-location="Orders_tr1_td2"]')).toContainText(payments[2].payment_id);
        await expect(page.locator('[data-table-location="Orders_tr3_td2"]')).toContainText(payments[0].payment_id);

        // Second click toggles DEC -> INC (ascending)
        await expect(sortDown).toBeVisible();
        await sortDown.click();
        await page.waitForLoadState("networkidle");
        await page.waitForTimeout(3000);
        await expect(page.locator('[data-table-location="Orders_tr1_td2"]')).toContainText(payments[0].payment_id);
        await expect(page.locator('[data-table-location="Orders_tr3_td2"]')).toContainText(payments[2].payment_id);
      }
    });
  });

  // Pagination
  test.describe("Pagination", () => {
    test("should paginate to the last page", async ({ page, context }) => {
      // 21 sequential payment-create API calls + UI nav routinely exceed 30s on CI.
      test.setTimeout(120000);
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        for (let i = 0; i < 21; i++) {
          await createPaymentAPI(merchantId, context.request).catch(() => { });
        }
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();
      // Let the orders list finish loading before asserting on its count text;
      // the previous run failed because the row count rendered after the 5s
      // expect timeout while the GET /payments/list response was still in
      // flight.
      await page.waitForLoadState("networkidle");
      await expect(page.getByText("Payment Operations")).toBeVisible();

      await expect(page.getByText("Showing 20 of 21")).toBeVisible({
        timeout: 15000,
      });
      await page.getByRole("button", { name: "2", exact: true }).click();
      await page.waitForLoadState("networkidle");
      await expect(page.getByText("Showing 21 of 21")).toBeVisible({
        timeout: 15000,
      });
    });
  });

  test.describe("Search bar", () => {
    test("should display correct payment when searched with payment ID", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        // Use API helpers to set up connector and payment without UI login flow
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
        await createPaymentAPI(merchantId, context.request);
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      const firstPaymentId = await page
        .locator('[data-table-location="Orders_tr1_td2"]')
        .textContent();
      if (firstPaymentId) {
        await paymentOperations.searchBox.fill(firstPaymentId);
        await paymentOperations.searchBox.press("Enter");

        await expect(
          page.locator('[data-table-location="Orders_tr1_td2"]'),
        ).toContainText(firstPaymentId);
      }

      await paymentOperations.searchBox.clear();

      const secondPaymentId = await page
        .locator('[data-table-location="Orders_tr2_td2"]')
        .textContent();
      if (secondPaymentId) {
        await paymentOperations.searchBox.fill(secondPaymentId);
        await paymentOperations.searchBox.press("Enter");

        await expect(
          page.locator('[data-table-location="Orders_tr1_td2"]'),
        ).toContainText(secondPaymentId);
      }
    });

    test.skip("should display a valid message and expand search timerange when searched with invalid payment ID", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      await expect(paymentOperations.searchBox).toBeVisible();
      await paymentOperations.searchBox.fill("invalidID");
      await paymentOperations.searchBox.press("Enter");

      await expect(
        page.locator(
          '[class="items-center text-2xl text-black font-bold mb-4"]',
        ),
      ).toHaveText("No results found");
      await expect(
        page.locator('[data-button-for="expandTheSearchToThePrevious90Days"]'),
      ).toHaveText("Expand the search to the previous 90 days");
      await expect(page.locator('[class="flex justify-center"]')).toContainText(
        "Or try the following:Try a different search parameterAdjust or remove filters and search once more",
      );
    });
  });

  test.describe("Filters", () => {
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
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      for (const filter of filterKeys) {
        await paymentOperations.addFilters.click();
        await page
          .locator(".mr-5.text-left")
          .getByText(filter, { exact: true })
          .click();
        await expect(
          page.locator('[class="flex relative  flex-row  flex-wrap"]').first(),
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
        .getByText("Merchant Order Reference ID")
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
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      await paymentOperations.addFilters.click();
      await page.locator(".mr-5.text-left").getByText("Connector").click();
      await page.locator('[class="flex relative  flex-row  flex-wrap"]').first().click();
      await page.locator('[value="Stripe Dummy"]').click();
      await expect(await page.locator('[data-button-text="Apply"]')).toBeEnabled({ timeout: 3000 });
      await page.locator('[data-button-text="Apply"]').click();
      await expect(page.getByText("Stripe Dummy").first()).toBeVisible();
      await expect(await page.locator('[data-button-text="Apply"]')).not.toBeVisible({ timeout: 3000 });

      await paymentOperations.addFilters.click();
      await page.locator(".mr-5.text-left").getByText("Status").click();
      await page.locator('[data-component-field-wrapper="field-status"]').click();
      await page.locator('[value="Succeeded"]').click();
      await expect(page.getByText('Clear All').first()).toBeVisible();
      await expect(await page.locator('[data-button-text="Apply"]')).toBeEnabled({ timeout: 3000 });
      await page.locator('[data-button-text="Apply"]').click();
      await expect(page.getByText("Succeeded").first()).toBeVisible();
      await expect(await page.locator('[data-button-text="Apply"]')).not.toBeVisible({ timeout: 3000 });

      await paymentOperations.addFilters.click();
      await page.locator(".mr-5.text-left").getByText("Currency").click();
      await page.getByText("Select Currency").click();
      await page.locator('[placeholder="Search..."]').fill("USD");
      await page.locator('[data-searched-text="USD"]').click();
      await expect(page.getByText('Clear All').first()).toBeVisible();
      await expect(await page.locator('[data-button-text="Apply"]')).toBeEnabled({ timeout: 3000 });
      await page.locator('[data-button-text="Apply"]').click();
      await expect(page.getByText("USD").first()).toBeVisible();

      await expect(page.locator('[data-table-location="Orders_tr1_td3"]')).toContainText("Stripe");
      await expect(page.locator('[data-table-location="Orders_tr1_td6"]')).toContainText("SUCCEEDED");
      await expect(page.locator('[data-table-location="Orders_tr1_td5"]')).toContainText("USD");
    });
  });

  test.describe("Date Selector", () => {
    test("should extend the time range by 90 days when no payments are listed", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      const initialRange = await paymentOperations.dateSelector.textContent();

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

        await expect(paymentOperations.dateSelector).toContainText(
          expectedStart,
        );
      }
    });

    test("should verify all time range filters are displayed in date selector dropdown", async ({
      page,
    }) => {
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

      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      await expect(paymentOperations.dateSelector).toBeVisible();
      await paymentOperations.dateSelector.click();

      await expect(
        page.locator('[data-date-picker-predefined="predefined-options"]'),
      ).toBeVisible();

      for (const filter of timeRangeFilters) {
        await expect(
          page.locator('[data-date-picker-predefined="predefined-options"]'),
        ).toContainText(filter);
      }
    });

    test("should verify selected timerange when predefined timerange is applied from dropdown", async ({
      page,
    }) => {
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

      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      const currentDay = new Date().getDate();

      const predefinedOptions = page.locator('[data-date-picker-predefined="predefined-options"]');

      for (const timeRange of predefinedTimeRange) {
        await paymentOperations.dateSelector.click({ force: true });
        await expect(predefinedOptions).toBeVisible();
        await predefinedOptions.getByText(timeRange, { exact: true }).click();
        const expectedText = currentDay === 7 && timeRange === "This Month" ? "Last 7 Days" : timeRange;
        await expect(page.getByTestId('date-range-selector')).toContainText(expectedText);
        await expect(predefinedOptions).toBeHidden();
        await page.waitForLoadState("networkidle");
      }
    });

    test("should verify applied custom timerange is displayed correctly", async ({
      page,
    }) => {
      const now = new Date();
      const today = now.getDate();
      const previousMonth = new Date(
        now.setMonth(now.getMonth() - 1),
      ).toLocaleString("default", { month: "short" });
      const currentYear = now.getFullYear();

      const startDate = today === 2 ? 1 : 2;
      const endDate = today === 28 ? 29 : 28;

      const formatDate = (day: number) => {
        const paddedDay = String(day).padStart(2, "0");
        return `${previousMonth} ${paddedDay}, ${currentYear}`;
      };

      const expectedRange = `${formatDate(startDate)} - ${formatDate(endDate)}`;

      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      await expect(paymentOperations.dateSelector).toBeVisible();
      await paymentOperations.dateSelector.click();

      await expect(
        page.locator('[data-date-picker-predefined="predefined-options"]'),
      ).toBeVisible();

      await page
        .locator('[data-daterange-dropdown-value="Custom Range"]')
        .click();

      await page.locator(`[data-testid*=" ${startDate},"]`).first().click();
      await page.locator(`[data-testid*=" ${endDate},"]`).first().click();

      await page.locator('[data-button-text="Apply"]').click();

      await expect(
        page.locator(`[data-button-text="${expectedRange}"]`),
      ).toContainText(expectedRange);
    });
  });

  test.describe("Views", () => {
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
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      for (const [view, filter] of Object.entries(viewFilters)) {
        await paymentOperations.transactionView.getByText(view).click();
        await expect(page.locator('[data-component-field-wrapper="field-status"]')).toContainText(filter);
      }
    });
  });

  // Generate Report
  test.describe("Generate Report", () => {
    test("should display Generate Report button when generate_report flag is ON", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await page.route("**/dashboard/config/feature?domain=", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        if (json && json.features) {
          json.features.generate_report = true;
        }
        await route.fulfill({ response, json });
      });

      await page.reload();

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      await expect(paymentOperations.generateReports).toBeVisible();

      await paymentOperations.generateReports.click();
      await expect(page.getByText("Generate Payment Reports")).toBeVisible();
      await expect(page.getByText("Date Range *")).toBeVisible();
      await expect(page.getByText("Report Type")).toBeVisible();
      await expect(page.getByText("Additional Recipients")).toBeVisible();
      await page.getByRole("button", { name: "Generate", exact: true }).click();
    });

    test("should hide Generate Report button when generate_report flag is OFF", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      await expect(paymentOperations.generateReports).not.toBeVisible();
    });

    test("should close the report modal when close icon is clicked", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await page.route("**/dashboard/config/feature?domain=", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        if (json && json.features) {
          json.features.generate_report = true;
        }
        await route.fulfill({ response, json });
      });
      await page.reload();

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      await paymentOperations.generateReports.click();
      const modal = page.locator(
        '[data-component="modal:Generate Payment Reports"]',
      );
      await expect(modal).toBeVisible();

      await modal.locator('[data-icon="modal-close-icon"]').click();
      await expect(modal).toBeHidden();
    });

    test("should show success toast and close modal when download succeeds", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await page.route("**/dashboard/config/feature?domain=", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        if (json && json.features) {
          json.features.generate_report = true;
        }
        await route.fulfill({ response, json });
      });
      await page.route("**/analytics/v1/**/report/payments", async (route) => {
        await route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify({ message: "ok" }),
        });
      });
      await page.reload();

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      await paymentOperations.generateReports.click();
      const modal = page.locator(
        '[data-component="modal:Generate Payment Reports"]',
      );
      await expect(modal).toBeVisible();

      await page.getByRole("button", { name: "Generate", exact: true }).click();

      await expect(page.locator('[data-toast="Email Sent"]')).toBeVisible();
      await expect(modal).toBeHidden();
    });

    test("should show error toast and keep modal open when download fails", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await page.route("**/dashboard/config/feature?domain=", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        if (json && json.features) {
          json.features.generate_report = true;
        }
        await route.fulfill({ response, json });
      });
      await page.route("**/analytics/v1/**/report/payments", async (route) => {
        await route.fulfill({
          status: 500,
          contentType: "application/json",
          body: JSON.stringify({
            error: { message: "Internal server error" },
          }),
        });
      });
      await page.reload();

      await homePage.operations.click();
      await homePage.paymentOperations.click();

      await paymentOperations.generateReports.click();
      const modal = page.locator(
        '[data-component="modal:Generate Payment Reports"]',
      );
      await expect(modal).toBeVisible();

      await page.getByRole("button", { name: "Generate", exact: true }).click();

      await expect(
        page.locator('[data-toast="Something went wrong. Please try again."]'),
      ).toBeVisible();
      await expect(modal).toBeVisible();
    });
  });

  test.describe("Open in new tab button for payment ID", () => {
    test("should verify open in new tab for a payment", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        const paymentData = await createPaymentAPI(merchantId, context.request);

        await homePage.operations.click();
        await homePage.paymentOperations.click();

        await expect(
          page.locator('[data-icon="external-link-alt"]'),
        ).toBeVisible();

        const href = await page
          .locator('[target="_blank"]')
          .first()
          .getAttribute("href");
        const lineage = await ompLineage(page);
        const expectedUrlPart = `/dashboard/payments/${paymentData.payment_id}/${lineage.profileId}/${lineage.merchantId}/${lineage.orgId}`;
        expect(href).toContain(expectedUrlPart);
      }
    });
  });

  test.describe("Payment details page", () => {
    test("should verify all components in Payment Details page - 1", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      //await page.goto("/dashboard/home");

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        // Use API helpers to set up connector and payment without UI login flow
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();
      await page.locator('[data-table-location="Orders_tr1_td1"]').click();

      await page.locator('[data-button-text="+ Refund"]').click();
      await page.locator('[name="amount"]').fill("12.34");
      await page.locator('[data-button-text="Initiate Refund"]').click();

      await expect(
        page.locator('[class="font-bold text-lg mb-5"]').nth(0),
      ).toContainText("Summary");
      await expect(
        page.locator('[class="md:text-5xl font-bold"]'),
      ).toContainText("123.45 USD");
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
      await expect(
        page.locator('[data-label="Amount Received"]'),
      ).toContainText("Amount Received");
      await expect(
        page.locator('[data-label="Payment ID"]').first(),
      ).toContainText("Payment ID");
      await expect(
        page.locator('[data-label="Connector Transaction ID"]'),
      ).toContainText("Connector Transaction ID");
      await expect(page.locator('[data-label="Error Message"]')).toContainText(
        "Error Message",
      );

      await expect(
        page.locator('[class="font-bold text-lg mb-5"]').nth(1),
      ).toContainText("About Payment");
      await expect(page.locator('[data-label="Profile ID"]')).toContainText(
        "Profile ID",
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
        page.locator('[data-label="Payment Method Type"]').first(),
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
        await expect(
          page.locator(`[data-label="${label}"]`).first(),
        ).toContainText(value);
      }

      await expect(
        page.locator('[class="flex flex-col gap-4"]').nth(1),
      ).toContainText("Refunds");

      const expectedRefundAttemptColumns = [
        "S.No",
        "Refund ID",
        "Payment ID",
        "Amount",
        "Refund Status",
        "Created",
        "Last Updated",
      ];

      const refundsTable = page.locator(
        'table[data-expandable-table="Refunds"]',
      );
      for (let i = 0; i < expectedRefundAttemptColumns.length; i++) {
        await expect(refundsTable.locator("thead tr th").nth(i)).toHaveText(
          expectedRefundAttemptColumns[i],
        );
      }

      await page.locator('[data-table-location="Refunds_tr1_td1"]').click();

      const expectedRefundValues: Record<string, string> = {
        "Refund Status": "SUCCEEDED",
        Amount: "Amount123.45 USD",
        Currency: "USD",
        "Refund Reason": "N/A",
        "Error Message": "N/A",
      };

      for (const [label, value] of Object.entries(expectedRefundValues)) {
        await expect(
          page.locator(`[data-label="${label}"]`).first(),
        ).toContainText(value);
      }
    });

    test("should verify all components in Payment Details page - 2", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        // Use API helpers to set up connector and payment without UI login flow
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();
      await page.locator('[data-table-location="Orders_tr1_td1"]').click();

      await page.getByText("Customer Details").click();

      const assertSectionFields = async (
        sectionName: string,
        fields: Record<string, string>,
      ) => {
        const sectionHeader = page.getByText(new RegExp(`^${sectionName}$`));
        await sectionHeader.waitFor({ state: "attached", timeout: 10000 });
        await sectionHeader.scrollIntoViewIfNeeded();
        await expect(sectionHeader).toBeVisible();
        for (const [label, value] of Object.entries(fields)) {
          await expect(
            sectionHeader
              .locator("xpath=../../..")
              .locator(`[data-label="${label}"]`)
              .first(),
          ).toContainText(value);
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

      await expect(page.locator('[data-label="Tag"]').first()).toContainText(
        "N/A",
      );
      await expect(
        page.locator('[data-label="Transaction Flow"]').first(),
      ).toContainText("N/A");
      await expect(
        page.locator('[data-label="Message"]').first(),
      ).toContainText("N/A");

      const expandAccordionAndAssertFields = async (
        accordionTitle: string,
        fields: Record<string, string>,
      ) => {
        const accordionHeader = page.getByText(
          new RegExp(`^${accordionTitle}$`),
        );
        await accordionHeader.waitFor({ state: "attached", timeout: 10000 });
        await accordionHeader.scrollIntoViewIfNeeded();
        await accordionHeader.click();
        for (const [label, value] of Object.entries(fields)) {
          await expect(
            page.locator(`[data-label="${label}"]`).first(),
          ).toContainText(value);
        }
      };

      await expandAccordionAndAssertFields("More Payment Details", {
        "Amount Capturable": "",
        "Error Code": "N/A",
        "Mandate Data": "N/A",
        "Merchant ID": "",
        "Return URL": "https://google.com",
        "Off Session": "N/A",
        "Capture On": "-",
        "Next Action": "N/A",
        "Setup Future Usage": "N/A",
        "Cancellation Reason": "N/A",
        "Statement Descriptor Name": "Juspay",
        "Statement Descriptor Suffix": "Router",
        "Payment Experience": "N/A",
        "Merchant Order Reference ID": "abcd",
        "Extended Auth Applied": "false",
        "Extended Auth Last Applied At": "-",
        "Request Extended Auth": "false",
        "Hyperswitch Error Description": "N/A",
      });

      const paymentMethodDetails = page.getByText(/^Payment Method Details$/);
      await paymentMethodDetails.waitFor({ state: "attached", timeout: 10000 });
      await paymentMethodDetails.scrollIntoViewIfNeeded();
      await paymentMethodDetails.click();
      await expect(paymentMethodDetails.locator("xpath=../..")).toContainText(
        "card",
      );

      const paymentMetadata = page.getByText(/^Payment Metadata$/);
      await paymentMetadata.waitFor({ state: "attached", timeout: 10000 });
      await paymentMetadata.scrollIntoViewIfNeeded();
      await paymentMetadata.click();
      await expect(paymentMetadata.locator("xpath=../..")).toContainText("key");
      await expect(paymentMetadata.locator("xpath=../..")).toContainText(
        "value",
      );

      await expandAccordionAndAssertFields("FRM Details", {
        "Payment ID": "",
        "Payment Method Type": "",
        Amount: "",
        Currency: "",
        "Payment Processor": "",
        "FRM Connector": "",
        "FRM Message": "",
        "Merchant Decision": "",
      });
    });
  });

  // Sync button
  test.describe("Sync button", () => {
    test("should display Sync button for a processing payment", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request, 12345, false);
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();
      await page.locator('[data-table-location="Orders_tr1_td1"]').click();

      await expect(page.getByRole("button", { name: "Sync" })).toBeVisible();
    });

    test("should refresh payment data on Sync button click", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request, 12345, false);
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();
      await page.locator('[data-table-location="Orders_tr1_td1"]').click();

      const syncRequest = page.waitForRequest((req) =>
        req.url().includes("force_sync=true"),
      );
      await page.getByRole("button", { name: "Sync" }).click();
      await syncRequest;
    });

    test("should not display Sync button for a succeeded payment", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();
      await page.locator('[data-table-location="Orders_tr1_td1"]').click();

      await expect(
        page.getByRole("button", { name: "Sync" }),
      ).not.toBeVisible();
    });
  });

  // Refund cases
  test.describe("Refund cases", () => {
    const openRefundModal = async (page: Page, homePage: HomePage) => {
      await homePage.operations.click();
      await homePage.paymentOperations.click();
      await page.locator('[data-table-location="Orders_tr1_td1"]').click();
      await page.locator('[data-button-text="+ Refund"]').click();
      await expect(page.getByText("Initiate Refund").first()).toBeVisible();
    };

    test("should display all fields and details in the refund popup", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await openRefundModal(page, homePage);

      await expect(
        page.getByText(
          "Note: Refunds cannot be canceled once placed. Please verify before proceeding.",
        ),
      ).toBeVisible();

      await expect(page.locator('[data-label="Amount"]').first()).toContainText(
        "123.45 USD",
      );
      await expect(page.getByText("Payment ID").first()).toBeVisible();
      await expect(
        page.locator('[data-label="Customer ID"]').first(),
      ).toContainText("test_customer");
      await expect(
        page.locator('[data-label="Customer Email"]').first(),
      ).toContainText("abc@test.com");
      await expect(
        page.locator('[data-label="Amount Refunded"]').first(),
      ).toContainText("0 USD");
      await expect(
        page.locator('[data-label="Pending Requested Amount"]').first(),
      ).toContainText("0 USD");

      await expect(page.locator('[name="amount"]')).toHaveAttribute(
        "placeholder",
        "Enter Refund Amount",
      );
      await expect(page.locator('[name="reason"]')).toHaveAttribute(
        "placeholder",
        "Enter Refund Reason",
      );

      await expect(page.getByRole("button", { name: "Cancel" })).toBeVisible();
      await expect(
        page.getByRole("button", { name: "Initiate Refund" }),
      ).toBeVisible();
    });

    test("should show validation error when refund amount is zero", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await openRefundModal(page, homePage);

      await page.locator('[name="amount"]').fill("0");
      await page.locator('[name="amount"]').blur();
      await expect(
        page.getByText("Please enter refund amount greater than zero"),
      ).toBeVisible();
      await page.getByRole("button", { name: "Initiate Refund" }).isDisabled;
    });

    test("should show validation error when refund amount exceeds payment amount", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await openRefundModal(page, homePage);

      await page.locator('[name="amount"]').fill("999.99");
      await page.locator('[name="amount"]').blur();
      await expect(
        page.getByText("Refund amount should not exceed 123.45"),
      ).toBeVisible();
      await page.getByRole("button", { name: "Initiate Refund" }).isDisabled();
    });

    test("should successfully initiate a partial refund (amount less than payment)", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await openRefundModal(page, homePage);

      await page.locator('[name="amount"]').fill("50.00");
      await page.locator('[name="reason"]').fill("Partial refund test");
      await page.getByRole("button", { name: "Initiate Refund" }).click();

      await expect(
        page.getByRole("button", { name: "Initiate Refund" }),
      ).not.toBeVisible();

      const refundsTable = page.locator(
        'table[data-expandable-table="Refunds"]',
      );
      await expect(
        refundsTable.locator('[data-table-location="Refunds_tr1_td4"]'),
      ).toContainText("50");
      await expect(
        refundsTable.locator('[data-table-location="Refunds_tr1_td5"]'),
      ).toContainText("SUCCEEDED");
    });

    test("should successfully initiate a full refund (amount equal to payment)", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await openRefundModal(page, homePage);

      await page.locator('[name="amount"]').fill("123.45");
      await page.locator('[name="reason"]').fill("Full refund test");
      await page.getByRole("button", { name: "Initiate Refund" }).click();

      await expect(
        page.getByRole("button", { name: "Initiate Refund" }),
      ).not.toBeVisible();

      const refundsTable = page.locator(
        'table[data-expandable-table="Refunds"]',
      );
      await expect(
        refundsTable.locator('[data-table-location="Refunds_tr1_td4"]'),
      ).toContainText("123.45");
      await expect(
        refundsTable.locator('[data-table-location="Refunds_tr1_td5"]'),
      ).toContainText("SUCCEEDED");
    });

    test("should close refund popup on Cancel click", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request);
      }

      await openRefundModal(page, homePage);

      await page.getByRole("button", { name: "Cancel" }).click();

      await expect(
        page.getByRole("button", { name: "Initiate Refund" }),
      ).not.toBeVisible();
    });

    test("should disable Refund button when payment status is not Succeeded", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createDummyConnectorAPI(
          merchantId,
          "stripe_test_1",
          context.request,
        );
        await createPaymentAPI(merchantId, context.request, 12345, false);
      }

      await homePage.operations.click();
      await homePage.paymentOperations.click();
      await page.locator('[data-table-location="Orders_tr1_td1"]').click();

      await expect(
        page.getByRole("button", { name: "+ Refund" }),
      ).toBeDisabled();
    });
  });
});
