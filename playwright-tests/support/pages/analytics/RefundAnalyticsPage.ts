import type { Page, Locator } from "@playwright/test";

// Page object for the Refunds Analytics page (RefundsAnalytics.res, rendered at
// /dashboard/analytics-refunds). The page is built on the shared Analytics.res
// component, so the dimension-filter popup, dimension tabs, summary table, OMP
// switcher and date-range selector all share the same DOM conventions as the
// Payments Analytics page — KPI cards are matched on their stable title text
// (HSwitchSingleStatWidget renders the title in its own node) and the summary
// table is keyed by its data-table-heading / data-table-location attributes.
export class RefundAnalyticsPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // ---- Navigation ----
  async visit() {
    await this.page.goto("/dashboard/analytics-refunds");
  }

  // ---- Page heading ----
  // PageUtils.PageHeading title="Refunds Analytics".
  get pageHeading(): Locator {
    return this.page.getByText("Refunds Analytics", { exact: true }).first();
  }

  // ---- KPI single-stat cards (DynamicSingleStat) ----
  // Each card renders its title in a dedicated node, so a card is matched on
  // its stable title text. getStatData builds the four refund cards.
  kpiCard(title: string): Locator {
    return this.page.getByText(title, { exact: true });
  }

  get successRateCard(): Locator {
    return this.kpiCard("Refunds Success Rate");
  }

  get overallRefundsCard(): Locator {
    return this.kpiCard("Overall Refunds");
  }

  get successRefundsCard(): Locator {
    return this.kpiCard("Success Refunds");
  }

  get processedAmountCard(): Locator {
    return this.kpiCard("Processed Amount");
  }

  // The big value rendered inside the card whose title is `title`
  // (HSwitchSingleStatWidget renders it lowercased in a `.text-3xl` node).
  kpiCardValue(title: string): Locator {
    return this.page
      .locator("div.singlestatBox")
      .filter({ hasText: title })
      .locator("div.text-3xl");
  }

  // ---- Summary table (BaseTableComponent -> LoadedTable title="Summary Table") ----
  // The shared component hard-codes the "Payments Summary" label above the
  // table for every analytics module.
  get summaryTable(): Locator {
    return this.page.getByText("Payments Summary", { exact: true });
  }

  // A column header in the summary table.
  summaryTableHeading(title: string): Locator {
    return this.page.locator(`[data-table-heading="${title}"]`);
  }

  // A cell in the summary table. The table emits a data-table-location of the
  // form "Summary Table_tr{row}_td{col}" (1-indexed).
  summaryTableCell(row: number, col: number): Locator {
    return this.page.locator(
      `[data-table-location="Summary Table_tr${row}_td${col}"]`,
    );
  }

  // ---- Refund trends chart (DynamicChart) ----
  // The chart renders an "ONE DAY" granularity button, used as a stable
  // chart-present indicator.
  get chartTimeRange(): Locator {
    return this.page.getByRole("button", { name: "ONE DAY" });
  }

  // ---- Dimension tabs (DynamicTabs) ----
  // The tab bar renders the first three (non-removable) dimensions concatenated
  // (Connector / Refund Method / Currency), plus a "+" control to add more.
  get trendsFilters(): Locator {
    return this.page.getByText("ConnectorRefund MethodCurrency");
  }

  // A single dimension tab, matched on its exact label inside the bar. The bar
  // also holds a hidden <span value="..."> per dimension (the add-dimension
  // dropdown), so scope to the first match — the visible tab node.
  trendsTab(name: string): Locator {
    return this.trendsFilters.getByText(name, { exact: true }).first();
  }

  // The "+" control that adds a custom dimension tab.
  get addDimensionTabButton(): Locator {
    return this.page.getByRole("button", { name: "+", exact: true });
  }

  // ---- OMP (org/merchant/profile) view switcher ----
  // OMPSwitchHelper.OMPViews — rendered for the Refunds/Disputes modules,
  // showing the "View data for:" label and the active entity name.
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
    return this.page.getByText("Oops, we hit a little bump on the road!", {
      exact: true,
    });
  }

  get refreshButton(): Locator {
    return this.page.getByRole("button", { name: "Refresh" });
  }

  // ---- Dimension filters (DynamicFilter "Add Filters" popup) ----
  get addFiltersButton(): Locator {
    return this.page.getByRole("button", { name: "Add Filters" });
  }

  get filterSelector(): Locator {
    return this.page.getByRole("button", { name: "Add Filters" });
  }

  // A dimension row inside the open Add Filters popup. Each row carries
  // data-dropdown-value with the title-cased dimension name (e.g. "Connector",
  // "Currency", "Refund Status"). The DynamicFilter renders the dimension in two
  // panels (the suggestion list and the full options list), so scope to the
  // first match.
  dimensionOption(label: string): Locator {
    return this.page.locator(`[data-id="${label}"]`).first();
  }

  // The button is wrapped by an overlay span that swallows the actionability
  // check, so force the click open. The refunds popup lists only a handful of
  // dimensions, so it has no search input — wait for the first dimension row.
  async openAddFilters(): Promise<void> {
    await this.addFiltersButton.click({ force: true });
    await this.dimensionOption("Connector").waitFor({
      state: "visible",
      timeout: 10000,
    });
  }

  // A selected dimension-filter chip ("Select <Label>"), rendered once a
  // dimension is picked from the Add Filters popup. Keyed by the snake_case
  // field name (e.g. "connector", "refund_status").
  selectedFilterChip(fieldKey: string): Locator {
    return this.page.locator(
      `[data-component-field-wrapper="field-${fieldKey}"]`,
    );
  }

  // The remove (cross) control inside a selected filter chip.
  clearFilterChipIcon(fieldKey: string): Locator {
    return this.selectedFilterChip(fieldKey).locator(
      '[data-icon="cross-outline"]',
    );
  }

  // Remove a selected filter chip and wait for it to detach.
  async clearFilterChip(fieldKey: string): Promise<void> {
    await this.clearFilterChipIcon(fieldKey).click();
    await this.selectedFilterChip(fieldKey).waitFor({
      state: "detached",
      timeout: 10000,
    });
  }

  // ---- Date range selector ----
  // Shared with the Insights/Payments pages — the trigger button carries
  // data-testid="date-range-selector" and its label shows the active range.
  get dateRangeSelector(): Locator {
    return this.page.locator('[data-element="preset-selector"]');
  }

  // The predefined-options column inside the open date picker dropdown.
  get predefinedDateOptions(): Locator {
    return this.page.getByText('Last 30 minutesLast 1');
  }

  // A single preset row (e.g. "Last 7 Days", "Last 30 Days", "This Month").
  predefinedDateOption(label: string): Locator {
    return this.page.getByRole('menuitem', { name: `${label}` });
  }

  async openDateRangeSelector(): Promise<void> {
    // Opening the picker is a state toggle that a concurrent re-render can
    // occasionally swallow, so retry the click until the options appear.
    for (let attempt = 0; attempt < 3; attempt++) {
      await this.dateRangeSelector.click({ timeout: 10000 });
      try {
        await this.predefinedDateOptions.waitFor({
          state: "visible",
          timeout: 4000,
        });
        return;
      } catch {
        await this.page.waitForTimeout(300);
      }
    }
    await this.predefinedDateOptions.waitFor({
      state: "visible",
      timeout: 8000,
    });
  }

  async selectPredefinedRange(label: string): Promise<void> {
    await this.openDateRangeSelector();
    await this.predefinedDateOption(label).click();
    await this.page.waitForLoadState("networkidle");
    await this.page.waitForTimeout(1000);
  }
}

export default RefundAnalyticsPage;
