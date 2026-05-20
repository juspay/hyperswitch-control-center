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

  get yesSaveItButton(): Locator {
    return this.page.getByRole("button", { name: "Yes, save it" });
  }

  get configurationSavedToast(): Locator {
    return this.page.locator('[data-toast="Configuration saved successfully!"]');
  }

  connectorAt(index: number): Locator {
    return this.defaultFallbackList.locator("> div").nth(index);
  }
}

export default DefaultFallback;
