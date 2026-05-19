import { Page, Locator } from "@playwright/test";

export class ConfigurePMTPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get creditCardToggle(): Locator {
    return this.page
      .locator('[data-testid*="credit"], input[type="checkbox"][name*="credit"]')
      .first();
  }

  get visaCheckbox(): Locator {
    return this.page
      .locator('[data-testid*="visa"], input[type="checkbox"][name*="visa"]')
      .first();
  }

  get walletToggle(): Locator {
    return this.page
      .locator('[data-testid*="wallet"], input[type="checkbox"][name*="wallet"]')
      .first();
  }

  get gpayCheckbox(): Locator {
    return this.page
      .locator('[data-testid*="gpay"], [data-testid*="google"]')
      .first();
  }

  get saveButton(): Locator {
    return this.page.locator('[data-button-for="save"]').first();
  }

  get minAmountInput(): Locator {
    return this.page.locator('[name*="min_amount"]').first();
  }

  get maxAmountInput(): Locator {
    return this.page.locator('[name*="max_amount"]').first();
  }

  get amountErrorToast(): Locator {
    return this.page.locator(
      '[data-field-error*="amount"], [data-toast*="error"]',
    );
  }

  get countrySelect(): Locator {
    return this.page
      .locator('[name*="allowed_countries"], select[name*="country"]')
      .first();
  }
}

export default ConfigurePMTPage;
