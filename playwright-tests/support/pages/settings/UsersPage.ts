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
      '[class="relative inline-flex items-center whitespace-pre leading-5 justify-between text-sm py-2 px-3 font-medium rounded-lg hover:bg-opacity-80 bg-white border w-full"]',
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
    return this.page.getByRole("tab", { name: "Roles" });
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

  get teamManagementText(): Locator {
    return this.page.getByText("Team management");
  }

  get usersTabText(): Locator {
    return this.page.getByText("Users").nth(1);
  }

  get rolesText(): Locator {
    return this.page.getByText("Roles");
  }

  get searchInput(): Locator {
    return this.page.getByRole("textbox", { name: "Search by name or email" });
  }

  get settingsNewIcon(): Locator {
    return this.page.locator('[data-icon="settings-new"]');
  }

  get viewDataForText(): Locator {
    return this.page.getByText("View data for:All");
  }

  get defaultFilterOption(): Locator {
    return this.page
      .locator('[data-dropdown-value="All"]')
      .filter({ hasText: "(Default)" });
  }

  get organizationFilterOption(): Locator {
    return this.page
      .locator('[data-dropdown-value^="playwright_"]')
      .filter({ hasText: "(Organization)" });
  }

  get merchantFilterOption(): Locator {
    return this.page
      .locator('[data-dropdown-value^="playwright_"]')
      .filter({ hasText: "(Merchant)" });
  }

  get profileFilterOption(): Locator {
    return this.page
      .locator('[data-dropdown-value="default"]')
      .filter({ hasText: "(Profile)" });
  }

  get inviteUsersRoleButton(): Locator {
    return this.page.getByRole("button", { name: "Invite users" });
  }

  get emailColumnHeader(): Locator {
    return this.page
      .locator("div")
      .filter({ hasText: /^Email$/ })
      .first();
  }

  get roleColumnHeader(): Locator {
    return this.page.getByRole("columnheader", { name: "Role" });
  }

  get organizationAdminColumnText(): Locator {
    return this.page
      .locator("div")
      .filter({ hasText: /^Organization Admin$/ })
      .first();
  }

  get noDataAvailableText(): Locator {
    return this.page.getByText("No Data Available");
  }

  get testMerchantValue(): Locator {
    return this.page.locator('[data-value="testMerchant"]');
  }

  get allMerchantsDropdownValue(): Locator {
    return this.page.locator('[data-dropdown-value="All merchants"]');
  }

  get allProfilesValue(): Locator {
    return this.page.locator('[data-value="allProfiles"]');
  }

  get defaultDropdownValue(): Locator {
    return this.page.locator('[data-dropdown-value="default"]');
  }

  get navigateToTeamManagementLink(): Locator {
    return this.page.getByRole("link", { name: "Navigate to Team management" });
  }

  currentPageBreadcrumb(label: string): Locator {
    return this.page.getByLabel(`Current page: ${label}`);
  }

  get table(): Locator {
    return this.page.locator("table");
  }

  get tableHeaders(): Locator {
    return this.page.locator("table th");
  }

  get tableMatrixHeaders(): Locator {
    return this.page.locator("table#table thead tr th");
  }

  get manageUserRoleButton(): Locator {
    return this.page.getByRole("button", { name: "Manage user" });
  }

  get switchToUpdateButton(): Locator {
    return this.page.getByRole("button", { name: "Switch to update" });
  }

  get inviteSentText(): Locator {
    return this.page.getByText("InviteSent");
  }

  get changeUserRoleText(): Locator {
    return this.page.getByText("Change user role");
  }

  get resendInviteText(): Locator {
    return this.page.getByText("Resend invite", { exact: true });
  }

  get deleteUserRoleText(): Locator {
    return this.page.getByText("Delete user role");
  }

  get merchantDeveloperText(): Locator {
    return this.page.getByText("Merchant Developer");
  }

  get merchantViewOnlyText(): Locator {
    return this.page.getByText("Merchant View Only");
  }

  get merchantDeveloperRoleDropdown(): Locator {
    return this.page.getByRole("button", { name: "merchant_developer" });
  }

  get merchantViewOnlyOption(): Locator {
    return this.page.getByText("merchant_view_only");
  }

  get updateRoleButtonByRole(): Locator {
    return this.page.getByRole("button", { name: "Update" });
  }

  get areYouSureDeleteText(): Locator {
    return this.page.getByText("Are you sure you want to delete this user?");
  }

  get inviteResentText(): Locator {
    return this.page.getByText("Invite resent. Please check your email.");
  }

  get merchantSwitchedSuccessText(): Locator {
    return this.page.getByText("Your merchant has been switched successfully.");
  }

  get profileSwitchedSuccessText(): Locator {
    return this.page.getByText("Your profile has been switched successfully.");
  }

  get merchantSwitchFailedText(): Locator {
    return this.page.getByText("Failed to switch merchant");
  }

  get profileSwitchFailedText(): Locator {
    return this.page.getByText("Failed to switch profile");
  }

  get merchantCreatedSuccessText(): Locator {
    return this.page.getByText("Merchant Created Successfully!");
  }

  get addNewMerchantText(): Locator {
    return this.page.getByText("Add a new merchant").first();
  }

  get createNewText(): Locator {
    return this.page.getByText("Create new");
  }

  get modulePermissionText(): Locator {
    return this.page.getByText("Module Permission");
  }

  get createCustomRoleHeader(): Locator {
    return this.page.getByText("Create custom role").first();
  }

  get roleVisibilityText(): Locator {
    return this.page.getByText("Role Visibility");
  }

  get entityTypeRequiredText(): Locator {
    return this.page.getByText("Entity Type *");
  }

  get selectPermissionLevelText(): Locator {
    return this.page.getByText("Select Permission Level");
  }

  get customRoleCreatedText(): Locator {
    return this.page.getByText("Custom role created successfully");
  }

  merchantButton(index: number = 0): Locator {
    return this.page.getByRole("button", { name: "Merchant" }).nth(index);
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
    await this.page.getByRole("link", { name: "Users" }).click();
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
    await expect(
      this.page.locator('[data-button-for="update"]'),
    ).toBeAttached();
    await this.page.locator('[data-button-for="resend"]').click();
    await expect(
      this.page.locator('[data-button-for="delete"]'),
    ).toBeAttached();
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
