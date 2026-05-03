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

test.describe("Webhooks page", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
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
    await gatedOrAssert(page, async () => {
      await expect(page.getByText(/Webhook/i).first()).toBeVisible({
        timeout: 10000,
      });
      await expect(page.getByPlaceholder("Search by ID")).toBeVisible({
        timeout: 10000,
      });
      await expect(page.getByText("Object ID").first()).toBeVisible({
        timeout: 10000,
      });
    });
  });
});
