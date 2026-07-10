import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { RoutingAnalyticsPage } from "../../support/pages/analytics/RoutingAnalyticsPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";
import {
  mockRoutingAnalytics,
  mockRoutingAnalyticsError,
  FROZEN_NOW,
} from "../../support/routingAnalyticsMocks";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// Signs up a fresh org, force-enables the routing_analytics feature flag, freezes
// the clock and intercepts every analytics API the page fires on load so the
// whole page renders with canned mock data (or, when a failing setup is
// supplied, the error state).
async function loginAndVisit(
  page: Page,
  setupMocks: (page: Page) => Promise<void> = mockRoutingAnalytics,
): Promise<RoutingAnalyticsPage> {
  // Freeze the clock so the analytics default date range ends on the same fixed
  // day (2026-05-15) the canned day-wise buckets are derived from.
  await page.clock.setFixedTime(new Date(FROZEN_NOW));

  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);

  // Routing Analytics is gated behind the `routing_analytics` feature flag, so
  // force it on in the config response before the page loads.
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    if (json && json.features) {
      json.features.routing_analytics = true;
    }
    await route.fulfill({ response, json });
  });

  // Override every endpoint the page calls before it navigates to the route.
  await setupMocks(page);

  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

  const analytics = new RoutingAnalyticsPage(page);
  await analytics.visit();
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(1000);
  return analytics;
}

test.describe("Analytics - Routing", () => {
  let analytics: RoutingAnalyticsPage;

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page);
  });

  test("should load the Routing Analytics page", async ({ page }) => {
    await expect(analytics.pageHeading).toBeVisible({ timeout: 15000 });
    await expect(page).toHaveURL(/analytics-routing/);

    await expect(analytics.dateRangeSelector).toBeVisible({ timeout: 15000 });
    await expect(analytics.ompViewSwitcher).toBeVisible({ timeout: 10000 });
    await expect(analytics.overallRoutingTab).toBeVisible({ timeout: 15000 });

    // Routing Metrics KPI cards.
    await expect(analytics.overallAuthorizationRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.firstAttemptAuthorizationRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.totalSuccessfulCard).toBeVisible({ timeout: 15000 });
    await expect(analytics.totalFailureCard).toBeVisible({ timeout: 15000 });

    // Card values served by the mocks.
    await expect(analytics.metricValue("92.50%")).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.metricValue("86.40%")).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.metricValue("1184")).toBeVisible({ timeout: 15000 });
    await expect(
      analytics.metricText("Out of 1280 transactions").first(),
    ).toBeVisible({ timeout: 15000 });

    // Routing Distribution section.
    await expect(analytics.distributionHeading).toBeVisible({ timeout: 15000 });
    await expect(analytics.connectorVolumeDistribution).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.routingLogicDistribution).toBeVisible({
      timeout: 15000,
    });

    // Routing Logic Performance Summary table.
    await expect(analytics.summaryHeading).toBeVisible({ timeout: 15000 });
    await expect(analytics.summaryTableHeading("Routing Logic")).toBeVisible({
      timeout: 15000,
    });
    await expect(
      analytics.summaryTableHeading("Traffic Percentage (%)"),
    ).toBeVisible({ timeout: 15000 });
    await expect(analytics.summaryTableHeading("No. of Payments")).toBeVisible({
      timeout: 15000,
    });
    await expect(
      analytics.summaryTableHeading("Authorization Rate (%)"),
    ).toBeVisible({ timeout: 15000 });
    await expect(
      analytics.summaryTableHeading("Processed Amount ($)"),
    ).toBeVisible({ timeout: 15000 });

    // Routing Trends section.
    await expect(analytics.trendsHeading).toBeVisible({ timeout: 15000 });
    await expect(analytics.successOverTime).toBeVisible({ timeout: 15000 });
    await expect(analytics.volumeOverTime).toBeVisible({ timeout: 15000 });

    // Charts render with the mocked data.
    await expect(analytics.charts.first()).toBeVisible({ timeout: 15000 });
  });
});

test.describe("Analytics - Routing - Date Range Selector", () => {
  let analytics: RoutingAnalyticsPage;

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

    await expect(analytics.overallAuthorizationRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.summaryHeading).toBeVisible({ timeout: 15000 });
  });
});

test.describe("Analytics - Routing - Dimension Filters", () => {
  let analytics: RoutingAnalyticsPage;

  // Every dimension the TopFilterUI "Add Filters" popup offers (currency is
  // stripped by filterCurrencyFromDimensions). `label` is the data-dropdown-value
  // shown in the popup; `key` is the snake_case field name the selected chip
  // ("Select <label>") is keyed by.
  const DIMENSION_FILTERS = [
    { label: "Connector", key: "connector" },
    { label: "Payment Method", key: "payment_method" },
    { label: "Payment Method Type", key: "payment_method_type" },
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
      await expect(analytics.dimensionOption(label)).toBeVisible({
        timeout: 10000,
      });
    }
  });

  test("should add and clear each dimension filter chip", async ({ page }) => {
    for (const { label, key } of DIMENSION_FILTERS) {
      // Open the dropdown and select the dimension.
      await analytics.openAddFilters();
      await analytics.dimensionOption(label).click();

      // A "Select <label>" chip appears for the selected dimension.
      await expect(analytics.selectedFilterChip(key)).toBeVisible({
        timeout: 10000,
      });
      await expect(analytics.selectedFilterChip(key)).toContainText(
        `Select ${label}`,
      );

      // Clear the chip before moving on to the next dimension.
      await analytics.clearFilterChip(key);
      await expect(analytics.selectedFilterChip(key)).toHaveCount(0);
    }
  });
});

test.describe("Analytics - Routing - OMP Switch", () => {
  let analytics: RoutingAnalyticsPage;

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

test.describe("Analytics - Routing - Tabs", () => {
  let analytics: RoutingAnalyticsPage;

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page);
  });

  // The Routing Analytics screen renders an Overall Routing tab and a Least Cost
  // Routing sub-view tab (the latter is hidden only in live mode without debit
  // routing; test orgs default to test mode, so both render).
  test("should render the Overall Routing and Least Cost Routing tabs", async () => {
    await expect(analytics.overallRoutingTab).toBeVisible({ timeout: 15000 });
    await expect(analytics.leastCostRoutingTab).toBeVisible({ timeout: 15000 });
  });

  test("should navigate to the Least Cost Routing sub-view", async ({
    page,
  }) => {
    await analytics.openLeastCostRoutingTab();

    await expect(page).toHaveURL(/analytics-routing\/least-cost-routing/);
    await expect(analytics.pageHeading).toBeVisible({ timeout: 15000 });
  });
});

test.describe("Analytics - Routing - Least Cost Routing", () => {
  let analytics: RoutingAnalyticsPage;

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page);
    await analytics.openLeastCostRoutingTab();
  });

  test("should load the Least Cost Routing tab", async ({ page }) => {
    await expect(page).toHaveURL(/analytics-routing\/least-cost-routing/);

    // Least Cost KPI cards.
    await expect(analytics.leastCostTotalSavingsCard).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.leastCostDebitRoutedTransactionsCard).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.leastCostRegulatedCard).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.leastCostUnregulatedCard).toBeVisible({
      timeout: 15000,
    });

    // Debit Routed Transactions count served by the mocks.
    await expect(analytics.metricValue("920")).toBeVisible({ timeout: 15000 });

    // Distribution section.
    await expect(analytics.leastCostDistributionHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.leastCostVolumeDistribution).toBeVisible({
      timeout: 15000,
    });
    await expect(analytics.leastCostSavingsOverTime).toBeVisible({
      timeout: 15000,
    });

    // Summary Table section.
    await expect(analytics.leastCostSummaryHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(
      analytics.leastCostSummaryColumn("Signature Brand"),
    ).toBeVisible({ timeout: 15000 });
    await expect(analytics.leastCostSummaryColumn("Card Network")).toBeVisible({
      timeout: 15000,
    });
    await expect(
      analytics.leastCostSummaryColumn("Traffic Percentage (%)"),
    ).toBeVisible({ timeout: 15000 });
    await expect(
      analytics.leastCostSummaryColumn("Debit Routed Transaction Count"),
    ).toBeVisible({ timeout: 15000 });
    await expect(
      analytics.leastCostSummaryColumn("Regulated Transaction Percentage (%)"),
    ).toBeVisible({ timeout: 15000 });
    await expect(
      analytics.leastCostSummaryColumn(
        "Unregulated Transaction Percentage (%)",
      ),
    ).toBeVisible({ timeout: 15000 });
    await expect(
      analytics.leastCostSummaryColumn("Debit Routing Savings ($)"),
    ).toBeVisible({ timeout: 15000 });

    // Charts render with the mocked data.
    await expect(analytics.charts.first()).toBeVisible({ timeout: 15000 });
  });

  test("should keep the date range selector and OMP switcher available on the tab", async () => {
    await expect(analytics.dateRangeSelector).toBeVisible({ timeout: 15000 });
    await expect(analytics.ompViewSwitcher).toBeVisible({ timeout: 10000 });
    await expect(analytics.overallRoutingTab).toBeVisible({ timeout: 15000 });
    await expect(analytics.leastCostRoutingTab).toBeVisible({ timeout: 15000 });
  });
});

test.describe("Analytics - Routing - Error State", () => {
  let analytics: RoutingAnalyticsPage;

  test.beforeEach(async ({ page }) => {
    analytics = await loginAndVisit(page, mockRoutingAnalyticsError);
  });

  // When the routing info / metric endpoints fail with HTTP 500, the page's
  // loadInfo catch block flips PageLoaderWrapper to its Error state
  // (DefaultLandingPage), rather than rendering the metric sections.
  test("should render the error state when the analytics APIs fail", async () => {
    await expect(analytics.errorTitle).toBeVisible({ timeout: 15000 });
    await expect(analytics.refreshButton).toBeVisible({ timeout: 10000 });

    await expect(analytics.summaryHeading).not.toBeVisible();
  });
});
