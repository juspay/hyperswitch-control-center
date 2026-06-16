import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { InsightsPaymentsPage } from "../../support/pages/analytics/InsightsPaymentsPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";
import {
  mockInsightsAnalytics,
  mockInsightsEmptyAnalytics,
  mockInsightsErrorAnalytics,
  FROZEN_NOW,
} from "../../support/insightsMocks";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// Signs up a fresh org, force-enables the new_analytics feature flag, logs in
// and opens the New Analytics > Insights (Payments tab) page.
async function loginAndVisit(
  page: Page,
  opts: {
    newAnalyticsFilters?: boolean;
    granularity?: boolean;
    smartRetries?: boolean;
    refunds?: boolean;
    setupMocks?: (page: Page) => Promise<void>;
  } = {},
): Promise<InsightsPaymentsPage> {
  // Freeze the clock so the analytics default date range — and every day-wise
  // bucket the mocks derive from it — ends on the same fixed day (2026-05-15).
  await page.clock.setFixedTime(new Date(FROZEN_NOW));

  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);

  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    if (json && json.features) {
      json.features.new_analytics = true;
      json.features.new_analytics_smart_retries = opts.smartRetries ?? true;
      json.features.new_analytics_refunds = opts.refunds ?? true;
      json.features.sample_data_analytics = true;
      json.features.new_analytics_filters = opts.newAnalyticsFilters ?? false;
      json.features.granularity = opts.granularity ?? false;
    }
    await route.fulfill({ response, json });
  });

  // Return canned analytics data so every Insights section renders non-empty
  // (or the empty/error variant when a test opts into one).
  await (opts.setupMocks ?? mockInsightsAnalytics)(page);

  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

  const insights = new InsightsPaymentsPage(page);
  await insights.visit();
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(1000);
  return insights;
}

test.describe("New Analytics - Insights Payments", () => {
  let insights: InsightsPaymentsPage;

  test.beforeEach(async ({ page }) => {
    insights = await loginAndVisit(page);
  });

  test("should load the Insights page with the Payments tab active", async ({
    page,
  }) => {
    await expect(
      page.getByText(
        "No data yet? View sample data to explore the analytics.View sample data",
      ),
    ).toBeVisible();
    await expect(
      page
        .locator("div")
        .filter({ hasText: /^Last 7 DaysNo ComparisonView data for:/ })
        .nth(2),
    ).toBeVisible();

    await expect(insights.pageHeading).toBeVisible({ timeout: 10000 });
    await expect(insights.paymentsTab).toBeVisible({ timeout: 10000 });
    await expect(insights.smartRetriesTab).toBeVisible({ timeout: 10000 });
    await expect(insights.refundsTab).toBeVisible({ timeout: 10000 });

    await expect(insights.totalPaymentSavingsCard).toBeVisible({
      timeout: 10000,
    });
    await expect(insights.authorizationRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.authorisedUncapturedCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.refundsProcessedCard).toBeVisible({ timeout: 15000 });
    await expect(insights.disputesCard).toBeVisible({ timeout: 15000 });

    await expect(insights.paymentsLifecycleHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedChartHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsSuccessRateHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsSuccessRateChartHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.successfulPaymentsDistributionHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(
      insights.successfulPaymentsDistributionChartHeading,
    ).toBeVisible({ timeout: 15000 });
    await expect(insights.failedPaymentsDistributionHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.failedPaymentsDistributionChartHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.failureReasonsHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.failureReasonsChartHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.failureReasonsTable).toBeVisible({ timeout: 15000 });

    // Scroll every section on-screen so each Highcharts SVG draws fully, then
    // verify the funnel + chart count.
    await insights.revealAllCharts();
    await expect(insights.sankeyChart).toBeVisible({ timeout: 20000 });
    await expect
      .poll(async () => await insights.charts.count(), { timeout: 20000 })
      .toBeGreaterThanOrEqual(4);

    await page
      .locator(
        ".highcharts-series.highcharts-series-0.highcharts-bar-series > rect",
      )
      .first()
      .hover();
  });

  test("should populate the Smart Retries tab with mocked data", async ({
    page,
  }) => {
    await insights.openSmartRetriesTab();

    await expect(insights.smartRetryPaymentsProcessedHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.smartRetryPaymentsProcessedChartHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.successfulSmartRetryDistributionHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(
      insights.smartRetryDistributionChartHeadings.first(),
    ).toBeVisible({ timeout: 15000 });
    await expect(insights.failedSmartRetryDistributionHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(
      insights.smartRetryDistributionChartHeadings.nth(2),
    ).toBeVisible({ timeout: 15000 });

    // Scroll every section on-screen so each Highcharts SVG draws fully, then
    // verify the chart count (processed line + two distribution bar charts).
    await insights.revealAllCharts();
    await expect
      .poll(async () => await insights.charts.count(), { timeout: 20000 })
      .toBeGreaterThanOrEqual(3);

    await page
      .locator(
        ".highcharts-series.highcharts-series-0.highcharts-bar-series > rect",
      )
      .first()
      .hover();
  });

  test("should populate the Refunds tab with mocked data", async () => {
    await insights.openRefundsTab();

    await expect(insights.refundSuccessRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.totalRefundsProcessedKpiCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.successfulRefundsCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.failedRefundsCard).toBeVisible({ timeout: 15000 });
    await expect(insights.pendingRefundsCard).toBeVisible({ timeout: 15000 });

    await expect(insights.refundsProcessedHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.refundsProcessedChartHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.refundsSuccessRateHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.refundsSuccessRateChartHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.successfulRefundsDistributionHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.failedRefundsDistributionHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.refundReasonsHeading).toBeVisible({ timeout: 15000 });
    await expect(insights.refundReasonsTable).toBeVisible({ timeout: 15000 });
    await expect(insights.failedRefundErrorReasonsHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.refundErrorReasonsTable).toBeVisible({
      timeout: 15000,
    });
    await expect
      .poll(async () => await insights.charts.count(), { timeout: 20000 })
      .toBeGreaterThanOrEqual(2);
  });
});

test.describe("New Analytics - Insights Payments - Dimension Filters", () => {
  let insights: InsightsPaymentsPage;

  test.beforeEach(async ({ page }) => {
    insights = await loginAndVisit(page, { newAnalyticsFilters: true });
  });

  test("should apply a currency dimension filter", async ({ page }) => {
    await expect(insights.currencyFilter).toBeVisible({ timeout: 15000 });

    await expect(insights.totalPaymentSavingsCard).toBeVisible({
      timeout: 10000,
    });
    await expect(insights.authorizationRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.authorisedUncapturedCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.refundsProcessedCard).toBeVisible({ timeout: 15000 });
    await expect(insights.disputesCard).toBeVisible({ timeout: 15000 });

    await insights.openCurrencyFilter();

    await expect(insights.currencyOption("USD")).toBeVisible({
      timeout: 10000,
    });
    await insights.currencyOption("USD").click();
    await expect(
      page.getByRole("button", { name: "All Currencies (Converted to USD*" }),
    ).not.toBeVisible();
    await expect(page.getByRole("button", { name: "USD" })).toBeVisible();

    await expect(insights.totalPaymentSavingsCard).not.toBeVisible({
      timeout: 10000,
    });
    await expect(insights.paymentsProcessedCard).not.toBeVisible({
      timeout: 15000,
    });
    await expect(insights.refundsProcessedCard).not.toBeVisible({
      timeout: 15000,
    });
  });
});

test.describe("New Analytics - Insights Payments - Date Range Selector", () => {
  let insights: InsightsPaymentsPage;

  test.beforeEach(async ({ page }) => {
    // These tests are date-sensitive — the default "Last 7 Days" preset and the
    // hardcoded custom range (May 5–12, 2026) only hold while "today" is pinned
    // to FROZEN_NOW (2026-05-15). Freeze the clock explicitly here so the block
    // owns its determinism rather than relying on loginAndVisit's side effect.
    await page.clock.setFixedTime(new Date(FROZEN_NOW));
    insights = await loginAndVisit(page);
  });

  // NA-024 — Default preset. The page initialises startTime/endTime from
  // getDateFilteredObject(~range=7), so the selector shows "Last 7 Days".
  test("should default the date range to the last 7 days preset", async () => {
    await expect(insights.dateRangeSelector).toBeVisible({ timeout: 15000 });
    await expect(insights.dateRangeSelector).toContainText("Last 7 Days");

    // The default range still resolves canned data, so the overview renders.
    await expect(insights.authorizationRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedCard).toBeVisible({
      timeout: 15000,
    });
  });

  // NA-025 — Selecting predefined presets updates the active range.
  test("should update the date range when a predefined preset is selected", async () => {
    const presets = ["Last 2 Days", "Last 30 Days", "This Month"];

    for (const preset of presets) {
      await insights.openDateRangeSelector();
      await expect(insights.predefinedDateOptions).toContainText(preset);

      await insights.predefinedDateOption(preset).click();
      await insights.page.waitForLoadState("networkidle");

      await expect(insights.dateRangeSelector).toContainText(preset);
      await expect(insights.predefinedDateOptions).toBeHidden();
    }

    // Charts keep rendering against the freshly selected range.
    await expect(insights.authorizationRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedCard).toBeVisible({
      timeout: 15000,
    });
  });

  // NA-026 — Custom range. Pick two days in the calendar and apply; the
  // selector reflects the chosen dates and the charts refresh.
  test("should apply a custom date range from the calendar", async () => {
    await insights.openDateRangeSelector();

    await insights.customRangeOption.click();

    // Frozen clock pins "today" to 2026-05-15, so May 5 → May 12 are valid
    // past days within the 180-day limit.
    await insights.calendarDate("May 5, 2026").first().click();
    await insights.calendarDate("May 12, 2026").first().click();

    await insights.applyDateRangeButton.click();
    await insights.page.waitForLoadState("networkidle");

    await expect(insights.dateRangeSelector).not.toContainText("Last 7 Days");
    await expect(insights.dateRangeSelector).toContainText("May 05, 2026");
    await expect(insights.dateRangeSelector).toContainText("May 12, 2026");

    await expect(insights.authorizationRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedCard).toBeVisible({
      timeout: 15000,
    });
  });
});

test.describe("New Analytics - Insights Payments - Granularity Selector", () => {
  let insights: InsightsPaymentsPage;

  test.beforeEach(async ({ page }) => {
    await page.clock.setFixedTime(new Date(FROZEN_NOW));
    insights = await loginAndVisit(page, { granularity: true });
  });

  test("should display the granularity selector with the Day-wise and Hour-wise options", async () => {
    await expect(insights.paymentsProcessedHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedChartHeading).toBeVisible({
      timeout: 15000,
    });

    await expect(insights.dayWiseGranularity).toBeVisible({ timeout: 15000 });
    await expect(insights.hourWiseGranularity).toBeVisible({ timeout: 15000 });
  });

  test("should refresh the payments processed chart when the granularity is changed", async () => {
    await expect(insights.dayWiseGranularity).toBeVisible({ timeout: 15000 });

    await insights.selectGranularity("Day-wise");
    await expect(insights.paymentsProcessedHeading).toBeVisible({
      timeout: 15000,
    });
    await expect
      .poll(async () => await insights.charts.count(), { timeout: 20000 })
      .toBeGreaterThanOrEqual(1);

    await insights.selectGranularity("Hour-wise");
    await expect(insights.paymentsProcessedHeading).toBeVisible({
      timeout: 15000,
    });
    await expect
      .poll(async () => await insights.charts.count(), { timeout: 20000 })
      .toBeGreaterThanOrEqual(1);
  });
});

test.describe("New Analytics - Insights Payments - Sample Data Toggle", () => {
  let insights: InsightsPaymentsPage;

  test.beforeEach(async ({ page }) => {
    // Sample data overrides the active date range with a fixed window
    // (2024-09-04 → 2024-10-03), so pin the clock for a deterministic default
    // range to revert to once the toggle is switched off.
    await page.clock.setFixedTime(new Date(FROZEN_NOW));
    insights = await loginAndVisit(page);
  });

  // The sample_data_analytics flag renders the orange banner with the
  // "View sample data" toggle while sample mode is off.
  test("should display the sample data banner with the view sample data toggle", async () => {
    await expect(insights.sampleDataBannerOff).toBeVisible({ timeout: 15000 });
    await expect(insights.viewSampleDataText).toBeVisible({ timeout: 10000 });
    await expect(insights.sampleDataToggle).toBeVisible({ timeout: 10000 });

    // The real-data overview still renders behind the banner.
    await expect(insights.authorizationRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedCard).toBeVisible({
      timeout: 15000,
    });
  });

  // Enabling sample data flips the banner copy, overrides the date range with
  // the fixed sample window and disables the OMP switcher.
  test("should switch to sample data when the toggle is enabled", async () => {
    await expect(insights.sampleDataBannerOff).toBeVisible({ timeout: 15000 });
    await expect(insights.dateRangeSelector).toContainText("Last 7 Days");

    await insights.enableSampleData();

    await expect(insights.sampleDataBannerOn).toBeVisible({ timeout: 15000 });
    await expect(insights.hideSampleDataText).toBeVisible({ timeout: 10000 });

    // Date range switches to the fixed sample window (2024-09-04 → 2024-10-03).
    await expect(insights.dateRangeSelector).not.toContainText("Last 7 Days");
    await expect(insights.dateRangeSelector).toContainText("Sep 04, 2024");
    await expect(insights.dateRangeSelector).toContainText("Oct 03, 2024");

    // OMP switcher is disabled and shows the fixed sample placeholder.
    await expect(insights.ompDisabledView).toBeVisible({ timeout: 10000 });

    // The Insights sections re-render against the sample window.
    await expect(insights.paymentsLifecycleHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsSuccessRateHeading).toBeVisible({
      timeout: 15000,
    });
  });

  // Toggling sample data back off restores the user-selected range, re-enables
  // the OMP switcher and reverts the banner copy.
  test("should revert to real data when the toggle is disabled", async () => {
    await insights.enableSampleData();
    await expect(insights.sampleDataBannerOn).toBeVisible({ timeout: 15000 });
    await expect(insights.dateRangeSelector).toContainText("Sep 04, 2024");

    await insights.disableSampleData();

    await expect(insights.sampleDataBannerOff).toBeVisible({ timeout: 15000 });
    await expect(insights.viewSampleDataText).toBeVisible({ timeout: 10000 });

    // Date range reverts off the sample window to the default 7-day range
    // resolved against the frozen clock (May 08 → May 15, 2026).
    await expect(insights.dateRangeSelector).not.toContainText("Sep 04, 2024");
    await expect(insights.dateRangeSelector).toContainText("May 15, 2026");

    // OMP switcher is re-enabled (sample placeholder no longer shown).
    await expect(insights.ompDisabledView).not.toBeVisible({ timeout: 10000 });

    await expect(insights.authorizationRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedCard).toBeVisible({
      timeout: 15000,
    });
  });
});

test.describe("New Analytics - Insights Payments - Feature Flag", () => {
  test("should fall back to the unauthorized view when new_analytics is disabled", async ({
    page,
  }) => {
    await page.clock.setFixedTime(new Date(FROZEN_NOW));

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.new_analytics = false;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

    const insights = new InsightsPaymentsPage(page);
    await insights.visit();
    await page.waitForLoadState("networkidle");

    await expect(insights.goToHomeButton).toBeVisible({ timeout: 10000 });
  });
});

test.describe("New Analytics - Insights Payments - OMP Switch", () => {
  let insights: InsightsPaymentsPage;

  test.beforeEach(async ({ page }) => {
    insights = await loginAndVisit(page);
  });

  // The OMPSwitchHelper.OMPViews switcher is rendered (and enabled) while sample
  // data is off. Opening it surfaces the Organization / Merchant / Profile view
  // options for the org-scoped user.
  test("should open the OMP view switcher and list the org, merchant and profile views", async () => {
    await expect(insights.ompViewSwitcher).toBeVisible({ timeout: 15000 });

    await insights.openOmpViewSwitcher();

    await expect(insights.ompViewOption("Organization")).toBeVisible({
      timeout: 10000,
    });
    await expect(insights.ompViewOption("Merchant")).toBeVisible({
      timeout: 10000,
    });
    await expect(insights.ompViewOption("Profile")).toBeVisible({
      timeout: 10000,
    });
  });

  // Selecting the Merchant view keeps the switcher and the analytics overview
  // mounted against the new entity context.
  test("should switch the analytics entity when a view is selected", async () => {
    await insights.openOmpViewSwitcher();
    await expect(insights.ompViewOption("Merchant")).toBeVisible({
      timeout: 10000,
    });

    await insights.ompViewOption("Merchant").click();
    await insights.page.waitForLoadState("networkidle");

    await expect(insights.ompViewSwitcher).toBeVisible({ timeout: 15000 });
    await expect(insights.authorizationRateCard).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsProcessedCard).toBeVisible({
      timeout: 15000,
    });
  });
});

test.describe("New Analytics - Insights Payments - Empty State", () => {
  let insights: InsightsPaymentsPage;

  test.beforeEach(async ({ page }) => {
    await page.clock.setFixedTime(new Date(FROZEN_NOW));
    insights = await loginAndVisit(page, {
      setupMocks: mockInsightsEmptyAnalytics,
    });
  });

  // With every metric endpoint returning no rows, the page shell still renders
  // but each chart tile flips to its NoData custom UI.
  test("should render the NoData custom UI when there is no data in the period", async () => {
    await expect(insights.pageHeading).toBeVisible({ timeout: 15000 });
    await expect(insights.paymentsTab).toBeVisible({ timeout: 10000 });

    await expect(insights.paymentsProcessedHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.paymentsSuccessRateHeading).toBeVisible({
      timeout: 15000,
    });

    await expect(insights.noDataMessage).toBeVisible({ timeout: 15000 });
  });
});

test.describe("New Analytics - Insights Payments - Error State", () => {
  let insights: InsightsPaymentsPage;

  test.beforeEach(async ({ page }) => {
    await page.clock.setFixedTime(new Date(FROZEN_NOW));
    insights = await loginAndVisit(page, {
      setupMocks: mockInsightsErrorAnalytics,
    });
  });

  // When the metric endpoints fail with HTTP 500 the tiles degrade gracefully to
  // their NoData state and the page shell stays usable rather than crashing.
  test("should degrade gracefully when the analytics metric endpoints fail", async () => {
    await expect(insights.pageHeading).toBeVisible({ timeout: 15000 });
    await expect(insights.paymentsTab).toBeVisible({ timeout: 10000 });

    await expect(insights.paymentsProcessedHeading).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.noDataMessage).toBeVisible({ timeout: 15000 });
  });
});

test.describe("New Analytics - Insights Payments - Tab Feature Flags", () => {
  // newAnalyticsSmartRetries OFF — the Payments and Refunds tabs render but the
  // Smart Retries tab is gated out.
  test("should hide the Smart Retries tab when new_analytics_smart_retries is disabled", async ({
    page,
  }) => {
    const insights = await loginAndVisit(page, { smartRetries: false });

    await expect(insights.paymentsTab).toBeVisible({ timeout: 15000 });
    await expect(insights.refundsTab).toBeVisible({ timeout: 15000 });
    await expect(insights.smartRetriesTab).not.toBeVisible({ timeout: 10000 });
  });

  // newAnalyticsRefunds OFF — the Payments and Smart Retries tabs render but the
  // Refunds tab is gated out.
  test("should hide the Refunds tab when new_analytics_refunds is disabled", async ({
    page,
  }) => {
    const insights = await loginAndVisit(page, { refunds: false });

    await expect(insights.paymentsTab).toBeVisible({ timeout: 15000 });
    await expect(insights.smartRetriesTab).toBeVisible({ timeout: 15000 });
    await expect(insights.refundsTab).not.toBeVisible({ timeout: 10000 });
  });
});

test.describe("New Analytics - Insights Payments - Smart Retry Toggle", () => {
  let insights: InsightsPaymentsPage;

  test.beforeEach(async ({ page }) => {
    insights = await loginAndVisit(page);
  });

  // InsightsHelper.SmartRetryToggle renders above the chart sections on the
  // Payments tab, alongside the "Include Payment Retries data" label.
  test("should display the smart retry toggle above the chart sections", async () => {
    await expect(insights.smartRetryToggleLabel).toBeVisible({
      timeout: 15000,
    });
    await expect(insights.smartRetryToggle).toBeVisible({ timeout: 10000 });
    await expect(insights.smartRetryToggle).toHaveAttribute(
      "data-bool-value",
      /on|off/,
    );
  });
});
