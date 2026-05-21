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
    return this.page.getByText("Configure advanced rules to apply surcharges");
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
