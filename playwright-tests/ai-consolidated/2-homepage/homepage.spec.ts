import { test, expect } from "../../support/test";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("Homepage - extended copy and CTAs", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
  });

  test("should display 'it's great to see you' greeting heading", async ({
    page,
  }) => {
    await expect(page.getByText(/it's great to see you/i).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("should render 'Developer resources' section on home", async ({
    page,
  }) => {
    await expect(page.getByText(/Developer resources/i).first()).toBeVisible({
      timeout: 10000,
    });
  });

  test("should render a Visit button for developer resources that is enabled", async ({
    page,
  }) => {
    const visit = page.getByRole("button", { name: "Visit" }).first();
    await expect(visit).toBeVisible({ timeout: 10000 });
    await expect(visit).toBeEnabled();
  });
});

test.describe("Homepage - top bar user chip", () => {
  test("should display logged-in email in the top-right user chip", async ({
    page,
    context,
  }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });

    await expect(page.getByText(email).first()).toBeVisible({
      timeout: 10000,
    });
  });
});
