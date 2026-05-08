/**
 * Auto-generated Playwright test
 * Source: PR #4412 - fix: audit and fix user-facing text across the control center
 * Generated: 2026-05-08
 * Target: /dashboard/payments
 */

import { test, expect } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentOperations } from "../support/pages/operations/PaymentOperations";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("PR #4412 - Text Audit Verification - Payments Module", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");
  });

  // REVIEW: similar existing tests — consider updating instead of duplicating: "should display Payment Link Domain heading" (/Users/prajwal.nl/hcc-tmp/hcc-d0e9c6cc-c1a2-4d8f-ab3b-ffb5defdfee7/hyperswitch-control-center/playwright-tests/e2e/7-developers/PaymentSettings.spec.ts); "Payment Operations" (/Users/prajwal.nl/hcc-tmp/hcc-d0e9c6cc-c1a2-4d8f-ab3b-ffb5defdfee7/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts); "should verify all components in Payment Operations page when no payment exists" (/Users/prajwal.nl/hcc-tmp/hcc-d0e9c6cc-c1a2-4d8f-ab3b-ffb5defdfee7/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts)
  test("should display Payment Operations heading correctly", async ({
    page,
  }) => {
    await expect(page.getByText("Payment Operations")).toBeVisible();
  });

  // REVIEW: similar existing test — consider updating instead of duplicating: "should display form fields with correct labels" (/Users/prajwal.nl/hcc-tmp/hcc-d0e9c6cc-c1a2-4d8f-ab3b-ffb5defdfee7/hyperswitch-control-center/playwright-tests/e2e/7-developers/PaymentSettings.spec.ts)
  test("should render status filter tabs with correct labels", async ({
    page,
  }) => {
    // Fixed (Attempt 2): Use exact match to avoid strict mode violation with "All" text in other elements
    await expect(page.getByText("All", { exact: true })).toBeVisible();
    await expect(page.getByText("Succeeded")).toBeVisible();
    await expect(page.getByText("Failed", { exact: true })).toBeVisible();
    await expect(page.getByText("Dropoffs")).toBeVisible();
    await expect(page.getByText("Cancelled")).toBeVisible();
    await expect(page.getByText("Requires Capture")).toBeVisible();
  });

  test("should display Add Filters button with correct text", async ({
    page,
  }) => {
    await expect(page.getByText("Add Filters")).toBeVisible();
  });

  test("should show search input with correct placeholder text", async ({
    page,
  }) => {
    await expect(
      page.locator('input[placeholder="Search for payment ID"]'),
    ).toBeVisible();
  });

  test("should display empty state message when no payments exist", async ({
    page,
  }) => {
    await expect(page.getByText("No results found")).toBeVisible();
  });

  // REVIEW: similar existing test — consider updating instead of duplicating: "should display a valid message and expand search timerange when searched with invalid payment ID" (/Users/prajwal.nl/hcc-tmp/hcc-d0e9c6cc-c1a2-4d8f-ab3b-ffb5defdfee7/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts)
  test("should show expand search button with correct label", async ({
    page,
  }) => {
    await expect(
      page.getByText("Expand the search to the previous 90 days"),
    ).toBeVisible();
  });

  // REVIEW: similar existing test — consider updating instead of duplicating: "should verify all time range filters are displayed in date selector dropdown" (/Users/prajwal.nl/hcc-tmp/hcc-d0e9c6cc-c1a2-4d8f-ab3b-ffb5defdfee7/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts)
  test("should render date range selector component", async ({ page }) => {
    await expect(
      page.locator('[data-testid="date-range-selector"]'),
    ).toBeVisible();
  });

  // REVIEW: similar existing tests — consider updating instead of duplicating: "should verify sidebar menu navigation - overview and operations" (/Users/prajwal.nl/hcc-tmp/hcc-d0e9c6cc-c1a2-4d8f-ab3b-ffb5defdfee7/hyperswitch-control-center/playwright-tests/e2e/2-homepage/homepage.spec.ts); "should verify sidebar menu navigation - connectors" (/Users/prajwal.nl/hcc-tmp/hcc-d0e9c6cc-c1a2-4d8f-ab3b-ffb5defdfee7/hyperswitch-control-center/playwright-tests/e2e/2-homepage/homepage.spec.ts); "should verify sidebar menu navigation - analytics and workflow" (/Users/prajwal.nl/hcc-tmp/hcc-d0e9c6cc-c1a2-4d8f-ab3b-ffb5defdfee7/hyperswitch-control-center/playwright-tests/e2e/2-homepage/homepage.spec.ts)
  test("should highlight Payments menu item in sidebar navigation", async ({
    page,
  }) => {
    await expect(page.locator('[data-testid="payments"]')).toBeVisible();
  });

  // Fixed (Attempt 2): Column headers are only visible when payments exist or in column customization modal
  // These tests verify the column names exist in the column customization dropdown
  test("should display column headers with correct text in customization modal", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    const paymentOperations = new PaymentOperations(page);

    await homePage.operations.click();
    await homePage.paymentOperations.click();
    await paymentOperations.columnButton.click();

    // Verify all column headers are present in the customization modal
    await expect(page.getByText("Profile ID")).toBeVisible();
    await expect(page.getByText("Merchant Order Reference ID")).toBeVisible();
    await expect(page.getByText("Amount Capturable")).toBeVisible();
    await expect(page.getByText("Attempt Count")).toBeVisible();
    await expect(page.getByText("Payment ID")).toBeVisible();
    await expect(page.getByText("Connector Transaction ID")).toBeVisible();
    await expect(page.getByText("Customer ID")).toBeVisible();
  });
});
