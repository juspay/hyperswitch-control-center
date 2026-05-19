import { Page, Locator } from "@playwright/test";

export class ProfilePage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get profileButton(): Locator {
    return this.page.locator('[data-button-for="profile"]');
  }

  get profileMenuEntry(): Locator {
    return this.page.getByText(/Profile|Account Settings|Personal Details/i).first();
  }

  get profileHeading(): Locator {
    return this.page.getByText("Profile").first();
  }

  get resetPasswordButton(): Locator {
    return this.page.getByRole("button", { name: "Reset Password" }).first();
  }

  async visit(): Promise<void> {
    await this.page.goto("/dashboard/account-settings/profile");
  }
}

export default ProfilePage;
