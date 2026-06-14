import type { Page, Locator } from "@playwright/test";

// Page object for the Routing Analytics page (RoutingAnalytics.res, rendered at
// /dashboard/analytics-routing and gated behind the `routing_analytics` feature
// flag). Mirrors the locator conventions used by InsightsPaymentsPage /
// PaymentAnalyticsPage — section headings, KPI card labels and chart titles are
// matched on their stable label text (not their values) so the assertions hold
// whether the widgets show 0 / "No Data" (a fresh org) or the canned mock data.
export class RoutingAnalyticsPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // ---- Navigation ----
  async visit() {
    await this.page.goto("/dashboard/analytics-routing");
  }

  // ---- Page heading ----
  // PageUtils.PageHeading title="Routing Analytics".
  get pageHeading(): Locator {
    return this.page.getByText("Routing Analytics", { exact: true }).first();
  }

  // ---- Top-level tabs (Overall Routing / Least Cost Routing) ----
  get overallRoutingTab(): Locator {
    return this.page.getByText("Overall Routing", { exact: true }).first();
  }

  get leastCostRoutingTab(): Locator {
    return this.page.getByText("Least Cost Routing", { exact: true }).first();
  }

  async openLeastCostRoutingTab(): Promise<void> {
    await this.leastCostRoutingTab.click({ timeout: 10000 });
    await this.page.waitForLoadState("networkidle");
    await this.page.waitForTimeout(1000);
  }

  // ---- Least Cost Routing tab — KPI cards (LeastCostRoutingAnalyticsMetrics) ----
  get leastCostTotalSavingsCard(): Locator {
    return this.page.getByText("Total Savings", { exact: true }).first();
  }

  get leastCostDebitRoutedTransactionsCard(): Locator {
    return this.page.getByText("Debit Routed Transactions", { exact: true }).first();
  }

  get leastCostRegulatedCard(): Locator {
    return this.page.getByText("Regulated Transactions Percentage", { exact: true }).first();
  }

  get leastCostUnregulatedCard(): Locator {
    return this.page.getByText("Unregulated Transactions Percentage", { exact: true }).first();
  }

  // ---- Least Cost Routing tab — Distribution section ----
  get leastCostDistributionHeading(): Locator {
    return this.page.getByText("Distribution", { exact: true }).first();
  }

  get leastCostVolumeDistribution(): Locator {
    return this.page.getByText("Volume Distribution", { exact: true }).first();
  }

  get leastCostSavingsOverTime(): Locator {
    return this.page.getByText("Savings over time", { exact: true }).first();
  }

  // ---- Least Cost Routing tab — Summary Table section ----
  get leastCostSummaryHeading(): Locator {
    return this.page.locator('div').filter({ hasText: /^Mastercard$/ }).first();
  }

  // A column header in the Least Cost summary LoadedTable, matched on its exact
  // title text (e.g. "Signature Brand", "Debit Routing Savings ($)").
  leastCostSummaryColumn(title: string): Locator {
    return this.page.getByText(title, { exact: true }).first();
  }

  // ---- Routing Metrics KPI cards (RoutingAnalyticsMetrics) ----
  // Each card is matched on its stable display-name label text.
  get overallAuthorizationRateCard(): Locator {
    return this.page.getByText("Overall Authorization Rate", { exact: true }).first();
  }

  get firstAttemptAuthorizationRateCard(): Locator {
    return this.page.getByText("First Attempt Authorization Rate (FAAR)", { exact: true }).first();
  }

  get totalSuccessfulCard(): Locator {
    return this.page.getByText("Total Successful", { exact: true }).first();
  }

  get totalFailureCard(): Locator {
    return this.page.getByText("Total Failure", { exact: true }).first();
  }

  // A single-stat value / helper text rendered on a KPI card (e.g. "92.50%",
  // "Out of 1280 transactions"). Used to assert the canned mock data is displayed.
  metricValue(value: string): Locator {
    return this.page.getByText(value, { exact: true }).first();
  }

  metricText(value: string): Locator {
    return this.page.getByText(value).first();
  }

  // ---- Routing Distribution section (RoutingAnalyticsDistribution) ----
  get performanceSummary(): Locator {
    return this.page.locator('div').filter({ hasText: /^Rule Based$/ }).first();
  }

  get connectorVolumeDistribution(): Locator {
    return this.page.getByText("Connector Volume Distribution", { exact: true }).first();
  }

  get routingLogicDistribution(): Locator {
    return this.page.getByText("Routing Logic Distribution", { exact: true }).first();
  }

  // ---- Routing Logic Performance Summary table (RoutingAnalyticsSummary) ----
  get summaryHeading(): Locator {
    return this.page.getByText("Routing Logic Performance Summary", { exact: true }).first();
  }

  // A column header in the summary CustomExpandableTable. Each heading cell
  // carries data-table-heading with the exact column title.
  summaryTableHeading(title: string): Locator {
    return this.page.locator(`[data-table-heading="${title}"]`);
  }

  // ---- Routing Trends section (RoutingAnalyticsTrends) ----
  get trendsHeading(): Locator {
    return this.page.getByText("Time Series Distribution", { exact: true }).first();
  }

  get successOverTime(): Locator {
    return this.page.getByText("Success Over Time", { exact: true }).first();
  }

  get volumeOverTime(): Locator {
    return this.page.getByText("Volume Over Time", { exact: true }).first();
  }

  // ---- Chart render assertions (populated with mocked data) ----
  // Highcharts renders an <svg class="highcharts-root"> per pie/line chart.
  get charts(): Locator {
    return this.page.locator("svg.highcharts-root");
  }

  // ---- Error state (PageLoaderWrapper Error -> DefaultLandingPage) ----
  get errorTitle(): Locator {
    return this.page.getByText("Oops, we hit a little bump on the road!", { exact: true });
  }

  get refreshButton(): Locator {
    return this.page.getByRole("button", { name: "Refresh" });
  }

  // ---- Dimension filters (TopFilterUI DynamicFilter "Add Filters" popup) ----
  get addFiltersButton(): Locator {
    return this.page.getByRole("button", { name: "Add Filters" });
  }

  get filterSelector(): Locator {
    return this.page.getByRole("button", { name: "Add Filters" });
  }

  get filterSearchInput(): Locator {
    return this.page.getByPlaceholder("Search name or ID...");
  }

  // A dimension row inside the open Add Filters popup. Each row carries
  // data-dropdown-value with the title-cased dimension name (e.g. "Connector",
  // "Status"). The DynamicFilter renders the dimension in two panels, so scope
  // to the first match.
  dimensionOption(label: string): Locator {
    return this.page.locator(`[data-dropdown-value="${label}"]`).first();
  }

  // The button is wrapped by an overlay span that swallows the actionability
  // check, so force the click open.
  async openAddFilters(): Promise<void> {
    await this.addFiltersButton.click({ force: true });
    await this.filterSearchInput.waitFor({ state: "visible", timeout: 10000 });
  }

  // A selected dimension-filter chip ("Select <Label>"), rendered once a
  // dimension is picked from the Add Filters popup. Keyed by the snake_case
  // field name (e.g. "connector", "routing_approach").
  selectedFilterChip(fieldKey: string): Locator {
    return this.page.locator(`[data-component-field-wrapper="field-${fieldKey}"]`);
  }

  // The remove (cross) control inside a selected filter chip.
  clearFilterChipIcon(fieldKey: string): Locator {
    return this.selectedFilterChip(fieldKey).locator('[data-icon="cross-outline"]');
  }

  // Remove a selected filter chip and wait for it to detach.
  async clearFilterChip(fieldKey: string): Promise<void> {
    await this.clearFilterChipIcon(fieldKey).click();
    await this.selectedFilterChip(fieldKey).waitFor({ state: "detached", timeout: 10000 });
  }

  // ---- OMP (org/merchant/profile) view switcher ----
  // OMPSwitchHelper.OMPViews rendered in the page header, showing the
  // "View data for:" label and the active entity name.
  get ompViewSwitcher(): Locator {
    return this.page.getByText("View data for:");
  }

  // A view option inside the open OMP dropdown, matched on its static
  // labelDescription text (e.g. "(Organization)" / "(Merchant)" / "(Profile)").
  ompViewOption(label: string): Locator {
    return this.page.getByText(`(${label})`, { exact: true });
  }

  async openOmpViewSwitcher(): Promise<void> {
    await this.ompViewSwitcher.click({ timeout: 10000 });
    await this.page.waitForTimeout(500);
  }

  // ---- Date range selector ----
  // Rendered by the page's DynamicFilter initialFixedFilters. The trigger button
  // carries data-testid="date-range-selector" and its label shows the active range.
  get dateRangeSelector(): Locator {
    return this.page.getByTestId("date-range-selector");
  }

  // The predefined-options column inside the open date picker dropdown.
  get predefinedDateOptions(): Locator {
    return this.page.locator('[data-date-picker-predefined="predefined-options"]');
  }

  // A single preset row (e.g. "Last 7 Days", "Last 30 Days", "This Month").
  predefinedDateOption(label: string): Locator {
    return this.page.locator(`[data-daterange-dropdown-value="${label}"]`);
  }

  get customRangeOption(): Locator {
    return this.page.locator('[data-daterange-dropdown-value="Custom Range"]');
  }

  // A calendar day cell. Its data-testid is the "MMM D, YYYY" label.
  calendarDate(label: string): Locator {
    return this.page.locator(`[data-testid="${label}"]`);
  }

  get applyDateRangeButton(): Locator {
    return this.page.locator('[data-button-text="Apply"]');
  }

  async openDateRangeSelector(): Promise<void> {
    // Opening the picker is a state toggle that a concurrent re-render can
    // occasionally swallow, so retry the click until the options appear.
    for (let attempt = 0; attempt < 3; attempt++) {
      await this.dateRangeSelector.click({ timeout: 10000 });
      try {
        await this.predefinedDateOptions.waitFor({ state: "visible", timeout: 4000 });
        return;
      } catch {
        await this.page.waitForTimeout(300);
      }
    }
    await this.predefinedDateOptions.waitFor({ state: "visible", timeout: 8000 });
  }

  async selectPredefinedRange(label: string): Promise<void> {
    await this.openDateRangeSelector();
    await this.predefinedDateOption(label).click();
    await this.page.waitForLoadState("networkidle");
    await this.page.waitForTimeout(1000);
  }
}

export default RoutingAnalyticsPage;
