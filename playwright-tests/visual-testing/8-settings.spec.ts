import { test, expect } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  mockV2MerchantList,
  createDummyConnectorAPI,
} from "../support/commands";
import { HomePage } from "../support/pages/homepage/HomePage";
import { ConfigurePMTPage } from "../support/pages/settings/ConfigurePMTPage";
import { OrganizationSettingsPage } from "../support/pages/settings/OrganizationSettingsPage";
import { UsersPage } from "../support/pages/settings/UsersPage";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Visual Testing - Settings", () => {
  test.describe("Configure PMTs", () => {
    test("configure pmts page should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const configurePMT = new ConfigurePMTPage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.settings.click();
      await homePage.configurePMT.click();
      await page.waitForLoadState("networkidle");

      // A fresh org has no configured connectors, so the page renders its
      // heading + the "No Data Available" empty state.
      await expect(configurePMT.pageHeading).toBeVisible({ timeout: 10000 });
      await expect(configurePMT.noDataMessage).toBeVisible({ timeout: 10000 });

      await expect(page).toHaveScreenshot("settings-configure-pmts-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        // Sidebar/top-bar carry the per-run merchant id & name.
        mask: [
          homePage.navHeaderMask,
          homePage.merchantNameButton,
          homePage.merchantID,
        ],
      });
    });

    test("configure pmts page with a configured payin connector should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const configurePMT = new ConfigurePMTPage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      // The merchant ID is only known after login; wait for the sidebar to
      // render it, then seed a payin (payment_processor) connector against it
      // via the API so the page renders a populated payment-methods table.
      await homePage.merchantID
        .nth(0)
        .waitFor({ state: "visible", timeout: 20000 });
      const merchantId = (
        await homePage.merchantID.nth(0).textContent()
      )?.trim();
      if (!merchantId) {
        throw new Error("Could not read merchant ID after login");
      }
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_pmt",
        context.request,
      );

      await homePage.settings.click();
      await homePage.configurePMT.click();
      await page.waitForLoadState("networkidle");

      await expect(configurePMT.pageHeading).toBeVisible({ timeout: 10000 });
      // The seeded connector is eventually consistent on the list endpoint, so
      // reload until its row appears.
      await configurePMT.waitForConnectorRow("stripe_test");

      const chromeMask = [
        homePage.navHeaderMask,
        homePage.merchantNameButton,
        homePage.merchantID,
      ];

      // Snapshot the populated PMT list.
      await expect(page).toHaveScreenshot("settings-configure-pmts-list.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        mask: chromeMask,
      });

      // Click a PMT row to open the per-row Configure PMTs modal and assert it.
      await configurePMT.cellByText("stripe_test").click();
      await expect(configurePMT.configureModalHeading).toBeVisible({
        timeout: 10000,
      });
      await expect(configurePMT.configureModalSubHeading).toBeVisible({
        timeout: 10000,
      });
      await expect(configurePMT.countriesDropdown).toBeVisible({
        timeout: 10000,
      });
      await expect(configurePMT.currenciesDropdown).toBeVisible({
        timeout: 10000,
      });
      await expect(configurePMT.minimumAmountInput).toBeVisible({
        timeout: 10000,
      });
      await expect(configurePMT.maximumAmountInput).toBeVisible({
        timeout: 10000,
      });
      await expect(configurePMT.submitButton).toBeVisible({ timeout: 10000 });

      await expect(page).toHaveScreenshot("settings-configure-pmts-modal.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        mask: chromeMask,
      });
    });
  });

  test.describe("Organization Settings", () => {
    test("organization settings page should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const orgSettings = new OrganizationSettingsPage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.settings.click();
      await homePage.organizationSettings.click();
      await page.waitForLoadState("networkidle");

      await expect(orgSettings.pageHeading).toBeVisible({ timeout: 10000 });
      await expect(orgSettings.organizationDetailsHeading).toBeVisible({
        timeout: 10000,
      });

      // The Organization ID and Organization Name values are per-run dynamic.
      // organizationIdRow wraps the ID label+value+copy; mirror that pattern
      // for the name row so both rows are masked.
      const orgNameRow = page
        .locator("div")
        .filter({ has: orgSettings.organizationNameLabel })
        .last();

      await expect(page).toHaveScreenshot(
        "settings-organization-settings-main.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [
            homePage.navHeaderMask,
            homePage.merchantNameButton,
            homePage.merchantID,
            orgSettings.organizationIdRow,
            orgNameRow,
          ],
        },
      );
    });
  });

  test.describe("Users", () => {
    test("users list page should match visual snapshot", async ({ page }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const usersPage = new UsersPage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.settings.click();
      await homePage.users.click();
      await page.waitForLoadState("networkidle");

      await expect(usersPage.teamManagementText).toBeVisible({
        timeout: 10000,
      });
      await expect(usersPage.usersTabText).toBeVisible({ timeout: 10000 });

      // The only row is the logged-in org admin, whose first column shows their
      // per-run email; mask the email cells to keep the snapshot stable while
      // leaving the role/status columns visible.
      const emailCells = page.locator("table#table tbody tr td:first-child");

      await expect(page).toHaveScreenshot("settings-users-list.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        mask: [
          homePage.navHeaderMask,
          homePage.merchantNameButton,
          homePage.merchantID,
          emailCells,
        ],
      });
    });

    test("users roles tab should match visual snapshot", async ({ page }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const usersPage = new UsersPage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.settings.click();
      await homePage.users.click();
      await page.waitForLoadState("networkidle");

      await expect(usersPage.teamManagementText).toBeVisible({
        timeout: 10000,
      });

      await usersPage.openRolesTab();

      // The roles matrix (role columns + permission-module rows) is static
      // backend-driven content, so no per-run masking is needed beyond chrome.
      await expect(usersPage.createCustomRoleButton).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await expect(page).toHaveScreenshot("settings-users-roles.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        mask: [
          homePage.navHeaderMask,
          homePage.merchantNameButton,
          homePage.merchantID,
        ],
      });
    });

    test("invite user drawer should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const usersPage = new UsersPage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.settings.click();
      await homePage.users.click();
      await page.waitForLoadState("networkidle");

      await expect(usersPage.teamManagementText).toBeVisible({
        timeout: 10000,
      });
      await usersPage.inviteUsersButton.click();

      // The invite drawer's email + role form is the stable content; wait for
      // its anchors before capturing.
      await expect(usersPage.emailListInput).toBeVisible({ timeout: 10000 });
      await expect(usersPage.sendInviteButton).toBeVisible({ timeout: 10000 });

      await expect(page).toHaveScreenshot("settings-users-invite.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        // Chrome carries the per-run merchant id/name, and the drawer's
        // "Select a Merchant" dropdown surfaces the auto-generated merchant
        // name from signup.
        mask: [
          homePage.navHeaderMask,
          homePage.merchantNameButton,
          homePage.merchantID,
          usersPage.merchantDropdown,
        ],
      });
    });

    test("user details page should match visual snapshot", async ({ page }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const usersPage = new UsersPage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.settings.click();
      await homePage.users.click();
      await page.waitForLoadState("networkidle");

      await expect(usersPage.teamManagementText).toBeVisible({
        timeout: 10000,
      });
      // The only row is the logged-in org admin; opening it shows the user
      // details view.
      await usersPage.usersTableRows.first().click();
      await page.waitForLoadState("networkidle");

      await expect(usersPage.navigateToTeamManagementLink).toBeVisible({
        timeout: 10000,
      });

      // The username heading, email and breadcrumb are derived from the per-run
      // email (playwright-<uuid>@test.com), so mask them. The details table
      // (All_merchants / all_profiles / Organization Admin / Active) is static.
      const usernameHeading = page.locator(
        "p.text-2xl.font-semibold.leading-8",
      );
      const emailText = page.locator("p.text-grey-600.opacity-40");
      const breadcrumbEmail = page.locator("[data-breadcrumb]").nth(1);

      await expect(page).toHaveScreenshot("settings-users-details.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        mask: [
          homePage.navHeaderMask,
          homePage.merchantNameButton,
          homePage.merchantID,
          usernameHeading,
          emailText,
          breadcrumbEmail,
        ],
      });
    });

    test("create custom role page should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const usersPage = new UsersPage(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await usersPage.visitCreateCustomRole();
      await page.waitForLoadState("networkidle");

      await expect(usersPage.createCustomRoleHeader).toBeVisible({
        timeout: 10000,
      });
      await expect(usersPage.roleNameInput).toBeVisible({ timeout: 10000 });
      // The permission table is hydrated from /user/parent/list — wait for it
      // so the (backend-static) module rows render before the capture.
      await expect(usersPage.selectPermissionLevelText).toBeVisible({
        timeout: 10000,
      });

      await expect(page).toHaveScreenshot(
        "settings-users-create-custom-role.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [
            homePage.navHeaderMask,
            homePage.merchantNameButton,
            homePage.merchantID,
          ],
        },
      );
    });
  });
});
