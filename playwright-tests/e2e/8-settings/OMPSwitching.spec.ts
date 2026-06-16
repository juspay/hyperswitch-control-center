import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import {
  generateUniqueEmail,
  generateDateTimeString,
} from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";
import UsersPage from "../../support/pages/settings/UsersPage";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Org / Merchant / Profile context switching", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
  });

  test("should open merchant/profile dropdowns from the top bar", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    // Hovering the org icon reveals the org name tooltip
    await homePage.orgIcon.hover();
    await expect(homePage.orgNameOnHover).toBeVisible();
    await expect(homePage.orgTypeLabel).toBeVisible();

    // Move the mouse away so the hover tooltip collapses
    await homePage.welcomeText.hover();
    await expect(homePage.orgNameOnHover).not.toBeVisible();

    // Merchant dropdown opens and closes on toggle
    await homePage.merchantDropdown.click();
    await expect(homePage.merchantDropdownSearchInput).toBeVisible();
    await homePage.merchantDropdown.click();
    await expect(homePage.merchantDropdownSearchInput).not.toBeVisible();

    // Profile dropdown opens and closes on toggle
    await homePage.profileDropdown.click();
    await expect(homePage.profileDropdownList).toBeVisible();
    await homePage.profileDropdown.click();
    await expect(homePage.profileDropdownList).not.toBeVisible();
  });

  test("should create a new merchant and profile and list them in the top-bar dropdowns", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const usersPage = new UsersPage(page);
    // OMP names allow only letters, digits, underscores and spaces
    const newMerchantName = `pw_merchant_${generateDateTimeString()}`;
    const newProfileName = `pw_profile_${generateDateTimeString()}`;

    // Create a new merchant from the merchant dropdown (retries the flow if the
    // create_merchant API intermittently 500s)
    await homePage.createMerchant(newMerchantName);
    await expect(usersPage.merchantCreatedSuccessText).toBeVisible();

    await page.reload();
    await homePage.merchantDropdown.click();
    await expect(homePage.merchantDropdownSearchInput).toBeVisible();

    // The dropdown stays open and lists the new merchant once the list refreshes
    await expect(homePage.ompDropdownItem(newMerchantName)).toBeVisible({
      timeout: 15000,
    });

    // Close the merchant dropdown
    await homePage.merchantDropdown.click();
    await expect(homePage.merchantDropdownSearchInput).not.toBeVisible();

    // Create a new profile from the profile dropdown
    await homePage.profileDropdown.click();
    await expect(homePage.profileDropdownList).toBeVisible();
    await homePage.clickCreateNewOption();

    await expect(homePage.addNewProfileHeader).toBeVisible();
    await homePage.newProfileNameInput.fill(newProfileName);
    await expect(homePage.addProfileButton).toBeEnabled();
    await homePage.addProfileButton.click();

    // The dropdown stays open and lists the new profile once the list refreshes
    await expect(homePage.ompDropdownItem(newProfileName)).toBeVisible({
      timeout: 15000,
    });
  });

  test("should switch between merchants and profiles from the top-bar dropdowns", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const usersPage = new UsersPage(page);
    const merchantA = `pw_merchant_a_${generateDateTimeString()}`;
    const newProfileName = `pw_profile_${generateDateTimeString()}`;

    // Create the first new merchant from the merchant dropdown (retries the
    // flow if the create_merchant API intermittently 500s)
    await homePage.createMerchant(merchantA);
    await expect(usersPage.merchantCreatedSuccessText).toBeVisible();
    await page.reload();
    await homePage.merchantDropdown.click();
    await expect(homePage.merchantDropdownSearchInput).toBeVisible();

    // Wait for the list to refresh, then switch into the new merchant
    await expect(homePage.ompDropdownItem(merchantA)).toBeVisible({
      timeout: 15000,
    });
    await homePage.ompDropdownItem(merchantA).click();
    await expect(usersPage.merchantSwitchedSuccessText).toBeVisible({
      timeout: 15000,
    });
    await expect(homePage.merchantDropdown).toContainText(merchantA, {
      timeout: 10000,
    });

    // Create a new profile inside the second merchant
    await homePage.profileDropdown.click();
    await expect(homePage.profileDropdownList).toBeVisible();
    await homePage.clickCreateNewOption();

    await expect(homePage.addNewProfileHeader).toBeVisible();
    await homePage.newProfileNameInput.fill(newProfileName);
    await expect(homePage.addProfileButton).toBeEnabled();
    await homePage.addProfileButton.click();
    await expect(homePage.ompDropdownItem(newProfileName)).toBeVisible({
      timeout: 15000,
    });

    // Switch into the newly created profile and confirm the top bar reflects it
    await homePage.ompDropdownItem(newProfileName).click();
    await expect(usersPage.profileSwitchedSuccessText).toBeVisible({
      timeout: 15000,
    });
    await expect(homePage.profileDropdown).toContainText(newProfileName, {
      timeout: 10000,
    });
  });

  test("should reject merchant names with special characters during creation", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const invalidMerchantName = "pw_invalid@merchant#1";

    await homePage.merchantDropdown.click();
    await expect(homePage.merchantDropdownSearchInput).toBeVisible();
    await homePage.clickCreateNewOption();

    await expect(homePage.addNewMerchantHeader).toBeVisible();
    await homePage.newMerchantNameInput.fill(invalidMerchantName);

    // Only letters, digits, underscores and spaces are allowed
    await expect(
      homePage.ompNameValidationError(
        "Merchant name should not contain special characters",
      ),
    ).toBeVisible();
    await expect(homePage.addMerchantButton).toBeDisabled();
  });

  test("should reject profile names with special characters during creation", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const invalidProfileName = "pw_invalid@profile#1";

    await homePage.profileDropdown.click();
    await expect(homePage.profileDropdownList).toBeVisible();
    await homePage.clickCreateNewOption();

    await expect(homePage.addNewProfileHeader).toBeVisible();
    await homePage.newProfileNameInput.fill(invalidProfileName);
    // The profile field surfaces its error once the field is touched
    await homePage.newProfileNameInput.blur();

    await expect(
      homePage.ompNameValidationError(
        "Profile name should not contain special characters",
      ),
    ).toBeVisible();
    await expect(homePage.addProfileButton).toBeDisabled();
  });

  test("should reject creating a merchant with a duplicate name", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const usersPage = new UsersPage(page);
    const merchantName = `pw_merchant_${generateDateTimeString()}`;

    // Create a merchant (retries the flow if the create_merchant API
    // intermittently 500s)
    await homePage.createMerchant(merchantName);
    await expect(usersPage.merchantCreatedSuccessText).toBeVisible();

    await page.reload();
    await homePage.merchantDropdown.click();
    await expect(homePage.merchantDropdownSearchInput).toBeVisible();

    // Wait for the merchant list to refresh so the duplicate check has the new name
    await expect(homePage.ompDropdownItem(merchantName)).toBeVisible({
      timeout: 15000,
    });

    // Attempt to create another merchant with the exact same name
    await homePage.clickCreateNewOption();
    await expect(homePage.addNewMerchantHeader).toBeVisible();
    await homePage.newMerchantNameInput.fill(merchantName);

    await expect(
      homePage.ompNameValidationError("Merchant with this name already exists"),
    ).toBeVisible();
    await expect(homePage.addMerchantButton).toBeDisabled();
  });

  test("should reject creating a profile with a duplicate name", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const profileName = `pw_profile_${generateDateTimeString()}`;

    // Create a profile
    await homePage.profileDropdown.click();
    await expect(homePage.profileDropdownList).toBeVisible();
    await homePage.clickCreateNewOption();
    await expect(homePage.addNewProfileHeader).toBeVisible();
    await homePage.newProfileNameInput.fill(profileName);
    await expect(homePage.addProfileButton).toBeEnabled();
    await homePage.addProfileButton.click();
    await expect(homePage.ompDropdownItem(profileName)).toBeVisible({
      timeout: 15000,
    });

    // Attempt to create another profile with the exact same name
    await homePage.clickCreateNewOption();
    await expect(homePage.addNewProfileHeader).toBeVisible();
    await homePage.newProfileNameInput.fill(profileName);
    await homePage.newProfileNameInput.blur();

    await expect(
      homePage.ompNameValidationError("Profile with this name already exists"),
    ).toBeVisible();
    await expect(homePage.addProfileButton).toBeDisabled();
  });

  test("should show an error toast when switching merchant fails", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const usersPage = new UsersPage(page);
    const merchantName = `pw_merchant_${generateDateTimeString()}`;

    // Create a merchant to switch into
    await homePage.merchantDropdown.click();
    await expect(homePage.merchantDropdownSearchInput).toBeVisible();
    await homePage.clickCreateNewOption();
    await expect(homePage.addNewMerchantHeader).toBeVisible();
    await homePage.newMerchantNameInput.fill(merchantName);
    await expect(homePage.addMerchantButton).toBeEnabled();
    await homePage.addMerchantButton.click();
    await expect(homePage.ompDropdownItem(merchantName)).toBeVisible({
      timeout: 15000,
    });

    // Force the merchant switch API to fail (covers both v1 and v2 paths)
    await page.route("**/user/switch/merchant", async (route) => {
      await route.fulfill({
        status: 500,
        contentType: "application/json",
        body: JSON.stringify({ error: { message: "Internal Server Error" } }),
      });
    });

    await homePage.ompDropdownItem(merchantName).click();
    await expect(usersPage.merchantSwitchFailedText).toBeVisible({
      timeout: 15000,
    });
  });

  test("should show an error toast when switching profile fails", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const usersPage = new UsersPage(page);
    const profileName = `pw_profile_${generateDateTimeString()}`;

    // Create a profile to switch into
    await homePage.profileDropdown.click();
    await expect(homePage.profileDropdownList).toBeVisible();
    await homePage.clickCreateNewOption();
    await expect(homePage.addNewProfileHeader).toBeVisible();
    await homePage.newProfileNameInput.fill(profileName);
    await expect(homePage.addProfileButton).toBeEnabled();
    await homePage.addProfileButton.click();
    await expect(homePage.ompDropdownItem(profileName)).toBeVisible({
      timeout: 15000,
    });

    // Force the profile switch API to fail (covers both v1 and v2 paths)
    await page.route("**/user/switch/profile", async (route) => {
      await route.fulfill({
        status: 500,
        contentType: "application/json",
        body: JSON.stringify({ error: { message: "Internal Server Error" } }),
      });
    });

    await homePage.ompDropdownItem(profileName).click();
    await expect(usersPage.profileSwitchFailedText).toBeVisible({
      timeout: 15000,
    });
  });
});
