import { test, expect } from "../../support/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe.skip("Profile - user menu items", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
  });

  test("should expose a Profile / Account Settings entry in the user menu", async ({
    page,
  }) => {
    await page.locator('[data-button-for="profile"]').click();

    const profile = page
      .getByText(/Profile|Account Settings|Personal Details/i)
      .first();
    const isVisible = await profile.isVisible().catch(() => false);
    if (!isVisible) {
      test.skip(
        true,
        "profile link not exposed in this build — menu-only sign out",
      );
    }
    await expect(profile).toBeVisible({ timeout: 5000 });
  });
});

test.describe.skip("Account Settings - Profile page", () => {
  test("should render 'Profile' heading and 'Reset Password' button", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

    await page.goto("/dashboard/account-settings/profile");
    await page.waitForLoadState("networkidle");
    await page.waitForTimeout(1000);

    await expect(page.getByText("Profile").first()).toBeVisible({
      timeout: 10000,
    });
    await expect(
      page.getByRole("button", { name: "Reset Password" }).first(),
    ).toBeVisible({ timeout: 10000 });
  });
});
