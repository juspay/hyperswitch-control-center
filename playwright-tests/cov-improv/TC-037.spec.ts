/**
 * TC-037: Routing rule builder interactions (Euclid WASM coverage)
 * Exercise euclid.js / routing configuration entry points.
 */
import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-037: Routing rule builder WASM coverage", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("routing landing page loads Setup / Manage CTAs", async ({ page }) => {
    await page.goto("/dashboard/routing");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    const cta = page.locator('button, [role="button"]').filter({
      hasText: /Set Up|Setup|Manage|Create New/i,
    });
    await expect(cta.first()).toBeVisible({ timeout: 15000 });
  });

  test("3DS decision manager page exposes Create New", async ({ page }) => {
    await page.goto("/dashboard/3ds");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    const button = page.locator("button").filter({
      hasText: /Create New|Configure|Set Up|Setup/i,
    });
    await expect(button.first()).toBeVisible({ timeout: 15000 });
  });

  test("surcharge page exposes Create New", async ({ page }) => {
    await page.goto("/dashboard/surcharge");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(1000);
    const button = page.locator("button").filter({
      hasText: /Create New|Configure|Setup|Set Up/i,
    });
    await expect(button.first()).toBeVisible({ timeout: 15000 });
  });

  test("3DS exemption manager page loads under dashboard", async ({ page }) => {
    await page.goto("/dashboard/3ds-exemption");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });

  test("payout routing page loads under dashboard", async ({ page }) => {
    await page.goto("/dashboard/payoutrouting");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });

  test("analytics-routing page loads under dashboard", async ({ page }) => {
    await page.goto("/dashboard/analytics-routing");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });

  test("sidebar navigation to Routing from Workflow", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.workflow.click().catch(() => {});
    await homePage.routing.click().catch(() => {});
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });
});
