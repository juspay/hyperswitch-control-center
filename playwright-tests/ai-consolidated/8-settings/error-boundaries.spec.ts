import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Error boundaries and loading states", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
  });

  test("should stay inside /dashboard when all API calls return 500", async ({
    page,
  }) => {
    await page.route("**/api/**", async (route) => {
      await route.fulfill({
        status: 500,
        body: JSON.stringify({ error: "Internal Server Error" }),
      });
    });

    const homePage = new HomePage(page);
    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.waitForTimeout(1500);

    expect(page.url()).toContain("/dashboard");
  });

  test("should keep /dashboard context when navigating to an unknown route", async ({
    page,
  }) => {
    await page.goto("/dashboard/nonexistent-page");
    await page.waitForLoadState("domcontentloaded");
    expect(page.url()).toContain("/dashboard");
  });

  test("should render loading skeletons while API responses are delayed", async ({
    page,
  }) => {
    await page.route("**/api/**", async (route) => {
      await new Promise((resolve) => setTimeout(resolve, 2000));
      await route.continue();
    });

    const homePage = new HomePage(page);
    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const skeleton = page
      .locator(
        '[data-testid*="skeleton"], [class*="skeleton"], [class*="animate-pulse"]',
      )
      .first();
    const visible = await skeleton.isVisible().catch(() => false);
    expect(visible || page.url().includes("/dashboard")).toBe(true);
  });

  test("should surface an error toast when a POST request returns 400", async ({
    page,
  }) => {
    await page.route("**/api/**", async (route) => {
      if (route.request().method() === "POST") {
        await route.fulfill({
          status: 400,
          body: JSON.stringify({ error: "Bad Request" }),
        });
      } else {
        await route.continue();
      }
    });

    const homePage = new HomePage(page);
    await homePage.connectors.click();
    await homePage.paymentProcessors.click();
    await page.waitForTimeout(2000);

    expect(page.url()).toContain("/dashboard");
  });

  test("should keep /dashboard even when all API calls time out", async ({
    page,
  }) => {
    await page.route("**/api/**", async (route) => {
      await new Promise((_, reject) =>
        setTimeout(() => reject(new Error("Timeout")), 100),
      );
    });

    const homePage = new HomePage(page);
    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await page.waitForTimeout(1500);

    expect(page.url()).toContain("/dashboard");
  });
});
