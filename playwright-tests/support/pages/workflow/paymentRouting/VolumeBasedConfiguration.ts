import { Page, Locator } from "@playwright/test";

export class VolumeBasedConfiguration {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get connectorDropdown(): Locator {
    return this.page.getByRole("button", { name: "Select Processors" });
  }

  get configurationNameInput(): Locator {
    return this.page.locator('[placeholder="Enter Configuration Name"]');
  }

  get configurationNameTextbox(): Locator {
    return this.page.getByRole("textbox", { name: "Enter Configuration Name" });
  }

  get descriptionInput(): Locator {
    return this.page.locator('[name="description"]');
  }

  get descriptionTextbox(): Locator {
    return this.page.getByRole("textbox", {
      name: "Add a description for your",
    });
  }

  get configureRuleButton(): Locator {
    return this.page.locator('[data-button-for="configureRule"]');
  }

  get saveRuleButton(): Locator {
    return this.page.locator('[data-button-for="saveRule"]');
  }

  get saveAndActivateRuleButton(): Locator {
    return this.page.locator('[data-button-for="saveAndActivateRule"]');
  }

  get saveAndActivateRuleByRoleButton(): Locator {
    return this.page.getByRole("button", { name: "Save and Activate Rule" });
  }

  get duplicateAndEditConfigurationButton(): Locator {
    return this.page.getByRole("button", {
      name: "Duplicate & Edit Configuration",
    });
  }

  get activeIndicator(): Locator {
    return this.page.locator('[data-icon="check"]').first();
  }

  get activeConfigContainer(): Locator {
    return this.page.locator('[class="flex flex-col gap-3"]');
  }

  connectorOption(value: string): Locator {
    return this.page.getByRole('option', { name: `${value}` });
  }

  percentageInput(name: string | number): Locator {
    return this.page.locator(`input[name="${name}"]`);
  }
}

export default VolumeBasedConfiguration;
