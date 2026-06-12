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

    // Freeze time so the greeting ("Good morning"/"afternoon"/"evening")
    // is deterministic across runs and can be snapshotted without masking.
    await page.clock.setFixedTime(new Date("2026-01-15T03:30:00Z"));

    await mockV2MerchantList(page);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.waitForTimeout(500);
    await expect(page).toHaveURL(/.*dashboard\/home/);

    await expect(page).toHaveScreenshot("homepage.png", {
      fullPage: true,
      animations: "disabled",
      mask: [homePage.navHeaderMask, homePage.merchantNameButton, page.locator('div.flex.items-center.gap-2').nth(9), page.locator('div.flex.items-center.gap-2').nth(10)],
    });

    await homePage.homeV2.click();
    await expect(page).toHaveURL(/.*dashboard\/v2\/home/);

    await expect(page).toHaveScreenshot("homepage-v2.png", {
      fullPage: true,
      animations: "disabled",
      mask: [homePage.navHeaderMask, homePage.merchantNameButton],
    });

    await homePage.merchantDropdown.click();
    await expect(page).toHaveScreenshot("homepage-merchant-dropdown.png", {
      fullPage: true,
      animations: "disabled",
      mask: [
        homePage.navHeaderMask,
        homePage.merchantDropdownItemsMask,
        homePage.merchantNameButton,
      ],
    });

    await homePage.profileDropdown.click();
    await expect(page).toHaveScreenshot("homepage-profile-dropdown.png", {
      fullPage: true,
      animations: "disabled",
      mask: [homePage.navHeaderMask, homePage.merchantNameButton],
    });
  });
});