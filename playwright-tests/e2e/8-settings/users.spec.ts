import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { UsersPage } from "../../support/pages/settings/UsersPage";
import { SignInPage } from "../../support/pages/auth/SignInPage";
import { ResetPasswordPage } from "../../support/pages/auth/ResetPasswordPage";
import {
  generateUniqueEmail,
  getInvalidEmails,
  generateDateTimeString,
} from "../../support/helper";
import {
  signupUser,
  loginUI,
  redirectFromMailInbox,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";
const MAIL_URL = process.env.PLAYWRIGHT_MAIL_URL || "http://localhost:8025";
const email = "playwright@test.com";

async function setupAndNavigate(
  page: Page,
  context: BrowserContext,
): Promise<{ email: string; usersPage: UsersPage }> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  const homePage = new HomePage(page);
  await homePage.users.click();
  return { email, usersPage: new UsersPage(page) };
}


test.describe("Users - UI", () => {

  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    const homePage = new HomePage(page);
    await homePage.users.click();
  });

  test("Verify the UI of the Users page", async ({
    page,
  }) => {
    await expect(page.getByText('Team management')).toBeVisible();
    await expect(page.getByText('Users').nth(1)).toBeVisible();
    await expect(page.getByText('Roles')).toBeVisible();

    await expect(page.getByRole('textbox', { name: 'Search by name or email' })).toBeAttached();

    await page.locator('[data-icon="settings-new"]').click({ force: true });

    await expect(page.getByText('View data for:All')).toBeVisible();
    await expect(page.locator('[data-dropdown-value="All"]').filter({ hasText: "(Default)" })).toBeAttached();
    await expect(page.locator('[data-dropdown-value^="202"]').filter({ hasText: "(Organization)" })).toBeAttached();
    await expect(page.locator('[data-dropdown-value^="202"]').filter({ hasText: "(Merchant)" })).toBeAttached();
    await expect(page.locator('[data-dropdown-value="default"]').filter({ hasText: "(Profile)" })).toBeAttached();

    await expect(page.getByRole('button', { name: 'Invite users' })).toBeVisible();
    await expect(page.getByRole('button', { name: 'Invite users' })).toBeEnabled();
  });

  test("Search filters the users table by email", async ({ page, context }) => {
    const searchInput = page.getByRole('textbox', { name: 'Search by name or email' });
    await expect(searchInput).toBeAttached();

    await searchInput.fill("@test.com");
    await expect(page.locator("table#table tbody tr")).toHaveCount(1);
    await expect(page.locator('div').filter({ hasText: /^Email$/ }).first()).toBeVisible();
    await expect(page.getByRole('columnheader', { name: 'Role' })).toBeVisible();
    await expect(page.locator("table#table tbody tr").first().locator("td").first()).toContainText("@test.com");
    await expect(page.locator("table#table tbody tr").first().locator("td").first()).toBeAttached();
    await expect(page.locator('div').filter({ hasText: /^Organization Admin$/ }).first()).toBeVisible();
    await expect(page.locator('div').filter({ hasText: /^Organization Admin$/ }).first()).toBeAttached();

    await searchInput.clear();
    await searchInput.fill("cypress+org_admin@example.com");
    await expect(page.getByText("No Data Available")).toBeAttached();
  });

  test("Verify different roles in list page", async ({ page }) => {
    const usersPage = new UsersPage(page);
    const merchantInvitee = generateUniqueEmail();
    const profileInvitee = generateUniqueEmail();

    const inviteAtScope = async (
      email: string,
      role: string,
      scope: "merchant" | "profile",
    ) => {
      await usersPage.inviteUsersButton.click();

      await usersPage.emailListInput.fill(email);
      await usersPage.emailListInput.press("Enter");

      if (scope === "profile") {
        await page.locator('[data-value="allProfiles"]').click();
        await page.locator('[data-dropdown-value="default"]').click();
      }

      // `roleOption` is the role dropdown trigger (DropdownWithLoading button).
      // Clicking it opens the menu; the menu items match `entityOption`.
      await usersPage.roleOption.click();
      await usersPage.entityOption
        .filter({ hasText: role })
        .first()
        .click();

      await usersPage.sendInviteButton.click();
      await expect(usersPage.sendInviteButton).toBeHidden();
      await usersPage.visit();
    };

    // Invite one user at merchant scope and one at profile scope
    await inviteAtScope(merchantInvitee, "Merchant Developer", "merchant");
    await inviteAtScope(profileInvitee, "Profile Developer", "profile");

    // Default view: Org Admin (logged-in user) + 2 invitees = 3 rows
    const rows = page.locator("table#table tbody tr");
    await expect(rows).toHaveCount(3);
    await expect(
      rows.filter({ hasText: "Organization Admin" }),
    ).toHaveCount(1);
    await expect(
      rows
        .filter({ hasText: merchantInvitee })
        .filter({ hasText: "Merchant Developer" }),
    ).toHaveCount(1);
    await expect(
      rows
        .filter({ hasText: profileInvitee })
        .filter({ hasText: "Profile Developer" }),
    ).toHaveCount(1);

    const applyFilter = async (filterLabel: string) => {
      await page
        .locator('[data-icon="settings-new"]')
        .click({ force: true });
      const valueSelector =
        filterLabel === "(Default)"
          ? '[data-dropdown-value="All"]'
          : filterLabel === "(Profile)"
            ? '[data-dropdown-value="default"]'
            : '[data-dropdown-value^="202"]';
      await page
        .locator(valueSelector)
        .filter({ hasText: filterLabel })
        .first()
        .click();
    };

    // Filter by Organization → Org Admin shows
    await applyFilter("(Organization)");
    await expect(
      rows.filter({ hasText: "Organization Admin" }),
    ).toHaveCount(1);

    // Filter by Merchant → Merchant Developer shows with the right role
    await applyFilter("(Merchant)");
    await expect(
      rows
        .filter({ hasText: merchantInvitee })
        .filter({ hasText: "Merchant Developer" }),
    ).toHaveCount(1);

    // Filter by Profile → Profile Developer shows with the right role
    await applyFilter("(Profile)");
    await expect(
      rows
        .filter({ hasText: profileInvitee })
        .filter({ hasText: "Profile Developer" }),
    ).toHaveCount(1);

    // Reset to default view → all 3 rows visible again
    await applyFilter("(Default)");
    await expect(rows).toHaveCount(3);
  });
});

test.describe("Users - Invite Users", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    const homePage = new HomePage(page);
    await homePage.users.click();
  });

  test("should successfully invite a user and accept invite from email link", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const usersPage = new UsersPage(page);
    const signinPage = new SignInPage(page);
    const resetPasswordPage = new ResetPasswordPage(page);
    const invitedEmail = generateUniqueEmail();
    const password = "Playwright00#";

    await homePage.users.click();
    await usersPage.inviteUser(invitedEmail);

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await redirectFromMailInbox(page, invitedEmail, "You have been invited to join Hyperswitch Community!");

    await page.getByRole('button', { name: 'Continue with Password' }).click();

    await signinPage.skip2FAButton.click();

    await resetPasswordPage.createPassword.fill(password);
    await resetPasswordPage.confirmPassword.fill(password);
    await resetPasswordPage.confirmButton.click();

    await signinPage.emailInput.fill(invitedEmail);
    await signinPage.passwordInput.fill(password);
    await signinPage.signinButton.click();
    await expect(signinPage.headerText2FA).toContainText(
      "Enable Two Factor Authentication",
    );
    await signinPage.skip2FAButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/);

    await expect(page.getByRole('button', { name: invitedEmail })).toBeVisible();

  });

  test("should redirect to login when accepting invite with an invalid or expired token", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const usersPage = new UsersPage(page);
    const invitedEmail = generateUniqueEmail();

    await homePage.users.click();
    await usersPage.inviteUser(invitedEmail);

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await page.goto(MAIL_URL);
    await page.locator('[id="search"]').fill(invitedEmail);
    await page.locator('[id="search"]').press("Enter");
    await page
      .locator("div.msglist-message")
      .filter({ hasText: "You have been invited to join Hyperswitch Community" })
      .filter({ hasText: invitedEmail })
      .first()
      .click();
    await page.waitForTimeout(1000);

    const iframe = page.locator("iframe").first().contentFrame();
    const verifyLink = await iframe.locator("a").first().getAttribute("href");
    const tamperedLink = verifyLink!.replace(/token=[^&]+/, "token=abcd");
    await page.goto(tamperedLink);

    await expect(page).toHaveURL(/.*login/);
    await expect(page.getByTestId('card-header')).toHaveText("Hey there, Welcome back!");
  });

  test("should accept multiple emails as pills in invite list", async ({
    page,
    context,
  }) => {
    const usersPage = new UsersPage(page);
    const email1 = generateUniqueEmail();
    const email2 = generateUniqueEmail();

    await usersPage.inviteUsersButton.click();

    await usersPage.emailListInput.fill(email1);
    await usersPage.emailListInput.press("Enter");
    await usersPage.emailListInput.fill(email2);
    await usersPage.emailListInput.press("Enter");

    await expect(page.getByText(email1).first()).toBeVisible();
    await expect(page.getByText(email2).first()).toBeVisible();
  });

  test("Send Invite button is disabled when invite list is empty", async ({
    page,
    context,
  }) => {
    const usersPage = new UsersPage(page);

    await usersPage.inviteUsersButton.click();
    await expect(usersPage.sendInviteButton).toBeDisabled();
  });

  test("Hovering on disabled Send Invite surfaces validation tooltip for missing email and role", async ({
    page,
  }) => {
    const usersPage = new UsersPage(page);

    await usersPage.inviteUsersButton.click();

    await expect(usersPage.sendInviteButton).toBeDisabled();
    await usersPage.sendInviteButton.hover();

    const tooltip = page.getByRole("tooltip");
    await expect(tooltip).toContainText("Email List: Please enter a Email List");
    await expect(tooltip).toContainText("Role Id: Please enter a Role Id");
  });

  test("Verify available roles and permission groups for each entity scope", async ({
    page,
  }) => {
    const usersPage = new UsersPage(page);
    await usersPage.inviteUsersButton.click();

    // For each role, the form fetches role details from `/user/role/{id}/v2`
    // and renders the returned `parent_groups` as accessible (highlighted),
    // any other module from the global module list as disabled (greyed out
    // with `text-grey-200`). We capture that API response per role and use
    // it as the canonical mapping, so the test stays in sync with whatever
    // role config the backend ships.
    const selectRoleAndVerifyPermissions = async (role: string) => {
      const responsePromise = page.waitForResponse(
        (resp) =>
          /\/user\/role\/[^/]+\/v2(\?|$)/.test(resp.url()) &&
          resp.request().method() === "GET" &&
          resp.status() === 200,
      );

      await usersPage.merchantDropdown.click();
      await usersPage.roleOption.click();
      await usersPage.entityOption.filter({ hasText: role }).first().click();

      const response = await responsePromise;
      const roleData = await response.json();
      const expectedAccessible: string[] = (roleData.parent_groups ?? []).map(
        (g: { name?: string }) => g?.name ?? "",
      );
      expect(
        expectedAccessible.length,
        `${role}: API returned no parent_groups`,
      ).toBeGreaterThan(0);

      await expect(
        page.getByText(new RegExp(`Role Description - '${role}'`)).first(),
      ).toBeVisible();

      const descriptionCard = page
        .locator("div.border.rounded-md.p-4.flex.flex-col")
        .first();
      await expect(descriptionCard).toBeVisible();

      // Each module row is a `div.flex.justify-between`; first <p> is the
      // parent group name. Disabled rows also carry `text-grey-200`.
      const moduleRows = descriptionCard.locator("div.flex.justify-between");
      const totalCount = await moduleRows.count();
      expect(totalCount).toBeGreaterThan(0);

      const renderedGroups: string[] = [];
      for (let i = 0; i < totalCount; i++) {
        const text = (
          await moduleRows.nth(i).locator("p").first().textContent()
        )?.trim();
        if (text) renderedGroups.push(text);
      }

      // Every accessible group from the API must be rendered and NOT greyed.
      for (const groupName of expectedAccessible) {
        expect(
          renderedGroups,
          `${role}: parent group "${groupName}" should be rendered`,
        ).toContain(groupName);

        const groupRow = moduleRows
          .filter({ has: page.getByText(groupName, { exact: true }) })
          .first();
        await expect(
          groupRow,
          `${role}: "${groupName}" should be highlighted (accessible)`,
        ).not.toHaveClass(/text-grey-200/);
      }

      // Every other rendered parent group must be greyed out.
      const expectedDisabled = renderedGroups.filter(
        (group) => !expectedAccessible.includes(group),
      );
      for (const groupName of expectedDisabled) {
        const groupRow = moduleRows
          .filter({ has: page.getByText(groupName, { exact: true }) })
          .first();
        await expect(
          groupRow,
          `${role}: "${groupName}" should be disabled (greyed out)`,
        ).toHaveClass(/text-grey-200/);
      }
    };

    // Merchant scope (default): verify merchant-level roles
    const merchantRoles = [
      "Merchant Admin",
      "Customer Support",
      "Merchant Developer",
      "Merchant Operator",
      "Merchant View Only",
      "Merchant Iam",
    ];
    for (const role of merchantRoles) {
      await selectRoleAndVerifyPermissions(role);
    }

    // Profile scope: switch profile to "default" and verify profile-level roles
    await page.locator('[data-value="allProfiles"]').click();
    await page.locator('[data-dropdown-value="default"]').click();
    const profileRoles = [
      "Profile Admin",
      "Profile Customer Support",
      "Profile Developer",
      "Profile Operator",
      "Profile View Only",
      "Profile Iam",
    ];
    for (const role of profileRoles) {
      await selectRoleAndVerifyPermissions(role);
    }

    // Organization scope: switch merchant to "All merchants" and verify org admin role
    await usersPage.merchantDropdown.click();
    await page.locator('[data-dropdown-value="All merchants"]').click();
    await selectRoleAndVerifyPermissions("Organization Admin");
  });
})

test.describe("Users - Details", () => {
  test("Verify the UI of the User Details page - Same user details", async ({ page, context }) => {
    const { email, usersPage } = await setupAndNavigate(page, context);
    await page.locator("table#table tbody tr").click();

    await expect(page.getByRole('link', { name: 'Navigate to Team management' })).toBeVisible();
    await expect(page.getByLabel('Current page: playwright-')).toBeVisible();

    await usersPage.verifyUserDetailsUsernameDisplay(email);
    await usersPage.verifyUserDetailsEmailDisplay(email);

    await expect(page.locator("table")).toBeAttached();
    await expect(page.locator("table th")).toHaveCount(5);

    const headers = page.locator("table th");
    await expect(headers.filter({ hasText: "Merchants" })).toHaveCount(1);
    await expect(headers.filter({ hasText: "Profile Name" })).toHaveCount(1);
    await expect(headers.filter({ hasText: "Role" })).toHaveCount(1);
    await expect(headers.filter({ hasText: "Status" })).toHaveCount(1);

    await usersPage.verifyUserDetailsTableRowContent(
      "All_merchants",
      "all_profiles",
      "Organization Admin",
    );
    await usersPage.verifyActiveStatus();
    await expect(page.getByRole('button', { name: 'Manage user' })).not.toBeAttached();
  });

  test("Verify the UI of the User Details page - Other user details", async ({ page, context }) => {
    const { email, usersPage } = await setupAndNavigate(page, context);

    const homePage = new HomePage(page);
    const signinPage = new SignInPage(page);
    const resetPasswordPage = new ResetPasswordPage(page);
    const invitedEmail = generateUniqueEmail();
    const password = "Playwright00#";

    await homePage.users.click();
    await usersPage.inviteUser(invitedEmail);

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await redirectFromMailInbox(page, invitedEmail, "You have been invited to join Hyperswitch Community!");

    await page.getByRole('button', { name: 'Continue with Password' }).click();

    await signinPage.skip2FAButton.click();

    await resetPasswordPage.createPassword.fill(password);
    await resetPasswordPage.confirmPassword.fill(password);
    await resetPasswordPage.confirmButton.click();

    await signinPage.emailInput.fill(invitedEmail);
    await signinPage.passwordInput.fill(password);
    await signinPage.signinButton.click();
    await expect(signinPage.headerText2FA).toContainText(
      "Enable Two Factor Authentication",
    );
    await signinPage.skip2FAButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/);

    await expect(page.getByRole('button', { name: invitedEmail })).toBeVisible();

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await expect(page).toHaveURL(/.*dashboard\/login/);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const merchantId = (await homePage.merchantID.nth(0).textContent()) ?? "";
    expect(merchantId, "merchantId should be readable from header").not.toBe("");
    await homePage.users.click();

    await page.getByText('Merchant Operator').click();

    await expect(page.getByRole('link', { name: 'Navigate to Team management' })).toBeVisible();
    await expect(page.getByLabel(`Current page: ${invitedEmail}`)).toBeVisible();

    await usersPage.verifyUserDetailsUsernameDisplay(invitedEmail);
    await usersPage.verifyUserDetailsEmailDisplay(invitedEmail);

    await expect(page.locator("table")).toBeAttached();
    await expect(page.locator("table th")).toHaveCount(5);

    const headers = page.locator("table th");
    await expect(headers.filter({ hasText: "Merchants" })).toHaveCount(1);
    await expect(headers.filter({ hasText: "Profile Name" })).toHaveCount(1);
    await expect(headers.filter({ hasText: "Role" })).toHaveCount(1);
    await expect(headers.filter({ hasText: "Status" })).toHaveCount(1);

    await usersPage.verifyUserDetailsTableRowContent(
      merchantId,
      "all_profiles",
      "Merchant Operator"
    );
    await usersPage.verifyActiveStatus();
    await expect(page.getByRole('button', { name: 'Manage user' })).toBeVisible();
  });

  test("Verify the UI of the User Details page - Different merchant context", async ({
    page,
    context,
  }) => {
    const { email, usersPage } = await setupAndNavigate(page, context);

    const homePage = new HomePage(page);
    const signinPage = new SignInPage(page);
    const resetPasswordPage = new ResetPasswordPage(page);
    const invitedEmail = generateUniqueEmail();
    const password = "Playwright00#";
    const newMerchantName = `pwMerchant${Date.now()}`;

    await page.getByRole('link', { name: 'Overview' }).click();
    // Capture the merchant the org admin signed up into (M1).
    const originalMerchantId = (await homePage.merchantID.nth(0).textContent()) ?? "";
    expect(originalMerchantId, "originalMerchantId should be readable").not.toBe("");

    // Org admin creates a second merchant (M2) before inviting the user. The
    // create flow refreshes the merchant list but does not auto-switch, so the
    // admin stays on M1 and the invite below lands on M1.
    await homePage.merchantDropdown.click();
    await page.getByText("Create new").click();
    await expect(page.getByText("Add a new merchant").first()).toBeVisible();
    await page.getByRole("textbox", { name: "Eg: My New Merchant" }).fill(newMerchantName);
    await page.getByRole("button", { name: "Add Merchant" }).click();
    await expect(page.getByText("Merchant Created Successfully!")).toBeVisible();
    await homePage.merchantDropdown.click();

    // Invite the user from M1.
    await homePage.users.click();
    await usersPage.inviteUser(invitedEmail);

    // Switch to M2 — the merchant the invitee is NOT a member of.
    await homePage.merchantDropdown.click();
    await page.getByText(newMerchantName, { exact: true }).first().click();

    // From M2's context, view all org users so the M1 invitee is visible.
    await usersPage.usersTableRows.filter({ hasText: invitedEmail }).first().click();

    await expect(page.getByRole("link", { name: "Navigate to Team management" })).toBeVisible();
    await expect(page.getByLabel(`Current page: ${invitedEmail}`)).toBeVisible();

    await expect(page.getByRole("button", { name: "Switch to update" })).toBeVisible();
    await expect(page.getByRole("button", { name: "Manage user" })).not.toBeAttached();

    await page.getByRole('button', { name: 'Switch to update' }).click();

    await expect(page.getByRole("button", { name: "Switch to update" })).not.toBeAttached();
    await expect(page.getByRole("button", { name: "Manage user" })).toBeVisible();

    await expect(page.getByText(`Merchant Account${originalMerchantId}`)).toBeVisible()
  });

  test("Manage user modal renders with user data and action sections", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const invitedEmail = generateUniqueEmail();
    const { email, usersPage } = await setupAndNavigate(page, context);
    await usersPage.inviteUser(invitedEmail);

    await page.goBack();
    await page.getByText('Merchant Operator').click();

    await expect(page.getByText('InviteSent')).toBeVisible();

    await expect(usersPage.manageUserButton).toBeVisible();
    await usersPage.manageUserButton.click();

    await expect(usersPage.manageUserModalHeading).toBeVisible();
    await expect(page.getByText("Change user role")).toBeVisible();
    await expect(page.getByText("Resend invite", { exact: true })).toBeVisible();
    await expect(page.getByText("Delete user role")).toBeVisible();
    await expect(usersPage.updateRoleButton).toBeVisible();
    await expect(usersPage.resendInviteButton).toBeVisible();
    await expect(usersPage.deleteUserButton).toBeVisible();
  });

  test("Updating role from modal calls update API and reflects in user list", async ({
    page,
    context,
  }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    const invitee = generateUniqueEmail();

    await usersPage.inviteUsersButton.click();
    await usersPage.emailListInput.fill(invitee);
    await usersPage.emailListInput.press("Enter");
    await usersPage.roleOption.click();
    await usersPage.entityOption.filter({ hasText: "Merchant Developer" }).first().click();
    await usersPage.sendInviteButton.click();
    await expect(usersPage.sendInviteButton).toBeHidden();
    await usersPage.visit();

    await usersPage.usersTableRows.filter({ hasText: invitee }).first().click();
    await usersPage.manageUserButton.click();
    await expect(usersPage.manageUserModalHeading).toBeVisible();
    await page.getByRole('button', { name: 'merchant_developer' }).click();
    await page.getByText('merchant_view_only').click();
    await page.getByRole('button', { name: 'Update' }).click();

    await expect(page.getByText('Merchant View Only')).toBeVisible();
  });

  test("Delete user from modal removes them from the users list", async ({
    page,
    context,
  }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    const invitee = generateUniqueEmail();

    await usersPage.inviteUsersButton.click();
    await usersPage.emailListInput.fill(invitee);
    await usersPage.emailListInput.press("Enter");
    await usersPage.roleOption.click();
    await usersPage.entityOption.filter({ hasText: "Merchant Developer" }).first().click();
    await usersPage.sendInviteButton.click();
    await expect(usersPage.sendInviteButton).toBeHidden();
    await usersPage.visit();

    await usersPage.usersTableRows.filter({ hasText: invitee }).first().click();
    await usersPage.manageUserButton.click();
    await expect(usersPage.manageUserModalHeading).toBeVisible();

    await usersPage.deleteUserButton.click();
    await expect(
      page.getByText("Are you sure you want to delete this user?"),
    ).toBeVisible();

    await usersPage.confirmDeleteButton.click();
    await expect(page).toHaveURL(/.*\/users(\?|$|\/)/);
    await expect(usersPage.usersTableRows.filter({ hasText: invitee })).toHaveCount(0);
  });

  test("Resend invite to pending invite user from modal", async ({
    page,
    context,
  }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    const invitee = generateUniqueEmail();

    await usersPage.inviteUsersButton.click();
    await usersPage.emailListInput.fill(invitee);
    await usersPage.emailListInput.press("Enter");
    await usersPage.roleOption.click();
    await usersPage.entityOption.filter({ hasText: "Merchant Developer" }).first().click();
    await usersPage.sendInviteButton.click();
    await expect(usersPage.sendInviteButton).toBeHidden();
    await usersPage.visit();

    await usersPage.usersTableRows.filter({ hasText: invitee }).first().click();
    await usersPage.manageUserButton.click();
    await expect(usersPage.manageUserModalHeading).toBeVisible();

    await usersPage.resendInviteButton.click();

    await expect(page.getByText('Invite resend. Please check')).toBeVisible();
  });
});

test.describe("Users - Roles Tab", () => {
  test("Roles tab displays the role list with expected columns", async ({
    page,
    context,
  }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    await usersPage.openRolesTab();

    const headers = page.locator("table#table thead tr th");
    await expect(headers.nth(0)).toHaveText("Role name");
    await expect(headers.nth(1)).toHaveText("Entity Type");
    await expect(headers.nth(2)).toHaveText("Module permissions");

    expect(await page.locator("table#table tbody tr").count()).toBeGreaterThan(0);
  });

  test("Create custom roles button navigates to create custom role page", async ({
    page,
    context,
  }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    await usersPage.openRolesTab();

    await expect(usersPage.createCustomRoleButton).toBeVisible();
    await usersPage.createCustomRoleButton.click();

    await expect(page).toHaveURL(/.*\/users\/create-custom-role/);
  });

  test("Clicking a role row reveals role details", async ({ page, context }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    await usersPage.openRolesTab();

    const firstRow = page.locator("table#table tbody tr").first();
    await firstRow.click();

    await expect(page.locator("[data-breadcrumb]").first()).toBeVisible();
  });
});

test.describe("Users - Create Custom Role", () => {
  test("Create custom role page renders form fields", async ({ page, context }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    await usersPage.visitCreateCustomRole();

    await expect(page.getByText("Create custom role").first()).toBeVisible();
    await expect(usersPage.roleNameInput).toBeVisible();
    await expect(page.getByText("Role Visibility")).toBeVisible();
    await expect(usersPage.submitCreateRoleButton).toBeVisible();
  });

  test("Role name input accepts user input", async ({ page, context }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    await usersPage.visitCreateCustomRole();

    const roleName = "Test Custom Role";
    await usersPage.roleNameInput.fill(roleName);
    await expect(usersPage.roleNameInput).toHaveValue(roleName);
  });

  test("Permissions matrix renders module groups", async ({ page, context }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    await usersPage.visitCreateCustomRole();
    await page.waitForLoadState("networkidle");

    const expectedModules = [
      "Payment",
      "Refund",
      "Dispute",
      "Customer",
      "Connector",
    ];
    for (const module of expectedModules) {
      await expect(
        page.locator("div.font-semibold").filter({ hasText: module }).first(),
      ).toBeVisible();
    }
  });

  test("Selecting and deselecting a permission group toggles state", async ({
    page,
    context,
  }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    await usersPage.visitCreateCustomRole();
    await page.waitForLoadState("networkidle");

    const paymentGroup = page
      .locator("div.cursor-pointer")
      .filter({ hasText: "Payment" })
      .first();

    await paymentGroup.click();
    await paymentGroup.click();
  });

  test("Create custom role validates missing role name", async ({
    page,
    context,
  }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    await usersPage.visitCreateCustomRole();
    await page.waitForLoadState("networkidle");

    await usersPage.submitCreateRoleButton.click();
    await expect(page.getByText("Role name is required").first()).toBeVisible();
  });

  test("Submitting a valid custom role redirects back to users", async ({
    page,
    context,
  }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    await usersPage.visitCreateCustomRole();
    await page.waitForLoadState("networkidle");

    const uniqueRoleName = `Playwright Role ${Date.now()}`;
    await usersPage.roleNameInput.fill(uniqueRoleName);

    await page
      .locator("div.cursor-pointer")
      .filter({ hasText: "Payment" })
      .first()
      .click();

    await usersPage.submitCreateRoleButton.click();

    await expect(page).toHaveURL(/.*\/users(\?|$|\/)/);
  });
});
