import { test, expect } from "../../support/test";
import { signupUser, loginUI } from "../../support/commands";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("API Key Management", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
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

    await expect(page.getByText(/Please note down the API key/i)).toBeVisible({
      timeout: 10000,
    });

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

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();
    await expect(page.getByText("Create API Key")).toBeVisible();

    const createButton = page.getByRole("button", {
      name: "Create",
      exact: true,
    });
    await expect(createButton).toBeDisabled();

    await expect(page.getByText("Create API Key")).toBeVisible();
  });

  test("should handle very long name input appropriately", async ({ page }) => {
    const homePage = new HomePage(page);
    const longName =
      "ThisIsAVeryLongAPIKeyNameThatExceedsTheMaximumAllowedCharacterLimitForAPIKeyNamesInTheHyperswitchSystem";
    const description =
      "Very long API key name used to test validation limits in the Hyperswitch dashboard ensuring proper handling of oversized identifiers while maintaining stability enforcing strict maximum character constraints across all services and integrations consistently.";

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();

    await page.locator('input[name="name"]').fill(longName);
    await page
      .locator('input[name="description"]')
      .fill("API description for long name test");

    await expect(
      page.getByText("Name can't be more than 64 characters", { exact: true }),
    ).toBeVisible();

    await page.locator('input[name="name"]').fill("API Key With Valid Name");
    await page.locator('input[name="description"]').fill(description);
    await expect(
      page.getByText("Description can't be more than 256 characters", {
        exact: true,
      }),
    ).toBeVisible();

    await page.locator('input[name="description"]').clear();
    await expect(
      page.getByText("Please enter description", { exact: true }),
    ).toBeVisible();
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

    await expect(page.getByText(/Please note down the API key/i)).toBeVisible({
      timeout: 10000,
    });

    await expect(page.getByText(/snd_/i).first()).toBeVisible();

    await page.getByRole("button", { name: "Download the key" }).click();
    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    await expect(page.getByText(keyName)).toBeVisible({ timeout: 10000 });
  });

  test.skip("should delete created API key", async ({ page }) => {
    const homePage = new HomePage(page);
    const timestamp = Date.now();
    const keyName = `DeleteTestKey ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();
    await page.getByRole("textbox", { name: "Name" }).fill(keyName);
    await page
      .getByRole("textbox", { name: "Description" })
      .fill("Test API key for automation");
    await page.getByRole("button", { name: "Create", exact: true }).click();

    await expect(page.getByText(/Please note down the API key/i)).toBeVisible({
      timeout: 10000,
    });

    await expect(page.getByText(/snd_/i).first()).toBeVisible();

    const downloadButton = page.getByRole("button", {
      name: "Download the key",
    });
    await expect(downloadButton).toBeVisible();
    await downloadButton.click();

    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    //scroll right to make delete button visible
    const keyRow = page.getByText(keyName).locator("xpath=../..");
    await keyRow.scrollIntoViewIfNeeded();
    await page.locator('[data-icon="delete"]').click();
  });

  test.skip("should update existing API key name", async ({
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
    await page
      .getByRole("textbox", { name: "Description" })
      .fill("Test API key for automation");
    await page.getByRole("button", { name: "Create", exact: true }).click();

    await expect(
      page.getByText(
        /Please note down the API key|API key created|successfully/i,
      ),
    ).toBeVisible({ timeout: 10000 });
    await page
      .getByRole("button", { name: /close|done|ok/i })
      .first()
      .click()
      .catch(() => {});
    await page.waitForTimeout(1000);

    await expect(page.getByText(originalName)).toBeVisible();

    await page.getByText(originalName).hover();
    const editButton = page
      .locator("[name='edit'], button:has-text('Edit'), [data-testid*='edit']")
      .first();

    if ((await editButton.count()) > 0) {
      await editButton.click();

      await expect(
        page.getByText(/update.*api key|edit.*api key/i),
      ).toBeVisible({ timeout: 5000 });

      const nameInput = page.getByRole("textbox", { name: "Name" });
      await nameInput.clear();
      await nameInput.fill(updatedName);

      await page.getByRole("button", { name: /update|save/i }).click();

      await expect(page.getByText(updatedName)).toBeVisible({
        timeout: 10000,
      });
      await expect(page.getByText(originalName)).not.toBeVisible();
    }
  });

  test.skip("should create key with custom expiration", async ({ page }) => {
    const homePage = new HomePage(page);
    const timestamp = Date.now();
    const keyName = `ExpiryTestKey ${timestamp}`;

    await homePage.developer.click();
    await homePage.apiKeys.click();

    await page.getByRole("button", { name: "Create New API Key" }).click();

    await page.getByRole("textbox", { name: "Name" }).fill(keyName);
    await page
      .getByRole("textbox", { name: "Description" })
      .fill("Test API key for automation");

    const expirationDropdown = page
      .locator("button:has-text('Never'), select[name='expiration']")
      .first();
    if (await expirationDropdown.isVisible().catch(() => false)) {
      await expirationDropdown.click();

      const customOption = page
        .getByText(/custom|30 days|60 days|90 days/i)
        .first();
      if ((await customOption.count()) > 0) {
        await customOption.click();

        const dateInput = page
          .locator("input[type='date'], input[name='expiration_date']")
          .first();
        if ((await dateInput.count()) > 0) {
          await dateInput.fill("2025-12-31");
        }
      }
    }

    await page.getByRole("button", { name: "Create", exact: true }).click();

    await expect(
      page.getByText(
        /Please note down the API key|API key created|successfully/i,
      ),
    ).toBeVisible({ timeout: 10000 });

    await page
      .getByRole("button", { name: /close|done|ok/i })
      .first()
      .click()
      .catch(() => {});

    await expect(page.getByText(keyName)).toBeVisible({ timeout: 10000 });

    const keyRow = page.getByText(keyName).locator("xpath=../..");
    const expirationCell = keyRow.locator("td").nth(4);
    if ((await expirationCell.count()) > 0) {
      const expirationText = await expirationCell.textContent();
      expect(expirationText).toBeTruthy();
    }
  });
});
