import { Page, Locator } from "@playwright/test";

export class Blocklist {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get tab(): Locator {
    return this.page.getByRole("tab", { name: "Block List", exact: true });
  }

  get pageHeading(): Locator {
    return this.page.getByText("Blocklist", { exact: true });
  }

  get uploadCsvHeading(): Locator {
    return this.page.getByRole("heading", { name: "Upload CSV" });
  }

  get fileInput(): Locator {
    return this.page.locator('input[type="file"][accept=".csv"]');
  }

  get uploadButton(): Locator {
    return this.page.getByRole("button", { name: "Upload" });
  }

  get chooseFileButton(): Locator {
    return this.page.getByRole("button", { name: "Choose File" });
  }

  get uploadFileText(): Locator {
    return this.page.getByText(
      "Upload a CSV file with up to 100,000 rows and a maximum size of 5 MB",
    );
  }

  get supportedFileText(): Locator {
    return this.page.getByText(
      "CSV files above either limit cannot be processed. Only .csv files are supported.",
    );
  }

  get removeSelectedFileButton(): Locator {
    return this.page.locator('[data-icon="trash-alt"]');
  }

  get downloadSampleFileButton(): Locator {
    return this.page.getByRole("button", { name: "Download Sample File" });
  }

  get jobsTable(): Locator {
    return this.page.getByText("Job ID", { exact: true });
  }

  // ---- Count summary cards ----
  get countsHelperText(): Locator {
    return this.page.getByText(
      "Counts are loaded when the page opens. Refresh the page to see updated counts after adding or removing entries.",
    );
  }

  get fingerprintsCountCard(): Locator {
    return this.page.getByText("Fingerprints", { exact: true });
  }

  get cardBinsCountCard(): Locator {
    return this.page.getByText("Card BINs", { exact: true });
  }

  binLengthCountCard(digits: number): Locator {
    return this.page.getByText(`${digits}-digit BINs`, { exact: true });
  }

  countValueFor(title: string): Locator {
    return this.page
      .locator("section")
      .filter({ has: this.page.getByText(title, { exact: true }) })
      .locator("p")
      .nth(1);
  }

  get countLoadFailureMessage(): Locator {
    return this.page.getByText("Couldn't load count.").first();
  }

  // ---- Check Blocklist (lookup) card ----
  get lookupHeading(): Locator {
    return this.page.getByRole("heading", { name: "Check Blocklist" });
  }

  get lookupDescription(): Locator {
    return this.page.getByText(
      "Check whether a card BIN or fingerprint is currently blocked.",
    );
  }

  get lookupInput(): Locator {
    return this.page.locator('input[name="blocklist-lookup-data"]');
  }

  get lookupHint(): Locator {
    return this.page.getByText(
      "Checked against every type, e.g. 411111 or fp_abc123",
    );
  }

  get lookupCheckButton(): Locator {
    return this.page.getByRole("button", { name: "Check", exact: true });
  }

  get lookupBlockedTag(): Locator {
    return this.page.getByText("Blocked", { exact: true });
  }

  get lookupNotBlockedTag(): Locator {
    return this.page.getByText("Not blocked", { exact: true });
  }

  // ---- Add / Remove single entry cards ----
  entryCard(title: string): Locator {
    return this.page
      .locator("section")
      .filter({ has: this.page.getByRole("heading", { name: title }) });
  }

  get addEntryCard(): Locator {
    return this.entryCard("Add to Blocklist");
  }

  get removeEntryCard(): Locator {
    return this.entryCard("Remove from Blocklist");
  }

  get addEntryDataInput(): Locator {
    return this.page.locator('input[name="blocklist_add_entry-data"]');
  }

  get removeEntryDataInput(): Locator {
    return this.page.locator('input[name="blocklist_delete_entry-data"]');
  }

  get addEntryButton(): Locator {
    return this.page.getByRole("button", { name: "Add Entry" });
  }

  get removeEntryButton(): Locator {
    return this.page.getByRole("button", { name: "Remove Entry" });
  }

  typeDropdownIn(card: Locator): Locator {
    return card.getByRole("button", {
      name: /Generic Card BIN|Fingerprint|Select type/,
    });
  }

  dropdownOption(label: string): Locator {
    return this.page.getByText(label, { exact: true });
  }

  helperTextIn(card: Locator, text: string): Locator {
    return card.getByText(text, { exact: true });
  }

  // ---- Generate Export card ----
  get generateExportHeading(): Locator {
    return this.page.getByRole("heading", { name: "Generate Export" });
  }

  get generateExportDescription(): Locator {
    return this.page.getByText(
      "Export this profile's blocklist as a CSV file. Download it from the jobs table once the export completes.",
    );
  }

  get generateExportButton(): Locator {
    return this.page.getByRole("button", { name: "Generate Export" });
  }

  // ---- Jobs table row actions ----
  /**
   * Row actions are scoped to the jobs table: the "Download Sample File"
   * button in the Upload CSV card uses the same download icon.
   */
  get jobsTableElement(): Locator {
    return this.page.locator("table");
  }

  get refreshJobAction(): Locator {
    return this.jobsTableElement.locator('[data-icon="sync"]');
  }

  get downloadExportAction(): Locator {
    return this.jobsTableElement.locator('[data-icon="nd-download-bar-down"]');
  }

  jobRow(jobId: string): Locator {
    return this.page.locator("tr").filter({ hasText: jobId });
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
      .filter({
        hasText: message,
      });
  }
}
