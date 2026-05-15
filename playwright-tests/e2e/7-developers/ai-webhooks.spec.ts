import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { Webhooks } from "../../support/pages/developers/Webhooks";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function gatedOrAssert(
  page: Page,
  assertion: () => Promise<void>,
): Promise<void> {
  const webhooks = new Webhooks(page);
  if (await webhooks.goToHomeFallback.isVisible().catch(() => false)) {
    test.skip(true, "page gated by feature flag — renders Go to Home fallback");
  }
  await assertion();
}

test.describe("Webhooks page", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    await homePage.developer.click();
    await homePage.webhooks.click();
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);
  });

  test("should render Webhooks heading, Search by ID input, and Object ID filter", async ({
    page,
  }) => {
    const webhooks = new Webhooks(page);
    await gatedOrAssert(page, async () => {
      await expect(webhooks.webhookHeading).toBeVisible({ timeout: 10000 });
      await expect(webhooks.searchByIdInput).toBeVisible({ timeout: 10000 });
      await expect(webhooks.objectIdFilter).toBeVisible({ timeout: 10000 });
    });
  });
});
