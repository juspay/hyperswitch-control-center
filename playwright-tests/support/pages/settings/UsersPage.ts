import { Page, Locator, expect } from "@playwright/test";

export class UsersPage {
  readonly page: Page;

  constructor(page: Page) {
    this.page = page;
  }

  get inviteUsersButton(): Locator {
    return this.page.locator('[data-button-for="inviteUsers"]');
  }

  get emailListInput(): Locator {
    return this.page.locator('[name="email_list"]');
  }

  get inviteEmailField(): Locator {
    return this.page.locator('[class="w-full cursor-text"]');
  }

  get roleDropdownTrigger(): Locator {
    return this.page.locator(
      '[class="bg-gray-200 w-full h-[calc(100%-16px)] my-2 flex items-center px-4"]',
    );
  }

  get merchantDropdown(): Locator {
    return this.page.locator('[data-dropdown-for="Select a Merchant"] button');
  }

  get roleOption(): Locator {
    return this.page.locator(
      '[class="relative inline-flex whitespace-pre leading-5 justify-between text-sm py-3 px-4 font-medium rounded-md hover:bg-opacity-80 bg-white border w-full"]',
    );
  }

  get entityOption(): Locator {
    return this.page.locator('[class="mr-5"]');
  }

  get sendInviteButton(): Locator {
    return this.page.locator('[data-button-for="sendInvite"]');
  }

  get manageUserButton(): Locator {
    return this.page.locator('[data-button-for="manageUser"]');
  }

  get pageTitle(): Locator {
    return this.page.locator("div.text-fs-28.font-semibold.leading-10");
  }

  get manageUserModalHeading(): Locator {
    return this.page.locator('[data-modal-header-text="Manage user"]');
  }

  get updateRoleButton(): Locator {
    return this.page.locator('[data-button-for="update"]');
  }

  get resendInviteButton(): Locator {
    return this.page.locator('[data-button-for="resend"]');
  }

  get deleteUserButton(): Locator {
    return this.page.locator('[data-button-for="delete"]');
  }

  get confirmDeleteButton(): Locator {
    return this.page.locator('[data-button-for="confirm"]');
  }

  async verifyPageTitle(): Promise<void> {
    await expect(this.pageTitle).toHaveText("Team management");
  }

  get usersTableRows(): Locator {
    return this.page.locator("table#table tbody tr");
  }

  get rolesTabInactive(): Locator {
    return this.page
      .locator("div.text-jp-gray-900.text-opacity-50")
      .filter({ hasText: "Roles" })
      .first();
  }

  get usersTabInactive(): Locator {
    return this.page
      .locator("div.text-jp-gray-900.text-opacity-50")
      .filter({ hasText: "Users" })
      .first();
  }

  get createCustomRoleButton(): Locator {
    return this.page.getByRole("button", { name: "Create custom roles" });
  }

  // The role_name input is rendered with autoComplete="off", which strips the
  // `name` attribute (see TextInput.res). The data-input-name attribute lives
  // on a wrapper <div>, so target the inner <input> via the accessible label.
  get roleNameInput(): Locator {
    return this.page.getByRole("textbox", { name: "Enter custom role name" });
  }

  get submitCreateRoleButton(): Locator {
    return this.page.getByRole("button", { name: "Create role" });
  }

  get roleScopeButton(): Locator {
    return this.page.locator(
      '[data-component-field-wrapper="field-role_scope"] button',
    );
  }

  get entityTypeButton(): Locator {
    return this.page.locator(
      '[data-component-field-wrapper="field-entity_type"] button',
    );
  }

  get modalCloseIcon(): Locator {
    return this.page.locator('[data-icon="modal-close-icon"]').first();
  }

  async visit(): Promise<void> {
    await this.page.goto("/dashboard/users");
  }

  async visitCreateCustomRole(): Promise<void> {
    await this.page.goto("/dashboard/users/create-custom-role");
  }

  async openRolesTab(): Promise<void> {
    await this.rolesTabInactive.click();
  }

  async navigate(): Promise<void> {
    await this.page.getByRole('link', { name: 'Users' }).click();
  }

  async navigateInviteUsers(): Promise<void> {
    await this.navigate();
    await this.inviteUsersButton.click();
  }

  async inviteUser(email: string): Promise<void> {
    await this.inviteUsersButton.click();
    await this.emailListInput.fill(email);
    await this.roleDropdownTrigger.click();
    await this.roleOption.click();
    await this.entityOption.filter({ hasText: "Developer" }).first().click();
    await this.sendInviteButton.click();
  }

  async fillInviteForm(
    email: string,
    role: string,
    profileType: string = "all_profiles",
    merchantType: string = "Test_merchant",
  ): Promise<void> {
    await this.inviteEmailField.fill(email);

    if (role === "Organization Admin") {
      await this.page.locator('[data-value="testMerchant"]').click();
      await this.page.locator('[data-dropdown-value="All merchants"]').click();
    }

    if (profileType === "default") {
      await this.page.locator('[data-value="allProfiles"]').click();
      await this.page.locator('[data-dropdown-value="default"]').click();
    }

    void merchantType;

    await this.roleDropdownTrigger.click();
    await this.roleOption.click();
    await this.entityOption.filter({ hasText: role }).first().click();

    await this.sendInviteButton.click();
    await expect(this.sendInviteButton).toBeHidden();
  }

  async verifyUserDetailsUsernameDisplay(email: string): Promise<void> {
    const localPart = email.split("@")[0];
    const username = localPart.charAt(0).toUpperCase() + localPart.slice(1);
    await expect(
      this.page.locator("p.text-2xl.font-semibold.leading-8"),
    ).toHaveText(username);
  }

  async verifyUserDetailsEmailDisplay(email: string): Promise<void> {
    const emailEl = this.page.locator("p", { hasText: email }).first();
    await expect(emailEl).toBeVisible();
    await expect(emailEl).toHaveClass(/text-grey-600/);
    await expect(emailEl).toHaveClass(/opacity-40/);
  }

  async verifyUserDetailsTableRowContent(
    merchants: string,
    profiles: string,
    role: string,
  ): Promise<void> {
    const row = this.page.locator("table tr").nth(1);
    await expect(row.locator("td").nth(0)).toHaveText(merchants);
    await expect(row.locator("td").nth(1)).toHaveText(profiles);
    await expect(row.locator("td").nth(2)).toHaveText(role);
  }

  async verifyStatus(
    status: string,
    textColor: string,
    bgColor: string,
  ): Promise<void> {
    const statusCell = this.page
      .locator("table tr")
      .nth(1)
      .locator("td")
      .nth(3)
      .locator("p");
    await expect(statusCell).toHaveText(status);
    await expect(statusCell).toHaveClass(new RegExp(`text-${textColor}`));
    await expect(statusCell).toHaveClass(new RegExp(`bg-${bgColor}`));
    await expect(statusCell).toHaveClass(/bg-opacity-20/);
    await expect(statusCell).toHaveClass(/rounded-full/);
  }

  async verifyActiveStatus(): Promise<void> {
    await this.verifyStatus("Active", "green-700", "green-700");
  }

  async verifyInviteStatus(): Promise<void> {
    await this.verifyStatus("InviteSent", "orange-950", "orange-950");
  }

  async verifyManageUserButton(): Promise<void> {
    await this.manageUserButton.click();
    await expect(this.page.locator('[data-button-for="update"]')).toBeAttached();
    await this.page.locator('[data-button-for="resend"]').click();
    await expect(this.page.locator('[data-button-for="delete"]')).toBeAttached();
  }

  async verifyUserDetails(
    userEmail: string,
    expectedRole: string,
    merchantType: string = "Test_merchant",
    profileType: string = "all_profiles",
  ): Promise<void> {
    await expect(this.page.locator("[data-breadcrumb]").nth(1)).toHaveText(
      userEmail,
    );
    const row = this.page.locator("table tr").nth(1);
    await expect(row.locator("td").nth(0)).toHaveText(merchantType);
    await expect(row.locator("td").nth(1)).toHaveText(profileType);
    await expect(row.locator("td").nth(2)).toHaveText(expectedRole);
    await expect(row.locator("td").nth(3).locator("p")).toHaveClass(
      /text-orange-950/,
    );
    await expect(this.manageUserButton).toBeAttached();
  }

  async updateUserRole(currentRole: string): Promise<void> {
    const dataValue = currentRole
      .toLowerCase()
      .replace(/\s+(.)/g, (_, c: string) => c.toUpperCase());
    await this.page.locator(`[data-value="${dataValue}"]`).click();

    const candidates = this.page.locator("[data-dropdown-value]");
    const count = await candidates.count();
    let chosen = "";
    for (let i = 0; i < count; i++) {
      const item = candidates.nth(i);
      const text = ((await item.textContent()) || "").trim();
      const selected = await item.getAttribute("data-dropdown-value-selected");
      if (text && !/[A-Z]/.test(text) && selected !== "true") {
        chosen = text;
        break;
      }
    }
    if (!chosen) {
      throw new Error("updateUserRole: no candidate role found");
    }

    await this.page.locator(`[data-dropdown-value="${chosen}"]`).click();
    await this.page.locator('[data-button-for="update"]').click();

    await this.usersTableRows.last().click();

    const newRoleDisplay = chosen
      .split("_")
      .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
      .join(" ");
    await expect(this.page.locator("td").nth(2)).toHaveText(newRoleDisplay);
  }

  async deleteUser(): Promise<void> {
    await this.manageUserButton.click();
    await this.page.locator('[data-button-for="delete"]').click();
    await this.page.locator('[data-button-for="confirm"]').click();
  }
}

export default UsersPage;
