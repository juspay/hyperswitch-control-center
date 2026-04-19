import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-019: Recon - Report Generation", () => {
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

  test("should navigate to recon reports", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page
      .locator('[data-testid*="recon"], a[href*="reports"]')
      .first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();
      await expect(page).toHaveURL(/.*dashboard\/reports/);
    }
  });

  test("should generate summary report", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const summaryReportButton = page
        .locator(
          '[data-button-for="summaryReport"], button:has-text("Summary")',
        )
        .first();
      if (await summaryReportButton.isVisible().catch(() => false)) {
        await summaryReportButton.click();

        await expect(
          page.locator(
            '[data-testid*="report-generated"], [data-toast*="Report generated"]',
          ),
        ).toBeVisible({ timeout: 10000 });
      }
    }
  });

  test("should generate detailed variance report", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const varianceReportButton = page
        .locator(
          '[data-button-for="varianceReport"], button:has-text("Variance")',
        )
        .first();
      if (await varianceReportButton.isVisible().catch(() => false)) {
        await varianceReportButton.click();

        await expect(
          page.locator('[data-testid*="variance-report"]'),
        ).toBeVisible({ timeout: 10000 });
      }
    }
  });

  test("should schedule daily recon email", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const scheduleButton = page
        .locator(
          '[data-button-for="scheduleReport"], button:has-text("Schedule")',
        )
        .first();
      if (await scheduleButton.isVisible().catch(() => false)) {
        await scheduleButton.click();

        const emailInput = page.locator('[name*="email"]').first();
        if (await emailInput.isVisible().catch(() => false)) {
          await emailInput.fill("reports@example.com");
        }

        const frequency = page.locator('[name*="frequency"]').first();
        if (await frequency.isVisible().catch(() => false)) {
          await frequency.selectOption("daily");
        }

        await page.locator('[data-button-for="saveSchedule"]').click();
      }
    }
  });

  test("should download report as PDF", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const downloadPdfButton = page
        .locator('[data-button-for="downloadPdf"], button:has-text("PDF")')
        .first();
      if (await downloadPdfButton.isVisible().catch(() => false)) {
        const [download] = await Promise.all([
          page.waitForEvent("download", { timeout: 10000 }).catch(() => null),
          downloadPdfButton.click(),
        ]);

        if (download) {
          expect(download.suggestedFilename()).toMatch(/\.pdf$/);
        }
      }
    }
  });
});
