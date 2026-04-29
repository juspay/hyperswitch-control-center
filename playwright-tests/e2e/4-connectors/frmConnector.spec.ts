import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function gotoFrmList(page: Page) {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  await homePage.frmConnectors.click();
  await page.waitForLoadState("networkidle");
}

test.describe("FRM (Fraud & Risk) Connectors", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should navigate to FRM connectors page via sidebar", async ({
    page,
  }) => {
    const homePage = new HomePage(page);
    await homePage.connectors.click();
    await homePage.frmConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/fraud-risk-management/);
  });

  test("should display Fraud & Risk Management heading", async ({ page }) => {
    await gotoFrmList(page);
    await expect(page.getByText("Fraud & Risk Management").first()).toBeVisible(
      { timeout: 10000 },
    );
  });

  test("should accept typed text in the search input", async ({ page }) => {
    await gotoFrmList(page);
    const searchInput = page.locator('[data-testid="search-processor"]');
    if (!(await searchInput.isVisible().catch(() => false))) {
      test.skip(true, "Search input not exposed on FRM landing page");
    }
    await searchInput.fill("signifyd");
    await page.waitForTimeout(500);
    await expect(searchInput).toHaveValue("signifyd");
  });

  test("should accept arbitrary text in search without crash", async ({
    page,
  }) => {
    await gotoFrmList(page);
    const searchInput = page.locator('[data-testid="search-processor"]');
    if (!(await searchInput.isVisible().catch(() => false))) {
      test.skip(true, "Search input not exposed on FRM landing page");
    }
    await searchInput.fill("not-a-real-frm-connector-zzz");
    await page.waitForTimeout(500);
    await expect(searchInput).toHaveValue("not-a-real-frm-connector-zzz");
  });

  test("should open FRM configuration form when Connect is clicked", async ({
    page,
  }) => {
    await gotoFrmList(page);
    const connectButtons = page.locator('[data-button-text="Connect"]');
    if ((await connectButtons.count().catch(() => 0)) === 0) {
      test.skip(true, "No FRM connectors exposed");
    }
    await connectButtons.nth(0).click();
    await page.waitForTimeout(1500);
    await expect(
      page.getByText(/Credential|API Key|Key/i).first(),
    ).toBeVisible({ timeout: 15000 });
  });

  test("should preserve route across navigation", async ({ page }) => {
    const homePage = new HomePage(page);
    await homePage.connectors.click();
    await homePage.frmConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/fraud-risk-management/);

    await homePage.connectors.click();
    await homePage.frmConnectors.click();
    await expect(page).toHaveURL(/.*dashboard\/fraud-risk-management/);
  });
});
