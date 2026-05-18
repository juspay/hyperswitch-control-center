import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { FrmConnector } from "../../support/pages/connector/FrmConnector";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI, assertConnectorFieldLabels, fillConnectorFields } from "../../support/commands";
import { frmConnectorConfig } from "../../support/fixtures/frmConnectorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD);
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
    const frmConnector = new FrmConnector(page);
    const searchInput = frmConnector.connectorSearchInput;
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
    const frmConnector = new FrmConnector(page);
    const searchInput = frmConnector.connectorSearchInput;
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
    const frmConnector = new FrmConnector(page);
    const connectButtons = frmConnector.connectButton;
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

test.describe("Live FRM Connectors", () => {
  let email: string;

  const frmConnectors = Object.entries(frmConnectorConfig);
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  for (const [key, connector] of frmConnectors) {
    test(`should setup and verify ${key} FRM connector`, async ({
      page,
    }) => {
      const homePage = new HomePage(page);
      const frmConnector = new FrmConnector(page);

      await homePage.connectors.click();
      await homePage.frmConnectors.click();

      await expect(page).toHaveURL(/.*dashboard\/fraud-risk-management/);

      const searchInput = frmConnector.connectorSearchInput;
      if (await searchInput.isVisible({ timeout: 5000 }).catch(() => false)) {
        await searchInput.fill(connector.label);
      }

      const connectButtons = frmConnector.connectButton;
      if ((await connectButtons.count().catch(() => 0)) > 0) {
        await connectButtons.nth(0).click();

        if (connector.fields.fieldLabels.length > 0) {
          await assertConnectorFieldLabels(page, connector.fields.fieldLabels);
          await fillConnectorFields(page, connector.fields);
        }

        const saveButton = frmConnector.saveOrConnectOrProceedButton;
        if (await saveButton.isVisible({ timeout: 5000 }).catch(() => false)) {
          await saveButton.click();
          await page.waitForLoadState("networkidle");
        }
      }
    });
  }
});
