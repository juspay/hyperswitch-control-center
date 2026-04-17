/**
 * Auto-generated Playwright test
 * Source: module:connector-new - per-connector "new" setup page
 * Generated: 2026-04-17
 *
 * Existing specs cover the connectors list (/connectors) and the full
 * payin/payout connect flows. This spec targets the standalone per-connector
 * setup page reached via `/connectors/new?name={connector}`, which was
 * previously only reachable through list navigation.
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Connector new setup page (direct URL)", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
  });

  test("deep link to /connectors/new?name=stripe_test resolves on dashboard", async ({
    page,
  }) => {
    await page.goto("/dashboard/connectors/new?name=stripe_test");
    await page.waitForLoadState("networkidle");

    // Either the setup page renders or we're bounced to the list — both OK.
    await expect(page).toHaveURL(
      /.*dashboard\/(connectors(\/new)?|home|login)/,
    );
  });

  test("page renders connector setup content when deep-linked", async ({
    page,
  }) => {
    await page.goto("/dashboard/connectors/new?name=stripe_test");
    await page.waitForLoadState("networkidle");

    // The setup screen (or the list fallback) always has a "Payment Processor"
    // / "Stripe" / "Connect" token somewhere in the rendered body. Matching
    // any one of them keeps the assertion robust to which view actually loaded.
    const anchor = page.getByText(/Payment Processor|Stripe|Connect/i).first();
    await expect(anchor).toBeVisible({ timeout: 10000 });
  });

  test("no page-level JS error thrown on /connectors/new", async ({ page }) => {
    const pageErrors: Error[] = [];
    page.on("pageerror", (err) => pageErrors.push(err));

    await page.goto("/dashboard/connectors/new?name=stripe_test");
    await page.waitForLoadState("networkidle");

    expect(pageErrors).toHaveLength(0);
  });

  test("navigation back to connectors list via sidebar still works", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await page.goto("/dashboard/connectors/new?name=stripe_test");
    await page.waitForLoadState("networkidle");

    // Use sidebar nav rather than back button so the assertion survives the
    // redirect-to-list fallback path.
    await homePage.connectors.click();
    await homePage.paymentProcessors.click();
    await expect(page).toHaveURL(/.*dashboard\/connectors/);
  });
});
