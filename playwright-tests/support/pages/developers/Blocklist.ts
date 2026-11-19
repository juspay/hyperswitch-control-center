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
    return this.page.getByText("Upload a CSV", { exact: true });
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
    return this.page.getByText("Up to 100,000 rows, 5 MB max");
  }

  get supportedFileText(): Locator {
    return this.page.getByText(
      "Only .csv files are supported. Larger files cannot be processed.",
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

  get sectionDescription(): Locator {
    return this.page.getByText(
      "Block card BINs and card fingerprints for this profile. Payments and payouts keep separate lists.",
    );
  }

  transactionTab(name: "Payment" | "Payout"): Locator {
    return this.page.getByRole("tab", { name, exact: true });
  }

  get addEntryStepDescription(): Locator {
    return this.page.getByText(
      /^Blocks a single card BIN or fingerprint in the/,
    );
  }

  get exportStepDescription(): Locator {
    return this.page.getByText(
      /^Download this profile's (payment|payout) blocklist\.$/,
    );
  }

  get exportCardDescription(): Locator {
    return this.page.getByText(
      /^Generates a CSV of every (payment|payout) entry/,
    );
  }

  get bulkUploadHeading(): Locator {
    return this.page.getByText("Bulk upload and copy", { exact: true });
  }

  get bulkUploadSharedNote(): Locator {
    return this.page.getByText(
      "These apply to both payment and payout blocklists.",
    );
  }

  get uploadCsvDescription(): Locator {
    return this.page.getByText(
      "One entry per row. Rows without a transaction_type go to payments. See the sample file for the format.",
    );
  }

  get backgroundJobsHeading(): Locator {
    return this.page.getByText("Background jobs", { exact: true });
  }

  get noBackgroundJobsText(): Locator {
    return this.page.getByText(
      "No background jobs yet. Bulk uploads, exports and clones will show up here.",
    );
  }

  get countsLoadError(): Locator {
    return this.page.getByText("Couldn't load count.");
  }

  countCard(title: string): Locator {
    return this.page
      .locator("section")
      .filter({ has: this.page.getByText(title, { exact: true }) });
  }

  get addEntryInput(): Locator {
    return this.page.locator('input[name="blocklist_add_entry-data"]');
  }

  get unblockEntryInput(): Locator {
    return this.page.locator('input[name="blocklist_delete_entry-data"]');
  }

  get lookupInput(): Locator {
    return this.page.locator('input[name="blocklist-lookup-data"]');
  }

  get blockButton(): Locator {
    return this.page.getByRole("button", { name: "Block", exact: true });
  }

  get unblockButton(): Locator {
    return this.page.getByRole("button", { name: "Unblock", exact: true });
  }

  get checkButton(): Locator {
    return this.page.getByRole("button", { name: "Check", exact: true });
  }

  get checkTab(): Locator {
    return this.page.getByRole("tab", { name: "Check", exact: true });
  }

  get unblockTab(): Locator {
    return this.page.getByRole("tab", { name: "Unblock", exact: true });
  }

  get addEntryPanel(): Locator {
    return this.page
      .locator(".rounded-lg.p-5")
      .filter({ has: this.addEntryInput });
  }

  get unblockEntryPanel(): Locator {
    return this.page
      .locator(".rounded-lg.p-5")
      .filter({ has: this.unblockEntryInput });
  }

  entryTypeDropdown(panel: Locator): Locator {
    return panel.getByRole("button", { name: "Generic Card BIN" });
  }

  entryTypeOption(label: string): Locator {
    return this.page
      .getByRole("menuitem", { name: label, exact: true })
      .or(this.page.locator(`[data-dropdown-value="${label}"]`))
      .first();
  }

  get generateExportButton(): Locator {
    return this.page.getByRole("button", { name: "Generate Export" });
  }

  get cloneBlocklistButton(): Locator {
    return this.page.getByRole("button", { name: "Clone Blocklist" });
  }

  get cloneModalHeading(): Locator {
    return this.page.getByText("Clone blocklist", { exact: true });
  }

  successToast(message: string): Locator {
    return this.page.getByText(message, { exact: true });
  }

  toast(message: string): Locator {
    return this.page
      .locator(`[data-toast="${message}"], [role="alert"]`)
      .filter({
        hasText: message,
      });
  }
}
