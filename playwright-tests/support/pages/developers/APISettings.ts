import { Page, Locator } from "@playwright/test";

export class APISettings {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // Page Header
  get pageHeading(): Locator {
    return this.page.getByRole("heading", { name: "API Keys", level: 2 });
  }

  get pageSubheading(): Locator {
    return this.page.getByText(
      "Manage API keys and credentials for integrated payment services",
    );
  }

  // Empty State
  get noDataAvailable(): Locator {
    return this.page.getByText(/No Data Available/i);
  }

  // Buttons
  get createNewApiKeyButton(): Locator {
    return this.page.getByRole("button", { name: "Create New API Key" });
  }

  get createButton(): Locator {
    return this.page.getByRole("button", { name: "Create", exact: true });
  }

  get updateButton(): Locator {
    return this.page.getByRole("button", { name: /Update/i });
  }

  get downloadKeyButton(): Locator {
    return this.page.getByRole("button", { name: "Download the key" });
  }

  get neverExpiryButton(): Locator {
    return this.page.getByRole("button", { name: "Never" });
  }

  get customExpiryOption(): Locator {
    return this.page.getByText("Custom", { exact: true });
  }

  get selectDateButton(): Locator {
    return this.page.getByRole("button", { name: "Select Date" });
  }

  get chevronRight(): Locator {
    return this.page.locator('[data-icon="chevron-right"]').first();
  }

  get yesDeleteItButton(): Locator {
    return this.page.getByRole("button", {
      name: "Yes, delete it",
      exact: true,
    });
  }

  // Modal Headings
  get createApiKeyModalHeading(): Locator {
    return this.page.getByText("Create API Key");
  }

  get updateApiKeyModalHeading(): Locator {
    return this.page.getByText(/Update API Key/i);
  }

  get pleaseNoteApiKey(): Locator {
    return this.page.getByText(/Please note down the API key/i);
  }

  get generatedKeyText(): Locator {
    return this.page.getByText(/snd_/i).first();
  }

  get copiedToClipboardToast(): Locator {
    return this.page.getByText("Copied to Clipboard!");
  }

  // Form Inputs — by name attribute
  get nameInput(): Locator {
    return this.page.locator('input[name="name"]');
  }

  get descriptionInput(): Locator {
    return this.page.locator('input[name="description"]');
  }

  // Form Inputs — by role (used in some flows when modal is open)
  get nameTextbox(): Locator {
    return this.page.getByRole("textbox", { name: "Name" });
  }

  get descriptionTextbox(): Locator {
    return this.page.getByRole("textbox", { name: "Description" });
  }

  // Validation Errors
  get nameRequiredError(): Locator {
    return this.page.getByText("Please enter name");
  }

  get descriptionRequiredError(): Locator {
    return this.page.getByText("Please enter description");
  }

  get nameTooLongError(): Locator {
    return this.page.getByText("Name can't be more than 64 characters", {
      exact: true,
    });
  }

  get descriptionTooLongError(): Locator {
    return this.page.getByText(
      "Description can't be more than 256 characters",
      {
        exact: true,
      },
    );
  }

  get descriptionRequiredErrorExact(): Locator {
    return this.page.getByText("Please enter description", { exact: true });
  }

  validationTooltip(): Locator {
    return this.page
      .locator('[role="tooltip"]')
      .filter({ hasText: /Name|Description/i })
      .first();
  }

  // Table
  expectedColumns(): string[] {
    return ["API Key Prefix", "Name", "Description", "Created", "Expiration"];
  }

  columnHeader(name: string): Locator {
    return this.page.getByRole("columnheader", { name, exact: true });
  }

  keyRow(keyName: string): Locator {
    return this.page.getByRole("row").filter({ hasText: keyName });
  }

  deleteIcon(row: Locator): Locator {
    return row.locator('[data-icon="delete"]');
  }

  editIcon(row: Locator): Locator {
    return row.locator('[data-icon="edit"]');
  }

  dayOfMonth(day: string): Locator {
    return this.page.getByText(day, { exact: true });
  }

  // Helpers
  async openCreateModal(): Promise<void> {
    await this.createNewApiKeyButton.click();
  }

  async fillNameAndDescription(
    name: string,
    description: string,
  ): Promise<void> {
    await this.nameInput.fill(name);
    await this.descriptionInput.fill(description);
  }
}

export default APISettings;
