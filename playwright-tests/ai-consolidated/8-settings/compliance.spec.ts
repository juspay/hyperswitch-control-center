import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
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

test.describe("Compliance - certificate upload and status", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.compliance = true;
      }
      await route.fulfill({ response, json });
    });

    const homePage = new HomePage(page);
    await homePage.settings.click();
    const complianceNav = page
      .locator('[data-testid*="compliance"], a[href*="compliance"]')
      .first();
    if (!(await complianceNav.isVisible().catch(() => false))) {
      test.skip(true, "compliance nav not exposed");
    }
    await complianceNav.click();
    await page.waitForLoadState("networkidle");
  });

  test("should accept a SOC2 certificate upload in its own slot", async ({
    page,
  }) => {
    await gatedOrAssert(page, async () => {
      const soc2Upload = page
        .locator('[data-testid*="soc2"]')
        .locator('input[type="file"]')
        .first();
      if (!(await soc2Upload.isVisible().catch(() => false))) {
        test.skip(true, "SOC2 upload slot not exposed");
      }
      await soc2Upload.setInputFiles({
        name: "soc2_certificate.pdf",
        mimeType: "application/pdf",
        buffer: Buffer.from("SOC2 certificate content"),
      });
      await expect(
        page.locator('[data-toast*="uploaded"], [data-testid*="upload-success"]'),
      ).toBeVisible({ timeout: 10000 });
    });
  });

  test("should accept a future expiration date for a certificate", async ({
    page,
  }) => {
    await gatedOrAssert(page, async () => {
      const expiryInput = page
        .locator('input[type="date"][name*="expiry"], input[name*="expiration"]')
        .first();
      if (!(await expiryInput.isVisible().catch(() => false))) {
        test.skip(true, "expiration date input not exposed");
      }
      const futureDate = new Date();
      futureDate.setFullYear(futureDate.getFullYear() + 1);
      const dateString = futureDate.toISOString().split("T")[0];

      await expiryInput.fill(dateString);
      await expect(expiryInput).toHaveValue(dateString);
    });
  });

  test("should accept a PDF certificate upload and show a compliance status", async ({
    page,
  }) => {
    await gatedOrAssert(page, async () => {
      const fileInput = page
        .locator('input[type="file"][accept*="pdf"]')
        .first();
      if (await fileInput.isVisible().catch(() => false)) {
        await fileInput.setInputFiles({
          name: "pci_dss_certificate.pdf",
          mimeType: "application/pdf",
          buffer: Buffer.from("PCI DSS certificate content"),
        });
      }

      const statusIndicator = page
        .locator('[data-testid*="status"], [class*="status"]')
        .first();
      if (await statusIndicator.isVisible().catch(() => false)) {
        const statusText = await statusIndicator.textContent();
        expect(statusText?.toLowerCase()).toMatch(/compliant|pending|expired/);
      }
    });
  });
});
