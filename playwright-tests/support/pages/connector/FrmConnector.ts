import { Page, Locator } from "@playwright/test";

export class FrmConnector {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get connectorSearchInput(): Locator {
    return this.page.locator('[data-testid="search-processor"]');
  }

  get connectButton(): Locator {
    return this.page.locator('[data-button-text="Connect"]');
  }

  get saveOrConnectOrProceedButton(): Locator {
    return this.page
      .locator(
        'button:has-text("Save"), button:has-text("Connect"), button:has-text("Proceed")',
      )
      .first();
  }
}

export default FrmConnector;
