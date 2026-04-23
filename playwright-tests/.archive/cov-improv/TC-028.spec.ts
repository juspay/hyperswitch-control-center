import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-028: Feature Flag Gated Components", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should show vault when feature flag enabled", async ({ page }) => {
    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.vault = true;
      }
      await route.fulfill({ response, json });
    });

    const homePage = new HomePage(page);
    await expect(homePage.vault).toBeVisible();
  });

  test("should hide vault when feature flag disabled", async ({ page }) => {
    // Fixed (Attempt 1): Route must be set up before navigation, use fulfill with full mock
    await page.route("**/dashboard/config/feature*", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          features: {
            vault: false,
            recon: false,
            surcharge: false,
            apm: false,
            test_processors: true,
          },
        }),
      });
    });

    await page.reload();
    await page.waitForLoadState("networkidle");

    const vaultNav = page.locator('[data-testid*="vault"]').first();
    await expect(vaultNav).toHaveCount(0);
  });

  test("should show recon when feature flag enabled", async ({ page }) => {
    // Fixed (Attempt 1): Use full mock response instead of modifying disposed response
    await page.route("**/dashboard/config/feature*", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          features: {
            vault: false,
            recon: true,
            surcharge: false,
            apm: false,
            test_processors: true,
          },
        }),
      });
    });

    await page.reload();
    await page.waitForLoadState("networkidle");

    const reconNav = page.locator('[data-testid*="recon"]').first();
    await expect(reconNav).toBeVisible();
  });

  test("should show surcharge menu when enabled", async ({ page }) => {
    // Fixed (Attempt 1): Mock surcharge feature flag with full response
    await page.route("**/dashboard/config/feature*", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          features: {
            vault: false,
            recon: false,
            surcharge: true,
            apm: false,
            test_processors: true,
          },
        }),
      });
    });

    await page.reload();
    await page.waitForLoadState("networkidle");

    const homePage = new HomePage(page);
    await expect(homePage.surchargeRouting).toBeVisible();
  });

  test("should handle combination of multiple feature flags", async ({
    page,
  }) => {
    // Fixed (Attempt 1): Added wait for networkidle to ensure feature flags are loaded
    await page.route("**/dashboard/config/feature*", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          features: {
            vault: true,
            recon: true,
            surcharge: true,
            apm: false,
            test_processors: true,
          },
        }),
      });
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
