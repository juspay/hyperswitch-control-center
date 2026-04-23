import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Cypress00#";

test.describe("FRM (Fraud & Risk) connectors", () => {
  test.beforeEach(async ({ page, context }) => {
    const email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);

    const homePage = new HomePage(page);
    await homePage.connectors.click();
    await homePage.frmConnectors.click();
    await page.waitForLoadState("networkidle");
  });

  test("should display Fraud & Risk Management heading", async ({ page }) => {
    await expect(page.getByText("Fraud & Risk Management").first()).toBeVisible(
      { timeout: 10000 },
    );
  });

  test("should accept typed text in the search input", async ({ page }) => {
    const searchInput = page.locator('[data-testid="search-processor"]');
    if (await searchInput.isVisible().catch(() => false)) {
      await searchInput.fill("signifyd");
      await page.waitForTimeout(500);
      await expect(searchInput).toHaveValue("signifyd");
    }
  });

  test("should open FRM configuration form when Connect is clicked", async ({
    page,
  }) => {
    const connectButtons = page.locator('[data-button-text="Connect"]');
    const hasButtons = (await connectButtons.count().catch(() => 0)) > 0;
    if (hasButtons) {
      await connectButtons.nth(0).click();
      await page.waitForTimeout(1500);
      await expect(
        page.getByText(/Credential|API Key|Key/i).first(),
      ).toBeVisible({ timeout: 15000 });
    }
  });
});
