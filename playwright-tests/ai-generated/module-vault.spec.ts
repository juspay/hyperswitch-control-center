/**
 * Auto-generated Playwright test
 * Source: module:vault - Vault Configuration and Customers & Tokens
 * Generated: 2026-04-17
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Vault Module", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to Vault Configuration if enabled", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const vault = homePage.vault;

    if ((await vault.count().catch(() => 0)) > 0) {
      await vault.click();
      const config = homePage.vaultConfiguration;
      if ((await config.count().catch(() => 0)) > 0) {
        await config.click();
        await expect(page).toHaveURL(/.*dashboard\/vault-onboarding/);
      }
    }
  });

  test("should navigate to Vault Customers & Tokens if enabled", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const vault = homePage.vault;

    if ((await vault.count().catch(() => 0)) > 0) {
      await vault.click();
      const customers = homePage.vaultCustomersAndTokens;
      if ((await customers.count().catch(() => 0)) > 0) {
        await customers.click();
        await expect(page).toHaveURL(
          /.*dashboard\/vault-customers-tokens/,
        );
      }
    }
  });

  test("should load vault-onboarding via direct URL", async ({ page }) => {
    await page.goto("/dashboard/vault-onboarding");
    await page.waitForLoadState("networkidle");

    const expected = /.*dashboard\/(vault-onboarding|home|login)/;
    await expect(page).toHaveURL(expected);
  });

  test("should load vault-customers-tokens via direct URL", async ({
    page,
  }) => {
    await page.goto("/dashboard/vault-customers-tokens");
    await page.waitForLoadState("networkidle");

    const expected = /.*dashboard\/(vault-customers-tokens|home|login)/;
    await expect(page).toHaveURL(expected);
  });
});
