import { Page, Locator } from "@playwright/test";

export class ThreeDSExemptionManager {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get betaBadge(): Locator {
    return this.page
      .locator(
        '[data-testid*="beta"], .badge:has-text("Beta"), span:has-text("BETA")',
      )
      .first();
  }

  get pageHeading(): Locator {
    return this.page.getByText("3DS Exemption Rules").first();
  }

  get createNewButton(): Locator {
    return this.page.getByRole("button", { name: "Create New" }).first();
  }

  get goToHomeFallback(): Locator {
    return this.page.getByText("Go to Home", { exact: true }).first();
  }
}

export default ThreeDSExemptionManager;
