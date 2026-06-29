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

  // The page heading is a plain div whose text ("Organization Settings") also
  // appears as the sidebar link, so the unique subtitle is the reliable
  // page-load marker.
  get pageHeading(): Locator {
    return this.page.getByText(
      "Manage organization configuration and settings",
      {
        exact: true,
      },
    );
  }

  get organizationDetailsHeading(): Locator {
    return this.page.getByText("Organization Details", { exact: true });
  }

  get organizationIdLabel(): Locator {
    return this.page.getByText("Organization ID", { exact: true });
  }

  get organizationNameLabel(): Locator {
    return this.page.getByText("Organization Name", { exact: true });
  }

  // Innermost div that wraps the Organization ID label + value + copy icon.
  get organizationIdRow(): Locator {
    return this.page
      .locator("div")
      .filter({ has: this.organizationIdLabel })
      .last();
  }

  get copyOrgIdIcon(): Locator {
    return this.organizationIdRow.locator('[data-icon="nd-copy"]');
  }

  get editOrganizationNameButton(): Locator {
    return this.page.getByRole("button", { name: "Edit" });
  }

  // The inline-edit input is the only textbox on the page while editing.
  get organizationNameInput(): Locator {
    return this.page.getByRole("textbox").first();
  }

  get saveOrganizationNameButton(): Locator {
    return this.page.locator('button:has([data-icon="nd-check"])');
  }

  get cancelOrganizationNameButton(): Locator {
    return this.page.locator('button:has([data-icon="nd-cross"])');
  }

  // InlineEditInput does not render the validation message text (the source has
  // a TODO for it); an invalid value surfaces a red ring + a disabled save
  // button instead.
  get invalidNameRing(): Locator {
    return this.page.locator(".ring-red-300");
  }

  get platformNameInput(): Locator {
    return this.page.getByPlaceholder("Eg: My Platform Organization");
  }

  // "Create Platform" is a substring of the "Create Platform Organization" CTA,
  // so the modal's submit button needs an exact match.
  get createPlatformSubmitButton(): Locator {
    return this.page.getByRole("button", {
      name: "Create Platform",
      exact: true,
    });
  }

  get aboutPlatformHeading(): Locator {
    return this.page.getByText("About Platform Organizations", { exact: true });
  }

  get createPlatformOrganizationCard(): Locator {
    return this.page.getByText(
      "Create New Platform OrganizationCreate a new platform organization to manage multiple connected merchants and enable platform-level features.",
    );
  }

  get convertToPlatformHeading(): Locator {
    return this.page.getByText("Convert to Platform");
  }

  get convertToPlatformDescription(): Locator {
    return this.page.getByText(
      "To convert your existing organization to a platform organization, please contact your administrator. This action requires elevated permissions and cannot be performed directly.",
    );
  }

  get contactUsText(): Locator {
    return this.page.getByText("Contact us for further assistance on Slack");
  }

  // The platform-creation modal (unlike the inline edit) does render the
  // validation message text on change.
  nameValidationError(message: string): Locator {
    return this.page.getByText(message, { exact: true });
  }

  toast(message: string): Locator {
    return this.page.locator(`[data-toast="${message}"]`);
  }

  async visit(): Promise<void> {
    await this.page.goto("/dashboard/organization-settings");
  }
}

export default OrganizationSettingsPage;
