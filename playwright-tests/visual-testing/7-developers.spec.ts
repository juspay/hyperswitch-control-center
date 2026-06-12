import { test, expect } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  mockV2MerchantList,
  createAPIKey,
} from "../support/commands";
import { HomePage } from "../support/pages/homepage/HomePage";
import { APISettings } from "../support/pages/developers/APISettings";
import { PaymentSettings } from "../support/pages/developers/PaymentSettings";
import { Webhooks } from "../support/pages/developers/Webhooks";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Visual Testing - Developers", () => {
  test.describe("API Keys", () => {
    test("api keys page with no keys should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const apiSettings = new APISettings(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.developer.click();
      await homePage.apiKeys.click();

      await expect(page).toHaveURL(/.*dashboard\/developer-api-keys/);
      await expect(apiSettings.pageHeading).toBeVisible({ timeout: 10000 });
      await expect(apiSettings.noDataAvailable).toBeVisible({ timeout: 10000 });
      await expect(apiSettings.createNewApiKeyButton).toBeVisible();

      await expect(page).toHaveScreenshot("developers-api-keys-empty.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
      });
    });

    test("api keys page with a seeded key should match visual snapshot", async ({
      page,
      context,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const apiSettings = new APISettings(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createAPIKey(merchantId, "", context.request);
      }

      await homePage.developer.click();
      await homePage.apiKeys.click();

      await expect(page).toHaveURL(/.*dashboard\/developer-api-keys/);
      await expect(apiSettings.pageHeading).toBeVisible({ timeout: 10000 });

      // createAPIKey seeds a key named "API Key 1"
      const keyRow = apiSettings.keyRow("API Key 1");
      await expect(keyRow).toBeVisible({ timeout: 10000 });

      // The API key prefix, Created and Expiration cells carry dynamic
      // (per-run) values, so mask them to keep the snapshot stable. Column
      // order is [Prefix(0), Name(1), Description(2), Created(3),
      // Expiration(4), CustomCell(5)] — see DeveloperUtils.res.
      const cells = keyRow.getByRole("cell");
      await expect(page).toHaveScreenshot("developers-api-keys-with-key.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        mask: [cells.nth(0), cells.nth(3), cells.nth(4)],
      });
    });
  });

  test.describe("Payment Settings", () => {
    test("payment settings page should match visual snapshot", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(paymentSettings.pageHeader).toBeVisible({ timeout: 10000 });
      await expect(paymentSettings.profileName).toBeVisible();
      await expect(paymentSettings.profileId).toBeVisible();
      await expect(paymentSettings.merchantId).toBeVisible();
      await expect(paymentSettings.paymentResponseHashKey).toBeVisible();
      // Default (Payment Behaviour) tab content is the stable form below.
      await expect(paymentSettings.collectBillingDetailsToggle).toBeVisible();

      // Profile Name / Profile ID / Merchant ID / Payment Response Hash Key
      // values are per-run dynamic. They are rendered as the subHeading <p>
      // (text-fs-16 text-nd_gray-600) of each info card — mask them all.
      const infoCardValues = page.locator("p.text-fs-16.text-nd_gray-600");

      await expect(page).toHaveScreenshot("developers-payment-settings.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        mask: [infoCardValues],
      });
    });
  });

  test.describe("Webhooks", () => {
    test("webhooks page should match visual snapshot", async ({ page }) => {
      await mockV2MerchantList(page);

      const homePage = new HomePage(page);
      const webhooks = new Webhooks(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.developer.click();
      await homePage.webhooks.click();
      await page.waitForLoadState("networkidle");

      await expect(webhooks.pageHeading).toBeVisible({ timeout: 10000 });
      await expect(webhooks.searchByIdInput).toBeVisible({ timeout: 10000 });

      // The date-range filter button surfaces relative/current timestamps
      // ("Now" + dates), so mask it to avoid flakiness.
      await expect(page).toHaveScreenshot("developers-webhooks.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        mask: [webhooks.dateRangeFilter],
      });
    });
  });
});
