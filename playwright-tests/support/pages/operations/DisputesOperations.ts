import { Page, Locator } from "@playwright/test";

export class DisputesOperations {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get searchInput(): Locator {
    return this.page.locator('input[placeholder="Search for dispute ID"]');
  }

  get filterDropdown(): Locator {
    return this.page
      .locator("div")
      .filter({ hasText: /^ConnectorDispute StatusDispute Stage$/ })
      .nth(1);
  }

  get fourColumnGrid(): Locator {
    return this.page.locator('[class*="grid-cols-4"]').first();
  }

  get disputeListFirstRow(): Locator {
    return this.page
      .locator('table tbody tr:first-child, [data-testid*="dispute-item"]')
      .first();
  }

  get firstDisputeRow(): Locator {
    return this.page.locator("table tbody tr:first-child").first();
  }

  get uploadEvidenceButton(): Locator {
    return this.page
      .locator('[data-button-for="uploadEvidence"], button:has-text("Upload")')
      .first();
  }

  get fileInput(): Locator {
    return this.page.locator('input[type="file"]').first();
  }

  get uploadToast(): Locator {
    return this.page.locator(
      '[data-toast*="upload"], [data-toast*="success"]',
    );
  }

  get deadlineElement(): Locator {
    return this.page
      .locator('[data-testid*="deadline"], [data-testid*="countdown"]')
      .first();
  }

  get expiredDispute(): Locator {
    return this.page
      .locator('[data-testid*="expired"], tr:has-text("Expired")')
      .first();
  }

  get submitEvidenceButton(): Locator {
    return this.page.locator('[data-button-for="submitEvidence"]').first();
  }
}

export default DisputesOperations;
