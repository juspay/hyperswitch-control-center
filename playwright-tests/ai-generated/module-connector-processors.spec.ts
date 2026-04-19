/**
 * Auto-generated Playwright test
 * Source: module:connector-processors - PM Auth, Tax, Billing, Vault processors
 * Generated: 2026-04-17
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

async function signupAndLogin(
  page: import("../support/test").Page,
  context: import("../support/test").BrowserContext,
) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

test.describe("PM Auth Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should navigate to PM Auth Processor if enabled", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    const link = homePage.pmAuthConnectors;
    if ((await link.count().catch(() => 0)) > 0) {
      await link.click();
      await expect(page).toHaveURL(/.*dashboard\/pm-authentication-processor/);
    }
  });

  test("should render PM Auth Processor heading if reachable", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    const link = homePage.pmAuthConnectors;
    if ((await link.count().catch(() => 0)) > 0) {
      await link.click();
      await page.waitForLoadState("networkidle");
      await expect(
        page.getByText(/PM Auth|Authentication|Processor/i).first(),
      ).toBeVisible({ timeout: 10000 });
    }
  });
});

test.describe("Tax Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should navigate to Tax Processor if enabled", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    const link = homePage.taxConnectors;
    if ((await link.count().catch(() => 0)) > 0) {
      await link.click();
      await expect(page).toHaveURL(/.*dashboard\/tax-processor/);
    }
  });

  test("should render Tax Processor heading if reachable", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    const link = homePage.taxConnectors;
    if ((await link.count().catch(() => 0)) > 0) {
      await link.click();
      await page.waitForLoadState("networkidle");
      await expect(page.getByText(/Tax|Processor/i).first()).toBeVisible({
        timeout: 10000,
      });
    }
  });
});

test.describe("Billing Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should navigate to Billing Processor if enabled", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    const link = homePage.billingConnectors;
    if ((await link.count().catch(() => 0)) > 0) {
      await link.click();
      await expect(page).toHaveURL(/.*dashboard\/billing-processor/);
    }
  });

  test("should render Billing Processor heading if reachable", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    const link = homePage.billingConnectors;
    if ((await link.count().catch(() => 0)) > 0) {
      await link.click();
      await page.waitForLoadState("networkidle");
      await expect(page.getByText(/Billing|Processor/i).first()).toBeVisible({
        timeout: 10000,
      });
    }
  });
});

test.describe("Vault Processor", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should navigate to Vault Processor if enabled", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    const link = homePage.vaultConnectors;
    if ((await link.count().catch(() => 0)) > 0) {
      await link.click();
      await expect(page).toHaveURL(/.*dashboard\/vault-processor/);
    }
  });

  test("should render Vault Processor heading if reachable", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    const link = homePage.vaultConnectors;
    if ((await link.count().catch(() => 0)) > 0) {
      await link.click();
      await page.waitForLoadState("networkidle");
      await expect(page.getByText(/Vault|Processor/i).first()).toBeVisible({
        timeout: 10000,
      });
    }
  });
});
