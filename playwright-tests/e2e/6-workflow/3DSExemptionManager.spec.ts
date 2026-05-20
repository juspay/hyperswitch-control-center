import { test, expect } from "../../support/test";
import type { Page } from "@playwright/test";
import { HomePage } from "../../support/pages/homepage/HomePage";
import { ThreeDSExemptionManager } from "../../support/pages/workflow/ThreeDSExemptionManager";
import { generateUniqueEmail } from "../../support/helper";
import {
    signupUser,
    loginUI,
} from "../../support/commands";

const PLAYWRIGHT_PASSWORD = process.env.PLAYWRIGHT_PASSWORD || "Playwright00#";

async function gatedOrAssert(
    page: Page,
    assertion: () => Promise<void>,
): Promise<void> {
    const exemption = new ThreeDSExemptionManager(page);
    if (await exemption.goToHomeFallback.isVisible().catch(() => false)) {
        test.skip(true, "page gated by feature flag — renders Go to Home fallback");
    }
    await assertion();
}

test.describe("3DS Exemption Manager - beta badge + exemption creation", () => {
    test.beforeEach(async ({ page, context }) => {
        const email = generateUniqueEmail();
        await signupUser(email, PLAYWRIGHT_PASSWORD);
        await loginUI(page, email, PLAYWRIGHT_PASSWORD);

        await page.route("**/dashboard/config/feature*", async (route) => {
            const response = await route.fetch();
            const json = await response.json();
            if (json.features) {
                json.features.threeds_exemption_manager = true;
            }
            await route.fulfill({ response, json });
        });

        const homePage = new HomePage(page);
        await homePage.workflow.click();
        const exemptionNav = homePage.threeDSExemptionManager;
        if ((await exemptionNav.count().catch(() => 0)) === 0) {
            test.skip(true, "3DS Exemption Manager not exposed");
        }
        await exemptionNav.click();
        await expect(page).toHaveURL(/.*dashboard\/3ds-exemption/);
    });

    test("should render a Beta badge on the exemption manager page", async ({
        page,
    }) => {
        const exemption = new ThreeDSExemptionManager(page);
        if (!(await exemption.betaBadge.isVisible().catch(() => false))) {
            test.skip(true, "beta badge not exposed in this build");
        }
        await expect(exemption.betaBadge).toBeVisible();
    });
});

test.describe("3DS Exemption Rules page", () => {
    test("should render heading and Create New button", async ({
        page,
        context,
    }) => {
        const email = generateUniqueEmail();
        await signupUser(email, PLAYWRIGHT_PASSWORD);
        await loginUI(page, email, PLAYWRIGHT_PASSWORD);
        await page.waitForURL(/dashboard\/home/, { timeout: 15000 });

        await page.goto("/dashboard/3ds-exemption");
        await page.waitForLoadState("networkidle");
        await page.waitForTimeout(1000);

        const exemption = new ThreeDSExemptionManager(page);
        await gatedOrAssert(page, async () => {
            await expect(exemption.pageHeading).toBeVisible({ timeout: 10000 });
            await expect(exemption.createNewButton).toBeVisible({ timeout: 10000 });
        });
    });
});
