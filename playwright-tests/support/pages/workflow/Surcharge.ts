import { Page, Locator } from "@playwright/test";

export class Surcharge {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // Page-level
  get pageHeading(): Locator {
    return this.page.getByText("Surcharge").first();
  }

  get pageSubtitle(): Locator {
    return this.page.getByText("Configure advanced rules to apply surcharges", { exact: true });
  }

  // LANDING view — no active rule
  get emptyStateHeading(): Locator {
    return this.page.getByText("Configure Surcharge", { exact: true });
  }

  get createNewButton(): Locator {
    return this.page.getByRole("button", { name: "Create New" });
  }

  // LANDING view — active rule preview
  get activeBadge(): Locator {
    return this.page.getByText("ACTIVE", { exact: true });
  }

  get editIcon(): Locator {
    return this.page.locator('[data-icon="edit"]').first();
  }

  get deleteIcon(): Locator {
    return this.page.locator('[data-icon="delete"]').first();
  }

  // Override / delete confirmation popups
  get overrideWarningHeading(): Locator {
    return this.page.getByText("Heads up!", { exact: true });
  }

  get overrideWarningDescription(): Locator {
    return this.page.getByText(
      /This will override the existing surcharge configuration/,
    );
  }

  get deleteConfirmHeading(): Locator {
    return this.page.getByText("Confirm delete?", { exact: true });
  }

  get deleteConfirmDescription(): Locator {
    return this.page.getByText(
      /Are you sure you want to delete currently active surcharge rule/,
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

  get saveButton(): Locator {
    return this.page.getByRole("button", { name: /^Save\s*$/i });
  }

  get cancelFormButton(): Locator {
    return this.page.getByRole("button", { name: "Cancel", exact: true });
  }

  get configureSurchargeBlock(): Locator {
    // Use the "For example:" hint copy — it's only rendered inside the form
    // view, so it doesn't collide with the page-level subtitle.
    return this.page.getByText("For example:");
  }

  get ruleHeading(): Locator {
    return this.page.getByText(/^Rule 1$/);
  }

  ruleHeadingByIndex(index: number): Locator {
    return this.page.getByText(new RegExp(`^Rule ${index}$`));
  }

  // Rule action icons live inside `.bg-gray-100.rounded-xl` clickable wrappers.
  // Filtering by the icon name disambiguates them from the condition-row plus
  // button (which uses `.rounded-full`).
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

  // Surcharge type selector
  get selectSurchargeTypeButton(): Locator {
    return this.page.getByRole("button", { name: /Select Surcharge Type|Rate|Fixed/ }).first();
  }

  surchargeTypeOption(label: "Rate" | "Fixed"): Locator {
    return this.page
      .locator("div")
      .filter({ hasText: new RegExp(`^${label}$`) })
      .first();
  }
  // The value input's `name` swaps suffix between `.percentage` (rate) and
  // `.amount` (fixed) — used to confirm a type toggle actually re-renders.
  surchargeValueInput(type: "percentage" | "amount"): Locator {
    return this.page.locator(`input[name$="surcharge.value.${type}"]`);
  }

  get taxOnSurchargeInput(): Locator {
    return this.page.locator('input[name$="tax_on_surcharge.percentage"]');
  }

  dropdownOption(text: string, nth = 5): Locator {
    return this.page
      .locator("div")
      .filter({ hasText: new RegExp(`^${text}$`) })
      .nth(nth);
  }

  // Generic helpers reused from the rest of the workflow tests
  get goToHomeFallback(): Locator {
    return this.page.getByText("Go to Home", { exact: true }).first();
  }

  // Back-compat shim used by the older spec — `createNewButton` is preferred
  // for new tests, but the old import path still references this name.
  get createNewOrSaveButton(): Locator {
    return this.page.getByRole("button", { name: /Create New|Save/i }).first();
  }

  successToast(text: string | RegExp): Locator {
    return this.page.locator(`[data-toast]`).filter({ hasText: text });
  }
}

export default Surcharge;
