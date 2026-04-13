import { Page, Locator } from "@playwright/test";

export class PaymentConnector {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get pageHeading(): Locator {
    return this.page.locator('[class="flex items-center gap-4 "]');
  }

  get pageBanner(): Locator {
    return this.page.locator('[class="flex flex-col gap-2.5"]');
  }

  get connectNowButton(): Locator {
    return this.page.locator('[data-button-for="connectNow"]');
  }

  get connectorSearchInput(): Locator {
    return this.page.locator('[data-testid="search-processor"]');
  }

  get stripeDummyConnector(): Locator {
    return this.page.locator('[data-testid="stripe_test"]');
  }

  get addConnectButton(): Locator {
    return this.page.locator('[data-button-text="Connect"]');
  }

  get connectAndProceedButton(): Locator {
    return this.page.locator("[data-button-for=connectAndProceed]");
  }

  get pmtProceedButton(): Locator {
    return this.page.locator("[data-button-for=proceed]");
  }

  get connectorSetupDone(): Locator {
    return this.page.locator("[data-button-for=done]");
  }
}

export default PaymentConnector;
