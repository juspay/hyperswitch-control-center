import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { RefundAnalyticsPage } from "../../support/pages/analytics/RefundAnalyticsPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";
import {
  mockRefundAnalytics,
  mockRefundAnalyticsError,
  FROZEN_NOW,
} from "../../support/refundAnalyticsMocks";
import { PaymentOperations } from "../../support/pages/operations/PaymentOperations";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// Signs up a fresh org, freezes the clock and intercepts every analytics API the
// page fires on load so the whole page renders with canned mock data (or, when a
// failing setup is supplied, the error state).
async function loginAndVisit(
  page: Page,
  setupMocks: (page: Page) => Promise<void> = mockRefundAnalytics,
): Promise<RefundAnalyticsPage> {
  // Freeze the clock so the analytics default date range ends on the same fixed
  // day (2026-05-15) the canned day-wise buckets are derived from.
  await page.clock.setFixedTime(new Date(FROZEN_NOW));

  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);

  // Override every endpoint the page calls before it navigates to the route.
  await setupMocks(page);

  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

  const analytics = new RefundAnalyticsPage(page);
  await analytics.visit();
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(1000);
  return analytics;
}

test.describe("Analytics - Refunds", () => {
  let analytics: RefundAnalyticsPage;

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page);
  });

  test("should load the Refunds Analytics page", async ({ page }) => {
    await expect(analytics.pageHeading).toBeVisible({ timeout: 15000 });
    await expect(page).toHaveURL(/analytics-refunds/);

    await expect(analytics.filterSelector).toBeVisible({ timeout: 15000 });
    await expect(analytics.dateRangeSelector).toBeVisible({ timeout: 15000 });
    await expect(analytics.ompViewSwitcher).toBeVisible({ timeout: 10000 });

    // Refunds KPI single-stat cards.
    await expect(analytics.successRateCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.overallRefundsCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.successRefundsCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.processedAmountCard).toBeVisible({ timeout: 15000 });

    // KPI card values (mock-driven).
    await expect(analytics.kpiCardValue("Refunds Success Rate")).toHaveText(
      "92.50%",
    );
    await expect(analytics.kpiCardValue("Overall Refunds")).toHaveText("1.28k");
    await expect(analytics.kpiCardValue("Success Refunds")).toHaveText("1.18k");

    // Refunds chart + summary table.
    await expect(analytics.chartTimeRange).toBeVisible({ timeout: 15000 });
    await expect(analytics.summaryTable).toBeVisible({ timeout: 15000 });

    // Summary table — column headings (default Connector grouping).
    await expect(analytics.summaryTableHeading("Connector")).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.summaryTableHeading("Success Rate")).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.summaryTableHeading("Refund Count")).toBeVisible({
      timeout: 15000,
    });
    await expect(
      analytics.summaryTableHeading("Refund Success Count"),
    ).toBeVisible({ timeout: 15000 });

    // Summary table — row 1 (Stripe).
    await expect(analytics.summaryTableCell(1, 1)).toHaveText("Stripe");
    await expect(analytics.summaryTableCell(1, 2)).toHaveText("94.20%");
    await expect(analytics.summaryTableCell(1, 3)).toHaveText("820");
    await expect(analytics.summaryTableCell(1, 4)).toHaveText("772");

    // Summary table — row 2 (Adyen).
    await expect(analytics.summaryTableCell(2, 1)).toHaveText("Adyen");
    await expect(analytics.summaryTableCell(2, 2)).toHaveText("91.20%");
    await expect(analytics.summaryTableCell(2, 3)).toHaveText("640");
    await expect(analytics.summaryTableCell(2, 4)).toHaveText("602");

    // Summary table — row 3 (Checkout).
    await expect(analytics.summaryTableCell(3, 1)).toHaveText("Checkout");
    await expect(analytics.summaryTableCell(3, 2)).toHaveText("88.20%");
    await expect(analytics.summaryTableCell(3, 3)).toHaveText("460");
    await expect(analytics.summaryTableCell(3, 4)).toHaveText("432");
  });
});

test.describe("Analytics - Refunds - Date Range Selector", () => {
  let analytics: RefundAnalyticsPage;

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page);
  });

  test("should list the predefined date range presets", async () => {
    await analytics.openDateRangeSelector();

    await expect(analytics.predefinedDateOptions).toContainText("Last 7 days");
    await expect(analytics.predefinedDateOptions).toContainText("Last 30 days");
    await expect(analytics.predefinedDateOptions).toContainText("This month");
  });

  test("should update the date range when a predefined preset is selected", async () => {
    await analytics.selectPredefinedRange("Last 30 Days");

    await expect(analytics.dateRangeSelector).toBeVisible({ timeout: 15000 });
    await expect(analytics.predefinedDateOptions).toBeHidden();

    await expect(analytics.successRateCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.summaryTable).toBeVisible({ timeout: 15000 });
  });
});

test.describe("Analytics - Refunds - Dimension Filters", () => {
  let analytics: RefundAnalyticsPage;

  // Every dimension the DynamicFilter "Add Filters" popup offers. `label` is the
  // data-dropdown-value shown in the popup; `key` is the snake_case field name
  // the selected chip ("Select <label>") is keyed by.
  const DIMENSION_FILTERS = [
    { label: "Connector", key: "connector" },
    { label: "Refund Method", key: "refund_method" },
    { label: "Currency", key: "currency" },
    { label: "Refund Status", key: "refund_status" },
  ];

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page);
  });

  test("should list the dimension filter options in the Add Filters popup", async () => {
    await analytics.openAddFilters();

    for (const { label } of DIMENSION_FILTERS) {
      await expect(analytics.dimensionOption(label)).toBeVisible({
        timeout: 10000,
      });
    }
  });

  test("should add and clear each dimension filter chip", async ({ page }) => {
    const paymentOperations = new PaymentOperations(page);
    for (const { label, key } of DIMENSION_FILTERS) {
      await page.getByRole("button", { name: "Add Filters" }).click();
      await expect(page.getByLabel("Add Filters").getByText(`${label}`, { exact: true })).toBeVisible();
      await page.getByLabel("Add Filters").getByText(`${label}`, { exact: true }).click({ force: true });
      await expect(paymentOperations.filterChipArea(label).first()).toContainText(`Select ${label}`);
      await expect(page.getByLabel("Add Filters").getByText("Refund Status")).not.toBeVisible();
    }
  });
});

test.describe("Analytics - Refunds - OMP Switch", () => {
  let analytics: RefundAnalyticsPage;

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page);
  });

  test("should open the OMP view switcher and list the org, merchant and profile views", async () => {
    await expect(analytics.ompViewSwitcher).toBeVisible({ timeout: 15000 });

    await analytics.openOmpViewSwitcher();

    await expect(analytics.ompViewOption("Organization")).toBeVisible({
      timeout: 10000,
    });
    await expect(analytics.ompViewOption("Merchant")).toBeVisible({
      timeout: 10000,
    });
    await expect(analytics.ompViewOption("Profile")).toBeVisible({
      timeout: 10000,
    });
  });

  test("should switch the analytics entity when a view is selected", async ({
    page,
  }) => {
    await analytics.openOmpViewSwitcher();
    await expect(analytics.ompViewOption("Profile")).toBeVisible({
      timeout: 10000,
    });

    await analytics.ompViewOption("Profile").click();
    await analytics.page.waitForLoadState("networkidle");

    await expect(page.getByText("View data for:default")).toBeVisible();
  });
});

test.describe("Analytics - Refunds - Multi-Tab Navigation", () => {
  let analytics: RefundAnalyticsPage;

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page);
  });

  // The DynamicTabs render the first three dimensions (the non-removable
  // defaults) plus a "+" control to add custom dimensions.
  test("should render the default dimension tabs and the add-dimension control", async () => {
    await expect(analytics.trendsTab("Connector")).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.trendsTab("Refund Method")).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.trendsTab("Currency")).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.addDimensionTabButton).toBeVisible({
      timeout: 15000,
    });
  });

  // Switching the active tab re-groups the summary table — its first column
  // header reflects the selected dimension.
  test("should update the summary table grouping when a different tab is selected", async () => {
    // Default grouping is Connector.
    await expect(analytics.summaryTableHeading("Connector")).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.summaryTableCell(1, 1)).toHaveText("Stripe");

    // Switch to the Refund Method tab.
    await analytics.trendsTab("Refund Method").click();
    await analytics.page.waitForLoadState("networkidle");

    await expect(analytics.summaryTableHeading("Refund Method")).toBeVisible({
      timeout: 15000,
    });

    // Switch back to Connector and the connector grouping returns.
    await analytics.trendsTab("Connector").click();
    await analytics.page.waitForLoadState("networkidle");

    await expect(analytics.summaryTableHeading("Connector")).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.summaryTableCell(1, 1)).toHaveText("Stripe");
  });
});

test.describe("Analytics - Refunds - Error State", () => {
  let analytics: RefundAnalyticsPage;

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page, mockRefundAnalyticsError);
  });

  // When the analytics endpoints fail with HTTP 500 the page's getRefundDetails
  // catch block flips PageLoaderWrapper to its Error state (DefaultLandingPage),
  // rather than rendering the metric sections.
  test("should render the error state when the analytics APIs fail", async () => {
    await expect(analytics.errorTitle).toBeVisible({ timeout: 15000 });
    await expect(analytics.refreshButton).toBeVisible({ timeout: 10000 });

    await expect(analytics.successRateCard).not.toBeVisible();
  });
});
