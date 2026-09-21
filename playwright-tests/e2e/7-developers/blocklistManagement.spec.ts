import { test, expect } from "../../support/test";
import type { Page, Route } from "@playwright/test";
import { signupUser, loginUI } from "../../support/commands";
import { generateUniqueEmail } from "../../support/helper";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { Blocklist } from "../../support/pages/developers/Blocklist";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

let blocklist: Blocklist;
let calls: BlocklistCalls;

type BatchJob = {
  job_id: string;
  job_type: "upload" | "export";
  status: string;
  total_rows?: number;
  succeeded_rows?: number;
  failed_rows?: number;
  downloadable?: boolean;
};

const makeJob = (job: BatchJob) => ({
  job_id: job.job_id,
  merchant_id: "merchant_test",
  job_type: job.job_type,
  status: job.status,
  total_rows: job.total_rows ?? 3,
  succeeded_rows: job.succeeded_rows ?? 3,
  failed_rows: job.failed_rows ?? 0,
  downloadable: job.downloadable ?? false,
  created_at: "2026-09-15T06:08:47.617Z",
  updated_at: "2026-09-15T06:08:47.617Z",
});

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
  jobsAfterAction?: ReturnType<typeof makeJob>[];
  refreshedJob?: ReturnType<typeof makeJob>;
  downloadUrl?: string;
};

type BlocklistCalls = {
  countUrls: string[];
  lookupUrls: string[];
  entryMethods: string[];
  entryBodies: Record<string, unknown>[];
  exportCount: number;
  listCount: number;
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
    refreshedJob,
    downloadUrl = "https://example.com/blocklist_export.csv",
  } = mocks;

  const apiCalls: BlocklistCalls = {
    countUrls: [],
    lookupUrls: [],
    entryMethods: [],
    entryBodies: [],
    exportCount: 0,
    listCount: 0,
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

    // GET /blocklist/batch/{jobId} — single job refresh / export download
    if (path.includes("/blocklist/batch/") && method === "GET") {
      return json(200, {
        ...(refreshedJob ??
          makeJob({
            job_id: "blkjob_01",
            job_type: "upload",
            status: "completed",
          })),
        download_url: downloadUrl,
      });
    }

    // GET /blocklist/batch?limit&offset — jobs list
    if (path.endsWith("/blocklist/batch") && method === "GET") {
      apiCalls.listCount += 1;
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
 * Installs the given blocklist API mocks, signs a fresh merchant in and opens
 * the Block List tab. Declared as a helper so each describe can apply its own
 * mock configuration from `beforeEach` without repeating setup in the tests.
 */
const useBlocklistTab = (mocks: BlocklistMocks = {}) => {
  test.beforeEach(async ({ page }) => {
    await setBlocklistFeatureFlag(page, true);
    calls = await mockBlocklistApis(page, mocks);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    blocklist = new Blocklist(page);

    await homePage.developer.click();
    await homePage.paymentSettings.click();
    await expect(page).toHaveURL(/.*dashboard\/payment-settings/);

    await expect(blocklist.tab).toBeVisible();
    await blocklist.tab.click();
    await expect(blocklist.pageHeading).toBeVisible();
  });
};

test.describe("Blocklist management UI", () => {
  test.describe("Count summary", () => {
    test.describe("with a per-length breakdown", () => {
      useBlocklistTab({
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
      useBlocklistTab({ cardBinCounts: {}, cardBinTotal: 42 });

      test("should fall back to a single Card BINs card when no length breakdown is returned", async ({
        page,
      }) => {
        await expect(blocklist.cardBinsCountCard).toBeVisible();
        await expect(page.getByText("42", { exact: true })).toBeVisible();
        await expect(blocklist.binLengthCountCard(6)).toBeHidden();
      });
    });

    test.describe("when the count request fails", () => {
      useBlocklistTab({ countStatus: 500 });

      test("should show a failure message when counts cannot be loaded", async () => {
        await expect(blocklist.countLoadFailureMessage).toBeVisible();
      });
    });
  });

  test.describe("Check Blocklist lookup", () => {
    test.describe("for a blocked value", () => {
      useBlocklistTab({ lookupBlocked: true });

      test("should report a blocked value from the lookup card", async () => {
        await expect(blocklist.lookupHeading).toBeVisible();
        await expect(blocklist.lookupDescription).toBeVisible();
        await expect(blocklist.lookupHint).toBeVisible();

        await blocklist.lookupInput.fill("411111");
        await blocklist.lookupCheckButton.click();

        await expect(blocklist.lookupBlockedTag).toBeVisible();
        expect(calls.lookupUrls[0]).toContain("data=411111");
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
      useBlocklistTab({ lookupBlocked: false });

      test("should report a value that is not blocked", async () => {
        await blocklist.lookupInput.fill("fp_abc123");
        await blocklist.lookupCheckButton.click();

        await expect(blocklist.lookupNotBlockedTag).toBeVisible();
      });
    });

    test.describe("when the lookup request fails", () => {
      useBlocklistTab({ lookupStatus: 500 });

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
      useBlocklistTab();

      test("should add a single card BIN to the blocklist", async () => {
        await blocklist.addEntryDataInput.fill("411111");
        await blocklist.addEntryButton.click();

        await expect(
          blocklist.toast("Added fp_generated_001 to blocklist."),
        ).toBeVisible();
        expect(calls.entryMethods).toContain("POST");
        expect(calls.entryBodies[0]).toEqual({
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
        expect(calls.entryMethods).toContain("DELETE");
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
        expect(calls.entryMethods).toHaveLength(0);
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
        expect(calls.entryBodies[0]).toEqual({
          type: "fingerprint",
          data: "fp_abc123",
        });
      });
    });

    test.describe("when the entry request fails", () => {
      useBlocklistTab({ entryStatus: 400 });

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
      useBlocklistTab({
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
        expect(calls.exportCount).toBe(1);

        await expect(
          page.getByText("blkexp_01", { exact: true }),
        ).toBeVisible();
      });
    });

    test.describe("when the export request fails", () => {
      useBlocklistTab({ exportStatus: 500 });

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
      useBlocklistTab({
        jobs: [
          makeJob({
            job_id: "blkexp_done",
            job_type: "export",
            status: "completed",
            downloadable: true,
          }),
          makeJob({
            job_id: "blkjob_running",
            job_type: "upload",
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
      useBlocklistTab({
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
        await expect(blocklist.downloadExportAction.locator("svg")).toHaveClass(
          /cursor-not-allowed/,
        );
      });
    });

    test.describe("with a refreshable upload job", () => {
      useBlocklistTab({
        jobs: [
          makeJob({
            job_id: "blkjob_01",
            job_type: "upload",
            status: "processing",
            succeeded_rows: 1,
          }),
        ],
        refreshedJob: makeJob({
          job_id: "blkjob_01",
          job_type: "upload",
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
    test.beforeEach(async ({ page }) => {
      await setBlocklistFeatureFlag(page, false);
      await mockBlocklistApis(page);

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      const homePage = new HomePage(page);
      blocklist = new Blocklist(page);

      await homePage.developer.click();
      await homePage.paymentSettings.click();
      await blocklist.tab.click();
    });

    test("should hide every blocklist management card when the flag is off", async ({
      page,
    }) => {
      // Payment Method Blocking stays; the blocklist tooling is hidden.
      await expect(
        page.getByText("Payment Method Blocking", { exact: true }),
      ).toBeVisible();
      await expect(blocklist.lookupHeading).toBeHidden();
      await expect(blocklist.generateExportHeading).toBeHidden();
      await expect(blocklist.addEntryButton).toBeHidden();
      await expect(blocklist.uploadCsvHeading).toBeHidden();
    });
  });
});
