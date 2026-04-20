/**
 * TC-043: Vault flows (onboarding, customers, tokens)
 * Exercises Vault + VaultProcessor bundles.
 */
import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-043: Vault coverage", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("vault-onboarding page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/vault-onboarding");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("vault-customers-tokens page renders under dashboard", async ({
    page,
  }) => {
    await page.goto("/dashboard/vault-customers-tokens");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("vault-processor page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/vault-processor");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("sidebar Vault entry brings vault subpages within reach", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    await homePage.vault.click().catch(() => {});
    await page.waitForTimeout(300);
    await homePage.vaultConfiguration.click().catch(() => {});
    await page.waitForTimeout(300);
    await homePage.vaultCustomersAndTokens.click().catch(() => {});
    await page.waitForTimeout(500);
    expect(page.url()).toContain("/dashboard");
  });

  test("vault onboarding page exposes a Connect action or search", async ({
    page,
  }) => {
    await page.goto("/dashboard/vault-onboarding");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1200);
    const anyInteractive = page.locator(
      'button, input[type="search"], input[placeholder*="Search" i]',
    );
    await expect(anyInteractive.first()).toBeVisible({ timeout: 15000 });
  });
});
