import { test, expect } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI, mockV2MerchantList } from "../support/commands";
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

      await expect(usersPage.teamManagementText).toBeVisible({ timeout: 10000 });
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

      await expect(usersPage.teamManagementText).toBeVisible({ timeout: 10000 });

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
  });
});
