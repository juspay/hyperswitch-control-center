import { test, expect, type Page, type Locator } from "@playwright/test";
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
    // Opens Payment Settings after a fresh signup/login and waits for the
    // page header plus the info cards that are shared across every tab.
    async function openPaymentSettings(page: Page): Promise<PaymentSettings> {
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

      return paymentSettings;
    }

    // Profile Name / Profile ID / Merchant ID / Payment Response Hash Key
    // values are per-run dynamic. They are rendered as the subHeading <p>
    // (text-fs-16 text-nd_gray-600) of each info card — mask them all on
    // every tab snapshot since the info cards stay mounted across tabs.
    function infoCardValues(page: Page): Locator {
      return page.locator("p.text-fs-16.text-nd_gray-600");
    }

    test("payment behaviour tab should match visual snapshot", async ({
      page,
    }) => {
      const paymentSettings = await openPaymentSettings(page);

      // Payment Behaviour is the default tab; its stable form anchor is the
      // collect-billing toggle. Scroll the last form control into view so any
      // lazily-rendered content is realised before the full-page capture.
      await expect(paymentSettings.collectBillingDetailsToggle).toBeVisible({
        timeout: 10000,
      });

      await expect(page).toHaveScreenshot("developers-payment-settings.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        mask: [infoCardValues(page)],
      });

      await paymentSettings.returnUrlInput.scrollIntoViewIfNeeded();

      await expect(page).toHaveScreenshot("developers-payment-settings-2.png", {
        fullPage: true,
        animations: "disabled",
        maxDiffPixelRatio: 0.01,
        mask: [infoCardValues(page)],
      });
    });

    test("3ds tab should match visual snapshot", async ({ page }) => {
      const paymentSettings = await openPaymentSettings(page);

      await paymentSettings.clickTab("3ds");
      await expect(paymentSettings.force3DSChallengeToggle).toBeVisible({
        timeout: 10000,
      });
      // Acquirer config sits at the bottom of the tab — bring it into view so
      // its (empty-state) content renders before capturing.
      await paymentSettings.acquirerConfigSettingsHeading.scrollIntoViewIfNeeded();

      await expect(page).toHaveScreenshot(
        "developers-payment-settings-3ds.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [infoCardValues(page)],
        },
      );
    });

    test("3ds tab with acquirer config should match visual snapshot", async ({
      page,
    }) => {
      const paymentSettings = await openPaymentSettings(page);

      await paymentSettings.clickTab("3ds");
      await expect(paymentSettings.force3DSChallengeToggle).toBeVisible({
        timeout: 10000,
      });

      await page.getByRole("button", { name: "Acquirer config group" }).click();

      await expect(page).toHaveScreenshot(
        "developers-payment-settings-3ds-acquirer-config-sidebar.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [infoCardValues(page)],
        },
      );

      await page
        .getByRole("textbox", { name: "e.g. Demo Merchant" })
        .fill("Hyperswitch");
      await page
        .getByRole('textbox', { name: 'e.g. 00004500000' })
        .fill("12345678");
      await page.getByRole("button", { name: "Select Network" }).click();
      await page
        .getByRole('menuitem', { name: 'Visa' })
        .click();
      await page
        .getByRole('spinbutton', { name: 'e.g.' }).first()
        .fill("12345678");
      await page.getByRole("button", { name: "Save" }).click();

      await expect(page).toHaveScreenshot(
        "developers-payment-settings-3ds-acquirer-config.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [infoCardValues(page)],
        },
      );
    });

    test("custom headers tab should match visual snapshot", async ({
      page,
    }) => {
      const paymentSettings = await openPaymentSettings(page);

      await paymentSettings.clickTab("customHeaders");
      await expect(paymentSettings.customHeadersKeyInput).toBeVisible({
        timeout: 10000,
      });
      await paymentSettings.customHeadersValueInput.scrollIntoViewIfNeeded();

      await expect(page).toHaveScreenshot(
        "developers-payment-settings-custom-headers.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [infoCardValues(page)],
        },
      );
    });

    test("metadata headers tab should match visual snapshot", async ({
      page,
    }) => {
      const paymentSettings = await openPaymentSettings(page);

      await paymentSettings.clickTab("metadataHeaders");
      await expect(paymentSettings.customMetadataHeadersHeading).toBeVisible({
        timeout: 10000,
      });
      await paymentSettings.customMetadataHeadersHeading.scrollIntoViewIfNeeded();

      await expect(page).toHaveScreenshot(
        "developers-payment-settings-metadata-headers.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [infoCardValues(page)],
        },
      );
    });

    test("payment link tab should match visual snapshot", async ({ page }) => {
      const paymentSettings = await openPaymentSettings(page);

      await paymentSettings.clickTab("paymentLink");
      await expect(paymentSettings.paymentLinkDomainHeading).toBeVisible({
        timeout: 10000,
      });
      await paymentSettings.allowedDomainInput.scrollIntoViewIfNeeded();

      await expect(page).toHaveScreenshot(
        "developers-payment-settings-payment-link.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [infoCardValues(page)],
        },
      );
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

    test("webhooks list and detail with mocked events should match visual snapshots", async ({
      page,
    }) => {
      await mockV2MerchantList(page);

      // A delivered event whose detail view exposes a single initial delivery
      // attempt with request/response payloads. Fixed timestamps keep the
      // rendered Created cells deterministic across runs.
      const events = {
        total_count: 1,
        events: [
          {
            event_id: "evt_success_1",
            event_class: "payments",
            event_type: "payment_succeeded",
            merchant_id: "merchant_1",
            profile_id: "profile_1",
            object_id: "pay_success_1",
            is_delivery_successful: true,
            initial_attempt_id: "evt_success_1",
            created: "2026-05-29T10:00:00.000Z",
          },
        ],
      };
      const attempts = [
        {
          ...events.events[0],
          delivery_attempt: "initial_attempt",
          request: {
            body: '{"event_type":"payment_succeeded","object_id":"pay_success_1"}',
            headers: [["content-type", "application/json"]],
          },
          response: {
            body: '{"status":"received"}',
            headers: [["content-type", "application/json"]],
            status_code: 200,
            error_message: "",
          },
        },
      ];

      await page.route("**/events/profile/list", async (route) => {
        await route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify(events),
        });
      });
      await page.route("**/events/*/*/attempts", async (route) => {
        await route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify(attempts),
        });
      });

      const homePage = new HomePage(page);
      const webhooks = new Webhooks(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      await homePage.developer.click();
      await homePage.webhooks.click();
      await page.waitForLoadState("networkidle");

      await expect(webhooks.pageHeading).toBeVisible({ timeout: 10000 });
      await expect(webhooks.cellByText("pay_success_1")).toBeVisible({
        timeout: 10000,
      });

      // List page snapshot. The date-range filter surfaces "Now" + current
      // dates, so mask it to keep the snapshot stable.
      await expect(page).toHaveScreenshot(
        "developers-webhooks-list-mocked.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
          mask: [webhooks.dateRangeFilter],
        },
      );

      // Drill into the event detail view.
      await webhooks.cellByText("payment_succeeded").click();
      await expect(page).toHaveURL(/dashboard\/webhooks\/evt_success_1/, {
        timeout: 10000,
      });
      await expect(webhooks.webhookDeliveryLabel).toBeVisible({
        timeout: 10000,
      });
      await expect(webhooks.requestTab).toBeVisible({ timeout: 10000 });
      await expect(webhooks.responseTab).toBeVisible({ timeout: 10000 });

      await expect(page).toHaveScreenshot(
        "developers-webhooks-detail-mocked.png",
        {
          fullPage: true,
          animations: "disabled",
          maxDiffPixelRatio: 0.01,
        },
      );
    });
  });
});
