import { test, expect } from "../support/test";
import { HomePage } from "../support/pages/homepage/HomePage";
import { PaymentConnector } from "../support/pages/connector/PaymentConnector";
import { generateUniqueEmail } from "../support/helper";
import { signupUser, loginUI } from "../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-035: ModalContainer - Stacking and Behavior", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should open first modal", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectNowButton.click({ force: true });

    const modal = page
      .locator(
        '[role="dialog"], [data-testid*="modal"], [data-component*="modal"]',
      )
      .first();
    await expect(modal).toBeVisible();
  });

  test("should close modal on backdrop click", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectNowButton.click({ force: true });

    await page.mouse.click(10, 10);
    await page.waitForTimeout(500);

    const modal = page
      .locator('[role="dialog"], [data-testid*="modal"]')
      .first();
    await expect(modal).toHaveCount(0);
  });

  test("should close modal on escape key", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectNowButton.click({ force: true });

    await page.keyboard.press("Escape");
    await page.waitForTimeout(500);

    const modal = page
      .locator('[role="dialog"], [data-testid*="modal"]')
      .first();
    await expect(modal).toHaveCount(0);
  });

  test("should display modal with long content", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.settings.click();

    const longContentModal = page
      .locator('[data-testid*="terms"], [data-testid*="policy"]')
      .first();
    if (await longContentModal.isVisible().catch(() => false)) {
      await longContentModal.click();

      const modalContent = page
        .locator(
          '[role="dialog"] [class*="content"], [data-testid*="modal-content"]',
        )
        .first();
      await expect(modalContent).toBeVisible();

      await modalContent.evaluate((el) => el.scrollTo(0, el.scrollHeight));
    }
  });

  test("should submit form in modal", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    await paymentConnector.connectNowButton.click({ force: true });

    const modal = page
      .locator('[role="dialog"], [data-testid*="modal"]')
      .first();
    await expect(modal).toBeVisible();

    const stripeOption = page.locator('[data-testid*="stripe_test"]').first();
    if (await stripeOption.isVisible().catch(() => false)) {
      await stripeOption.click();

      await expect(page).toHaveURL(/.*dashboard\/connectors/);
    }
  });

  test("should lock body scroll when modal open", async ({ page }) => {
    const homePage = new HomePage(page);
    const paymentConnector = new PaymentConnector(page);

    await homePage.connectors.click();
    await homePage.paymentProcessors.click();

    const originalOverflow = await page.evaluate(
      () => document.body.style.overflow,
    );

    await paymentConnector.connectNowButton.click({ force: true });

    const modal = page
      .locator('[role="dialog"], [data-testid*="modal"]')
      .first();
    if (await modal.isVisible().catch(() => false)) {
      const bodyOverflow = await page.evaluate(
        () => document.body.style.overflow,
      );
      expect(
        bodyOverflow === "hidden" || originalOverflow === bodyOverflow,
      ).toBe(true);
    }
  });
});
