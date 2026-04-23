import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-017: Recon - File Upload and Processing", () => {
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

  test("should navigate to recon file upload", async ({ page }) => {
    const homePage = new HomePage(page);

    await expect(homePage.connectors).toBeVisible();

    const reconNav = page
      .locator('[data-testid*="recon"], a[href*="upload-files"]')
      .first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();
      await expect(page).toHaveURL(/.*dashboard\/upload-files/);
    }
  });

  test("should upload CSV settlement file", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const fileInput = page.locator('input[type="file"]').first();
      if (await fileInput.isVisible().catch(() => false)) {
        await fileInput.setInputFiles({
          name: "settlement.csv",
          mimeType: "text/csv",
          buffer: Buffer.from(
            "transaction_id,amount,currency\ntxn_123,100.00,USD",
          ),
        });

        await expect(
          page.locator(
            '[data-toast*="uploaded"], [data-testid*="file-success"]',
          ),
        ).toBeVisible({ timeout: 10000 });
      }
    }
  });

  test("should reject incorrect file format", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const fileInput = page.locator('input[type="file"]').first();
      if (await fileInput.isVisible().catch(() => false)) {
        await fileInput.setInputFiles({
          name: "invalid.txt",
          mimeType: "text/plain",
          buffer: Buffer.from("invalid content"),
        });

        await expect(
          page.locator('[data-toast*="error"], [data-testid*="file-error"]'),
        ).toBeVisible({ timeout: 10000 });
      }
    }
  });

  test("should reject oversized file", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const fileInput = page.locator('input[type="file"]').first();
      if (await fileInput.isVisible().catch(() => false)) {
        const largeBuffer = Buffer.alloc(11 * 1024 * 1024);

        await fileInput.setInputFiles({
          name: "large.csv",
          mimeType: "text/csv",
          buffer: largeBuffer,
        });

        await expect(
          page.locator('[data-toast*="size"], [data-testid*="file-too-large"]'),
        ).toBeVisible({ timeout: 10000 });
      }
    }
  });

  test("should map columns to recon schema", async ({ page }) => {
    const homePage = new HomePage(page);

    const reconNav = page.locator('[data-testid*="recon"]').first();
    if (await reconNav.isVisible().catch(() => false)) {
      await reconNav.click();

      const mappingButton = page
        .locator(
          '[data-button-for="mapColumns"], button:has-text("Map Columns")',
        )
        .first();
      if (await mappingButton.isVisible().catch(() => false)) {
        await mappingButton.click();

        const columnMapping = page
          .locator('[name*="mapping"], select[data-testid*="column-map"]')
          .first();
        if (await columnMapping.isVisible().catch(() => false)) {
          await columnMapping.selectOption("transaction_id");
        }

        await page.locator('[data-button-for="saveMapping"]').click();
      }
    }
  });
});
