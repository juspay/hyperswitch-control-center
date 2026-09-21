import { test, expect } from "../../support/test";
import type { Page, Route } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentSettings } from "../../support/pages/developers/PaymentSettings";
import { Blocklist } from "../../support/pages/developers/Blocklist";
import { SurchargeProcessor } from "../../support/pages/connector/SurchargeProcessor";
import { VaultProcessor } from "../../support/pages/connector/VaultProcessor";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createAuthenticationConnectorAPI,
  fillConnectorFields,
} from "../../support/commands";
import { vaultProcessorConfig } from "../../support/fixtures/vaultProcessorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

const SLACK_URL = "https://hyperswitch-io.slack.com/?redir=%2Fssb%2Fredirect";

/** Accordion sections, one per blockable payment method. */
const BLOCKING_SECTIONS = ["Card", "Apple Pay", "Google Pay"] as const;

/** The multi-select filters added by the payment-method-blocking change. */
const BLOCKING_SELECT_FIELDS = [
  { label: "Issuing Country", buttonText: "Select Countries" },
  { label: "Card Types", buttonText: "Select Card Types" },
  { label: "Card Networks", buttonText: "Select Card Networks" },
  { label: "Funding Sources", buttonText: "Select Funding Sources" },
  { label: "Card Segment Types", buttonText: "Select Segment Types" },
  { label: "Card Subtypes", buttonText: "Select Card Subtypes" },
] as const;

const BLOCKING_TOGGLE_FIELDS = [
  "Block virtual cards",
  "Block non-reloadable prepaid cards",
  "Block gambling BINs",
  "Block if BIN info unavailable",
] as const;

const captureProfileUpdate = (page: Page) =>
  page.waitForRequest(
    (request) =>
      request.method() === "POST" &&
      request.url().includes("/business_profile/"),
  );

const RESULTS_PER_PAGE = 10;

let blocklist: Blocklist;
let blocklistCalls: BlocklistCalls;

type BatchJob = {
  job_id: string;
  job_type?: "upload" | "export";
  status?: string;
  total_rows?: number;
  succeeded_rows?: number;
  failed_rows?: number;
  downloadable?: boolean;
};

const makeJob = (job: BatchJob) => ({
  job_id: job.job_id,
  merchant_id: "merchant_test",
  job_type: job.job_type ?? "upload",
  status: job.status ?? "completed",
  total_rows: job.total_rows ?? 3,
  succeeded_rows: job.succeeded_rows ?? 3,
  failed_rows: job.failed_rows ?? 0,
  downloadable: job.downloadable ?? false,
  created_at: "2026-09-15T06:08:47.617Z",
  updated_at: "2026-09-15T06:08:47.617Z",
});

const makeBlocklistCsvWithDataRows = (rowCount: number) =>
  `type,data,metadata\n${Array.from(
    { length: rowCount },
    () => "card_bin,411111,",
  ).join("\n")}`;

type BlocklistMocks = {
  /** counts_by_length for the generic_card_bin data kind, e.g. { "6": 12 }. */
  cardBinCounts?: Record<string, number>;
  cardBinTotal?: number;
  fingerprintTotal?: number;
  countStatus?: number;
  lookupBlocked?: boolean;
  lookupStatus?: number;
  entryStatus?: number;
  exportStatus?: number;
  exportFileName?: string;
  jobs?: ReturnType<typeof makeJob>[];
  /** Jobs returned on every list call after the first one. */
  jobsAfterAction?: ReturnType<typeof makeJob>[];
  /** Overrides the list response per requested offset, for pagination. */
  jobsByOffset?: (offset: number) => {
    data: ReturnType<typeof makeJob>[];
    total: number;
  };
  refreshedJob?: ReturnType<typeof makeJob>;
  downloadUrl?: string;
  uploadStatus?: number;
  uploadJobId?: string;
};

type BlocklistCalls = {
  countUrls: string[];
  lookupUrls: string[];
  entryMethods: string[];
  entryBodies: Record<string, unknown>[];
  exportCount: number;
  listCount: number;
  listUrls: string[];
  uploadCount: number;
};

const setBlocklistFeatureFlag = async (page: Page, enabled: boolean) => {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    if (json && json.features) {
      json.features.dev_blocklist = enabled;
    }
    await route.fulfill({ response, json });
  });
};

/**
 * A single handler for every blocklist endpoint. The paths overlap
 * (`/blocklist`, `/blocklist/count`, `/blocklist/batch`), so dispatching inside
 * one glob keeps behaviour independent of Playwright's handler precedence.
 */
const mockBlocklistApis = async (
  page: Page,
  mocks: BlocklistMocks = {},
): Promise<BlocklistCalls> => {
  const {
    cardBinCounts = { "6": 12, "8": 3 },
    cardBinTotal = 15,
    fingerprintTotal = 7,
    countStatus = 200,
    lookupBlocked = true,
    lookupStatus = 200,
    entryStatus = 200,
    exportStatus = 200,
    exportFileName = "blocklist_export_2026_09_15.csv",
    jobs = [],
    jobsAfterAction,
    jobsByOffset,
    refreshedJob,
    downloadUrl = "https://example.com/blocklist_export.csv",
    uploadStatus = 200,
    uploadJobId = "blockbatch_test",
  } = mocks;

  const apiCalls: BlocklistCalls = {
    countUrls: [],
    lookupUrls: [],
    entryMethods: [],
    entryBodies: [],
    exportCount: 0,
    listCount: 0,
    listUrls: [],
    uploadCount: 0,
  };

  await page.route("**/blocklist**", async (route: Route) => {
    const request = route.request();
    const method = request.method();
    const url = new URL(request.url());
    const path = url.pathname;

    const json = (status: number, body: unknown) =>
      route.fulfill({
        status,
        contentType: "application/json",
        body: JSON.stringify(body),
      });

    if (path.endsWith("/blocklist/count")) {
      apiCalls.countUrls.push(request.url());
      if (countStatus !== 200) {
        return json(countStatus, { error: { message: "count unavailable" } });
      }
      const isFingerprint =
        url.searchParams.get("data_kind") === "payment_method";
      return json(
        200,
        isFingerprint
          ? { total_count: fingerprintTotal, counts_by_length: {} }
          : { total_count: cardBinTotal, counts_by_length: cardBinCounts },
      );
    }

    if (path.endsWith("/blocklist/lookup")) {
      apiCalls.lookupUrls.push(request.url());
      if (lookupStatus !== 200) {
        return json(lookupStatus, {
          error: { message: "Lookup service unavailable" },
        });
      }
      return json(200, {
        data: url.searchParams.get("data") ?? "",
        blocked: lookupBlocked,
      });
    }

    if (path.endsWith("/blocklist/export") && method === "POST") {
      apiCalls.exportCount += 1;
      if (exportStatus !== 200) {
        return json(exportStatus, {
          error: { message: "Export could not be queued" },
        });
      }
      return json(200, { file_name: exportFileName });
    }

    // POST /blocklist/batch — CSV upload (multipart, so never parsed as JSON)
    if (path.endsWith("/blocklist/batch") && method === "POST") {
      apiCalls.uploadCount += 1;
      if (uploadStatus !== 200) {
        return json(uploadStatus, { error: { message: "Upload failed" } });
      }
      return json(200, {
        job_id: uploadJobId,
        total_rows: 3,
        status: "initiated",
      });
    }

    // GET /blocklist/batch/{jobId} — single job refresh / export download
    if (path.includes("/blocklist/batch/") && method === "GET") {
      return json(200, {
        ...(refreshedJob ?? makeJob({ job_id: "blkjob_01" })),
        download_url: downloadUrl,
      });
    }

    // GET /blocklist/batch?limit&offset — jobs list
    if (path.endsWith("/blocklist/batch") && method === "GET") {
      apiCalls.listCount += 1;
      apiCalls.listUrls.push(request.url());
      if (jobsByOffset) {
        const offset = Number(url.searchParams.get("offset") ?? "0");
        const { data, total } = jobsByOffset(offset);
        return json(200, { data, total_count: total });
      }
      const payload =
        apiCalls.listCount > 1 && jobsAfterAction ? jobsAfterAction : jobs;
      return json(200, { data: payload, total_count: payload.length });
    }

    // POST / DELETE /blocklist — single entry add / remove
    if (
      path.endsWith("/blocklist") &&
      (method === "POST" || method === "DELETE")
    ) {
      apiCalls.entryMethods.push(method);
      apiCalls.entryBodies.push(request.postDataJSON());
      if (entryStatus !== 200) {
        return json(entryStatus, {
          error: { message: "Entry already present in blocklist" },
        });
      }
      return json(200, {
        fingerprint_id: "fp_generated_001",
        data_kind: "generic_card_bin",
        created_at: "2026-09-15T06:08:47.617Z",
      });
    }

    return route.fallback();
  });

  return apiCalls;
};

/**
 * Enables dev_blocklist, installs the given API mocks and opens the Block List
 * tab. The feature flag is read when the app boots, so the page is reloaded
 * after the route is registered — the outer beforeEach has already signed in.
 */
const useBlockListTab = (mocks: BlocklistMocks = {}, enabled = true) => {
  test.beforeEach(async ({ page }) => {
    await setBlocklistFeatureFlag(page, enabled);
    blocklistCalls = await mockBlocklistApis(page, mocks);

    const configResponse = page.waitForResponse(
      (response) => response.url().includes("/config/feature") && response.ok(),
    );
    await page.reload();
    await configResponse;

    const homePage = new HomePage(page);
    blocklist = new Blocklist(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();
    await expect(page).toHaveURL(/.*dashboard\/payment-settings/);

    await expect(blocklist.tab).toBeVisible();
    await blocklist.tab.click();
  });
};

async function configureInterPaymentsSurchargeProcessor(
  page: Page,
): Promise<void> {
  const homePage = new HomePage(page);
  const surchargeProcessor = new SurchargeProcessor(page);

  await homePage.connectors.click();
  await homePage.surchargeConnectors.click();
  await expect(page).toHaveURL(/.*dashboard\/surcharge-processor/);

  await expect(surchargeProcessor.connectNowOrConnectButton).toBeVisible();
  await surchargeProcessor.connectNowOrConnectButton.click();
  await page
    .locator('[name*="api_key"]')
    .first()
    .fill("interpayments_test_api_key");
  await surchargeProcessor.connectAndProceedButton.click();
  await surchargeProcessor.doneButton.click();
  await expect(page.getByTestId("interpayments_default")).toBeVisible();
}

test.describe("Payment Settings", () => {
  test.beforeEach(async ({ page, context: _context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test.describe("Navigation, Header and fields", () => {
    test("should display page header and information cards", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(paymentSettings.pageHeader).toBeVisible({ timeout: 10000 });
      await expect(paymentSettings.profileName).toBeVisible();
      await expect(paymentSettings.profileId).toBeVisible();
      await expect(paymentSettings.merchantId).toBeVisible();
      await expect(paymentSettings.paymentResponseHashKey).toBeVisible();
    });
  });

  test.describe("Tabs Navigation", () => {
    test("should display all available tabs", async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(paymentSettings.paymentBehaviourTab).toBeVisible();
      await expect(paymentSettings.threeDSTab).toBeVisible();
      await expect(paymentSettings.customHeadersTab).toBeVisible();
      await expect(paymentSettings.metadataHeadersTab).toBeVisible();
      await expect(paymentSettings.paymentLinkTab).toBeVisible();
    });

    test("should display Vault and Surcharge tabs when both connectors are configured", async ({
      page,
    }) => {
      test.slow();

      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);
      const vaultProcessor = new VaultProcessor(page);

      await homePage.connectors.click();
      await homePage.vaultConnectors.click();
      await expect(page).toHaveURL(/.*dashboard\/vault-processor/);

      await expect(vaultProcessor.connectButton.first()).toBeVisible();
      await vaultProcessor.connectButton.first().click();
      await fillConnectorFields(page, vaultProcessorConfig.vgs.fields);
      await vaultProcessor.saveOrConnectOrProceedButton.click();
      await page.waitForLoadState("networkidle");
      await vaultProcessor.doneButton.click();

      await configureInterPaymentsSurchargeProcessor(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(paymentSettings.vaultTab).toBeVisible();
      await expect(paymentSettings.surchargeTab).toBeVisible();
    });

    test("should switch between tabs correctly", async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();

      await expect(paymentSettings.collectBillingDetailsToggle).toBeVisible();

      await paymentSettings.threeDSTab.click();
      await expect(paymentSettings.force3DSChallengeToggle).toBeVisible();

      await paymentSettings.customHeadersTab.click();
      await expect(paymentSettings.customHeadersKeyInput).toBeVisible();

      await paymentSettings.metadataHeadersTab.click();
      await expect(paymentSettings.customMetadataHeadersHeading).toBeVisible();

      await paymentSettings.paymentLinkTab.click();
      await expect(paymentSettings.paymentLinkDomainHeading).toBeVisible();
    });
  });

  test.describe("Surcharge Tab", () => {
    const connectorLabel = "interpayments_default";

    test.beforeEach(async ({ page }) => {
      await page.route("**/dashboard/config/feature*", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        if (json.features) {
          json.features.surcharge_processor = true;
        }
        await route.fulfill({ response, json });
      });
      await page.reload({ waitUntil: "domcontentloaded" });

      await configureInterPaymentsSurchargeProcessor(page);

      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);
      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await expect(paymentSettings.surchargeTab).toBeVisible();
      await paymentSettings.surchargeTab.click();
    });

    test("should display the configured surcharge processor in Payment Settings", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.surchargeConnectorsLabel).toBeVisible();
      await expect(paymentSettings.surchargeConnectorDropdown).toBeVisible();
      await expect(paymentSettings.updateButton).toBeVisible();

      await paymentSettings.surchargeConnectorDropdown.click();
      await expect(
        paymentSettings.surchargeConnectorOption(connectorLabel),
      ).toBeVisible();
    });

    test("should update and persist the surcharge processor on the business profile", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.surchargeConnectorDropdown.click();
      const connectorOption =
        paymentSettings.surchargeConnectorOption(connectorLabel);
      await expect(connectorOption).toBeVisible();

      const connectorOptionValue =
        await connectorOption.getAttribute("data-id");
      const connectorId = connectorOptionValue?.match(/mca_[A-Za-z0-9]+/)?.[0];
      expect(connectorId).toMatch(/^mca_/);
      await connectorOption.click();

      await expect(
        paymentSettings.selectedSurchargeConnector(connectorLabel),
      ).toBeVisible();

      const updateRequestPromise = page.waitForRequest(
        (request) =>
          request.method() === "POST" &&
          /\/account\/[^/]+\/business_profile\/[^/?]+$/.test(request.url()),
      );
      await paymentSettings.clickUpdate();
      const updateRequest = await updateRequestPromise;
      const requestBody = updateRequest.postDataJSON();

      expect(requestBody.surcharge_connector_details).toEqual({
        surcharge_connector_id: connectorId,
      });
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();
      await paymentSettings.surchargeTab.click();

      await expect(
        paymentSettings.selectedSurchargeConnector(connectorLabel),
      ).toBeVisible();
    });
  });

  test.describe("Payment Behaviour Tab", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      await homePage.developer.click();
      await homePage.paymentSettings.click();
    });

    test("should display all toggle options", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.collectBillingDetailsToggle).toBeVisible();
      await expect(paymentSettings.collectShippingDetailsToggle).toBeVisible();
      await expect(paymentSettings.autoRetriesToggle).toBeVisible();
      await expect(paymentSettings.manualRetriesToggle).toBeVisible();
      await expect(paymentSettings.extendedAuthorizationToggle).toBeVisible();
      await expect(paymentSettings.alwaysEnableOvercaptureToggle).toBeVisible();
      await expect(paymentSettings.networkTokenizationToggle).toBeVisible();
      await expect(paymentSettings.merchantCategoryCodeDropdown).toBeVisible();
      await expect(paymentSettings.clickToPayToggle).toBeVisible();
      await expect(paymentSettings.returnUrlInput).toBeVisible();
      await expect(paymentSettings.webhookUrlInput).toBeVisible();
      await expect(paymentSettings.updateButton).toBeVisible();
    });

    test("should allow entering values in form fields", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.fillReturnUrl("https://example.com/return");
      await paymentSettings.fillWebhookUrl("https://example.com/webhook");

      await expect(paymentSettings.returnUrlInput).toHaveValue(
        "https://example.com/return",
      );
      await expect(paymentSettings.webhookUrlInput).toHaveValue(
        "https://example.com/webhook",
      );
    });

    test("should save toggle, form, and dropdown values when Update is clicked", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const toggleLabels = [
        "Manual Retries",
        "Extended Authorization",
        "Always Enable Overcapture",
        "Connector Agnostic",
      ];

      const expectedToggleStates: Record<string, "on" | "off"> = {};
      for (const label of toggleLabels) {
        const toggle = paymentSettings.toggleSwitchByLabel(label);
        await expect(toggle).toBeVisible();
        const initial = await toggle.getAttribute("data-bool-value");
        const expected = initial === "on" ? "off" : "on";
        await toggle.click();
        await expect(toggle).toHaveAttribute("data-bool-value", expected);
        expectedToggleStates[label] = expected;
      }

      const returnUrl = "https://example.com/return";
      const webhookUrl = "https://example.com/webhook";
      const expectedCategory = "Wine producers";

      await paymentSettings.fillReturnUrl(returnUrl);
      await paymentSettings.fillWebhookUrl(webhookUrl);

      await paymentSettings.selectFirstMerchantCategoryCode();
      await expect(
        paymentSettings.buttonByName(expectedCategory),
      ).toBeVisible();

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      // Wait for the PUT /merchant_account response to settle before reload —
      // otherwise reload can race the persisted state and read stale toggles.
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");

      await expect(paymentSettings.returnUrlInput).toHaveValue(returnUrl, {
        timeout: 10000,
      });
      await expect(paymentSettings.webhookUrlInput).toHaveValue(webhookUrl);
      await expect(
        paymentSettings.buttonByName(expectedCategory),
      ).toBeVisible();

      for (const label of toggleLabels) {
        await expect(
          paymentSettings.toggleSwitchByLabel(label),
        ).toHaveAttribute("data-bool-value", expectedToggleStates[label], {
          timeout: 10000,
        });
      }
    });

    test("should save Auto Retries with Max Auto Retries value", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const autoRetriesToggle =
        paymentSettings.toggleSwitchByLabel("Auto Retries");
      const initial = await autoRetriesToggle.getAttribute("data-bool-value");
      if (initial !== "on") {
        await autoRetriesToggle.click();
        await expect(autoRetriesToggle).toHaveAttribute(
          "data-bool-value",
          "on",
        );
      }

      await expect(paymentSettings.maxAutoRetriesInput).toBeVisible();
      await paymentSettings.maxAutoRetriesInput.fill("4");
      await expect(paymentSettings.maxAutoRetriesInput).toHaveValue("4");

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();

      await expect(
        paymentSettings.toggleSwitchByLabel("Auto Retries"),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
      await expect(paymentSettings.maxAutoRetriesInput).toHaveValue("4");
    });

    test("should save Collect billing and shipping details with Always option", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const billingToggle = paymentSettings.toggleSwitchByLabel(
        "Collect billing details from wallets",
      );
      const shippingToggle = paymentSettings.toggleSwitchByLabel(
        "Collect shipping details from wallets",
      );

      const billingInitial =
        await billingToggle.getAttribute("data-bool-value");
      if (billingInitial !== "on") {
        await billingToggle.click();
        await expect(billingToggle).toHaveAttribute("data-bool-value", "on");
      }
      await paymentSettings.radioOption("Always").click();

      const shippingInitial =
        await shippingToggle.getAttribute("data-bool-value");
      if (shippingInitial !== "on") {
        await shippingToggle.click();
        await expect(shippingToggle).toHaveAttribute("data-bool-value", "on");
      }
      // The shipping section's "Always" is the second occurrence of that label
      await paymentSettings.alwaysOption("last").click();

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();

      await expect(
        paymentSettings.toggleSwitchByLabel(
          "Collect billing details from wallets",
        ),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
      await expect(
        paymentSettings.toggleSwitchByLabel(
          "Collect shipping details from wallets",
        ),
      ).toHaveAttribute("data-bool-value", "on");
      // Both "Always" options remain visible because their parent toggles are ON
      await expect(page.getByText("Always", { exact: true })).toHaveCount(2);
    });
  });

  test.describe("Payment Behaviour Tab — Network Tokenization", () => {
    test.beforeEach(async ({ page }) => {
      await page.route("**/dashboard/config/feature*", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        if (json.features) {
          json.features.network_tokenization = true;
        }
        await route.fulfill({ response, json });
      });
      await page.reload({ waitUntil: "domcontentloaded" });

      const homePage = new HomePage(page);
      await homePage.developer.click();
      await homePage.paymentSettings.click();
    });

    test("should save Network Tokenization toggle when feature flag is enabled", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const ntToggle = paymentSettings.toggleSwitchByLabel(
        "Network Tokenization",
      );
      await expect(ntToggle).toBeVisible();

      const initial = await ntToggle.getAttribute("data-bool-value");
      if (initial !== "on") {
        await ntToggle.click();
        await expect(ntToggle).toHaveAttribute("data-bool-value", "on");
      }

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");

      await expect(
        paymentSettings.toggleSwitchByLabel("Network Tokenization"),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
    });
  });

  test.describe("Payment Behaviour Tab — Click to Pay", () => {
    const connectorLabel = "juspaythreedsserver_default";

    test.beforeEach(async ({ page, context }) => {
      await page.route("**/dashboard/config/feature*", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        if (json.features) {
          json.features.dev_click_to_pay = true;
        }
        await route.fulfill({ response, json });
      });

      const homePage = new HomePage(page);
      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createAuthenticationConnectorAPI(
          merchantId,
          connectorLabel,
          context.request,
          page,
        );
      }

      await page.reload();
      await homePage.developer.click();
      await homePage.paymentSettings.click();
    });

    test("should save Click to Pay toggle with selected connector", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const clickToPayToggle =
        paymentSettings.toggleSwitchByLabel("Click to Pay");
      await expect(clickToPayToggle).toBeVisible();

      const initial = await clickToPayToggle.getAttribute("data-bool-value");
      if (initial !== "on") {
        await clickToPayToggle.click();
        await expect(clickToPayToggle).toHaveAttribute("data-bool-value", "on");
      }

      await expect(paymentSettings.clickToPayConnectorDropdown).toBeVisible();
      await paymentSettings.clickToPayConnectorDropdown.click();
      await page.getByRole("menuitem", { name: connectorLabel }).click();

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");

      await expect(
        paymentSettings.toggleSwitchByLabel("Click to Pay"),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
      await expect(
        paymentSettings.buttonByName(new RegExp(connectorLabel)),
      ).toBeVisible();
    });
  });

  test.describe("3DS Tab", () => {
    test("should save Force 3DS Challenge toggle without a 3DS connector", async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.threeDSTab.click();

      const forceChallenge = paymentSettings.toggleSwitchByLabel(
        "Force 3DS Challenge",
      );
      const initial = await forceChallenge.getAttribute("data-bool-value");
      if (initial !== "on") {
        await forceChallenge.click();
        await expect(forceChallenge).toHaveAttribute("data-bool-value", "on");
      }

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();
      await paymentSettings.threeDSTab.click();

      await expect(
        paymentSettings.toggleSwitchByLabel("Force 3DS Challenge"),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
    });

    test("should save all fields when a 3DS connector is created", async ({
      page,
      context,
    }) => {
      // This flow chains a connector setup, several toggle/dropdown
      // interactions, an update + reload, and then re-asserts persisted state.
      // On CI the default 30s budget is too tight; one of the retries was
      // killed mid-assertion ("browser has been closed") because the previous
      // attempt was still tearing down. Give the test enough headroom.
      test.setTimeout(120000);

      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      const merchantId = await homePage.merchantID.nth(0).textContent();
      if (merchantId) {
        await createAuthenticationConnectorAPI(
          merchantId,
          "threeds_tab_connector",
          context.request,
          page,
        );
      }
      await page.reload();
      await page.waitForLoadState("networkidle");

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.threeDSTab.click();

      const forceChallenge = paymentSettings.toggleSwitchByLabel(
        "Force 3DS Challenge",
      );
      await expect(forceChallenge).toBeVisible();
      const initial = await forceChallenge.getAttribute("data-bool-value");
      if (initial !== "on") {
        await forceChallenge.click();
        await expect(forceChallenge).toHaveAttribute("data-bool-value", "on");
      }

      const requestorUrl = "https://example.com/3ds-requestor";
      const requestorAppUrl = "https://example.com/3ds-requestor-app";

      await paymentSettings.selectFieldDropdown().click();
      await page.getByRole("option", { name: "juspaythreedsserver" }).click();
      await page.keyboard.press("Escape");

      await paymentSettings.threeDsRequestorUrlInput.fill(requestorUrl);
      await paymentSettings.threeDsRequestorAppUrlInput.fill(requestorAppUrl);

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");
      await paymentSettings.threeDSTab.click();

      await expect(
        paymentSettings.toggleSwitchByLabel("Force 3DS Challenge"),
      ).toHaveAttribute("data-bool-value", "on", { timeout: 10000 });
      await expect(paymentSettings.threeDsRequestorUrlInput).toHaveValue(
        requestorUrl,
      );
      await expect(paymentSettings.threeDsRequestorAppUrlInput).toHaveValue(
        requestorAppUrl,
      );

      // Verify the connector is the selected option in the multi-select
      await page.getByRole("button", { name: "Select Field1" }).click();
      await expect(
        page
          .getByRole("option", { name: "juspaythreedsserver" })
          .getByRole("checkbox"),
      ).toHaveAttribute("data-state", "checked");
    });
  });

  test.describe("Acquirer Config Settings", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.threeDSTab.click();
    });

    test("should show empty state with heading and Acquirer config group button", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.acquirerConfigSettingsHeading).toBeVisible();
      await expect(paymentSettings.noAcquirerConfigsText).toBeVisible();
      await expect(paymentSettings.acquirerConfigGroupButton).toBeVisible();
    });

    test("should keep Add Acquirer modal actions visible and fields scrollable on a short viewport", async ({
      page,
    }) => {
      await page.setViewportSize({ width: 1280, height: 750 });
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.acquirerConfigGroupButton.click();

      const modal = paymentSettings.addAcquirerModal;
      await expect(modal).toBeVisible();
      await expect(
        modal.getByText("Add Acquirer Configuration", { exact: true }),
      ).toBeVisible();

      // Field labels
      await expect(
        modal.getByText("Acquirer merchant name", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Acquirer Merchant ID", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Card Network", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Acquirer BIN", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Acquirer ICA (optional)", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Fraud Rate (%) (optional)", { exact: false }),
      ).toBeVisible();
      await expect(
        modal.getByText("Acquirer Country (optional)", { exact: false }),
      ).toBeVisible();

      // Inputs
      await expect(
        paymentSettings.acquirerMerchantNameInput(modal),
      ).toBeVisible();
      await expect(
        paymentSettings.acquirerMerchantIdInput(modal),
      ).toBeVisible();
      await expect(paymentSettings.acquirerBinInput(modal)).toBeVisible();
      await expect(paymentSettings.acquirerIcaInput(modal)).toBeVisible();
      await expect(paymentSettings.acquirerFraudRateInput(modal)).toBeVisible();

      // Dropdowns
      await expect(
        paymentSettings.acquirerNetworkDropdownInModal(modal),
      ).toBeVisible();
      await expect(
        paymentSettings.acquirerCountryDropdownInModal(modal),
      ).toBeVisible();

      // Buttons
      await expect(
        paymentSettings.acquirerModalSaveButton(modal),
      ).toBeVisible();
      await expect(
        paymentSettings.acquirerModalCancelButton(modal),
      ).toBeVisible();

      const scrollRegion = paymentSettings.acquirerModalScrollRegion(modal);
      const saveButton = paymentSettings.acquirerModalSaveButton(modal);
      const cancelButton = paymentSettings.acquirerModalCancelButton(modal);
      const countryDropdown =
        paymentSettings.acquirerCountryDropdownInModal(modal);

      await expect(saveButton).toBeInViewport({ ratio: 1 });
      await expect(cancelButton).toBeInViewport({ ratio: 1 });

      const scrollMetrics = await scrollRegion.evaluate((element) => ({
        clientHeight: element.clientHeight,
        scrollHeight: element.scrollHeight,
      }));
      expect(scrollMetrics.scrollHeight).toBeGreaterThan(
        scrollMetrics.clientHeight,
      );

      await scrollRegion.evaluate((element) => {
        element.scrollTop = element.scrollHeight;
      });
      await expect
        .poll(() => scrollRegion.evaluate((element) => element.scrollTop))
        .toBeGreaterThan(0);
      await expect(countryDropdown).toBeInViewport();
      await expect(saveButton).toBeInViewport({ ratio: 1 });
      await expect(cancelButton).toBeInViewport({ ratio: 1 });
    });

    test("should close modal when Cancel is clicked without saving", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.acquirerConfigGroupButton.click();
      const modal = paymentSettings.addAcquirerModal;
      await expect(modal).toBeVisible();

      await paymentSettings.acquirerModalCancelButton(modal).click();
      // Modal hides — empty state remains
      await expect(paymentSettings.noAcquirerConfigsText).toBeVisible();
    });

    test("should show validation errors for BIN and fraud rate in the modal", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.acquirerConfigGroupButton.click();
      const modal = paymentSettings.addAcquirerModal;
      await expect(modal).toBeVisible();

      // BIN too short (< 4 digits)
      await paymentSettings.acquirerBinInput(modal).fill("12");
      await paymentSettings.acquirerBinInput(modal).press("Enter");
      await expect(paymentSettings.acquirerBinError).toBeVisible();

      // BIN valid → error clears
      await paymentSettings.acquirerBinInput(modal).fill("56688");
      await paymentSettings.acquirerBinInput(modal).blur();
      await expect(paymentSettings.acquirerBinError).toHaveCount(0);

      // Fraud rate out of range (> 100)
      await paymentSettings.acquirerFraudRateInput(modal).fill("150");
      await paymentSettings.acquirerFraudRateInput(modal).blur();
      await expect(paymentSettings.fraudRateError).toBeVisible();

      // Fraud rate valid → error clears
      await paymentSettings.acquirerFraudRateInput(modal).fill("25");
      await paymentSettings.acquirerFraudRateInput(modal).blur();
      await expect(paymentSettings.fraudRateError).toHaveCount(0);
    });

    test("should create an acquirer config group and display it as default", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      const merchantName = "Acme Test Merchant";
      const merchantId = "acmeMerchant001";
      const network = "Visa";
      const bin = "56688";
      const ica = "12345";
      const fraudRate = "5";

      await paymentSettings.acquirerConfigGroupButton.click();
      const modal = paymentSettings.addAcquirerModal;
      await expect(modal).toBeVisible();

      await paymentSettings.acquirerMerchantNameInput(modal).fill(merchantName);
      await paymentSettings.acquirerMerchantIdInput(modal).fill(merchantId);
      await paymentSettings.acquirerNetworkDropdownInModal(modal).click();
      await paymentSettings.dropdownValue(network).click();
      await paymentSettings.acquirerBinInput(modal).fill(bin);
      await paymentSettings.acquirerIcaInput(modal).fill(ica);
      await paymentSettings.acquirerFraudRateInput(modal).fill(fraudRate);

      await paymentSettings.acquirerModalSaveButton(modal).click();
      await expect(paymentSettings.acquirerCreatedToast).toBeVisible({
        timeout: 10000,
      });

      // Bucket renders with merchant name and a Default tag (only bucket)
      await expect(page.getByText(merchantName, { exact: true })).toBeVisible();
      await expect(paymentSettings.defaultTag().first()).toBeVisible();
    });

    test("should add a new network to an existing acquirer bucket", async ({
      page,
    }) => {
      test.setTimeout(60000);
      const paymentSettings = new PaymentSettings(page);

      // Seed: create initial bucket with Visa
      await paymentSettings.acquirerConfigGroupButton.click();
      const addModal = paymentSettings.addAcquirerModal;
      await paymentSettings
        .acquirerMerchantNameInput(addModal)
        .fill("Seed Merchant");
      await paymentSettings
        .acquirerMerchantIdInput(addModal)
        .fill("seedmerchant1");
      await paymentSettings.acquirerNetworkDropdownInModal(addModal).click();
      await paymentSettings.dropdownValue("Visa").click();
      await paymentSettings.acquirerBinInput(addModal).fill("56688");
      await paymentSettings.acquirerModalSaveButton(addModal).click();
      await expect(paymentSettings.acquirerCreatedToast).toBeVisible({
        timeout: 10000,
      });

      // Expand the accordion to reach the Add New Network button
      await page.getByText("Seed Merchant", { exact: true }).click();
      await expect(paymentSettings.addNewNetworkButton).toBeVisible();
      await paymentSettings.addNewNetworkButton.click();

      const netModal = paymentSettings.addNetworkModal;
      await expect(netModal).toBeVisible();
      await expect(
        netModal.getByText("Add Network Configuration", { exact: true }),
      ).toBeVisible();

      await paymentSettings.acquirerNetworkDropdownInModal(netModal).click();
      await paymentSettings.dropdownValue("Mastercard").click();
      await paymentSettings.acquirerBinInput(netModal).fill("99887");
      await paymentSettings.acquirerModalSaveButton(netModal).click();

      await expect(paymentSettings.networkAddedToast).toBeVisible({
        timeout: 10000,
      });
      await expect(page.getByText("Mastercard", { exact: true })).toBeVisible();
    });

    test("should edit an existing network entry with the network field locked", async ({
      page,
    }) => {
      test.setTimeout(60000);
      const paymentSettings = new PaymentSettings(page);

      // Seed: create initial bucket with Visa BIN 56688
      await paymentSettings.acquirerConfigGroupButton.click();
      const addModal = paymentSettings.addAcquirerModal;
      await paymentSettings
        .acquirerMerchantNameInput(addModal)
        .fill("Edit Merchant");
      await paymentSettings
        .acquirerMerchantIdInput(addModal)
        .fill("editmerchant1");
      await paymentSettings.acquirerNetworkDropdownInModal(addModal).click();
      await paymentSettings.dropdownValue("Visa").click();
      await paymentSettings.acquirerBinInput(addModal).fill("56688");
      await paymentSettings.acquirerModalSaveButton(addModal).click();
      await expect(paymentSettings.acquirerCreatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.getByText("Edit Merchant", { exact: true }).click();
      await paymentSettings.editIconForRow("Visa").click();

      const editModal = paymentSettings.editNetworkModal;
      await expect(editModal).toBeVisible();
      await expect(
        editModal.getByText("Edit Network Configuration", { exact: true }),
      ).toBeVisible();

      // The locked network field renders the current network as button text
      // (buttonText=n.network) — its mere presence proves the field is
      // pre-filled with the existing network. We don't open the dropdown
      // because Escape (the only way to close it without selecting) also
      // closes the surrounding modal in this codebase.
      await expect(
        editModal.getByRole("button", { name: "Visa" }),
      ).toBeVisible();

      // Change BIN and save
      await paymentSettings.acquirerBinInput(editModal).fill("77777");
      await paymentSettings.acquirerModalUpdateButton(editModal).click();

      await expect(paymentSettings.networkUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await expect(page.getByText("77777", { exact: true })).toBeVisible();
    });
  });

  test.describe("Custom Headers Tab", () => {
    test("should validate fields, save, reload, update again, and persist", async ({
      page,
    }) => {
      test.setTimeout(90000);
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.customHeadersTab.click();

      await expect(paymentSettings.customHeadersKeyInput).toBeVisible();
      await expect(paymentSettings.customHeadersValueInput).toBeVisible();
      await expect(paymentSettings.updateButton).toBeVisible();

      const initialKey = "X-Custom-Header";
      const initialValue = "CustomValue123";

      await paymentSettings.fillCustomHeader(initialKey, initialValue);
      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        initialKey,
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        initialValue,
      );

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");
      await paymentSettings.customHeadersTab.click();

      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        initialKey,
        { timeout: 10000 },
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        "Cu**********23",
      );

      const updatedKey = "X-Updated-Header";
      const updatedValue = "UpdatedValue456";

      await expect(paymentSettings.editButton).toBeVisible();
      await paymentSettings.editButton.click();
      await expect(paymentSettings.proceedButton).toBeVisible();
      await paymentSettings.proceedButton.click();
      await paymentSettings.fillCustomHeader(updatedKey, updatedValue);
      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        updatedKey,
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        updatedValue,
      );

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");
      await paymentSettings.customHeadersTab.click();

      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        updatedKey,
        { timeout: 10000 },
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        "Up***********56",
      );
    });
  });

  test.describe("Metadata Headers Tab", () => {
    test("should validate fields, save, reload, update again, and persist", async ({
      page,
    }) => {
      test.setTimeout(90000);
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await paymentSettings.metadataHeadersTab.click();

      await expect(paymentSettings.customMetadataHeadersHeading).toBeVisible();
      await expect(paymentSettings.customHeadersKeyInput).toBeVisible();
      await expect(paymentSettings.customHeadersValueInput).toBeVisible();
      await expect(paymentSettings.updateButton).toBeVisible();

      const initialKey = "metadata-key";
      const initialValue = "metadata-value";

      await paymentSettings.fillCustomHeader(initialKey, initialValue);
      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        initialKey,
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        initialValue,
      );

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");
      await paymentSettings.metadataHeadersTab.click();

      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        initialKey,
        { timeout: 10000 },
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        initialValue,
      );

      const updatedKey = "metadata-key-updated";
      const updatedValue = "metadata-value-updated";

      await expect(paymentSettings.editButton).toBeVisible();
      await paymentSettings.editButton.click();
      await expect(paymentSettings.proceedButton).toBeVisible();
      await paymentSettings.proceedButton.click();
      await paymentSettings.fillCustomHeader(updatedKey, updatedValue);
      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        updatedKey,
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        updatedValue,
      );

      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });
      await page.waitForLoadState("networkidle");

      await page.reload();
      await page.waitForLoadState("networkidle");
      await paymentSettings.metadataHeadersTab.click();

      await expect(paymentSettings.customHeadersKeyInput).toHaveValue(
        updatedKey,
        { timeout: 10000 },
      );
      await expect(paymentSettings.customHeadersValueInput).toHaveValue(
        updatedValue,
      );
    });
  });

  test.describe("Payment Link Tab", () => {
    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await expect(paymentSettings.pageHeader).toBeVisible();
      await paymentSettings.paymentLinkTab.click();
    });

    test("should fill all fields, save, reload, and persist", async ({
      page,
    }) => {
      const paymentSettings = new PaymentSettings(page);

      await expect(paymentSettings.paymentLinkDomainHeading).toBeVisible();
      await expect(paymentSettings.domainNameInput).toBeVisible();
      await expect(paymentSettings.allowedDomainInput).toBeVisible();
      await expect(paymentSettings.updateButton).toBeVisible();
      await expect(paymentSettings.cancelButton).toBeVisible();
      await expect(paymentSettings.updateButton).toBeDisabled();

      const domainName = "example.com";
      const allowedDomain = "https://example.com";

      await paymentSettings.fillPaymentLinkDomain(domainName, allowedDomain);
      await expect(paymentSettings.domainNameInput).toHaveValue(domainName);
      await expect(paymentSettings.allowedDomainInput).toHaveValue(
        allowedDomain,
      );

      await expect(paymentSettings.updateButton).toBeEnabled();
      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();
      await paymentSettings.paymentLinkTab.click();

      await expect(paymentSettings.domainNameInput).toHaveValue(domainName, {
        timeout: 10000,
      });
      await expect(paymentSettings.allowedDomainInput).toHaveValue(
        allowedDomain,
      );
    });

    test("should show validation errors for each field", async ({ page }) => {
      const paymentSettings = new PaymentSettings(page);

      await paymentSettings.paymentLinkDomainHeading.click();
      // Domain Name — invalid → error appears
      await paymentSettings.domainNameInput.fill("not a valid url");
      await paymentSettings.domainNameInput.blur();
      await expect(paymentSettings.validUrlError).toBeVisible();

      // Domain Name — valid → error clears
      await paymentSettings.domainNameInput.fill("example.com");
      await paymentSettings.domainNameInput.blur();
      await expect(paymentSettings.validUrlError).toHaveCount(0);

      // Allowed Domains — invalid → error appears
      await paymentSettings.allowedDomainInput.fill("not a valid url");
      await paymentSettings.allowedDomainInput.blur();
      await expect(paymentSettings.allowedDomainsError).toBeVisible();

      // Allowed Domains — valid → error clears
      await paymentSettings.allowedDomainInput.fill("https://example.com");
      await paymentSettings.allowedDomainInput.blur();
      await expect(paymentSettings.allowedDomainsError).toHaveCount(0);

      // With both fields valid, Update should be enabled
      await expect(paymentSettings.updateButton).toBeEnabled();
    });
  });

  test.describe("Payment Method Blocking", () => {
    let paymentSettings: PaymentSettings;

    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await expect(page).toHaveURL(/.*dashboard\/payment-settings/);

      await paymentSettings.blockListTab.click();
      await expect(paymentSettings.paymentMethodBlocking).toBeVisible();
    });

    test.describe("Section layout", () => {
      test("should show a blocking accordion for card and both wallets", async () => {
        await expect(paymentSettings.cardPaymentMethodBlocking).toBeVisible();
        await expect(
          paymentSettings.applePayPaymentMethodBlocking,
        ).toBeVisible();
        await expect(
          paymentSettings.googlePayPaymentMethodBlocking,
        ).toBeVisible();
        await expect(paymentSettings.updateButton).toBeVisible();
      });

      test("should render a searchable country filter for every payment method", async () => {
        for (const section of BLOCKING_SECTIONS) {
          await paymentSettings.paymentMethodBlockingAccordion(section).click();
          await expect(
            paymentSettings.paymentMethodBlockingDropdown(
              section,
              "Select Countries",
            ),
          ).toBeVisible();
          // Collapse again so the next section's locators stay unambiguous.
          await paymentSettings.paymentMethodBlockingAccordion(section).click();
        }
      });
    });

    test.describe("Card accordion", () => {
      test.beforeEach(async () => {
        await paymentSettings.paymentMethodBlockingAccordion("Card").click();
      });

      test("should expose every filter and toggle inside an expanded accordion", async ({
        page,
      }) => {
        for (const field of BLOCKING_SELECT_FIELDS) {
          await expect(
            page.getByText(field.label, { exact: true }).first(),
          ).toBeVisible();
          await expect(
            paymentSettings.paymentMethodBlockingDropdown(
              "Card",
              field.buttonText,
            ),
          ).toBeVisible();
        }

        for (const toggleLabel of BLOCKING_TOGGLE_FIELDS) {
          await expect(
            page.getByText(toggleLabel, { exact: true }).first(),
          ).toBeVisible();
        }

        // The non-obvious default for unrecognised BINs is explained in a tooltip.
        await paymentSettings.openPaymentMethodBlockingTooltip(
          "Card",
          "Block if BIN info unavailable",
        );
        await expect(
          page
            .getByText(
              /Off by default, so unrecognised BINs are allowed through\./,
            )
            .first(),
        ).toBeVisible();
      });

      test("should submit the new card filters under payment_method_blocking.card", async ({
        page,
      }) => {
        await paymentSettings
          .paymentMethodBlockingDropdown("Card", "Select Card Networks")
          .click();
        await paymentSettings.dropdownValueByText("Visa").click();
        await page.keyboard.press("Escape");

        await paymentSettings
          .paymentMethodBlockingDropdown("Card", "Select Funding Sources")
          .click();
        await paymentSettings.dropdownValueByText("Credit").first().click();
        await page.keyboard.press("Escape");

        const updateRequest = captureProfileUpdate(page);
        await paymentSettings.clickUpdate();

        const cardBlocking = (await updateRequest).postDataJSON()
          .payment_method_blocking.card;

        expect(cardBlocking.card_networks).toEqual(["Visa"]);
        expect(cardBlocking.funding_sources).toEqual(["CREDIT"]);
        await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
          timeout: 10000,
        });
      });

      test("should submit blocking toggles as booleans for the selected payment method", async ({
        page,
      }) => {
        await paymentSettings
          .paymentMethodBlockingToggle("Card", "Block virtual cards")
          .click();
        await paymentSettings
          .paymentMethodBlockingToggle("Card", "Block gambling BINs")
          .click();

        const updateRequest = captureProfileUpdate(page);
        await paymentSettings.clickUpdate();

        const cardBlocking = (await updateRequest).postDataJSON()
          .payment_method_blocking.card;

        expect(cardBlocking.block_virtual_cards).toBe(true);
        expect(cardBlocking.gambling_blocked).toBe(true);
        // Untouched toggles must not be silently switched on.
        expect(cardBlocking.block_if_bin_info_unavailable).toBeFalsy();
      });

      test("should persist blocking selections across a page reload", async ({
        page,
      }) => {
        await paymentSettings
          .paymentMethodBlockingToggle("Card", "Block virtual cards")
          .click();
        await paymentSettings.clickUpdate();
        await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
          timeout: 10000,
        });

        await page.reload();
        await paymentSettings.blockListTab.click();
        await paymentSettings.paymentMethodBlockingAccordion("Card").click();

        await expect(
          paymentSettings.paymentMethodBlockingToggle(
            "Card",
            "Block virtual cards",
          ),
        ).toHaveAttribute("data-bool-value", "on");
      });

      test("should show an error toast and stay on the tab when the update fails", async ({
        page,
      }) => {
        await paymentSettings
          .paymentMethodBlockingToggle("Card", "Block virtual cards")
          .click();

        await page.route("**/business_profile/**", async (route) => {
          if (route.request().method() === "POST") {
            await route.fulfill({
              status: 500,
              contentType: "application/json",
              body: JSON.stringify({ error: { message: "Update rejected" } }),
            });
            return;
          }
          await route.fallback();
        });

        await paymentSettings.clickUpdate();

        await expect(page.getByText("Failed to update")).toBeVisible({
          timeout: 10000,
        });
        await expect(paymentSettings.paymentMethodBlocking).toBeVisible();
      });

      test("should allow selecting several values in one filter and clearing them again", async ({
        page,
      }) => {
        await paymentSettings
          .paymentMethodBlockingDropdown("Card", "Select Card Types")
          .click();
        await paymentSettings.dropdownValueByText("Credit").first().click();
        await paymentSettings.dropdownValueByText("Debit").first().click();
        await page.keyboard.press("Escape");

        let updateRequest = captureProfileUpdate(page);
        await paymentSettings.clickUpdate();
        let cardBlocking = (await updateRequest).postDataJSON()
          .payment_method_blocking.card;
        expect(cardBlocking.card_types).toEqual(["credit", "debit"]);

        await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
          timeout: 10000,
        });

        // Saving remounts the form, which collapses the accordion again.
        await paymentSettings.paymentMethodBlockingAccordion("Card").click();

        // Deselecting both must clear the filter rather than leave a stale value.
        await paymentSettings
          .paymentMethodBlockingDropdown("Card", "Select Card Types")
          .click();
        await paymentSettings.dropdownValueByText("Credit").first().click();
        await paymentSettings.dropdownValueByText("Debit").first().click();
        await page.keyboard.press("Escape");

        updateRequest = captureProfileUpdate(page);
        await paymentSettings.clickUpdate();
        cardBlocking = (await updateRequest).postDataJSON()
          .payment_method_blocking.card;
        expect(cardBlocking.card_types ?? []).toEqual([]);
      });
    });

    test.describe("Wallet accordions", () => {
      test("should submit nested wallet payment method blocking payload", async ({
        page,
      }) => {
        await expect(
          paymentSettings.applePayPaymentMethodBlocking,
        ).toBeVisible();
        await expect(
          paymentSettings.googlePayPaymentMethodBlocking,
        ).toBeVisible();

        await paymentSettings
          .paymentMethodBlockingAccordion("Apple Pay")
          .click();
        await paymentSettings
          .paymentMethodBlockingCardTypesDropdown("Apple Pay")
          .click();
        await paymentSettings.dropdownValueByText("Credit").click();
        await page.keyboard.press("Escape");

        await expect(
          paymentSettings.dropdownValueByText("Credit"),
        ).not.toBeVisible();

        await paymentSettings
          .paymentMethodBlockingAccordion("Google Pay")
          .click();
        await paymentSettings
          .paymentMethodBlockingCardTypesDropdown("Google Pay")
          .click();
        await paymentSettings.dropdownValueByText("Debit").click();
        await page.keyboard.press("Escape");

        const updateRequest = captureProfileUpdate(page);
        await paymentSettings.clickUpdate();

        const walletBlocking = (await updateRequest).postDataJSON()
          .payment_method_blocking.wallet;

        expect(walletBlocking.card_types).toBeUndefined();
        expect(walletBlocking.apple_pay.card_types).toEqual(["credit"]);
        expect(walletBlocking.google_pay.card_types).toEqual(["debit"]);
        await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
          timeout: 10000,
        });
      });

      test("should not send blocking config for payment methods left untouched", async ({
        page,
      }) => {
        await paymentSettings
          .paymentMethodBlockingAccordion("Apple Pay")
          .click();
        await paymentSettings
          .paymentMethodBlockingDropdown("Apple Pay", "Select Card Types")
          .click();
        await paymentSettings.dropdownValueByText("Credit").first().click();
        await page.keyboard.press("Escape");

        const updateRequest = captureProfileUpdate(page);
        await paymentSettings.clickUpdate();

        const blocking = (await updateRequest).postDataJSON()
          .payment_method_blocking;

        expect(blocking.wallet.apple_pay.card_types).toEqual(["credit"]);
        // Google Pay was never opened, so it must not inherit Apple Pay's choice.
        expect(blocking.wallet.google_pay?.card_types).toBeUndefined();
      });

      test("should keep card and wallet filters independent of one another", async ({
        page,
      }) => {
        await paymentSettings.paymentMethodBlockingAccordion("Card").click();
        await paymentSettings
          .paymentMethodBlockingDropdown("Card", "Select Card Types")
          .click();
        await paymentSettings.dropdownValueByText("Credit").first().click();
        await page.keyboard.press("Escape");

        await paymentSettings
          .paymentMethodBlockingAccordion("Google Pay")
          .click();
        await paymentSettings
          .paymentMethodBlockingDropdown("Google Pay", "Select Card Types")
          .click();
        await paymentSettings.dropdownValueByText("Debit").first().click();
        await page.keyboard.press("Escape");

        const updateRequest = captureProfileUpdate(page);
        await paymentSettings.clickUpdate();

        const blocking = (await updateRequest).postDataJSON()
          .payment_method_blocking;

        expect(blocking.card.card_types).toEqual(["credit"]);
        expect(blocking.wallet.google_pay.card_types).toEqual(["debit"]);
        // The wallet grouping must not collapse into a shared card_types key.
        expect(blocking.wallet.card_types).toBeUndefined();
      });
    });
  });

  test.describe("Account Updater", () => {
    let paymentSettings: PaymentSettings;

    test.beforeEach(async ({ page }) => {
      const homePage = new HomePage(page);
      paymentSettings = new PaymentSettings(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await expect(page).toHaveURL(/.*dashboard\/payment-settings/);
    });

    test("should show the Account Updater section with its explanation and supported networks", async ({
      page,
    }) => {
      await expect(paymentSettings.accountUpdaterHeading).toBeVisible();
      await expect(paymentSettings.accountUpdaterDescription).toBeVisible();

      await expect(
        page.getByText(
          /keeps stored cards current .*when a card is reissued, expired or replaced/i,
        ),
      ).toBeVisible();

      // Visa and Mastercard are called out in the copy and as network logos.
      await expect(paymentSettings.accountUpdaterVisaIcon).toBeVisible();
      await expect(paymentSettings.accountUpdaterMastercardIcon).toBeVisible();
    });

    test("should link out to Slack in a new tab for enabling the feature", async () => {
      await expect(paymentSettings.accountUpdaterSlackLink).toBeVisible();
      await expect(paymentSettings.accountUpdaterSlackLink).toHaveAttribute(
        "href",
        SLACK_URL,
      );
      await expect(paymentSettings.accountUpdaterSlackLink).toHaveAttribute(
        "target",
        "_blank",
      );
    });

    test("should render the toggle off and refuse to turn it on", async () => {
      const toggle = paymentSettings.accountUpdaterToggle;
      await expect(toggle).toBeVisible();
      await expect(toggle).toHaveAttribute("data-bool-value", "off");

      // Merchants must go through support; the control must not be operable.
      await toggle.click({ force: true });
      await expect(toggle).toHaveAttribute("data-bool-value", "off");
    });

    test("should not send any account updater field when the profile is updated", async ({
      page,
    }) => {
      await expect(paymentSettings.accountUpdaterHeading).toBeVisible();
      await paymentSettings.fillReturnUrl("https://example.com/return");

      const updateRequest = captureProfileUpdate(page);
      await paymentSettings.clickUpdate();

      const payload = (await updateRequest).postDataJSON();

      // The section is display-only; it must not leak a field into the profile.
      expect(JSON.stringify(payload)).not.toContain("account_updater");
      expect(payload.return_url).toBe("https://example.com/return");
    });

    test("should keep the section visible and still disabled after saving and reloading", async ({
      page,
    }) => {
      await paymentSettings.fillReturnUrl("https://example.com/return");
      await paymentSettings.clickUpdate();
      await expect(paymentSettings.detailsUpdatedToast).toBeVisible({
        timeout: 10000,
      });

      await page.reload();

      await expect(paymentSettings.accountUpdaterHeading).toBeVisible();
      await expect(paymentSettings.accountUpdaterToggle).toHaveAttribute(
        "data-bool-value",
        "off",
      );
      await expect(paymentSettings.accountUpdaterVisaIcon).toBeVisible();
      await expect(paymentSettings.accountUpdaterMastercardIcon).toBeVisible();
    });
  });

  test.describe("Block List Tab", () => {
    test.describe("CSV upload", () => {
      test.describe("with no jobs yet", () => {
        useBlockListTab({ jobs: [] });

        test("should show the upload UI and hide the jobs table", async ({
          page,
        }) => {
          await expect(blocklist.pageHeading).toBeVisible();
          await expect(blocklist.uploadCsvHeading).toBeVisible();
          await expect(blocklist.uploadFileText).toBeVisible();
          await expect(blocklist.supportedFileText).toBeVisible();
          await expect(blocklist.downloadSampleFileButton).toBeVisible();
          await expect(blocklist.chooseFileButton).toHaveCount(1);
          await expect(blocklist.chooseFileButton).toBeVisible();
          await expect(blocklist.jobsTable).toBeHidden();
          await expect(page.getByText("CSV sample format")).toBeHidden();
          await expect(page.getByText("type,data,metadata")).toBeHidden();
        });

        test("should download sample CSV file from frontend content", async ({
          page,
        }) => {
          const [download] = await Promise.all([
            page.waitForEvent("download"),
            blocklist.downloadSampleFileButton.click(),
          ]);

          expect(download.suggestedFilename()).toBe("blocklist_sample.csv");

          const stream = await download.createReadStream();
          const chunks: Buffer[] = [];
          for await (const chunk of stream) {
            chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
          }

          expect(Buffer.concat(chunks).toString()).toBe(
            "type,data,metadata\ngeneric_card_bin,411111,source=fraud_team;reason=chargeback\ngeneric_card_bin,4111111100,\nfingerprint,fp_abc123,",
          );
        });

        test("should reject CSV files with unsupported MIME type", async ({
          page,
        }) => {
          await blocklist.fileInput.setInputFiles({
            name: "blocklist.csv",
            mimeType: "application/json",
            buffer: Buffer.from("type,data,metadata\ncard_bin,411111,"),
          });

          await expect(
            page.getByText("Please upload a valid CSV file."),
          ).toBeVisible();
        });

        test("should accept CSV files with common browser MIME variants", async ({
          page,
        }) => {
          await blocklist.fileInput.setInputFiles({
            name: "blocklist.csv",
            mimeType: "application/vnd.ms-excel",
            buffer: Buffer.from("type,data,metadata\ncard_bin,411111,"),
          });

          await expect(blocklist.uploadButton).toBeVisible();
          await expect(
            page.getByText("Please upload a valid CSV file."),
          ).toBeHidden();

          await blocklist.removeSelectedFileButton.click();

          await blocklist.fileInput.setInputFiles({
            name: "blocklist.csv",
            mimeType: "",
            buffer: Buffer.from("type,data,metadata\nfingerprint,fp_abc123,"),
          });

          await expect(blocklist.uploadButton).toBeVisible();
          await expect(
            page.getByText("Please upload a valid CSV file."),
          ).toBeHidden();
        });

        test("should reject CSV files larger than 5 MB", async ({ page }) => {
          await blocklist.fileInput.setInputFiles({
            name: "blocklist.csv",
            mimeType: "text/csv",
            buffer: Buffer.alloc(5 * 1024 * 1024 + 1, "a"),
          });

          await expect(
            page.getByText("CSV files larger than 5 MB cannot be processed."),
          ).toBeVisible();
        });

        test("should reject an empty CSV file", async ({ page }) => {
          await blocklist.fileInput.setInputFiles({
            name: "blocklist.csv",
            mimeType: "text/csv",
            buffer: Buffer.from(""),
          });

          await expect(
            page.getByText("CSV file must contain at least one data row."),
          ).toBeVisible();
          await expect(blocklist.uploadButton).toBeHidden();
        });

        test("should accept a CSV file with exactly 100,000 rows", async () => {
          await blocklist.fileInput.setInputFiles({
            name: "blocklist.csv",
            mimeType: "text/csv",
            buffer: Buffer.from(makeBlocklistCsvWithDataRows(100_000)),
          });

          await expect(blocklist.uploadButton).toBeVisible();
        });

        test("should reject a CSV file with 100,001 rows", async ({ page }) => {
          await blocklist.fileInput.setInputFiles({
            name: "blocklist.csv",
            mimeType: "text/csv",
            buffer: Buffer.from(makeBlocklistCsvWithDataRows(100_001)),
          });

          await expect(
            page.getByText(
              "CSV files with more than 100,000 rows cannot be processed.",
            ),
          ).toBeVisible();
          await expect(blocklist.uploadButton).toBeHidden();
        });
      });

      test.describe("when the upload succeeds", () => {
        useBlockListTab({
          jobs: [],
          jobsAfterAction: [
            makeJob({ job_id: "blockbatch_test", status: "initiated" }),
          ],
        });

        test("should upload CSV and refresh blocklist jobs", async ({
          page,
        }) => {
          await blocklist.fileInput.setInputFiles({
            name: "blocklist.csv",
            mimeType: "text/csv",
            buffer: Buffer.from(
              "type,data,metadata\ncard_bin,411111,source=fraud_team\nfingerprint,fp_abc123,",
            ),
          });

          const uploadResponsePromise = page.waitForResponse(
            (response) =>
              response.url().includes("/blocklist/batch") &&
              response.request().method() === "POST" &&
              response.status() === 200,
          );
          const refreshedListPromise = page.waitForResponse((response) => {
            const requestUrl = new URL(response.url());
            return (
              requestUrl.pathname.endsWith("/blocklist/batch") &&
              response.request().method() === "GET" &&
              requestUrl.searchParams.get("offset") === "0" &&
              response.status() === 200
            );
          });

          await Promise.all([
            uploadResponsePromise,
            refreshedListPromise,
            blocklist.uploadButton.click(),
          ]);

          await expect(
            page.getByText("blockbatch_test", { exact: true }),
          ).toBeVisible();
          expect(blocklistCalls.uploadCount).toBe(1);
        });
      });

      test.describe("when the upload fails", () => {
        useBlockListTab({ jobs: [], uploadStatus: 500 });

        test("should show upload error when CSV upload fails", async () => {
          await blocklist.fileInput.setInputFiles({
            name: "blocklist.csv",
            mimeType: "text/csv",
            buffer: Buffer.from("type,data,metadata\ncard_bin,411111,"),
          });
          await blocklist.uploadButton.click();

          await expect(blocklist.toast("Upload failed")).toHaveCount(1);
          await expect(blocklist.toast("Upload failed")).toBeVisible();
        });
      });

      test.describe("with more jobs than fit on one page", () => {
        useBlockListTab({
          jobsByOffset: (offset) =>
            offset === RESULTS_PER_PAGE
              ? { data: [makeJob({ job_id: "blkbatch_11" })], total: 11 }
              : {
                  data: Array.from({ length: RESULTS_PER_PAGE }, (_, index) =>
                    makeJob({
                      job_id: `blkbatch_${String(index + 1).padStart(2, "0")}`,
                    }),
                  ),
                  total: 11,
                },
        });

        test("should request and render the second page using item offset", async ({
          page,
        }) => {
          await expect(page.getByText("blkbatch_01")).toBeVisible();

          await page.getByRole("button", { name: "2", exact: true }).click();

          await expect(page.getByText("blkbatch_11")).toBeVisible();
          const secondPageRequestUrl = blocklistCalls.listUrls.find((url) =>
            url.includes(`offset=${RESULTS_PER_PAGE}`),
          );
          expect(secondPageRequestUrl).toContain(`limit=${RESULTS_PER_PAGE}`);
          expect(secondPageRequestUrl).toContain(`offset=${RESULTS_PER_PAGE}`);
        });
      });
    });

    test.describe("Count summary", () => {
      test.describe("with a per-length breakdown", () => {
        useBlockListTab({
          cardBinCounts: { "6": 1234, "8": 56 },
          fingerprintTotal: 7,
        });

        test("should show one count card per BIN length plus fingerprints", async ({
          page,
        }) => {
          await expect(blocklist.binLengthCountCard(6)).toBeVisible();
          await expect(blocklist.binLengthCountCard(8)).toBeVisible();
          await expect(blocklist.fingerprintsCountCard).toBeVisible();

          // Counts are thousand-separated for readability.
          await expect(page.getByText("1,234", { exact: true })).toBeVisible();
          await expect(page.getByText("56", { exact: true })).toBeVisible();
          await expect(blocklist.countsHelperText).toBeVisible();
        });
      });

      test.describe("without a per-length breakdown", () => {
        useBlockListTab({ cardBinCounts: {}, cardBinTotal: 42 });

        test("should fall back to a single Card BINs card when no length breakdown is returned", async ({
          page,
        }) => {
          await expect(blocklist.cardBinsCountCard).toBeVisible();
          await expect(page.getByText("42", { exact: true })).toBeVisible();
          await expect(blocklist.binLengthCountCard(6)).toBeHidden();
        });
      });

      test.describe("when the count request fails", () => {
        useBlockListTab({ countStatus: 500 });

        test("should show a failure message when counts cannot be loaded", async () => {
          await expect(blocklist.countLoadFailureMessage).toBeVisible();
        });
      });
    });

    test.describe("Check Blocklist lookup", () => {
      test.describe("for a blocked value", () => {
        useBlockListTab({ lookupBlocked: true });

        test("should report a blocked value from the lookup card", async () => {
          await expect(blocklist.lookupHeading).toBeVisible();
          await expect(blocklist.lookupDescription).toBeVisible();
          await expect(blocklist.lookupHint).toBeVisible();

          await blocklist.lookupInput.fill("411111");
          await blocklist.lookupCheckButton.click();

          await expect(blocklist.lookupBlockedTag).toBeVisible();
          expect(blocklistCalls.lookupUrls[0]).toContain("data=411111");
        });

        test("should keep Check disabled for empty or whitespace-only input", async () => {
          await expect(blocklist.lookupCheckButton).toBeDisabled();

          await blocklist.lookupInput.fill("   ");
          await expect(blocklist.lookupCheckButton).toBeDisabled();

          await blocklist.lookupInput.fill("411111");
          await expect(blocklist.lookupCheckButton).toBeEnabled();
        });

        test("should clear a stale lookup result when the input changes", async () => {
          await blocklist.lookupInput.fill("411111");
          await blocklist.lookupCheckButton.click();
          await expect(blocklist.lookupBlockedTag).toBeVisible();

          // A result must never appear to belong to a value it was not checked for.
          await blocklist.lookupInput.fill("422222");
          await expect(blocklist.lookupBlockedTag).toBeHidden();
        });
      });

      test.describe("for a value that is not blocked", () => {
        useBlockListTab({ lookupBlocked: false });

        test("should report a value that is not blocked", async () => {
          await blocklist.lookupInput.fill("fp_abc123");
          await blocklist.lookupCheckButton.click();

          await expect(blocklist.lookupNotBlockedTag).toBeVisible();
        });
      });

      test.describe("when the lookup request fails", () => {
        useBlockListTab({ lookupStatus: 500 });

        test("should surface a readable error when the lookup call fails", async () => {
          await blocklist.lookupInput.fill("411111");
          await blocklist.lookupCheckButton.click();

          await expect(
            blocklist.toast("Lookup service unavailable"),
          ).toBeVisible();
        });
      });
    });

    test.describe("Add and remove single entries", () => {
      test.describe("when the entry request succeeds", () => {
        useBlockListTab();

        test("should add a single card BIN to the blocklist", async () => {
          await blocklist.addEntryDataInput.fill("411111");
          await blocklist.addEntryButton.click();

          await expect(
            blocklist.toast("Added fp_generated_001 to blocklist."),
          ).toBeVisible();
          expect(blocklistCalls.entryMethods).toContain("POST");
          expect(blocklistCalls.entryBodies[0]).toEqual({
            type: "generic_card_bin",
            data: "411111",
          });

          // The field resets so the next entry starts clean.
          await expect(blocklist.addEntryDataInput).toHaveValue("");
        });

        test("should remove a single entry from the blocklist", async () => {
          await blocklist.removeEntryDataInput.fill("411111");
          await blocklist.removeEntryButton.click();

          await expect(
            blocklist.toast("Removed fp_generated_001 from blocklist."),
          ).toBeVisible();
          expect(blocklistCalls.entryMethods).toContain("DELETE");
        });

        test("should reject a card BIN shorter than six digits", async () => {
          await blocklist.addEntryDataInput.fill("41111");
          await blocklist.addEntryButton.click();

          await expect(
            blocklist.helperTextIn(
              blocklist.addEntryCard,
              "Card BIN must be 6 to 10 digits.",
            ),
          ).toBeVisible();
          // Nothing is sent while the value is invalid.
          expect(blocklistCalls.entryMethods).toHaveLength(0);
        });

        test("should keep the action disabled until a value is entered", async () => {
          await expect(blocklist.addEntryButton).toBeDisabled();
          await blocklist.addEntryDataInput.fill("411111");
          await expect(blocklist.addEntryButton).toBeEnabled();
        });

        test("should ignore non-digits typed into a card BIN field", async () => {
          await blocklist.addEntryDataInput.fill("4111ab");

          // Generic Card BIN is numeric-only, so the letters never reach the field.
          await expect(blocklist.addEntryDataInput).not.toHaveValue("4111ab");
        });

        test("should accept an alphanumeric value once the type is Fingerprint", async () => {
          await blocklist.typeDropdownIn(blocklist.addEntryCard).click();
          await blocklist.dropdownOption("Fingerprint").last().click();

          await blocklist.addEntryDataInput.fill("fp_abc123");
          await expect(blocklist.addEntryDataInput).toHaveValue("fp_abc123");

          await blocklist.addEntryButton.click();
          expect(blocklistCalls.entryBodies[0]).toEqual({
            type: "fingerprint",
            data: "fp_abc123",
          });
        });
      });

      test.describe("when the entry request fails", () => {
        useBlockListTab({ entryStatus: 400 });

        test("should show the API error when an entry cannot be added", async () => {
          await blocklist.addEntryDataInput.fill("411111");
          await blocklist.addEntryButton.click();

          await expect(
            blocklist.toast("Entry already present in blocklist"),
          ).toBeVisible();
        });
      });
    });

    test.describe("Generate export", () => {
      test.describe("when the export is queued", () => {
        useBlockListTab({
          jobs: [],
          jobsAfterAction: [
            makeJob({
              job_id: "blkexp_01",
              job_type: "export",
              status: "initiated",
            }),
          ],
        });

        test("should queue an export and refresh the jobs table", async ({
          page,
        }) => {
          await expect(blocklist.generateExportHeading).toBeVisible();
          await expect(blocklist.generateExportDescription).toBeVisible();

          await blocklist.generateExportButton.click();

          await expect(
            blocklist.toast(
              "Blocklist export started. File: blocklist_export_2026_09_15.csv",
            ),
          ).toBeVisible();
          expect(blocklistCalls.exportCount).toBe(1);

          await expect(
            page.getByText("blkexp_01", { exact: true }),
          ).toBeVisible();
        });
      });

      test.describe("when the export request fails", () => {
        useBlockListTab({ exportStatus: 500 });

        test("should show an error when the export cannot be queued", async () => {
          await blocklist.generateExportButton.click();

          await expect(
            blocklist.toast("Export could not be queued"),
          ).toBeVisible();
        });
      });
    });

    test.describe("Jobs table actions", () => {
      test.describe("with a downloadable export and a running upload", () => {
        useBlockListTab({
          jobs: [
            makeJob({
              job_id: "blkexp_done",
              job_type: "export",
              status: "completed",
              downloadable: true,
            }),
            makeJob({
              job_id: "blkjob_running",
              status: "processing",
              succeeded_rows: 1,
            }),
          ],
        });

        test("should offer Download for a completed export and Refresh for a running upload", async ({
          page,
        }) => {
          await expect(
            page.getByText("blkexp_done", { exact: true }),
          ).toBeVisible();
          await expect(
            page.getByText("blkjob_running", { exact: true }),
          ).toBeVisible();

          await expect(blocklist.downloadExportAction).toHaveCount(1);
          await expect(blocklist.refreshJobAction).toHaveCount(1);

          // Export rows have no per-row success/failure counts.
          await expect(
            blocklist
              .jobRow("blkexp_done")
              .getByText("-", { exact: true })
              .first(),
          ).toBeVisible();
        });
      });

      test.describe("with an export that is not yet downloadable", () => {
        useBlockListTab({
          jobs: [
            makeJob({
              job_id: "blkexp_pending",
              job_type: "export",
              status: "completed",
              downloadable: false,
            }),
          ],
        });

        test("should disable Download while a completed export is not yet downloadable", async ({
          page,
        }) => {
          await expect(
            page.getByText("blkexp_pending", { exact: true }),
          ).toBeVisible();
          await expect(blocklist.downloadExportAction).toBeVisible();
          // The action renders as a non-interactive icon rather than a disabled button.
          await expect(
            blocklist.downloadExportAction.locator("svg"),
          ).toHaveClass(/cursor-not-allowed/);
        });
      });

      test.describe("with a refreshable upload job", () => {
        useBlockListTab({
          jobs: [
            makeJob({
              job_id: "blkjob_01",
              status: "processing",
              succeeded_rows: 1,
            }),
          ],
          refreshedJob: makeJob({
            job_id: "blkjob_01",
            status: "completed",
            succeeded_rows: 3,
          }),
        });

        test("should refresh a running upload job and show its new status", async ({
          page,
        }) => {
          await expect(
            page.getByText("Processing", { exact: true }),
          ).toBeVisible();
          await blocklist.refreshJobAction.click();

          await expect(blocklist.toast("Refreshed blkjob_01")).toBeVisible();
          await expect(
            page.getByText("Completed", { exact: true }),
          ).toBeVisible();
        });
      });
    });

    test.describe("Feature flag off", () => {
      useBlockListTab({}, false);

      test("should hide the blocklist content when the feature flag is off", async ({
        page,
      }) => {
        // Payment Method Blocking stays; the blocklist tooling is hidden.
        await expect(
          page.getByText("Payment Method Blocking", { exact: true }),
        ).toBeVisible();
        await expect(blocklist.pageHeading).toBeHidden();
        await expect(blocklist.uploadCsvHeading).toBeHidden();
        await expect(blocklist.lookupHeading).toBeHidden();
        await expect(blocklist.generateExportHeading).toBeHidden();
        await expect(blocklist.addEntryButton).toBeHidden();
      });
    });
  });
});
