import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

type FlagSet = {
  vault: boolean;
  recon: boolean;
  surcharge: boolean;
  apm: boolean;
  test_processors: boolean;
};

async function mockFlags(
  page: import("@playwright/test").Page,
  flags: FlagSet,
): Promise<void> {
  await page.route("**/dashboard/config/feature*", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({ features: flags }),
    });
  });
}

test.describe("Feature-flag driven sidebar visibility", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should hide Vault from sidebar when vault flag is disabled", async ({
    page,
  }) => {
    await mockFlags(page, {
      vault: false,
      recon: false,
      surcharge: false,
      apm: false,
      test_processors: true,
    });
    await page.reload();
    await page.waitForLoadState("networkidle");

    const vaultNav = page.locator('[data-testid*="vault"]').first();
    await expect(vaultNav).toHaveCount(0);
  });

  test("should show Recon + Surcharge when their flags are enabled", async ({
    page,
  }) => {
    await mockFlags(page, {
      vault: false,
      recon: true,
      surcharge: true,
      apm: false,
      test_processors: true,
    });
    await page.reload();
    await page.waitForLoadState("networkidle");

    const homePage = new HomePage(page);
    const reconNav = page.locator('[data-testid*="recon"]').first();
    await expect(reconNav).toBeVisible();
    await expect(homePage.surchargeRouting).toBeVisible();
  });

  test("should hide APM when vault+recon+surcharge are enabled but APM is not", async ({
    page,
  }) => {
    await mockFlags(page, {
      vault: true,
      recon: true,
      surcharge: true,
      apm: false,
      test_processors: true,
    });
    await page.reload();
    await page.waitForLoadState("networkidle");

    const homePage = new HomePage(page);
    await expect(homePage.vault).toBeVisible();
    await expect(homePage.surchargeRouting).toBeVisible();

    const apmNav = page.locator('[data-testid*="apm"]').first();
    await expect(apmNav).toHaveCount(0);
  });
});
