import { Page, Locator } from "@playwright/test";

export class Surcharge {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get addRuleButton(): Locator {
    return this.page
      .locator('[data-button-for="addRule"], button:has-text("Add Rule")')
      .first();
  }

  get ruleNameInput(): Locator {
    return this.page.locator('[name*="rule_name"]');
  }

  get feeTypeSelect(): Locator {
    return this.page.locator('[name*="fee_type"]').first();
  }

  get feeValueInput(): Locator {
    return this.page.locator('[name*="fee_value"], [name*="percentage"]');
  }

  get saveRuleButton(): Locator {
    return this.page.locator('[data-button-for="saveRule"]');
  }

  get pageHeading(): Locator {
    return this.page.getByText("Surcharge").first();
  }

  get createNewOrSaveButton(): Locator {
    return this.page.getByRole("button", { name: /Create New|Save/i }).first();
  }

  get goToHomeFallback(): Locator {
    return this.page.getByText("Go to Home", { exact: true }).first();
  }
}

export default Surcharge;
