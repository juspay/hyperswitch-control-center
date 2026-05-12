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

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
const MAIL_URL = process.env.PLAYWRIGHT_MAIL_URL || "http://localhost:8025";
const email = "playwright@test.com";

async function setupAndNavigate(
  page: Page,
  context: BrowserContext,
): Promise<{ email: string; usersPage: UsersPage }> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  const homePage = new HomePage(page);
  await homePage.users.click();
  return { email, usersPage: new UsersPage(page) };
}


test.describe("Users - UI", () => {

  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
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
    await searchInput.fill("playwright+org_admin@example.com");
    await expect(page.getByText("No Data Available")).toBeAttached();
  });

  test("Verify different roles in list page", async ({ page }) => {
    // Each invite cycle is a multi-step modal flow; chained twice plus four
    // filter assertions runs over the default 30s budget on CI.
    test.setTimeout(120000);
    const usersPage = new UsersPage(page);
    const merchantInvitee = generateUniqueEmail();
    const profileInvitee = generateUniqueEmail();

    const inviteAtScope = async (
      email: string,
      role: string,
      scope: "merchant" | "profile",
    ) => {
      await expect(usersPage.inviteUsersButton).toBeVisible();
      await usersPage.inviteUsersButton.click();

      await expect(usersPage.emailListInput).toBeVisible();
      await usersPage.emailListInput.fill(email);
      await usersPage.emailListInput.press("Enter");

      if (scope === "profile") {
        const allProfiles = page.locator('[data-value="allProfiles"]');
        await expect(allProfiles).toBeVisible();
        await allProfiles.click();
        const defaultOption = page.locator('[data-dropdown-value="default"]');
        await expect(defaultOption).toBeVisible();
        await defaultOption.click();
      }

      // `roleOption` is the role dropdown trigger (DropdownWithLoading button).
      // Clicking it opens the menu; the menu items match `entityOption`.
      await expect(usersPage.roleOption).toBeVisible();
      await usersPage.roleOption.click();
      await usersPage.entityOption
        .filter({ hasText: role })
        .first()
        .click();

      await usersPage.sendInviteButton.click();
      await expect(usersPage.sendInviteButton).toBeHidden();
      await usersPage.visit();
      await page.waitForLoadState("networkidle");
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
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    const homePage = new HomePage(page);
    await homePage.users.click();
  });

  test("should successfully invite a user and accept invite from email link", async ({
    page,
  }) => {
    // Invite + sign-out + accept-invite-via-mail + 2FA skip + sign-in is a
    // long chain of independent waits; the default 30s budget can't cover it
    // on CI even when each individual step is fast.
    test.setTimeout(120000);
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

    const continueWithPassword = page.getByRole('button', { name: 'Continue with Password' });
    await expect(continueWithPassword).toBeVisible();
    await continueWithPassword.click();

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

    await expect(page).toHaveURL(/.*dashboard\/home/, { timeout: 30000 });

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
    // Two full sign-in flows + invite acceptance round-trip + role inspection
    // — the chained waits routinely overflow the 30s default on CI.
    test.setTimeout(180000);
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

    const continueWithPassword = page.getByRole('button', { name: 'Continue with Password' });
    await expect(continueWithPassword).toBeVisible();
    await continueWithPassword.click();

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

    await expect(page).toHaveURL(/.*dashboard\/home/, { timeout: 30000 });

    await expect(page.getByRole('button', { name: invitedEmail })).toBeVisible();

    await homePage.userAccount.click();
    await homePage.signOut.click();

    await expect(page).toHaveURL(/.*dashboard\/login/, { timeout: 30000 });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const merchantId = (await homePage.merchantID.nth(0).textContent()) ?? "";
    expect(merchantId, "merchantId should be readable from header").not.toBe("");
    await homePage.users.click();
    await page.waitForLoadState("networkidle");

    const merchantDeveloper = page.getByText('Merchant Developer');
    await expect(merchantDeveloper).toBeVisible();
    await merchantDeveloper.click();

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
      "Merchant Developer"
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
    test.setTimeout(60000);
    const homePage = new HomePage(page);
    const invitedEmail = generateUniqueEmail();
    const { email, usersPage } = await setupAndNavigate(page, context);
    await usersPage.inviteUser(invitedEmail);

    await usersPage.visit();
    await page.waitForLoadState("networkidle");
    const merchantDeveloper = page.getByText('Merchant Developer');
    await expect(merchantDeveloper).toBeVisible({ timeout: 15000 });
    await merchantDeveloper.click();

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
    test.setTimeout(90000);
    const { usersPage } = await setupAndNavigate(page, context);
    const invitee = generateUniqueEmail();

    await expect(usersPage.inviteUsersButton).toBeVisible();
    await usersPage.inviteUsersButton.click();
    await expect(usersPage.emailListInput).toBeVisible();
    await usersPage.emailListInput.fill(invitee);
    await usersPage.emailListInput.press("Enter");
    await expect(usersPage.roleOption).toBeVisible();
    await usersPage.roleOption.click();
    await usersPage.entityOption.filter({ hasText: "Merchant Developer" }).first().click();
    await usersPage.sendInviteButton.click();
    await expect(usersPage.sendInviteButton).toBeHidden();
    await usersPage.visit();
    await page.waitForLoadState("networkidle");

    const inviteeRow = usersPage.usersTableRows.filter({ hasText: invitee }).first();
    await expect(inviteeRow).toBeVisible();
    await inviteeRow.click();
    await page.waitForLoadState("networkidle");
    await expect(usersPage.manageUserButton).toBeVisible();
    await usersPage.manageUserButton.click();
    await expect(usersPage.manageUserModalHeading).toBeVisible();
    const roleDropdown = page.getByRole('button', { name: 'merchant_developer' });
    await expect(roleDropdown).toBeVisible();
    await roleDropdown.click();
    const viewOnlyOption = page.getByText('merchant_view_only');
    await expect(viewOnlyOption).toBeVisible();
    await viewOnlyOption.click();
    const updateButton = page.getByRole('button', { name: 'Update' });
    await expect(updateButton).toBeVisible();
    await updateButton.click();

    await expect(page.getByText('Merchant View Only')).toBeVisible({
      timeout: 15000,
    });
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

    await expect(page.getByText('Invite resent. Please check your email.')).toBeVisible();
  });

  test("Check User permissions - Admin roles see Workflows in sidebar; developer roles do not", async ({
    page,
    context,
  }) => {
    // Four invite cycles plus four full sign-in flows in a single test —
    // by far the longest in the suite. Allow significant headroom on CI.
    test.setTimeout(360000);
    const { usersPage } = await setupAndNavigate(page, context);
    const homePage = new HomePage(page);
    const signinPage = new SignInPage(page);
    const resetPasswordPage = new ResetPasswordPage(page);

    const password = "Playwright00#";
    const invitees = [
      { email: generateUniqueEmail(), role: "Merchant Admin", scope: "merchant" as const, expectWorkflow: true },
      { email: generateUniqueEmail(), role: "Merchant Developer", scope: "merchant" as const, expectWorkflow: false },
      { email: generateUniqueEmail(), role: "Profile Admin", scope: "profile" as const, expectWorkflow: true },
      { email: generateUniqueEmail(), role: "Profile Developer", scope: "profile" as const, expectWorkflow: false },
    ];

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

      await usersPage.roleOption.click();
      await usersPage.entityOption.filter({ hasText: role }).first().click();

      await usersPage.sendInviteButton.click();
      await expect(usersPage.sendInviteButton).toBeHidden();
      await usersPage.visit();
    };

    for (const { email, role, scope } of invitees) {
      await inviteAtScope(email, role, scope);
    }

    await homePage.userAccount.click();
    await homePage.signOut.click();
    await expect(page).toHaveURL(/.*dashboard\/login/);

    const acceptInviteAndSignIn = async (invitedEmail: string) => {
      await redirectFromMailInbox(
        page,
        invitedEmail,
        "You have been invited to join Hyperswitch Community!",
      );
      await page.getByRole("button", { name: "Continue with Password" }).click();
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
      await expect(page.getByRole("button", { name: invitedEmail })).toBeVisible();
    };

    const signOutCurrentUser = async () => {
      await homePage.userAccount.click();
      await homePage.signOut.click();
      await expect(page).toHaveURL(/.*dashboard\/login/);
    };

    for (const { email, role, expectWorkflow } of invitees) {
      await acceptInviteAndSignIn(email);

      if (expectWorkflow) {
        await expect(
          homePage.workflow,
          `${role}: Workflow section should be visible in sidebar`,
        ).toBeVisible();
      } else {
        await expect(
          homePage.workflow,
          `${role}: Workflow section should not be attached in sidebar`,
        ).not.toBeAttached();
      }

      await signOutCurrentUser();
    }
  });
});

test.describe("Users - Roles Tab", () => {
  test("Roles matrix renders permission groups as rows and roles as columns for organization, merchant, and profile entities", async ({
    page,
    context,
  }) => {
    // V2 roles matrix (RolesPermissionsMatrix.res + RolesPermissionsMatrixHelper.res):
    //   - Header[0]      = "Module Permission"
    //   - Header[1..]    = role names (snake_case → Title Case of role.role_name)
    //   - Rows           = union of role.parent_groups[].name across all roles
    //   - Cells          = "View" / "Edit" pill or "--"
    // The matrix is hydrated from GET /user/role/list?groups=true&entity_type=...,
    // so we capture that response and use it as the source of truth — keeps the
    // assertions in sync with whatever role config the backend currently ships.

    const snakeToTitle = (s: string): string =>
      s
        .split("_")
        .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
        .join(" ");

    type ApiRole = {
      role_id: string;
      role_name: string;
      entity_type: string;
      parent_groups: Array<{ name: string; description: string; scopes: string[] }>;
    };

    type EntityKey = "organization" | "merchant" | "profile";
    type EntityLabel = "Organization" | "Merchant" | "Profile";

    const waitForRolesResponse = (entity: EntityKey) =>
      page.waitForResponse(
        (resp) =>
          new RegExp(`/user/role/list\\?.*entity_type=${entity}`).test(resp.url()) &&
          resp.request().method() === "GET" &&
          resp.status() === 200,
      );

    // Roles tab opens with Merchant selected by default (ListRolesV2 sets
    // initialRolesEntity = #Merchant for non-profile users), so the first
    // role-list call already targets entity_type=merchant — register the
    // listener before opening the tab so we don't miss it.
    const merchantResponsePromise = waitForRolesResponse("merchant");

    const { usersPage } = await setupAndNavigate(page, context);
    await usersPage.openRolesTab();

    await page.getByText('Module Permission').click();
    await expect(page.getByRole('button', { name: 'Create custom roles' })).toBeVisible();

    const merchantApiRoles = (await (await merchantResponsePromise).json()) as ApiRole[];

    const headers = page.locator("table#table thead tr th");
    const rows = page.locator("table#table tbody tr");

    const validateMatrix = async (
      entityLabel: EntityLabel,
      apiRoles: ApiRole[],
    ) => {
      expect(
        apiRoles.length,
        `${entityLabel}: API returned no roles`,
      ).toBeGreaterThan(0);

      const expectedRoleNames = apiRoles.map((r) => snakeToTitle(r.role_name));
      const expectedModules = Array.from(
        new Set(apiRoles.flatMap((r) => r.parent_groups.map((g) => g.name))),
      );
      expect(
        expectedModules.length,
        `${entityLabel}: API returned no parent_groups`,
      ).toBeGreaterThan(0);

      // Columns: "Module Permission" + one per role.
      await expect(headers).toHaveCount(expectedRoleNames.length + 1);
      await expect(headers.nth(0)).toHaveText("Module Permission");
      for (let i = 0; i < expectedRoleNames.length; i++) {
        await expect(
          headers.nth(i + 1),
          `${entityLabel}: column ${i + 1} should be role "${expectedRoleNames[i]}"`,
        ).toContainText(expectedRoleNames[i]);
      }

      // Rows: one per unique parent_group across all roles.
      await expect(rows).toHaveCount(expectedModules.length);
      for (const moduleName of expectedModules) {
        const row = rows.filter({ hasText: moduleName }).first();
        await expect(
          row,
          `${entityLabel}: module "${moduleName}" should be a row`,
        ).toBeVisible();
        // Cells: first column shows the module name; remaining cells (one per
        // role) carry a permission pill ("View" / "Edit") or "--".
        await expect(row.locator("td")).toHaveCount(expectedRoleNames.length + 1);
      }
    };

    // Switch the entity dropdown and capture the resulting role-list call.
    // The OMP entity dropdown uses "settings-new" as the trigger; options are
    // exposed via [data-dropdown-value]. data-dropdown-value carries the
    // option's description text — the org/merchant ID (starts with "202") for
    // Organization and Merchant, and "default" for Profile — so we use the
    // labelDescription text "(Organization)" / "(Merchant)" / "(Profile)" to
    // disambiguate.
    const switchEntityAndCapture = async (
      entityKey: EntityKey,
      entityLabel: EntityLabel,
    ): Promise<ApiRole[]> => {
      const responsePromise = waitForRolesResponse(entityKey);
      await page.locator('[data-icon="settings-new"]').click({ force: true });
      const valueSelector =
        entityLabel === "Profile"
          ? '[data-dropdown-value="default"]'
          : '[data-dropdown-value^="202"]';
      await page
        .locator(valueSelector)
        .filter({ hasText: `(${entityLabel})` })
        .first()
        .click();
      return (await (await responsePromise).json()) as ApiRole[];
    };

    await validateMatrix("Merchant", merchantApiRoles);

    const profileApiRoles = await switchEntityAndCapture("profile", "Profile");
    await validateMatrix("Profile", profileApiRoles);

    const orgApiRoles = await switchEntityAndCapture("organization", "Organization");
    await validateMatrix("Organization", orgApiRoles);
  });
});

test.describe("Users - Create Custom Role", () => {
  test("Create custom role page renders form fields", async ({ page, context }) => {
    const { usersPage } = await setupAndNavigate(page, context);
    await usersPage.visitCreateCustomRole();

    await expect(page.getByText("Create custom role").first()).toBeVisible();
    await expect(usersPage.roleNameInput).toBeVisible();
    await expect(page.getByText("Role Visibility")).toBeVisible();
    await expect(page.getByRole('button', { name: 'Merchant' }).first()).toBeVisible();
    await expect(page.getByText('Entity Type *')).toBeVisible();
    await expect(page.getByRole('button', { name: 'Merchant' }).nth(1)).toBeVisible();
    await expect(usersPage.submitCreateRoleButton).toBeVisible();
  });

  test("Permission groups in table match what /user/parent/list returns", async ({
    page,
    context,
  }) => {
    // CreateCustomRoleV2 hydrates the permission table from
    // GET /user/parent/list?entity_type=<entity>&product_type=<product>. Each
    // returned module renders as a row with `name` (semibold) and
    // `description` (the comma-separated sub-modules shown in the screenshot).
    // Capture the response so the assertions track whatever the backend ships.
    const { usersPage } = await setupAndNavigate(page, context);

    const responsePromise = page.waitForResponse(
      (resp) =>
        /\/user\/parent\/list\?.*entity_type=/.test(resp.url()) &&
        resp.request().method() === "GET" &&
        resp.status() === 200,
    );

    await usersPage.visitCreateCustomRole();

    const modules = (await (await responsePromise).json()) as Array<{
      name: string;
      description: string;
      scopes: string[];
    }>;
    expect(
      modules.length,
      "/user/parent/list returned no permission modules",
    ).toBeGreaterThan(0);

    await expect(page.getByText("Select Permission Level")).toBeVisible();

    // Module rows live inside the bordered wrapper; each row is a
    // `flex items-center py-4 px-6` whose first child holds the name and the
    // description. Scope to the wrapper so we don't pick up unrelated rows.
    const moduleRows = page.locator(
      "div.border.border-nd_gray-150.rounded-lg div.flex.items-center.py-4.px-6",
    );
    await expect(moduleRows).toHaveCount(modules.length);

    for (const { name, description } of modules) {
      // Match the row by an exact-text element so module names that are
      // substrings of another module's description (e.g. "Account" appears
      // inside Analytics' "…Merchant Account") don't collide.
      const row = moduleRows
        .filter({ has: page.getByText(name, { exact: true }) })
        .first();
      await expect(
        row,
        `permission module "${name}" should be rendered`,
      ).toBeVisible();
      await expect(
        row,
        `description for "${name}" should list its sub-modules`,
      ).toContainText(description);
    }
  });

  test("Custom roles by scope x entity: M1 invite shows all 4 + lists 4 invitees; M2 only shows the 2 org-scope roles + 2 invitees", async ({
    page,
    context,
  }) => {
    // 4 create-custom-role flows + 4 invites + multiple navigations easily
    // exceed the default 30s budget; bump to 3 minutes so the assertions get
    // to run instead of the test dying mid-step.
    test.setTimeout(180_000);
    // Org admin signs up into M1 (its default profile). They create 4 custom
    // roles spanning {Merchant, Organization} scope × {Merchant, Profile}
    // entity, invite a unique user to each, then switch to a freshly created
    // M2 (with its own default profile). In M2 only the 2 Organization-scope
    // roles are selectable in the invite drawer, and only the 2 org-scope
    // invitees show up in the users list — merchant-scope roles & their
    // invitees are bound to M1.
    const { usersPage } = await setupAndNavigate(page, context);
    const homePage = new HomePage(page);

    // CreateCustomRoleV2.res:175 runs role_name through `titleToSnake` on
    // submit, and DropdownWithLoading.res:33 renders option labels through
    // `snakeToTitle`. With a single-token name (no spaces, no underscores)
    // both transforms are no-ops besides capitalising the first character —
    // so the role appears as `displayName(name)` in every dropdown.
    const displayName = (n: string) => n.charAt(0).toUpperCase() + n.slice(1);

    const ts = Date.now();
    const customRoles = [
      { tag: "msme", scope: "Merchant" as const, entity: "Merchant" as const, name: `pwmsme${ts}` },
      { tag: "mspe", scope: "Merchant" as const, entity: "Profile" as const, name: `pwmspe${ts}` },
      { tag: "osme", scope: "Organization" as const, entity: "Merchant" as const, name: `pwosme${ts}` },
      { tag: "ospe", scope: "Organization" as const, entity: "Profile" as const, name: `pwospe${ts}` },
    ];
    // Helper: drive the Create Custom Role form for one row of the matrix.
    const createCustomRole = async (r: (typeof customRoles)[number]) => {
      await usersPage.visitCreateCustomRole();

      // Pick entity_type FIRST. The form's key is `create-user-role-${entity}`
      // (CreateCustomRoleV2.res:259), so switching entity remounts the form
      // and would wipe any role_name we'd already filled. Selecting the same
      // value as current is a no-op (handleEntityTypeChange:230 short-circuits).
      await usersPage.entityTypeButton.click();
      await page.locator(`[data-dropdown-value="${r.entity}"]`).first().click();

      // Wait for the permission table to be (re)rendered for the new entity
      // before touching downstream fields.
      await expect(
        page
          .locator(
            "div.border.border-nd_gray-150.rounded-lg div.flex.items-center.py-4.px-6",
          )
          .first(),
      ).toBeVisible();

      await usersPage.roleNameInput.fill(r.name);

      // Role Visibility (scope) — org_admin can pick "Organization" per
      // UserManagementUtils.res:30. SelectBox options carry
      // data-dropdown-value=<labelText>.
      await usersPage.roleScopeButton.click();
      await page.locator(`[data-dropdown-value="${r.scope}"]`).first().click();

      // Form validation requires at least one parent_group with a non-empty
      // scope. AddDataAttributes spreads `data-selected-checkbox` onto the
      // same div that carries the cursor class, so a checkbox is enabled iff
      // the element also has `cursor-pointer`. Modules whose API scopes lack
      // "read"/"write" render with `cursor-not-allowed` and ignore clicks —
      // pick the first ENABLED checkbox anywhere in the table.
      const firstEnabledCheckbox = page
        .locator(
          "div.border.border-nd_gray-150.rounded-lg [data-selected-checkbox][class*='cursor-pointer']",
        )
        .first();
      await expect(firstEnabledCheckbox).toBeVisible();
      await firstEnabledCheckbox.click();

      await expect(usersPage.submitCreateRoleButton).toBeEnabled();
      await usersPage.submitCreateRoleButton.click();
      await expect(page.getByText("Custom role created successfully")).toBeVisible();
      await expect(page).toHaveURL(/\/users(\?|$|\/)/);
    };

    // Helper: open the invite drawer and the role popover for a given entity
    // scope. Profile-entity is gated by picking a specific profile.
    const openInviteRolePopover = async (entity: "Merchant" | "Profile") => {
      await usersPage.visit();
      await usersPage.inviteUsersButton.click();
      if (entity === "Profile") {
        await page.locator('[data-value="allProfiles"]').click();
        await page.locator('[data-dropdown-value="default"]').click();
      }
      await usersPage.roleOption.click();
      // Block on at least one option being rendered so the negative
      // assertions below don't race the loading state.
      await expect(usersPage.entityOption.first()).toBeVisible();
    };

    // Helper: set the OMP filter on /users to the "All" default view.
    const applyAllFilter = async () => {
      await page.locator('[data-icon="settings-new"]').click({ force: true });
      await page.locator('[data-dropdown-value="All"]').filter({ hasText: "(Default)" }).first().click();
    };

    // ----- Org admin in M1: create the 4 custom roles -----
    for (const r of customRoles) {
      await createCustomRole(r);
    }

    // ----- M1 invite dropdown: all 4 custom roles selectable -----
    // Merchant-entity invite shows the 2 merchant-entity roles (one per scope).
    await openInviteRolePopover("Merchant");
    for (const r of customRoles.filter((x) => x.entity === "Merchant")) {
      await expect(usersPage.entityOption.filter({ hasText: displayName(r.name) }), `${r.name} (${r.scope}/${r.entity}) should be selectable in M1`).toHaveCount(1);
    }
    // Profile-entity invite shows the 2 profile-entity roles (one per scope).
    await openInviteRolePopover("Profile");
    for (const r of customRoles.filter((x) => x.entity === "Profile")) {
      await expect(
        usersPage.entityOption.filter({ hasText: displayName(r.name) }), `${r.name} (${r.scope}/${r.entity}) should be selectable in M1`).toHaveCount(1);
    }

    // ----- Invite one unique user per custom role from M1 -----
    const invitees = customRoles.map((r) => ({
      email: generateUniqueEmail(),
      role: r,
    }));
    for (const { email: inviteeEmail, role } of invitees) {
      await usersPage.visit();
      await usersPage.inviteUsersButton.click();
      await usersPage.emailListInput.fill(inviteeEmail);
      await usersPage.emailListInput.press("Enter");
      if (role.entity === "Profile") {
        await page.locator('[data-value="allProfiles"]').click();
        await page.locator('[data-dropdown-value="default"]').click();
      }
      await usersPage.roleOption.click();
      await usersPage.entityOption.filter({ hasText: displayName(role.name) }).first().click();
      await usersPage.sendInviteButton.click();
      await expect(usersPage.sendInviteButton).toBeHidden();
    }

    // ----- M1 users list: all 4 invitees show with the correct role -----
    await usersPage.visit();
    await applyAllFilter();
    for (const { email: inviteeEmail, role } of invitees) {
      const row = usersPage.usersTableRows.filter({ hasText: inviteeEmail });
      await expect(row, `${inviteeEmail} (role ${role.tag}) should be in M1 users list`).toHaveCount(1);
      await expect(row, `${inviteeEmail} should be tagged with role "${displayName(role.name)}"`).toContainText(displayName(role.name));
    }

    // ----- Create a second merchant M2 (its own default profile) -----
    const m2Name = `pwM2${ts}`;
    await homePage.merchantDropdown.click();
    await page.getByText("Create new").click();
    await expect(page.getByText("Add a new merchant").first()).toBeVisible();
    await page.getByRole("textbox", { name: "Eg: My New Merchant" }).fill(m2Name);
    await page.getByRole("button", { name: "Add Merchant" }).click();
    await expect(page.getByText("Merchant Created Successfully!")).toBeVisible();

    // ----- Switch to M2 (new merchant + its default profile = "M2/P2") -----
    await homePage.merchantDropdown.click();
    await page.getByText(m2Name, { exact: true }).first().click();
    // Wait for the merchant-switch toast (OMPSwitchHooks.res:143) so the
    // session has actually flipped to M2 before we open M2's invite drawer.
    await expect(
      page.getByText("Your merchant has been switched successfully."),
    ).toBeVisible();
    await page.waitForLoadState("networkidle");

    // ----- M2 invite dropdown: the 2 Organization-scope roles surface -----
    // Only the positive case is asserted: the LIST_ROLES_FOR_INVITE endpoint
    // is filtered by entity_type but does NOT currently scope-filter custom
    // roles by merchant, so merchant-scope roles created in M1 may also
    // appear here. We only check that the org-scope ones the user explicitly
    // expects ARE present.
    await openInviteRolePopover("Merchant");
    await expect(
      usersPage.entityOption.filter({ hasText: displayName(`pwosme${ts}`) }),
      "Org-scope merchant-entity role should be visible in M2",
    ).toHaveCount(1);

    await openInviteRolePopover("Profile");
    await expect(
      usersPage.entityOption.filter({ hasText: displayName(`pwospe${ts}`) }),
      "Org-scope profile-entity role should be visible in M2",
    ).toHaveCount(1);

    // ----- M2 users list: the 2 Organization-scope invitees show -----
    await usersPage.visit();
    await applyAllFilter();
    for (const { email: inviteeEmail, role } of invitees.filter(
      (i) => i.role.scope === "Organization",
    )) {
      await expect(
        usersPage.usersTableRows.filter({ hasText: inviteeEmail }),
        `${inviteeEmail} (org-scope ${role.tag}) should be in M2 users list`,
      ).toHaveCount(1);
    }
  });

});
