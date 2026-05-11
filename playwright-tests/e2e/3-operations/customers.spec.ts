import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
  createCustomerAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Customers page", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display Customers heading, empty state, and date range selector", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(page).toHaveURL(/.*dashboard\/customers/);
    await expect(page.getByText('CustomersView all customers')).toBeVisible();

    const empty = page.getByText("No results found");
    const table = page.locator("table tbody tr");
    const hasEmpty = await empty.isVisible().catch(() => false);
    const rowCount = await table.count().catch(() => 0);
    expect(hasEmpty || rowCount === 0).toBeTruthy();

    await expect(
      page.locator('[data-testid="date-range-selector"]'),
    ).toBeVisible();

    await expect(page.getByRole('textbox', { name: 'Search for Customer ID' })).toBeVisible();

    await expect(page.getByRole('button').nth(3)).not.toBeAttached();
  });

  test("should navigate to customer list page after creating a payment", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(page.locator('.flex.flex-row.items-stretch')).toBeVisible();

    const columns = [
      { text: "S.No", exact: false },
      { text: "Customer Id", exact: false },
      { text: "Customer Name", exact: false },
      { text: "Email", exact: false },
      { text: "Phone Country Code", exact: false },
      { text: "Phone", exact: true },
      { text: "Description", exact: false },
    ];

    const table = page.locator("#table");
    for (const column of columns) {
      await expect(
        table.getByText(column.text, { exact: column.exact }).first(),
      ).toBeVisible();
    }

    const firstRowCells = [
      { location: "Customers_tr1_td1", text: "1" },
      { location: "Customers_tr1_td2", text: "test_customer" },
      { location: "Customers_tr1_td3", text: "Joseph Doe" },
      { location: "Customers_tr1_td4", text: "abc@test.com" },
      { location: "Customers_tr1_td5", text: "+65" },
      { location: "Customers_tr1_td6", text: "999999999" },
      { location: "Customers_tr1_td7", text: "N/A" },
    ];

    for (const cell of firstRowCells) {
      await expect(
        page.locator(`[data-table-location="${cell.location}"]`),
      ).toHaveText(cell.text);
    }
  });

  test("should validate customer details page", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    await page.getByText('1', { exact: true }).click();

    await expect(page).toHaveURL(/.*dashboard\/customers\/test_customer/);

    await expect(page.getByText("Customers").nth(1)).toBeVisible();

    await expect(
      page.getByRole("link", { name: "Navigate to Customers" }),
    ).toBeVisible();
    await expect(
      page.getByLabel("Current page: test_customer"),
    ).toBeVisible();

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
      const container = page.locator(`[data-label="${field.label}"]`);
      await expect(container).toBeVisible();
      await expect(container.getByText(field.label, { exact: true })).toBeVisible();
      await expect(container.getByText(field.value, { exact: true })).toBeVisible();
    }

    await expect(page.locator('[data-label="Created"]')).toBeVisible();
    await expect(
      page.locator('[data-label="Created"] [data-date]'),
    ).toBeVisible();
  });

  test("should display matching customer when searched by customer ID", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(merchantId, "stripe_test_1", context.request);
    await createPaymentAPI(merchantId, context.request);
    await createCustomerAPI(merchantId, "test_customer2", context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    const searchInput = page.getByRole('textbox', { name: 'Search for Customer ID' });
    await expect(searchInput).toBeVisible();

    await searchInput.fill("test_customer");
    await searchInput.press("Enter");

    await expect(page.locator('[data-table-location="Customers_tr1_td2"]')).toContainText("test_customer");
    await expect(page.locator('[data-table-location="Customers_tr2_td2"]')).toHaveCount(0);
    await expect(page.getByText('test_customer2')).not.toBeAttached();
  });

  test("should show empty state on non-existent customer search", async ({
    page,
    context
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createCustomerAPI(merchantId, "test_customer2", context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    await expect(page.getByText('test_customer2')).toBeVisible();

    const searchInput = page.locator('input[placeholder*="Search" i]').first();

    await searchInput.fill("cust_nonexistent_zzz");
    await searchInput.press("Enter");

    await expect(page.getByText('CustomersView all customers')).toBeVisible();

    const empty = page.getByText("No results found");
    const table = page.locator("table tbody tr");
    const hasEmpty = await empty.isVisible().catch(() => false);
    const rowCount = await table.count().catch(() => 0);
    expect(hasEmpty || rowCount === 0).toBeTruthy();

    await expect(page.locator('[data-testid="date-range-selector"]')).toBeVisible();
    await expect(page.getByRole('textbox', { name: 'Search for Customer ID' })).toBeVisible();
    await expect(page.getByRole('button').nth(3)).not.toBeAttached();
    await expect(page.getByText('test_customer2')).not.toBeVisible();
  });

  test("should toggle columns from the column toggler", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createCustomerAPI(merchantId, "test_customer2", context.request);

    await homePage.operations.click();
    await homePage.customers.click();

    //Default order
    await expect(page.getByText('S.NoCustomer IdCustomer NameEmailPhone Country CodePhoneDescriptionCreated')).toBeVisible();

    //logic to change order drag column up and down
    await page.locator('[data-button-for="CustomIcon"]').click();
    const modal = page.locator('[data-component="modal:Table Columns"]');
    await expect(modal).toBeVisible();

    const dragColumn = async (sourceLabel: string, targetLabel: string) => {
      const source = modal.locator(
        `[data-dropdown-value="${sourceLabel}"]`,
      );
      const target = modal.locator(
        `[data-dropdown-value="${targetLabel}"]`,
      );

      const sourceBox = await source.boundingBox();
      const targetBox = await target.boundingBox();
      if (!sourceBox || !targetBox) {
        throw new Error(
          `Bounding box missing for ${sourceLabel} or ${targetLabel}`,
        );
      }

      const startX = sourceBox.x + sourceBox.width / 2;
      const startY = sourceBox.y + sourceBox.height / 2;
      const endX = targetBox.x + targetBox.width / 2;
      const endY = targetBox.y + targetBox.height / 2;

      await page.mouse.move(startX, startY);
      await page.mouse.down();
      await page.mouse.move(startX, startY + 8, { steps: 5 });
      await page.mouse.move(endX, endY, { steps: 15 });
      await page.mouse.move(endX, endY + 2, { steps: 3 });
      await page.mouse.up();
      await page.waitForTimeout(300);
    };

    // Initial modal order: [Customer Id, Customer Name, Email, Phone Country Code, Phone, Description, Created]
    // Step 1: Email -> above Customer Name
    await dragColumn("Email", "Customer Name");
    // Step 2: Created -> above Phone Country Code
    await dragColumn("Created", "Phone Country Code");
    // Step 3: Phone Country Code -> below Description
    await dragColumn("Phone Country Code", "Description");

    await page.locator('[data-button-text="Save"]').click();
    await expect(modal).toBeHidden();
    await page.waitForLoadState("networkidle");

    //Updated order
    await expect(
      page.getByText(
        'S.NoCustomer IdEmailCustomer NameCreatedPhone Country CodePhoneDescription',
      ),
    ).toBeVisible({ timeout: 15000 });

  });

  test("should paginate through customer pages", async ({ page, context }) => {
    const homePage = new HomePage(page);

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

    await expect(page.locator("#table tbody tr")).toHaveCount(20);
    const firstPageFirstId = await page
      .locator('[data-table-location="Customers_tr1_td2"]')
      .textContent();

    await page.getByRole("button", { name: "2", exact: true }).click();

    await expect(
      page.locator('[data-table-location="Customers_tr1_td2"]'),
    ).not.toHaveText(firstPageFirstId ?? "");
    await expect(
      page.locator('[data-table-location="Customers_tr1_td2"]'),
    ).toBeVisible();
    await expect(page.getByText('Showing 22')).toBeVisible();
  });
});
