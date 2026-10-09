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

  get learnMoreButton(): Locator {
    return this.page.getByRole("button", { name: "Learn More" });
  }

  get infoModalHeading(): Locator {
    return this.page.getByText("How the hierarchy works", { exact: true });
  }

  get infoModalDescription(): Locator {
    return this.page.getByText(
      "How Organization, Merchant, and Profile levels nest across platform and standard setups.",
      { exact: true },
    );
  }

  get standardOrganizationsTab(): Locator {
    return this.page.getByText("Standard Organizations", { exact: true });
  }

  get platformOrganizationsTab(): Locator {
    return this.page.getByText("Platform Organizations", { exact: true });
  }

  get standardOrganizationDiagram(): Locator {
    return this.page.getByText("Standard Organization", { exact: true });
  }

  get firstStandardMerchantAccount(): Locator {
    return this.page.getByText("Merchant Account 1", { exact: true });
  }

  get secondStandardMerchantAccount(): Locator {
    return this.page.getByText("Merchant Account 2", { exact: true });
  }

  get platformOrganizationDiagram(): Locator {
    return this.page.getByText("Platform Organization", { exact: true });
  }

  get platformMerchantAccount(): Locator {
    return this.page.getByText("Platform Merchant Account", { exact: true });
  }

  get connectedMerchantAccounts(): Locator {
    return this.page.getByText("Connected Merchant Accounts", { exact: true });
  }

  get connectedProfiles(): Locator {
    return this.page.getByText("Connected Profiles", { exact: true });
  }

  get standardMerchantAccount(): Locator {
    return this.page.getByText("Standard Merchant Account", { exact: true });
  }

  get infoModalCloseIcon(): Locator {
    return this.page.locator('[data-icon="modal-close-icon"]').nth(3);
  }

  get orgColumn(): Locator {
    return this.page.getByText("Organization").nth(4);
  }

  get merchantColumn(): Locator {
    return this.page.getByText("Merchant", { exact: true });
  }

  get profileColumn(): Locator {
    return this.page.getByText("Profile", { exact: true });
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
    return this.profileColumn
      .locator("button")
      .filter({ hasText: name })
      .first();
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
