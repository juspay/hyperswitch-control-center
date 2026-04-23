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

test.describe("Processor list pages — Request CTA and search", () => {
  const processorRoutes = [
    { path: "3ds-authenticators", heading: "3DS Authenticators" },
    { path: "pm-authentication-processor", heading: "PM Auth Processor" },
    { path: "tax-processor", heading: "Tax Processor" },
    { path: "billing-processor", heading: "Billing Processor" },
    { path: "vault-processor", heading: "Vault Processor" },
  ];

  for (const { path, heading } of processorRoutes) {
    test(`${heading} page exposes 'Request a Processor' CTA and typeable search input`, async ({
      page,
      context,
    }) => {
      await setup(page, context);
      await page.goto(`/dashboard/${path}`);
      await page.waitForLoadState("networkidle");
      await page.waitForTimeout(1000);

      await gatedOrAssert(page, async () => {
        await expect(
          page.getByRole("button", { name: "Request a Processor" }).first(),
        ).toBeVisible({ timeout: 10000 });

        const search = page.getByPlaceholder("Search a processor");
        await expect(search).toBeVisible({ timeout: 10000 });
        await search.fill("stripe");
        await expect(search).toHaveValue("stripe");
      });
    });
  }
});
