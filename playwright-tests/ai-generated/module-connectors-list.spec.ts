/**
 * Auto-generated Playwright test
 * Source: exploration-driven gap fill — Payment processors list page
 * Generated: 2026-04-17
 *
 * /dashboard/connectors surfaced 220 visible buttons during exploration
 * (every processor card has a Connect button). Existing specs test
 * search and config form entry, but not:
 *   - "Connect a Dummy Processor" CTA
 *   - "Request a Processor" CTA
 *   - "Connect Now" featured processor CTA
 *
 * This file covers those top-level list interactions.
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
  await page.goto("/dashboard/connectors");
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(1500);
}

test.describe("Connectors — list page CTAs", () => {
  test("Payment Processors heading renders", async ({ page, context }) => {
    await setup(page, context);
    await expect(page.getByText(/Payment Processors/i).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("Connect a new processor subtitle renders", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    await expect(
      page.getByText(/Connect a new processor/i).first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test("Connect a Dummy Processor CTA is present", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    const dummy = page.getByRole("button", {
      name: "Connect a Dummy Processor",
    });
    // Dummy processor is gated to non-prod builds; skip if absent.
    if ((await dummy.count().catch(() => 0)) === 0) {
      test.skip(true, "Dummy processor not available in this build");
    }
    await expect(dummy.first()).toBeVisible({ timeout: 10000 });
  });

  test("Request a Processor CTA is present", async ({ page, context }) => {
    await setup(page, context);
    await expect(
      page.getByRole("button", { name: "Request a Processor" }).first(),
    ).toBeVisible({ timeout: 10000 });
  });

  test("Connect Now featured CTA is present", async ({ page, context }) => {
    await setup(page, context);
    const connectNow = page.getByRole("button", { name: "Connect Now" });
    if ((await connectNow.count().catch(() => 0)) === 0) {
      test.skip(true, "No featured processor exposed (empty state)");
    }
    await expect(connectNow.first()).toBeVisible({ timeout: 10000 });
  });

  test("processor grid renders many Connect buttons", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    const connectBtns = page.getByRole("button", { name: "Connect" });
    // Under parallel load the connector list API is slow; wait until the
    // grid hydrates before counting.
    await expect(connectBtns.first()).toBeVisible({ timeout: 20000 });
    const count = await connectBtns.count();
    // Exploration showed 220 visible buttons on this page; expect >5
    // Connect buttons for a non-trivial processor list.
    expect(count).toBeGreaterThan(5);
  });

  test("search a processor filters the visible list", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    const search = page.getByPlaceholder("Search a processor");
    await search.fill("adyen");
    await page.waitForTimeout(500);
    // After filtering, "Adyen" must be one of the remaining labels.
    await expect(page.getByText(/adyen/i).first()).toBeVisible({
      timeout: 5000,
    });
  });

  test("search with gibberish yields empty state", async ({
    page,
    context,
  }) => {
    await setup(page, context);
    const search = page.getByPlaceholder("Search a processor");
    await search.fill("nonexistentprocessor_zzzzzzzz");
    await page.waitForTimeout(700);
    // Count visible Connect buttons — should drop to 0 after filter.
    const connectVisible = await page
      .getByRole("button", { name: "Connect", exact: true })
      .filter({ visible: true })
      .count();
    expect(connectVisible).toBe(0);
  });
});
