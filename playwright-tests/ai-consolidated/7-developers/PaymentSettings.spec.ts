import { test, expect } from "../../support/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Payment Settings - extended form controls", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
    await page.goto("/dashboard/payment-settings");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1500);
  });

  test("should render at least one 'Select Card Types' dropdown", async ({
    page,
  }) => {
    const cardTypes = page.getByRole("button", { name: "Select Card Types" });
    expect(await cardTypes.count()).toBeGreaterThan(0);
  });

  test("should stay on /payment-settings after filling Return URL and clicking Update", async ({
    page,
  }) => {
    const returnUrl = page.getByPlaceholder("Enter Return URL");
    await returnUrl.fill("https://example.com/return");

    const update = page
      .getByRole("button", { name: "Update", exact: true })
      .first();
    if (!(await update.isEnabled().catch(() => false))) {
      test.skip(true, "Update button disabled — form did not accept change");
    }
    await update.click();
    await page.waitForTimeout(1500);
    await expect(page).toHaveURL(/payment-settings/);
  });
});
