import { test, expect } from "./support/test";
import { generateUniqueEmail } from "./support/helper";
import { signupUser, loginUI } from "./support/commands";

test.describe("Sign In - Happy Flow", () => {
  const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";
  let email: string;

  test.beforeEach(async ({ page }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, page.context().request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should successfully login with valid credentials", async ({ page }) => {
    await expect(page).toHaveURL(/.*dashboard\/home/);
  });
});
