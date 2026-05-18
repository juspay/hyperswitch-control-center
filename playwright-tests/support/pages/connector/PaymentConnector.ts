import { Page, Locator } from "@playwright/test";

export class PaymentConnector {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get pageHeading(): Locator {
    return this.page.locator('[class*="flex items-center gap-4"]').first();
  }

  get pageBanner(): Locator {
    return this.page.locator('.flex.flex-col.justify-evenly').first();
  }

  get connectNowButton(): Locator {
    return this.page.getByRole("button", { name: /Connect Now/i });
  }

  get connectorSearchInput(): Locator {
    return this.page.locator('[data-testid="search-processor"]');
  }

  get stripeDummyConnector(): Locator {
    return this.page.locator('[data-testid="stripe_test"]');
  }

  get addConnectButton(): Locator {
    return this.page.getByRole('button', { name: 'Connect' });
  }

  get connectAndProceedButton(): Locator {
    return this.page.getByRole("button", { name: /Connect and Proceed/i });
  }

  get pmtProceedButton(): Locator {
    return this.page.getByRole("button", { name: /Proceed/i });
  }

  get connectorSetupDone(): Locator {
    return this.page.getByRole("button", { name: /Done/i });
  }
}

export default PaymentConnector;
