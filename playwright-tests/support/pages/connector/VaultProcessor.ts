import { Page, Locator } from "@playwright/test";

export class VaultProcessor {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get connectorSearchInput(): Locator {
    return this.page.locator('[data-testid="search-processor"]');
  }

  get searchProcessorPlaceholder(): Locator {
    return this.page.getByPlaceholder("Search a processor");
  }

  get requestProcessorButton(): Locator {
    return this.page
      .getByRole("button", { name: "Request a Processor" })
      .first();
  }

  get goToHomeFallback(): Locator {
    return this.page.getByText("Go to Home", { exact: true }).first();
  }

  get connectNowOrConnectButton(): Locator {
    return this.page
      .locator(
        '[data-button-for="connectNow"], button:has-text("Connect Vault"), button:has-text("Connect")',
      )
      .first();
  }

  get connectButton(): Locator {
    return this.page.locator(
      '[data-button-text="Connect"], button:has-text("Connect")',
    );
  }

  get connectAndProceedButton(): Locator {
    return this.page.locator('[data-button-for="connectAndProceed"]');
  }

  get saveOrConnectOrProceedButton(): Locator {
    return this.page
      .locator(
        'button:has-text("Save"), button:has-text("Connect"), button:has-text("Proceed")',
      )
      .first();
  }

  get doneButton(): Locator {
    return this.page.getByRole("button", { name: "Done" });
  }

  get successToast(): Locator {
    return this.page.locator(
      '[data-toast*="success"], [data-toast*="Connected"]',
    );
  }
}

export default VaultProcessor;
