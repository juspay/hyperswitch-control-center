import { Page, Locator } from "@playwright/test";

export class TenantSwitchingPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get merchantOption(): Locator {
    return this.page.locator(
      '[data-testid*="merchant-option"], [role="option"]:has-text("Merchant")',
    );
  }

  get profileOption(): Locator {
    return this.page.locator(
      '[data-testid*="profile-option"], [role="option"]:has-text("Profile")',
    );
  }

  get merchantOptionByTestId(): Locator {
    return this.page.locator('[data-testid*="merchant-option"]');
  }
}

export default TenantSwitchingPage;
