import type { Page, Locator } from "@playwright/test";

// Page object for the legacy Payments Analytics page (PaymentAnalytics.res,
// rendered at /dashboard/analytics-payments). Mirrors the locator conventions
// used by InsightsPaymentsPage — section headings and KPI cards are matched on
// their stable label text (not their values) so the assertions hold whether the
// cards show 0 / "No Data" (a fresh org) or real numbers.
export class PaymentAnalyticsPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // ---- Navigation ----
  async visit() {
    await this.page.goto("/dashboard/analytics-payments");
  }

  // ---- Page heading ----
  // PageUtils.PageHeading title="Payments Analytics".
  get pageHeading(): Locator {
    return this.page.getByText("Payments Analytics", { exact: true }).first();
  }

  // ---- Section headings (MetricsState / OverallSummary <h2>) ----
  get paymentsOverviewHeading(): Locator {
    return this.page.getByRole("heading", { name: "Payments Overview" });
  }

  get amountMetricsHeading(): Locator {
    return this.page.getByRole("heading", { name: "Amount Metrics" });
  }

  get smartRetriesHeading(): Locator {
    return this.page.getByRole("heading", { name: "Smart Retries" });
  }

  get smartRetriesSubHeading(): Locator {
    return this.page.getByText('Note: Only date range filters are supported currently for Smart Retry metrics');
  }

  get paymentsTrendsHeading(): Locator {
    return this.page.getByRole("heading", { name: "Payments Trends" });
  }

  get paymentsTrendsFilters(): Locator {
    return this.page.getByText('ConnectorPayment MethodPayment Method + Payment Method Type');
  }

  get paymentsTrendsTimeRange(): Locator {
    return this.page.getByRole('button', { name: 'ONE DAY' });
  }

  // ---- Payments Overview KPI cards (general metrics) ----
  // Matched on the stable single-stat label text.
  get overallSuccessRateCard(): Locator {
    return this.page.locator('div').filter({ hasText: /^92\.50%Overall Success Rate$/ }).nth(1);
  }

  get confirmedSuccessRateCard(): Locator {
    return this.page.locator('div').filter({ hasText: /^95\.30%Confirmed Success Rate$/ }).nth(1);
  }

  get overallPaymentsCard(): Locator {
    return this.page.locator('div').filter({ hasText: /^1\.28kOverall Payments$/ }).nth(1);
  }

  get successPaymentsCard(): Locator {
    return this.page.locator('div').filter({ hasText: /^1\.18kSuccess Payments$/ }).nth(1);
  }

  get authorisedUncapturedCard(): Locator {
    return this.page.locator('div').filter({ hasText: /^42Authorised Uncaptured Payments$/ }).nth(1);
  }

  // ---- Amount Metrics KPI cards ----
  get processedAmountCard(): Locator {
    return this.page.locator('div').filter({ hasText: /^Processed AmountUSD52\.34K$/ }).nth(1);
  }

  get avgTicketSizeCard(): Locator {
    return this.page.locator('div').filter({ hasText: /^Avg Ticket SizeUSD87\.5$/ }).nth(1);
  }

  // ---- Smart Retries section cards ----
  get successfulSmartRetriesCard(): Locator {
    return this.page.locator('div').filter({ hasText: /^312Successful Smart Retries$/ }).nth(1);
  }

  get smartRetriesMadeCard(): Locator {
    return this.page.locator('div').filter({ hasText: /^480Smart Retries made$/ }).nth(1);
  }

  get smartRetriesSavingsCard(): Locator {
    return this.page.locator('div').filter({ hasText: /^Smart Retries SavingsUSD18\.45K$/ }).nth(4);
  }

  // ---- Payments Trends section ----
  get paymentsSummary(): Locator {
    return this.page.getByText("Payments Summary", { exact: true });
  }

  // A single-stat value rendered on a KPI card (e.g. "92.50%", "1.28k",
  // "52.34K"). Used to assert the canned mock data is displayed.
  metricValue(value: string): Locator {
    return this.page.getByText(value, { exact: true }).first();
  }

  // A connector row inside the Payments Summary table.
  summaryConnectorRow(name: string): Locator {
    return this.page.getByText(name, { exact: true }).first();
  }

  // A column header in the Payments Trends "Summary Table".
  summaryTableHeading(title: string): Locator {
    return this.page.locator(`[data-table-heading="${title}"]`);
  }

  // A cell in the Payments Trends "Summary Table". The table emits a
  // data-table-location of the form "Summary Table_tr{row}_td{col}" (1-indexed).
  summaryTableCell(row: number, col: number): Locator {
    return this.page.locator(`[data-table-location="Summary Table_tr${row}_td${col}"]`);
  }

  // ---- Payments Trends dimension tabs (DynamicTabs) ----
  // The tab bar (Connector / Payment Method / Payment Method + Payment Method
  // Type). A single tab is matched on its exact label inside the bar.
  trendsTab(name: string): Locator {
    return this.paymentsTrendsFilters.getByText(name, { exact: true });
  }

  // The "+" control that adds a custom dimension tab.
  get addDimensionTabButton(): Locator {
    return this.page.getByRole("button", { name: "+", exact: true });
  }

  // ---- OMP (org/merchant/profile) view switcher ----
  // OMPSwitchHelper.OMPViews portalled into the page header, showing the
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

  // ---- Error state (PageLoaderWrapper Error -> DefaultLandingPage) ----
  get errorTitle(): Locator {
    return this.page.getByText("Oops, we hit a little bump on the road!", { exact: true });
  }

  get refreshButton(): Locator {
    return this.page.getByRole("button", { name: "Refresh" });
  }

  // ---- Dimension filters (DynamicFilter "Add Filters" popup) ----
  get addFiltersButton(): Locator {
    return this.page.getByRole("button", { name: "Add Filters" });
  }

  get filterSearchInput(): Locator {
    return this.page.getByPlaceholder("Search name or ID...");
  }

  // A dimension row inside the open Add Filters popup. Each row carries
  // data-dropdown-value with the title-cased dimension name (e.g. "Connector",
  // "Currency", "Authentication Type", "Status"). The DynamicFilter renders the
  // dimension in two panels (the suggestion list and the full options list), so
  // scope to the first match.
  dimensionOption(label: string): Locator {
    return this.page.locator(`[data-dropdown-value="${label}"]`).first();
  }

  // The button is wrapped by an overlay span that swallows the actionability
  // check, so force the click open.
  async openAddFilters(): Promise<void> {
    await this.addFiltersButton.click({ force: true });
    await this.filterSearchInput.waitFor({ state: "visible", timeout: 10000 });
  }

  async selectDimensionFilter(label: string): Promise<void> {
    await this.openAddFilters();
    await this.dimensionOption(label).click();
    await this.page.waitForLoadState("networkidle");
    await this.page.waitForTimeout(500);
  }

  // A selected dimension-filter chip ("Select <Label>"), rendered once a
  // dimension is picked from the Add Filters popup. Keyed by the snake_case
  // field name (e.g. "connector", "payment_method_type").
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


  get filterSelector(): Locator {
    return this.page.getByRole('button', { name: 'Add Filters' });
  }
  // ---- Date range selector ----
  // Shared with the Insights page — the trigger button carries
  // data-testid="date-range-selector" and its label shows the active range.
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

export default PaymentAnalyticsPage;
