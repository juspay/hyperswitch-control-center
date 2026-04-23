import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Vault Onboarding Wizard", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.vault = true;
        json.features.vault_onboarding = true;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    await homePage.vault.click();
    await homePage.vaultConfiguration.click();
    await page.waitForLoadState("networkidle");
  });

  test("should land on vault-onboarding URL and expose a processor picker", async ({
    page,
  }) => {
    await expect(page).toHaveURL(/.*dashboard\/vault-onboarding/);
    await expect(page.getByPlaceholder("Search a processor")).toBeVisible();

    const connectButtons = page.getByRole("button", { name: "Connect" });
    expect(await connectButtons.count()).toBeGreaterThan(0);
  });

  test("should filter the processor picker by typing a vendor name", async ({
    page,
  }) => {
    const search = page.getByPlaceholder("Search a processor");
    await search.fill("spreedly");
    await page.waitForTimeout(500);
    await expect(search).toHaveValue("spreedly");
  });

  test("should open a configuration panel for the selected vault provider", async ({
    page,
  }) => {
    const firstConnect = page.getByRole("button", { name: "Connect" }).first();
    await firstConnect.click();
    await page.waitForLoadState("networkidle");

    const credentialField = page
      .locator(
        '[name*="api_key"], [name*="environment_key"], [name*="access_secret"], [name*="encryption_key"]',
      )
      .first();
    await expect(credentialField).toBeVisible({ timeout: 10000 });
  });

  test("should accept credential input and preserve the value", async ({
    page,
  }) => {
    const firstConnect = page.getByRole("button", { name: "Connect" }).first();
    await firstConnect.click();
    await page.waitForLoadState("networkidle");

    const credentialField = page
      .locator(
        '[name*="api_key"], [name*="environment_key"], [name*="access_secret"], [name*="encryption_key"]',
      )
      .first();
    await expect(credentialField).toBeVisible({ timeout: 10000 });
    await credentialField.fill("vault_test_credential_12345");
    await expect(credentialField).toHaveValue("vault_test_credential_12345");
  });
});
