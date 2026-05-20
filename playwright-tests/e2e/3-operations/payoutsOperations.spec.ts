import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PayoutOperations } from "../../support/pages/operations/PayoutOperations";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createPayoutConnectorAPI,
  createPayoutAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
let email: string;

const setupPayout = async (
  homePage: HomePage,
  request: Parameters<typeof createPayoutConnectorAPI>[2],
) => {
  const merchantId = await homePage.merchantID.nth(0).textContent();
  if (!merchantId) {
    throw new Error("Merchant ID not found");
  }
  await createPayoutConnectorAPI(merchantId, "adyen_test_1", request);
  const payout = (await createPayoutAPI(merchantId, request)) as unknown as {
    payout_id: string;
    amount: number;
    currency: string;
    status: string;
    connector: string;
  };
  return { merchantId, payout };
};

const goToPayouts = async (page: Page, homePage: HomePage) => {
  await homePage.operations.click();
  await homePage.payoutsOperations.click();
  await expect(page).toHaveURL(/\/payouts/);
};

test.describe("Payouts Operations", () => {
  test.beforeEach(async ({ page }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test.describe("Payouts List page", () => {
    test("should show 'No results found' empty state when no payouts exist", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const payoutOperations = new PayoutOperations(page);

      await goToPayouts(page, homePage);

      await expect(payoutOperations.searchBox).toHaveAttribute(
        "placeholder",
        "Search for payout ID",
      );
      await expect(payoutOperations.dateSelector).toBeVisible();
      await expect(payoutOperations.addFilters).toBeVisible();

      await expect(payoutOperations.noResultsHeader).toHaveText(
        "No results found",
      );
      await expect(payoutOperations.expandSearch90Days).toBeVisible();
    });

    test.describe("Search bar", () => {
      test("should display correct payout when searched with payout ID", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        const { payout } = await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);

        const searchBox = payoutOperations.searchBox;
        await searchBox.fill(payout.payout_id);
        await searchBox.press("Enter");

        // CopyLinkTableCell truncates display to first 20 chars unless toggled,
        // so assert on the leading prefix rather than the full id.
        await expect(payoutOperations.payoutCell(1, 2)).toContainText(
          payout.payout_id.slice(0, 20),
        );
      });

      test("should show empty state when searched with invalid payout ID", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        const { payout } = await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);

        // Sanity check: the created payout shows up in row 1 before searching.
        await expect(payoutOperations.payoutCell(1, 2)).toContainText(
          payout.payout_id.slice(0, 20),
        );

        await payoutOperations.searchBox.fill("invalid_payout_id_xyz");
        await payoutOperations.searchBox.press("Enter");

        await expect(payoutOperations.noResultsHeader).toHaveText(
          "No results found",
        );
        await expect(payoutOperations.payoutCell(1, 2)).not.toBeVisible();
      });
    });

    test.describe("Columns", () => {
      test("should display all default columns in the payouts table", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);

        const expectedHeaders = [
          "S.No",
          "Payout ID",
          "Connector",
          "Amount",
          "Payout Status",
          "Connector Transaction ID",
          "Created At",
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
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);

        // Six columns shown by default (PayoutsEntity.res defaultColumns).
        const defaultColumns = [
          "Payout ID",
          "Connector",
          "Amount",
          "Payout Status",
          "Connector Transaction ID",
          "Created At",
        ];

        // Remaining 21 columns the user can opt-in via the customizer
        // (PayoutsEntity.res allColumns minus defaultColumns).
        const optionalColumns = [
          "Merchant ID",
          "Currency",
          "Payout Type",
          "Send Priority",
          "Billing",
          "Customer ID",
          "Auto Fulfill",
          "Email",
          "Name",
          "Phone",
          "Phone Country Code",
          "Client Secret",
          "Return URL",
          "Business Country",
          "Business Label",
          "Description",
          "Entity Type",
          "Recurring",
          "Error Message",
          "Error Code",
          "Profile ID",
        ];

        await payoutOperations.columnButton.click();

        // The customizer modal must list every selectable column.
        for (const column of [...defaultColumns, ...optionalColumns]) {
          await expect(payoutOperations.columnsModalBody).toContainText(column);
        }

        // Enable all optional columns and save.
        for (const column of optionalColumns) {
          await payoutOperations.dropdownValue(column).click();
        }
        await payoutOperations.saveButton.click();

        // Every column — default + optional — should now be rendered in the
        // table header.
        for (const column of [...defaultColumns, ...optionalColumns]) {
          await expect(payoutOperations.tableHeading(column)).toBeAttached();
        }
      });

      test("should filter columns in the customizer when searched by name", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);
        await payoutOperations.columnButton.click();

        const allColumns = [
          "Payout ID",
          "Connector",
          "Amount",
          "Payout Status",
          "Connector Transaction ID",
          "Created At",
          "Merchant ID",
          "Currency",
          "Payout Type",
          "Send Priority",
          "Billing",
          "Customer ID",
          "Auto Fulfill",
          "Email",
          "Name",
          "Phone",
          "Phone Country Code",
          "Client Secret",
          "Return URL",
          "Business Country",
          "Business Label",
          "Description",
          "Entity Type",
          "Recurring",
          "Error Message",
          "Error Code",
          "Profile ID",
        ];
        // Placeholder is `Search in ${allColumns.length} options`
        // (SelectModal.res:104).
        const searchInput = page.locator(
          `input[placeholder="Search in ${allColumns.length} options"]`,
        );

        for (const column of allColumns) {
          await searchInput.clear();
          await searchInput.fill(column);
          await expect(payoutOperations.dropdownValue(column)).toBeVisible();
        }

        // Garbage strings should collapse the list to the empty-state.
        await searchInput.clear();
        await searchInput.fill("not_a_real_column_xyz");
        await expect(page.getByText("No matching records found")).toBeVisible();
      });

      test("should persist column order after dragging and saving", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);

        const tableHeadings = page.locator("[data-table-heading]");
        // Default header order (PayoutsEntity.res:250) plus S.No.
        await expect(tableHeadings).toHaveText([
          "S.No",
          "Payout ID",
          "Connector",
          "Amount",
          "Payout Status",
          "Connector Transaction ID",
          "Created At",
        ]);

        await payoutOperations.columnButton.click();
        const modal = payoutOperations.tableColumnsModal;
        await expect(modal).toBeVisible();

        // Drag-and-drop helper copied from customers.spec.ts — the column
        // list is rendered through react-beautiful-dnd, which requires a
        // small initial nudge before the drop target is engaged.
        const dragColumn = async (
          sourceLabel: string,
          targetLabel: string,
          position: "above" | "below",
        ) => {
          const source = payoutOperations.dropdownValue(sourceLabel);
          const target = payoutOperations.dropdownValue(targetLabel);

          const sourceBox = await source.boundingBox();
          if (!sourceBox) {
            throw new Error(`Bounding box missing for ${sourceLabel}`);
          }

          const startX = sourceBox.x + sourceBox.width / 2;
          const startY = sourceBox.y + sourceBox.height / 2;

          await page.mouse.move(startX, startY);
          await page.mouse.down();
          await page.mouse.move(startX, startY + 8, { steps: 5 });

          const targetBox = await target.boundingBox();
          if (!targetBox) {
            await page.mouse.up();
            throw new Error(`Bounding box missing for ${targetLabel}`);
          }

          const endX = targetBox.x + targetBox.width / 2;
          const endY =
            position === "above"
              ? targetBox.y + 4
              : targetBox.y + targetBox.height - 4;

          await page.mouse.move(endX, endY, { steps: 15 });
          await page.mouse.move(endX, endY, { steps: 3 });
          await page.mouse.up();
          await page.waitForTimeout(300);
        };

        // Move "Amount" above "Connector" inside the modal.
        await dragColumn("Amount", "Connector", "above");

        await payoutOperations.saveButton.click();
        await expect(modal).toBeHidden();
        await page.waitForLoadState("networkidle");

        // Table should now reflect the modified column order.
        await expect(tableHeadings).toHaveText(
          [
            "S.No",
            "Payout ID",
            "Amount",
            "Connector",
            "Payout Status",
            "Connector Transaction ID",
            "Created At",
          ],
          { timeout: 15000 },
        );
      });
    });

    test.describe("Date Selector", () => {
      test("should apply a custom date range filter", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);

        const dateSelector = payoutOperations.dateSelector;
        await dateSelector.click();
        await payoutOperations
          .daterangeDropdownValue("Last 30 Days")
          .click();

        await expect(dateSelector).toContainText("Last 30 Days");
      });
    });

    test.describe("Filters", () => {
      test("should apply a Status filter", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);

        // The Add Filters dropdown lists filters by their snake_case API key
        // run through snakeToTitle (see Filter.res:251–256). For payouts the
        // available filter keys are connector, currency, payout_method, status
        // — so Status (not Payout Status) is the label that appears here.
        await payoutOperations.addFilters.click();
        await page
          .locator('[data-dropdown-value="Status"]:visible')
          .click();

        // Once the filter is added, a "Select status" chip is rendered with
        // the status field wrapper visible in the filter row.
        await expect(payoutOperations.payoutStatusFieldWrapper).toBeVisible();
        await expect(
          payoutOperations.filterChipArea.first(),
        ).toContainText("Select status");
      });
    });

    test.describe("Generate Report", () => {
      // Both `generate_report` AND `email` flags must be true for the button
      // to render (see PayoutsList.res:96), and at least one payout has to be
      // present in the list.
      test("should display Generate Report button when generate_report flag is ON", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        await page.route("**/dashboard/config/feature?domain=", async (route) => {
          const response = await route.fetch();
          const json = await response.json();
          json.features = {
            ...json.features,
            generate_report: true,
            email: true,
          };
          await route.fulfill({ response, json });
        });
        await page.reload();

        await goToPayouts(page, homePage);

        await expect(payoutOperations.generateReports).toBeVisible();

        await payoutOperations.generateReports.click();
        await expect(page.getByText("Generate Payout Reports")).toBeVisible();
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
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);

        await expect(payoutOperations.generateReports).not.toBeVisible();
      });
    });
  });

  test.describe("Payout details page", () => {
    test("should load the payout detail page when a row is clicked", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const payoutOperations = new PayoutOperations(page);
      const { payout } = await setupPayout(homePage, context.request);

      await goToPayouts(page, homePage);
      await payoutOperations.payoutCell(1, 1).click();

      await expect(page).toHaveURL(new RegExp(`/payouts/${payout.payout_id}`));

      // Page header + Summary section are the smoke markers for a successful
      // detail render.
      await expect(page.getByText("Summary", { exact: true })).toBeVisible();
      await expect(
        page.getByText("About Payout", { exact: true }),
      ).toBeVisible();
      await expect(
        page.getByText("Payout Attempts", { exact: true }),
      ).toBeVisible();
    });

    test("should display Summary and About Payout fields", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const payoutOperations = new PayoutOperations(page);
      const { payout } = await setupPayout(homePage, context.request);

      await goToPayouts(page, homePage);
      await payoutOperations.payoutCell(1, 1).click();

      // Big amount header + status badge (ShowPayout.res:117–128).
      await expect(
        page.locator('[class="md:text-5xl font-bold"]'),
      ).toContainText(`${payout.amount / 100} ${payout.currency}`);
      await expect(
        page.getByText(payout.status.toUpperCase(), { exact: true }).first(),
      ).toBeVisible();

      // Summary detailsFields=[Created, AmountReceived, PayoutId, ConnectorTransactionID, ErrorMessage].
      for (const label of [
        "Created",
        "Amount Received",
        "Payout ID",
        "Connector Transaction ID",
        "Error Message",
      ]) {
        await expect(
          payoutOperations.dataLabel(label).first(),
        ).toBeVisible();
      }

      // About Payout fields shown by ShowPayout.PayoutInfo.
      for (const label of [
        "Profile ID",
        "Payout Connector",
        "Connector Label",
        "Payout Type",
      ]) {
        await expect(
          payoutOperations.dataLabel(label).first(),
        ).toBeVisible();
      }
    });

    test.describe("Events and logs", () => {
      test("should display Events and logs accordion when auditTrail flag is ON", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        // audit_trail defaults to true locally; force it on explicitly so the
        // test does not depend on env state.
        await page.route(
          "**/dashboard/config/feature?domain=",
          async (route) => {
            const response = await route.fetch();
            const json = await response.json();
            json.features = { ...json.features, audit_trail: true };
            await route.fulfill({ response, json });
          },
        );
        await page.reload();

        await goToPayouts(page, homePage);
        await payoutOperations.payoutCell(1, 1).click();

        await expect(page.getByText("Events and logs")).toBeVisible();
      });

      test("should hide Events and logs accordion when auditTrail flag is OFF", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        await page.route(
          "**/dashboard/config/feature?domain=",
          async (route) => {
            const response = await route.fetch();
            const json = await response.json();
            json.features = { ...json.features, audit_trail: false };
            await route.fulfill({ response, json });
          },
        );
        await page.reload();

        await goToPayouts(page, homePage);
        await payoutOperations.payoutCell(1, 1).click();

        await expect(page.getByText("Summary", { exact: true })).toBeVisible();
        await expect(page.getByText("Events and logs")).not.toBeVisible();
      });
    });
  });

  test.describe("Sync button", () => {
    // ShowPayout.res does not render a Sync button (unlike ShowOrder.res /
    // refund details). Marked as skip rather than asserting on absent UI so
    // the gap stays visible in the test report.
    test.skip(
      "should display Sync button for a non-terminal status payout",
      () => {},
    );
  });
});
