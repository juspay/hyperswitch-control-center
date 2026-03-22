import { Page, Locator } from "@playwright/test";

export class DefaultFallback {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get defaultFallbackList(): Locator {
    return this.page.locator('[class="flex flex-col  w-full"]');
  }

  get saveChangesButton(): Locator {
    return this.page.locator('[data-button-for="saveChanges"]');
  }
}

export default DefaultFallback;
