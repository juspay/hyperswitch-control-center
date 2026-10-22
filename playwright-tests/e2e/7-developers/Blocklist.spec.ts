import { test, expect } from "../../support/test";
import { Locator, Page } from "@playwright/test";
import { signupUser, loginUI } from "../../support/commands";
import { generateUniqueEmail } from "../../support/helper";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { Blocklist } from "../../support/pages/developers/Blocklist";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
const RESULTS_PER_PAGE = 10;

const setBlocklistFeatureFlag = async (
  page: Page,
  enabled: boolean,
  payoutBlocklistEnabled = false,
) => {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    if (json && json.features) {
      json.features.dev_blocklist = enabled;
      json.features.dev_payout_blocklist = payoutBlocklistEnabled;
    }
    await route.fulfill({ response, json });
  });
};

type TransactionType = "payment" | "payout";

type BlocklistApiCalls = {
  counts: URL[];
  entries: { method: string; body: Record<string, string> }[];
  lookups: URL[];
  exports: URL[];
};

const mockBlocklistApis = async (
  page: Page,
  {
    countsByType = {
      payment: { cardBin: { "6": 12, "8": 3 }, fingerprint: 4 },
      payout: { cardBin: { "6": 2 }, fingerprint: 1 },
    },
    lookupBlocked = true,
  }: {
    countsByType?: Record<
      TransactionType,
      { cardBin: Record<string, number>; fingerprint: number }
    >;
    lookupBlocked?: boolean;
  } = {},
): Promise<BlocklistApiCalls> => {
  const calls: BlocklistApiCalls = {
    counts: [],
    entries: [],
    lookups: [],
    exports: [],
  };

  await page.route("**/blocklist/batch?**", async (route) => {
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({ data: [], total_count: 0 }),
    });
  });

  await page.route("**/blocklist/count?**", async (route) => {
    const url = new URL(route.request().url());
    calls.counts.push(url);
    const transactionType = (url.searchParams.get("transaction_type") ||
      "payment") as TransactionType;
    const counts = countsByType[transactionType];
    const body =
      url.searchParams.get("data_kind") === "payment_method"
        ? { total_count: counts.fingerprint }
        : {
            total_count: Object.values(counts.cardBin).reduce(
              (sum, n) => sum + n,
              0,
            ),
            counts_by_length: counts.cardBin,
          };
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify(body),
    });
  });

  await page.route("**/blocklist", async (route) => {
    const request = route.request();
    const body = request.postDataJSON() || {};
    calls.entries.push({ method: request.method(), body });
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        fingerprint_id: body.data,
        data_kind: body.type,
        created_at: "2026-10-19T06:08:47.617Z",
      }),
    });
  });

  await page.route("**/blocklist/lookup?**", async (route) => {
    const url = new URL(route.request().url());
    calls.lookups.push(url);
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        data: url.searchParams.get("data"),
        blocked: lookupBlocked,
      }),
    });
  });

  await page.route("**/blocklist/export**", async (route) => {
    calls.exports.push(new URL(route.request().url()));
    await route.fulfill({
      status: 200,
      contentType: "application/json",
      body: JSON.stringify({
        job_id: "blkbatch_export",
        file_name: "blocklist_export.csv",
      }),
    });
  });

  return calls;
};

const selectEntryType = async (
  blocklist: Blocklist,
  panel: Locator,
  label: string,
) => {
  await blocklist.entryTypeDropdown(panel).click();
  await blocklist.entryTypeOption(label).click();
};

const openBlocklistTab = async (page: Page) => {
  const homePage = new HomePage(page);
  const blocklist = new Blocklist(page);

  await homePage.developer.click();
  await homePage.paymentSettings.click();
  await expect(page).toHaveURL(/.*dashboard\/payment-settings/);

  await expect(blocklist.tab).toBeVisible();
  await blocklist.tab.click();

  return blocklist;
};

const makeBlocklistJob = (jobId: string) => ({
  job_id: jobId,
  merchant_id: "merchant_test",
  job_type: "upload",
  status: "completed",
  total_rows: 3,
  succeeded_rows: 3,
  failed_rows: 0,
  created_at: "2026-05-06T06:08:47.617Z",
  updated_at: "2026-05-06T06:08:47.617Z",
  downloadable: false,
});

const makeBlocklistJobs = (count: number) =>
  Array.from({ length: count }, (_, index) =>
    makeBlocklistJob(`blkbatch_${String(index + 1).padStart(2, "0")}`),
  );

const makeBlocklistCsvWithDataRows = (rowCount: number) =>
  `type,data,metadata\n${Array.from(
    { length: rowCount },
    () => "card_bin,411111,",
  ).join("\n")}`;

test.describe("Blocklist", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await setBlocklistFeatureFlag(page, true);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to Blocklist page via sidebar and show upload UI", async ({
    page,
  }) => {
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const blocklist = await openBlocklistTab(page);

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
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const blocklist = await openBlocklistTab(page);

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
      "type,data,metadata,transaction_type\ngeneric_card_bin,411111,source=fraud_team;reason=chargeback,payment\ngeneric_card_bin,4111111100,,payment\nfingerprint,fp_abc123,,payout",
    );
  });

  test("should upload CSV and refresh blocklist jobs", async ({ page }) => {
    let listRequestCount = 0;

    await page.route("**/blocklist/batch?**", async (route) => {
      listRequestCount += 1;
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          data:
            listRequestCount > 1
              ? [
                  {
                    job_id: "blockbatch_test",
                    merchant_id: "merchant_test",
                    job_type: "upload",
                    status: "initiated",
                    total_rows: 3,
                    succeeded_rows: 0,
                    failed_rows: 0,
                    created_at: "2026-05-06T06:08:47.617Z",
                    updated_at: "2026-05-06T06:08:47.617Z",
                    downloadable: false,
                  },
                ]
              : [],
          total_count: listRequestCount > 1 ? 1 : 0,
        }),
      });
    });

    await page.route("**/blocklist/batch", async (route) => {
      if (route.request().method() === "POST") {
        await route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify({
            job_id: "blockbatch_test",
            total_rows: 3,
            status: "initiated",
          }),
        });
      } else {
        await route.fallback();
      }
    });

    const blocklist = await openBlocklistTab(page);

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
  });

  test("should request and render the second page using item offset", async ({
    page,
  }) => {
    let secondPageRequestUrl = "";
    const secondPageOffset = String(RESULTS_PER_PAGE);

    await page.route("**/blocklist/batch?**", async (route) => {
      const requestUrl = new URL(route.request().url());
      const offset = requestUrl.searchParams.get("offset");

      if (offset === secondPageOffset) {
        secondPageRequestUrl = route.request().url();
      }

      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({
          data:
            offset === secondPageOffset
              ? [makeBlocklistJob("blkbatch_11")]
              : makeBlocklistJobs(RESULTS_PER_PAGE),
          total_count: RESULTS_PER_PAGE + 1,
        }),
      });
    });

    await openBlocklistTab(page);
    await expect(page.getByText("blkbatch_01")).toBeVisible();

    await page.getByRole("button", { name: "2", exact: true }).click();

    await expect(page.getByText("blkbatch_11")).toBeVisible();
    expect(secondPageRequestUrl).toContain(`limit=${RESULTS_PER_PAGE}`);
    expect(secondPageRequestUrl).toContain(`offset=${secondPageOffset}`);
  });

  test("should show upload error when CSV upload fails", async ({ page }) => {
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    await page.route("**/blocklist/batch", async (route) => {
      if (route.request().method() === "POST") {
        await route.fulfill({
          status: 500,
          contentType: "application/json",
          body: JSON.stringify({ error: { message: "Upload failed" } }),
        });
      } else {
        await route.fallback();
      }
    });

    const blocklist = await openBlocklistTab(page);

    await blocklist.fileInput.setInputFiles({
      name: "blocklist.csv",
      mimeType: "text/csv",
      buffer: Buffer.from("type,data,metadata\ncard_bin,411111,"),
    });
    await blocklist.uploadButton.click();

    await expect(blocklist.toast("Upload failed")).toHaveCount(1);
    await expect(blocklist.toast("Upload failed")).toBeVisible();
  });

  test("should reject CSV files with unsupported MIME type", async ({
    page,
  }) => {
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const blocklist = await openBlocklistTab(page);

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
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const blocklist = await openBlocklistTab(page);

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
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const blocklist = await openBlocklistTab(page);

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
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const blocklist = await openBlocklistTab(page);

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

  test("should accept a CSV file with exactly 100,000 rows", async ({
    page,
  }) => {
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const blocklist = await openBlocklistTab(page);

    await blocklist.fileInput.setInputFiles({
      name: "blocklist.csv",
      mimeType: "text/csv",
      buffer: Buffer.from(makeBlocklistCsvWithDataRows(100_000)),
    });

    await expect(blocklist.uploadButton).toBeVisible();
  });

  test("should reject a CSV file with 100,001 rows", async ({ page }) => {
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const blocklist = await openBlocklistTab(page);

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

test.describe("Blocklist feature flag", () => {
  test("should hide the blocklist content when feature flag is off", async ({
    page,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await setBlocklistFeatureFlag(page, false);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const blocklist = new Blocklist(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();
    await expect(page).toHaveURL(/.*dashboard\/payment-settings/);

    await expect(blocklist.tab).toBeVisible();
    await blocklist.tab.click();

    await expect(
      page.getByText("Payment Method Blocking", { exact: true }),
    ).toBeVisible();
    await expect(blocklist.pageHeading).toBeHidden();
    await expect(blocklist.uploadCsvHeading).toBeHidden();
  });
});

test.describe("Blocklist with payout blocklist enabled", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await setBlocklistFeatureFlag(page, true, true);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should show Payment and Payout tabs with Payment selected by default", async ({
    page,
  }) => {
    const calls = await mockBlocklistApis(page);
    const blocklist = await openBlocklistTab(page);

    await expect(blocklist.pageHeading).toBeVisible();
    await expect(blocklist.sectionDescription).toBeVisible();
    await expect(blocklist.transactionTab("Payment")).toBeVisible();
    await expect(blocklist.transactionTab("Payout")).toBeVisible();
    await expect(blocklist.transactionTab("Payment")).toHaveAttribute(
      "aria-selected",
      "true",
    );

    await expect(blocklist.addEntryStepDescription).toHaveText(
      "Blocks a single card BIN or fingerprint in the payment blocklist. To add many at once, use Bulk upload below.",
    );
    await expect(blocklist.exportStepDescription).toHaveText(
      "Download this profile's payment blocklist.",
    );
    await expect(blocklist.countCard("6-digit BINs")).toContainText("12");
    await expect(blocklist.countCard("8-digit BINs")).toContainText("3");
    await expect(blocklist.countCard("Fingerprints")).toContainText("4");

    expect(calls.counts.length).toBeGreaterThan(0);
    for (const url of calls.counts) {
      expect(url.searchParams.get("transaction_type")).toBe("payment");
    }
  });

  test("should switch to Payout tab and load payout counts and copy", async ({
    page,
  }) => {
    const calls = await mockBlocklistApis(page);
    const blocklist = await openBlocklistTab(page);
    await expect(blocklist.countCard("6-digit BINs")).toContainText("12");

    const payoutCountResponse = page.waitForResponse((response) => {
      const url = new URL(response.url());
      return (
        url.pathname.endsWith("/blocklist/count") &&
        url.searchParams.get("transaction_type") === "payout"
      );
    });
    await blocklist.transactionTab("Payout").click();
    await payoutCountResponse;

    await expect(blocklist.transactionTab("Payout")).toHaveAttribute(
      "aria-selected",
      "true",
    );
    await expect(blocklist.addEntryStepDescription).toHaveText(
      "Blocks a single card BIN or fingerprint in the payout blocklist. To add many at once, use Bulk upload below.",
    );
    await expect(blocklist.exportStepDescription).toHaveText(
      "Download this profile's payout blocklist.",
    );
    await expect(blocklist.exportCardDescription).toHaveText(
      "Generates a CSV of every payout entry on this profile. Download it from Background jobs once it completes.",
    );
    await expect(blocklist.countCard("6-digit BINs")).toContainText("2");
    await expect(blocklist.countCard("8-digit BINs")).toBeHidden();
    await expect(blocklist.countCard("Fingerprints")).toContainText("1");

    const payoutCounts = calls.counts.filter(
      (url) => url.searchParams.get("transaction_type") === "payout",
    );
    expect(
      payoutCounts.map((url) => url.searchParams.get("data_kind")).sort(),
    ).toEqual(["generic_card_bin", "payment_method"]);
  });

  test("should keep bulk upload, clone and background jobs shared outside the tabs", async ({
    page,
  }) => {
    await mockBlocklistApis(page);
    const blocklist = await openBlocklistTab(page);

    for (const tab of ["Payment", "Payout"] as const) {
      await blocklist.transactionTab(tab).click();
      await expect(blocklist.bulkUploadHeading).toHaveCount(1);
      await expect(blocklist.bulkUploadSharedNote).toBeVisible();
      await expect(blocklist.uploadCsvDescription).toBeVisible();
      await expect(blocklist.chooseFileButton).toHaveCount(1);
      await expect(blocklist.cloneBlocklistButton).toHaveCount(1);
      await expect(blocklist.backgroundJobsHeading).toBeVisible();
      await expect(blocklist.noBackgroundJobsText).toBeVisible();
    }
  });

  for (const transactionType of ["payment", "payout"] as const) {
    const tabName = transactionType === "payment" ? "Payment" : "Payout";

    test(`should block a card BIN with transaction_type=${transactionType}`, async ({
      page,
    }) => {
      const calls = await mockBlocklistApis(page);
      const blocklist = await openBlocklistTab(page);
      await blocklist.transactionTab(tabName).click();

      await blocklist.addEntryInput.fill("411111");
      await blocklist.blockButton.click();

      await expect(
        blocklist.successToast("Added 411111 to blocklist."),
      ).toBeVisible();
      await expect(blocklist.addEntryInput).toHaveValue("");
      expect(calls.entries).toEqual([
        {
          method: "POST",
          body: {
            type: "generic_card_bin",
            data: "411111",
            transaction_type: transactionType,
          },
        },
      ]);
    });

    test(`should unblock a fingerprint with transaction_type=${transactionType}`, async ({
      page,
    }) => {
      const calls = await mockBlocklistApis(page);
      const blocklist = await openBlocklistTab(page);
      await blocklist.transactionTab(tabName).click();

      await blocklist.unblockTab.click();
      await selectEntryType(
        blocklist,
        blocklist.unblockEntryPanel,
        "Fingerprint",
      );
      await blocklist.unblockEntryInput.fill("fp_abc123");
      await blocklist.unblockButton.click();

      await expect(
        blocklist.successToast("Removed fp_abc123 from blocklist."),
      ).toBeVisible();
      expect(calls.entries).toEqual([
        {
          method: "DELETE",
          body: {
            type: "fingerprint",
            data: "fp_abc123",
            transaction_type: transactionType,
          },
        },
      ]);
    });

    test(`should look up an entry with transaction_type=${transactionType}`, async ({
      page,
    }) => {
      const calls = await mockBlocklistApis(page);
      const blocklist = await openBlocklistTab(page);
      await blocklist.transactionTab(tabName).click();

      await blocklist.checkTab.click();
      await blocklist.lookupInput.fill("411111");
      await blocklist.checkButton.click();

      await expect(page.getByText("Blocked", { exact: true })).toBeVisible();
      expect(calls.lookups).toHaveLength(1);
      expect(calls.lookups[0].searchParams.get("data")).toBe("411111");
      expect(calls.lookups[0].searchParams.get("transaction_type")).toBe(
        transactionType,
      );
    });

    test(`should generate an export with transaction_type=${transactionType}`, async ({
      page,
    }) => {
      const calls = await mockBlocklistApis(page);
      const blocklist = await openBlocklistTab(page);
      await blocklist.transactionTab(tabName).click();

      await blocklist.generateExportButton.click();

      await expect(
        blocklist.successToast(
          "Blocklist export started. File: blocklist_export.csv",
        ),
      ).toBeVisible();
      expect(calls.exports).toHaveLength(1);
      expect(calls.exports[0].searchParams.get("transaction_type")).toBe(
        transactionType,
      );
    });
  }

  test("should show Not blocked and clear the result when the lookup value changes", async ({
    page,
  }) => {
    await mockBlocklistApis(page, { lookupBlocked: false });
    const blocklist = await openBlocklistTab(page);
    await blocklist.transactionTab("Payout").click();

    await blocklist.checkTab.click();
    await expect(blocklist.checkButton).toBeDisabled();
    await blocklist.lookupInput.fill("fp_abc123");
    await blocklist.checkButton.click();

    const notBlocked = page.getByText("Not blocked", { exact: true });
    await expect(notBlocked).toBeVisible();

    await blocklist.lookupInput.fill("fp_abc1234");
    await expect(notBlocked).toBeHidden();
  });

  test("should validate card BIN input before blocking", async ({ page }) => {
    const calls = await mockBlocklistApis(page);
    const blocklist = await openBlocklistTab(page);
    await blocklist.transactionTab("Payout").click();

    await expect(blocklist.blockButton).toBeDisabled();
    await expect(
      page.getByText("Must be 6 to 10 digits, e.g. 411111"),
    ).toBeVisible();

    await blocklist.addEntryInput.pressSequentially("41ab");
    await expect(blocklist.addEntryInput).toHaveValue("41");

    await blocklist.blockButton.click();
    await expect(
      page.getByText("Card BIN must be 6 to 10 digits."),
    ).toBeVisible();
    expect(calls.entries).toHaveLength(0);

    await selectEntryType(blocklist, blocklist.addEntryPanel, "Fingerprint");
    await expect(page.getByText("e.g. fp_abc123")).toBeVisible();
    await expect(
      page.getByText("Card BIN must be 6 to 10 digits."),
    ).toBeHidden();
  });

  test("should surface API errors when blocking a payout entry fails", async ({
    page,
  }) => {
    await mockBlocklistApis(page);
    await page.route("**/blocklist", async (route) => {
      await route.fulfill({
        status: 400,
        contentType: "application/json",
        body: JSON.stringify({
          error: { message: "Entry already exists in the payout blocklist" },
        }),
      });
    });
    const blocklist = await openBlocklistTab(page);
    await blocklist.transactionTab("Payout").click();

    await blocklist.addEntryInput.fill("411111");
    await blocklist.blockButton.click();

    await expect(
      blocklist.toast("Entry already exists in the payout blocklist"),
    ).toBeVisible();
    await expect(blocklist.addEntryInput).toHaveValue("411111");
  });

  test("should show a fallback when counts fail to load", async ({ page }) => {
    await mockBlocklistApis(page);
    await page.route("**/blocklist/count?**", async (route) => {
      await route.fulfill({
        status: 500,
        contentType: "application/json",
        body: JSON.stringify({ error: { message: "boom" } }),
      });
    });
    const blocklist = await openBlocklistTab(page);
    await blocklist.transactionTab("Payout").click();

    await expect(blocklist.countsLoadError.first()).toBeVisible();
  });

  test("should open and close the clone blocklist modal", async ({ page }) => {
    await mockBlocklistApis(page);
    const blocklist = await openBlocklistTab(page);

    await expect(
      page.getByText(
        "Apply this profile's payment and payout blocklists to other profiles. Entries already on those profiles are kept.",
      ),
    ).toBeVisible();
    await blocklist.cloneBlocklistButton.click();
    await expect(blocklist.cloneModalHeading).toBeVisible();
    await expect(page.getByText("Source profile")).toBeVisible();
    await expect(page.getByText("Target profiles")).toBeVisible();

    await page.getByRole("button", { name: "Cancel" }).click();
    await expect(blocklist.cloneModalHeading).toBeHidden();
  });
});

test.describe("Blocklist with payout blocklist disabled", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await setBlocklistFeatureFlag(page, true, false);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should render only the payment blocklist without transaction tabs", async ({
    page,
  }) => {
    const calls = await mockBlocklistApis(page);
    const blocklist = await openBlocklistTab(page);

    await expect(blocklist.pageHeading).toBeVisible();
    await expect(blocklist.transactionTab("Payment")).toBeHidden();
    await expect(blocklist.transactionTab("Payout")).toBeHidden();
    await expect(blocklist.addEntryStepDescription).toHaveText(
      "Blocks a single card BIN or fingerprint in the payment blocklist. To add many at once, use Bulk upload below.",
    );
    await expect(blocklist.exportStepDescription).toHaveText(
      "Download this profile's payment blocklist.",
    );
    await expect(blocklist.countCard("6-digit BINs")).toContainText("12");
    await expect(blocklist.bulkUploadHeading).toBeVisible();
    await expect(blocklist.cloneBlocklistButton).toBeVisible();

    for (const url of calls.counts) {
      expect(url.searchParams.get("transaction_type")).toBe("payment");
    }
  });

  test("should send transaction_type=payment for block and export", async ({
    page,
  }) => {
    const calls = await mockBlocklistApis(page);
    const blocklist = await openBlocklistTab(page);

    await blocklist.addEntryInput.fill("4111111100");
    await blocklist.blockButton.click();
    await expect(
      blocklist.successToast("Added 4111111100 to blocklist."),
    ).toBeVisible();

    await blocklist.generateExportButton.click();
    await expect(
      blocklist.successToast(
        "Blocklist export started. File: blocklist_export.csv",
      ),
    ).toBeVisible();

    expect(calls.entries[0].body.transaction_type).toBe("payment");
    expect(calls.exports[0].searchParams.get("transaction_type")).toBe(
      "payment",
    );
  });
});
