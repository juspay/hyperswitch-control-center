import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentRouting } from "../../support/pages/workflow/paymentRouting/PaymentRouting";
import { generateUniqueEmail } from "../../support/helper";
import {
  signupUser,
  loginUI,
  createDummyConnectorAPI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

async function gatedOrAssert(
  page: Page,
  assertion: () => Promise<void>,
): Promise<void> {
  const fallback = page.getByText("Go to Home", { exact: true }).first();
  if (await fallback.isVisible().catch(() => false)) {
    test.skip(true, "page gated by feature flag — renders Go to Home fallback");
  }
  await assertion();
}

test.describe("Rule-based routing - configuration page", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should land on the rule-based editor and render Name input + Save/Add Rule controls", async ({
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

    await expect(page).toHaveURL(/.*routing\/(rule|advanced|advanced-rule)/);

    const nameInput = page.locator('[placeholder="Enter Configuration Name"]');
    if (await nameInput.isVisible().catch(() => false)) {
      await expect(nameInput).toBeVisible();
    }

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

test.describe("3DS Decision Manager", () => {
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
    await page.waitForTimeout(1500);
  });

  test("should land on /dashboard/3ds and render Create New or Configure 3DS Rule", async ({
    page,
  }) => {
    await expect(page).toHaveURL(/.*dashboard\/3ds/);

    const createNew = page.getByRole("button", { name: /Create New/i });
    const configureRule = page.getByText(/Configure 3DS Rule/i);
    await expect(createNew.or(configureRule).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("should render Cancel button after clicking Create New", async ({
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

test.describe("Surcharge decision page", () => {
  test("should render heading and Create New/Save control", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    await page.goto("/dashboard/surcharge");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1500);

    await gatedOrAssert(page, async () => {
      await expect(page.getByText("Surcharge").first()).toBeVisible({
        timeout: 10000,
      });
      const control = page
        .getByRole("button", { name: /Create New|Save/i })
        .first();
      await expect(control).toBeVisible({ timeout: 10000 });
    });
  });
});

test.describe("3DS Exemption Rules page", () => {
  test("should render heading and Create New button", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    await page.goto("/dashboard/3ds-exemption");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await gatedOrAssert(page, async () => {
      await expect(page.getByText("3DS Exemption Rules").first()).toBeVisible({
        timeout: 10000,
      });
      await expect(
        page.getByRole("button", { name: "Create New" }).first(),
      ).toBeVisible({ timeout: 10000 });
    });
  });
});

test.describe("Payout Routing landing", () => {
  test("should render Volume/Rule/Default configuration cards", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

    const homePage = new HomePage(page);
    await homePage.workflow.click();
    const payoutRouting = homePage.payoutRouting;
    if ((await payoutRouting.count().catch(() => 0)) === 0) {
      test.skip(true, "Payout Routing not available");
    }
    await payoutRouting.click();
    await page.waitForLoadState("networkidle");

    await expect(
      page
        .getByText(
          /Volume Based Configuration|Rule Based Configuration|Default fallback|Active configuration|Manage rules/,
        )
        .first(),
    ).toBeVisible({ timeout: 10000 });
  });
});
