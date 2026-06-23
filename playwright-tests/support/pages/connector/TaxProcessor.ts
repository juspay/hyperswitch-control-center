import { Page, Locator } from "@playwright/test";

export class TaxProcessor {
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

  get connectButton(): Locator {
    return this.page.locator(
      '[data-button-text="Connect"], button:has-text("Connect")',
    );
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

  get configureButton(): Locator {
    return this.page
      .locator('[data-button-for="configure"], button:has-text("Configure")')
      .first();
  }

  get saveButton(): Locator {
    return this.page.locator(
      '[data-button-for="save"], button:has-text("Save")',
    );
  }
}

export default TaxProcessor;
