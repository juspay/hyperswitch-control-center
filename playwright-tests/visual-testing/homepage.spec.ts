import { test, expect } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  mockV2MerchantList,
} from "../support/commands";
import { HomePage } from "../support/pages/homepage/HomePage";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Visual Testing - Homepage", () => {
  test("homepage should match visual snapshot", async ({ page, context }) => {
    const homePage = new HomePage(page);
    await mockV2MerchantList(page);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.waitForTimeout(500);
    await expect(page).toHaveURL(/.*dashboard\/home/);

    await expect(page).toHaveScreenshot("homepage.png", {
      fullPage: true,
      animations: "disabled",
      mask: [
        page.locator(".text-left.flex.gap-2.justify-between"),
        page.locator(".flex.flex-col.gap-7 ").locator(".flex.items-center.gap-2"),
        page.getByRole('button', { name: 'playwright-' })
      ],
    });

    await homePage.homeV2.click();
    await expect(page).toHaveURL(/.*dashboard\/v2\/home/);

    await expect(page).toHaveScreenshot("homepage-v2.png", {
      fullPage: true,
      animations: "disabled",
      mask: [
        page.locator(".text-left.flex.gap-2.justify-between"),
        page.getByRole('button', { name: 'playwright-' })
      ],
    });

    await homePage.merchantDropdown.click();
    await expect(page).toHaveScreenshot("homepage-merchant-dropdown.png", {
      fullPage: true,
      animations: "disabled",
      mask: [
        page.locator(".text-left.flex.gap-2.justify-between"),
        page.locator('[data-dropdown="dropdown"]').locator(".flex.justify-between.items-center.w-full"),
        page.getByRole('button', { name: 'playwright-' })
      ],
    });

    await homePage.profileDropdown.click();
    await expect(page).toHaveScreenshot("homepage-profile-dropdown.png", {
      fullPage: true,
      animations: "disabled",
      mask: [
        page.locator(".text-left.flex.gap-2.justify-between"),
        page.getByRole('button', { name: 'playwright-' })
      ],
    });
  });
});
