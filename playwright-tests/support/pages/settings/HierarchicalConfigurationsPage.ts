import { Page, Locator } from "@playwright/test";

/**
 * Certificate Management — the "Hierarchical Configurations" page under
 * Settings. Gated behind the `hierarchical_configurations` feature flag.
 */
export class HierarchicalConfigurationsPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  // Sidebar
  get sidebarLink(): Locator {
    return this.page.locator('[data-testid="hierarchicalconfigurations"]');
  }

  // Page chrome
  get pageSubHeading(): Locator {
    return this.page.getByText(
      "Manage certificates used to configure connectors",
    );
  }

  /**
   * Scoped to the page header block: the sidebar entry carries the same text,
   * so an unscoped lookup is ambiguous.
   */
  get pageHeader(): Locator {
    return this.page
      .locator("div")
      .filter({ has: this.pageSubHeading })
      .filter({
        has: this.page.getByText("Hierarchical Configurations", {
          exact: true,
        }),
      })
      .last();
  }

  get pageHeading(): Locator {
    return this.pageHeader.getByText("Hierarchical Configurations", {
      exact: true,
    });
  }

  get addCertificateButton(): Locator {
    return this.page.getByRole("button", { name: "Add new certificate" });
  }

  get emptyStateMessage(): Locator {
    return this.page.getByText(
      "No certificates yet. Click 'Add new certificate' to create one.",
    );
  }

  // Table
  get resourceIdColumn(): Locator {
    return this.page.getByText("Resource ID", { exact: true });
  }

  get merchantIdentifierColumn(): Locator {
    return this.page.getByText("Merchant Identifier", { exact: true });
  }

  get createdColumn(): Locator {
    return this.page.getByText("Created", { exact: true });
  }

  // Modal — shared
  get modalHeading(): Locator {
    return this.page.getByText("Add New Apple Pay Certificate", {
      exact: true,
    });
  }

  get stepOneSubHeading(): Locator {
    return this.page.getByText(
      "Step 1 of 2 - Download the certificate signing request",
    );
  }

  get stepTwoSubHeading(): Locator {
    return this.page.getByText("Step 2 of 2 - Upload the signed certificate");
  }

  get errorBannerHeading(): Locator {
    return this.page.getByText("Something went wrong", { exact: true });
  }

  // Modal — step 1 (download CSR)
  get downloadFileButton(): Locator {
    return this.page.getByRole("button", { name: "Download File" });
  }

  get continueButton(): Locator {
    return this.page.getByRole("button", { name: "Continue" });
  }

  // Modal — step 2 (upload signed certificate)
  get chooseFileButton(): Locator {
    return this.page.getByRole("button", { name: "Choose File" });
  }

  get certificateFileInput(): Locator {
    return this.page.locator('input[type="file"][accept=".cer"]');
  }

  get submitButton(): Locator {
    return this.page.getByRole("button", { name: "Submit" });
  }

  get removeSelectedFileButton(): Locator {
    return this.page.locator('[data-icon="trash-alt"]');
  }

  selectedFileName(name: string): Locator {
    return this.page.getByText(name, { exact: true });
  }

  /**
   * Toasts render as `[data-snackbar="<message>"]`; the other two selectors
   * cover the legacy toast markup still used when the design system is off.
   */
  toast(message: string): Locator {
    return this.page
      .locator(
        `[data-snackbar="${message}"], [data-toast="${message}"], [role="alert"]`,
      )
      .filter({ hasText: message });
  }
}
