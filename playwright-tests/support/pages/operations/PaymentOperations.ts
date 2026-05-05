import { Page, Locator } from "@playwright/test";

export class PaymentOperations {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get transactionView(): Locator {
    return this.page.locator(
      '[class="grid lg:grid-cols-6 md:grid-cols-3 sm:grid-cols-2 grid-cols-2 gap-spacing-3xl"]',
    );
  }

  get searchBox(): Locator {
    return this.page.locator('[name="name"]');
  }

  get dateSelector(): Locator {
    return this.page.locator('[data-testid="date-range-selector"]');
  }

  get viewDropdown(): Locator {
    return this.page.locator(
      '[class="flex h-fit rounded-lg hover:bg-opacity-80"]',
    );
  }

  get addFilters(): Locator {
    return this.page.locator('[data-icon="plus"]');
  }

  get generateReports(): Locator {
    return this.page.locator('[data-button-for="generateReports"]');
  }

  get columnButton(): Locator {
    return this.page.locator('[data-button-for="CustomIcon"]');
  }

  get paymentIdCopyButton(): Locator {
    return this.page.locator(
      '[class="fill-current cursor-pointer opacity-70 h-7 py-1"]',
    );
  }
}

export default PaymentOperations;
