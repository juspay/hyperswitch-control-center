import { Page, Locator } from "@playwright/test";

export class ThreeDSAuthenticator {
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

  get authenticatorSearchInput(): Locator {
    return this.page.locator('[data-testid="search-processor"]');
  }

  get requestProcessorButton(): Locator {
    return this.page
      .getByRole("button", { name: "Request a Processor" })
      .first();
  }

  get connectButton(): Locator {
    return this.page.locator('[data-button-text="Connect"]');
  }

  get connectAndProceedButton(): Locator {
    return this.page.locator("[data-button-for=connectAndProceed]");
  }

  get proceedButton(): Locator {
    return this.page.locator("[data-button-for=proceed]");
  }

  get setupDoneButton(): Locator {
    return this.page.locator("[data-button-for=done]");
  }

  get connectorLabelTextbox(): Locator {
    return this.page.getByRole("textbox", { name: "Enter Connector label" });
  }
}

export default ThreeDSAuthenticator;
