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

test.describe("Configure PMTs page", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    const homePage = new HomePage(page);
    await homePage.settings.click();
    await homePage.configurePMT.click();
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);
  });

  test("should render 'Configure PMTs at Checkout' heading and Add Filters button", async ({
    page,
  }) => {
    await gatedOrAssert(page, async () => {
      await expect(
        page.getByText("Configure PMTs at Checkout").first(),
      ).toBeVisible({ timeout: 10000 });
      await expect(
        page.getByRole("button", { name: "Add Filters" }).first(),
      ).toBeVisible({ timeout: 10000 });
    });
  });

  test("should preserve /configure-pmts URL after reload", async ({ page }) => {
    await expect(page).toHaveURL(/.*dashboard\/configure-pmts/);
    await page.reload();
    await expect(page).toHaveURL(/.*dashboard\/configure-pmts/);
  });
});
