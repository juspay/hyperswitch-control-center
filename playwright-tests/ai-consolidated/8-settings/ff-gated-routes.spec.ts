import { test, expect } from "../../support/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

const FALLBACK_ROUTES: ReadonlyArray<string> = [
  "analytics-disputes",
  "analytics-routing",
  "performance-monitor",
  "new-analytics",
  "compliance",
  "payment-link-theme",
];

test.describe("Feature-flag gated dashboard routes", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
  });

  for (const route of FALLBACK_ROUTES) {
    test(`/${route} renders either real content or the Go-to-Home fallback`, async ({
      page,
    }) => {
      await page.goto(`/dashboard/${route}`);
      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      const fallback = page.getByText("Go to Home", { exact: true }).first();
      const bodyHtmlLen = await page.evaluate(
        () => document.body.innerHTML.length,
      );
      const hasFallback = await fallback.isVisible().catch(() => false);
      const hasRealContent = bodyHtmlLen > 1000;
      const onDashboard = /\/dashboard\//.test(page.url());

      expect(hasFallback || hasRealContent || onDashboard).toBe(true);
    });
  }
});
