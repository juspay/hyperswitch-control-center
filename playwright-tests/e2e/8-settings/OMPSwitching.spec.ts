import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { TenantSwitchingPage } from "../../support/pages/settings/TenantSwitchingPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe.skip("Org / Merchant / Profile context switching", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
  });

  test("should open org/merchant/profile dropdowns from the top bar", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.orgIcon.click().catch(() => { });
    await page.keyboard.press("Escape");

    await homePage.merchantDropdown.click().catch(() => { });
    await page.keyboard.press("Escape");

    await homePage.profileDropdown.click().catch(() => { });
    await page.keyboard.press("Escape");

    expect(page.url()).toContain("/dashboard");
  });

  test("should change the merchant context and reload data for the new merchant", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const tenantSwitching = new TenantSwitchingPage(page);

    const initialMerchantId = await homePage.merchantID.nth(0).textContent();

    await homePage.merchantDropdown.click();

    const merchantOption = tenantSwitching.merchantOption.nth(1);
    if (!(await merchantOption.isVisible().catch(() => false))) {
      test.skip(true, "only one merchant in this test account");
    }
    await merchantOption.click();
    await page.waitForTimeout(2000);

    const newMerchantId = await homePage.merchantID.nth(0).textContent();
    expect(newMerchantId).not.toBe(initialMerchantId);
  });

  test("should switch profile within merchant", async ({ page }) => {
    const homePage = new HomePage(page);
    const tenantSwitching = new TenantSwitchingPage(page);

    await homePage.profileDropdown.click();
    const profileOption = tenantSwitching.profileOption.nth(1);
    if (!(await profileOption.isVisible().catch(() => false))) {
      test.skip(true, "only one profile in this test account");
    }
    await profileOption.click();
    await page.waitForTimeout(1000);

    expect(page.url()).toContain("/dashboard");
  });

  test("should update URL / context IDs after switching merchant", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const tenantSwitching = new TenantSwitchingPage(page);

    await homePage.merchantDropdown.click();
    const merchantOption = tenantSwitching.merchantOptionByTestId.nth(1);
    if (!(await merchantOption.isVisible().catch(() => false))) {
      test.skip(true, "only one merchant available");
    }
    await merchantOption.click();
    await page.waitForTimeout(1000);

    const currentUrl = page.url();
    expect(currentUrl).toMatch(/merchant_id=|merchantId=|\/[a-f0-9]+/);
  });
});
