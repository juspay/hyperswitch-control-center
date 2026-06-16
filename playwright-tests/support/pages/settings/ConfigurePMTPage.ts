import type { Page, Locator } from "@playwright/test";

export class ConfigurePMTPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // ---- Navigation ----
  async visit() {
    await this.page.goto("/dashboard/configure-pmts");
  }

  // ---- Page heading / subtitle ----
  get pageHeading(): Locator {
    return this.page
      .getByText("Configure PMTs at Checkout", { exact: true })
      .first();
  }

  get pageSubtitle(): Locator {
    return this.page.getByText(
      "Control the visibility of your payment methods at the checkout",
      { exact: true },
    );
  }

  // ---- Empty state (no configured payment connectors) ----
  get noDataMessage(): Locator {
    return this.page.getByText("No Data Available", { exact: true });
  }

  get addFiltersButton(): Locator {
    return this.page.getByRole("button", { name: "Add Filters" });
  }

  async openFilters(): Promise<void> {
    await this.addFiltersButton.waitFor({ state: "visible", timeout: 10000 });
    await this.addFiltersButton.scrollIntoViewIfNeeded();
    await this.addFiltersButton.click({ force: true });
  }

  // ---- Table (rendered once connectors are configured) ----
  columnHeader(title: string): Locator {
    return this.page.getByText(title, { exact: true }).first();
  }

  cellByText(text: string): Locator {
    return this.page.getByText(text, { exact: true }).first();
  }

  // A freshly seeded connector is eventually consistent on the list endpoint, so
  // the first render can show the empty state. Reload until the row appears.
  async waitForConnectorRow(text: string, reloads = 4): Promise<void> {
    for (let attempt = 0; attempt < reloads; attempt++) {
      if (
        await this.cellByText(text)
          .isVisible()
          .catch(() => false)
      )
        return;
      await this.page.reload();
      await this.page.waitForLoadState("networkidle");
      await this.page.waitForTimeout(1000);
    }
    await this.cellByText(text).waitFor({ state: "visible", timeout: 10000 });
  }

  // ---- Filters ----
  get selectProfileFilter(): Locator {
    return this.page.getByText("Select Profile", { exact: true });
  }

  get selectConnectorFilter(): Locator {
    return this.page.getByText("Select Connector", { exact: true });
  }

  get selectPaymentMethodFilter(): Locator {
    return this.page.getByText("Select Payment Method", { exact: true });
  }

  get selectPaymentMethodTypeFilter(): Locator {
    return this.page.getByText("Select Payment Method Type", { exact: true });
  }

  // ---- Configure PMT modal (per-row "Configure PMTs" dialog) ----
  get configureModalHeading(): Locator {
    return this.page.getByText('DEBIT', { exact: true });
  }

  get configureModalSubHeading(): Locator {
    return this.page.locator('#table').getByText('Configure PMTs');
  }

  get countriesLabel(): Locator {
    return this.page.getByText("Countries", { exact: true });
  }

  get countriesDropdown(): Locator {
    return this.page.getByRole('button', { name: 'Select Value' }).first();
  }

  get currenciesLabel(): Locator {
    return this.page.getByText("Currencies", { exact: true });
  }

  get currenciesDropdown(): Locator {
    return this.page.getByRole('button', { name: 'Select Value' }).nth(1);
  }

  get minimumAmountInputHeading(): Locator {
    return this.page.getByText('Minimum Amount *');
  }

  get minimumAmountInput(): Locator {
    return this.page.getByPlaceholder("Enter Minimum Amount");
  }

  get maximumAmountInputHeading(): Locator {
    return this.page.getByText('Maximum Amount *');
  }

  get maximumAmountInput(): Locator {
    return this.page.getByPlaceholder("Enter Maximum Amount");
  }

  get submitButton(): Locator {
    return this.page.getByRole("button", { name: "Submit" });
  }

  // The Modal renders its dismiss control as a cross icon in the header.
  get modalCloseButton(): Locator {
    return this.page.getByText('DEBITConfigure PMTs').locator('[data-icon="modal-close-icon"]');
  }

  // ---- Feature-flag fallback (rendered when configure_pmts is disabled) ----
  get goToHomeButton(): Locator {
    return this.page.getByRole("button", { name: "Go to Home" });
  }
}
