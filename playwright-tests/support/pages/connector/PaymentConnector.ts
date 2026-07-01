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
    return this.page.locator(".flex.flex-col.justify-evenly").first();
  }

  get connectNowButton(): Locator {
    return this.page.getByRole("button", { name: /Connect Now/i });
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

  get stripeDummyConnector(): Locator {
    return this.page.locator('[data-testid="stripe_test"]');
  }

  get stripeConnector(): Locator {
    return this.page.locator('[data-testid="stripe"]').first();
  }

  get addConnectButton(): Locator {
    return this.page.getByRole("button", { name: "Connect" });
  }

  get connectAndProceedButton(): Locator {
    return this.page.locator('[data-button-for="connectAndProceed"]');
  }

  get pmtProceedButton(): Locator {
    return this.page.getByRole("button", { name: /Proceed/i });
  }

  get connectorSetupDone(): Locator {
    return this.page.getByRole("button", { name: /Done/i });
  }

  get apiKeyInput(): Locator {
    return this.page.locator("[name=connector_account_details\\.api_key]");
  }

  get connectorLabelInput(): Locator {
    return this.page.locator("[name=connector_label]");
  }

  get connectorLabelTextbox(): Locator {
    return this.page.getByRole("textbox", { name: "Enter Connector label" });
  }

  get connectorCreatedToast(): Locator {
    return this.page.locator('[data-toast="Connector Created Successfully!"]');
  }

  get connectorLabelExistsToast(): Locator {
    return this.page
      .locator('[data-toast*="Connector label already exist!"]')
      .first();
  }

  get detailsUpdatedToast(): Locator {
    return this.page.locator('[data-toast*="Details Updated!"]').first();
  }

  get paymentMethodToggle(): Locator {
    return this.page
      .locator(".flex.items-center.transition.rounded-2\\.5")
      .first();
  }

  get connectorEnableToggle(): Locator {
    return this.page.locator(".transition.rounded-full");
  }

  get submitButton(): Locator {
    return this.page.getByRole("button", { name: "Submit" });
  }
}

export default PaymentConnector;
