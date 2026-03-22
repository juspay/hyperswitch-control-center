import { Page, Locator } from "@playwright/test";

export class DefaultFallback {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }
}

export default DefaultFallback;
