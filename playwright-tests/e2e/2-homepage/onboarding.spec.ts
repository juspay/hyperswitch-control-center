import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

test.describe("Onboarding Survey", () => {
  test.beforeEach(async ({ page }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);

    await page.route("**/accounts/**", async (route) => {
      if (route.request().method() === "GET") {
        const response = await route.fetch();
        const json = await response.json();
        if (json) {
          delete json.merchant_name;
        }
        await route.fulfill({ response, json });
      } else {
        await route.continue();
      }
    });

    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  test("should display the onboarding survey modal with business name field for a new merchant", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await expect(
      page.getByText("Welcome aboard! Let's get started"),
    ).toBeVisible();
    await expect(page.getByText("Business details").first()).toBeVisible();
    await expect(
      page.getByText("Business name *", { exact: true }),
    ).toBeVisible();
    await expect(homePage.enterMerchantName).toBeVisible();
    await expect(homePage.onboardingSubmitButton).toBeVisible();
    await expect(homePage.onboardingSubmitButton).toContainText(
      "Start Exploring",
    );
  });

  test("should submit merchant name via survey form and show success toast", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await expect(
      page.getByText("Welcome aboard! Let's get started"),
    ).toBeVisible();
    await homePage.enterMerchantName.fill("Playwright Test Corp");
    await homePage.onboardingSubmitButton.click();

    await expect(
      page.getByText("Successfully updated onboarding survey"),
    ).toBeVisible();
  });
});
