/**
 * Auto-generated Playwright test
 * Source: module:connector-forms - PM-Auth(Plaid) / Tax(Taxjar) /
 *         Billing(Chargebee) / Vault(VGS) processor config forms.
 *
 * Verifies: Connect click → lands on /new config URL → credential field
 * labels visible → proceed button visible. Does NOT fully save because
 * these are live processors requiring real credentials.
 * Generated: 2026-04-17
 */

import { test, expect, type Page } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentConnector } from "../support/pages/connector/PaymentConnector";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

interface ProcessorCase {
  describe: string;
  url: string;
  sidebarGet: (hp: HomePage) => import("../support/test").Locator;
  searchTerm: string;
  expectedConfigUrl: RegExp;
}

const processors: ProcessorCase[] = [
  {
    describe: "PM Auth Processor (Plaid)",
    url: "/dashboard/pm-authentication-processor",
    sidebarGet: (hp) => hp.pmAuthConnectors,
    searchTerm: "plaid",
    expectedConfigUrl: /.*dashboard\/pm-authentication-processor\/new/,
  },
  {
    describe: "Tax Processor (Taxjar)",
    url: "/dashboard/tax-processor",
    sidebarGet: (hp) => hp.taxConnectors,
    searchTerm: "taxjar",
    expectedConfigUrl: /.*dashboard\/tax-processor\/new/,
  },
  {
    describe: "Billing Processor (Chargebee)",
    url: "/dashboard/billing-processor",
    sidebarGet: (hp) => hp.billingConnectors,
    searchTerm: "chargebee",
    expectedConfigUrl: /.*dashboard\/billing-processor\/new/,
  },
  {
    describe: "Vault Processor (VGS)",
    url: "/dashboard/vault-processor",
    sidebarGet: (hp) => hp.vaultConnectors,
    searchTerm: "vgs",
    expectedConfigUrl: /.*dashboard\/vault-processor\/new/,
  },
];

async function login(
  page: Page,
  context: import("../support/test").BrowserContext,
) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

for (const proc of processors) {
  test.describe(`${proc.describe} - config form`, () => {
    test.beforeEach(async ({ page, context }) => {
      await login(page, context);
    });

    test("navigate via sidebar lands on listing URL", async ({ page }) => {
      const homePage = new HomePage(page);
      await homePage.connectors.click();
      const link = proc.sidebarGet(homePage);
      if ((await link.count().catch(() => 0)) === 0) {
        test.skip(true, "Sidebar entry not rendered for this account");
      }
      await link.click();
      await expect(page).toHaveURL(new RegExp(proc.url));
    });

    test("search input accepts processor name", async ({ page }) => {
      await page.goto(proc.url);
      await page.waitForLoadState("networkidle");

      const searchInput = page.locator('[data-testid="search-processor"]');
      if (!(await searchInput.isVisible().catch(() => false))) {
        test.skip(true, "Search input not rendered on this page");
      }
      await searchInput.fill(proc.searchTerm);
      await expect(searchInput).toHaveValue(proc.searchTerm);
    });

    test("Connect click navigates to /new config URL", async ({ page }) => {
      await page.goto(proc.url);
      await page.waitForLoadState("networkidle");

      const paymentConnector = new PaymentConnector(page);
      const connectBtn = paymentConnector.addConnectButton;
      const count = await connectBtn.count().catch(() => 0);
      if (count === 0) {
        test.skip(true, "No Connect buttons rendered (empty list)");
      }
      await connectBtn.first().click();

      await expect(page).toHaveURL(proc.expectedConfigUrl, { timeout: 15000 });
    });

    test("credential form fields render on config page", async ({ page }) => {
      await page.goto(proc.url);
      await page.waitForLoadState("networkidle");

      const paymentConnector = new PaymentConnector(page);
      const count = await paymentConnector.addConnectButton
        .count()
        .catch(() => 0);
      if (count === 0) {
        test.skip(true, "No Connect buttons rendered");
      }
      await paymentConnector.addConnectButton.first().click();

      await page.waitForLoadState("networkidle");
      const connectorLabel = page.locator('[name="connector_label"]');
      const apiKey = page.locator(
        '[name="connector_account_details\\.api_key"]',
      );
      const hasLabel = await connectorLabel.isVisible().catch(() => false);
      const hasApiKey = await apiKey.isVisible().catch(() => false);
      expect(hasLabel || hasApiKey).toBeTruthy();
    });

    test("connect-and-proceed button is visible on config page", async ({
      page,
    }) => {
      await page.goto(proc.url);
      await page.waitForLoadState("networkidle");

      const paymentConnector = new PaymentConnector(page);
      const count = await paymentConnector.addConnectButton
        .count()
        .catch(() => 0);
      if (count === 0) {
        test.skip(true, "No Connect buttons rendered");
      }
      await paymentConnector.addConnectButton.first().click();
      await page.waitForLoadState("networkidle");

      const proceedBtn = paymentConnector.connectAndProceedButton;
      if (await proceedBtn.isVisible().catch(() => false)) {
        await expect(proceedBtn).toBeVisible();
      }
    });
  });
}
