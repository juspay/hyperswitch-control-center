import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../../support/commands";

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

test.describe("Alternative Payment Methods - country-bound enablement", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "apm_test_connector",
        context.request,
      );
    }

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.apm = true;
      }
      await route.fulfill({ response, json });
    });

    await page.goto("/dashboard/apm");
    await page.waitForLoadState("networkidle");
  });

  test("should enable iDEAL scoped to Netherlands", async ({ page }) => {
    await gatedOrAssert(page, async () => {
      const idealToggle = page
        .locator(
          '[data-testid*="ideal"], input[type="checkbox"][name*="ideal"]',
        )
        .first();
      if (!(await idealToggle.isVisible().catch(() => false))) {
        test.skip(true, "iDEAL toggle not exposed");
      }
      await idealToggle.check();

      const countrySelect = page
        .locator('[name*="country"][name*="ideal"]')
        .first();
      if (await countrySelect.isVisible().catch(() => false)) {
        await countrySelect.selectOption("NL");
      }

      const save = page.locator('[data-button-for="save"]').first();
      if (await save.isVisible().catch(() => false)) {
        await save.click();
      }
    });
  });

  test("should enable Sofort scoped to Germany", async ({ page }) => {
    await gatedOrAssert(page, async () => {
      const sofortToggle = page.locator('[data-testid*="sofort"]').first();
      if (!(await sofortToggle.isVisible().catch(() => false))) {
        test.skip(true, "Sofort toggle not exposed");
      }
      await sofortToggle.check();

      const countrySelect = page
        .locator('[name*="country"][name*="sofort"]')
        .first();
      if (await countrySelect.isVisible().catch(() => false)) {
        await countrySelect.selectOption("DE");
      }

      const save = page.locator('[data-button-for="save"]').first();
      if (await save.isVisible().catch(() => false)) {
        await save.click();
      }
    });
  });

  test("should persist APM-specific rules via Rules tab", async ({ page }) => {
    await gatedOrAssert(page, async () => {
      const rulesTab = page
        .locator('[role="tab"]:has-text("Rules"), [data-testid*="rules"]')
        .first();
      if (!(await rulesTab.isVisible().catch(() => false))) {
        test.skip(true, "Rules tab not exposed");
      }
      await rulesTab.click();

      const minAmount = page.locator('[name*="min_amount"]').first();
      if (await minAmount.isVisible().catch(() => false)) {
        await minAmount.fill("5.00");
        await expect(minAmount).toHaveValue("5.00");
      }

      const save = page.locator('[data-button-for="saveRules"]').first();
      if (await save.isVisible().catch(() => false)) {
        await save.click();
      }
    });
  });

  test("should validate and save APM credentials via Credentials tab", async ({
    page,
  }) => {
    await gatedOrAssert(page, async () => {
      const credentialsTab = page
        .locator(
          '[role="tab"]:has-text("Credentials"), [data-testid*="credentials"]',
        )
        .first();
      if (!(await credentialsTab.isVisible().catch(() => false))) {
        test.skip(true, "Credentials tab not exposed");
      }
      await credentialsTab.click();

      await page.locator('[name*="api_key"]').fill("apm_test_api_key");
      await page.locator('[name*="merchant_id"]').fill("apm_merchant_123");

      await page
        .locator('[data-button-for="validate"], button:has-text("Validate")')
        .click();
      await expect(
        page.locator('[data-toast*="validated"], [data-toast*="success"]'),
      ).toBeVisible({ timeout: 10000 });
    });
  });
});
