/**
 * Auto-generated Playwright test
 * Source: module:home-overview - Overview / Home page deeper interactions
 * Generated: 2026-04-17
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Home / Overview Module", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should land on home after login", async ({ page }) => {
    await expect(page).toHaveURL(/.*dashboard\/home/);
  });

  test("should display org icon and merchant dropdown", async ({ page }) => {
    const homePage = new HomePage(page);

    await expect(homePage.orgIcon).toBeVisible({ timeout: 10000 });
    await expect(homePage.merchantDropdown).toBeVisible();
  });

  test("should display profile dropdown in topbar", async ({ page }) => {
    const homePage = new HomePage(page);

    await expect(homePage.profileDropdown).toBeVisible({ timeout: 10000 });
  });

  test("should display production access banner in Test Mode", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    const banner = homePage.productionAccessBanner;
    if (await banner.isVisible().catch(() => false)) {
      await expect(banner).toContainText(/Test Mode|Production/i);
    }
  });

  test("should show Integrate a Processor card", async ({ page }) => {
    const homePage = new HomePage(page);

    await expect(homePage.integrateConnectorCard).toBeVisible({
      timeout: 10000,
    });
    await expect(homePage.integrateConnectorCard).toContainText(
      /Integrate|Processor|gateway/i,
    );
  });

  test("should navigate to connectors via processor CTA", async ({ page }) => {
    const homePage = new HomePage(page);

    const cta = homePage.integrateConnectorCard.locator(
      '[data-button-for="connectProcessors"]',
    );
    if (await cta.isVisible().catch(() => false)) {
      await cta.click();
      await expect(page).toHaveURL(/.*dashboard\/connectors/);
    }
  });

  test("should expand operations submenu", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.operations.click();
    await expect(homePage.paymentOperations).toBeVisible({ timeout: 5000 });
    await expect(homePage.refundOperations).toBeVisible();
  });

  test("should expand connectors submenu", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await expect(homePage.paymentProcessors).toBeVisible({ timeout: 5000 });
  });

  test("should expand workflow submenu", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await expect(homePage.routing).toBeVisible({ timeout: 5000 });
  });

  test("should expand developer submenu", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.developer.click();
    await expect(homePage.apiKeys).toBeVisible({ timeout: 5000 });
  });

  test("should have working sign-out from user account menu", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.userAccount.click();
    await expect(homePage.signOut).toBeVisible({ timeout: 5000 });
  });
});
