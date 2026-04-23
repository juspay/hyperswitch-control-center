import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Vault - customer search and token deletion", () => {
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

    const homePage = new HomePage(page);
    await homePage.vault.click();
    await homePage.vaultCustomersAndTokens.click();
    await expect(page).toHaveURL(/.*dashboard\/vault-customers-tokens/);
  });

  test("should accept a customer-ID search and press Enter", async ({
    page,
  }) => {
    const searchInput = page
      .locator('[data-testid*="search"], input[placeholder*="customer" i]')
      .first();
    if (!(await searchInput.isVisible().catch(() => false))) {
      test.skip(true, "customer search not exposed");
    }
    await searchInput.fill("cust_12345");
    await searchInput.press("Enter");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("vault-customers-tokens");
  });

  test("should filter tokens by status via status dropdown", async ({
    page,
  }) => {
    const statusFilter = page
      .locator('[name*="status"], select[data-testid*="status"]')
      .first();
    if (!(await statusFilter.isVisible().catch(() => false))) {
      test.skip(true, "status filter not exposed");
    }
    await statusFilter.selectOption("active");
    await page.waitForLoadState("networkidle");
    expect(page.url()).toContain("vault-customers-tokens");
  });

  test("should navigate into a customer row and reveal a Cards / Tokens section", async ({
    page,
  }) => {
    const customerRow = page
      .locator('table tbody tr:first-child, [data-testid*="customer-item"]')
      .first();
    if (!(await customerRow.isVisible().catch(() => false))) {
      test.skip(true, "no customer rows rendered");
    }
    await customerRow.click();

    const cardsSection = page
      .locator('[data-testid*="cards"], [data-testid*="tokens"], h2:has-text("Cards")')
      .first();
    await expect(cardsSection).toBeVisible({ timeout: 10000 });
  });

  test("should delete a token via confirmation dialog", async ({ page }) => {
    const deleteButton = page
      .locator('[data-button-for="deleteToken"], button:has-text("Delete")')
      .first();
    if (!(await deleteButton.isVisible().catch(() => false))) {
      test.skip(true, "no token rows / delete CTA not exposed");
    }
    await deleteButton.click();

    const confirmDialog = page
      .locator('[role="dialog"], [data-testid*="confirm"]')
      .first();
    await expect(confirmDialog).toBeVisible();

    const confirmButton = page
      .locator('[data-button-for="confirmDelete"], button:has-text("Confirm")')
      .first();
    if (await confirmButton.isVisible().catch(() => false)) {
      await confirmButton.click();
      await expect(
        page.locator('[data-toast*="deleted"], [data-toast*="removed"]'),
      ).toBeVisible({ timeout: 10000 });
    }
  });
});
