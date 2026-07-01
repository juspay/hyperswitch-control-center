import { test, expect } from "../../support/test";
import { signupUser, loginUI } from "../../support/commands";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { APISettings } from "../../support/pages/developers/APISettings";
import { generateUniqueEmail } from "../../support/helper";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("API Key Management", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to API Keys page via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);
    const apiSettings = new APISettings(page);

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await expect(page).toHaveURL(/.*dashboard\/developer-api-keys/);
    await expect(apiSettings.pageSubheading).toBeVisible();
    await expect(apiSettings.pageHeading).toBeVisible();
  });

  test("should show empty state with create button when no API keys exist", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const apiSettings = new APISettings(page);

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await expect(page).toHaveURL(/.*dashboard\/developer-api-keys/);
    await expect(apiSettings.noDataAvailable).toBeVisible({ timeout: 10000 });
    await expect(apiSettings.createNewApiKeyButton).toBeVisible();
  });

  test("should successfully create an API key with valid name and description", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const apiSettings = new APISettings(page);
    const timestamp = Date.now();
    const keyName = `Test API Key ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();
    await expect(page).toHaveURL(/.*dashboard\/developer-api-keys/);

    await expect(apiSettings.createNewApiKeyButton).toBeVisible();
    await apiSettings.createNewApiKeyButton.click();

    await expect(apiSettings.createApiKeyModalHeading).toBeVisible();

    await apiSettings.fillNameAndDescription(
      keyName,
      "Test API key for automation",
    );

    await apiSettings.createButton.click();

    await expect(apiSettings.pleaseNoteApiKey).toBeVisible({ timeout: 10000 });

    await expect(apiSettings.generatedKeyText).toBeVisible();

    await expect(apiSettings.downloadKeyButton).toBeVisible();
    await apiSettings.downloadKeyButton.click();

    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    await expect(page.getByText(keyName)).toBeVisible({ timeout: 10000 });
  });

  test("should show validation error for empty name field", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const apiSettings = new APISettings(page);

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await apiSettings.createNewApiKeyButton.click();
    await expect(apiSettings.createApiKeyModalHeading).toBeVisible();

    const nameInput = apiSettings.nameTextbox;
    const descriptionInput = apiSettings.descriptionTextbox;

    await nameInput.fill("temp");
    await nameInput.clear();
    await nameInput.blur();
    await expect(apiSettings.nameRequiredError).toBeVisible();

    await descriptionInput.fill("temp");
    await descriptionInput.clear();
    await descriptionInput.blur();
    await expect(apiSettings.descriptionRequiredError).toBeVisible();

    await expect(apiSettings.createButton).toBeDisabled();

    await apiSettings.createButton.hover();
    const tooltip = apiSettings.validationTooltip();
    await expect(tooltip).toBeVisible({ timeout: 5000 });
    await expect(tooltip).toContainText("Name: Please enter name");
    await expect(tooltip).toContainText(
      "Description: Please enter description",
    );
  });

  test("should handle very long name input appropriately", async ({ page }) => {
    const homePage = new HomePage(page);
    const apiSettings = new APISettings(page);
    const longName =
      "ThisIsAVeryLongAPIKeyNameThatExceedsTheMaximumAllowedCharacterLimitForAPIKeyNamesInTheHyperswitchSystem";
    const description =
      "Very long API key name used to test validation limits in the Hyperswitch dashboard ensuring proper handling of oversized identifiers while maintaining stability enforcing strict maximum character constraints across all services and integrations consistently.";

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await apiSettings.createNewApiKeyButton.click();

    await apiSettings.nameInput.fill(longName);
    await apiSettings.descriptionInput.fill(
      "API description for long name test",
    );

    await expect(apiSettings.nameTooLongError).toBeVisible();

    await apiSettings.nameInput.fill("API Key With Valid Name");
    await apiSettings.descriptionInput.fill(description);
    await expect(apiSettings.descriptionTooLongError).toBeVisible();

    await apiSettings.descriptionInput.clear();
    await expect(apiSettings.descriptionRequiredErrorExact).toBeVisible();
  });

  test("should handle special characters in name", async ({ page }) => {
    const homePage = new HomePage(page);
    const apiSettings = new APISettings(page);
    const timestamp = Date.now();
    const keyName = `Test-Key_123!@# ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await apiSettings.createNewApiKeyButton.click();

    await apiSettings.fillNameAndDescription(
      keyName,
      "Key with special characters",
    );
    await apiSettings.createButton.click();

    await expect(apiSettings.pleaseNoteApiKey).toBeVisible({ timeout: 10000 });

    await expect(apiSettings.generatedKeyText).toBeVisible();

    await apiSettings.downloadKeyButton.click();
    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    await expect(page.getByText(keyName)).toBeVisible({ timeout: 10000 });
  });

  test("should copy generated key to clipboard from success screen", async ({
    page,
    context,
  }) => {
    await context.grantPermissions(["clipboard-read", "clipboard-write"]);

    const homePage = new HomePage(page);
    const apiSettings = new APISettings(page);
    const timestamp = Date.now();
    const keyName = `Clipboard Test ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await apiSettings.createNewApiKeyButton.click();
    await apiSettings.fillNameAndDescription(
      keyName,
      "Test clipboard copy of generated key",
    );
    await apiSettings.createButton.click();

    await expect(apiSettings.pleaseNoteApiKey).toBeVisible({ timeout: 10000 });

    const generatedKey = apiSettings.generatedKeyText;
    await expect(generatedKey).toBeVisible();
    await generatedKey.click();

    await expect(apiSettings.copiedToClipboardToast).toBeVisible({
      timeout: 5000,
    });

    const clipboardContent = await page.evaluate(() =>
      navigator.clipboard.readText(),
    );
    expect(clipboardContent).toMatch(/^snd_/);
  });

  test("should display all expected columns in API keys table", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const apiSettings = new APISettings(page);
    const timestamp = Date.now();
    const keyName = `Columns Test ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await apiSettings.createNewApiKeyButton.click();
    await apiSettings.fillNameAndDescription(
      keyName,
      "Verifying table columns",
    );
    await apiSettings.createButton.click();

    await expect(apiSettings.pleaseNoteApiKey).toBeVisible({ timeout: 10000 });
    await page.keyboard.press("Escape");

    await expect(page.getByText(keyName)).toBeVisible({ timeout: 10000 });

    for (const column of apiSettings.expectedColumns()) {
      await expect(apiSettings.columnHeader(column)).toBeVisible();
    }
  });

  test("should delete created API key", async ({ page }) => {
    const homePage = new HomePage(page);
    const apiSettings = new APISettings(page);
    const timestamp = Date.now();
    const keyName = `DeleteTestKey ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await apiSettings.createNewApiKeyButton.click();
    await apiSettings.nameTextbox.fill(keyName);
    await apiSettings.descriptionTextbox.fill("Test API key for automation");
    await apiSettings.createButton.click();

    await expect(apiSettings.pleaseNoteApiKey).toBeVisible();

    await expect(apiSettings.generatedKeyText).toBeVisible();

    await expect(apiSettings.downloadKeyButton).toBeVisible();
    await apiSettings.downloadKeyButton.click();

    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    await expect(page.getByText(keyName)).toBeVisible();

    const keyRow = apiSettings.keyRow(keyName);
    await keyRow.scrollIntoViewIfNeeded();
    await keyRow.hover();

    const deleteIcon = apiSettings.deleteIcon(keyRow);
    await expect(deleteIcon).toBeVisible();
    await deleteIcon.click();

    await apiSettings.yesDeleteItButton.click();

    await expect(page.getByText(keyName)).toBeHidden();
  });

  test("should update existing API key name and description", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const apiSettings = new APISettings(page);
    const timestamp = Date.now();
    const originalName = `EditTestKey ${timestamp}`;
    const updatedName = `UpdatedKeyName ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await apiSettings.createNewApiKeyButton.click();
    await apiSettings.nameTextbox.fill(originalName);
    await apiSettings.descriptionTextbox.fill("Test API key for automation");
    await apiSettings.createButton.click();

    await expect(apiSettings.pleaseNoteApiKey).toBeVisible();

    await expect(apiSettings.generatedKeyText).toBeVisible();

    await expect(apiSettings.downloadKeyButton).toBeVisible();
    await apiSettings.downloadKeyButton.click();

    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    await expect(page.getByText(originalName)).toBeVisible();

    const keyRow = apiSettings.keyRow(originalName);
    await keyRow.scrollIntoViewIfNeeded();
    await keyRow.hover();

    const editIcon = apiSettings.editIcon(keyRow);
    await expect(editIcon).toBeVisible();
    await editIcon.click();

    await expect(apiSettings.updateApiKeyModalHeading).toBeVisible();

    const nameInput = apiSettings.nameTextbox;
    await nameInput.clear();
    await nameInput.fill(updatedName);

    const descriptionInput = apiSettings.descriptionTextbox;
    await descriptionInput.clear();
    await descriptionInput.fill("Updated API key for automation");

    await apiSettings.updateButton.click();

    await expect(page.getByText(updatedName)).toBeVisible({ timeout: 10000 });
    await expect(page.getByText(originalName)).not.toBeVisible();
    await expect(page.getByText("Updated API key for automation")).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.getByText("Test API key for automation"),
    ).not.toBeVisible();
  });

  test("should create key with custom expiration", async ({ page }) => {
    const homePage = new HomePage(page);
    const apiSettings = new APISettings(page);
    const timestamp = Date.now();
    const keyName = `ExpiryTestKey ${timestamp}`;

    const today = new Date();
    const nextMonth = new Date(today.getFullYear(), today.getMonth() + 1, 10);
    const monthShort = nextMonth.toLocaleString("en-US", { month: "short" });
    const expectedDateLabel = `${monthShort} 10, ${nextMonth.getFullYear()}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await apiSettings.createNewApiKeyButton.click();
    await expect(apiSettings.createApiKeyModalHeading).toBeVisible();

    await apiSettings.fillNameAndDescription(
      keyName,
      "Test API key for automation",
    );

    await apiSettings.neverExpiryButton.click();
    await apiSettings.customExpiryOption.click();

    await apiSettings.selectDateButton.click();

    await apiSettings.chevronRight.click();
    await apiSettings.dayOfMonth("10").click();
    await apiSettings.createButton.click();

    await apiSettings.downloadKeyButton.click();
    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    await expect(page.getByText(keyName)).toBeVisible();

    const keyRow = apiSettings.keyRow(keyName);
    await expect(keyRow).not.toContainText("Never");
    await expect(keyRow).toContainText(expectedDateLabel);
  });
});
