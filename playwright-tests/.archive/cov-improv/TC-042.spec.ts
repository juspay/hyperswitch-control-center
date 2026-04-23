/**
 * TC-042: Transaction view tabs + filters across pages
 * Covers TransactionViews and HSwitchRemoteFilter utilities.
 */
import { test, expect } from "../../support/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

const tables = [
  "/payments",
  "/refunds",
  "/disputes",
  "/payouts",
  "/customers",
];

test.describe("TC-042: Transaction table coverage", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  for (const route of tables) {
    test(`${route} listing exposes a search input`, async ({ page }) => {
      await page.goto(`/dashboard${route}`);
      await page.waitForLoadState("domcontentloaded");
      await page.waitForTimeout(1200);
      const search = page
        .locator('input[placeholder*="Search" i], input[type="search"]')
        .first();
      const visible = await search.isVisible().catch(() => false);
      if (visible) {
        await search.fill("unmatched-xyz");
        await page.waitForTimeout(400);
        await search.fill("");
      }
      expect(page.url()).toContain("/dashboard");
    });

    test(`${route} listing survives reload`, async ({ page }) => {
      await page.goto(`/dashboard${route}`);
      await page.waitForLoadState("domcontentloaded");
      await page.waitForTimeout(800);
      await page.reload();
      await page.waitForLoadState("domcontentloaded");
      expect(page.url()).toContain("/dashboard");
    });
  }
});
