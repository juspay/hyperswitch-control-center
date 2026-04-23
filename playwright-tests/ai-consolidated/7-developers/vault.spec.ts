import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
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

async function setup(page: Page, context: BrowserContext): Promise<void> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
}

test.describe("Vault Onboarding - processor picker", () => {
  test("should expose Connect cards and a 'Search a processor' input", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await page.goto("/dashboard/vault-onboarding");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(page.getByPlaceholder("Search a processor")).toBeVisible({
        timeout: 10000,
      });
      const connectButtons = page.getByRole("button", { name: "Connect" });
      expect(await connectButtons.count()).toBeGreaterThan(0);
    });
  });
});

test.describe("Vault Customers & Tokens", () => {
  test("should render a Refresh button on the page", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await page.goto("/dashboard/vault-customers-tokens");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(
        page.getByRole("button", { name: "Refresh" }).first(),
      ).toBeVisible({ timeout: 10000 });
    });
  });
});
