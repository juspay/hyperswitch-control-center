import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

async function setup(page: Page, context: BrowserContext): Promise<void> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
}

async function gotoAnalytics(page: Page, route: string): Promise<boolean> {
  await page.goto(`/dashboard/${route}`);
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(1500);
  const fallback = page.getByText("Go to Home", { exact: true }).first();
  return !(await fallback.isVisible().catch(() => false));
}

test.describe("Payments Analytics - sections, tabs, and interactive controls", () => {
  test("should render heading, Overview/Amount Metrics sections, Trends tabs, ONE DAY toggle and a date-range button", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    const ok = await gotoAnalytics(page, "analytics-payments");
    if (!ok) test.skip(true, "analytics gated off — fallback rendered");

    await expect(page.getByText(/Payments Analytics/i).first()).toBeVisible({
      timeout: 10000,
    });
    await expect(page.getByText(/Payments Overview/i).first()).toBeVisible();
    await expect(page.getByText(/Amount Metrics/i).first()).toBeVisible();

    await expect(page.getByText(/Payments Trends/i).first()).toBeVisible();
    await expect(page.getByText(/Connector/i).first()).toBeVisible();
    await expect(page.getByText(/Payment Method/i).first()).toBeVisible();

    await expect(page.getByText("ONE DAY").first()).toBeVisible();

    const dateRange = page
      .getByRole("button")
      .filter({ hasText: /[A-Z][a-z]{2} \d+, \d{4}/ })
      .first();
    await expect(dateRange).toBeVisible();
  });

  test("should reveal 'Add more tabs' popover when clicking the + button", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    const ok = await gotoAnalytics(page, "analytics-payments");
    if (!ok) test.skip(true, "analytics gated off");

    const plusBtn = page
      .getByRole("button", { name: "+", exact: true })
      .first();
    await expect(plusBtn).toBeVisible({ timeout: 10000 });
    await plusBtn.click();
    await expect(page.getByText(/Add more tabs/i).first()).toBeVisible({
      timeout: 8000,
    });
  });
});

test.describe("Refunds Analytics - empty state", () => {
  test("should expose 'Make a Payment' CTA on the empty Refunds Analytics page", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    const ok = await gotoAnalytics(page, "analytics-refunds");
    if (!ok) test.skip(true, "refunds analytics gated off");

    await expect(page.getByText(/Refunds Analytics/i).first()).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.getByRole("button", { name: /Make a Payment/i }).first(),
    ).toBeVisible({ timeout: 10000 });
  });
});
