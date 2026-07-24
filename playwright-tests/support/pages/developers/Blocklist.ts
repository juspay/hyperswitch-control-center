import { Page, Locator } from "@playwright/test";

export class Blocklist {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get pageHeading(): Locator {
    return this.page.getByRole("heading", { name: "Blocklist" });
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
    return this.page.getByText("Upload a CSV file up to 5 MB");
  }

  get supportedFileText(): Locator {
    return this.page.getByText(
      "Only .csv files are supported for blocklist batch uploads.",
    );
  }

  get removeSelectedFileButton(): Locator {
    return this.page.locator('[data-icon="trash-alt"]');
  }

  get downloadSampleFileButton(): Locator {
    return this.page.getByRole("button", { name: "Download Sample File" });
  }

  get emptyState(): Locator {
    return this.page.getByText("No blocklist batch uploads found");
  }

  toast(message: string): Locator {
    return this.page.locator(`[data-toast="${message}"]`);
  }
}
