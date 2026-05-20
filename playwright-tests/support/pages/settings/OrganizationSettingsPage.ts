import { Page, Locator } from "@playwright/test";

export class OrganizationSettingsPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get learnMoreButton(): Locator {
    return this.page.getByRole("button", { name: "Learn More" }).first();
  }

  get createPlatformOrganizationButton(): Locator {
    return this.page
      .getByRole("button", { name: "Create Platform Organization" })
      .first();
  }

  get goToHomeFallback(): Locator {
    return this.page.getByText("Go to Home", { exact: true }).first();
  }

  async visit(): Promise<void> {
    await this.page.goto("/dashboard/organization-settings");
  }
}

export default OrganizationSettingsPage;
