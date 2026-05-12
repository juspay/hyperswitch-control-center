import { Page, Locator } from "@playwright/test";

export class PaymentRouting {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get volumeBasedRoutingSetupButton(): Locator {
    return this.page.locator('[data-button-for="setup"]').nth(0);
  }

  get volumeBasedRoutingHeader(): Locator {
    return this.page.locator('[class="flex items-center gap-spacing-xl"]');
  }

  get ruleBasedRoutingSetupButton(): Locator {
    return this.page.locator('[data-button-for="setup"]').nth(1);
  }

  get defaultFallbackManageButton(): Locator {
    return this.page.locator('[data-button-for="manage"]').nth(0);
  }
}

export default PaymentRouting;
