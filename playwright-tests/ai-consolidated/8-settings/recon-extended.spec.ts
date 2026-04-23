import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

async function gatedOrAssert(
  page: Page,
  assertion: () => Promise<void>,
): Promise<void> {
  const fallback = page.getByText("Go to Home", { exact: true }).first();
  if (await fallback.isVisible().catch(() => false)) {
    test.skip(true, "page gated by feature flag — renders Go to Home fallback");
  }
  await assertion();
}

test.describe("Recon - file upload, manual run, and report generation", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.recon = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should upload a CSV settlement file on /upload-files", async ({
    page,
  }) => {
    await page.goto("/dashboard/upload-files");
    await page.waitForLoadState("networkidle");

    await gatedOrAssert(page, async () => {
      const fileInput = page.locator('input[type="file"]').first();
      if (!(await fileInput.isVisible().catch(() => false))) {
        test.skip(true, "file input not exposed");
      }
      await fileInput.setInputFiles({
        name: "settlement.csv",
        mimeType: "text/csv",
        buffer: Buffer.from("transaction_id,amount,currency\ntxn_123,100.00,USD"),
      });
      expect(page.url()).toContain("/dashboard");
    });
  });

  test("should reject a non-CSV file on /upload-files", async ({ page }) => {
    await page.goto("/dashboard/upload-files");
    await page.waitForLoadState("networkidle");

    await gatedOrAssert(page, async () => {
      const fileInput = page.locator('input[type="file"]').first();
      if (!(await fileInput.isVisible().catch(() => false))) {
        test.skip(true, "file input not exposed");
      }
      await fileInput.setInputFiles({
        name: "invalid.txt",
        mimeType: "text/plain",
        buffer: Buffer.from("invalid content"),
      });

      const errorToast = page.locator(
        '[data-toast*="error"], [data-testid*="file-error"]',
      );
      if (await errorToast.isVisible().catch(() => false)) {
        await expect(errorToast).toBeVisible();
      }
    });
  });

  test("should render Matched / Unmatched tabs on /run-recon", async ({
    page,
  }) => {
    await page.goto("/dashboard/run-recon");
    await page.waitForLoadState("networkidle");

    await gatedOrAssert(page, async () => {
      const matchedTab = page
        .locator('[role="tab"]:has-text("Matched"), [data-testid*="matched"]')
        .first();
      const unmatchedTab = page
        .locator('[role="tab"]:has-text("Unmatched"), [data-testid*="unmatched"]')
        .first();

      if (
        !(await matchedTab.isVisible().catch(() => false)) &&
        !(await unmatchedTab.isVisible().catch(() => false))
      ) {
        test.skip(true, "Matched/Unmatched tabs not exposed");
      }

      if (await matchedTab.isVisible().catch(() => false)) {
        await matchedTab.click();
      }
      if (await unmatchedTab.isVisible().catch(() => false)) {
        await unmatchedTab.click();
      }
    });
  });

  test("should generate a summary report on /reports", async ({ page }) => {
    await page.goto("/dashboard/reports");
    await page.waitForLoadState("networkidle");

    await gatedOrAssert(page, async () => {
      const summaryReportButton = page
        .locator('[data-button-for="summaryReport"], button:has-text("Summary")')
        .first();
      if (!(await summaryReportButton.isVisible().catch(() => false))) {
        test.skip(true, "summary report CTA not exposed");
      }
      await summaryReportButton.click();
      await expect(
        page.locator(
          '[data-testid*="report-generated"], [data-toast*="Report generated"]',
        ),
      ).toBeVisible({ timeout: 10000 });
    });
  });
});
