import { test, expect } from "../../support/test";
import { signupUser, loginUI } from "../../support/commands";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";


test.describe("API Key Management", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to API Keys page via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await expect(page).toHaveURL(/.*dashboard\/developer-api-keys/);
    await expect(
      page.getByText(
        "Manage API keys and credentials for integrated payment services",
      ),
    ).toBeVisible();
    await expect(
      page.getByRole("heading", { name: "API Keys", level: 2 }),
    ).toBeVisible();
  });

  test("should show empty state with create button when no API keys exist", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await expect(page).toHaveURL(/.*dashboard\/developer-api-keys/);
    await expect(page.getByText(/No Data Available/i)).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.getByRole("button", { name: "Create New API Key" }),
    ).toBeVisible();
  });

  test("should successfully create an API key with valid name and description", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const timestamp = Date.now();
    const keyName = `Test API Key ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();
    await expect(page).toHaveURL(/.*dashboard\/developer-api-keys/);

    const createButton = page.getByRole("button", {
      name: "Create New API Key",
    });
    await expect(createButton).toBeVisible();
    await createButton.click();

    await expect(page.getByText("Create API Key")).toBeVisible();

    await page.locator('input[name="name"]').fill(keyName);
    await page
      .locator('input[name="description"]')
      .fill("Test API key for automation");

    await page.getByRole("button", { name: "Create", exact: true }).click();

    await expect(page.getByText(/Please note down the API key/i)).toBeVisible(
      { timeout: 10000 },
    );

    await expect(page.getByText(/snd_/i).first()).toBeVisible();

    const downloadButton = page.getByRole("button", {
      name: "Download the key",
    });
    await expect(downloadButton).toBeVisible();
    await downloadButton.click();

    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    await expect(page.getByText(keyName)).toBeVisible({ timeout: 10000 });
  });

  test("should show validation error for empty name field", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const createButton = page.getByRole("button", { name: "Create", exact: true });

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();
    await expect(page.getByText("Create API Key")).toBeVisible();

    const nameInput = page.getByRole('textbox', { name: 'Name' });
    const descriptionInput = page.getByRole('textbox', { name: 'Description' });

    await nameInput.fill("temp");
    await nameInput.clear();
    await nameInput.blur();
    await expect(page.getByText('Please enter name')).toBeVisible();

    await descriptionInput.fill("temp");
    await descriptionInput.clear();
    await descriptionInput.blur();
    await expect(page.getByText('Please enter description')).toBeVisible();

    await expect(createButton).toBeDisabled();

    await createButton.hover();
    const tooltip = page
      .locator('[role="tooltip"]')
      .filter({ hasText: /Name|Description/i })
      .first();
    await expect(tooltip).toBeVisible({ timeout: 5000 });
    await expect(tooltip).toContainText("Name: Please enter name");
    await expect(tooltip).toContainText("Description: Please enter description");
  });

  test("should handle very long name input appropriately", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const longName =
      "ThisIsAVeryLongAPIKeyNameThatExceedsTheMaximumAllowedCharacterLimitForAPIKeyNamesInTheHyperswitchSystem";
    const description = "Very long API key name used to test validation limits in the Hyperswitch dashboard ensuring proper handling of oversized identifiers while maintaining stability enforcing strict maximum character constraints across all services and integrations consistently.";

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();

    await page.locator('input[name="name"]').fill(longName);
    await page
      .locator('input[name="description"]')
      .fill("API description for long name test");

    await expect(page.getByText('Name can\'t be more than 64 characters', { exact: true })).toBeVisible();

    await page.locator('input[name="name"]').fill("API Key With Valid Name");
    await page.locator('input[name="description"]').fill(description);
    await expect(page.getByText('Description can\'t be more than 256 characters', { exact: true })).toBeVisible();

    await page.locator('input[name="description"]').clear();
    await expect(page.getByText('Please enter description', { exact: true })).toBeVisible();
  });

  test("should handle special characters in name", async ({ page }) => {
    const homePage = new HomePage(page);
    const timestamp = Date.now();
    const keyName = `Test-Key_123!@# ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();

    await page.locator('input[name="name"]').fill(keyName);
    await page
      .locator('input[name="description"]')
      .fill("Key with special characters");
    await page.getByRole("button", { name: "Create", exact: true }).click();

    await expect(page.getByText(/Please note down the API key/i)).toBeVisible(
      { timeout: 10000 },
    );

    await expect(page.getByText(/snd_/i).first()).toBeVisible();

    await page.getByRole("button", { name: "Download the key" }).click();
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
    const timestamp = Date.now();
    const keyName = `Clipboard Test ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();
    await page.locator('input[name="name"]').fill(keyName);
    await page
      .locator('input[name="description"]')
      .fill("Test clipboard copy of generated key");
    await page.getByRole("button", { name: "Create", exact: true }).click();

    await expect(page.getByText(/Please note down the API key/i)).toBeVisible({
      timeout: 10000,
    });

    const generatedKey = page.getByText(/snd_/i).first();
    await expect(generatedKey).toBeVisible();
    await generatedKey.click();

    await expect(page.getByText("Copied to Clipboard!")).toBeVisible({
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
    const timestamp = Date.now();
    const keyName = `Columns Test ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();
    await page.locator('input[name="name"]').fill(keyName);
    await page
      .locator('input[name="description"]')
      .fill("Verifying table columns");
    await page.getByRole("button", { name: "Create", exact: true }).click();

    await expect(page.getByText(/Please note down the API key/i)).toBeVisible({
      timeout: 10000,
    });
    await page.keyboard.press("Escape");

    await expect(page.getByText(keyName)).toBeVisible({ timeout: 10000 });

    const expectedColumns = [
      "API Key Prefix",
      "Name",
      "Description",
      "Created",
      "Expiration",
    ];
    for (const column of expectedColumns) {
      await expect(
        page.getByRole("columnheader", { name: column, exact: true }),
      ).toBeVisible();
    }
  });

  test("should delete created API key", async ({ page }) => {
    const homePage = new HomePage(page);
    const timestamp = Date.now();
    const keyName = `DeleteTestKey ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();
    await page.getByRole("textbox", { name: "Name" }).fill(keyName);
    await page.getByRole("textbox", { name: "Description" }).fill("Test API key for automation");
    await page.getByRole("button", { name: "Create", exact: true }).click();

    await expect(page.getByText(/Please note down the API key/i)).toBeVisible();

    await expect(page.getByText(/snd_/i).first()).toBeVisible();

    const downloadButton = page.getByRole("button", { name: "Download the key" });
    await expect(downloadButton).toBeVisible();
    await downloadButton.click();

    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    await expect(page.getByText(keyName)).toBeVisible();

    const keyRow = page.getByRole("row").filter({ hasText: keyName });
    await keyRow.scrollIntoViewIfNeeded();
    await keyRow.hover();

    const deleteIcon = keyRow.locator('[data-icon="delete"]');
    await expect(deleteIcon).toBeVisible();
    await deleteIcon.click();

    await page.getByRole("button", { name: "Yes, delete it", exact: true }).click();

    await expect(page.getByText(keyName)).toBeHidden();
  });

  test("should update existing API key name and description", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const timestamp = Date.now();
    const originalName = `EditTestKey ${timestamp}`;
    const updatedName = `UpdatedKeyName ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();
    await page.getByRole("textbox", { name: "Name" }).fill(originalName);
    await page.getByRole("textbox", { name: "Description" }).fill("Test API key for automation");
    await page.getByRole("button", { name: "Create", exact: true }).click();

    await expect(page.getByText(/Please note down the API key/i)).toBeVisible();

    await expect(page.getByText(/snd_/i).first()).toBeVisible();

    const downloadButton = page.getByRole("button", { name: "Download the key" });
    await expect(downloadButton).toBeVisible();
    await downloadButton.click();

    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    await expect(page.getByText(originalName)).toBeVisible();

    const keyRow = page.getByRole("row").filter({ hasText: originalName });
    await keyRow.scrollIntoViewIfNeeded();
    await keyRow.hover();

    const editIcon = keyRow.locator('[data-icon="edit"]');
    await expect(editIcon).toBeVisible();
    await editIcon.click();

    await expect(page.getByText(/Update API Key/i)).toBeVisible();

    const nameInput = page.getByRole("textbox", { name: "Name" });
    await nameInput.clear();
    await nameInput.fill(updatedName);

    const descriptionInput = page.getByRole("textbox", { name: "Description" });
    await descriptionInput.clear();
    await descriptionInput.fill("Updated API key for automation");

    await page.getByRole("button", { name: /Update/i }).click();

    await expect(page.getByText(updatedName)).toBeVisible({ timeout: 10000 });
    await expect(page.getByText(originalName)).not.toBeVisible();
    await expect(page.getByText("Updated API key for automation")).toBeVisible({ timeout: 10000 });
    await expect(page.getByText("Test API key for automation")).not.toBeVisible();
  });

  test("should create key with custom expiration", async ({ page }) => {
    const homePage = new HomePage(page);
    const timestamp = Date.now();
    const keyName = `ExpiryTestKey ${timestamp}`;

    const today = new Date();
    const nextMonth = new Date(today.getFullYear(), today.getMonth() + 1, 10);
    const monthShort = nextMonth.toLocaleString("en-US", { month: "short" });
    const expectedDateLabel = `${monthShort} 10, ${nextMonth.getFullYear()}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();
    await expect(page.getByText("Create API Key")).toBeVisible();

    await page.locator('input[name="name"]').fill(keyName);
    await page.locator('input[name="description"]').fill("Test API key for automation");

    await page.getByRole("button", { name: "Never" }).click();
    await page.getByText("Custom", { exact: true }).click();

    await page.getByRole("button", { name: "Select Date" }).click();

    await page.locator('[data-icon="chevron-right"]').first().click();
    await page.getByText('10', { exact: true }).click();
    await page.getByRole("button", { name: "Create", exact: true }).click();

    await page.getByRole("button", { name: "Download the key" }).click();
    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    await expect(page.getByText(keyName)).toBeVisible();

    const keyRow = page.getByRole("row").filter({ hasText: keyName });
    await expect(keyRow).not.toContainText("Never");
    await expect(keyRow).toContainText(expectedDateLabel);
  });
});
