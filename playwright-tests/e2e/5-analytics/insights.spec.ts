import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { InsightsPaymentsPage } from "../../support/pages/analytics/InsightsPaymentsPage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

// Signs up a fresh org, force-enables the new_analytics feature flag, logs in
// and opens the New Analytics > Insights (Payments tab) page.
async function loginAndVisit(page: Page): Promise<InsightsPaymentsPage> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);

  await page.route("**/dashboard/config/feature*", async (route) => {
    const response = await route.fetch();
    const json = await response.json();
    if (json && json.features) {
      json.features.new_analytics = true;
      json.features.new_analytics_smart_retries = true;
      json.features.new_analytics_refunds = true;
      json.features.sample_data_analytics = true;
    }
    await route.fulfill({ response, json });
  });

  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

  const insights = new InsightsPaymentsPage(page);
  await insights.visit();
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(1000);
  return insights;
}

test.describe("New Analytics - Insights Payments", () => {
  let insights: InsightsPaymentsPage;

  test.beforeEach(async ({ page }) => {
    insights = await loginAndVisit(page);
  });

  test("should load the Insights page with the Payments tab active", async () => {
    await expect(insights.pageHeading).toBeVisible({ timeout: 10000 });
    await expect(insights.paymentsTab).toBeVisible({ timeout: 10000 });
    await expect(insights.smartRetriesTab).toBeVisible({ timeout: 10000 });
    await expect(insights.refundsTab).toBeVisible({ timeout: 10000 });

    await expect(insights.totalPaymentSavingsCard).toBeVisible({ timeout: 10000 });
    await expect(insights.authorizationRateCard).toBeVisible({ timeout: 15000 });
    await expect(insights.paymentsProcessedCard).toBeVisible({ timeout: 15000 });
    await expect(insights.authorisedUncapturedCard).toBeVisible({ timeout: 15000 });
    await expect(insights.refundsProcessedCard).toBeVisible({ timeout: 15000 });
    await expect(insights.disputesCard).toBeVisible({ timeout: 15000 });

    await expect(insights.paymentsLifecycleHeading).toBeVisible({ timeout: 15000 });
    await expect(insights.paymentsProcessedHeading).toBeVisible({ timeout: 15000 });
    await expect(insights.paymentsSuccessRateHeading).toBeVisible({ timeout: 15000 });
    await expect(insights.successfulPaymentsDistributionHeading).toBeVisible({ timeout: 15000 });
    await expect(insights.failedPaymentsDistributionHeading).toBeVisible({ timeout: 15000 });
    await expect(insights.failureReasonsHeading).toBeVisible({ timeout: 15000 });
  });

});

test.describe("New Analytics - Insights Payments - Feature Flag", () => {
  test("should fall back to the unauthorized view when new_analytics is disabled", async ({
    page,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json && json.features) {
        json.features.new_analytics = false;
      }
      await route.fulfill({ response, json });
    });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

    const insights = new InsightsPaymentsPage(page);
    await insights.visit();
    await page.waitForLoadState("networkidle");

    await expect(insights.goToHomeButton).toBeVisible({ timeout: 10000 });
  });
});
