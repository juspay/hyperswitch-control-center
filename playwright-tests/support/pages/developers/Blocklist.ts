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

  toast(message: string): Locator {
    return this.page
      .locator(`[data-toast="${message}"], [role="alert"]`)
      .filter({
        hasText: message,
      });
  }
}
