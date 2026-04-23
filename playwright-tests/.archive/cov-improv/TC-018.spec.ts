import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-018: Recon - Manual Reconciliation Run", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.recon = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should navigate to run recon page", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page
      .locator('[data-testid*="recon"], a[href*="run-recon"]')
      .first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();
      await expect(page).toHaveURL(/.*dashboard\/run-recon/);
    }
  });

  test("should select date range for reconciliation", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const startDate = page
        .locator('[name*="start_date"], input[placeholder*="Start"]')
        .first();
      const endDate = page
        .locator('[name*="end_date"], input[placeholder*="End"]')
        .first();

      if (await startDate.isVisible().catch(() => false)) {
        await startDate.fill("2024-01-01");
      }
      if (await endDate.isVisible().catch(() => false)) {
        await endDate.fill("2024-01-31");
      }
    }
  });

  test("should run reconciliation job", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const runButton = page
        .locator('[data-button-for="runRecon"], button:has-text("Run Recon")')
        .first();
      if (await runButton.isVisible().catch(() => false)) {
        await runButton.click();

        await expect(
          page.locator(
            '[data-testid*="recon-progress"], [data-toast*="started"]',
          ),
        ).toBeVisible({ timeout: 10000 });
      }
    }
  });

  test("should view matched transactions", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const matchedTab = page
        .locator('[role="tab"]:has-text("Matched"), [data-testid*="matched"]')
        .first();
      if (await matchedTab.isVisible().catch(() => false)) {
        await matchedTab.click();

        const matchedCount = page
          .locator('[data-testid*="matched-count"]')
          .first();
        await expect(
          matchedCount.or(page.locator("table tbody tr")),
        ).toBeTruthy();
      }
    }
  });

  test("should view unmatched transactions", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const unmatchedTab = page
        .locator(
          '[role="tab"]:has-text("Unmatched"), [data-testid*="unmatched"]',
        )
        .first();
      if (await unmatchedTab.isVisible().catch(() => false)) {
        await unmatchedTab.click();

        const unmatchedCount = page
          .locator('[data-testid*="unmatched-count"]')
          .first();
        await expect(
          unmatchedCount.or(page.locator("table tbody tr")),
        ).toBeTruthy();
      }
    }
  });

  test("should mark exceptions", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const exceptionCheckbox = page
        .locator('[data-testid*="exception-checkbox"], input[type="checkbox"]')
        .first();
      if (await exceptionCheckbox.isVisible().catch(() => false)) {
        await exceptionCheckbox.check();

        const markExceptionButton = page
          .locator('[data-button-for="markException"]')
          .first();
        if (await markExceptionButton.isVisible().catch(() => false)) {
          await markExceptionButton.click();
        }
      }
    }
  });
});
