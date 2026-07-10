import type { Page, Locator } from "@playwright/test";

export class InsightsPaymentsPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // ---- Navigation ----
  async visit() {
    await this.page.goto("/dashboard/new-analytics");
  }

  // ---- Page heading / tabs ----
  get pageHeading(): Locator {
    return this.page.getByText("Insights", { exact: true }).first();
  }

  get paymentsTab(): Locator {
    return this.page.getByRole("tab", { name: "Payments" });
  }

  get smartRetriesTab(): Locator {
    return this.page.getByRole("tab", { name: "Smart Retries" });
  }

  get refundsTab(): Locator {
    return this.page.getByRole("tab", { name: "Refunds" });
  }

  // ---- Overview KPI cards (rendered on success) ----
  // Matched on the stable label text (not the value) so the assertions hold
  // whether the cards show 0 (no data) or mocked non-zero amounts.

  get totalPaymentSavingsCard(): Locator {
    return this.page.getByText(
      "Total Payment SavingsSaved 18.5K USD*Amount saved via payment retries",
    );
  }

  get authorizationRateCard(): Locator {
    return this.page.getByText(
      "88.00%Total Authorization RateOverall successful payment intents divided by total payment intents excluding dropoffs",
    );
  }

  get paymentsProcessedCard(): Locator {
    return this.page.getByText(
      "524K USD*Total Payments ProcessedThe total amount of payments processed in the selected time range",
    );
  }

  get authorisedUncapturedCard(): Locator {
    return this.page.getByText(
      "320Authorised Uncaptured Payments CountTotal amount of authorised but uncaptured payments in the selected time range",
    );
  }

  get refundsProcessedCard(): Locator {
    return this.page.getByText(
      "26.4K USD*Total Refunds ProcessedThe total amount of refund payments processed in the selected time range",
    );
  }

  get disputesCard(): Locator {
    return this.page.getByText(
      "6All DisputesTotal number of disputes irrespective of status in the selected time range",
    );
  }

  // ---- Section headings (ModuleHeader h2, rendered regardless of data) ----
  get paymentsLifecycleHeading(): Locator {
    return this.page.getByText("Payments Lifecycle", { exact: true }).first();
  }

  get paymentsProcessedHeading(): Locator {
    return this.page.getByText("Payments Processed", { exact: true }).first();
  }

  // Chart-tile header (the grid-cols-3 control bar above the line chart). The
  // Day-wise/Hour-wise granularity tabs only render when the `granularity`
  // feature flag is on, so match on the always-present metric dropdown ("By
  // Amount") rather than baking the granularity tabs into the locator. The
  // success-rate tiles have no metric dropdown, so they match on the percentage
  // header instead (excluding the overview, which also shows percentages).
  get paymentsProcessedChartHeading(): Locator {
    return this.page
      .locator("div.grid.grid-cols-3")
      .filter({ hasText: "By Amount" });
  }

  get paymentsSuccessRateHeading(): Locator {
    return this.page
      .getByText("Payments Success Rate", { exact: true })
      .first();
  }

  get paymentsSuccessRateChartHeading(): Locator {
    return this.page
      .locator("div.grid.grid-cols-3")
      .filter({ hasText: "%" })
      .filter({ hasNotText: "Total" });
  }

  get successfulPaymentsDistributionHeading(): Locator {
    return this.page
      .getByText("Successful Payments Distribution", { exact: true })
      .first();
  }

  get successfulPaymentsDistributionChartHeading(): Locator {
    return this.page
      .locator("div")
      .filter({
        hasText:
          /^ConnectorPayment MethodPayment Method TypeAuthentication Type$/,
      })
      .first();
  }

  get failedPaymentsDistributionHeading(): Locator {
    return this.page
      .getByText("Failed Payments Distribution", { exact: true })
      .first();
  }

  get failedPaymentsDistributionChartHeading(): Locator {
    return this.page
      .locator("div")
      .filter({
        hasText:
          /^ConnectorPayment MethodPayment Method TypeAuthentication Type$/,
      })
      .nth(2);
  }

  get failureReasonsHeading(): Locator {
    return this.page.getByText("Failure Reasons", { exact: true }).first();
  }

  get failureReasonsChartHeading(): Locator {
    return this.page.getByText(
      "ConnectorPayment MethodPayment Method TypeAuthentication TypePayment Method + Payment Method Type",
    );
  }

  get failureReasonsTable(): Locator {
    return this.page.getByText(
      "Error ReasonCountRatio (%)ConnectorInsufficient funds8044.44%stripeCard",
    );
  }

  // ---- Chart render assertions (populated with mocked data) ----
  // Highcharts renders an <svg class="highcharts-root"> per line/bar chart.
  get charts(): Locator {
    return this.page.locator("svg.highcharts-root");
  }

  // The Payments Lifecycle funnel is a Highcharts sankey series.
  get sankeyChart(): Locator {
    return this.page.locator(".highcharts-sankey-series").first();
  }

  // ---- Refunds tab content ----
  get refundsProcessedHeading(): Locator {
    return this.page.getByText("Refunds Processed", { exact: true }).first();
  }

  get refundsSuccessRateHeading(): Locator {
    return this.page.getByRole("heading", { name: "Refunds Success Rate" });
  }

  // ---- Refunds tab KPI cards ----
  get refundSuccessRateCard(): Locator {
    return this.page.getByText(
      "84.20%Refund Success RateSuccessful refunds divided by total refunds",
    );
  }

  get totalRefundsProcessedKpiCard(): Locator {
    return this.page.getByText(
      "26.4K USD*Total Refunds ProcessedTotal refunds processed amount on all successful refunds",
    );
  }

  get successfulRefundsCard(): Locator {
    return this.page.getByText(
      "0Successful RefundsTotal number of refunds that were successfully processed",
    );
  }

  get failedRefundsCard(): Locator {
    return this.page.getByText(
      "0Failed RefundsTotal number of refunds that were failed during processing",
    );
  }

  get pendingRefundsCard(): Locator {
    return this.page.getByText(
      "0Pending RefundsTotal number of refunds currently in pending state",
    );
  }

  // ---- Refunds tab chart controls / sections / tables ----
  // Granularity-agnostic, mirroring the Payments-tab chart headers above (the
  // Day-wise/Hour-wise tabs are gated behind the `granularity` flag).
  get refundsProcessedChartHeading(): Locator {
    return this.page
      .locator("div.grid.grid-cols-3")
      .filter({ hasText: "By Amount" });
  }

  get refundsSuccessRateChartHeading(): Locator {
    return this.page
      .locator("div.grid.grid-cols-3")
      .filter({ hasText: "%" })
      .filter({ hasNotText: "Total" });
  }

  get successfulRefundsDistributionHeading(): Locator {
    return this.page.getByRole("heading", {
      name: "Successful Refunds Distribution By Connector",
    });
  }

  get failedRefundsDistributionHeading(): Locator {
    return this.page.getByRole("heading", {
      name: "Failed Refunds Distribution By Connector",
    });
  }

  get refundReasonsHeading(): Locator {
    return this.page.getByRole("heading", { name: "Refund Reasons" });
  }

  get refundReasonsTable(): Locator {
    return this.page.getByText(
      "Refund ReasonCountRatioConnectorcustomer_request400.00%stripe",
    );
  }

  get failedRefundErrorReasonsHeading(): Locator {
    return this.page.getByRole("heading", {
      name: "Failed Refund Error Reasons",
    });
  }

  get refundErrorReasonsTable(): Locator {
    return this.page.getByText(
      "Error ReasonCountRatioConnectorprocessor_declined00.00%stripe",
    );
  }

  // Granularity-agnostic (see paymentsProcessedChartHeading) — matched on the
  // always-present "By Amount" metric dropdown on the Smart Retries tab.
  get smartRetryPaymentsProcessedChartHeading(): Locator {
    return this.page
      .locator("div.grid.grid-cols-3")
      .filter({ hasText: "By Amount" });
  }

  get successfulSmartRetryDistributionHeading(): Locator {
    return this.page.getByRole("heading", {
      name: "Successful Distribution of",
    });
  }

  get failedSmartRetryDistributionHeading(): Locator {
    return this.page.getByRole("heading", {
      name: "Failed Distribution of Smart",
    });
  }

  // The Smart Retry distribution charts share the same groupBy tab bar as the
  // Payments distributions (Connector / Payment Method / …). Two appear on the
  // tab — one per distribution chart.
  get smartRetryDistributionChartHeadings(): Locator {
    return this.page.locator("div").filter({
      hasText:
        /^ConnectorPayment MethodPayment Method TypeAuthentication Type$/,
    });
  }

  // First bar of the first bar chart — hovered to surface its tooltip.
  get firstBar(): Locator {
    return this.page
      .locator(
        ".highcharts-series.highcharts-series-0.highcharts-bar-series > rect",
      )
      .first();
  }

  // Make every chart on the current tab draw fully. Charts (esp. the inverted
  // bar distributions) stay at scale-0 until their section is scrolled on-screen
  // and runs its on-view animation, so scroll the whole tab top→bottom→top, then
  // fire one Highcharts reflow to settle final geometry. Tab-agnostic — works
  // for Payments, Smart Retries and Refunds.
  async revealAllCharts(): Promise<void> {
    const vp = this.page.viewportSize();
    await this.page.mouse.move(
      (vp?.width ?? 1200) / 2,
      (vp?.height ?? 800) / 2,
    );
    for (let i = 0; i < 12; i++) {
      await this.page.mouse.wheel(0, 700);
      await this.page.waitForTimeout(200);
    }
    await this.page.evaluate(() => window.dispatchEvent(new Event("resize")));
    await this.page.waitForTimeout(800);
    await this.page.mouse.wheel(0, -9000);
    await this.page.waitForTimeout(300);
  }

  // ---- Tab navigation helpers ----
  async openRefundsTab(): Promise<void> {
    await this.refundsTab.click();
    await this.page.waitForLoadState("networkidle");
    await this.page.waitForTimeout(1000);
    await this.revealAllCharts();
  }

  async openSmartRetriesTab(): Promise<void> {
    await this.smartRetriesTab.click();
    await this.page.waitForLoadState("networkidle");
    await this.page.waitForTimeout(1000);
    await this.revealAllCharts();
  }

  // ---- Sample data banner / toggle (gated by sample_data_analytics flag) ----
  get sampleDataBannerOff(): Locator {
    return this.page.getByText(
      "No data yet? View sample data to explore the analytics.",
    );
  }

  get viewSampleDataText(): Locator {
    return this.page.getByText("View sample data", { exact: true });
  }

  get sampleDataBannerOn(): Locator {
    return this.page.getByText(
      "Currently viewing sample data. Toggle it off to return to your real insights.",
    );
  }

  get hideSampleDataText(): Locator {
    return this.page.getByText("Hide sample data", { exact: true });
  }

  // The banner toggle is a BoolInput switch ([data-bool-value]) inside the
  // orange banner.
  get sampleDataToggle(): Locator {
    return this.page
      .locator(".bg-orange-50")
      .first()
      .locator("[data-bool-value]")
      .first();
  }

  async enableSampleData(): Promise<void> {
    await this.sampleDataToggle.click({ timeout: 10000 });
    await this.page.waitForLoadState("networkidle");
    await this.hideSampleDataText.waitFor({ state: "visible", timeout: 15000 });
    await this.page.waitForTimeout(1500);
  }

  async disableSampleData(): Promise<void> {
    await this.sampleDataToggle.click({ timeout: 10000 });
    await this.page.waitForLoadState("networkidle");
    await this.viewSampleDataText.waitFor({ state: "visible", timeout: 15000 });
    await this.page.waitForTimeout(1500);
  }

  // OMP (org/merchant/profile) view switcher rendered in the page header. Once
  // sample data is enabled the container disables it and swaps the active
  // entity name for the fixed "Hyperswitch_test" placeholder. The name exceeds
  // 15 chars so it renders truncated (EllipsisText -> "Hyperswitch_tes…").
  get ompDisabledView(): Locator {
    return this.page.getByText(/Hyperswitch_te/).first();
  }

  // ---- Dimension filters (gated by the new_analytics_filters flag) ----
  // The InsightsAnalyticsFilters component renders a currency CustomDropDown
  // (HeadlessUI Menu.Button) beside the Smart Retry toggle. Its default label is
  // the "All Currencies" option; selecting a currency swaps the button label.
  get currencyFilter(): Locator {
    return this.page.getByRole("button", { name: /All Currencies/ }).first();
  }

  // A currency option row inside the open dropdown menu (e.g. "USD").
  currencyOption(name: string): Locator {
    return this.page.getByRole("button", { name, exact: true });
  }

  async openCurrencyFilter(): Promise<void> {
    await this.currencyFilter.click({ timeout: 10000 });
    await this.page.waitForTimeout(500);
  }

  // ---- Date range selector ----
  // Rendered by InsightsContainerUtils.initialFixedFilterFields via
  // InputFields.filterDateRangeField -> DateRangeField. The trigger button
  // carries data-testid="date-range-selector" and its label shows the active
  // preset ("Last 7 Days" by default) or the resolved custom range.
  get dateRangeSelector(): Locator {
    return this.page.getByTestId("date-range-selector");
  }

  // The predefined-options column inside the open date picker dropdown.
  get predefinedDateOptions(): Locator {
    return this.page.locator(
      '[data-date-picker-predefined="predefined-options"]',
    );
  }

  // A single preset row (e.g. "Last 7 Days", "Last 30 Days", "This Month").
  predefinedDateOption(label: string): Locator {
    return this.page.locator(`[data-daterange-dropdown-value="${label}"]`);
  }

  get customRangeOption(): Locator {
    return this.page.locator('[data-daterange-dropdown-value="Custom Range"]');
  }

  // A calendar day cell. Its data-testid is the "MMM D, YYYY" label (e.g.
  // "May 5, 2026") generated by Calendar.res.
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

  // ---- Granularity selector (gated by the `granularity` feature flag) ----
  // PaymentsProcessed (and the other line tiles) render a NewAnalyticsHelper.Tabs
  // of granularity options whose set depends on the active date range: under a
  // day -> 30min/15min, under a day-to-week -> Day-wise/Hour-wise, longer ->
  // Day-wise only. With the default "Last 7 Days" preset the selector offers
  // Day-wise and Hour-wise. Each option is a clickable <div> carrying its label
  // text ("Day-wise" / "Hour-wise" / "30min-wise" / "15min-wise"). With the flag
  // on the last option (Hour-wise) is selected by default.
  granularityOption(label: string): Locator {
    return this.page.getByText(label, { exact: true });
  }

  // `.first()` targets the granularity tab bar on the Payments Processed tile
  // (the first line chart on the Payments tab).
  get dayWiseGranularity(): Locator {
    return this.granularityOption("Day-wise").first();
  }

  get hourWiseGranularity(): Locator {
    return this.granularityOption("Hour-wise").first();
  }

  async selectGranularity(label: string): Promise<void> {
    await this.granularityOption(label).first().click({ timeout: 10000 });
    await this.page.waitForLoadState("networkidle");
    await this.page.waitForTimeout(1000);
  }

  // ---- Distribution groupBy dimension tabs (Connector / Payment Method / …) ----
  // Each distribution chart exposes a Tabs bar of clickable dimension <div>s.
  // `.first()` targets the bar on the Successful Payments Distribution chart.
  get connectorDimensionTab(): Locator {
    return this.page.getByText("Connector", { exact: true }).first();
  }

  get paymentMethodDimensionTab(): Locator {
    return this.page.getByText("Payment Method", { exact: true }).first();
  }

  get paymentMethodTypeDimensionTab(): Locator {
    return this.page.getByText("Payment Method Type", { exact: true }).first();
  }

  get authenticationTypeDimensionTab(): Locator {
    return this.page.getByText("Authentication Type", { exact: true }).first();
  }

  // ---- OMP (org/merchant/profile) view switcher ----
  // OMPSwitchHelper.OMPViews is portalled into the page header. Its base
  // component (OMPViewBaseComp) shows the "View data for:" label and the active
  // entity name; clicking it opens a SelectBox dropdown whose option rows each
  // render their entity name plus a static labelDescription ("(Organization)",
  // "(Merchant)", "(Profile)"). The switcher is disabled while sample data is on.
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

  // ---- Empty / error tile state ----
  // Both an empty data set and a failed metric fetch flip a tile's screenState
  // to Custom, which renders NewAnalyticsHelper.NoData with this message.
  get noDataMessage(): Locator {
    return this.page
      .getByText("No entries in the selected time period.")
      .first();
  }

  // ---- Smart Retry toggle (InsightsHelper.SmartRetryToggle, Payments tab) ----
  // A BoolInput switch ([data-bool-value]) sitting beside the "Include Payment
  // Retries data" label, above the chart sections. Defaults to "on" (the
  // smartRetry filter key defaults to true) and is disabled while sample data is
  // on. Scope to the container that holds the label so it is not confused with
  // the sample-data banner toggle elsewhere on the page.
  get smartRetryToggleLabel(): Locator {
    return this.page.getByText("Include Payment Retries data", { exact: true });
  }

  get smartRetryToggle(): Locator {
    return this.page
      .locator("div")
      .filter({ has: this.smartRetryToggleLabel })
      .locator("[data-bool-value]")
      .first();
  }

  async toggleSmartRetry(): Promise<void> {
    await this.smartRetryToggle.click({ timeout: 10000 });
    await this.page.waitForLoadState("networkidle");
    await this.page.waitForTimeout(1000);
  }

  // ---- Feature-flag fallback (rendered when new_analytics is disabled) ----
  get goToHomeButton(): Locator {
    return this.page.getByRole("button", { name: "Go to Home" });
  }
}

export default InsightsPaymentsPage;
