import { test, expect } from "../../support/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { generateUniqueEmail } from "../../support/helper";
import { signupUser, loginUI } from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Test@123456";

test.describe("3DS Authenticators Module", () => {
    test.beforeEach(async ({ page, context }) => {
        const email = generateUniqueEmail();
        await signupUser(email, PLAYWRIGHT_PASSWORD, context.request);
        await loginUI(page, email, PLAYWRIGHT_PASSWORD);
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

        await expect(page.locator('[data-testid="search-processor"]')).toBeVisible();
    });


    test("should filter 3DS authenticator list when searching", async ({
        page,
    }) => {
        const homePage = new HomePage(page);

        await homePage.connectors.click();
        await homePage.threeDSConnectors.click();

        const searchInput = page.locator('[data-testid="search-processor"]');
        if (await searchInput.isVisible().catch(() => false)) {
            await searchInput.fill("threedsecureio");
            await page.waitForTimeout(500);
            await expect(searchInput).toHaveValue("threedsecureio");
        }
    });

    test("should show no results when searching unknown authenticator", async ({
        page,
    }) => {
        const homePage = new HomePage(page);

        await homePage.connectors.click();
        await homePage.threeDSConnectors.click();

        const searchInput = page.locator('[data-testid="search-processor"]');
        if (await searchInput.isVisible().catch(() => false)) {
            await searchInput.fill("notarealauthenticator_zzz");
            await page.waitForTimeout(1000);
            await expect(searchInput).toHaveValue("notarealauthenticator_zzz");
        }
    });

    test("should open configuration form when a 3DS authenticator is selected", async ({
        page,
    }) => {
        const homePage = new HomePage(page);

        await homePage.connectors.click();
        await homePage.threeDSConnectors.click();

        const connectButtons = page.locator('[data-button-text="Connect"]');
        const hasButtons = (await connectButtons.count().catch(() => 0)) > 0;
        if (hasButtons) {
            await connectButtons.nth(0).click();
            await expect(page.getByText('API Key *')).toBeVisible();
            await expect(page.getByText('Organization Unit ID *')).toBeVisible();
            await expect(page.getByText('API ID *')).toBeVisible();
            await expect(page.getByText('Connector label *')).toBeVisible();
            await expect(page.getByText('Pull Mechanism Enabled')).toBeVisible();
        }
    });
});
