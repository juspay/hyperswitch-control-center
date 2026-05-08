/**
 * Auto-generated Playwright test
 * Source: PR #4412 - fix: audit and fix user-facing text across the control center
 * Generated: 2026-05-08T05:16:16Z
 */

import { test, expect } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("PR #4412 - Text Audit Verification - Payments Module", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");
  });

  // REVIEW: similar existing tests — consider updating instead of duplicating: "should verify all components in Payment Operations page when no payment exists" (/Users/prajwal.nl/hcc-tmp/hcc-8a057325-014a-4431-a464-7ec81142b8f5/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts); "should verify all components in Payment Operations page when a payment exists" (/Users/prajwal.nl/hcc-tmp/hcc-8a057325-014a-4431-a464-7ec81142b8f5/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts); "should display Payment Link Domain heading" (/Users/prajwal.nl/hcc-tmp/hcc-8a057325-014a-4431-a464-7ec81142b8f5/hyperswitch-control-center/playwright-tests/e2e/7-developers/PaymentSettings.spec.ts)
  test("Verify Payment Operations page heading renders correctly", async ({
    page,
  }) => {
    await expect(page.getByText("Payment Operations")).toBeVisible();
    await expect(page).toHaveTitle(/Payments/);
  });

  // REVIEW: similar existing test — consider updating instead of duplicating: "should verify applied custom timerange is displayed correctly" (/Users/prajwal.nl/hcc-tmp/hcc-8a057325-014a-4431-a464-7ec81142b8f5/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts)
  test("Verify empty state messaging displays correctly", async ({ page }) => {
    await expect(page.getByText("No results found")).toBeVisible();
    await expect(
      page.getByText("Expand the search to the previous 90 days"),
    ).toBeVisible();
  });

  // REVIEW: similar existing tests — consider updating instead of duplicating: "should display form fields with correct labels" (/Users/prajwal.nl/hcc-tmp/hcc-8a057325-014a-4431-a464-7ec81142b8f5/hyperswitch-control-center/playwright-tests/e2e/7-developers/PaymentSettings.spec.ts); "should verify filter dropdown contains all filters" (/Users/prajwal.nl/hcc-tmp/hcc-8a057325-014a-4431-a464-7ec81142b8f5/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts); "should verify all transaction filter views are displayed" (/Users/prajwal.nl/hcc-tmp/hcc-8a057325-014a-4431-a464-7ec81142b8f5/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts)
  test("Verify filter panel uses correct text casing for ID fields", async ({
    page,
  }) => {
    await page.getByRole("button", { name: "Add Filters" }).click();
    await expect(page.getByText("Customer ID")).toBeVisible();
    await expect(page.getByText("Merchant Order Reference ID")).toBeVisible();
  });

  // REVIEW: similar existing test — consider updating instead of duplicating: "should display form fields with correct labels" (/Users/prajwal.nl/hcc-tmp/hcc-8a057325-014a-4431-a464-7ec81142b8f5/hyperswitch-control-center/playwright-tests/e2e/7-developers/PaymentSettings.spec.ts)
  // Fixed (Attempt 3): Scope selectors to the tabs container to avoid matching hidden elements
  test("Verify status tabs display with correct labels", async ({ page }) => {
    // Wait for the payment operations section to load
    await page.waitForSelector("text=Payment Operations");
    // Locate the tabs container first, then find text within it to avoid hidden elements
    const tabsContainer = page.locator(
      '.grid.lg\\:grid-cols-5, [class*="grid-cols-5"]',
    );
    await expect(tabsContainer.getByText("All")).toBeVisible();
    await expect(tabsContainer.getByText("Succeeded")).toBeVisible();
    await expect(tabsContainer.getByText("Failed")).toBeVisible();
    await expect(tabsContainer.getByText("Dropoffs")).toBeVisible();
    await expect(tabsContainer.getByText("Cancelled")).toBeVisible();
    await expect(tabsContainer.getByText("Requires Capture")).toBeVisible();
  });

  // REVIEW: similar existing tests — consider updating instead of duplicating: "should verify all time range filters are displayed in date selector dropdown" (/Users/prajwal.nl/hcc-tmp/hcc-8a057325-014a-4431-a464-7ec81142b8f5/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts); "should verify applied custom timerange is displayed correctly" (/Users/prajwal.nl/hcc-tmp/hcc-8a057325-014a-4431-a464-7ec81142b8f5/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts)
  test("Verify date range selector displays correctly", async ({ page }) => {
    await expect(page.getByTestId("date-range-selector")).toBeVisible();
    await expect(page.getByText("View data for:")).toBeVisible();
  });

  test("Verify search input placeholder text", async ({ page }) => {
    const searchInput = page.getByPlaceholder(/Search for payment ID/);
    await expect(searchInput).toBeVisible();
  });
});
