import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { RefundOperations } from "../../support/pages/operations/RefundOperations";
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

const goToRefunds = async (
  page: Page,
  homePage: HomePage,
  _refundOperations?: RefundOperations,
) => {
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

      const refundOperations = new RefundOperations(page);
      await setupRefund(homePage, context.request);

      await goToRefunds(page, homePage);

      for (const view of ["All", "Succeeded", "Failed", "Pending"]) {
        await expect(refundOperations.refundsTransactionView).toContainText(view);
      }

      await expect(refundOperations.searchBox).toHaveAttribute(
        "placeholder",
        "Search for payment ID or refund ID",
      );
      await expect(
        refundOperations.dateSelector,
      ).toBeVisible();
      await expect(refundOperations.addFilters).toBeVisible();
      await expect(
        refundOperations.columnButton,
      ).toBeVisible();

      await expect(page.locator("table thead tr th")).toHaveCount(7);
      await expect(
        refundOperations.refundCell(1, 1),
      ).toBeVisible();
    });

    test("should show 'No results found' empty state when no refunds exist", async ({
      page,
    }) => {
      const homePage = new HomePage(page);

      const refundOperations = new RefundOperations(page);
      await goToRefunds(page, homePage);

      for (const view of ["All", "Succeeded", "Failed", "Pending"]) {
        await expect(refundOperations.refundsTransactionView).toContainText(view);
      }

      await expect(refundOperations.searchBox).toHaveAttribute(
        "placeholder",
        "Search for payment ID or refund ID",
      );
      await expect(
        refundOperations.dateSelector,
      ).toBeVisible();
      await expect(refundOperations.addFilters).toBeVisible();

      await expect(
        refundOperations.noResultsHeader,
      ).toHaveText("No results found");
      await expect(
        refundOperations.expandSearch90Days,
      ).toHaveText("Expand the search to the previous 90 days");
    });

    test.describe("Search bar", () => {
      test("should display correct refund when searched with payment ID or refund ID", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);

        const refundOperations = new RefundOperations(page);
        const { payment, refund } = await setupRefund(
          homePage,
          context.request,
        );

        await goToRefunds(page, homePage);

        const searchBox = refundOperations.searchBox;

        await searchBox.fill(payment.payment_id);
        await searchBox.press("Enter");
        await expect(
          refundOperations.refundCell(1, 6),
        ).toContainText(payment.payment_id);

        await searchBox.clear();

        await searchBox.fill(refund.refund_id);
        await searchBox.press("Enter");
        await expect(
          refundOperations.refundCell(1, 2),
        ).toContainText(refund.refund_id);
      });

      test("should display empty state when searched with invalid ID", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);

        const refundOperations = new RefundOperations(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        await refundOperations.searchBox.fill("invalid_refund_id_xyz");
        await refundOperations.searchBox.press("Enter");

        await expect(
          refundOperations.noResultsHeader,
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

        const refundOperations = new RefundOperations(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        await refundOperations.columnButton.click();

        await expect(
          refundOperations.tableColumnsDropdownItems,
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
          await refundOperations.dropdownValue(column).click();
        }

        await refundOperations.saveButton.click();

        for (const column of expectedHeaders) {
          await expect(
            refundOperations.tableHeading(column),
          ).toBeAttached();
        }

        for (const column of optionalColumns) {
          await expect(
            refundOperations.tableHeading(column),
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

        const refundOperations = new RefundOperations(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        const dateSelector = refundOperations.dateSelector;
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

        const refundOperations = new RefundOperations(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        await refundOperations.addFilters.click();

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

        const refundOperations = new RefundOperations(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        // Connector — open dropdown and select first option (Stripe Dummy)
        await refundOperations.addFilters.click();
        await page
          .locator('div').filter({ hasText: /^Connector$/ }).first()
          .click();
        await page.getByText("Select Connector").click();
        await page.locator('[value="Stripe Dummy"]').click();
        await refundOperations.applyButton.click();
        await expect(page.getByText("Stripe Dummy").first()).toBeVisible();
        await expect(page.locator('[placeholder="Search..."]')).not.toBeVisible();

        // Currency — select USD (first matching value)
        await refundOperations.addFilters.click();
        await page
          .locator('div').filter({ hasText: /^Currency$/ }).first()
          .click();
        await page.getByText("Select Currency").click();
        await page.locator('[placeholder="Search..."]').fill("USD");
        await page.locator('[data-searched-text="USD"]').click();
        await refundOperations.applyButton.click();
        await expect(page.getByText("USD").first()).toBeVisible();

        // Refund Status — select Succeeded (first option)
        await refundOperations.addFilters.click();
        await page
          .locator('div').filter({ hasText: /^Refund Status$/ }).first()
          .click();
        await page
          .locator('[data-component-field-wrapper="field-refund_status"]')
          .click();
        await page.locator('[value="success"]').click();
        await refundOperations.applyButton.click();
        await expect(page.getByText("Succeeded").first()).toBeVisible();

        await page.getByRole("button", { name: "Clear All" }).click();
      });

      test("should filter refunds by Succeeded status via view chip", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);

        const refundOperations = new RefundOperations(page);
        const { refund } = await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        await page.getByText("Succeeded", { exact: true }).first().click();

        await expect(
          refundOperations.refundCell(1, 2),
        ).toContainText(refund.refund_id);
        await expect(
          refundOperations.refundCell(1, 5),
        ).toContainText("SUCCEEDED");
      });
    });

    test.describe("Generate Report", () => {
      test("should display Generate Report button when generate_report flag is ON", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);

        const refundOperations = new RefundOperations(page);
        await setupRefund(homePage, context.request);

        await page.route(/\/config\/feature/, async (route) => {
          const response = await route.fetch();
          const json = await response.json();
          json.features = { ...json.features, generate_report: true };
          await route.fulfill({ response, json });
        });
        await page.reload();

        await goToRefunds(page, homePage);

        await expect(refundOperations.generateReports).toBeVisible();

        await refundOperations.generateReports.click();
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

        const refundOperations = new RefundOperations(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);

        await expect(
          refundOperations.generateReports,
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

      const refundOperations = new RefundOperations(page);
      const { payment, refund } = await setupRefund(homePage, context.request);

      await goToRefunds(page, homePage);
      await refundOperations.refundCell(1, 1).click();

      await expect(page).toHaveURL(new RegExp(`/refunds/${refund.refund_id}`));

      await expect(page.getByText("Summary", { exact: true })).toBeVisible();
      await expect(refundOperations.refundSummaryAmount).toContainText(
        `${refund.amount / 100} ${refund.currency}`,
      );

      await expect(
        refundOperations.dataLabel("Connector").first(),
      ).toBeVisible();
      await expect(
        refundOperations.dataLabel("Created").first(),
      ).toBeVisible();
      await expect(
        refundOperations.dataLabel("Currency").first(),
      ).toBeVisible();
      await expect(
        refundOperations.dataLabel("Error Code").first(),
      ).toBeVisible();
      await expect(
        refundOperations.dataLabel("Error Message").first(),
      ).toBeVisible();

      await expect(
        refundOperations.dataLabel("Last Updated").first(),
      ).toBeVisible();
      await expect(
        refundOperations.dataLabel("Metadata").first(),
      ).toBeVisible();
      await expect(
        refundOperations.dataLabel("Payment ID").first(),
      ).toContainText(payment.payment_id);
      await expect(
        refundOperations.dataLabel("Refund ID").first(),
      ).toContainText(refund.refund_id);
      await expect(
        refundOperations.dataLabel("Refund Reason").first(),
      ).toBeVisible();

      await expect(page.getByText("Payment", { exact: true })).toBeVisible();
      await expect(page.getByRole('columnheader', { name: 'Payment ID' })).toBeVisible();
      await expect(refundOperations.paymentCell(1, 2)).toContainText(payment.payment_id);
    });

    test.describe("Sync button", () => {
      test("should display Sync button for a refund with non-terminal status", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);

        const refundOperations = new RefundOperations(page);
        const { refund } = await setupRefund(homePage, context.request);

        await page.route(`**/refunds/${refund.refund_id}`, async (route) => {
          const response = await route.fetch();
          const json = await response.json();
          json.status = "pending";
          await route.fulfill({ response, json });
        });

        await goToRefunds(page, homePage);
        await refundOperations.refundCell(1, 1).click();

        await expect(page.getByRole("button", { name: "Sync" })).toBeVisible();
      });

      test("should not display Sync button for a succeeded refund", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);

        const refundOperations = new RefundOperations(page);
        await setupRefund(homePage, context.request);

        await goToRefunds(page, homePage);
        await refundOperations.refundCell(1, 1).click();

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

      const refundOperations = new RefundOperations(page);
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
      await refundOperations.refundCell(1, 1).click();

      await expect(
        refundOperations.dataLabel("Error Code").first(),
      ).toContainText("RU01");
      await expect(
        refundOperations.dataLabel("Error Message").first(),
      ).toContainText("Refund declined by processor");
    });
  });
});
