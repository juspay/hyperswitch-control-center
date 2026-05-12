import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  createPaymentAPI,
  createRefundAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
const refundColumnSize = 12;
let email: string;

const setupRefund = async (
  homePage: HomePage,
  request: Parameters<typeof createDummyConnectorAPI>[2],
) => {
  const merchantId = await homePage.merchantID.nth(0).textContent();
  if (!merchantId) {
    throw new Error("Merchant ID not found");
  }
  await createDummyConnectorAPI(merchantId, "stripe_test_1", request);
  const payment = await createPaymentAPI(merchantId, request);
  const refund = await createRefundAPI(merchantId, payment.payment_id, request);
  return { merchantId, payment, refund };
};

const goToRefunds = async (page: Page, homePage: HomePage) => {
  await homePage.operations.click();
  await homePage.refundOperations.click();
  await expect(page).toHaveURL(/\/refunds/);
};

test.describe("Refunds Operations", () => {
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test.describe("Refunds List page", () => {
    test("should display all components when refunds list loads", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      await setupRefund(homePage, context.request);

      await goToRefunds(page, homePage);

      const transactionView = page.locator(
        '[class="grid lg:grid-cols-4 md:grid-cols-3 sm:grid-cols-2 grid-cols-2 gap-6 mb-8"]',
      );
      for (const view of ["All", "Succeeded", "Failed", "Pending"]) {
        await expect(transactionView).toContainText(view);
      }

      await expect(page.locator('[name="name"]')).toHaveAttribute(
        "placeholder",
        "Search for payment ID or refund ID",
      );
      await expect(
        page.locator('[data-testid="date-range-selector"]'),
      ).toBeVisible();
      await expect(page.locator('[data-icon="plus"]')).toBeVisible();
      await expect(
        page.locator('[data-button-for="CustomIcon"]'),
      ).toBeVisible();

      await expect(page.locator("table thead tr th")).toHaveCount(7);
      await expect(
        page.locator('[data-table-location="Refunds_tr1_td1"]'),
      ).toBeVisible();
    });

    test("should show 'No results found' empty state when no refunds exist", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      await goToRefunds(page, homePage);

      await expect(
        page.locator(
          '[class="items-center text-2xl text-black font-bold mb-4"]',
        ),
      ).toHaveText("No results found");
      await expect(
        page.locator('[data-button-for="expandTheSearchToThePrevious90Days"]'),
      ).toHaveText("Expand the search to the previous 90 days");
    });

    test.describe("Search bar", () => {
      test("should display correct refund when searched with payment ID or refund ID", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const { payment, refund } = await setupRefund(
          homePage,
          context.request,
        );

        await goToRefunds(page, homePage);

        const searchBox = page.locator('[name="name"]');

        await searchBox.fill(payment.payment_id);
        await searchBox.press("Enter");
        await expect(
          page.locator('[data-table-location="Refunds_tr1_td6"]'),
        ).toContainText(payment.payment_id);

        await searchBox.clear();

        await searchBox.fill(refund.refund_id);
        await searchBox.press("Enter");
        await expect(
          page.locator('[data-table-location="Refunds_tr1_td2"]'),
        ).toContainText(refund.refund_id);
      });

      test("should display empty state when searched with invalid ID", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        await page.locator('[name="name"]').fill("invalid_refund_id_xyz");
        await page.locator('[name="name"]').press("Enter");

        await expect(
          page.locator(
            '[class="items-center text-2xl text-black font-bold mb-4"]',
          ),
        ).toHaveText("No results found");
      });
    });

    test.describe("Columns", () => {
      test("should display all default columns in the refunds table", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        const expectedHeaders = [
          "S.No",
          "Refund ID",
          "Connector",
          "Amount",
          "Refund Status",
          "Payment ID",
          "Created",
        ];

        for (let i = 0; i < expectedHeaders.length; i++) {
          await expect(page.locator("table thead tr th").nth(i)).toHaveText(
            expectedHeaders[i],
          );
        }
      });

      test("should allow selecting and deselecting columns from the column toggler", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        await page.locator('[data-button-for="CustomIcon"]').click();

        await expect(
          page.locator(
            '[data-component="modal:Table Columns"] [data-dropdown-numeric]',
          ),
        ).toHaveCount(refundColumnSize);

        const expectedHeaders = [
          "S.No",
          "Refund ID",
          "Connector",
          "Amount",
          "Refund Status",
          "Payment ID",
          "Created",
        ];

        const optionalColumns = [
          "Currency",
          "Error Code",
          "Error Message",
          "Last Updated",
          "Metadata",
          "Refund Reason",
        ];
        for (const column of optionalColumns) {
          await page.locator(`[data-dropdown-value="${column}"]`).click();
        }

        await page.locator('[data-button-text="Save"]').click();

        for (const column of expectedHeaders) {
          await expect(
            page.locator(`[data-table-heading="${column}"]`),
          ).toBeAttached();
        }

        for (const column of optionalColumns) {
          await expect(
            page.locator(`[data-table-heading="${column}"]`),
          ).toBeAttached();
        }
      });
    });

    test.describe("Date Selector", () => {
      test("should apply a custom date range filter", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        const dateSelector = page.locator(
          '[data-testid="date-range-selector"]',
        );
        await dateSelector.click();
        await page
          .locator('[data-daterange-dropdown-value="Last 30 Days"]')
          .click();

        await expect(dateSelector).toContainText("Last 30 Days");
      });
    });

    test.describe("Filters", () => {
      const allFilters = ["Connector", "Currency", "Refund Status", "Amount"];

      test("should display all available filters in the Add Filters dropdown", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        await page.locator('[data-icon="plus"]').click();

        const filterDropdown = page.locator('div').filter({ hasText: /^ConnectorCurrencyRefund StatusAmount$/ }).nth(1);
        for (const filter of allFilters) {
          await expect(filterDropdown).toContainText(filter);
        }
      });

      test("should apply all filters with first value and remove each via its own close button", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        // Connector — open dropdown and select first option (Stripe Dummy)
        await page.locator('[data-icon="plus"]').click();
        await page
          .locator('div').filter({ hasText: /^Connector$/ }).first()
          .click();
        await page.getByText("Select Connector").click();
        await page.locator('[value="Stripe Dummy"]').click();
        await page.locator('[data-button-text="Apply"]').click();
        await expect(page.getByText("Stripe Dummy").first()).toBeVisible();
        await expect(page.locator('[placeholder="Search..."]')).not.toBeVisible();

        // Currency — select USD (first matching value)
        await page.locator('[data-icon="plus"]').click();
        await page
          .locator('div').filter({ hasText: /^Currency$/ }).first()
          .click();
        await page.getByText("Select Currency").click();
        await page.locator('[placeholder="Search..."]').fill("USD");
        await page.locator('[data-searched-text="USD"]').click();
        await page.locator('[data-button-text="Apply"]').click();
        await expect(page.getByText("USD").first()).toBeVisible();

        // Refund Status — select Succeeded (first option)
        await page.locator('[data-icon="plus"]').click();
        await page
          .locator('div').filter({ hasText: /^Refund Status$/ }).first()
          .click();
        await page
          .locator('[data-component-field-wrapper="field-refund_status"]')
          .click();
        await page.locator('[value="success"]').click();
        await page.locator('[data-button-text="Apply"]').click();
        await expect(page.getByText("Succeeded").first()).toBeVisible();

        await page.getByRole("button", { name: "Clear All" }).click();
      });

      test("should filter refunds by Succeeded status via view chip", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const { refund } = await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        await page.getByText("Succeeded", { exact: true }).first().click();

        await expect(
          page.locator('[data-table-location="Refunds_tr1_td2"]'),
        ).toContainText(refund.refund_id);
        await expect(
          page.locator('[data-table-location="Refunds_tr1_td5"]'),
        ).toContainText("SUCCEEDED");
      });
    });

    test.describe("Generate Report", () => {
      test("should display Generate Report button when generate_report flag is ON", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        await setupRefund(homePage, context.request);

        await page.route(/\/config\/feature/, async (route) => {
          const response = await route.fetch();
          const json = await response.json();
          json.features = { ...json.features, generate_report: true };
          await route.fulfill({ response, json });
        });
        await page.reload();

        await goToRefunds(page, homePage);

        const generateReportsButton = page.locator(
          '[data-button-for="generateReports"]',
        );
        await expect(generateReportsButton).toBeVisible();

        await generateReportsButton.click();
        await expect(page.getByText("Generate Refund Reports")).toBeVisible();
        await expect(page.getByText("Date Range *")).toBeVisible();
        await expect(page.getByText("Report Type")).toBeVisible();
        await expect(page.getByText("Additional Recipients")).toBeVisible();
        await page
          .getByRole("button", { name: "Generate", exact: true })
          .click();
      });

      test("should hide Generate Report button when generate_report flag is OFF", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        await expect(
          page.locator('[data-button-for="generateReports"]'),
        ).not.toBeVisible();
      });
    });
  });

  test.describe("Refund Detail page", () => {
    test("should display Summary section with refund fields", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const { payment, refund } = await setupRefund(homePage, context.request);

      await goToRefunds(page, homePage);
      await page.locator('[data-table-location="Refunds_tr1_td1"]').click();

      await expect(page).toHaveURL(new RegExp(`/refunds/${refund.refund_id}`));

      await expect(page.getByText("Summary", { exact: true })).toBeVisible();
      await expect(
        page.locator('[class="font-bold text-4xl m-3"]'),
      ).toContainText(`${refund.amount / 100} ${refund.currency}`);

      await expect(
        page.locator('[data-label="Connector"]').first(),
      ).toBeVisible();
      await expect(
        page.locator('[data-label="Created"]').first(),
      ).toBeVisible();
      await expect(
        page.locator('[data-label="Currency"]').first(),
      ).toBeVisible();
      await expect(
        page.locator('[data-label="Error Code"]').first(),
      ).toBeVisible();
      await expect(
        page.locator('[data-label="Error Message"]').first(),
      ).toBeVisible();

      await expect(
        page.locator('[data-label="Last Updated"]').first(),
      ).toBeVisible();
      await expect(
        page.locator('[data-label="Metadata"]').first(),
      ).toBeVisible();
      await expect(
        page.locator('[data-label="Payment ID"]').first(),
      ).toContainText(payment.payment_id);
      await expect(
        page.locator('[data-label="Refund ID"]').first(),
      ).toContainText(refund.refund_id);
      await expect(
        page.locator('[data-label="Refund Reason"]').first(),
      ).toBeVisible();
    });

    test("should display Payment section with related payment details", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const { payment } = await setupRefund(homePage, context.request);

      await goToRefunds(page, homePage);
      await page.locator('[data-table-location="Refunds_tr1_td1"]').click();

      await expect(page.getByText("Payment", { exact: true })).toBeVisible();
      await expect(page.getByRole('columnheader', { name: 'Payment ID' })).toBeVisible();
      await expect(page.locator('[data-table-location="Payment_tr1_td2"]')).toContainText(payment.payment_id);
    });

    test.describe("Sync button", () => {
      test("should display Sync button for a refund with non-terminal status", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const { refund } = await setupRefund(homePage, context.request);

        await page.route(`**/refunds/${refund.refund_id}`, async (route) => {
          const response = await route.fetch();
          const json = await response.json();
          json.status = "pending";
          await route.fulfill({ response, json });
        });

        await goToRefunds(page, homePage);
        await page.locator('[data-table-location="Refunds_tr1_td1"]').click();

        await expect(page.getByRole("button", { name: "Sync" })).toBeVisible();
      });

      test("should not display Sync button for a succeeded refund", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);
        await page.locator('[data-table-location="Refunds_tr1_td1"]').click();

        await expect(page.getByText("Summary", { exact: true })).toBeVisible();
        await expect(
          page.getByRole("button", { name: "Sync" }),
        ).not.toBeVisible();
      });
    });

    test("should display error code and message for a failed refund", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const { refund } = await setupRefund(homePage, context.request);

      await page.route(`**/refunds/${refund.refund_id}`, async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        json.status = "failed";
        json.error_code = "RU01";
        json.error_message = "Refund declined by processor";
        await route.fulfill({ response, json });
      });

      await goToRefunds(page, homePage);
      await page.locator('[data-table-location="Refunds_tr1_td1"]').click();

      await expect(
        page.locator('[data-label="Error Code"]').first(),
      ).toContainText("RU01");
      await expect(
        page.locator('[data-label="Error Message"]').first(),
      ).toContainText("Refund declined by processor");
    });
  });
});
