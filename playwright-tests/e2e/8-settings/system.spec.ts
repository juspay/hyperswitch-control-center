import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { SystemPage } from "../../support/pages/settings/SystemPage";
import { signupUser, loginUI } from "../../support/commands";
import { generateUniqueEmail } from "../../support/helper";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("System", () => {
  let homePage: HomePage;
  let systemPage: SystemPage;
  let email: string;

  test.beforeEach(async ({ page }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
    await page.waitForURL(/dashboard\/home/, { timeout: 20000 });
    homePage = new HomePage(page);
    systemPage = new SystemPage(page);
  });

  test("should render the unauthorized page with a go to home button", async () => {
    await systemPage.navigateToUnauthorized();
    await expect(systemPage.unauthorizedMessage).toBeVisible();
    await expect(systemPage.goToHomeButton).toBeVisible();
  });

  test("should navigate to home from the unauthorized page", async ({
    page,
  }) => {
    await systemPage.navigateToUnauthorized();
    await expect(systemPage.goToHomeButton).toBeVisible();
    await systemPage.clickGoToHome();
    await expect(page).toHaveURL(/home/);
    await expect(homePage.welcomeText).toBeVisible();
  });
});
