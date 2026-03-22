import { Page, Locator } from "@playwright/test";

export class VolumeBasedConfiguration {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get connectorDropdown(): Locator {
    return this.page.locator('[data-value="addProcessors"]');
  }
}

export default VolumeBasedConfiguration;
