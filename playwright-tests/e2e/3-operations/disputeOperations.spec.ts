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

test.describe("Disputes Operations", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
  });

  test.describe("Disputes List page", () => {
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
          "Connector Required By",
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

  test("should load the dispute detail page when a row is clicked", async ({ page }) => {
    const homePage = new HomePage(page);
    const disputesOperations = new DisputesOperations(page);
    const dispute = sampleDispute();

    await openDisputeDetail(page, homePage, disputesOperations, dispute);

    // The page header, the Summary section, and the amount block are the
    // smoke markers that the detail page rendered.
    await expect(page.getByText("Summary", { exact: true })).toBeVisible();
    await expect(page.getByText("12.5 USD", { exact: true }).first()).toBeVisible();
    await expect(page.getByText("DISPUTE_OPENED", { exact: true }).first()).toBeVisible();
  });

  test("should display Summary section fields", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);
    const disputesOperations = new DisputesOperations(page);
    const dispute = sampleDispute({ connector_reason: "fraudulent" });

    await openDisputeDetail(page, homePage, disputesOperations, dispute);

    // ShowDisputes.DisputesInfo renders Details with allColumns
    // (DisputesEntity.res:7-23): every dispute field as a DisplayKeyValueParams
    // row. Spot-check the headings the CSV calls out.
    await expect(paymentOperations.dataLabel("Payment ID").first()).toBeVisible();
    await expect(paymentOperations.dataLabel("Attempt ID").first()).toBeVisible();
    await expect(paymentOperations.dataLabel("Created").first()).toBeVisible();
    await expect(paymentOperations.dataLabel("Connector Reason").first()).toContainText("fraudulent");
    await expect(paymentOperations.dataLabel("Dispute Status").first()).toBeVisible();
    // No dedicated "Related Payment" section exists — the dispute's payment is
    // exposed through the Payment ID + Attempt ID cells in the Details panel.
    await expect(page.getByText(dispute.payment_id).first()).toBeVisible();
  });

  test("should show 'X days to respond' badge for opened disputes with a challenge deadline", async ({ page }) => {
    const homePage = new HomePage(page);
    const disputesOperations = new DisputesOperations(page);
    // Deadline ~5 days from "today" (2026-05-21 per the session clock).
    const dispute = sampleDispute({
      dispute_status: "dispute_opened",
      challenge_required_by: "2026-05-26T18:00:00.000Z",
    });

    await openDisputeDetail(page, homePage, disputesOperations, dispute);

    await expect(page.getByText(/\d+ days to respond/)).toBeVisible();
  });

  test("should show the dual refund alert when is_already_refunded is true", async ({ page }) => {
    const homePage = new HomePage(page);
    const disputesOperations = new DisputesOperations(page);
    const dispute = sampleDispute({ is_already_refunded: true });

    await openDisputeDetail(page, homePage, disputesOperations, dispute);

    // ShowDisputes.DisputesInfo:122-127 renders DualRefundsAlert with this
    // subText when is_already_refunded is true.
    await expect(page.getByText(/The chargeback has exceeded the dispute amount/)).toBeVisible();
  });

  test.describe("Upload Evidence (Counter Dispute) button", () => {
    test("should be visible when flag is ON, connector is Stripe, and dispute is opened", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute({ connector: "stripe", dispute_status: "dispute_opened" });

      await enableEvidenceUploadFlag(page);
      await openDisputeDetail(page, homePage, disputesOperations, dispute);

      await expect(page.getByRole("button", { name: "Counter Dispute" })).toBeVisible();
    });

    test("should be hidden when disputeEvidenceUpload flag is OFF", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute({ connector: "stripe", dispute_status: "dispute_opened" });

      // Flag defaults to false in the local config — no mock needed.
      await openDisputeDetail(page, homePage, disputesOperations, dispute);

      await expect(page.getByRole("button", { name: "Counter Dispute" })).not.toBeVisible();
    });

    test("should be hidden when the connector is not in the supported list", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      // DisputesUtils.res:251 — connectorSupportCounterDispute is
      // [CHECKOUT, STRIPE] only; Adyen is not eligible.
      const dispute = sampleDispute({ connector: "adyen", dispute_status: "dispute_opened" });

      await enableEvidenceUploadFlag(page);
      await openDisputeDetail(page, homePage, disputesOperations, dispute);

      await expect(page.getByRole("button", { name: "Counter Dispute" })).not.toBeVisible();
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

      await expect(page.getByText("Attach supporting evidence")).toBeVisible();
      await expect(page.getByText("Upload evidence that is most relevant to this dispute")).toBeVisible();
      await expect(page.getByRole("button", { name: "Attach Evidence" })).toBeVisible();
    });

    test("should disable Attach Evidence until a file is uploaded", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute({ connector: "stripe", dispute_status: "dispute_opened" });

      await enableEvidenceUploadFlag(page);
      await openDisputeDetail(page, homePage, disputesOperations, dispute);
      await page.getByRole("button", { name: "Counter Dispute" }).click();

      // Initially no file → button is in Disabled state.
      await expect(page.getByRole("button", { name: "Attach Evidence" })).toBeDisabled();

      // Hidden inputs accept only .pdf,.csv,.img,.jpeg (one per evidence type).
      // Use a short name; UploadEvidenceForDisputes truncates filenames longer
      // than 10 chars (truncateFileNameWithEllipses).
      await page.locator('input[type="file"]').first().setInputFiles({
        name: "ev.pdf",
        mimeType: "application/pdf",
        buffer: Buffer.from("mock pdf content"),
      });

      // File chip now showing, button enabled.
      await expect(page.getByText("ev.pdf")).toBeVisible();
      await expect(page.getByRole("button", { name: "Attach Evidence" })).toBeEnabled();
    });

    test("should submit evidence successfully when a file is uploaded", async ({ page }) => {
      const homePage = new HomePage(page);
      const disputesOperations = new DisputesOperations(page);
      const dispute = sampleDispute({ connector: "stripe", dispute_status: "dispute_opened" });

      await enableEvidenceUploadFlag(page);

      // UploadEvidenceModal hits PUT /disputes/evidence (DISPUTES_ATTACH_EVIDENCE).
      // Stub it so the success path runs without a real backend.
      await page.route(/\/disputes\/evidence(\/|$)/, async (route) => {
        await route.fulfill({
          status: 200,
          contentType: "application/json",
          body: JSON.stringify({ dispute_id: dispute.dispute_id }),
        });
      });

      await openDisputeDetail(page, homePage, disputesOperations, dispute);
      await page.getByRole("button", { name: "Counter Dispute" }).click();

      await page.locator('input[type="file"]').first().setInputFiles({
        name: "evidence.pdf",
        mimeType: "application/pdf",
        buffer: Buffer.from("mock pdf content"),
      });

      const evidenceRequest = page.waitForRequest((req) => /\/disputes\/evidence(\/|$)/.test(req.url()));
      await page.getByRole("button", { name: "Attach Evidence" }).click();
      await evidenceRequest;
      // No error toast on success.
      await expect(page.getByText(/Failed to submit the evidence/)).not.toBeVisible();
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
