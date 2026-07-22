import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { CustomerOperations } from "../../support/pages/operations/CustomerOperations";
import { PaymentOperations } from "../../support/pages/operations/PaymentOperations";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
  createCustomerAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// ---------------------------------------------------------------------------
// Customer detail page (/customers/:id, src/screens/Customers/ShowCustomers.res)
// fires two requests on load:
//   GET  customers/:id        -> the customer summary (Summary section)
//   POST analytics/v1/search  -> related sub-resources (Payment Intents, Refunds)
// A freshly signed-up org has no transactions, so to exercise the
// "customer with >10 related records" path we mock both endpoints with canned
// data. Each global-search section carries `count` (the true total) and a page
// of `hits`; when count > 10 the preview renders a "View N results" pagination
// link to the full sub-resource list.
// ---------------------------------------------------------------------------
const RELATED_CUSTOMER_ID = "cus_pw_related";

type GlobalSearchSection = {
  index: string;
  count: number;
  hits: Record<string, unknown>[];
};

// Payment-intent hits carry every field the preview table's visible columns map
// (payment_id, status, amount, currency, active_attempt_id, etc.).
function buildPaymentIntentHits(n: number): Record<string, unknown>[] {
  return Array.from({ length: n }, (_, i) => ({
    payment_id: `pay_related_${i + 1}`,
    merchant_id: "merchant_pw",
    status: i % 2 === 0 ? "succeeded" : "failed",
    amount: 10000 + i,
    currency: "USD",
    active_attempt_id: `att_${i + 1}`,
    business_country: "US",
    business_label: "default",
    attempt_count: 1,
    created_at: 1700000000 + i * 1000,
    profile_id: "pro_pw",
    organization_id: "org_pw",
  }));
}

function buildRefundHits(n: number): Record<string, unknown>[] {
  return Array.from({ length: n }, (_, i) => ({
    refund_id: `ref_related_${i + 1}`,
    payment_id: `pay_related_${i + 1}`,
    refund_status: "success",
    total_amount: 5000 + i,
    currency: "USD",
    connector: "stripe",
    created_at: 1700000000 + i * 1000,
    profile_id: "pro_pw",
    organization_id: "org_pw",
    merchant_id: "merchant_pw",
  }));
}

async function mockCustomerWithRelatedRecords(page: Page): Promise<void> {
  // Customer summary. The glob also matches the SPA navigation to
  // /dashboard/customers/:id, so only intercept the XHR fetch — let the
  // document request fall through to the real app shell.
  await page.route(`**/customers/${RELATED_CUSTOMER_ID}`, (route) => {
    const request = route.request();
    if (request.resourceType() === "document" || request.method() !== "GET") {
      return route.fallback();
    }
    return route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        customer_id: RELATED_CUSTOMER_ID,
        name: "Related Records Customer",
        email: "related@test.com",
        phone: "9876543210",
        phone_country_code: "+91",
        description: "Customer with many related records",
        created_at: "2026-01-15T10:00:00.000Z",
      }),
    });
  });

  // Related sub-resources. 12 payment hits / count 25 -> preview truncates to a
  // single 10-row page and shows "View 25 results"; 6 refund hits / count 15 ->
  // all 6 render and "View 15 results" still appears (count > 10).
  await page.route("**/analytics/v1/search", (route) => {
    if (route.request().method() !== "POST") return route.fallback();
    const body: GlobalSearchSection[] = [
      { index: "payment_intents", count: 25, hits: buildPaymentIntentHits(12) },
      { index: "refunds", count: 15, hits: buildRefundHits(6) },
    ];
    return route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify(body),
    });
  });
}

test.describe("Customers page", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display Customers heading, empty state, and date range selector", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    const customerOperations = new CustomerOperations(page);

    const paymentOperations = new PaymentOperations(page);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(page).toHaveURL(/.*dashboard\/customers/);
    await expect(customerOperations.pageHeading).toBeVisible();

    const empty = page.getByText("No results found");
    const table = page.locator("table tbody tr");
    const hasEmpty = await empty.isVisible().catch(() => false);
    const rowCount = await table.count().catch(() => 0);
    expect(hasEmpty || rowCount === 0).toBeTruthy();

    await expect(paymentOperations.dateSelector).toBeVisible();

    await expect(customerOperations.searchInput).toBeVisible();
  });

  test("should navigate to customer list page after creating a payment", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const customerOperations = new CustomerOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(customerOperations.filterRow).toBeVisible();

    const columns = [
      { text: "S.No", exact: false },
      { text: "Customer Id", exact: false },
      { text: "Customer Name", exact: false },
      { text: "Email", exact: false },
      { text: "Phone Country Code", exact: false },
      { text: "Phone", exact: true },
      { text: "Description", exact: false },
    ];

    for (const column of columns) {
      await expect(
        customerOperations.table
          .getByText(column.text, { exact: column.exact })
          .first(),
      ).toBeVisible();
    }

    const firstRowCells: { row: number; col: number; text: string }[] = [
      { row: 1, col: 1, text: "1" },
      { row: 1, col: 2, text: "test_customer" },
      { row: 1, col: 3, text: "Joseph Doe" },
      { row: 1, col: 4, text: "abc@test.com" },
      { row: 1, col: 5, text: "+65" },
      { row: 1, col: 6, text: "999999999" },
      { row: 1, col: 7, text: "N/A" },
    ];

    for (const cell of firstRowCells) {
      await expect(
        customerOperations.customerCell(cell.row, cell.col),
      ).toHaveText(cell.text);
    }
  });

  test("should validate customer details page", async ({ page, context }) => {
    const homePage = new HomePage(page);

    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    await page.getByText("1", { exact: true }).click();

    await expect(page).toHaveURL(/.*dashboard\/customers\/test_customer/);

    await expect(page.getByText("Customers").nth(1)).toBeVisible();

    await expect(
      page.getByRole("link", { name: "Navigate to Customers" }),
    ).toBeVisible();
    await expect(page.getByLabel("Current page: test_customer")).toBeVisible();

    await expect(page.getByText("Summary")).toBeVisible();

    const summaryFields = [
      { label: "Customer ID", value: "test_customer" },
      { label: "Customer Name", value: "Joseph Doe" },
      { label: "Email", value: "abc@test.com" },
      { label: "Phone Country Code", value: "+65" },
      { label: "Phone", value: "999999999" },
      { label: "Description", value: "N/A" },
      { label: "Address", value: "N/A" },
    ];

    for (const field of summaryFields) {
      const container = paymentOperations.dataLabel(field.label);
      await expect(container).toBeVisible();
      await expect(
        container.getByText(field.label, { exact: true }),
      ).toBeVisible();
      await expect(
        container.getByText(field.value, { exact: true }),
      ).toBeVisible();
    }

    await expect(paymentOperations.dataLabel("Created")).toBeVisible();
    await expect(
      paymentOperations.dataLabel("Created").locator("[data-date]"),
    ).toBeVisible();
  });

  test("should display matching customer when searched by customer ID", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const customerOperations = new CustomerOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);
    await createCustomerAPI(merchantId, "test_customer2", context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    const searchInput = customerOperations.searchInput;
    await expect(searchInput).toBeVisible();

    await searchInput.fill("test_customer");
    await searchInput.press("Enter");

    await expect(customerOperations.customerCell(1, 2)).toContainText(
      "test_customer",
    );
    await expect(customerOperations.customerCell(2, 2)).toHaveCount(0);
    await expect(page.getByText("test_customer2")).not.toBeAttached();
  });

  test("should show empty state on non-existent customer search", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const customerOperations = new CustomerOperations(page);

    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createCustomerAPI(merchantId, "test_customer2", context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(page.getByText("test_customer2")).toBeVisible();

    const searchInput = customerOperations.genericSearchInput;

    await searchInput.fill("cust_nonexistent_zzz");
    await searchInput.press("Enter");

    await expect(customerOperations.pageHeading).toBeVisible();

    const empty = page.getByText("No results found");
    const table = page.locator("table tbody tr");
    const hasEmpty = await empty.isVisible().catch(() => false);
    const rowCount = await table.count().catch(() => 0);
    expect(hasEmpty || rowCount === 0).toBeTruthy();

    await expect(paymentOperations.dateSelector).toBeVisible();
    await expect(customerOperations.searchInput).toBeVisible();
    await expect(page.getByText("test_customer2")).not.toBeVisible();
  });

  test("should toggle columns from the column toggler", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const paymentOperations = new PaymentOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createCustomerAPI(merchantId, "test_customer2", context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    //Default order
    const tableHeadings = page.locator("[data-table-heading]");
    await expect(tableHeadings).toHaveText([
      "S.No",
      "Customer ID",
      "Customer Name",
      "Email",
      "Phone Country Code",
      "Phone",
      "Description",
      "Created",
    ]);

    //logic to change order drag column up and down
    await paymentOperations.columnButton.click();
    const modal = paymentOperations.tableColumnsModal;
    await expect(modal).toBeVisible();

    const modalColumns = modal.locator("[data-dropdown-value]");

    const dragColumn = async (
      sourceLabel: string,
      targetLabel: string,
      position: "above" | "below",
    ) => {
      const source = paymentOperations.dropdownValue(sourceLabel);
      const target = paymentOperations.dropdownValue(targetLabel);

      const sourceBox = await source.boundingBox();
      if (!sourceBox) {
        throw new Error(`Bounding box missing for ${sourceLabel}`);
      }

      const startX = sourceBox.x + sourceBox.width / 2;
      const startY = sourceBox.y + sourceBox.height / 2;

      await page.mouse.move(startX, startY);
      await page.mouse.down();
      // Nudge to engage the dnd library before measuring target
      await page.mouse.move(startX, startY + 8, { steps: 5 });

      // Re-measure target after the drag placeholder may have shifted layout
      const targetBox = await target.boundingBox();
      if (!targetBox) {
        await page.mouse.up();
        throw new Error(`Bounding box missing for ${targetLabel}`);
      }

      const endX = targetBox.x + targetBox.width / 2;
      // Aim explicitly above or below the target's midpoint so the drop
      // position does not depend on a coin-flip around the midpoint.
      const endY =
        position === "above"
          ? targetBox.y + 4
          : targetBox.y + targetBox.height - 4;

      await page.mouse.move(endX, endY, { steps: 15 });
      await page.mouse.move(endX, endY, { steps: 3 });
      await page.mouse.up();
      await page.waitForTimeout(300);
    };

    // Initial modal order
    await expect(modalColumns).toHaveText([
      "Customer ID",
      "Customer Name",
      "Email",
      "Phone Country Code",
      "Phone",
      "Description",
      "Created",
    ]);

    // Step 1: Email -> above Customer Name
    await dragColumn("Email", "Customer Name", "above");
    await expect(modalColumns).toHaveText([
      "Customer ID",
      "Email",
      "Customer Name",
      "Phone Country Code",
      "Phone",
      "Description",
      "Created",
    ]);

    // Step 2: Created -> above Phone Country Code
    await dragColumn("Created", "Phone Country Code", "above");
    await expect(modalColumns).toHaveText([
      "Customer ID",
      "Email",
      "Customer Name",
      "Created",
      "Phone Country Code",
      "Phone",
      "Description",
    ]);

    await paymentOperations.saveButton.click();
    await expect(modal).toBeHidden();
    await page.waitForLoadState("networkidle");

    //Updated order
    await expect(tableHeadings).toHaveText(
      [
        "S.No",
        "Customer ID",
        "Email",
        "Customer Name",
        "Created",
        "Phone Country Code",
        "Phone",
        "Description",
      ],
      { timeout: 15000 },
    );
  });

  test("should paginate through customer pages", async ({ page, context }) => {
    const homePage = new HomePage(page);

    const customerOperations = new CustomerOperations(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    const customerIds = Array.from(
      { length: 22 },
      (_, i) => `pw_customer_${i + 1}`,
    );

    for (const customerId of customerIds) {
      await createCustomerAPI(merchantId, customerId, context.request);
    }

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(customerOperations.tableRows).toHaveCount(20);
    const firstPageFirstId = await customerOperations
      .customerCell(1, 2)
      .textContent();

    await page.getByRole("button", { name: "2", exact: true }).click();

    await expect(customerOperations.customerCell(1, 2)).not.toHaveText(
      firstPageFirstId ?? "",
    );
    await expect(customerOperations.customerCell(1, 2)).toBeVisible();
    await expect(page.getByText("Showing 22")).toBeVisible();
  });

  test("should display related payments and refunds for a customer with many related records", async ({
    page,
  }) => {
    const paymentOperations = new PaymentOperations(page);

    await mockCustomerWithRelatedRecords(page);

    await page.goto(`/dashboard/customers/${RELATED_CUSTOMER_ID}`);
    await expect(page).toHaveURL(
      new RegExp(`dashboard/customers/${RELATED_CUSTOMER_ID}`),
    );

    // Summary section, driven by the mocked GET customers/:id response.
    await expect(page.getByText("Summary")).toBeVisible();
    const idLabel = paymentOperations.dataLabel("Customer ID");
    await expect(
      idLabel.getByText(RELATED_CUSTOMER_ID, { exact: true }),
    ).toBeVisible();
    await expect(
      paymentOperations
        .dataLabel("Email")
        .getByText("related@test.com", { exact: true }),
    ).toBeVisible();

    // Related sub-resource sections. Scope to the detail panel so the section
    // headers don't collide with the Operations sidebar links.
    await expect(
      page.getByText("Payment Intents", { exact: true }),
    ).toBeVisible();
    await expect(page.getByText("RefundsView 15")).toBeVisible();

    // Related payment rows render from the mocked hits.
    await expect(
      page.locator('[data-table-location="payment_intents_tr1_td1"]'),
    ).toContainText("pay_related_1");

    // The preview truncates to one 10-row page even though 12 hits were
    // returned — the rest are reachable only via the "View results" link.
    const paymentRows = page.locator(
      '[data-table-location^="payment_intents_tr"][data-table-location$="_td1"]',
    );
    await expect(paymentRows).toHaveCount(10);

    // count > 10 surfaces the pagination link to the full sub-resource list.
    await expect(page.getByText("View 25 results")).toBeVisible();
    await expect(page.getByText("View 15 results")).toBeVisible();

    // Download buttons reflect the number of loaded records per section.
    await expect(page.getByText("Download (12 records)")).toBeVisible();
    await expect(page.getByText("Download (6 records)")).toBeVisible();

    // Related refund rows render in full (6 hits, below the 10-row page size).
    await expect(
      page.locator('[data-table-location="refunds_tr1_td1"]'),
    ).toContainText("ref_related_1");
    const refundRows = page.locator(
      '[data-table-location^="refunds_tr"][data-table-location$="_td1"]',
    );
    await expect(refundRows).toHaveCount(6);
  });
});
