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
      // PayoutsUtils.res:127-134 — supported filter keys for payouts.
      // Filter.res:251-256 snakeToTitle's the keys into Add-Filters labels.
      const filterKeys = ["connector", "currency", "payout_method", "status"];
      const filterLabels = ["Connector", "Currency", "Payout Method", "Status"];

      test("should apply a Status filter", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);

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

      test("should list all available filter options in the Add Filters dropdown", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);

        await payoutOperations.addFilters.click();

        for (const label of filterLabels) {
          await expect(
            payoutOperations.visibleDropdownValue(label),
          ).toBeVisible();
        }
      });

      test("should render a filter chip for each selected filter option", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);

        await goToPayouts(page, homePage);

        for (let i = 0; i < filterLabels.length; i++) {
          const label = filterLabels[i];
          const key = filterKeys[i];

          await payoutOperations.addFilters.click();
          await page
            .locator(`[data-dropdown-value="${label}"]:visible`)
            .click();

          // PayoutsUtils.res renders the chip as `Select ${key}` with the
          // raw snake_case API key (not snakeToTitle'd).
          await expect(
            payoutOperations.filterChipArea.first(),
          ).toContainText(`Select ${key}`);

          // Remove the chip so the next iteration starts clean.
          await payoutOperations.crossOutlineIcon.first().click();
        }
      });

      // Shared helpers + fixtures for the status-filter scenarios below.
      const succeededId = "playwright_success_00000000000000000001";
      const failedId = "playwright_failed_00000000000000000002";

      const buildPayout = (payoutId: string, status: string) => ({
        payout_id: payoutId,
        merchant_id: "playwright_merchant",
        merchant_order_reference_id: null,
        amount: 4000,
        currency: "USD",
        connector: "adyen",
        payout_type: "card",
        payout_method_data: null,
        billing: {
          address: {
            city: "San Francisco",
            country: "US",
            line1: "1467",
            line2: "Harrison Street",
            line3: "Harrison Street",
            zip: "94122",
            state: "CA",
            first_name: "John",
            last_name: "Doe",
          },
          phone: { number: "8056594427", country_code: "+91" },
          email: null,
        },
        auto_fulfill: true,
        customer_id: "new_cust",
        customer: null,
        client_secret: null,
        return_url: null,
        business_country: null,
        business_label: null,
        description: "Mocked payout",
        entity_type: "Individual",
        recurring: true,
        metadata: { ref: "123" },
        merchant_connector_id: "mca_test",
        status,
        error_message: status === "failed" ? "Card declined" : null,
        error_code: status === "failed" ? "000" : null,
        profile_id: "pro_test",
        created: "2024-10-04T08:00:44.217Z",
        connector_transaction_id: null,
        priority: null,
        attempts: [],
        payout_link: null,
        email: "payout_customer@example.com",
        name: "John Doe",
        phone: "999999999",
        phone_country_code: "+65",
        unified_code: null,
        unified_message: null,
        payout_method_id: null,
      });

      // Stand up the two mocked records + intelligent /payouts/list route so
      // either status returns only its matching row.
      const mockTwoPayoutList = async (page: Page) => {
        const succeeded = buildPayout(succeededId, "success");
        const failed = buildPayout(failedId, "failed");

        await page.route("**/payouts/filter", async (route) => {
          await route.fulfill({
            status: 200,
            contentType: "application/json",
            body: JSON.stringify({
              connector: ["adyen"],
              currency: ["USD"],
              payout_method: ["card"],
              status: ["success", "failed"],
            }),
          });
        });

        await page.route("**/payouts/list", async (route) => {
          const raw = route.request().postData();
          const filter = raw ? JSON.parse(raw) : {};
          const requested = Array.isArray(filter.status)
            ? filter.status
            : filter.status
              ? [filter.status]
              : [];

          let data = [succeeded, failed];
          if (requested.includes("success") && !requested.includes("failed")) {
            data = [succeeded];
          } else if (
            requested.includes("failed") &&
            !requested.includes("success")
          ) {
            data = [failed];
          }
          await route.fulfill({
            status: 200,
            contentType: "application/json",
            body: JSON.stringify({
              size: data.length,
              data,
              total_count: data.length,
            }),
          });
        });
      };

      const applyStatusFilter = async (
        page: Page,
        payoutOperations: PayoutOperations,
        statusValue: string,
      ) => {
        await payoutOperations.addFilters.click();
        await page
          .locator('[data-dropdown-value="Status"]:visible')
          .click();
        await payoutOperations.payoutStatusFieldWrapper.click();
        await page.locator(`[value="${statusValue}"]`).click();
        await payoutOperations.applyButton.click();
        await page.waitForLoadState("networkidle");
      };

      test("should narrow the list to only the matching status when a status filter is applied", async ({
        page,
        context,
      }) => {
        const homePage = new HomePage(page);
        const payoutOperations = new PayoutOperations(page);
        await setupPayout(homePage, context.request);
        await mockTwoPayoutList(page);

        await goToPayouts(page, homePage);

        // Baseline: both mocked payouts present.
        await expect(payoutOperations.payoutCell(1, 2)).toContainText(
          succeededId.slice(0, 20),
        );
        await expect(payoutOperations.payoutCell(2, 2)).toContainText(
          failedId.slice(0, 20),
        );

        // Apply status=success: only the succeeded row remains.
        await applyStatusFilter(page, payoutOperations, "success");

        await expect(payoutOperations.payoutCell(1, 2)).toContainText(
          succeededId.slice(0, 20),
        );
        await expect(payoutOperations.payoutCell(2, 2)).not.toBeVisible();
        await expect(
          page.getByText(failedId.slice(0, 20)),
        ).not.toBeVisible();

        // Dismiss the existing status chip so the next selection starts clean.
        await payoutOperations.crossOutlineIcon.first().click();
        await page.waitForLoadState("networkidle");

        // Apply status=failed: only the failed row remains.
        await applyStatusFilter(page, payoutOperations, "failed");

        await expect(payoutOperations.payoutCell(1, 2)).toContainText(
          failedId.slice(0, 20),
        );
        await expect(payoutOperations.payoutCell(2, 2)).not.toBeVisible();
        await expect(
          page.getByText(succeededId.slice(0, 20)),
        ).not.toBeVisible();
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
    test("should verify all elements in payout details page", async ({
      page,
      context,
    }) => {
      const homePage = new HomePage(page);
      const payoutOperations = new PayoutOperations(page);
      const { payout } = await setupPayout(homePage, context.request);

      await goToPayouts(page, homePage);
      await payoutOperations.payoutCell(1, 1).click();

      await expect(page.getByText("Summary", { exact: true })).toBeVisible();
      await expect(page.getByText("About Payout", { exact: true })).toBeVisible();
      await expect(page.getByText("Payout Attempts", { exact: true })).toBeVisible();

      // Accordion sections rendered after the Summary block (ShowPayout.res:337–398).
      // Payout Method Details renders only when payout_type === "card" + payout_method_data
      // is present; Payout Metadata renders only when metadata is non-empty. createPayoutAPI
      // satisfies both (card payout + metadata={key: "value"}).
      await expect(page.getByText("Customer Details", { exact: true })).toBeVisible();
      await expect(
        page.getByText("More Payout Details", { exact: true }),
      ).toBeVisible();
      await expect(
        page.getByText("Payout Method Details", { exact: true }),
      ).toBeVisible();
      await expect(
        page.getByText("Payout Metadata", { exact: true }),
      ).toBeVisible();

      // Big amount header + status badge (ShowPayout.res:117–128).
      await expect(page.getByText('123.45 EUR').first()).toBeVisible();
      await expect(page.getByText(payout.status.toUpperCase(), { exact: true }).first()).toBeVisible();

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

      // About Payout fields shown by ShowPayout.PayoutInfo
      // (detailsFields=[ProfileId, ProfileName, Connector, ConnectorLabel,
      //  PayoutType, CardNetwork], ShowPayout.res:175–182).
      for (const label of [
        "Profile ID",
        "Profile Name",
        "Payout Connector",
        "Connector Label",
        "Payout Type",
        "Card Network",
      ]) {
        await expect(
          payoutOperations.dataLabel(label).first(),
        ).toBeVisible();
      }

      // Payout Attempts table columns (PayoutsUtils.attemptsColumns +
      // showSerial=true, ShowPayout.res:75–86).
      const expectedAttemptHeaders = [
        "S.No",
        "Attempt ID",
        "Status",
        "Amount",
        "Currency",
        "Connector",
      ];
      const attemptsTable = page
        .locator('table[data-expandable-table="Attempts"]')
        .first();
      for (let i = 0; i < expectedAttemptHeaders.length; i++) {
        await expect(attemptsTable.locator("thead tr th").nth(i)).toHaveText(
          expectedAttemptHeaders[i],
        );
      }
      // First attempt row should render with the data we created.
      await expect(payoutOperations.attemptCell(1, 1)).toBeVisible();

      // Expand each collapsible accordion and assert its inner fields render.
      // The accordion <header> is the only element with the exact section name;
      // clicking it toggles the body open.
      const expandAccordionAndAssertLabels = async (
        title: string,
        labels: string[],
      ) => {
        const header = page.getByText(new RegExp(`^${title}$`));
        await header.waitFor({ state: "attached", timeout: 10000 });
        await header.scrollIntoViewIfNeeded();
        await header.click();
        for (const label of labels) {
          await expect(
            payoutOperations.dataLabel(label).first(),
          ).toBeVisible();
        }
      };

      // CustomerDetails: Customer + Billing + Payout Method sub-sections
      // (ShowPayout.res:190–224, fields via getHeadingForOtherDetails).
      await expandAccordionAndAssertLabels("Customer Details", [
        "Customer ID",
        "First Name",
        "Last Name",
        "Email",
        "Phone",
        "Phone Country Code",
        "Description",
        "Billing Email",
        "Billing Phone",
        "Billing Address",
        "Payout Method Email",
        "Payout Method Address",
      ]);

      // MorePayoutDetails detailsFields (ShowPayout.res:235–246).
      await expandAccordionAndAssertLabels("More Payout Details", [
        "Auto Fulfill",
        "Recurring",
        "Entity Type",
        "Business Country",
        "Business Label",
        "Return URL",
        "Client Secret",
        "Priority",
        "Error Code",
        "Merchant ID",
      ]);

      // Payout Method Details + Payout Metadata are PrettyPrintJson dumps —
      // no data-labels, just assert known keys from the payload appear in the
      // section body once expanded.
      const payoutMethodDetails = page.getByText(/^Payout Method Details$/);
      await payoutMethodDetails.waitFor({ state: "attached", timeout: 10000 });
      await payoutMethodDetails.scrollIntoViewIfNeeded();
      await payoutMethodDetails.click();
      await expect(payoutMethodDetails.locator("xpath=../..")).toContainText(
        "card",
      );

      const payoutMetadata = page.getByText(/^Payout Metadata$/);
      await payoutMetadata.waitFor({ state: "attached", timeout: 10000 });
      await payoutMetadata.scrollIntoViewIfNeeded();
      await payoutMetadata.click();
      await expect(payoutMetadata.locator("xpath=../..")).toContainText("key");
      await expect(payoutMetadata.locator("xpath=../..")).toContainText("value");
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
});
