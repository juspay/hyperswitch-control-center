import { test, expect } from "../../support/test";
import { Page } from "@playwright/test";
import { signupUser, loginUI } from "../../support/commands";
import { generateUniqueEmail } from "../../support/helper";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { Blocklist } from "../../support/pages/developers/Blocklist";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

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

test.describe("Blocklist", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await setBlocklistFeatureFlag(page, true);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should navigate to Blocklist page via sidebar and show upload UI", async ({ page }) => {
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const homePage = new HomePage(page);
    const blocklist = new Blocklist(page);

    await homePage.developer.click();
    await expect(homePage.blocklist).toBeVisible();
    await homePage.blocklist.click();

    await expect(page).toHaveURL(/.*dashboard\/blocklist/);
    await expect(blocklist.pageHeading).toBeVisible();
    await expect(blocklist.uploadCsvHeading).toBeVisible();
    await expect(blocklist.uploadFileText).toBeVisible();
    await expect(blocklist.supportedFileText).toBeVisible();
    await expect(blocklist.downloadSampleFileButton).toBeVisible();
    await expect(blocklist.chooseFileButton).toHaveCount(1);
    await expect(blocklist.chooseFileButton).toBeVisible();
    await expect(blocklist.emptyState).toBeVisible();
    await expect(page.getByText("CSV sample format")).toBeHidden();
    await expect(page.getByText("type,data,metadata")).toBeHidden();
  });

  test("should download sample CSV file from frontend content", async ({ page }) => {
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const homePage = new HomePage(page);
    const blocklist = new Blocklist(page);

    await homePage.developer.click();
    await homePage.blocklist.click();

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
      "type,data,metadata\ncard_bin,411111,source=fraud_team;reason=chargeback\nextended_card_bin,41111100,\nfingerprint,fp_abc123,",
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
                    job_id: "blkbatch_test",
                    merchant_id: "merchant_test",
                    status: "initiated",
                    total_rows: 3,
                    succeeded_rows: 0,
                    failed_rows: 0,
                    created_at: "2026-05-06T06:08:47.617Z",
                    updated_at: "2026-05-06T06:08:47.617Z",
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
          status: 202,
          contentType: "application/json",
          body: JSON.stringify({
            job_id: "blkbatch_test",
            total_rows: 3,
            status: "initiated",
          }),
        });
      } else {
        await route.fallback();
      }
    });

    const homePage = new HomePage(page);
    const blocklist = new Blocklist(page);

    await homePage.developer.click();
    await homePage.blocklist.click();

    await blocklist.fileInput.setInputFiles({
      name: "blocklist.csv",
      mimeType: "text/csv",
      buffer: Buffer.from(
        "type,data,metadata\ncard_bin,411111,source=fraud_team\nfingerprint,fp_abc123,",
      ),
    });
    await blocklist.uploadButton.click();

    await expect(page.getByText("Blocklist CSV uploaded. Job ID: blkbatch_test")).toBeVisible();
    await expect(page.getByText("blkbatch_test")).toBeVisible();
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

    const homePage = new HomePage(page);
    const blocklist = new Blocklist(page);

    await homePage.developer.click();
    await homePage.blocklist.click();

    await blocklist.fileInput.setInputFiles({
      name: "blocklist.csv",
      mimeType: "text/csv",
      buffer: Buffer.from("type,data,metadata\ncard_bin,411111,"),
    });
    await blocklist.uploadButton.click();

    await expect(blocklist.toast("Upload failed")).toHaveCount(1);
    await expect(blocklist.toast("Upload failed")).toBeVisible();
  });

  test("should reject CSV files with unsupported MIME type", async ({ page }) => {
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const homePage = new HomePage(page);
    const blocklist = new Blocklist(page);

    await homePage.developer.click();
    await homePage.blocklist.click();

    await blocklist.fileInput.setInputFiles({
      name: "blocklist.csv",
      mimeType: "application/json",
      buffer: Buffer.from("type,data,metadata\ncard_bin,411111,"),
    });

    await expect(page.getByText("Please upload a valid CSV file.")).toBeVisible();
  });

  test("should reject CSV files larger than 5 MB", async ({ page }) => {
    await page.route("**/blocklist/batch?**", async (route) => {
      await route.fulfill({
        status: 200,
        contentType: "application/json",
        body: JSON.stringify({ data: [], total_count: 0 }),
      });
    });

    const homePage = new HomePage(page);
    const blocklist = new Blocklist(page);

    await homePage.developer.click();
    await homePage.blocklist.click();

    await blocklist.fileInput.setInputFiles({
      name: "blocklist.csv",
      mimeType: "text/csv",
      buffer: Buffer.alloc(5 * 1024 * 1024 + 1, "a"),
    });

    await expect(page.getByText("CSV file size should be less than 5 MB.")).toBeVisible();
  });
});

test.describe("Blocklist feature flag", () => {
  test("should hide sidebar link and block direct route when feature flag is off", async ({
    page,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await setBlocklistFeatureFlag(page, false);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const blocklist = new Blocklist(page);

    await homePage.developer.click();
    await expect(homePage.blocklist).toBeHidden();

    await page.goto("/dashboard/blocklist");
    await expect(blocklist.pageHeading).toBeHidden();
  });
});
