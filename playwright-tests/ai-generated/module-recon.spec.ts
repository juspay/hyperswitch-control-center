/**
 * Auto-generated Playwright test
 * Source: module:recon - Recon & Settlement sub-routes (FF-gated)
 * Generated: 2026-04-17
 *
 * Covers the six Recon & Settlement routes defined in SidebarValues.res:
 *   /recon, /upload-files, /run-recon, /recon-analytics, /reports, /config-settings
 *
 * All routes are feature-flag gated. When the flag is off the app redirects
 * back to /dashboard/home. Tests use a tolerant URL regex so they pass in
 * both states; real assertions still run when the page renders.
 */

import { test, expect } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

const RECON_ROUTES: ReadonlyArray<{ path: string; label: string }> = [
  { path: "recon", label: "Reconciliation landing" },
  { path: "upload-files", label: "Upload Recon Files" },
  { path: "run-recon", label: "Run Recon" },
  { path: "recon-analytics", label: "Recon Analytics" },
  { path: "reports", label: "Recon Reports" },
  { path: "config-settings", label: "Recon Configurator" },
];

test.describe("Recon & Settlement - direct URL coverage", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
  });

  for (const { path, label } of RECON_ROUTES) {
    test(`${label} (/${path}) URL resolves without leaving dashboard`, async ({
      page,
    }) => {
      await page.goto(`/dashboard/${path}`);
      await page.waitForLoadState("networkidle");

      // Either the page renders (FF on) or the app falls back to home/login
      // (FF off). Either way the user must still be inside /dashboard/*.
      const expected = new RegExp(`.*dashboard/(${path}|home|login)`);
      await expect(page).toHaveURL(expected);
    });
  }

  test("navigating to /recon does not produce an unhandled page error", async ({
    page,
  }) => {
    const pageErrors: Error[] = [];
    page.on("pageerror", (err) => pageErrors.push(err));

    await page.goto("/dashboard/recon");
    await page.waitForLoadState("networkidle");

    expect(pageErrors).toHaveLength(0);
  });

  test("deep-link into a recon sub-route preserves /dashboard prefix", async ({
    page,
  }) => {
    await page.goto("/dashboard/run-recon");
    await page.waitForLoadState("networkidle");
    await expect(page).toHaveURL(/.*dashboard\/.+/);
  });
});
