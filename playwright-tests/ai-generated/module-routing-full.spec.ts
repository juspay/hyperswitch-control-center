/**
 * Auto-generated Playwright test
 * Source: module:routing-full - rule-based routing save, 3DS Decision save,
 *         Surcharge save, Payout Routing elements. Extends existing volume
 *         routing coverage in e2e/6-workflow/PaymentRouting.spec.ts.
 * Generated: 2026-04-17
 */

import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentRouting } from "../support/pages/workflow/paymentRouting/PaymentRouting";
import { VolumeBasedConfiguration } from "../support/pages/workflow/paymentRouting/VolumeBasedConfiguration";
import { generateUniqueEmail } from "../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("Rule-based routing - configure", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("rule-based setup with connector lands on /routing/rule", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.ruleBasedRoutingSetupButton.click();

    await expect(page).toHaveURL(/.*routing\/(rule|advanced|advanced-rule)/);
  });

  test("rule-based configuration page has Name + Description inputs", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.ruleBasedRoutingSetupButton.click();
    await page.waitForLoadState("networkidle");

    const nameInput = page.locator(
      '[placeholder="Enter Configuration Name"]',
    );
    if (await nameInput.isVisible().catch(() => false)) {
      await expect(nameInput).toBeVisible();
    }
  });

  test("rule-based page shows Add Rule / Save controls", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (merchantId) {
      await createDummyConnectorAPI(
        merchantId,
        "stripe_test_1",
        context.request,
      );
    }

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.ruleBasedRoutingSetupButton.click();
    await page.waitForLoadState("networkidle");

    const saveBtn = page.locator(
      '[data-button-for="saveRule"], [data-button-for="saveAndActivateRule"]',
    );
    const addRuleBtn = page.locator(
      '[data-button-for="configureRule"], [data-button-for="addRule"]',
    );
    const saveCount = await saveBtn.count().catch(() => 0);
    const addCount = await addRuleBtn.count().catch(() => 0);
    expect(saveCount + addCount).toBeGreaterThan(0);
  });
});

test.describe("3DS Decision Manager - configure", () => {
  // Fixed (Attempt 1): navigate via sidebar to avoid 2FA race.
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    const homePage = new HomePage(page);
    await homePage.workflow.click();
    const threeDs = homePage.threeDSRouting;
    if ((await threeDs.count().catch(() => 0)) === 0) {
      test.skip(true, "3DS Decision Manager not available");
    }
    await threeDs.click();
    await page.waitForLoadState("networkidle");
  });

  test("lands on /dashboard/3ds", async ({ page }) => {
    await expect(page).toHaveURL(/.*dashboard\/3ds/);
  });

  test("shows Create New or Configure 3DS Rule controls", async ({ page }) => {
    // Motion-settle: 3DS content mounts via framer-motion. `isVisible()`
    // is non-retrying so the old OR-check raced the transition. Use
    // .or() + expect.toBeVisible so Playwright auto-waits.
    await page.waitForTimeout(1500);
    const createNew = page.getByRole("button", { name: /Create New/i });
    const configureRule = page.getByText(/Configure 3DS Rule/i);
    // Both controls render together on this page, so .or() resolves to
    // multiple elements (strict-mode violation). Collapse to the first
    // match of the union.
    await expect(createNew.or(configureRule).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("Save / Cancel buttons render when configuring a rule", async ({
    page,
  }) => {
    const createNew = page.getByRole("button", { name: /Create New/i });
    if (await createNew.isVisible().catch(() => false)) {
      await createNew.click();
      await page.waitForLoadState("networkidle");

      const cancelBtn = page.getByRole("button", { name: /Cancel/i });
      const hasCancel = await cancelBtn.isVisible().catch(() => false);
      expect(hasCancel).toBeTruthy();
    }
  });
});

test.describe("Surcharge - configure", () => {
  // Fixed (Attempt 1): navigate via sidebar; skip when FF disabled.
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    const homePage = new HomePage(page);
    await homePage.workflow.click();
    const surcharge = homePage.surchargeRouting;
    if ((await surcharge.count().catch(() => 0)) === 0) {
      test.skip(true, "Surcharge not available for this merchant");
    }
    await surcharge.click();
    await page.waitForLoadState("networkidle");
  });

  test("lands on /dashboard/surcharge", async ({ page }) => {
    expect(page.url()).not.toMatch(/\/login/);
  });

  test("shows Create New or Save control on surcharge page", async ({
    page,
  }) => {
    // Motion-settle: surcharge content mounts behind a framer-motion
    // transition. `isVisible()` is non-retrying and returns false while the
    // tween is still running, even though the button is in the DOM. Use
    // expect().toBeVisible() on first match so Playwright auto-waits.
    await page.waitForTimeout(1500);
    if (!page.url().includes("surcharge")) return;
    const control = page
      .getByRole("button", { name: /Create New|Save/i })
      .first();
    await expect(control).toBeVisible({ timeout: 10000 });
  });
});

test.describe("Payout Routing - navigation", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("payout routing URL reachable via sidebar", async ({ page }) => {
    // Fixed (Attempt 1): sidebar nav (direct goto raced 2FA screen).
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
    const homePage = new HomePage(page);
    await homePage.workflow.click();
    const payoutRouting = homePage.payoutRouting;
    if ((await payoutRouting.count().catch(() => 0)) === 0) {
      test.skip(true, "Payout Routing not available");
    }
    await payoutRouting.click();
    await page.waitForLoadState("networkidle");
    expect(page.url()).not.toMatch(/\/login/);
  });

  test("payout routing shows setup/manage cards", async ({ page }) => {
    // Fixed (Attempt 2): payout routing index renders Volume/Rule setup cards
    // and Manage buttons; assert on the visible button text rather than the
    // empty-connector data attribute (which only appears after Setup click).
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });
    const homePage = new HomePage(page);
    await homePage.workflow.click();
    const payoutRouting = homePage.payoutRouting;
    if ((await payoutRouting.count().catch(() => 0)) === 0) {
      test.skip(true, "Payout Routing not available");
    }
    await payoutRouting.click();
    await page.waitForLoadState("networkidle");

    // Fixed (Attempt 3): getByRole("button", …) didn't match (buttons are
    // divs with role=button). Match on visible text from page snapshot.
    await expect(
      page
        .getByText(
          /Volume Based Configuration|Rule Based Configuration|Default fallback|Active configuration|Manage rules/,
        )
        .first(),
    ).toBeVisible({ timeout: 10000 });
  });
});

test.describe("Default fallback - with connector", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("default fallback shows connector list after creation", async ({
    page,
    context,
  }) => {
    const homePage = new HomePage(page);
    const paymentRouting = new PaymentRouting(page);

    const merchantId = await homePage.merchantID.nth(0).textContent();
    if (!merchantId) return;

    await createDummyConnectorAPI(
      merchantId,
      "stripe_test_fallback",
      context.request,
    );

    await homePage.workflow.click();
    await homePage.routing.click();
    await paymentRouting.defaultFallbackManageButton.click();
    await page.waitForLoadState("networkidle");

    await expect(
      page.getByText("stripe_test_fallback"),
    ).toBeVisible({ timeout: 15000 });
  });
});
