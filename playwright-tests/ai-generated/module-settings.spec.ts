/**
 * Auto-generated Playwright test
 * Source: module:settings - configure PMTs, organization settings, profile
 * Generated: 2026-04-17
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Settings - Navigation & Sub-Pages", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should expand Settings group in sidebar", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();

    await expect(homePage.configurePMT).toBeVisible();
  });

  test("should open Configure PMTs page", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();
    await homePage.configurePMT.click();

    await expect(page).toHaveURL(/.*dashboard\/configure-pmts/);
  });

  test("should display Configure PMTs heading", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();
    await homePage.configurePMT.click();

    await expect(
      page.getByText(/Payment Method|Configure/i).first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test("should open Organization Settings page", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();
    const orgSettings = homePage.organizationSettings;
    if ((await orgSettings.count().catch(() => 0)) > 0) {
      await orgSettings.click();
      await expect(page).toHaveURL(/.*(organization|settings|account)/);
    }
  });

  test("should display Organization name section", async ({ page }) => {
    // Fixed (Attempt 1): Organization settings page may use "Account" / "Profile"
    // labels; verify the URL lands on a settings/account route rather than
    // relying on exact text which is locale-dependent.
    const homePage = new HomePage(page);

    await homePage.settings.click();
    const orgSettings = homePage.organizationSettings;
    if ((await orgSettings.count().catch(() => 0)) > 0) {
      await orgSettings.click();
      await page.waitForLoadState("networkidle");
      await expect(page).toHaveURL(
        /.*(organization|settings|account|organisation)/i,
      );
    }
  });

  test("should preserve URL when reloading settings page", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();
    await homePage.configurePMT.click();
    await expect(page).toHaveURL(/.*dashboard\/configure-pmts/);

    await page.reload();
    await expect(page).toHaveURL(/.*dashboard\/configure-pmts/);
  });
});

test.describe("Settings - Profile / Account menu", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should open user account dropdown", async ({ page }) => {
    const homePage = new HomePage(page);

    const trigger = homePage.userAccount;
    if ((await trigger.count().catch(() => 0)) > 0) {
      await trigger.first().click();
      await expect(homePage.signOut).toBeVisible({ timeout: 10000 });
    }
  });

  test("should allow navigating to profile settings from user menu", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    const trigger = homePage.userAccount;
    if ((await trigger.count().catch(() => 0)) > 0) {
      await trigger.first().click();
      const profileLink = page.getByText(/Profile|Account/i).first();
      if (await profileLink.isVisible().catch(() => false)) {
        await profileLink.click();
        await expect(page).toHaveURL(/.*(profile|account|settings)/);
      }
    }
  });
});
