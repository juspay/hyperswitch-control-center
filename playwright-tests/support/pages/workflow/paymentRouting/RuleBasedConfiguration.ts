import { Page, Locator } from "@playwright/test";

export class RuleBasedConfiguration {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get configurationNameInput(): Locator {
    return this.page.locator('[placeholder*="Configuration Name"]');
  }

  get selectFieldButton(): Locator {
    return this.page.getByRole("button", { name: "Select Field" });
  }

  get selectOperatorButton(): Locator {
    return this.page.getByRole("button", { name: "Select Operator" });
  }

  get selectValueButton(): Locator {
    return this.page.getByRole("button", { name: "Select Value" });
  }

  get addProcessorsButton(): Locator {
    return this.page.getByRole("button", { name: "Add Processors" });
  }

  get configureRuleButton(): Locator {
    return this.page.getByRole("button", { name: "Configure Rule" });
  }

  get saveAndActivateRuleButton(): Locator {
    return this.page.getByRole("button", { name: "Save and Activate Rule" });
  }

  get duplicateAndEditButton(): Locator {
    return this.page.getByRole("button", { name: "Duplicate and Edit" });
  }

  get distributeText(): Locator {
    return this.page.getByText("Distribute");
  }

  get distributeCheckboxNotSelected(): Locator {
    return this.page
      .locator('#app').getByRole('checkbox');
  }

  get distributeCheckboxSelected(): Locator {
    return this.page.getByRole('checkbox');
  }

  get addConditionButton(): Locator {
    return this.page.locator('[data-icon="plus"]').nth(1);
  }

  get logicalOperatorToggle(): Locator {
    return this.page.locator("button").filter({ hasText: /^AND$|^OR$/ });
  }

  get logicalOperatorSwitch(): Locator {
    return this.page
      .locator(".flex.items-center.cursor-pointer.rounded-full")
      .first();
  }

  get firstAddConditionRowButton(): Locator {
    return this.page
      .locator(".flex.items-center.justify-center.p-2.bg-gray-100")
      .first();
  }

  get rule2Button(): Locator {
    return this.page.getByRole("button", {
      name: "Rule 2 Select Field Select",
    });
  }

  get removeFirstConnectorButton(): Locator {
    return this.page.locator(".w-min > .flex.flex-col").first();
  }

  percentageInput(name: string | number): Locator {
    return this.page.locator(`input[name="${name}"]`);
  }
}

export default RuleBasedConfiguration;
