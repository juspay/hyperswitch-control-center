import { Page, Locator } from "@playwright/test";

export class VolumeBasedConfiguration {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }
}

export default VolumeBasedConfiguration;
