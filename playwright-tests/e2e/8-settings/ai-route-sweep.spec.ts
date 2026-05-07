/**
 * Dashboard route coverage sweep.
 * Deep-links every known /dashboard/* route to exercise router branches
 * in app.js (React Router + feature-flag gating). Previously TC-036.
 */
import { test, expect } from "../../support/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

const routes = [
  "/home",
  "/payments",
  "/refunds",
  "/disputes",
  "/payouts",
  "/customers",
  "/connectors",
  "/payoutconnectors",
  "/3ds-authenticators",
  "/fraud-risk-management",
  "/pm-authentication-processor",
  "/tax-processor",
  "/billing-processor",
  "/vault-processor",
  "/analytics-payments",
  "/analytics-refunds",
  "/analytics-disputes",
  "/analytics-authentication",
  "/analytics-routing",
  "/new-analytics",
  "/performance-monitor",
  "/routing",
  "/3ds",
  "/3ds-exemption",
  "/surcharge",
  "/payoutrouting",
  "/vault-customers-tokens",
  "/vault-onboarding",
  "/developer-api-keys",
  "/webhooks",
  "/payment-settings",
  "/configure-pmts",
  "/organization-settings",
  "/users",
  "/compliance",
  "/payment-link-theme",
  "/recon",
  "/recon-analytics",
  "/run-recon",
  "/upload-files",
  "/reports",
  "/config-settings",
  "/apm",
  "/account-settings/profile",
];

test.describe("Dashboard route coverage sweep", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("deep link all routes resolve without leaving /dashboard", async ({
    page,
  }) => {
    // Sweeping ~40 routes with a per-route load + settle adds up; CI runners
    // need significantly more headroom than the previous 60s budget.
    test.setTimeout(180000);
    for (const route of routes) {
      await page.goto(`/dashboard${route}`, { timeout: 30000 });
      await page.waitForLoadState("domcontentloaded");
      await page.waitForTimeout(800);
      expect(page.url()).toContain(`/dashboard${route}`);
    }
  });
});
