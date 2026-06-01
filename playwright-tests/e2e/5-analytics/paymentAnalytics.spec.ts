import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { PaymentAnalyticsPage } from "../../support/pages/analytics/PaymentAnalyticsPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";
import { mockPaymentAnalytics, FROZEN_NOW } from "../../support/paymentAnalyticsMocks";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// Signs up a fresh org, freezes the clock and intercepts every analytics API the
// page fires on load so the whole page renders with canned, non-zero mock data.
async function loginAndVisit(page: Page): Promise<PaymentAnalyticsPage> {
  // Freeze the clock so the analytics default date range ends on the same fixed
  // day (2026-05-15) the canned day-wise buckets are derived from.
  await page.clock.setFixedTime(new Date(FROZEN_NOW));

  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);

  // Override every endpoint the page calls before it navigates to the route.
  await mockPaymentAnalytics(page);

  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

  const analytics = new PaymentAnalyticsPage(page);
  await analytics.visit();
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(1000);
  return analytics;
}

test.describe("Analytics - Payments", () => {
  let analytics: PaymentAnalyticsPage;

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page);
  });

  test("should load the Payments Analytics page", async ({ page }) => {
    await expect(analytics.pageHeading).toBeVisible({ timeout: 15000 });
    await expect(page).toHaveURL(/analytics-payments/);

    await expect(analytics.filterSelector).toBeVisible({ timeout: 15000 });
    await expect(analytics.dateRangeSelector).toBeVisible({ timeout: 15000 });
    await expect(analytics.ompViewSwitcher).toBeVisible({ timeout: 10000 });

    await expect(analytics.paymentsOverviewHeading).toBeVisible({ timeout: 15000 });
    await expect(analytics.overallSuccessRateCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.confirmedSuccessRateCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.overallPaymentsCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.successPaymentsCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.authorisedUncapturedCard).toBeVisible({ timeout: 15000 });

    await expect(analytics.amountMetricsHeading).toBeVisible({ timeout: 15000 });
    await expect(analytics.processedAmountCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.avgTicketSizeCard).toBeVisible({ timeout: 15000 });

    await expect(analytics.smartRetriesHeading).toBeVisible({ timeout: 15000 });
    await expect(analytics.smartRetriesSubHeading).toBeVisible({ timeout: 15000 });
    await expect(analytics.successfulSmartRetriesCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.smartRetriesMadeCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.smartRetriesSavingsCard).toBeVisible({ timeout: 15000 });

    await expect(analytics.paymentsTrendsHeading).toBeVisible({ timeout: 15000 });
    await expect(analytics.paymentsTrendsFilters).toBeVisible({ timeout: 15000 });
    await expect(analytics.paymentsTrendsTimeRange).toBeVisible({ timeout: 15000 });
    await expect(analytics.paymentsSummary).toBeVisible({ timeout: 15000 });

    // Payments Summary table — column headings.
    await expect(analytics.summaryTableHeading("Connector")).toBeVisible({ timeout: 15000 });
    await expect(analytics.summaryTableHeading("Success Rate")).toBeVisible({ timeout: 15000 });
    await expect(analytics.summaryTableHeading("Current Week S.R")).toBeVisible({ timeout: 15000 });
    await expect(analytics.summaryTableHeading("Payment Count")).toBeVisible({ timeout: 15000 });
    await expect(analytics.summaryTableHeading("Payment Success Count")).toBeVisible({ timeout: 15000 });
    await expect(analytics.summaryTableHeading("Top 5 Error Reasons")).toBeVisible({ timeout: 15000 });

    // Payments Summary table — row 1 (Stripe).
    await expect(analytics.summaryTableCell(1, 1)).toHaveText("Stripe");
    await expect(analytics.summaryTableCell(1, 2)).toHaveText("94.20%");
    await expect(analytics.summaryTableCell(1, 3)).toHaveText("94.20%");
    await expect(analytics.summaryTableCell(1, 4)).toHaveText("820");
    await expect(analytics.summaryTableCell(1, 5)).toHaveText("772");
    await expect(analytics.summaryTableCell(1, 6)).toContainText("NA");

    // Payments Summary table — row 2 (Adyen).
    await expect(analytics.summaryTableCell(2, 1)).toHaveText("Adyen");
    await expect(analytics.summaryTableCell(2, 2)).toHaveText("91.20%");
    await expect(analytics.summaryTableCell(2, 3)).toHaveText("91.20%");
    await expect(analytics.summaryTableCell(2, 4)).toHaveText("640");
    await expect(analytics.summaryTableCell(2, 5)).toHaveText("602");
    await expect(analytics.summaryTableCell(2, 6)).toContainText("NA");

    // Payments Summary table — row 3 (Checkout).
    await expect(analytics.summaryTableCell(3, 1)).toHaveText("Checkout");
    await expect(analytics.summaryTableCell(3, 2)).toHaveText("88.20%");
    await expect(analytics.summaryTableCell(3, 3)).toHaveText("88.20%");
    await expect(analytics.summaryTableCell(3, 4)).toHaveText("460");
    await expect(analytics.summaryTableCell(3, 5)).toHaveText("432");
    await expect(analytics.summaryTableCell(3, 6)).toContainText("NA");
  });
});

test.describe("Analytics - Payments - Date Range Selector", () => {
  let analytics: PaymentAnalyticsPage;

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page);
  });

  test("should list the predefined date range presets", async () => {
    await analytics.openDateRangeSelector();

    await expect(analytics.predefinedDateOptions).toContainText("Last 7 Days");
    await expect(analytics.predefinedDateOptions).toContainText("Last 30 Days");
    await expect(analytics.predefinedDateOptions).toContainText("This Month");
  });

  test("should update the date range when a predefined preset is selected", async () => {
    await analytics.selectPredefinedRange("Last 30 Days");

    await expect(analytics.dateRangeSelector).toBeVisible({ timeout: 15000 });
    await expect(analytics.predefinedDateOptions).toBeHidden();

    await expect(analytics.paymentsOverviewHeading).toBeVisible({ timeout: 15000 });
    await expect(analytics.overallSuccessRateCard).toBeVisible({ timeout: 15000 });
  });
});

test.describe("Analytics - Payments - Dimension Filters", () => {
  let analytics: PaymentAnalyticsPage;

  // Every dimension the DynamicFilter "Add Filters" popup offers. `label` is the
  // data-dropdown-value shown in the popup; `key` is the snake_case field name
  // the selected chip ("Select <label>") is keyed by.
  const DIMENSION_FILTERS = [
    { label: "Connector", key: "connector" },
    { label: "Payment Method", key: "payment_method" },
    { label: "Payment Method Type", key: "payment_method_type" },
    { label: "Currency", key: "currency" },
    { label: "Authentication Type", key: "authentication_type" },
    { label: "Status", key: "status" },
    { label: "Client Source", key: "client_source" },
    { label: "Client Version", key: "client_version" },
    { label: "Profile Id", key: "profile_id" },
    { label: "Card Network", key: "card_network" },
    { label: "Merchant Id", key: "merchant_id" },
    { label: "Routing Approach", key: "routing_approach" },
  ];

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page);
  });

  test("should list the dimension filter options in the Add Filters popup", async () => {
    await analytics.openAddFilters();

    for (const { label } of DIMENSION_FILTERS) {
      await expect(analytics.dimensionOption(label)).toBeVisible({ timeout: 10000 });
    }
  });

  test("should add and clear each dimension filter chip", async ({ page }) => {
    for (const { label, key } of DIMENSION_FILTERS) {
      // Open the dropdown and select the dimension.
      await analytics.openAddFilters();
      await analytics.dimensionOption(label).click();

      await expect(page.locator('.h-6 > div > svg').first()).not.toBeVisible();

      // A "Select <label>" chip appears for the selected dimension.
      await expect(analytics.selectedFilterChip(key)).toBeVisible({ timeout: 10000 });
      await expect(analytics.selectedFilterChip(key)).toContainText(`Select ${label}`);

      // Clear the chip before moving on to the next dimension.
      await analytics.clearFilterChip(key);
      await expect(analytics.selectedFilterChip(key)).toHaveCount(0);
    }
  });
});
