import { test, expect } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  mockV2MerchantList,
} from "../support/commands";
import { HomePage } from "../support/pages/homepage/HomePage";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Visual Testing - Homepage", () => {
  test("homepage should match visual snapshot", async ({ page,context }) => {
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
      maxDiffPixelRatio: 0.01,
    });

    await homePage.homeV2.click();
    await expect(page).toHaveURL(/.*dashboard\/v2\/home/);

    await expect(page).toHaveScreenshot("homepage-v2.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await homePage.merchantDropdown.click();
    await expect(page).toHaveScreenshot("homepage-merchant-dropdown.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });

    await homePage.profileDropdown.click();
    await expect(page).toHaveScreenshot("homepage-profile-dropdown.png", {
      fullPage: true,
      animations: "disabled",
      maxDiffPixelRatio: 0.01,
    });
  });
});
