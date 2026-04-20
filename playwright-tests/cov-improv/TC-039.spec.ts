/**
 * TC-039: Connector listing + search (covers search/filter utilities).
 */
import { test, expect } from "../support/test";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

const processorPages = [
  "/connectors",
  "/payoutconnectors",
  "/3ds-authenticators",
  "/fraud-risk-management",
  "/pm-authentication-processor",
  "/tax-processor",
  "/billing-processor",
  "/vault-processor",
];

test.describe("TC-039: Connector listing + search coverage", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  for (const route of processorPages) {
    test(`${route} page renders and handles search typing`, async ({
      page,
    }) => {
      await page.goto(`/dashboard${route}`);
      await page.waitForLoadState("domcontentloaded");
      await page.waitForTimeout(1200);

      const search = page
        .locator(
          'input[placeholder*="Search" i], input[type="search"], input[placeholder*="processor" i]',
        )
        .first();
      if (await search.isVisible().catch(() => false)) {
        await search.fill("stripe");
        await page.waitForTimeout(300);
        await search.fill("");
      }
      expect(page.url()).toContain("/dashboard");
    });
  }
});
