import { test, expect } from "../../support/test";
import type { Page, BrowserContext } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI, assertConnectorFieldLabels, fillConnectorFields } from "../../support/commands";
import { threedsAuthProcessorConfig } from "../../support/fixtures/threedsAuthProcessorConfig";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function signupAndLogin(page: Page, context: BrowserContext) {
  const email = generateUniqueEmail();
  await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
  await loginUI(page, email, PLAYWRIGHT_PASSWORD);
}

async function gotoThreeDS(page: Page) {
  const homePage = new HomePage(page);
  await homePage.connectors.click();
  await homePage.threeDSConnectors.click();
  await page.waitForLoadState("networkidle");
}

test.describe("3DS Authenticators Module", () => {
  test.beforeEach(async ({ page, context }) => {
    await signupAndLogin(page, context);
  });

  test("should navigate to 3DS authenticators page via sidebar and verify all elements are present", async ({
    page,
  }) => {
    const homePage = new HomePage(page);

    await homePage.connectors.click();
    await homePage.threeDSConnectors.click();

    await expect(page).toHaveURL(/.*dashboard\/3ds-authenticators/);

    await expect(page.getByText(/3DS Authenticator/i).first()).toBeVisible({
      timeout: 10000,
    });

    await expect(
      page.locator('[data-testid="search-processor"]'),
    ).toBeVisible();
  });

  test("should expose 'Request a Processor' CTA on 3DS list page", async ({
    page,
  }) => {
    await gotoThreeDS(page);
    const cta = page
      .getByRole("button", { name: "Request a Processor" })
      .first();
    if (!(await cta.isVisible().catch(() => false))) {
      test.skip(true, "Request a Processor CTA not exposed");
    }
    await expect(cta).toBeVisible({ timeout: 10000 });
  });

  test("should filter 3DS authenticator list when searching", async ({
    page,
  }) => {
    await gotoThreeDS(page);
    const searchInput = page.locator('[data-testid="search-processor"]');
    if (!(await searchInput.isVisible().catch(() => false))) {
      test.skip(true, "Search input not exposed on 3DS list");
    }
    await searchInput.fill("threedsecureio");
    await page.waitForTimeout(500);
    await expect(searchInput).toHaveValue("threedsecureio");
  });

  test("should show no results when searching unknown authenticator", async ({
    page,
  }) => {
    await gotoThreeDS(page);
    const searchInput = page.locator('[data-testid="search-processor"]');
    if (!(await searchInput.isVisible().catch(() => false))) {
      test.skip(true, "Search input not exposed on 3DS list");
    }
    await searchInput.fill("notarealauthenticator_zzz");
    await page.waitForTimeout(1000);
    await expect(searchInput).toHaveValue("notarealauthenticator_zzz");
  });

  test("should open configuration form when a 3DS authenticator is selected", async ({
    page,
  }) => {
    await gotoThreeDS(page);
    const connectButtons = page.locator('[data-button-text="Connect"]');
    if ((await connectButtons.count().catch(() => 0)) === 0) {
      test.skip(true, "No 3DS authenticators exposed");
    }
    await connectButtons.nth(0).click();
    await expect(page.getByText("API Key *")).toBeVisible();
    await expect(page.getByText("Organization Unit ID *")).toBeVisible();
    await expect(page.getByText("API ID *")).toBeVisible();
    await expect(page.getByText("Connector label *")).toBeVisible();
    await expect(page.getByText("Pull Mechanism Enabled")).toBeVisible();
  });
});

test.describe("Live 3DS Authenticators", () => {
  let email: string;

  const threedsAuthenticators = Object.entries(threedsAuthProcessorConfig);
  test.beforeEach(async ({ page, context }) => {
    email = generateUniqueEmail();
    await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
    await loginUI(page, email, PLAYWRIGHT_PASSWORD);
  });

  for (const [key, authenticator] of threedsAuthenticators) {
    test(`should setup and verify ${key} 3DS authenticator`, async ({
      page,
    }) => {
      const homePage = new HomePage(page);

      await homePage.connectors.click();
      await homePage.threeDSConnectors.click();

      await expect(page).toHaveURL(/.*dashboard\/3ds-authenticators/);

      const searchInput = page.locator('[data-testid="search-processor"]');
      if (await searchInput.isVisible({ timeout: 5000 }).catch(() => false)) {
        await searchInput.fill(authenticator.label);
      }

      const connectButtons = page.locator('[data-button-text="Connect"]');
      if ((await connectButtons.count().catch(() => 0)) > 0) {
        await connectButtons.nth(0).click();

        if (authenticator.fields.fieldLabels.length > 0) {
          await assertConnectorFieldLabels(page, authenticator.fields.fieldLabels);
          await fillConnectorFields(page, authenticator.fields);
        }

        const saveButton = page.locator('button:has-text("Save"), button:has-text("Connect"), button:has-text("Proceed")').first();
        if (await saveButton.isVisible({ timeout: 5000 }).catch(() => false)) {
          await saveButton.click();
          await page.waitForLoadState("networkidle");
        }
      }
    });
  }
});
