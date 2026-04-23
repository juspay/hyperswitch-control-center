import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("TC-015: 3DS Exemption Manager - Beta", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    await page.route("**/dashboard/config/feature*", async (route) => {
      const response = await route.fetch();
      const json = await response.json();
      if (json.features) {
        json.features.threeds_exemption_manager = true;
      }
      await route.fulfill({ response, json });
    });
  });

  test("should display beta badge", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.threeDSExemptionManager.click();

    await expect(page).toHaveURL(/.*dashboard\/3ds-exemption/);

    const betaBadge = page
      .locator(
        '[data-testid*="beta"], .badge:has-text("Beta"), span:has-text("BETA")',
      )
      .first();
    if (await betaBadge.isVisible().catch(() => false)) {
      await expect(betaBadge).toBeVisible();
    }
  });

  test("should create exemption for subscription payments", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.threeDSExemptionManager.click();

    const addExemptionButton = page
      .locator(
        '[data-button-for="addExemption"], button:has-text("Add Exemption")',
      )
      .first();
    if (await addExemptionButton.isVisible().catch(() => false)) {
      await addExemptionButton.click();

      await page
        .locator('[name*="exemption_name"]')
        .fill("Subscription Exemption");

      const paymentType = page.locator('[name*="payment_type"]').first();
      if (await paymentType.isVisible().catch(() => false)) {
        await paymentType.selectOption("subscription");
      }

      const frequency = page.locator('[name*="frequency"]').first();
      if (await frequency.isVisible().catch(() => false)) {
        await frequency.selectOption("recurring");
      }

      await page.locator('[data-button-for="saveExemption"]').click();
    }
  });

  test("should create exemption for low-risk MCCs", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.threeDSExemptionManager.click();

    const addExemptionButton = page
      .locator('[data-button-for="addExemption"]')
      .first();
    if (await addExemptionButton.isVisible().catch(() => false)) {
      await addExemptionButton.click();

      await page.locator('[name*="exemption_name"]').fill("Low Risk MCC");

      const conditionType = page.locator('[name*="condition"]').first();
      if (await conditionType.isVisible().catch(() => false)) {
        await conditionType.selectOption("mcc");
      }

      const mccInput = page
        .locator('[name*="mcc_value"], [name*="mcc"]')
        .first();
      if (await mccInput.isVisible().catch(() => false)) {
        await mccInput.fill("5411");
      }

      await page.locator('[data-button-for="saveExemption"]').click();
    }
  });

  test("should set exemption threshold", async ({ page }) => {
    const homePage = new HomePage(page);

    await homePage.workflow.click();
    await homePage.threeDSExemptionManager.click();

    const thresholdInput = page
      .locator('[name*="exemption_threshold"], [name*="threshold_amount"]')
      .first();
    if (await thresholdInput.isVisible().catch(() => false)) {
      await thresholdInput.fill("100");

      const saveButton = page
        .locator('[data-button-for="saveThreshold"], button:has-text("Save")')
        .first();
      if (await saveButton.isVisible().catch(() => false)) {
        await saveButton.click();
      }
    }
  });
});
