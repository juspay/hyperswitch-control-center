import { Page, Locator } from "@playwright/test";

export class AuthRateBasedConfiguration {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get bucketSizeInput(): Locator {
    return this.page.getByRole("textbox", { name: "Bucket size" });
  }

  get explorationPercentInput(): Locator {
    return this.page.getByRole("textbox", { name: "Exploration percentage" });
  }

  get rolloutPercentInput(): Locator {
    return this.page.getByRole("textbox", { name: "Rollout percentage" });
  }

  get configureRuleButton(): Locator {
    return this.page.locator('[data-button-for="configureRule"]');
  }

  get saveRuleButton(): Locator {
    return this.page.locator('button:has-text("Save Rule")');
  }

  get saveAndActivateRuleButton(): Locator {
    return this.page.locator('button:has-text("Save and Activate Rule")');
  }

  get activateConfigurationButton(): Locator {
    return this.page.getByRole("button", { name: "Activate Configuration" });
  }

  get deactivateConfigurationButton(): Locator {
    return this.page.getByRole("button", { name: "Deactivate Configuration" });
  }

  get duplicateAndEditButton(): Locator {
    return this.page.getByRole("button", { name: "Duplicate and Edit Configuration" });
  }
}

export default AuthRateBasedConfiguration;
