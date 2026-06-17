import { Page, Locator } from "@playwright/test";

export class ThreeDSExemptionManager {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // Page-level
  get pageHeading(): Locator {
    return this.page.getByText("3DS Exemption Rules").first();
  }

  get pageSubtitle(): Locator {
    return this.page
      .getByText(/Optimize 3DS strategy by correctly applying 3DS exemptions/)
      .first();
  }

  // LANDING view — Configure section
  get configureSectionHeading(): Locator {
    return this.page.getByText("Configure 3DS Exemption Rules", { exact: true });
  }

  get createNewButton(): Locator {
    return this.page.getByRole("button", { name: "Create New" });
  }

  // LANDING view — active rule preview
  get activeBadge(): Locator {
    return this.page.getByText("ACTIVE", { exact: true });
  }

  get deleteIcon(): Locator {
    return this.page.locator('[data-icon="delete"]').first();
  }

  // Override / delete confirmation popups
  get overrideWarningHeading(): Locator {
    return this.page.getByText("Heads up!", { exact: true });
  }

  get overrideWarningDescription(): Locator {
    return this.page.getByText(/This will override the existing 3DS configuration/);
  }

  get deleteConfirmHeading(): Locator {
    return this.page.getByText("Confirm delete?", { exact: true });
  }

  get deleteConfirmDescription(): Locator {
    return this.page.getByText(
      /Are you sure you want to delete currently active 3DS exemption rule/,
    );
  }

  get confirmButton(): Locator {
    return this.page.getByRole("button", { name: "Confirm" });
  }

  get cancelPopupButton(): Locator {
    return this.page.getByRole("button", { name: "Cancel" });
  }

  // NEW form view
  get ruleNameInput(): Locator {
    return this.page.locator('input[name="name"]').first();
  }

  // The submit button label is rendered with a trailing space ("Save ") —
  // the regex tolerates both forms.
  get saveButton(): Locator {
    return this.page.getByRole("button", { name: /^Save\s*$/i });
  }

  get cancelFormButton(): Locator {
    return this.page.getByRole("button", { name: "Cancel", exact: true });
  }

  get ruleHeading(): Locator {
    return this.page.getByText(/^Rule 1$/);
  }

  ruleHeadingByIndex(index: number): Locator {
    return this.page.getByText(new RegExp(`^Rule ${index}$`));
  }

  // Rule action icons live inside `.bg-gray-100.rounded-xl` wrappers.
  // Filtering by the icon name disambiguates them from the condition-row
  // plus button (which uses `.rounded-full`).
  get addRuleButton(): Locator {
    return this.page
      .locator(".bg-gray-100.rounded-xl")
      .filter({ has: this.page.locator('[data-icon="plus"]') })
      .first();
  }

  get copyRuleButton(): Locator {
    return this.page
      .locator(".bg-gray-100.rounded-xl")
      .filter({ has: this.page.locator('[data-icon="nd-copy"]') })
      .first();
  }

  get deleteRuleButton(): Locator {
    return this.page
      .locator(".bg-gray-100.rounded-xl")
      .filter({ has: this.page.locator('[data-icon="trash"]') })
      .first();
  }

  get dragRuleHandle(): Locator {
    return this.page
      .locator(".bg-gray-100.rounded-xl")
      .filter({ has: this.page.locator('[data-icon="grip-vertical"]') })
      .first();
  }

  // Condition-row plus button uses a `.rounded-full` wrapper.
  get addConditionRowButton(): Locator {
    return this.page
      .locator(".rounded-full")
      .filter({ has: this.page.locator('[data-icon="plus"]') })
      .first();
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

  // Auth type dropdown — Add3DSConditionForThreeDsExemption uses
  // buttonText="Select Field", and the two default conditions are pre-filled
  // (amount, currency), so on the initial form the only "Select Field" button
  // is the auth-type field.
  get authTypeDropdown(): Locator {
    return this.page.getByRole("button", { name: "Select Field" }).first();
  }

  dropdownOption(text: string, nth = 5): Locator {
    return this.page
      .locator("div")
      .filter({ hasText: new RegExp(`^${text}$`) })
      .nth(nth);
  }

  // Generic helpers reused across workflow tests
  get goToHomeFallback(): Locator {
    return this.page.getByText("Go to Home", { exact: true }).first();
  }

  get betaBadge(): Locator {
    return this.page
      .locator(
        '[data-testid*="beta"], .badge:has-text("Beta"), span:has-text("BETA")',
      )
      .first();
  }
}

export default ThreeDSExemptionManager;
