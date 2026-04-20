/**
 * TC-044: Recon/Settlement deep links
 * Exercises Recon and ReconEngine bundles.
 */
import { test, expect } from "../support/test";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

const reconRoutes = [
  "/recon",
  "/recon-analytics",
  "/run-recon",
  "/upload-files",
  "/reports",
  "/config-settings",
];

test.describe("TC-044: Recon coverage sweep", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  for (const route of reconRoutes) {
    test(`${route} deep link stays under /dashboard`, async ({ page }) => {
      await page.goto(`/dashboard${route}`);
      await page.waitForLoadState("domcontentloaded");
      await page.waitForTimeout(800);
      expect(page.url()).toContain("/dashboard");
    });

    test(`${route} deep link survives reload`, async ({ page }) => {
      await page.goto(`/dashboard${route}`);
      await page.waitForLoadState("domcontentloaded");
      await page.waitForTimeout(500);
      await page.reload();
      await page.waitForLoadState("domcontentloaded");
      expect(page.url()).toContain("/dashboard");
    });
  }
});
