/**
 * Auto-generated Playwright test
 * Source: module: homepage validation
 * Generated: 2026-03-23
 */

import { test, expect } from "@playwright/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { SignInPage } from "../support/pages/auth/SignInPage";
import { signupUser } from "../support/commands";
import { generateUniqueEmail } from "../support/helper";

test.describe("Homepage Validation", () => {
  let testEmail: string;
  const testPassword = process.env.TEST_PASSWORD || "Test@123";

  test.beforeEach(async ({ page }) => {
    testEmail = generateUniqueEmail();
    await signupUser(testEmail, testPassword);

    const signInPage = new SignInPage(page);
    await page.goto("/dashboard/login");
    await signInPage.emailInput.fill(testEmail);
    await signInPage.passwordInput.fill(testPassword);
    await signInPage.signinButton.click();

    const skip2FAButton = page.locator('[data-testid="skip-now"]');
    await skip2FAButton.waitFor({ state: "visible", timeout: 10000 });
    await skip2FAButton.click();

    await expect(page).toHaveURL(/.*dashboard\/home/, { timeout: 10000 });
  });

  test("Homepage displays all navigation elements after login", async ({
    page,
  }) => {
    await expect(page.getByText("Overview")).toBeVisible();
    await expect(page.getByText("Operations")).toBeVisible();
    await expect(page.getByText("Connectors")).toBeVisible();
    await expect(page.getByText("Analytics")).toBeVisible();
    await expect(page.getByText("Workflow")).toBeVisible();
    await expect(page.getByText("Reconciliation")).toBeVisible();
    await expect(
      page.getByTestId("developers").getByText("Developers"),
    ).toBeVisible();
    await expect(page.getByText("Settings")).toBeVisible();
  });

  test("Homepage shows quick action cards for new users", async ({ page }) => {
    await expect(page.getByText("Integrate a Processor")).toBeVisible();
    await expect(page.getByText("Connect Processors")).toBeVisible();
    await expect(page.getByText("Demo our checkout experience")).toBeVisible();
    await expect(page.getByText("Try It Out")).toBeVisible();
  });

  test("User can access profile dropdown from homepage", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.userAccount.click();
    await expect(homePage.signOut).toBeVisible();
  });

  test("Navigation menu items redirect to correct pages", async ({ page }) => {
    await page.getByText("Connectors").click();
    await page.getByText("Payment Processors").click();
    await expect(page).toHaveURL(/.*dashboard\/connectors/);

    await page.goto("/dashboard/home");
    await expect(page).toHaveURL(/.*dashboard\/home/);
  });

  test("Homepage displays merchant information in header", async ({ page }) => {
    const homePage = new HomePage(page);

    await expect(homePage.merchantDropdown).toBeVisible();
    await expect(homePage.orgChartIcon).toBeVisible();
  });
});
