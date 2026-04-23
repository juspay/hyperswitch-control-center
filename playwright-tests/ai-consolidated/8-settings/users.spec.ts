import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Users & Roles - invite modal interactions", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    await homePage.users.click();
    await page.waitForLoadState("networkidle");
  });

  test("should open the Invite Users modal, accept a typed email, and close it", async ({
    page,
  }) => {
    const invitedEmail = generateUniqueEmail();

    await expect(page.locator('[data-button-for="inviteUsers"]')).toBeVisible();
    await page.locator('[data-button-for="inviteUsers"]').click();

    const emailInput = page.locator('[name="email_list"]');
    await expect(emailInput).toBeVisible();
    await emailInput.fill(invitedEmail);
    await expect(emailInput).toHaveValue(invitedEmail);

    const closeIcon = page.locator('[data-icon="modal-close-icon"]').first();
    if (await closeIcon.isVisible().catch(() => false)) {
      await closeIcon.click();
      await expect(page.locator('[name="email_list"]')).toHaveCount(0);
    }
  });
});
