import { test, expect } from "../../support/test";
import type { BrowserContext, Page, Response } from "@playwright/test";
import fs from "fs";
import { HierarchicalConfigurationsPage } from "../../support/pages/settings/HierarchicalConfigurationsPage";
import { generateUniqueEmail } from "../../support/helper";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentConnector } from "../../support/pages/connector/PaymentConnector";
import {
  signupUser,
  loginUI,
  signApplePayCsr,
  createApplePayCertificateAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
const API_TIMEOUT = 15000;
const RESOURCE_TYPE = "apple_pay_certificate";
const MERCHANT_IDENTIFIER = "merchant.com.playwright.test";
const CONNECTOR_SETUP_TIMEOUT = 60000;

type Resource = {
  id: string;
  display_data: { apple_pay_merchant_identifier?: string };
  created_at: string;
  is_linked: boolean;
};
type ResourceList = { resources: Resource[] };
type CreatedResource = {
  id: string;
  data: { apple_pay_certificate: { csr: string } };
};

function isResourceList(response: Response): boolean {
  return (
    response.request().method() === "POST" &&
    new URL(response.url()).pathname.endsWith("/hierarchical_resources/list")
  );
}

function isResourceCreate(response: Response): boolean {
  return (
    response.request().method() === "POST" &&
    new URL(response.url()).pathname.endsWith("/hierarchical_resources")
  );
}

async function setHierarchicalConfigurationsFlag(page: Page, enabled: boolean) {
  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    json.features = {
      ...(json.features ?? {}),
      hierarchical_configurations: enabled,
    };
    await route.fulfill({ response, json });
  });
}

// Opens the modal and clicks Download File, returning the CSR the backend
// issued along with the file the browser saved.
async function generateCsr(
  page: Page,
  certificates: HierarchicalConfigurationsPage,
) {
  await certificates.addCertificateButton.click();
  await expect(certificates.modal).toBeVisible();
  const [createResponse, download] = await Promise.all([
    page.waitForResponse(isResourceCreate, { timeout: API_TIMEOUT }),
    page.waitForEvent("download", { timeout: API_TIMEOUT }),
    certificates.downloadFileButton.click(),
  ]);
  expect(createResponse.ok()).toBeTruthy();
  expect(createResponse.request().postDataJSON()).toEqual({
    type: RESOURCE_TYPE,
  });
  const resource: CreatedResource = await createResponse.json();
  return { resource, download };
}

async function chooseCertificateFile(
  page: Page,
  certificates: HierarchicalConfigurationsPage,
  name: string,
  buffer: Buffer,
) {
  const [fileChooser] = await Promise.all([
    page.waitForEvent("filechooser"),
    certificates.chooseFileButton.click(),
  ]);
  await fileChooser.setFiles({
    name,
    mimeType: "application/pkix-cert",
    buffer,
  });
}

// Menus on the long Apple Pay form can open outside the viewport, so pick the
// item with the keyboard rather than a pointer click.
async function selectMenuItem(page: Page, name: string) {
  await page.getByRole("button", { name: "Select Value" }).first().click();
  const item = page.getByRole("menuitem", { name, exact: true });
  await item.focus();
  await page.keyboard.press("Enter");
  await expect(item).toBeHidden();
}

// Walks the Stripe setup to the Apple Pay iOS Certificate form with every
// field except "Payment Processing Details At" filled.
async function openApplePayIosCertificateForm(page: Page) {
  const homePage = new HomePage(page);
  const paymentConnector = new PaymentConnector(page);
  await homePage.connectors.click();
  await homePage.paymentProcessors.click();
  await paymentConnector.connectorSearchInput.fill("stripe");
  await paymentConnector.stripeConnector
    .locator("button")
    .click({ force: true });
  await expect(paymentConnector.apiKeyInput).toBeVisible();
  const inputs = page
    .locator('.grid.grid-cols-2 input[type="text"]')
    .locator("visible=true");
  for (let i = 0; i < (await inputs.count()); i++) {
    await inputs.nth(i).fill("test_value");
  }
  await paymentConnector.connectAndProceedButton.click();

  await page.getByText("Apple Pay").first().click();
  await page
    .getByText("iOS Certificate")
    .locator("visible=true")
    .first()
    .click();
  await page.getByRole("button", { name: "Continue" }).click();
  await page
    .getByRole("textbox", { name: "Enter Merchant Certificate (" })
    .fill("test_value");
  await page
    .getByRole("textbox", { name: "Enter Merchant PrivateKey (" })
    .fill("test_value");
  await page
    .getByRole("textbox", { name: "Enter Apple Merchant" })
    .fill(MERCHANT_IDENTIFIER);
  await page
    .getByRole("textbox", { name: "Enter Display Name" })
    .fill("Playwright");
  await selectMenuItem(page, "IOS");
  await selectMenuItem(page, "UnitedStatesOfAmerica");
  await expect(page.getByText("Payment Processing Details At")).toBeVisible();
}

test.describe("Hierarchical Configurations", () => {
  test.describe("Feature flag", () => {
    test("should hide Hierarchical Configurations from Settings and block its route when hierarchical_configurations is OFF", async ({
      page,
      context,
    }) => {
      await setHierarchicalConfigurationsFlag(page, false);
      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);
      const certificates = new HierarchicalConfigurationsPage(page);

      await certificates.settingsSidebar.click();
      // Sibling links render, so the Settings section is expanded.
      await expect(page.getByTestId("organizationsettings")).toBeVisible();
      await expect(certificates.sidebarLink).toHaveCount(0);

      await certificates.visit();
      await expect(certificates.unauthorizedMessage).toBeVisible();
      await expect(certificates.subtitle).toHaveCount(0);
      await expect(certificates.addCertificateButton).toHaveCount(0);
    });
  });

  test.describe("Certificate management page", () => {
    test.beforeEach(async ({ page, context }) => {
      await setHierarchicalConfigurationsFlag(page, true);
      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);
      const certificates = new HierarchicalConfigurationsPage(page);
      await certificates.settingsSidebar.click();
      const [response] = await Promise.all([
        page.waitForResponse(isResourceList, { timeout: API_TIMEOUT }),
        certificates.sidebarLink.click(),
      ]);
      expect(
        response.ok(),
        `DBG ${response.status()} ${await response.text()} ${JSON.stringify(response.request().headers())}`,
      ).toBeTruthy();
      expect(response.request().postDataJSON()).toEqual({
        type: RESOURCE_TYPE,
      });
      const list: ResourceList = await response.json();
      expect(list.resources).toEqual([]);
    });

    test("should navigate from Settings to an empty certificate list and display all its elements", async ({
      page,
    }) => {
      const certificates = new HierarchicalConfigurationsPage(page);
      await expect(certificates.sidebarLink).toHaveText(
        "Hierarchical Configurations",
      );
      await expect(page).toHaveURL(
        /\/dashboard\/hierarchical-configurations(?:[?#].*)?$/,
      );
      await expect(certificates.pageHeading).toBeVisible();
      await expect(certificates.subtitle).toBeVisible();
      await expect(certificates.addCertificateButton).toBeVisible();
      await expect(certificates.emptyTableMessage).toBeVisible();
      await expect(certificates.tableRows).toHaveCount(0);
    });

    test("should generate and download a CSR on step 1 of the Add certificate modal", async ({
      page,
    }) => {
      const certificates = new HierarchicalConfigurationsPage(page);
      await certificates.addCertificateButton.click();
      await expect(certificates.modalHeading).toHaveText(
        "Add New Apple Pay Certificate",
      );
      await expect(
        certificates.modalText(
          "Step 1 of 2 - Download the certificate signing request",
        ),
      ).toBeVisible();
      await expect(
        certificates.modalText(
          "Use this Certificate Signing Request to obtain a secure certificate from Apple, which enables you to accept Apple Pay.",
        ),
      ).toBeVisible();
      await expect(certificates.downloadFileButton).toBeEnabled();
      // Continue unlocks only once a CSR has been generated.
      await expect(certificates.continueButton).toBeDisabled();
      await certificates.closeModalIcon.click();
      await expect(certificates.modal).toBeHidden();

      const { resource, download } = await generateCsr(page, certificates);
      expect(resource.id).toBeTruthy();
      const csr = resource.data.apple_pay_certificate.csr;
      expect(csr).toContain("-----BEGIN CERTIFICATE REQUEST-----");
      expect(download.suggestedFilename()).toBe("apple_pay.csr");
      expect(fs.readFileSync(await download.path(), "utf8")).toBe(csr);
      await expect(certificates.continueButton).toBeEnabled();

      // A CSR without an uploaded certificate is not listed.
      await certificates.closeModalIcon.click();
      await certificates.addCertificateButton.click();
      await expect(certificates.continueButton).toBeDisabled();
      await expect(certificates.emptyTableMessage).toBeVisible();
    });

    test("should upload a signed certificate and list it in the table", async ({
      page,
    }) => {
      const certificates = new HierarchicalConfigurationsPage(page);
      const { resource } = await generateCsr(page, certificates);
      const certificate = signApplePayCsr(
        resource.data.apple_pay_certificate.csr,
        MERCHANT_IDENTIFIER,
      );

      await certificates.continueButton.click();
      await expect(
        certificates.modalText("Step 2 of 2 - Upload the signed certificate"),
      ).toBeVisible();
      await expect(
        certificates.modalText(
          "Upload your new certificate file below and click Submit.",
        ),
      ).toBeVisible();
      await expect(certificates.submitButton).toBeDisabled();

      await chooseCertificateFile(
        page,
        certificates,
        "apple_pay.cer",
        certificate,
      );
      await expect(certificates.modalText("apple_pay.cer")).toBeVisible();
      await expect(certificates.chooseFileButton).toHaveCount(0);
      await expect(certificates.submitButton).toBeEnabled();

      const [uploadResponse, listResponse] = await Promise.all([
        page.waitForResponse(
          (response) =>
            response.request().method() === "PUT" &&
            new URL(response.url()).pathname.endsWith(
              `/hierarchical_resources/${RESOURCE_TYPE}/${resource.id}`,
            ),
          { timeout: API_TIMEOUT },
        ),
        page.waitForResponse(isResourceList, { timeout: API_TIMEOUT }),
        certificates.submitButton.click(),
      ]);
      expect(uploadResponse.ok()).toBeTruthy();
      expect(uploadResponse.request().postDataJSON()).toEqual({
        certificate: certificate.toString("base64"),
      });
      await expect(
        certificates.toast("Certificate uploaded successfully"),
      ).toBeVisible();
      await expect(certificates.modal).toBeHidden();

      const list: ResourceList = await listResponse.json();
      expect(list.resources).toHaveLength(1);
      expect(list.resources[0]).toMatchObject({
        id: resource.id,
        display_data: { apple_pay_merchant_identifier: MERCHANT_IDENTIFIER },
        is_linked: false,
      });

      for (const heading of [
        "S.No",
        "Resource ID",
        "Merchant Identifier",
        "Created",
      ]) {
        await expect(certificates.tableHeading(heading)).toBeVisible();
      }
      await expect(certificates.tableRows).toHaveCount(1);
      await expect(certificates.resourceCell(resource.id, 1)).toHaveText("1");
      await expect(certificates.resourceCell(resource.id, 2)).toContainText(
        resource.id,
      );
      await expect(certificates.resourceCell(resource.id, 3)).toHaveText(
        MERCHANT_IDENTIFIER,
      );
      await expect(certificates.resourceCell(resource.id, 4)).not.toHaveText(
        "",
      );
      await expect(certificates.emptyTableMessage).toHaveCount(0);
    });

    test("should show an error and clear the file when an invalid certificate is submitted", async ({
      page,
    }) => {
      const certificates = new HierarchicalConfigurationsPage(page);
      await generateCsr(page, certificates);
      await certificates.continueButton.click();

      // Removing a chosen file puts the picker back.
      await chooseCertificateFile(
        page,
        certificates,
        "removed.cer",
        Buffer.from("removed"),
      );
      await expect(certificates.modalText("removed.cer")).toBeVisible();
      await certificates.removeFileIcon.click();
      await expect(certificates.modalText("removed.cer")).toHaveCount(0);
      await expect(certificates.chooseFileButton).toBeVisible();
      await expect(certificates.submitButton).toBeDisabled();

      await chooseCertificateFile(
        page,
        certificates,
        "invalid.cer",
        Buffer.from("not a certificate"),
      );
      const [uploadResponse] = await Promise.all([
        page.waitForResponse(
          (response) =>
            response.request().method() === "PUT" &&
            /\/hierarchical_resources\/apple_pay_certificate\/[^/]+$/.test(
              new URL(response.url()).pathname,
            ),
          { timeout: API_TIMEOUT },
        ),
        certificates.submitButton.click(),
      ]);
      expect(uploadResponse.status()).toBe(422);

      await expect(
        certificates.modalText("Something went wrong"),
      ).toBeVisible();
      await expect(
        certificates.modal.getByText(
          "Certificate is not a valid DER-encoded X.509 certificate Try uploading again.",
        ),
      ).toBeVisible();
      await expect(
        certificates.modalText("Step 2 of 2 - Upload the signed certificate"),
      ).toBeVisible();
      await expect(certificates.modalText("invalid.cer")).toHaveCount(0);
      await expect(certificates.chooseFileButton).toBeVisible();
      await expect(certificates.submitButton).toBeDisabled();

      await certificates.closeModalIcon.click();
      await expect(certificates.modal).toBeHidden();
      await expect(certificates.emptyTableMessage).toBeVisible();
    });
  });

  test.describe("Apple Pay connector certificate source", () => {
    async function loginWithFlag(
      page: Page,
      context: BrowserContext,
      enabled: boolean,
    ) {
      test.setTimeout(CONNECTOR_SETUP_TIMEOUT);
      await setHierarchicalConfigurationsFlag(page, enabled);
      const email = generateUniqueEmail();
      await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
      await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    }

    const certificateSourceLabel = (page: Page) =>
      page.locator('[data-form-label="Certificate Source"]');
    const rawCertificateInput = (page: Page) =>
      page.getByPlaceholder("Enter Processing Certificate", { exact: true });
    const rawKeyInput = (page: Page) =>
      page.getByPlaceholder("Enter Processing Key", { exact: true });
    const linkHint = (page: Page) =>
      page.getByText("Proceed to next step to link the certificate.", {
        exact: true,
      });

    test("should offer a Certificate Source choice when payment processing is at Hyperswitch", async ({
      page,
      context,
    }) => {
      await loginWithFlag(page, context, true);
      await openApplePayIosCertificateForm(page);
      await expect(certificateSourceLabel(page)).toHaveCount(0);

      await page.getByText("Hyperswitch", { exact: true }).click();
      await expect(certificateSourceLabel(page)).toBeVisible();
      await expect(
        page.getByText("Enter certificate details", { exact: true }),
      ).toBeVisible();
      await expect(
        page.getByText("Link a managed certificate", { exact: true }),
      ).toBeVisible();
      // Nothing below the choice until a source is picked.
      await expect(rawCertificateInput(page)).toHaveCount(0);
      await expect(linkHint(page)).toHaveCount(0);
      await expect(
        page.getByRole("button", { name: "Verify & Enable" }),
      ).toBeDisabled();

      await page
        .getByText("Link a managed certificate", { exact: true })
        .click();
      await expect(linkHint(page)).toBeVisible();
      await expect(rawCertificateInput(page)).toHaveCount(0);
      await expect(rawKeyInput(page)).toHaveCount(0);
      await expect(
        page.getByRole("button", { name: "Verify & Enable" }),
      ).toBeEnabled();

      await page
        .getByText("Enter certificate details", { exact: true })
        .click();
      await expect(linkHint(page)).toHaveCount(0);
      await expect(rawCertificateInput(page)).toBeVisible();
      await expect(rawKeyInput(page)).toBeVisible();

      // Switching back to Connector drops the Hyperswitch-only fields.
      await page.getByText("Connector", { exact: true }).click();
      await expect(certificateSourceLabel(page)).toHaveCount(0);
      await expect(rawCertificateInput(page)).toHaveCount(0);
    });

    test("should ask for raw certificate details only when hierarchical_configurations is OFF", async ({
      page,
      context,
    }) => {
      await loginWithFlag(page, context, false);
      await openApplePayIosCertificateForm(page);
      await page.getByText("Hyperswitch", { exact: true }).click();
      await expect(rawCertificateInput(page)).toBeVisible();
      await expect(rawKeyInput(page)).toBeVisible();
      await expect(certificateSourceLabel(page)).toHaveCount(0);
      await expect(
        page.getByText("Link a managed certificate", { exact: true }),
      ).toHaveCount(0);
    });

    test("should link a managed certificate to the connector from its preview", async ({
      page,
      context,
    }) => {
      await loginWithFlag(page, context, true);
      await openApplePayIosCertificateForm(page);
      await page.getByText("Hyperswitch", { exact: true }).click();
      await page
        .getByText("Link a managed certificate", { exact: true })
        .click();
      await page.getByRole("button", { name: "Verify & Enable" }).click();
      const applePay = page.getByLabel("Apple Pay");
      await applePay.getByRole("button", { name: "Proceed" }).click();
      await expect(
        applePay.getByRole("button", { name: "Proceed" }),
      ).toHaveCount(0);

      const [connectorResponse] = await Promise.all([
        page.waitForResponse(
          (response) =>
            response.request().method() === "POST" &&
            /\/account\/[^/]+\/connectors$/.test(
              new URL(response.url()).pathname,
            ),
          { timeout: API_TIMEOUT },
        ),
        new PaymentConnector(page).pmtProceedButton.click(),
      ]);
      expect(connectorResponse.ok()).toBeTruthy();
      const sessionTokenData = connectorResponse.request().postDataJSON()
        .metadata.apple_pay_combined.manual.session_token_data;
      expect(sessionTokenData).toMatchObject({
        payment_processing_details_at: "Hyperswitch",
        payment_processing_detail_input_type: "link_hierarchical_resource",
      });
      expect(
        sessionTokenData.payment_processing_certificate ?? null,
      ).toBeNull();
      expect(
        sessionTokenData.payment_processing_certificate_key ?? null,
      ).toBeNull();
      const { merchant_connector_id: connectorId } =
        await connectorResponse.json();

      const certificateSection = page
        .getByRole("heading", { name: "Apple Pay Certificate" })
        .locator("xpath=../..");
      const linkButton = certificateSection.getByRole("button", {
        name: "Link",
        exact: true,
      });
      await expect(
        certificateSection.getByText(
          "No certificates available. Add one from Settings > Hierarchical Configurations.",
        ),
      ).toBeVisible();
      await expect(linkButton).toBeDisabled();

      const resourceId = await createApplePayCertificateAPI(
        page,
        MERCHANT_IDENTIFIER,
      );
      const optionLabel = `${MERCHANT_IDENTIFIER} (${resourceId})`;
      // Reopen the saved connector; the setup URL restarts the wizard.
      const connectorUrl = `/dashboard/connectors/${connectorId}?name=stripe`;
      const [listResponse] = await Promise.all([
        page.waitForResponse(isResourceList, { timeout: API_TIMEOUT }),
        page.goto(connectorUrl),
      ]);
      expect(listResponse.request().postDataJSON()).toEqual({
        type: RESOURCE_TYPE,
        scope_type: "merchant_connector_account",
        scope_id: connectorId,
      });
      await expect(
        certificateSection.getByText("Select certificate"),
      ).toBeVisible();
      await expect(linkButton).toBeDisabled();

      await certificateSection.getByText("Select certificate").click();
      await page.getByText(optionLabel, { exact: true }).click();
      // The menu stays open after picking, so the trigger is the first match.
      await expect(
        certificateSection.getByText(optionLabel).first(),
      ).toBeVisible();
      await expect(linkButton).toBeEnabled();

      const [linkResponse] = await Promise.all([
        page.waitForResponse(
          (response) =>
            response.request().method() === "POST" &&
            new URL(response.url()).pathname.endsWith(
              `/hierarchical_resources/${resourceId}/link`,
            ),
          { timeout: API_TIMEOUT },
        ),
        linkButton.click(),
      ]);
      expect(linkResponse.ok()).toBeTruthy();
      expect(linkResponse.request().postDataJSON()).toEqual({
        requestor_type: "merchant_connector_account",
        requestor_id: connectorId,
      });
      await expect(
        page.locator('[data-id="Certificate linked successfully"]'),
      ).toBeVisible();
      await expect(linkButton).toBeDisabled();

      // The link persists: after a reload the certificate is preselected.
      const [relisted] = await Promise.all([
        page.waitForResponse(isResourceList, { timeout: API_TIMEOUT }),
        page.goto(connectorUrl),
      ]);
      const list: ResourceList = await relisted.json();
      expect(list.resources).toEqual([
        expect.objectContaining({ id: resourceId, is_linked: true }),
      ]);
      await expect(certificateSection.getByText(optionLabel)).toBeVisible();
      await expect(linkButton).toBeDisabled();
    });
  });
});
