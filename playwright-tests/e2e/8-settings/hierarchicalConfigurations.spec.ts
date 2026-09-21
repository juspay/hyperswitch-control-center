import { test, expect } from "../../support/test";
import type { Page, Route } from "@playwright/test";
import { signupUser, loginUI } from "../../support/commands";
import { generateUniqueEmail } from "../../support/helper";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { HierarchicalConfigurationsPage } from "../../support/pages/settings/HierarchicalConfigurationsPage";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

const RESOURCE_TYPE = "apple_pay_certificate";
const SAMPLE_CSR =
  "-----BEGIN CERTIFICATE REQUEST-----\nMIIBotest\n-----END CERTIFICATE REQUEST-----";

let certificates: HierarchicalConfigurationsPage;
let calls: ResourceApiCalls;

type ResourceOverrides = {
  id?: string;
  merchantIdentifier?: string | null;
  createdAt?: string;
  isLinked?: boolean;
};

const makeResource = (overrides: ResourceOverrides = {}) => {
  const {
    id = "res_apple_pay_001",
    merchantIdentifier = "merchant.com.playwright.test",
    createdAt = "2026-09-15T10:12:00.000Z",
    isLinked = false,
  } = overrides;

  return {
    id,
    display_schema: { apple_pay_merchant_identifier: { type: "string" } },
    display_data:
      merchantIdentifier === null
        ? {}
        : { apple_pay_merchant_identifier: merchantIdentifier },
    created_at: createdAt,
    is_linked: isLinked,
  };
};

type ResourceApiMocks = {
  /** Resources returned by POST /hierarchical_resources/list */
  resources?: ReturnType<typeof makeResource>[];
  /** Resources returned on every list call after the first one. */
  resourcesAfterUpload?: ReturnType<typeof makeResource>[];
  listStatus?: number;
  generateStatus?: number;
  uploadStatus?: number;
  csr?: string;
};

type ResourceApiCalls = {
  listCount: number;
  generateCount: number;
  uploadCount: number;
  uploadBodies: Record<string, unknown>[];
  uploadUrls: string[];
};

const setHierarchicalConfigFeatureFlag = async (
  page: Page,
  enabled: boolean,
) => {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    if (json && json.features) {
      json.features.hierarchical_configurations = enabled;
    }
    await route.fulfill({ response, json });
  });
};

/**
 * One route handler for every hierarchical_resources endpoint. Registering a
 * single glob keeps the list / generate / upload calls unambiguous — Playwright
 * matches handlers in reverse registration order, so overlapping globs would
 * make which handler wins depend on registration order.
 */
const mockResourceApis = async (
  page: Page,
  mocks: ResourceApiMocks = {},
): Promise<ResourceApiCalls> => {
  const {
    resources = [],
    resourcesAfterUpload,
    listStatus = 200,
    generateStatus = 200,
    uploadStatus = 200,
    csr = SAMPLE_CSR,
  } = mocks;

  const apiCalls: ResourceApiCalls = {
    listCount: 0,
    generateCount: 0,
    uploadCount: 0,
    uploadBodies: [],
    uploadUrls: [],
  };

  await page.route("**/hierarchical_resources**", async (route: Route) => {
    const request = route.request();
    const method = request.method();
    const path = new URL(request.url()).pathname;

    const json = (status: number, body: unknown) =>
      route.fulfill({
        status,
        contentType: "application/json",
        body: JSON.stringify(body),
      });

    // POST /hierarchical_resources/list
    if (method === "POST" && path.endsWith("/hierarchical_resources/list")) {
      apiCalls.listCount += 1;
      if (listStatus !== 200) {
        return json(listStatus, {
          error: { message: "Unable to list resources" },
        });
      }
      const payload =
        apiCalls.listCount > 1 && resourcesAfterUpload
          ? resourcesAfterUpload
          : resources;
      return json(200, { resources: payload });
    }

    // POST /hierarchical_resources -> generate CSR
    if (method === "POST" && path.endsWith("/hierarchical_resources")) {
      apiCalls.generateCount += 1;
      if (generateStatus !== 200) {
        return json(generateStatus, {
          error: { message: "certificate authority unavailable" },
        });
      }
      return json(200, {
        id: "res_apple_pay_001",
        data: { [RESOURCE_TYPE]: { csr } },
      });
    }

    // PUT /hierarchical_resources/apple_pay_certificate/{id} -> upload
    if (method === "PUT") {
      apiCalls.uploadCount += 1;
      apiCalls.uploadUrls.push(request.url());
      apiCalls.uploadBodies.push(request.postDataJSON());
      if (uploadStatus !== 200) {
        return json(uploadStatus, {
          error: { message: "certificate does not match the request" },
        });
      }
      return json(200, { id: "res_apple_pay_001", status: "linked" });
    }

    return route.fallback();
  });

  return apiCalls;
};

const readDownload = async (download: {
  createReadStream: () => Promise<NodeJS.ReadableStream>;
}) => {
  const stream = await download.createReadStream();
  const chunks: Buffer[] = [];
  for await (const chunk of stream) {
    chunks.push(Buffer.isBuffer(chunk) ? chunk : Buffer.from(chunk));
  }
  return Buffer.concat(chunks).toString();
};

/**
 * Installs the given resource API mocks, signs a fresh merchant in and opens
 * the Certificate Management page. Declared as a helper so each describe can
 * apply its own mock configuration from `beforeEach` without repeating setup
 * inside the tests.
 */
const useCertificatesPage = (mocks: ResourceApiMocks = {}) => {
  test.beforeEach(async ({ page }) => {
    await setHierarchicalConfigFeatureFlag(page, true);
    calls = await mockResourceApis(page, mocks);

    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    certificates = new HierarchicalConfigurationsPage(page);

    await homePage.settings.click();
    await expect(certificates.sidebarLink).toBeVisible();
    await certificates.sidebarLink.click();
    await expect(page).toHaveURL(/.*dashboard\/hierarchical-configurations/);
  });
};

/** Opens the modal and completes step 1, leaving the upload step showing. */
const openUploadStep = async (page: Page) => {
  await certificates.addCertificateButton.click();
  await Promise.all([
    page.waitForEvent("download"),
    certificates.downloadFileButton.click(),
  ]);
  await certificates.continueButton.click();
  await expect(certificates.stepTwoSubHeading).toBeVisible();
};

test.describe("Certificate Management (Hierarchical Configurations)", () => {
  test.describe("Certificate list", () => {
    test.describe("with no certificates", () => {
      useCertificatesPage({ resources: [] });

      test("should show the page heading, add button and empty state when no certificates exist", async () => {
        await expect(certificates.pageHeading).toBeVisible();
        await expect(certificates.pageSubHeading).toBeVisible();
        await expect(certificates.addCertificateButton).toBeVisible();
        await expect(certificates.emptyStateMessage).toBeVisible();
      });
    });

    test.describe("with existing certificates", () => {
      useCertificatesPage({
        resources: [
          makeResource({
            id: "res_apple_pay_001",
            merchantIdentifier: "merchant.com.playwright.one",
          }),
          makeResource({
            id: "res_apple_pay_002",
            merchantIdentifier: "merchant.com.playwright.two",
          }),
        ],
      });

      test("should list existing certificates with resource ID, merchant identifier and created date", async ({
        page,
      }) => {
        await expect(certificates.resourceIdColumn).toBeVisible();
        await expect(certificates.merchantIdentifierColumn).toBeVisible();
        await expect(certificates.createdColumn).toBeVisible();

        await expect(page.getByText("res_apple_pay_001")).toBeVisible();
        await expect(
          page.getByText("merchant.com.playwright.one"),
        ).toBeVisible();
        await expect(page.getByText("res_apple_pay_002")).toBeVisible();
        await expect(
          page.getByText("merchant.com.playwright.two"),
        ).toBeVisible();
        await expect(certificates.emptyStateMessage).toBeHidden();
      });
    });

    test.describe("with a certificate missing its merchant identifier", () => {
      useCertificatesPage({
        resources: [
          makeResource({
            id: "res_apple_pay_no_identifier",
            merchantIdentifier: null,
          }),
        ],
      });

      test("should render a dash when a certificate has no merchant identifier", async ({
        page,
      }) => {
        await expect(
          page.getByText("res_apple_pay_no_identifier"),
        ).toBeVisible();
        await expect(
          page.getByText("-", { exact: true }).first(),
        ).toBeVisible();
      });
    });

    test.describe("when the list request fails", () => {
      useCertificatesPage({ listStatus: 500 });

      test("should show an error screen when the certificate list fails to load", async ({
        page,
      }) => {
        // The page swaps to the shared error screen rather than an empty table.
        await expect(
          page.getByText("Oops, we hit a little bump on the road!"),
        ).toBeVisible();
        await expect(
          page.getByRole("button", { name: "Refresh" }),
        ).toBeVisible();
        await expect(certificates.emptyStateMessage).toBeHidden();
      });
    });
  });

  test.describe("Add certificate modal", () => {
    test.describe("happy path", () => {
      useCertificatesPage({
        resources: [],
        resourcesAfterUpload: [
          makeResource({
            id: "res_apple_pay_001",
            merchantIdentifier: "merchant.com.playwright.new",
          }),
        ],
      });

      test("should download the CSR file on step 1 and enable Continue", async ({
        page,
      }) => {
        await certificates.addCertificateButton.click();

        await expect(certificates.modalHeading).toBeVisible();
        await expect(certificates.stepOneSubHeading).toBeVisible();
        await expect(certificates.continueButton).toBeDisabled();

        const [download] = await Promise.all([
          page.waitForEvent("download"),
          certificates.downloadFileButton.click(),
        ]);

        expect(download.suggestedFilename()).toBe("apple_pay.csr");
        expect(await readDownload(download)).toBe(SAMPLE_CSR);
        expect(calls.generateCount).toBe(1);

        await expect(certificates.continueButton).toBeEnabled();
      });

      test("should upload a signed certificate and refresh the list", async ({
        page,
      }) => {
        await openUploadStep(page);

        await expect(certificates.chooseFileButton).toBeVisible();
        await expect(certificates.submitButton).toBeDisabled();

        await certificates.certificateFileInput.setInputFiles({
          name: "apple_pay.cer",
          mimeType: "application/x-x509-ca-cert",
          buffer: Buffer.from("signed-apple-pay-certificate"),
        });

        await expect(
          certificates.selectedFileName("apple_pay.cer"),
        ).toBeVisible();
        await expect(certificates.submitButton).toBeEnabled();

        await certificates.submitButton.click();

        await expect(
          certificates.toast("Certificate uploaded successfully"),
        ).toBeVisible();

        // The modal closes and the list is refetched with the new certificate.
        await expect(certificates.modalHeading).toBeHidden();
        await expect(
          page.getByText("merchant.com.playwright.new"),
        ).toBeVisible();

        expect(calls.uploadCount).toBe(1);
        expect(calls.uploadUrls[0]).toContain(
          `/hierarchical_resources/${RESOURCE_TYPE}/res_apple_pay_001`,
        );
        // The file is sent base64 encoded, without the data-URL prefix.
        expect(calls.uploadBodies[0]).toEqual({
          certificate: Buffer.from("signed-apple-pay-certificate").toString(
            "base64",
          ),
        });
        expect(calls.listCount).toBeGreaterThan(1);
      });

      test("should re-download the same CSR without generating a second request", async ({
        page,
      }) => {
        await certificates.addCertificateButton.click();

        const [firstDownload] = await Promise.all([
          page.waitForEvent("download"),
          certificates.downloadFileButton.click(),
        ]);
        const [secondDownload] = await Promise.all([
          page.waitForEvent("download"),
          certificates.downloadFileButton.click(),
        ]);

        expect(await readDownload(firstDownload)).toBe(SAMPLE_CSR);
        expect(await readDownload(secondDownload)).toBe(SAMPLE_CSR);
        // A CSR is bound to one resource; clicking again must reuse it.
        expect(calls.generateCount).toBe(1);
      });

      test("should reset the modal back to step 1 after closing and reopening it", async ({
        page,
      }) => {
        await openUploadStep(page);

        // Close by clicking outside the modal, then reopen.
        await page.keyboard.press("Escape");
        await page.mouse.click(5, 5);
        await expect(certificates.modalHeading).toBeHidden();

        await certificates.addCertificateButton.click();
        await expect(certificates.stepOneSubHeading).toBeVisible();
        await expect(certificates.stepTwoSubHeading).toBeHidden();
        await expect(certificates.continueButton).toBeDisabled();
        expect(calls.generateCount).toBe(1);
      });

      test("should let the user remove a selected certificate before submitting", async ({
        page,
      }) => {
        await openUploadStep(page);

        await certificates.certificateFileInput.setInputFiles({
          name: "apple_pay.cer",
          mimeType: "application/x-x509-ca-cert",
          buffer: Buffer.from("signed-apple-pay-certificate"),
        });
        await expect(certificates.submitButton).toBeEnabled();

        await certificates.removeSelectedFileButton.click();

        await expect(
          certificates.selectedFileName("apple_pay.cer"),
        ).toBeHidden();
        await expect(certificates.chooseFileButton).toBeVisible();
        await expect(certificates.submitButton).toBeDisabled();
      });
    });

    test.describe("when CSR generation fails", () => {
      useCertificatesPage({ resources: [], generateStatus: 500 });

      test("should show an inline error and keep Continue disabled when CSR generation fails", async ({
        page,
      }) => {
        await certificates.addCertificateButton.click();
        await certificates.downloadFileButton.click();

        await expect(certificates.errorBannerHeading).toBeVisible();
        await expect(
          page.getByText(
            /certificate authority unavailable.*Please try again\./i,
          ),
        ).toBeVisible();

        // No CSR was produced, so the user cannot advance to step 2.
        await expect(certificates.continueButton).toBeDisabled();
      });
    });

    test.describe("when certificate upload fails", () => {
      useCertificatesPage({ resources: [], uploadStatus: 400 });

      test("should surface an error and reset the file when certificate upload fails", async ({
        page,
      }) => {
        await openUploadStep(page);

        await certificates.certificateFileInput.setInputFiles({
          name: "wrong.cer",
          mimeType: "application/x-x509-ca-cert",
          buffer: Buffer.from("mismatched-certificate"),
        });
        await certificates.submitButton.click();

        await expect(certificates.errorBannerHeading).toBeVisible();
        await expect(
          page.getByText(
            /certificate does not match the request.*Try uploading again\./i,
          ),
        ).toBeVisible();

        // The bad file is dropped so the user must pick another one.
        await expect(certificates.chooseFileButton).toBeVisible();
        await expect(certificates.submitButton).toBeDisabled();
        await expect(certificates.modalHeading).toBeVisible();
      });
    });
  });

  test.describe("Feature flag off", () => {
    test.beforeEach(async ({ page }) => {
      await setHierarchicalConfigFeatureFlag(page, false);
      await mockResourceApis(page, { resources: [] });

      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);

      certificates = new HierarchicalConfigurationsPage(page);
      await new HomePage(page).settings.click();
    });

    test("should hide the sidebar entry and block the route when the feature flag is off", async ({
      page,
    }) => {
      await expect(certificates.sidebarLink).toBeHidden();

      // Deep-linking must not render the page either.
      await page.goto("/dashboard/hierarchical-configurations");
      await expect(certificates.addCertificateButton).toBeHidden();
      await expect(certificates.pageSubHeading).toBeHidden();
    });
  });
});
