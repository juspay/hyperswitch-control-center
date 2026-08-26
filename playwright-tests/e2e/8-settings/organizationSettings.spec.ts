import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { OrganizationSettingsPage } from "../../support/pages/settings/OrganizationSettingsPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// Signs up a fresh org-admin user, logs in via the UI and opens the
// Organization Settings page.
async function loginAndVisit(page: Page): Promise<OrganizationSettingsPage> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

  const orgSettings = new OrganizationSettingsPage(page);
  await orgSettings.visit();
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(1000);
  return orgSettings;
}

test.describe("Organization Settings - Page & Details", () => {
  let orgSettings: OrganizationSettingsPage;

  test.beforeEach(async ({ page }) => {
    orgSettings = await loginAndVisit(page);
  });

  test("should load the page with heading, subtitle and organization details", async () => {
    await expect(orgSettings.pageHeading).toBeVisible({ timeout: 10000 });
    await expect(orgSettings.organizationDetailsHeading).toBeVisible({
      timeout: 10000,
    });

    await expect(orgSettings.organizationIdLabel).toBeVisible({
      timeout: 10000,
    });
    await expect(orgSettings.copyOrgIdIcon).toBeVisible({ timeout: 10000 });
    await orgSettings.copyOrgIdIcon.click();
    await expect(orgSettings.toast("Copied to Clipboard!")).toBeVisible({
      timeout: 10000,
    });

    await expect(orgSettings.organizationNameLabel).toBeVisible({
      timeout: 10000,
    });
    await expect(orgSettings.editOrganizationNameButton).toBeVisible({
      timeout: 10000,
    });

    await expect(orgSettings.createPlatformOrganizationCard).toBeVisible();

    await expect(orgSettings.learnMoreButton).toBeVisible({ timeout: 10000 });
    await expect(orgSettings.createPlatformOrganizationButton).toBeVisible({
      timeout: 10000,
    });

    await expect(orgSettings.convertToPlatformHeading).toBeVisible();
    await expect(orgSettings.convertToPlatformDescription).toBeVisible();
    await expect(orgSettings.contactUsText).toBeVisible();
  });
});

test.describe("Organization Settings - Edit Organization Name", () => {
  let orgSettings: OrganizationSettingsPage;

  test.beforeEach(async ({ page }) => {
    orgSettings = await loginAndVisit(page);
  });

  test("should switch the name field to an editable input on edit", async () => {
    await orgSettings.editOrganizationNameButton.click();
    await expect(orgSettings.organizationNameInput).toBeVisible({
      timeout: 10000,
    });
    await expect(orgSettings.saveOrganizationNameButton).toBeVisible({
      timeout: 10000,
    });
    await expect(orgSettings.cancelOrganizationNameButton).toBeVisible({
      timeout: 10000,
    });
  });

  test("should discard changes and exit edit mode on cancel", async ({
    page,
  }) => {
    await orgSettings.editOrganizationNameButton.click();
    await orgSettings.organizationNameInput.fill("Discarded Name 123");
    await orgSettings.cancelOrganizationNameButton.click();

    await expect(orgSettings.organizationNameInput).toBeHidden();
    await expect(orgSettings.editOrganizationNameButton).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.getByText("Discarded Name 123", { exact: true }),
    ).toBeHidden();
  });

  test("should block a name with invalid formatss", async () => {
    await orgSettings.editOrganizationNameButton.click();
    await orgSettings.organizationNameInput.fill("Bad@Name!#$");

    await expect(orgSettings.invalidNameRing).toBeVisible({ timeout: 10000 });
    await expect(orgSettings.saveOrganizationNameButton).toBeDisabled();

    await orgSettings.organizationNameInput.fill("");

    await expect(orgSettings.invalidNameRing).toBeVisible({ timeout: 10000 });
    await expect(orgSettings.saveOrganizationNameButton).toBeDisabled();

    await orgSettings.organizationNameInput.fill("a".repeat(65));

    await expect(orgSettings.invalidNameRing).toBeVisible({ timeout: 10000 });
    await expect(orgSettings.saveOrganizationNameButton).toBeDisabled();
  });

  test("should save a new organization name", async ({ page }) => {
    const newName = `Org ${Date.now()}`;
    await orgSettings.editOrganizationNameButton.click();
    await orgSettings.organizationNameInput.fill(newName);
    await orgSettings.saveOrganizationNameButton.click();

    await expect(orgSettings.toast("Updated organization name!")).toBeVisible({
      timeout: 10000,
    });
    // The name also renders (collapsed/hidden) in the sidebar org switcher, so
    // scope to the visible Organization Details field.
    await expect(
      page
        .getByText(newName, { exact: true })
        .filter({ visible: true })
        .first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should show an error toast when saving the name fails", async ({
    page,
  }) => {
    // Fail only the organization update (PUT); let the org-list refresh pass.
    await page.route("**/organization/*", async (route) => {
      if (route.request().method() === "PUT") {
        await route.fulfill({
          status: 500,
          contentType: "application/json",
          body: JSON.stringify({ error: { message: "update failed" } }),
        });
      } else {
        await route.fallback();
      }
    });

    await orgSettings.editOrganizationNameButton.click();
    await orgSettings.organizationNameInput.fill(`Org ${Date.now()}`);
    await orgSettings.saveOrganizationNameButton.click();

    await expect(
      orgSettings.toast("Failed to update organization name!"),
    ).toBeVisible({ timeout: 10000 });
  });
});

test.describe("Organization Settings - Platform Organization", () => {
  let orgSettings: OrganizationSettingsPage;

  test.beforeEach(async ({ page }) => {
    orgSettings = await loginAndVisit(page);
  });

  test("should open the About Platform Organizations info modal", async () => {
    await orgSettings.learnMoreButton.click();
    await expect(orgSettings.aboutPlatformHeading).toBeVisible({
      timeout: 10000,
    });
  });

  test("should open the Create Platform Organization modal with a name input", async ({
    page,
  }) => {
    await orgSettings.createPlatformOrganizationButton.click();
    await expect(page.getByText("Create New Platform").nth(1)).toBeVisible();
    await expect(page.getByText("Organization Name *")).toBeVisible();
    await expect(orgSettings.platformNameInput).toBeVisible({ timeout: 10000 });
    await expect(orgSettings.createPlatformSubmitButton).toBeVisible({
      timeout: 10000,
    });
  });

  test("should reject a platform organization name with special characters", async () => {
    await orgSettings.createPlatformOrganizationButton.click();
    await expect(orgSettings.platformNameInput).toBeVisible({ timeout: 10000 });
    await orgSettings.platformNameInput.fill("Bad@Name!");

    await expect(
      orgSettings.nameValidationError(
        "Organization name should not contain special characters",
      ),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should create a platform organization successfully", async ({
    page,
  }) => {
    await page.route("**/user/create_platform", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({}),
      });
    });

    await orgSettings.createPlatformOrganizationButton.click();
    await expect(orgSettings.platformNameInput).toBeVisible({ timeout: 10000 });
    await orgSettings.platformNameInput.fill("My Platform Org 123");
    await orgSettings.createPlatformSubmitButton.click();

    await expect(
      orgSettings.toast("Platform Organization Created Successfully!"),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should show an error toast when platform creation fails", async ({
    page,
  }) => {
    await page.route("**/user/create_platform", async (route) => {
      await route.fulfill({
        status: 500,
        contentType: "application/json",
        body: JSON.stringify({ error: { message: "creation failed" } }),
      });
    });

    await orgSettings.createPlatformOrganizationButton.click();
    await expect(orgSettings.platformNameInput).toBeVisible({ timeout: 10000 });
    await orgSettings.platformNameInput.fill("My Platform Org 123");
    await orgSettings.createPlatformSubmitButton.click();

    await expect(
      orgSettings.toast("Platform Organization Creation Failed"),
    ).toBeVisible({ timeout: 10000 });
  });
});
