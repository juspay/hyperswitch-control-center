/**
 * Auto-generated Playwright test
 * Source: exploration-driven gap fill — /dashboard/home CTA buttons
 * Generated: 2026-04-17
 *
 * Exploration (.opencode/sessions/playwright-run/explore.json) showed the
 * home page exposes 9 visible CTA buttons — "Connect Processors" (×2),
 * "Try It Out" (×2), "Go to API keys" (×2), "Visit" (×2), and the email
 * dropdown. None of the existing ai-generated specs click these cards.
 * This file exercises the navigation outcome of each.
 */

import { test, expect, Page, BrowserContext } from "@playwright/test";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

async function setup(page: Page, context: BrowserContext): Promise<void> {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
  // framer-motion mount settle
  await page.waitForTimeout(1500);
}

test.describe("Home page onboarding CTAs", () => {
  test("Connect Processors card navigates to /dashboard/connectors", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await page
      .getByRole("button", { name: "Connect Processors" })
      .first()
      .click();
    await page.waitForURL(/\/dashboard\/connectors/, { timeout: 15000 });
    await expect(page).toHaveURL(/\/dashboard\/connectors/);
  });

  test("Go to API keys card navigates to developer-api-keys", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await page.getByRole("button", { name: "Go to API keys" }).first().click();
    await page.waitForURL(/\/dashboard\/developer-api-keys/, {
      timeout: 15000,
    });
    await expect(page).toHaveURL(/developer-api-keys/);
  });

  test("Try It Out button is visible and clickable on home", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    const tryIt = page.getByRole("button", { name: "Try It Out" }).first();
    await expect(tryIt).toBeVisible({ timeout: 10000 });
    await expect(tryIt).toBeEnabled();
  });

  test('home greeting heading "it\'s great to see you" renders', async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await expect(
      page.getByText(/it's great to see you/i).first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test('"Developer resources" section renders on home', async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await expect(
      page.getByText(/Developer resources/i).first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test("Visit button (developer resources) is clickable", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    const visit = page.getByRole("button", { name: "Visit" }).first();
    await expect(visit).toBeVisible({ timeout: 10000 });
    await expect(visit).toBeEnabled();
  });
});

test.describe("Top bar — merchant & organization chrome", () => {
  test("merchant account / organization chart region renders", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    // Both labels are present in body text per explore data
    await expect(page.getByText(/Merchant Account/i).first()).toBeVisible({
      timeout: 10000,
    });
    await expect(page.getByText(/Organization Chart/i).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("logged-in email appears in top-right user chip", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
    await page.waitForTimeout(1500);
    await expect(page.getByText(email).first()).toBeVisible({
      timeout: 10000,
    });
  });
});
