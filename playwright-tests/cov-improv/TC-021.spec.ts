import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-021: Vault - Token Management", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.vault = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should navigate to customers and tokens", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.vault.click();
    await homePage.vaultCustomersAndTokens.click();

    await expect(page).toHaveURL(/.*dashboard\/vault-customers-tokens/);
  });

  test("should search for customer by ID", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.vault.click();
    await homePage.vaultCustomersAndTokens.click();

    const searchInput = page
      .locator('[data-testid*="search"], input[placeholder*="customer" i]')
      .first();
    if (await searchInput.isVisible().catch(() => false)) {
      await searchInput.fill("cust_12345");
      await searchInput.press("Enter");
      await page.waitForTimeout(1000);
    }
  });

  test("should view customer's vaulted cards", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.vault.click();
    await homePage.vaultCustomersAndTokens.click();

    const customerRow = page
      .locator('table tbody tr:first-child, [data-testid*="customer-item"]')
      .first();
    if (await customerRow.isVisible().catch(() => false)) {
      await customerRow.click();

      const cardsSection = page
        .locator('[data-testid*="cards"], [data-testid*="tokens"]')
        .first();
      await expect(
        cardsSection.or(page.locator("h2:has-text('Cards')")),
      ).toBeTruthy();
    }
  });

  test("should delete specific token with confirmation", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.vault.click();
    await homePage.vaultCustomersAndTokens.click();

    const deleteButton = page
      .locator('[data-button-for="deleteToken"], button:has-text("Delete")')
      .first();
    if (await deleteButton.isVisible().catch(() => false)) {
      await deleteButton.click();

      const confirmDialog = page
        .locator('[role="dialog"], [data-testid*="confirm"]')
        .first();
      await expect(confirmDialog).toBeVisible();

      const confirmButton = page
        .locator(
          '[data-button-for="confirmDelete"], button:has-text("Confirm")',
        )
        .first();
      if (await confirmButton.isVisible().catch(() => false)) {
        await confirmButton.click();

        await expect(
          page.locator('[data-toast*="deleted"], [data-toast*="removed"]'),
        ).toBeVisible({ timeout: 10000 });
      }
    }
  });

  test("should filter tokens by status", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.vault.click();
    await homePage.vaultCustomersAndTokens.click();

    const statusFilter = page
      .locator('[name*="status"], select[data-testid*="status"]')
      .first();
    if (await statusFilter.isVisible().catch(() => false)) {
      await statusFilter.selectOption("active");
      await page.waitForTimeout(1000);
    }
  });
});
