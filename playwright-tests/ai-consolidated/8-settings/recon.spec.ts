import { test, expect } from "../../support/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

const RECON_ROUTES: ReadonlyArray<{ path: string; label: string }> = [
  { path: "recon", label: "Reconciliation landing" },
  { path: "upload-files", label: "Upload Recon Files" },
  { path: "run-recon", label: "Run Recon" },
  { path: "recon-analytics", label: "Recon Analytics" },
  { path: "reports", label: "Recon Reports" },
  { path: "config-settings", label: "Recon Configurator" },
];

test.describe("Recon & Settlement - feature-flag gated routes", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
  });

  for (const { path, label } of RECON_ROUTES) {
    test(`${label} (/${path}) resolves without leaving /dashboard and without page errors`, async ({
      page,
    }) => {
      const pageErrors: Error[] = [];
      page.on("pageerror", (err) => pageErrors.push(err));

      await page.goto(`/dashboard/${path}`);
      await page.waitForLoadState("networkidle");

      const expected = new RegExp(`.*dashboard/(${path}|home|login)`);
      await expect(page).toHaveURL(expected);
      expect(pageErrors).toHaveLength(0);
    });
  }
});
