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

  get profileSubtitle(): Locator {
    return this.page.getByText("Manage your profile settings here").first();
  }

  get userInfoSectionHeading(): Locator {
    return this.page.getByText("User Info", { exact: true }).first();
  }

  get twoFactorAuthSectionHeading(): Locator {
    return this.page.getByText("Two factor authentication", { exact: true }).first();
  }

  get nameLabel(): Locator {
    return this.page.getByText("Name:", { exact: true }).first();
  }

  get emailLabel(): Locator {
    return this.page.getByText("Email:", { exact: true }).first();
  }

  get passwordLabel(): Locator {
    return this.page.getByText("Password:", { exact: true }).first();
  }

  get maskedPassword(): Locator {
    return this.page.getByText("********", { exact: true }).first();
  }

  get phoneLabel(): Locator {
    return this.page.getByText(/^Phone:?$/i).first();
  }

  get phoneInput(): Locator {
    return this.page.locator('input[name="phone"]').first();
  }

  get signOutAllSessionsButton(): Locator {
    return this.page.getByRole("button", { name: /Sign Out All Sessions/i }).first();
  }

  get resetPasswordButton(): Locator {
    return this.page.getByRole("button", { name: "Reset Password" }).first();
  }

  get changePasswordButton(): Locator {
    return this.page.locator('[data-button-text="Change Password"]').first();
  }

  get changePasswordModalHeader(): Locator {
    return this.page.locator('[data-modal-header-text="Change Password"]').first();
  }

  get oldPasswordInput(): Locator {
    return this.page.locator('input[name="old_password"]').first();
  }

  get newPasswordInput(): Locator {
    return this.page.locator('input[name="new_password"]').first();
  }

  get confirmPasswordInput(): Locator {
    return this.page.locator('input[name="confirm_password"]').first();
  }

  get confirmSubmitButton(): Locator {
    return this.page.locator('[data-button-text="Confirm"]').first();
  }

  get passwordMismatchError(): Locator {
    return this.page.getByText("The New password does not match!").first();
  }

  get passwordChangedSuccessToast(): Locator {
    return this.page.locator('[data-toast="Password Changed Successfully"]').first();
  }

  get passwordChangeFailedToast(): Locator {
    return this.page.locator('[data-toast="Password Change Failed, Try again"]').first();
  }

  toastByMessage(message: string): Locator {
    return this.page.locator(`[data-toast="${message}"]`).first();
  }

  async visit(): Promise<void> {
    await this.page.goto("/dashboard/account-settings/profile");
  }
}

export default ProfilePage;
