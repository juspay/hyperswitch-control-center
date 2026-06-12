import { Page, Locator } from "@playwright/test";

export class OrganizationChartPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get pageHeading(): Locator {
    return this.page.getByText("Organization Chart", { exact: true });
  }

  get pageSubtitle(): Locator {
    return this.page.getByText(
      "An entity-level overview enabling navigation and transitions across your organization based on access permissions.",
    );
  }

  get orgColumn(): Locator {
    return this.page.getByText('Organization').nth(4);
  }

  get merchantColumn(): Locator {
    return this.page.getByText('Merchant', { exact: true });
  }

  get profileColumn(): Locator {
    return this.page.getByText('Profile', { exact: true });
  }

  get firstOrgButton(): Locator {
    return this.orgColumn.locator("button").first();
  }

  get firstMerchantButton(): Locator {
    return this.merchantColumn.locator("button").first();
  }

  get firstProfileButton(): Locator {
    return this.profileColumn.locator("button").first();
  }

  profileButtonByName(name: string): Locator {
    return this.profileColumn.locator("button").filter({ hasText: name }).first();
  }

  get merchantSwitchingLoader(): Locator {
    return this.page.getByText(/Switching merchant\.\.\./);
  }

  get profileSwitchingLoader(): Locator {
    return this.page.getByText(/Switching profile\.\.\./);
  }

  async visit(): Promise<void> {
    await this.page.goto("/dashboard/organization-chart");
  }
}

export default OrganizationChartPage;
