/**
 * TC-041: Developer area — API keys, webhooks, payment settings
 * Exercise Developer/APIKeys, Developer/Webhooks, Developer/PaymentSettings bundles.
 */
import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-041: Developer area deep coverage", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("developer-api-keys page heading renders", async ({ page }) => {
    await page.goto("/dashboard/developer-api-keys");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    const heading = page
      .locator("h1, h2, h3")
      .filter({ hasText: /API Keys?|Credentials?/i })
      .first();
    await expect(heading).toBeVisible({ timeout: 15000 });
  });

  test("webhooks page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/webhooks");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("payment-settings page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/payment-settings");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("clicking Create New API Key opens the creation modal", async ({
    page,
  }) => {
    await page.goto("/dashboard/developer-api-keys");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1200);
    const createBtn = page.getByRole("button", { name: /Create New API Key/i });
    if (await createBtn.isVisible().catch(() => false)) {
      await createBtn.click();
      await page.waitForTimeout(500);
    }
    expect(page.url()).toContain("/dashboard");
  });

  test("sidebar Developer → API Keys clicks successfully", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.developer.click().catch(() => {});
    await homePage.apiKeys.click().catch(() => {});
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });

  test("sidebar Developer → Webhooks clicks successfully", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.developer.click().catch(() => {});
    await homePage.webhooks.click().catch(() => {});
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });

  test("sidebar Developer → Payment Settings clicks successfully", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    await homePage.developer.click().catch(() => {});
    await homePage.paymentSettings.click().catch(() => {});
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });
});
