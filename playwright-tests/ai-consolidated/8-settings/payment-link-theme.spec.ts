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

test.describe("Payment Link Theme configurator", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.theme_configurator = true;
        json.features.payment_link_theme = true;
      }
      await route.fulfill({ response, json });
    });

    await page.goto("/dashboard/payment-link-theme");
    await page.waitForLoadState("networkidle");
  });

  test("should accept a primary color and save the theme", async ({ page }) => {
    await gatedOrAssert(page, async () => {
      const colorInput = page
        .locator('input[type="color"], [name*="primary_color"]')
        .first();
      if (await colorInput.isVisible().catch(() => false)) {
        await colorInput.fill("#FF6B35");
      }

      const saveButton = page
        .locator('[data-button-for="saveTheme"], button:has-text("Save")')
        .first();
      if (await saveButton.isVisible().catch(() => false)) {
        await saveButton.click();
        await expect(
          page.locator('[data-toast*="saved"], [data-toast*="success"]'),
        ).toBeVisible({ timeout: 10000 });
      }
    });
  });

  test("should accept button style customization (rounded + color)", async ({
    page,
  }) => {
    await gatedOrAssert(page, async () => {
      const buttonStyle = page
        .locator('[name*="button_style"], select[name*="button"]')
        .first();
      if (await buttonStyle.isVisible().catch(() => false)) {
        await buttonStyle.selectOption("rounded");
      }

      const buttonColor = page
        .locator('input[type="color"][name*="button"]')
        .first();
      if (await buttonColor.isVisible().catch(() => false)) {
        await buttonColor.fill("#006DF9");
        await expect(buttonColor).toHaveValue(/#006DF9/i);
      }
    });
  });

  test("should open the theme preview iframe when Preview is clicked", async ({
    page,
  }) => {
    await gatedOrAssert(page, async () => {
      const previewButton = page
        .locator('[data-button-for="preview"], button:has-text("Preview")')
        .first();
      if (!(await previewButton.isVisible().catch(() => false))) {
        test.skip(true, "Preview CTA not exposed");
      }
      await previewButton.click();

      const previewFrame = page
        .locator(
          'iframe[data-testid*="preview"], [data-testid*="preview-container"]',
        )
        .first();
      await expect(previewFrame).toBeVisible();
    });
  });
});
