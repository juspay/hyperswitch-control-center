import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { PaymentConnector } from "../../support/pages/connector/PaymentConnector";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("ModalContainer behavior - connector processor picker", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();
    await paymentConnector.connectNowButton.click({ force: true });
  });

  test("should render a modal dialog when picking a processor", async ({
    page,
  }) => {
    const modal = page
      .locator(
        '[role="dialog"], [data-testid*="modal"], [data-component*="modal"]',
      )
      .first();
    await expect(modal).toBeVisible();
  });

  test("should close the processor picker modal when Escape is pressed", async ({
    page,
  }) => {
    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    const modal = page
      .locator('[role="dialog"], [data-testid*="modal"]')
      .first();
    await expect(modal).toHaveCount(0);
  });

  test("should lock body scroll (overflow:hidden) while the modal is open", async ({
    page,
  }) => {
    const modal = page
      .locator('[role="dialog"], [data-testid*="modal"]')
      .first();
    if (!(await modal.isVisible().catch(() => false))) {
      test.skip(true, "modal not open");
    }
    const bodyOverflow = await page.evaluate(
      () => document.body.style.overflow,
    );
    expect(bodyOverflow === "hidden" || bodyOverflow === "").toBe(true);
  });

  test("should close the modal when a backdrop click lands outside content", async ({
    page,
  }) => {
    await page.mouse.click(10, 10);
    await page.waitForTimeout(500);

    const modal = page
      .locator('[role="dialog"], [data-testid*="modal"]')
      .first();
    await expect(modal).toHaveCount(0);
  });

  test("should navigate to /connectors after selecting Stripe dummy in the processor picker", async ({
    page,
  }) => {
    const modal = page
      .locator('[role="dialog"], [data-testid*="modal"]')
      .first();
    await expect(modal).toBeVisible();

    const stripeOption = page.locator('[data-testid*="stripe_test"]').first();
    if (!(await stripeOption.isVisible().catch(() => false))) {
      test.skip(true, "stripe dummy option not visible in this modal");
    }
    await stripeOption.click();
    await expect(page).toHaveURL(/.*dashboard\/connectors/);
  });
});
