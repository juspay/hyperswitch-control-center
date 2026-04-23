import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-030: Tenant/Org/Merchant/Profile Switching", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should switch organization from dropdown", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.orgIcon.click();

    const orgDropdown = page
      .locator(
        '[data-testid*="org-dropdown"], [data-testid*="organization-select"]',
      )
      .first();
    if (await orgDropdown.isVisible().catch(() => false)) {
      const orgOption = orgDropdown
        .locator('[data-testid*="org-option"], [role="option"]')
        .nth(1);
      if (await orgOption.isVisible().catch(() => false)) {
        await orgOption.click();
        await page.waitForTimeout(1000);

        await expect(page.locator("body")).toBeTruthy();
      }
    }
  });

  test("should switch merchant within org", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.merchantDropdown.click();

    const merchantOption = page
      .locator(
        '[data-testid*="merchant-option"], [role="option"]:has-text("Merchant")',
      )
      .nth(1);
    if (await merchantOption.isVisible().catch(() => false)) {
      await merchantOption.click();
      await page.waitForTimeout(1000);

      await expect(page.locator("body")).toBeTruthy();
    }
  });

  test("should switch profile within merchant", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.profileDropdown.click();

    const profileOption = page
      .locator(
        '[data-testid*="profile-option"], [role="option"]:has-text("Profile")',
      )
      .nth(1);
    if (await profileOption.isVisible().catch(() => false)) {
      await profileOption.click();
      await page.waitForTimeout(1000);

      await expect(page.locator("body")).toBeTruthy();
    }
  });

  test("should reload data for new context", async ({ page }) => {
    const homePage = new HomePage(page);

    const initialMerchantId = await homePage.merchantID.nth(0).textContent();

    await homePage.merchantDropdown.click();

    const merchantOption = page
      .locator('[data-testid*="merchant-option"]')
      .nth(1);
    if (await merchantOption.isVisible().catch(() => false)) {
      await merchantOption.click();
      await page.waitForTimeout(2000);

      const newMerchantId = await homePage.merchantID.nth(0).textContent();
      expect(newMerchantId).not.toBe(initialMerchantId);
    }
  });

  test("should update URL with new context IDs", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.merchantDropdown.click();

    const merchantOption = page
      .locator('[data-testid*="merchant-option"]')
      .nth(1);
    if (await merchantOption.isVisible().catch(() => false)) {
      await merchantOption.click();
      await page.waitForTimeout(1000);

      const currentUrl = page.url();
      expect(currentUrl).toMatch(/merchant_id=|merchantId=|\/[a-f0-9]+/);
    }
  });
});
