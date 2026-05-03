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

  for (const route of routes) {
    test(`deep link ${route} resolves without leaving /dashboard`, async ({
      page,
    }) => {
      await page.goto(`/dashboard${route}`);
      await page.waitForLoadState("domcontentloaded");
      await page.waitForTimeout(800);
      expect(page.url()).toContain("/dashboard");
    });
  }
});
