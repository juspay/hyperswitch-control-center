import { Page, Locator } from "@playwright/test";

export class PayoutRouting {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get volumeBasedRoutingSetupButton(): Locator {
    return this.page.locator('[data-button-for="setup"]').nth(0);
  }

  get volumeBasedRoutingHeader(): Locator {
    return this.page.locator('[class="flex items-center gap-4 "]');
  }

  get ruleBasedRoutingSetupButton(): Locator {
    return this.page.locator('[data-button-for="setup"]').nth(1);
  }

  get defaultFallbackManageButton(): Locator {
    return this.page.locator('[data-button-for="manage"]').nth(0);
  }

  get noConnectorsMessage(): Locator {
    return this.page.locator('[class="px-3 text-fs-16"]');
  }

  get noConnectorsMessageLarge(): Locator {
    return this.page.locator('[class="px-3 text-2xl mt-32 "]');
  }

  get noProcessorFoundMessage(): Locator {
    return this.page.getByText("No Processor Found");
  }

  get configurationHistoryTab(): Locator {
    return this.page.getByRole("tab", { name: "Configuration History" });
  }

  get activeConfigurationTab(): Locator {
    return this.page.getByRole("tab", { name: "Active configuration" });
  }

  get activeBadge(): Locator {
    return this.page.locator("div").filter({ hasText: /^Active$/ });
  }

  get viewAndManageButton(): Locator {
    return this.page.getByRole("button", { name: "View and Manage" });
  }

  get setupButton(): Locator {
    return this.page.getByRole("button", { name: "Setup" });
  }

  get manageButton(): Locator {
    return this.page.getByRole("button", { name: "Manage", exact: true });
  }

  historyCell(row: number, col: number): Locator {
    return this.page.locator(
      `[data-table-location="History_tr${row}_td${col}"]`,
    );
  }

  dataToast(text: string): Locator {
    return this.page.locator(`[data-toast="${text}"]`);
  }

  dataLabel(label: string): Locator {
    return this.page.locator(`[data-label="${label}"]`);
  }
}

export default PayoutRouting;
