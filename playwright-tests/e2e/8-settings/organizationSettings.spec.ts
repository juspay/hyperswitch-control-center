import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { OrganizationSettingsPage } from "../../support/pages/settings/OrganizationSettingsPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function gatedOrAssert(
  page: Page,
  assertion: () => Promise<void>,
): Promise<void> {
  const orgSettings = new OrganizationSettingsPage(page);
  if (await orgSettings.goToHomeFallback.isVisible().catch(() => false)) {
    test.skip(true, "page gated by feature flag — renders Go to Home fallback");
  }
  await assertion();
}

test.describe("Organization Settings", () => {
  test("should render 'Learn More' and 'Create Platform Organization' CTAs", async ({
    page,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

    const orgSettings = new OrganizationSettingsPage(page);
    await orgSettings.visit();
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(orgSettings.learnMoreButton).toBeVisible({ timeout: 10000 });
      await expect(orgSettings.createPlatformOrganizationButton).toBeVisible({
        timeout: 10000,
      });
    });
  });
});
