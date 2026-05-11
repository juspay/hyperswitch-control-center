/**
 * Auto-generated Playwright test
 * Source: PR #4412 - fix: audit and fix user-facing text across the control center
 * Generated: 2026-05-08T04:52:00Z
 */

import { test, expect } from "@playwright/test";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
  ompLineage,
} from "../support/commands";
import { generateUniqueEmail } from "../support/helper";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("PR #4412 - Text Audit and Fixes", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  // REVIEW: similar existing tests — consider updating instead of duplicating: "should display Payment Link Domain heading" (/Users/prajwal.nl/hcc-tmp/hcc-7693de37-c998-40f5-98cd-79d24a84f90e/hyperswitch-control-center/playwright-tests/e2e/7-developers/PaymentSettings.spec.ts); "Payment Operations" (/Users/prajwal.nl/hcc-tmp/hcc-7693de37-c998-40f5-98cd-79d24a84f90e/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts); "should verify all components in Payment Operations page when no payment exists" (/Users/prajwal.nl/hcc-tmp/hcc-7693de37-c998-40f5-98cd-79d24a84f90e/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts)
  test("should display Payment Operations heading with correct text", async ({
    page,
  }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    const heading = page.getByRole("heading", { name: "Payment Operations" });
    await expect(heading).toBeVisible();
  });

  test("should display Profile ID column header with correct casing", async ({
    page,
  }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    const profileIdHeader = page.getByText("Profile ID", { exact: true });
    await expect(profileIdHeader).toBeVisible();
  });

  test("should display Merchant Order Reference ID column header with correct casing", async ({
    page,
  }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    const merchantOrderRefHeader = page.getByText(
      "Merchant Order Reference ID",
      {
        exact: true,
      },
    );
    await expect(merchantOrderRefHeader).toBeVisible();
  });

  test("should display Amount Capturable column header with proper spacing", async ({
    page,
  }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    const amountCapturableHeader = page.getByText("Amount Capturable", {
      exact: true,
    });
    await expect(amountCapturableHeader).toBeVisible();
  });

  test("should display Attempt Count column header with correct capitalization", async ({
    page,
  }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    const attemptCountHeader = page.getByText("Attempt Count", { exact: true });
    await expect(attemptCountHeader).toBeVisible();
  });

  test("should display homepage welcome text with American spelling", async ({
    page,
  }) => {
    await page.goto("/dashboard/home");
    await page.waitForLoadState("networkidle");

    const welcomeText = page.getByText("Control Center", { exact: false });
    await expect(welcomeText).toBeVisible();

    const aimsText = page.getByText("aims to provide", { exact: false });
    await expect(aimsText).toBeVisible();
  });

  test("should display integrate connector card with correct text", async ({
    page,
  }) => {
    await page.goto("/dashboard/home");
    await page.waitForLoadState("networkidle");

    const headStartText = page.getByText("head start", { exact: false });
    await expect(headStartText).toBeVisible();
  });

  test("should show success toast with proper grammar when creating routing configuration", async ({
    page,
    context,
  }) => {
    const { merchantId } = await ompLineage(page);
    await createDummyConnectorAPI(
      merchantId,
      "stripe_test_routing",
      context.request,
    );

    await page.goto("/dashboard/routing");
    await page.waitForLoadState("networkidle");

    await page.getByRole("button", { name: "Create New Config" }).click();
    await page.waitForLoadState("networkidle");

    const configNameInput = page.locator('input[name="configName"]');
    await configNameInput.fill("Test Config");

    await page.getByRole("button", { name: "Save Rule" }).click();

    const successToast = page.locator(
      '[data-toast="Successfully created a new configuration!"]',
    );
    await expect(successToast).toBeVisible({ timeout: 10000 });
  });

  // REVIEW: similar existing tests — consider updating instead of duplicating: "should display an error message for an invalid email" (/Users/prajwal.nl/hcc-tmp/hcc-7693de37-c998-40f5-98cd-79d24a84f90e/hyperswitch-control-center/playwright-tests/e2e/1-auth/auth.spec.ts); "should display an error message with invalid credentials" (/Users/prajwal.nl/hcc-tmp/hcc-7693de37-c998-40f5-98cd-79d24a84f90e/hyperswitch-control-center/playwright-tests/e2e/1-auth/auth.spec.ts); "should display error message with invalid TOTP in 2FA page" (/Users/prajwal.nl/hcc-tmp/hcc-7693de37-c998-40f5-98cd-79d24a84f90e/hyperswitch-control-center/playwright-tests/e2e/1-auth/auth.spec.ts)
  test("should display fallback connector error message with correct grammar", async ({
    page,
  }) => {
    await page.goto("/dashboard/routing");
    await page.waitForLoadState("networkidle");

    await page.getByRole("button", { name: "Manage Default Fallback" }).click();

    const atLeastText = page.getByText("at least", { exact: false });
    await expect(atLeastText).toBeVisible();
  });

  test("should display 2FA recovery code text with correct article usage", async ({
    page,
  }) => {
    await page.goto("/dashboard/login");
    await page.waitForLoadState("networkidle");

    const emailInput = page.getByPlaceholder("Enter your Email");
    const passwordInput = page.getByPlaceholder("Enter your Password");

    await emailInput.fill("test@example.com");
    await passwordInput.fill("password123");

    await page.getByRole("button", { name: "Continue" }).click();
    await page.waitForLoadState("networkidle");

    const useRecoveryCodeLink = page.getByText("Use recovery code");
    await useRecoveryCodeLink.click();

    const eightDigitText = page.getByText("an 8-digit recovery code", {
      exact: false,
    });
    await expect(eightDigitText).toBeVisible();
  });

  // REVIEW: similar existing test — consider updating instead of duplicating: "should display correct payment when searched with payment ID" (/Users/prajwal.nl/hcc-tmp/hcc-7693de37-c998-40f5-98cd-79d24a84f90e/hyperswitch-control-center/playwright-tests/e2e/3-operations/paymentOperations.spec.ts)
  test("should display Payment ID column header in refunds with correct casing", async ({
    page,
  }) => {
    await page.goto("/dashboard/payments");
    await page.waitForLoadState("networkidle");

    await page.getByTestId("refunds").click();
    await page.waitForLoadState("networkidle");

    const paymentIdHeader = page.getByText("Payment ID", { exact: true });
    await expect(paymentIdHeader).toBeVisible();
  });
});
