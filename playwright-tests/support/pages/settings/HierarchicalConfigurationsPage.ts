import { Page, Locator } from "@playwright/test";

export class HierarchicalConfigurationsPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get settingsSidebar(): Locator {
    return this.page.getByTestId("settings");
  }

  get sidebarLink(): Locator {
    return this.page.getByTestId("hierarchicalconfigurations");
  }

  // The title also appears as the sidebar link, so the subtitle anchors it.
  get subtitle(): Locator {
    return this.page.getByText(
      "Manage certificates used to configure connectors",
      { exact: true },
    );
  }

  get pageHeading(): Locator {
    return this.subtitle
      .locator("..")
      .getByText("Hierarchical Configurations", { exact: true });
  }

  get addCertificateButton(): Locator {
    return this.page.getByRole("button", {
      name: "Add new certificate",
      exact: true,
    });
  }

  get emptyTableMessage(): Locator {
    return this.page.getByText(
      "No certificates yet. Click 'Add new certificate' to create one.",
      { exact: true },
    );
  }

  get tableRows(): Locator {
    return this.page.locator(
      'tr:has([data-table-location^="Hierarchical Configurations_tr"])',
    );
  }

  tableHeading(heading: string): Locator {
    return this.page.locator(`[data-table-heading="${heading}"]`);
  }

  resourceRow(resourceId: string): Locator {
    return this.tableRows.filter({
      has: this.page.getByText(resourceId, { exact: true }),
    });
  }

  resourceCell(resourceId: string, column: number): Locator {
    return this.resourceRow(resourceId).locator(
      `[data-table-location$="_td${column}"]`,
    );
  }

  get unauthorizedMessage(): Locator {
    return this.page.getByText("don't have access to this module").first();
  }

  // Add New Apple Pay Certificate modal
  get modal(): Locator {
    return this.page.locator(
      '[data-component="modal:Add New Apple Pay Certificate"]',
    );
  }

  get modalHeading(): Locator {
    return this.modal.locator(
      '[data-modal-header-text="Add New Apple Pay Certificate"]',
    );
  }

  modalText(text: string): Locator {
    return this.modal.getByText(text, { exact: true });
  }

  modalButton(name: string): Locator {
    return this.modal.getByRole("button", { name, exact: true });
  }

  get downloadFileButton(): Locator {
    return this.modalButton("Download File");
  }

  get continueButton(): Locator {
    return this.modalButton("Continue");
  }

  get chooseFileButton(): Locator {
    return this.modalButton("Choose File");
  }

  get submitButton(): Locator {
    return this.modalButton("Submit");
  }

  get removeFileIcon(): Locator {
    return this.modal.locator('[data-icon="trash-alt"]');
  }

  get closeModalIcon(): Locator {
    return this.modal.locator('[data-icon="modal-close-icon"]');
  }

  toast(message: string): Locator {
    return this.page.locator(`[data-id="${message}"]`);
  }

  async visit(): Promise<void> {
    await this.page.goto("/dashboard/hierarchical-configurations");
  }
}

export default HierarchicalConfigurationsPage;
