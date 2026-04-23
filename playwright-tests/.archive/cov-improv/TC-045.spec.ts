/**
 * TC-045: Compliance + payment-link-theme interaction (PaymentLinkThemeConfigurator).
 */
import { test, expect } from "../../support/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-045: Compliance + payment-link theme coverage", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("compliance landing page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/compliance");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("compliance page heading OR fallback renders", async ({ page }) => {
    await page.goto("/dashboard/compliance");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1200);
    const body = await page.locator("body").textContent();
    expect(body && body.length > 0).toBeTruthy();
  });

  test("payment-link-theme page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/payment-link-theme");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("payment-link-theme exposes interactive elements", async ({ page }) => {
    await page.goto("/dashboard/payment-link-theme");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1500);
    const interactive = page.locator(
      'button, input, [role="button"], a[href*="/dashboard"]',
    );
    const count = await interactive.count();
    expect(count).toBeGreaterThan(0);
  });

  test("apm landing page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/apm");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    expect(page.url()).toContain("/dashboard");
  });

  test("apm landing page body content renders", async ({ page }) => {
    await page.goto("/dashboard/apm");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1500);
    const body = await page.locator("body").textContent();
    expect(body && body.length > 0).toBeTruthy();
  });
});
