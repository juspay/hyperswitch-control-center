import { test, expect } from "@playwright/test";
import type { Page } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI, mockV2MerchantList } from "../support/commands";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentAnalyticsPage } from "../support/pages/analytics/PaymentAnalyticsPage";
import { RefundAnalyticsPage } from "../support/pages/analytics/RefundAnalyticsPage";
import { RoutingAnalyticsPage } from "../support/pages/analytics/RoutingAnalyticsPage";
import { InsightsPaymentsPage } from "../support/pages/analytics/InsightsPaymentsPage";
import { mockPaymentAnalytics } from "../support/paymentAnalyticsMocks";
import { mockRefundAnalytics } from "../support/refundAnalyticsMocks";
import { mockRoutingAnalytics } from "../support/routingAnalyticsMocks";
import {
  mockInsightsAnalytics,
  mockInsightsEmptyAnalytics,
  FROZEN_NOW,
} from "../support/insightsMocks";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// Signs up a fresh org, freezes the browser clock to FROZEN_NOW (so the
// analytics default date range — and every day-wise bucket the mocks derive
// from it — lands on the same fixed day 2026-05-15), optionally force-enables
// feature flags, installs the analytics API mocks so charts/tables render
// deterministic data, mocks the v2 merchant list, then logs in. Everything is
// registered BEFORE login so the routes are in place before the page fires
// any request. Mirrors the loginAndVisit setup the functional analytics specs use.
async function signupAndLogin(
  page: Page,
  setupMocks: (page: Page) => Promise<void>,
  featureFlags?: Record<string, boolean>,
): Promise<void> {
  await page.clock.setFixedTime(new Date(FROZEN_NOW));

  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);

  if (featureFlags) {
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        Object.assign(json.features, featureFlags);
      }
      await route.fulfill({ response, json });
    });
  }

  await setupMocks(page);
  await mockV2MerchantList(page);

  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
}

const SCREENSHOT_OPTS = {
  fullPage: true,
  animations: "disabled",
  maxDiffPixelRatio: 0.01,
} as const;

test.describe("Visual Testing - Analytics", () => {
  test.describe("Payments Analytics", () => {
    test("payments analytics with mocked data should match visual snapshot", async ({
      page,
    }) => {
      await signupAndLogin(page, mockPaymentAnalytics);

      const homePage = new HomePage(page);
      const analytics = new PaymentAnalyticsPage(page);

      await homePage.analytics.click();
      await homePage.paymentsAnalytics.click();

      await expect(analytics.pageHeading).toBeVisible({ timeout: 15000 });
      await expect(analytics.paymentsOverviewHeading).toBeVisible({
        timeout: 15000,
      });
      // Wait on the canned mock data so the page is fully populated before capture.
      await expect(analytics.summaryTableCell(1, 1)).toHaveText("Stripe", {
        timeout: 15000,
      });

      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await expect(page).toHaveScreenshot(
        "analytics-payments-populated.png",
        SCREENSHOT_OPTS,
      );

      await page
        .getByRole("img", { name: "Success Rate" })
        .scrollIntoViewIfNeeded();

      await expect(page).toHaveScreenshot(
        "analytics-payments-charts1-.png",
        SCREENSHOT_OPTS,
      );

      await page
        .getByText("'NA' denotes those incomplete")
        .scrollIntoViewIfNeeded();

      await expect(page).toHaveScreenshot(
        "analytics-payments-charts2-.png",
        SCREENSHOT_OPTS,
      );
    });
  });

  test.describe("Refunds Analytics", () => {
    test("refunds analytics with mocked data should match visual snapshot", async ({
      page,
    }) => {
      await signupAndLogin(page, mockRefundAnalytics);

      const homePage = new HomePage(page);
      const analytics = new RefundAnalyticsPage(page);

      await homePage.analytics.click();
      await homePage.refundAnalytics.click();

      await expect(analytics.pageHeading).toBeVisible({ timeout: 15000 });
      await expect(analytics.successRateCard).toBeVisible({ timeout: 15000 });
      await expect(analytics.summaryTableCell(1, 1)).toHaveText("Stripe", {
        timeout: 15000,
      });

      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await expect(page).toHaveScreenshot(
        "analytics-refunds-populated.png",
        SCREENSHOT_OPTS,
      );

      await page
        .getByText("'NA' denotes those incomplete")
        .scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-refunds-chart.png",
        SCREENSHOT_OPTS,
      );
    });
  });

  test.describe("Insights", () => {
    test("insights with no data should match visual snapshot", async ({
      page,
    }) => {
      // Every metric endpoint returns no rows, so each tile flips to its
      // NoData custom UI while the page shell still renders.
      await signupAndLogin(page, mockInsightsEmptyAnalytics, {
        new_analytics: true,
        new_analytics_smart_retries: true,
        new_analytics_refunds: true,
        sample_data_analytics: true,
        new_analytics_filters: false,
        granularity: false,
      });

      const homePage = new HomePage(page);
      const insights = new InsightsPaymentsPage(page);

      await homePage.analytics.click();
      await homePage.insightsAnalytics.click();

      await expect(insights.pageHeading).toBeVisible({ timeout: 15000 });
      await expect(insights.paymentsProcessedHeading).toBeVisible({
        timeout: 15000,
      });
      await expect(insights.noDataMessage).toBeVisible({ timeout: 15000 });

      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await expect(page).toHaveScreenshot(
        "analytics-insights-empty.png",
        SCREENSHOT_OPTS,
      );

      await page.getByRole("tab", { name: "Smart Retries" }).click();
      await expect(page).toHaveScreenshot(
        "analytics-smartretries-empty.png",
        SCREENSHOT_OPTS,
      );

      await page.getByRole("tab", { name: "Refunds" }).click();
      await expect(page).toHaveScreenshot(
        "analytics-refunds-empty.png",
        SCREENSHOT_OPTS,
      );
    });

    test("insights with mocked data should match visual snapshot", async ({
      page,
    }) => {
      // Insights (New Analytics) is gated behind the new_analytics flag family.
      await signupAndLogin(page, mockInsightsAnalytics, {
        new_analytics: true,
        new_analytics_smart_retries: true,
        new_analytics_refunds: true,
        sample_data_analytics: true,
        new_analytics_filters: false,
        granularity: false,
      });

      const homePage = new HomePage(page);
      const insights = new InsightsPaymentsPage(page);

      await homePage.analytics.click();
      await homePage.insightsAnalytics.click();

      await expect(insights.pageHeading).toBeVisible({ timeout: 15000 });
      await expect(insights.authorizationRateCard).toBeVisible({
        timeout: 15000,
      });
      await expect(insights.failureReasonsTable).toBeVisible({
        timeout: 15000,
      });

      // Scroll every section on-screen so each Highcharts SVG draws fully.
      await insights.revealAllCharts();
      await expect(insights.sankeyChart).toBeVisible({ timeout: 20000 });

      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await expect(page).toHaveScreenshot(
        "analytics-insights1-populated.png",
        SCREENSHOT_OPTS,
      );

      await page
        .getByRole("heading", { name: "Payments Processed" })
        .scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-insights2-populated.png",
        SCREENSHOT_OPTS,
      );

      await page
        .getByRole("heading", { name: "Payments Success Rate" })
        .scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-insights3-populated.png",
        SCREENSHOT_OPTS,
      );

      await page
        .getByRole("heading", { name: "Successful Payments" })
        .scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-insights4-populated.png",
        SCREENSHOT_OPTS,
      );

      await page
        .getByRole("heading", { name: "Failed Payments Distribution" })
        .scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-insights5-populated.png",
        SCREENSHOT_OPTS,
      );

      await page
        .getByRole("heading", { name: "Failure Reasons" })
        .scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-insights6-populated.png",
        SCREENSHOT_OPTS,
      );
    });

    test("smart retries with mocked data should match visual snapshot", async ({
      page,
    }) => {
      // Smart Retries tab shares the new_analytics flag family with Payments.
      await signupAndLogin(page, mockInsightsAnalytics, {
        new_analytics: true,
        new_analytics_smart_retries: true,
        new_analytics_refunds: true,
        sample_data_analytics: true,
        new_analytics_filters: false,
        granularity: false,
      });

      const homePage = new HomePage(page);
      const insights = new InsightsPaymentsPage(page);

      await homePage.analytics.click();
      await homePage.insightsAnalytics.click();

      await expect(insights.pageHeading).toBeVisible({ timeout: 15000 });

      // Switch to the Smart Retries tab; the helper waits for network idle and
      // scrolls every section so each Highcharts SVG draws fully.
      await insights.openSmartRetriesTab();

      await expect(insights.charts.first()).toBeVisible({ timeout: 20000 });

      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await expect(page).toHaveScreenshot(
        "analytics-smartretries1-populated.png",
        SCREENSHOT_OPTS,
      );

      await insights.failedSmartRetryDistributionHeading.scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-smartretries2-populated.png",
        SCREENSHOT_OPTS,
      );
    });

    test("refunds tab with mocked data should match visual snapshot", async ({
      page,
    }) => {
      // Refunds tab shares the new_analytics flag family with Payments.
      await signupAndLogin(page, mockInsightsAnalytics, {
        new_analytics: true,
        new_analytics_smart_retries: true,
        new_analytics_refunds: true,
        sample_data_analytics: true,
        new_analytics_filters: false,
        granularity: false,
      });

      const homePage = new HomePage(page);
      const insights = new InsightsPaymentsPage(page);

      await homePage.analytics.click();
      await homePage.insightsAnalytics.click();

      await expect(insights.pageHeading).toBeVisible({ timeout: 15000 });

      // Switch to the Refunds tab; the helper waits for network idle and scrolls
      // every section so each Highcharts SVG draws fully.
      await insights.openRefundsTab();

      await expect(insights.refundSuccessRateCard).toBeVisible({
        timeout: 15000,
      });
      await expect(insights.refundReasonsTable).toBeVisible({ timeout: 15000 });

      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await expect(page).toHaveScreenshot(
        "analytics-refundstab1-populated.png",
        SCREENSHOT_OPTS,
      );

      await insights.refundsSuccessRateHeading.scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-refundstab2-populated.png",
        SCREENSHOT_OPTS,
      );

      await page
        .getByRole("heading", { name: "Failed Refunds Distribution" })
        .scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-refundstab3-populated.png",
        SCREENSHOT_OPTS,
      );

      await page
        .getByRole("heading", { name: "Failed Refund Error Reasons" })
        .scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-refundstab4-populated.png",
        SCREENSHOT_OPTS,
      );
    });
  });

  test.describe("Routing Analytics", () => {
    test("routing analytics with mocked data should match visual snapshot", async ({
      page,
    }) => {
      // Routing Analytics is gated behind the routing_analytics flag and has no
      // dedicated sidebar getter, so navigate by URL exactly like the functional
      // spec's RoutingAnalyticsPage.visit().
      await signupAndLogin(page, mockRoutingAnalytics, {
        routing_analytics: true,
      });

      const analytics = new RoutingAnalyticsPage(page);
      await analytics.visit();

      await expect(analytics.pageHeading).toBeVisible({ timeout: 15000 });
      await expect(analytics.summaryHeading).toBeVisible({ timeout: 15000 });
      await expect(analytics.charts.first()).toBeVisible({ timeout: 15000 });

      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await expect(page).toHaveScreenshot(
        "analytics-routing-populated.png",
        SCREENSHOT_OPTS,
      );

      // Routing Distribution section (two pie charts).
      await analytics.performanceSummary.scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-routing-performanceSummary.png",
        SCREENSHOT_OPTS,
      );

      // Time Series Distribution section (two trend line charts).
      await analytics.volumeOverTime.scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-routing-volumeOverTime.png",
        SCREENSHOT_OPTS,
      );
    });

    test("least cost routing analytics with mocked data should match visual snapshot", async ({
      page,
    }) => {
      // Least Cost Routing is a tab within Routing Analytics, also gated behind
      // the routing_analytics flag.
      await signupAndLogin(page, mockRoutingAnalytics, {
        routing_analytics: true,
      });

      const analytics = new RoutingAnalyticsPage(page);
      await analytics.visit();

      await expect(analytics.pageHeading).toBeVisible({ timeout: 15000 });

      // Switch to the Least Cost Routing tab; the helper waits for network idle.
      await analytics.openLeastCostRoutingTab();

      // KPI cards.
      await expect(analytics.leastCostTotalSavingsCard).toBeVisible({
        timeout: 15000,
      });
      await expect(analytics.leastCostDebitRoutedTransactionsCard).toBeVisible({
        timeout: 15000,
      });
      await expect(analytics.charts.first()).toBeVisible({ timeout: 15000 });

      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await expect(page).toHaveScreenshot(
        "analytics-leastcost-populated.png",
        SCREENSHOT_OPTS,
      );

      // Summary Table section.
      await analytics.leastCostSummaryHeading.scrollIntoViewIfNeeded();
      await expect(page).toHaveScreenshot(
        "analytics-leastcost-summary.png",
        SCREENSHOT_OPTS,
      );
    });
  });
});
