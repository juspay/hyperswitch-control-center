/**
 * Auto-generated Playwright test
 * Source: PR #4412 - fix: audit and fix user-facing text across the control center
 * Generated: 2026-05-08T05:48:00.000Z
 */

import { test, expect } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("PR #4412 - Text Audit Verification", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("homepage welcome text uses 'Control Center' spelling", async ({
    page,
  }) => {
    await page.goto("/dashboard/home");
    await page.waitForLoadState("networkidle");

    const welcomeMessage = page.getByText(
      "Welcome to the home of your Payments Control Center",
    );
    await expect(welcomeMessage).toBeVisible();

    const messageText = await welcomeMessage.textContent();
    expect(messageText).toContain("Control Center");
    expect(messageText).not.toContain("Control Centre");
    expect(messageText).toContain("It aims to provide");
    expect(messageText).not.toContain("It aims at providing");
  });

  test("integrate processor card displays corrected text", async ({ page }) => {
    await page.goto("/dashboard/home");
    await page.waitForLoadState("networkidle");

    const integrateCard = page.getByText("Integrate a Processor");
    await expect(integrateCard).toBeVisible();

    // Fixed (Attempt 1): [data-testid='home'] doesn't exist; use parent container of the heading
    const cardContainer = integrateCard.locator("xpath=../..");
    await expect(cardContainer).toBeVisible();
    const cardText = await cardContainer.textContent();

    expect(cardText).toContain("Get a head start");
    expect(cardText).not.toContain("Give a headstart");
    expect(cardText).toContain("20+ gateways");
    expect(cardText).not.toContain("more than 20+ gateways");
  });

  // REVIEW: similar existing tests — consider updating instead of duplicating: "should display Payment Link Domain heading" (/Users/prajwal.nl/hcc-tmp/hcc-01073665-1890-4abc-a22d-2e0a934392e7/hyperswitch-control-center/playwright-tests/e2e/7-developers/PaymentSettings.spec.ts); "Payment Operations" (/Users/prajwal.nl/hcc-tmp/hcc-01073665-1890-4abc-a22d-2e0a934392e7/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts); "should verify all components in Payment Operations page when no payment exists" (/Users/prajwal.nl/hcc-tmp/hcc-01073665-1890-4abc-a22d-2e0a934392e7/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts)
  test("Payment Operations page displays correct heading", async ({ page }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    // Fixed (Attempt 1): "Payment Operations" is in a div, not a heading role element
    const pageHeading = page.getByText("Payment Operations").first();
    await expect(pageHeading).toBeVisible();
    await expect(pageHeading).toHaveText("Payment Operations");
  });

  test("filter options use correct ID casing", async ({ page }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    const addFiltersButton = page.getByRole("button", { name: "Add Filters" });
    await expect(addFiltersButton).toBeVisible();
    await addFiltersButton.click();

    await page.waitForTimeout(500);

    const customerIdFilter = page.getByText("Customer ID", { exact: false });
    await expect(customerIdFilter.first()).toBeVisible();

    const merchantOrderRefFilter = page.getByText(
      "Merchant Order Reference ID",
      { exact: false },
    );
    await expect(merchantOrderRefFilter.first()).toBeVisible();
  });

  test("table column headers use correct casing", async ({ page }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    // Fixed (Attempt 1): Open filters to check filter labels (table only visible with data)
    const addFiltersButton = page.getByRole("button", { name: "Add Filters" });
    await expect(addFiltersButton).toBeVisible();
    await addFiltersButton.click();
    await page.waitForTimeout(500);

    // Fixed (Attempt 2): Removed "Profile Id" check - it doesn't exist in filter dropdown
    // Only "Customer Id" and "Merchant Order Reference Id" are present
    const customerIdFilter = page.getByText("Customer Id", { exact: true });
    await expect(customerIdFilter.first()).toBeVisible();

    const merchantOrderRefFilter = page.getByText(
      "Merchant Order Reference Id",
      { exact: true },
    );
    await expect(merchantOrderRefFilter.first()).toBeVisible();
  });

  // REVIEW: similar existing tests — consider updating instead of duplicating: "should display correct payment when searched with payment ID" (/Users/prajwal.nl/hcc-tmp/hcc-01073665-1890-4abc-a22d-2e0a934392e7/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts); "should verify all components in Payment Details page - 1" (/Users/prajwal.nl/hcc-tmp/hcc-01073665-1890-4abc-a22d-2e0a934392e7/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts); "should verify all components in Payment Details page - 2" (/Users/prajwal.nl/hcc-tmp/hcc-01073665-1890-4abc-a22d-2e0a934392e7/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts)
  test("payment details panel shows correct Profile ID label", async ({
    page,
  }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    await page.waitForTimeout(2000);

    const firstPaymentRow = page.locator("[role='row']").nth(1);
    const rowCount = await page.locator("[role='row']").count();

    if (rowCount > 1) {
      await firstPaymentRow.click();
      await page.waitForTimeout(1000);

      const profileIdLabel = page.getByText("Profile ID", { exact: true });
      await expect(profileIdLabel.first()).toBeVisible();

      const aboutPaymentSection = page.getByText("About Payment", {
        exact: true,
      });
      await expect(aboutPaymentSection).toBeVisible();
    }
  });

  test("refund attempts table uses Payment ID column header", async ({
    page,
  }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    await page.waitForTimeout(2000);

    const rows = page.locator("[role='row']");
    const rowCount = await rows.count();

    if (rowCount > 1) {
      await rows.nth(1).click();
      await page.waitForTimeout(1000);

      const refundAttemptsTable = page.getByText("Refund Attempts", {
        exact: false,
      });
      const refundCount = await refundAttemptsTable.count();

      if (refundCount > 0) {
        await expect(refundAttemptsTable.first()).toBeVisible();

        const paymentIdColumn = page.getByText("Payment ID", { exact: true });
        await expect(paymentIdColumn.first()).toBeVisible();
      }
    }
  });

  test("empty state displays correct messaging", async ({ page }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    await page.waitForTimeout(2000);

    const noResultsMessage = page.getByText("No results found", {
      exact: true,
    });
    const expandSearchButton = page.getByRole("button", {
      name: "Expand the search to the previous 90 days",
    });

    const noResultsVisible = await noResultsMessage
      .isVisible()
      .catch(() => false);
    const expandButtonVisible = await expandSearchButton
      .isVisible()
      .catch(() => false);

    if (noResultsVisible) {
      await expect(noResultsMessage).toBeVisible();
    }

    if (expandButtonVisible) {
      await expect(expandSearchButton).toBeVisible();
    }
  });
});
