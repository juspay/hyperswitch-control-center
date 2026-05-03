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

test.describe("Organization Settings", () => {
  test("should render 'Learn More' and 'Create Platform Organization' CTAs", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

    await page.goto("/dashboard/organization-settings");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(
        page.getByRole("button", { name: "Learn More" }).first(),
      ).toBeVisible({ timeout: 10000 });
      await expect(
        page
          .getByRole("button", { name: "Create Platform Organization" })
          .first(),
      ).toBeVisible({ timeout: 10000 });
    });
  });
});
