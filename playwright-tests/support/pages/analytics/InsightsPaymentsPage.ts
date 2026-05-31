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
    return this.page.getByRole('tab', { name: 'Payments' });
  }

  get smartRetriesTab(): Locator {
    return this.page.getByRole('tab', { name: 'Smart Retries' });
  }

  get refundsTab(): Locator {
    return this.page.getByRole('tab', { name: 'Refunds' });
  }

  // ---- Overview KPI cards (rendered on success) ----


  get totalPaymentSavingsCard(): Locator {
    return this.page.getByText('Total Payment SavingsSaved 0 USD*Amount saved via payment retries');
  }

  get authorizationRateCard(): Locator {
    return this.page.getByText('0.00%Total Authorization RateOverall successful payment intents divided by total payment intents excluding dropoffs');
  }

  get paymentsProcessedCard(): Locator {
    return this.page.getByText('0 USD*Total Payments ProcessedThe total amount of payments processed in the selected time range');
  }

  get authorisedUncapturedCard(): Locator {
    return this.page.getByText('0Authorised Uncaptured Payments CountTotal amount of authorised but uncaptured payments in the selected time range');
  }

  get refundsProcessedCard(): Locator {
    return this.page.getByText('0 USD*Total Refunds ProcessedThe total amount of refund payments processed in the selected time range');
  }

  get disputesCard(): Locator {
    return this.page.getByText('0All DisputesTotal number of disputes irrespective of status in the selected time range');
  }

  // ---- Section headings (ModuleHeader h2, rendered regardless of data) ----
  get paymentsLifecycleHeading(): Locator {
    return this.page.getByText("Payments Lifecycle", { exact: true }).first();
  }

  get paymentsProcessedHeading(): Locator {
    return this.page.getByText("Payments Processed", { exact: true }).first();
  }

  get paymentsSuccessRateHeading(): Locator {
    return this.page.getByText("Payments Success Rate", { exact: true }).first();
  }

  get successfulPaymentsDistributionHeading(): Locator {
    return this.page.getByText("Successful Payments Distribution", { exact: true }).first();
  }

  get failedPaymentsDistributionHeading(): Locator {
    return this.page.getByText("Failed Payments Distribution", { exact: true }).first();
  }

  get failureReasonsHeading(): Locator {
    return this.page.getByText("Failure Reasons", { exact: true }).first();
  }

  // ---- Sample data banner / toggle (gated by sample_data_analytics flag) ----
  get sampleDataBannerOff(): Locator {
    return this.page.getByText("No data yet? View sample data to explore the analytics.");
  }

  get viewSampleDataText(): Locator {
    return this.page.getByText("View sample data", { exact: true });
  }

  get sampleDataBannerOn(): Locator {
    return this.page.getByText("Currently viewing sample data. Toggle it off to return to your real insights.");
  }

  get hideSampleDataText(): Locator {
    return this.page.getByText("Hide sample data", { exact: true });
  }

  // The banner toggle is a BoolInput switch ([data-bool-value]) inside the
  // orange banner.
  get sampleDataToggle(): Locator {
    return this.page.locator(".bg-orange-50").first().locator("[data-bool-value]").first();
  }

  async enableSampleData(): Promise<void> {
    await this.sampleDataToggle.click({ timeout: 10000 });
    await this.page.waitForLoadState("networkidle");
    await this.hideSampleDataText.waitFor({ state: "visible", timeout: 15000 });
    await this.page.waitForTimeout(1500);
  }

  // ---- Feature-flag fallback (rendered when new_analytics is disabled) ----
  get goToHomeButton(): Locator {
    return this.page.getByRole("button", { name: "Go to Home" });
  }
}

export default InsightsPaymentsPage;
