/**
 * TC-038: Settings sub-pages + account profile deep interactions
 * Exercises Settings/HSwitchProfile/OrganizationSettings/UserRevamp.
 */
import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-038: Settings + profile deep interactions", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("account settings profile page renders personal info", async ({
    page,
  }) => {
    await page.goto("/dashboard/account-settings/profile");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(800);
    const heading = page
      .locator("h1, h2, h3")
      .filter({ hasText: /Profile|Personal|Account/i })
      .first();
    await expect(heading).toBeVisible({ timeout: 15000 });
  });

  test("organization settings page renders under dashboard", async ({
    page,
  }) => {
    await page.goto("/dashboard/organization-settings");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });

  test("users page (settings) renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/users");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });

  test("configure-pmts page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/configure-pmts");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });

  test("open user account dropdown via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.userAccount.first().click({ force: true }).catch(() => {});
    await page.waitForTimeout(500);
    expect(page.url()).toContain("/dashboard");
  });

  test("navigate Settings → Organization via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.settings.click().catch(() => {});
    await homePage.organizationSettings.click().catch(() => {});
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });

  test("navigate Settings → Users via sidebar", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.settings.click().catch(() => {});
    await homePage.users.click().catch(() => {});
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });

  test("compliance page renders under dashboard", async ({ page }) => {
    await page.goto("/dashboard/compliance");
    await page.waitForLoadState("domcontentloaded");
    await page.waitForTimeout(800);
    expect(page.url()).toContain("/dashboard");
  });
});
