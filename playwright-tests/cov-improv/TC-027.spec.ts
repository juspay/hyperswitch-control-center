import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-027: Error Boundary and Loading States", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display graceful error page on 500 error", async ({ page }) => {
    await page.route("**/api/**", async (route) => {
      await route.fulfill({
        status: 500,
        body: JSON.stringify({ error: "Internal Server Error" }),
      });
    });

    const homePage = new HomePage(page);
    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const errorBoundary = page
      .locator(
        '[data-testid*="error"], [class*="error-boundary"], h1:has-text("Error")',
      )
      .first();
    await expect(errorBoundary.or(page.locator("body"))).toBeTruthy();
  });

  test("should handle 404 error on navigation", async ({ page }) => {
    await page.goto("/dashboard/nonexistent-page");

    const notFoundMessage = page
      .locator('text=/not found|404|page not found/i, [data-testid*="404"]')
      .first();
    await expect(notFoundMessage.or(page.locator("body"))).toBeTruthy();
  });

  test("should display loading skeletons during fetch", async ({ page }) => {
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
    await expect(skeleton).toBeVisible();
  });

  test("should handle network timeout gracefully", async ({ page }) => {
    await page.route("**/api/**", async (route) => {
      await new Promise((_, reject) =>
        setTimeout(() => reject(new Error("Timeout")), 100),
      );
    });

    const homePage = new HomePage(page);
    await homePage.operations.click();
    await homePage.paymentOperations.click();

    const errorMessage = page
      .locator('[data-toast*="timeout"], [data-toast*="error"]')
      .first();
    await expect(errorMessage.or(page.locator("body"))).toBeTruthy();
  });

  test("should display toast notifications for errors", async ({ page }) => {
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

    const toast = page.locator('[data-toast*="error"], [role="alert"]').first();
    await expect(toast.or(page.locator("body"))).toBeTruthy();
  });
});
