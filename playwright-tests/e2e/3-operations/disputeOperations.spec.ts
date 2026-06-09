import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentOperations } from "../../support/pages/operations/PaymentOperations";
import { DisputesOperations } from "../../support/pages/operations/DisputesOperations";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  buildDispute,
  mockDisputesList,
  ompLineage,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// Disputes have no client-facing creation endpoint — production disputes
// arrive via connector webhooks — so every scenario that needs row data
// installs the mock from commands.ts before navigating.
const sampleDispute = (overrides = {}) =>
  buildDispute({
    dispute_id: "dp_playwright_sample_0001",
    payment_id: "pay_playwright_sample_0001",
    attempt_id: "pay_playwright_sample_0001_1",
    amount: "1250",
    currency: "USD",
    dispute_status: "dispute_opened",
    connector: "stripe",
    ...overrides,
  });

const goToDisputes = async (page: Page, homePage: HomePage) => {
  await homePage.operations.click();
  await homePage.disputesOperations.click();
  await page.waitForURL(/dashboard\/disputes/, { timeout: 15000 });
};


test.describe("Disputes List page", () => {

  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
  });

  test("should load the disputes list with all top-level controls and row data", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);
    const disputesOperations = new DisputesOperations(page);

    const dispute = sampleDispute();
    await mockDisputesList(page, [dispute]);
    await goToDisputes(page, homePage);

    await expect(page.getByText("Disputes").first()).toBeVisible();
    await expect(page.getByText(/View and manage all disputes/i)).toBeVisible();
    await expect(disputesOperations.searchInput).toBeVisible();
    await expect(paymentOperations.dateSelector).toBeVisible();
    await expect(paymentOperations.addFilters).toBeVisible();
    await expect(disputesOperations.fourColumnGrid).toBeVisible();

    // Row content: defaults are [DisputeId, Amount, DisputeStatus,
    // PaymentId, CreatedAt] (DisputesEntity.res:4); S.No is td1.
    await expect(disputesOperations.disputeCell(1, 1)).toBeVisible();
    await expect(disputesOperations.disputeCell(1, 2)).toContainText(dispute.dispute_id.slice(0, 20));
    await expect(disputesOperations.disputeCell(1, 3)).toContainText("12.5 USD");
    await expect(disputesOperations.disputeCell(1, 4)).toContainText("DISPUTE_OPENED");
    await expect(disputesOperations.disputeCell(1, 5)).toContainText(dispute.payment_id);
  });

  test("should show 'No results found' empty state when no disputes exist", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);
    const disputesOperations = new DisputesOperations(page);

    await mockDisputesList(page, []);
    await goToDisputes(page, homePage);

    await expect(disputesOperations.searchInput).toBeVisible();
    await expect(paymentOperations.dateSelector).toBeVisible();
    await expect(paymentOperations.addFilters).toBeVisible();
    await expect(page.getByText("No results found")).toBeVisible();
    await expect(paymentOperations.expandSearch90Days).toBeVisible();
  });

  test.describe("Search bar", () => {
    test("should display the matching dispute when searched by dispute ID", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);

      const target = sampleDispute({ dispute_id: "dp_playwright_search_target" });
      const other = sampleDispute({
        dispute_id: "dp_playwright_search_other",
        payment_id: "pay_other",
      });
      await mockDisputesList(page, [target, other]);
      await goToDisputes(page, homePage);

      await disputesOperations.searchInput.fill(target.dispute_id);
      await disputesOperations.searchInput.press("Enter");

      // CopyLinkTableCell truncates to the first 20 chars unless toggled.
      await expect(disputesOperations.disputeCell(1, 2)).toContainText(target.dispute_id.slice(0, 20));
      await expect(disputesOperations.disputeCell(2, 2)).not.toBeVisible();
    });

    test("should display the matching dispute when searched by payment ID", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);

      const target = sampleDispute({
        dispute_id: "dp_playwright_pay_search",
        payment_id: "pay_playwright_search_target",
      });
      const other = sampleDispute({
        dispute_id: "dp_playwright_pay_other",
        payment_id: "pay_unrelated",
      });
      await mockDisputesList(page, [target, other]);
      await goToDisputes(page, homePage);

      await disputesOperations.searchInput.fill(target.payment_id);
      await disputesOperations.searchInput.press("Enter");

      await expect(disputesOperations.disputeCell(1, 5)).toContainText(target.payment_id);
      await expect(disputesOperations.disputeCell(2, 5)).not.toBeVisible();
    });

    test("should display 'No results found' when search returns no matches", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);

      await mockDisputesList(page, [sampleDispute()]);
      await goToDisputes(page, homePage);

      await disputesOperations.searchInput.fill("dp_nonexistent_zzz");
      await disputesOperations.searchInput.press("Enter");
      await expect(page.getByText("No results found")).toBeVisible();
    });
  });

  test.describe("Columns", () => {
    test("should display all default columns in the disputes table", async ({ page }) => {
      const homePage = new HomePage(page);

      await mockDisputesList(page, [sampleDispute()]);
      await goToDisputes(page, homePage);

      // DisputesEntity.res:4 — defaults are [DisputeId, Amount, DisputeStatus, PaymentId, CreatedAt]
      // plus the implicit S.No column.
      const expectedHeaders = [
        "S.No",
        "Dispute ID",
        "Amount",
        "Dispute Status",
        "Payment ID",
        "Created",
      ];
      for (let i = 0; i < expectedHeaders.length; i++) {
        await expect(page.locator("table thead tr th").nth(i)).toHaveText(expectedHeaders[i]);
      }
    });

    test("should allow selecting columns from the column toggler", async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      await mockDisputesList(page, [sampleDispute()]);
      await goToDisputes(page, homePage);

      // All 10 optional columns the customizer can add (DisputesEntity.res
      // allColumns minus defaultColumns).
      const optionalColumns = [
        "Attempt ID",
        "Challenge Required By",
        "Connector",
        "Connector Created At",
        "Connector Dispute ID",
        "Connector Reason",
        "Connector Reason Code",
        "Connector Status",
        "Connector Updated At",
        "Currency",
      ];

      await paymentOperations.columnButton.click();

      // Modal should list every selectable column (defaults + optional).
      const defaultColumns = ["Dispute ID", "Amount", "Dispute Status", "Payment ID", "Created"];
      for (const column of [...defaultColumns, ...optionalColumns]) {
        await expect(paymentOperations.columnsModalBody).toContainText(column);
      }

      for (const column of optionalColumns) {
        await paymentOperations.dropdownValue(column).click();
      }
      await paymentOperations.saveButton.click();

      for (const column of [...defaultColumns, ...optionalColumns]) {
        await expect(paymentOperations.tableHeading(column)).toBeAttached();
      }
    });
  });

  test.describe("Date Selector", () => {
    test("should apply a predefined date range filter", async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      await mockDisputesList(page, [sampleDispute()]);
      await goToDisputes(page, homePage);

      await paymentOperations.dateSelector.click();
      await page.locator('[data-daterange-dropdown-value="Last 30 Days"]').click();
      await expect(paymentOperations.dateSelector).toContainText("Last 30 Days");
    });
  });

  test.describe("Filters", () => {
    test("should open the Add Filters dropdown and show all available filter options", async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);
      const disputesOperations = new DisputesOperations(page);

      await mockDisputesList(page, [sampleDispute()]);
      await goToDisputes(page, homePage);

      await paymentOperations.addFilters.click();
      await expect(disputesOperations.filterDropdown).toBeVisible();
      await expect(disputesOperations.filterDropdownOptions).toBeVisible();
    });

    test("should narrow the list when a dispute status filter is applied", async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);
      const disputesOperations = new DisputesOperations(page);

      const opened = sampleDispute({
        dispute_id: "dp_playwright_opened",
        payment_id: "pay_playwright_opened",
        dispute_status: "dispute_opened",
      });
      const won = sampleDispute({
        dispute_id: "dp_playwright_won",
        payment_id: "pay_playwright_won",
        dispute_status: "dispute_won",
      });
      await mockDisputesList(page, [opened, won]);
      await goToDisputes(page, homePage);

      // Baseline: both rows present.
      await expect(disputesOperations.disputeCell(1, 2)).toContainText(opened.dispute_id.slice(0, 20));
      await expect(disputesOperations.disputeCell(2, 2)).toContainText(won.dispute_id.slice(0, 20));

      await paymentOperations.addFilters.click();
      await page.locator('[data-dropdown-value="Dispute Status"]:visible').click();
      await page.locator('[data-component-field-wrapper="field-dispute_status"]').click();
      await page.locator('[value="dispute_won"]').click();
      await paymentOperations.applyButton.click();
      await page.waitForLoadState("networkidle");

      await expect(disputesOperations.disputeCell(1, 2)).toContainText(won.dispute_id.slice(0, 20));
      await expect(disputesOperations.disputeCell(2, 2)).not.toBeVisible();
      await expect(page.getByText(opened.dispute_id.slice(0, 20))).not.toBeVisible();
    });
  });

  test.describe("Generate Report", () => {
    // Both `generate_report` AND `email` flags must be true for the button
    // to render (Disputes.res:123), and at least one dispute has to be in
    // the list.
    test("should display Generate Report button when generate_report flag is ON", async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      await page.route("**/dashboard/config/feature?domain=", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        json.features = { ...json.features, generate_report: true, email: true };
        await route.fulfill({ response, json });
      });
      await page.reload();

      await mockDisputesList(page, [sampleDispute()]);
      await goToDisputes(page, homePage);

      await expect(paymentOperations.generateReports).toBeVisible();

      await paymentOperations.generateReports.click();
      await expect(page.getByText("Generate Dispute Reports")).toBeVisible();
      await expect(page.getByText("Date Range *")).toBeVisible();
      await expect(page.getByText("Report Type")).toBeVisible();
      await expect(page.getByText("Additional Recipients")).toBeVisible();
      await page.getByRole("button", { name: "Generate", exact: true }).click();
    });

    test("should hide Generate Report button when generate_report flag is OFF", async ({ page }) => {
      const homePage = new HomePage(page);
      const paymentOperations = new PaymentOperations(page);

      await mockDisputesList(page, [sampleDispute()]);
      await goToDisputes(page, homePage);

      await expect(paymentOperations.generateReports).not.toBeVisible();
    });
  });
});

test.describe("Dispute detail page", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
  });

  // Drives the list → detail navigation. The dispute's profile_id is
  // rewritten to the user's real session profile because DisputesEntity
  // builds the detail URL from `disputesData.profile_id` and
  // ShowDisputes.internalSwitch redirects back to /home if the URL
  // profile_id doesn't belong to the signed-in user.
  const openDisputeDetail = async (
    page: Page,
    homePage: HomePage,
    disputesOperations: DisputesOperations,
    dispute: ReturnType<typeof sampleDispute>,
  ) => {
    const { profileId } = await ompLineage(page);
    const resolved = { ...dispute, profile_id: profileId };
    await mockDisputesList(page, [resolved]);
    await goToDisputes(page, homePage);
    await disputesOperations.disputeCell(1, 2).click();
    await expect(page).toHaveURL(new RegExp(`/disputes/${dispute.dispute_id}`));
  };

  // ShowDisputes.res:48–60 — Counter Dispute (Upload Evidence) button is gated
  // on disputeEvidenceUpload flag AND connector ∈ {STRIPE, CHECKOUT} AND
  // dispute_status === dispute_opened. Helper flips the flag ON so eligibility
  // depends only on connector + status.
  const enableEvidenceUploadFlag = async (page: Page) => {
    await page.route("**/dashboard/config/feature?domain=", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      json.features = { ...json.features, dispute_evidence_upload: true };
      await route.fulfill({ response, json });
    });
    await page.reload();
  };

  test("should load the dispute detail page and render every Summary field", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);
    const disputesOperations = new DisputesOperations(page);
    const dispute = sampleDispute();

    await openDisputeDetail(page, homePage, disputesOperations, dispute);

    // Smoke markers — the page header + Summary block rendered.
    await expect(page.getByText("Summary", { exact: true })).toBeVisible();
    await expect(page.getByText("12.5 USD", { exact: true }).first()).toBeVisible();
    await expect(page.getByText("DISPUTE_OPENED", { exact: true }).first()).toBeVisible();
    await expect(page.getByText(/\d+ days to respond/)).toBeVisible();

    // ShowDisputes.DisputesInfo renders Details with allColumns
    // (DisputesEntity.res:7-23): every dispute field as a DisplayKeyValueParams
    // row keyed by `data-label`. Asserting on the formatted values produced by
    // the sample dispute's payload.
    await expect(paymentOperations.dataLabel("Amount").first()).toContainText("12.5 USD");
    await expect(paymentOperations.dataLabel("Attempt ID").first()).toContainText(dispute.attempt_id);
    // Dates are formatted with the user's locale TZ — assert on the
    // date portion only to keep this stable across machines.
    await expect(paymentOperations.dataLabel("Challenge Required By").first()).toContainText("Jun 08, 2026");
    await expect(paymentOperations.dataLabel("Connector").first()).toContainText("Stripe");
    await expect(paymentOperations.dataLabel("Connector Created At").first()).toContainText("May 19, 2026");
    await expect(paymentOperations.dataLabel("Connector Dispute ID").first()).toContainText(dispute.connector_dispute_id);
    await expect(paymentOperations.dataLabel("Connector Reason").first()).toContainText("fraudulent");
    await expect(paymentOperations.dataLabel("Connector Reason Code").first()).toContainText("N/A");
    await expect(paymentOperations.dataLabel("Connector Status").first()).toContainText("NeedsResponse");
    // null connector_updated_at renders as the "-" placeholder.
    await expect(paymentOperations.dataLabel("Connector Updated At").first()).toContainText("-");
    await expect(paymentOperations.dataLabel("Created").first()).toContainText("May 19, 2026");
    await expect(paymentOperations.dataLabel("Currency").first()).toContainText("USD");
    // CopyLinkTableCell truncates to the first 20 chars unless toggled.
    await expect(paymentOperations.dataLabel("Dispute ID").first()).toContainText(dispute.dispute_id.slice(0, 20));
    await expect(paymentOperations.dataLabel("Dispute Status").first()).toContainText("DISPUTE_OPENED");
    await expect(paymentOperations.dataLabel("Payment ID").first()).toContainText(dispute.payment_id);
  });

  test("should show the dual refund alert when is_already_refunded is true", async ({ page }) => {
    const homePage = new HomePage(page);
    const disputesOperations = new DisputesOperations(page);
    const dispute = sampleDispute({ is_already_refunded: true });

    // Inline the openDisputeDetail flow so we can land on the list page
    // first and assert the list-level alert before navigating to detail.
    const { profileId } = await ompLineage(page);
    await mockDisputesList(page, [{ ...dispute, profile_id: profileId }]);
    await goToDisputes(page, homePage);

    // Disputes.res:132–137 renders DualRefundsAlert on the LIST page when
    // any dispute row has is_already_refunded=true, with subText
    // "Click on Dispute ID to learn more".
    await expect(page.getByText('Dual Refunds DetectedClick on Dispute ID to learn')).toBeVisible();

    await disputesOperations.disputeCell(1, 2).click();
    await expect(page).toHaveURL(new RegExp(`/disputes/${dispute.dispute_id}`));

    // ShowDisputes.DisputesInfo:122-127 renders DualRefundsAlert on the
    // DETAIL page with a different subText.
    await expect(page.getByText(/The chargeback has exceeded the dispute amount/)).toBeVisible();
  });

  test.describe("Accept / Counter Dispute buttons by connector", () => {
    // DisputesUtils.res:249-251 —
    //   connectorSupportCounterDispute   = [CHECKOUT, STRIPE]
    //   connectorsSupportAcceptDispute   = [CHECKOUT]
    // The Counter Dispute button rides the ShowDisputes wrapper render gate,
    // so it appears whenever the connector is in the counter list. The Accept
    // Dispute button is rendered inside that wrapper, gated by the accept
    // list — so only CHECKOUT shows both.

    test("Stripe: Counter Dispute is visible, Accept Dispute is hidden", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute({ connector: "stripe", dispute_status: "dispute_opened" });

      await enableEvidenceUploadFlag(page);
      await openDisputeDetail(page, homePage, disputesOperations, dispute);

      await expect(page.getByRole("button", { name: "Counter Dispute" })).toBeVisible();
      await expect(page.getByRole("button", { name: "Accept Dispute" })).not.toBeVisible();
    });

    test("Checkout: both Counter Dispute and Accept Dispute are visible", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute({ connector: "checkout", dispute_status: "dispute_opened" });

      await enableEvidenceUploadFlag(page);
      await openDisputeDetail(page, homePage, disputesOperations, dispute);

      await expect(page.getByRole("button", { name: "Counter Dispute" })).toBeVisible();
      await expect(page.getByRole("button", { name: "Accept Dispute" })).toBeVisible();
    });

    test("Adyen: neither Counter Dispute nor Accept Dispute is visible", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute({ connector: "adyen", dispute_status: "dispute_opened" });

      await enableEvidenceUploadFlag(page);
      await openDisputeDetail(page, homePage, disputesOperations, dispute);

      await expect(page.getByRole("button", { name: "Counter Dispute" })).not.toBeVisible();
      await expect(page.getByRole("button", { name: "Accept Dispute" })).not.toBeVisible();
    });

    test("should hide both buttons when disputeEvidenceUpload flag is OFF (even on Checkout)", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute({ connector: "checkout", dispute_status: "dispute_opened" });

      // Flag defaults to false in local config — no mock needed.
      await openDisputeDetail(page, homePage, disputesOperations, dispute);

      await expect(page.getByRole("button", { name: "Counter Dispute" })).not.toBeVisible();
      await expect(page.getByRole("button", { name: "Accept Dispute" })).not.toBeVisible();
    });

    test("Accept Dispute opens the confirmation popup and POSTs to /disputes/accept on Proceed", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute({ connector: "checkout", dispute_status: "dispute_opened" });

      await enableEvidenceUploadFlag(page);

      // Stub POST /disputes/accept/{id} so the Proceed click hits a known
      // success response instead of the real backend.
      await page.route(/\/disputes\/accept\/(dp_[^/?]+)(\?|$)/, async (route) => {
        await route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify({ ...dispute, dispute_status: "dispute_accepted" }),
        });
      });

      await openDisputeDetail(page, homePage, disputesOperations, dispute);

      await page.getByRole("button", { name: "Accept Dispute" }).click();

      // Popup body (UploadEvidenceForDisputes.res:397-405).
      await expect(page.getByText("Accept this dispute?")).toBeVisible();
      await expect(
        page.getByText(/By accepting you will lose this dispute and will have to refund the amount to the user/),
      ).toBeVisible();
      await expect(page.getByRole("button", { name: "Cancel" })).toBeVisible();
      await expect(page.getByRole("button", { name: "Proceed" })).toBeVisible();

      // Clicking Proceed fires handleAcceptDispute → POST /disputes/accept/{id}.
      const acceptRequest = page.waitForRequest(
        (req) => /\/disputes\/accept\/dp_/.test(req.url()) && req.method() === "POST",
      );
      await page.getByRole("button", { name: "Proceed" }).click();
      await acceptRequest;
      // No "Something went wrong" toast — handleAcceptDispute's catch path
      // only fires on a non-2xx response.
      await expect(page.getByText('DISPUTE_ACCEPTED').first()).toBeVisible();
    });
  });

  test.describe("Evidence upload modal", () => {
    test("should open the attach-supporting-evidence modal when Counter Dispute is clicked", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute({ connector: "stripe", dispute_status: "dispute_opened" });

      await enableEvidenceUploadFlag(page);
      await openDisputeDetail(page, homePage, disputesOperations, dispute);

      await page.getByRole("button", { name: "Counter Dispute" }).click();

      // Modal heading + helper copy (UploadEvidenceForDisputes.res:143-161).
      await expect(page.getByText("Attach supporting evidence")).toBeVisible();
      await expect(page.getByText("Upload evidence that is most relevant to this dispute")).toBeVisible();
      await expect(page.getByText("The evidence can be one or more of the following:")).toBeVisible();

      // Every evidence-type row from DisputesUtils.evidenceList renders a
      // label + an Upload control. Asserting on each row keeps the test in
      // step with the canonical list.
      const evidenceTypes = [
        "Receipt",
        "Refund policy",
        "Uncategorized file",
        "Customer signature",
        "Service documentation",
        "Customer communication",
        "Shipping documentation",
        "Recurring transaction agreement",
        "Invoice showing distinct transactions",
      ];
      for (const label of evidenceTypes) {
        await expect(page.getByText(label, { exact: true })).toBeVisible();
      }
      // One Upload affordance per row; the modal renders many of them.
      await expect(page.getByText("Upload", { exact: true })).toHaveCount(evidenceTypes.length);

      await expect(page.getByRole("button", { name: "Attach Evidence" })).toBeVisible();
    });

    test("should submit evidence successfully when a file is uploaded", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute({ connector: "stripe", dispute_status: "dispute_opened" });

      await enableEvidenceUploadFlag(page);

      // Two endpoints share the /disputes/evidence prefix:
      //   PUT  /disputes/evidence/{id} — per-file attach, expects {file_id}
      //   POST /disputes/evidence      — final submit, response replaces the
      //                                  page's disputeData via setDisputeData
      // The post-submit handler also upgrades dispute_status from
      // dispute_opened → dispute_challenged on the backend; mirror that here
      // so the Details panel keeps showing real values + the new status.
      await page.route(/\/disputes\/evidence(\/|$)/, async (route) => {
        const method = route.request().method();
        if (method === "POST") {
          await route.fulfill({
            status: 200,
            contentType: "application/json",
            body: JSON.stringify({ ...dispute, dispute_status: "dispute_challenged" }),
          });
          return;
        }
        // PUT (per-file attach) — the UI only reads `file_id` off the
        // response (UploadEvidenceForDisputes.res:126).
        await route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify({ file_id: `mock_file_${Date.now()}` }),
        });
      });

      await openDisputeDetail(page, homePage, disputesOperations, dispute);
      await page.getByRole("button", { name: "Counter Dispute" }).click();
      await expect(page.getByRole("button", { name: "Attach Evidence" })).toBeDisabled();

      await page.locator('input[type="file"]').first().setInputFiles({
        name: "evidence.pdf",
        mimeType: "application/pdf",
        buffer: Buffer.from("mock pdf content"),
      });

      const evidenceRequest = page.waitForRequest((req) => /\/disputes\/evidence(\/|$)/.test(req.url()));
      await page.getByRole("button", { name: "Attach Evidence" }).click();
      await evidenceRequest;
      // No error toast on success.
      await expect(page.getByText('Your dispute evidence has')).toBeVisible();
      await expect(page.locator('div').filter({ hasText: /^evidence\.pdf$/ }).nth(1)).toBeVisible();
      await expect(page.getByRole('button', { name: 'Attach More' })).toBeVisible();
      const submitRequest = page.waitForRequest(
        (req) => /\/disputes\/evidence(\/|$)/.test(req.url()) && req.method() === "POST",
      );
      await page.getByRole('button', { name: 'Submit your evidence' }).click();
      await submitRequest;

      // Backend echoes the dispute back with dispute_status flipped to
      // dispute_challenged, so the page should re-render with the new badge
      // and the Counter / Accept buttons should disappear (the gate in
      // ShowDisputes.res:48-60 requires dispute_status === DisputeOpened).
      await expect(page.getByText("DISPUTE_CHALLENGED", { exact: true }).first()).toBeVisible();
      await expect(page.getByRole("button", { name: "Counter Dispute" })).not.toBeVisible();
      await expect(page.getByRole("button", { name: "Accept Dispute" })).not.toBeVisible();
      await expect(page.getByText('These are the attachments you have provided as evidence.evidence.pdf')).toBeVisible();
    });
  });

  test.describe("Events and logs accordion", () => {
    test("should be visible when audit_trail flag is ON", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute();

      await page.route("**/dashboard/config/feature?domain=", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        json.features = { ...json.features, audit_trail: true };
        await route.fulfill({ response, json });
      });
      await page.reload();

      await openDisputeDetail(page, homePage, disputesOperations, dispute);

      await expect(page.getByText("Events and logs")).toBeVisible();
    });

    test("should be hidden when audit_trail flag is OFF", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute();

      await page.route("**/dashboard/config/feature?domain=", async (route) => {
        const response = await route.fetch();
        const json = await response.json();
        json.features = { ...json.features, audit_trail: false };
        await route.fulfill({ response, json });
      });
      await page.reload();

      await openDisputeDetail(page, homePage, disputesOperations, dispute);

      await expect(page.getByText("Summary", { exact: true })).toBeVisible();
      await expect(page.getByText("Events and logs")).not.toBeVisible();
    });
  });
});
